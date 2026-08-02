package com.google.android.apps.inputmethod.libs.framework.keyboard;

import com.google.android.apps.inputmethod.libs.framework.core.Event;
import com.google.android.apps.inputmethod.libs.framework.core.IPopupViewManager;
import android.view.View;

public interface IMotionEventHandlerDelegate {
    void declareTargetHandler();
    void fireEvent(Event event);
    View getKeyboardArea();
    IPopupViewManager getPopupViewManager();
}
