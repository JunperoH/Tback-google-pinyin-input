package com.google.android.apps.inputmethod.libs.chinese.ime.hmm;

import com.google.android.apps.inputmethod.libs.framework.core.Candidate;
import com.google.android.apps.inputmethod.libs.hmm.AbstractHmmDecodeProcessor;

public abstract class AbstractHmmChineseDecodeProcessor extends AbstractHmmDecodeProcessor {
    public abstract boolean onSelectTextCandidate(Candidate candidate, boolean commit);
}
