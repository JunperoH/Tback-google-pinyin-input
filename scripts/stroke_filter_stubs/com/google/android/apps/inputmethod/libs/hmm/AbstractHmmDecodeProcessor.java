package com.google.android.apps.inputmethod.libs.hmm;

import com.google.android.apps.inputmethod.libs.framework.core.Candidate;

import java.util.Iterator;
import java.util.List;

public abstract class AbstractHmmDecodeProcessor {
    public Iterator<Candidate> mTextCandidateIterator;
    public abstract boolean isComposing();
    public abstract boolean onRequestCandidates(int requested);
    public abstract void doAppendTextCandidates(
            List<Candidate> candidates, Candidate selected, boolean hasMore);
    public abstract void doUpdateTextCandidates(boolean available);
}
