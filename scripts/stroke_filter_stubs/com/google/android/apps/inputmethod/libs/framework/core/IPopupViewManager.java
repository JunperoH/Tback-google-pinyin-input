package com.google.android.apps.inputmethod.libs.framework.core;

import android.animation.Animator;
import android.view.View;

public interface IPopupViewManager {
    void dismissPopupView(View view, Animator animator, boolean immediate);
    View inflatePopupView(int layoutId);
    boolean isPopupViewShowing(View view);
    void showPopupView(
            View view, View anchor, int gravity, int xOffset, int yOffset, Animator animator);
}
