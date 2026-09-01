package com.google.android.apps.inputmethod.libs.hmm;

import android.os.Handler;
import android.os.Looper;

import com.google.android.apps.inputmethod.libs.framework.core.Candidate;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

/** Replayable view over one composing generation's original Candidate objects. */
public final class StrokeFilterCandidateSession {
    public static final int IDLE = 0;
    public static final int SCANNING = 1;
    public static final int READY = 2;
    public static final int NO_MATCH = 3;

    static final int SCAN_BUDGET = 256;
    static final int CACHE_LIMIT = 8192;

    int composingGeneration;
    int filterGeneration;
    Iterator<Candidate> sourceIterator;
    final ArrayList<Candidate> rawCandidateCache = new ArrayList<Candidate>();
    int rawCursor;
    boolean sourceExhausted;
    boolean cacheLimitReached;
    Candidate firstMatchedCandidateForFilter;
    Runnable pendingRunnable;
    int state = IDLE;
    boolean valid;

    private final Handler handler = new Handler(Looper.getMainLooper());

    public void bind(Iterator<Candidate> source) {
        cancelPending();
        composingGeneration++;
        filterGeneration++;
        sourceIterator = source;
        rawCandidateCache.clear();
        rawCursor = 0;
        sourceExhausted = source == null;
        cacheLimitReached = false;
        firstMatchedCandidateForFilter = null;
        state = IDLE;
        valid = source != null;
    }

    public void resetFilter() {
        cancelPending();
        filterGeneration++;
        rawCursor = 0;
        firstMatchedCandidateForFilter = null;
        state = IDLE;
    }

    public void destroy() {
        cancelPending();
        composingGeneration++;
        filterGeneration++;
        sourceIterator = null;
        rawCandidateCache.clear();
        rawCursor = 0;
        sourceExhausted = true;
        cacheLimitReached = false;
        firstMatchedCandidateForFilter = null;
        state = IDLE;
        valid = false;
    }

    public void cancelPending() {
        if (pendingRunnable != null) {
            handler.removeCallbacks(pendingRunnable);
            pendingRunnable = null;
        }
    }

    public boolean request(
            final AbstractHmmDecodeProcessor ime,
            final int requested,
            final String prefix,
            final StrokeFilterData data) {
        if (!valid || requested <= 0 || prefix == null || prefix.length() == 0 || data == null) {
            return false;
        }
        cancelPending();
        final int expectedComposing = composingGeneration;
        final int expectedFilter = filterGeneration;
        ArrayList<Candidate> output = new ArrayList<Candidate>();
        int scanned = 0;

        while (output.size() < requested && scanned < SCAN_BUDGET) {
            if (!tokensMatch(expectedComposing, expectedFilter)) {
                return true;
            }
            Candidate candidate = nextRawCandidate(expectedComposing, expectedFilter);
            if (candidate == null) {
                break;
            }
            scanned++;
            if (matches(candidate, prefix, data)) {
                if (!tokensMatch(expectedComposing, expectedFilter)) {
                    return true;
                }
                output.add(candidate);
                if (firstMatchedCandidateForFilter == null) {
                    firstMatchedCandidateForFilter = candidate;
                }
            }
        }

        if (cacheLimitReached) {
            StrokeFilterCompat.failOpenFromSession(ime, this);
            ime.doUpdateTextCandidates(true);
            return true;
        }

        if (!tokensMatch(expectedComposing, expectedFilter)) {
            return true;
        }
        boolean hasUnread = hasUnreadRawCandidate();
        if (output.size() < requested && hasUnread) {
            state = SCANNING;
        } else if (firstMatchedCandidateForFilter == null && sourceExhausted) {
            state = NO_MATCH;
        } else {
            state = READY;
        }
        ime.doAppendTextCandidates(output, firstMatchedCandidateForFilter, hasUnread);

        if (output.size() < requested && hasUnread) {
            final int remaining = requested - output.size();
            Runnable continuation = new Runnable() {
                @Override
                public void run() {
                    if (!tokensMatch(expectedComposing, expectedFilter)
                            || !StrokeFilterCompat.shouldHandle(ime, StrokeFilterCandidateSession.this)) {
                        return;
                    }
                    pendingRunnable = null;
                    ime.onRequestCandidates(remaining);
                }
            };
            if (tokensMatch(expectedComposing, expectedFilter)) {
                pendingRunnable = continuation;
                handler.post(continuation);
            }
        }
        return true;
    }

    private Candidate nextRawCandidate(int expectedComposing, int expectedFilter) {
        if (!tokensMatch(expectedComposing, expectedFilter)) {
            return null;
        }
        if (rawCursor < rawCandidateCache.size()) {
            Candidate cached = rawCandidateCache.get(rawCursor);
            if (!tokensMatch(expectedComposing, expectedFilter)) {
                return null;
            }
            rawCursor++;
            return cached;
        }
        if (sourceExhausted || sourceIterator == null) {
            return null;
        }
        if (!sourceIterator.hasNext()) {
            if (tokensMatch(expectedComposing, expectedFilter)) {
                sourceExhausted = true;
            }
            return null;
        }
        if (rawCandidateCache.size() >= CACHE_LIMIT) {
            cacheLimitReached = true;
            return null;
        }
        Candidate candidate = sourceIterator.next();
        if (!tokensMatch(expectedComposing, expectedFilter)) {
            return null;
        }
        rawCandidateCache.add(candidate);
        rawCursor++;
        return candidate;
    }

    private boolean hasUnreadRawCandidate() {
        if (rawCursor < rawCandidateCache.size()) {
            return true;
        }
        if (sourceExhausted || sourceIterator == null) {
            return false;
        }
        if (!sourceIterator.hasNext()) {
            sourceExhausted = true;
            return false;
        }
        return rawCandidateCache.size() < CACHE_LIMIT;
    }

    private boolean matches(Candidate candidate, String prefix, StrokeFilterData data) {
        if (candidate == null || candidate.a == null || candidate.a.length() == 0) {
            return false;
        }
        int codePoint = Character.codePointAt(candidate.a, 0);
        return isHan(codePoint) && data.matches(codePoint, prefix);
    }

    private static boolean isHan(int codePoint) {
        return codePoint == 0x3007
                || (codePoint >= 0x3400 && codePoint <= 0x4DBF)
                || (codePoint >= 0x4E00 && codePoint <= 0x9FFF)
                || (codePoint >= 0x20000 && codePoint <= 0x323AF);
    }

    private boolean tokensMatch(int expectedComposing, int expectedFilter) {
        return valid
                && composingGeneration == expectedComposing
                && filterGeneration == expectedFilter;
    }

    public Iterator<Candidate> createReplayIterator() {
        cancelPending();
        valid = false;
        return new ReplayIterator(rawCandidateCache, sourceIterator, sourceExhausted);
    }

    private static final class ReplayIterator implements Iterator<Candidate> {
        private final List<Candidate> cache;
        private final Iterator<Candidate> source;
        private final boolean sourceWasExhausted;
        private int cursor;

        ReplayIterator(List<Candidate> cache, Iterator<Candidate> source, boolean sourceWasExhausted) {
            this.cache = new ArrayList<Candidate>(cache);
            this.source = source;
            this.sourceWasExhausted = sourceWasExhausted;
        }

        @Override
        public boolean hasNext() {
            return cursor < cache.size()
                    || (!sourceWasExhausted && source != null && source.hasNext());
        }

        @Override
        public Candidate next() {
            if (cursor < cache.size()) {
                return cache.get(cursor++);
            }
            if (!sourceWasExhausted && source != null) {
                return source.next();
            }
            throw new NoSuchElementException();
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
    }
}
