package com.google.android.apps.inputmethod.libs.framework.keyboard;

import android.content.Context;
import android.view.MotionEvent;

public interface IMotionEventHandler {
    boolean acceptInitialEvent(MotionEvent event);
    void activate();
    void close();
    void deactivate();
    void handle(MotionEvent event);
    void handleInitialMotionEvent(MotionEvent event);
    void initialize(Context context, IMotionEventHandlerDelegate delegate);
    void onKeyboardViewStateChanged(long oldState, long newState);
    void onSoftKeyboardViewAttachedToWindow();
    void onSoftKeyboardViewDetachedFromWindow();
    void onSoftKeyboardViewLayout(boolean changed, int left, int top, int right, int bottom);
    boolean preHandleAsTargetHandler(MotionEvent event);
    void reset();
    void setSoftKeyboardView(SoftKeyboardView view);
}
