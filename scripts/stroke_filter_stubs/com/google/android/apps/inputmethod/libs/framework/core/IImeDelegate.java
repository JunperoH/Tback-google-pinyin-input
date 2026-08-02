package com.google.android.apps.inputmethod.libs.framework.core;

import java.util.List;

public interface IImeDelegate {
    void appendTextCandidates(List<Candidate> candidates, Candidate selected, boolean hasMore);
    void textCandidatesUpdated(boolean available);
}
