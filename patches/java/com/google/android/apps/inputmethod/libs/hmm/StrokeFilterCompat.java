package com.google.android.apps.inputmethod.libs.hmm;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.google.android.apps.inputmethod.libs.chinese.ime.hmm.AbstractHmmChineseDecodeProcessor;
import com.google.android.apps.inputmethod.libs.framework.core.Candidate;

import java.util.Iterator;
import java.util.WeakHashMap;

/** Process-local bridge between T+ lifecycle, stroke state and HMM candidates. */
public final class StrokeFilterCompat {
    public static final String PREF_KEY = "tplus_stroke_filter_enabled";
    public static final int STROKE_EVENT_BASE = -40000;

    private static final WeakHashMap<AbstractHmmDecodeProcessor, StrokeFilterCandidateSession> SESSIONS =
            new WeakHashMap<AbstractHmmDecodeProcessor, StrokeFilterCandidateSession>();

    private static Context applicationContext;
    private static AbstractHmmDecodeProcessor currentIme;
    private static boolean tplusActive;
    private static boolean captureActive;
    private static String prefix = "";

    private StrokeFilterCompat() {}

    public static synchronized void initialize(Context context) {
        if (applicationContext == null && context != null) {
            applicationContext = context.getApplicationContext();
        }
    }

    public static synchronized void activateTPlus() {
        tplusActive = true;
    }

    public static synchronized void deactivateTPlus() {
        tplusActive = false;
        captureActive = false;
        prefix = "";
        destroyAllSessions();
    }

    public static synchronized void onSetTextCandidates(
            AbstractHmmDecodeProcessor ime, Iterator<Candidate> iterator) {
        if (ime == null) {
            return;
        }
        boolean hadSession = SESSIONS.containsKey(ime);
        currentIme = ime;
        StrokeFilterCandidateSession old = SESSIONS.remove(ime);
        if (old != null) {
            old.destroy();
        }
        if (!tplusActive || !isSettingEnabled() || iterator == null) {
            captureActive = false;
            prefix = "";
            return;
        }
        StrokeFilterCandidateSession session = new StrokeFilterCandidateSession();
        session.bind(iterator);
        SESSIONS.put(ime, session);
        if (!hadSession && prefix.length() == 0 && ime.isComposing() && isDataReady()) {
            captureActive = true;
        }
    }

    public static synchronized void onResetInternalStates(AbstractHmmDecodeProcessor ime) {
        StrokeFilterCandidateSession session = SESSIONS.remove(ime);
        if (session != null) {
            session.destroy();
        }
        if (currentIme == ime) {
            currentIme = null;
            captureActive = false;
            prefix = "";
        }
    }

    public static synchronized boolean requestCandidates(AbstractHmmDecodeProcessor ime, int requested) {
        StrokeFilterCandidateSession session = SESSIONS.get(ime);
        if (!shouldHandle(ime, session)) {
            if (session != null && prefix.length() > 0) {
                failOpen(ime, session);
            }
            return false;
        }
        StrokeFilterData data = StrokeFilterData.get(applicationContext);
        if (data == null) {
            failOpen(ime, session);
            ime.doUpdateTextCandidates(true);
            return false;
        }
        return session.request(ime, requested, prefix, data);
    }

    static synchronized boolean shouldHandle(
            AbstractHmmDecodeProcessor ime, StrokeFilterCandidateSession session) {
        return ime != null
                && session != null
                && session.valid
                && ime == currentIme
                && tplusActive
                && isSettingEnabled()
                && prefix.length() > 0
                && ime.isComposing();
    }

    public static synchronized boolean toggleCapture() {
        if (!tplusActive || !isSettingEnabled() || currentIme == null
                || !currentIme.isComposing() || !isDataReady()) {
            captureActive = false;
            return false;
        }
        if (!SESSIONS.containsKey(currentIme) && currentIme.mTextCandidateIterator != null) {
            StrokeFilterCandidateSession session = new StrokeFilterCandidateSession();
            session.bind(currentIme.mTextCandidateIterator);
            SESSIONS.put(currentIme, session);
        }
        captureActive = !captureActive;
        if (!captureActive) {
            restartCurrentFilter();
        }
        return captureActive;
    }

    public static synchronized boolean isCaptureActive() {
        return captureActive
                && tplusActive
                && isSettingEnabled()
                && currentIme != null
                && currentIme.isComposing();
    }

    /** Disable only the native Pinyin glide handlers while T+ stroke filtering is enabled. */
    public static synchronized boolean shouldDisableTPlusGesture() {
        return tplusActive && isSettingEnabled();
    }

    public static synchronized boolean appendStroke(int stroke) {
        if (!isCaptureActive() || stroke < 1 || stroke > 5 || prefix.length() >= 5) {
            return false;
        }
        prefix = prefix + (char) ('0' + stroke);
        restartCurrentFilter();
        return true;
    }

    public static synchronized boolean deleteStroke() {
        if (prefix.length() == 0) {
            return false;
        }
        prefix = prefix.substring(0, prefix.length() - 1);
        if (prefix.length() == 0) {
            captureActive = false;
            StrokeFilterCandidateSession session = SESSIONS.get(currentIme);
            if (session != null) {
                failOpen(currentIme, session);
                currentIme.doUpdateTextCandidates(true);
            }
            return true;
        }
        restartCurrentFilter();
        return true;
    }

    public static synchronized String getPrefix() {
        return prefix;
    }

    public static synchronized int getState() {
        StrokeFilterCandidateSession session = SESSIONS.get(currentIme);
        return session == null ? StrokeFilterCandidateSession.IDLE : session.state;
    }

    public static synchronized void updateToggle(final View root) {
        if (root == null) {
            return;
        }
        View toggle = root.findViewWithTag("compat_stroke_filter_toggle");
        View holder = root.findViewWithTag("compat_stroke_filter_holder");
        if (toggle == null) {
            return;
        }
        boolean visible = tplusActive
                && isSettingEnabled()
                && currentIme != null
                && currentIme.isComposing()
                && isDataReady();
        toggle.setVisibility(visible ? View.VISIBLE : View.GONE);
        toggle.setSelected(captureActive);
        if (holder != null) {
            int reserved = visible ? (int) (48.0f * holder.getResources()
                    .getDisplayMetrics().density + 0.5f) : 0;
            ViewGroup.LayoutParams rawParams = holder.getLayoutParams();
            if (rawParams instanceof ViewGroup.MarginLayoutParams) {
                ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) rawParams;
                if (params.rightMargin != reserved) {
                    params.rightMargin = reserved;
                    holder.setLayoutParams(params);
                }
            }
        }
        if (!visible) {
            return;
        }
        if (toggle instanceof TextView) {
            TextView label = (TextView) toggle;
            int state = getState();
            String text;
            if (state == StrokeFilterCandidateSession.SCANNING && prefix.length() > 0) {
                text = localized("stroke_filter_scanning", "筛选……");
            } else if (state == StrokeFilterCandidateSession.NO_MATCH && prefix.length() > 0) {
                text = localized("stroke_filter_no_match", "无匹配");
            } else if (captureActive && prefix.length() == 0) {
                text = localized("stroke_filter_capturing", "笔·画");
            } else {
                text = localized("stroke_filter_toggle_label", "笔");
            }
            label.setText(text);
        }
        toggle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toggleCapture();
                updateToggle(root);
            }
        });
    }

    public static synchronized boolean handleFilteredCommit(
            AbstractHmmChineseDecodeProcessor processor) {
        StrokeFilterCandidateSession session = SESSIONS.get(processor);
        if (!shouldHandle(processor, session)) {
            return false;
        }
        Candidate candidate = session.firstMatchedCandidateForFilter;
        if (candidate == null) {
            failOpen(processor, session);
            processor.doUpdateTextCandidates(true);
            return true;
        }
        boolean selected = processor.onSelectTextCandidate(candidate, true);
        if (!selected) {
            failOpen(processor, session);
            processor.doUpdateTextCandidates(true);
            return true;
        }
        onResetInternalStates(processor);
        return true;
    }

    public static synchronized boolean isDataReady() {
        return applicationContext != null && StrokeFilterData.get(applicationContext) != null;
    }

    private static boolean isSettingEnabled() {
        if (applicationContext == null) {
            return false;
        }
        SharedPreferences preferences =
                PreferenceManager.getDefaultSharedPreferences(applicationContext);
        return preferences.getBoolean(PREF_KEY, false);
    }

    private static String localized(String name, String fallback) {
        if (applicationContext == null) {
            return fallback;
        }
        int id = applicationContext.getResources().getIdentifier(
                name, "string", applicationContext.getPackageName());
        return id == 0 ? fallback : applicationContext.getString(id);
    }

    private static void restartCurrentFilter() {
        StrokeFilterCandidateSession session = SESSIONS.get(currentIme);
        if (session == null || !session.valid) {
            return;
        }
        session.resetFilter();
        currentIme.doUpdateTextCandidates(true);
    }

    private static void failOpen(AbstractHmmDecodeProcessor ime, StrokeFilterCandidateSession session) {
        session.filterGeneration++;
        session.cancelPending();
        ime.mTextCandidateIterator = session.createReplayIterator();
        SESSIONS.remove(ime);
        captureActive = false;
        prefix = "";
    }

    static synchronized void failOpenFromSession(
            AbstractHmmDecodeProcessor ime, StrokeFilterCandidateSession session) {
        if (SESSIONS.get(ime) == session) {
            failOpen(ime, session);
        }
    }

    private static void destroyAllSessions() {
        for (StrokeFilterCandidateSession session : SESSIONS.values()) {
            session.destroy();
        }
        SESSIONS.clear();
        currentIme = null;
    }
}
