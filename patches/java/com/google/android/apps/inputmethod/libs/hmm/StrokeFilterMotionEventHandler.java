package com.google.android.apps.inputmethod.libs.hmm;

import android.content.Context;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.widget.FrameLayout;

import com.google.android.apps.inputmethod.libs.framework.core.Action;
import com.google.android.apps.inputmethod.libs.framework.core.Event;
import com.google.android.apps.inputmethod.libs.framework.core.IPopupViewManager;
import com.google.android.apps.inputmethod.libs.framework.core.KeyData;
import com.google.android.apps.inputmethod.libs.framework.keyboard.IMotionEventHandler;
import com.google.android.apps.inputmethod.libs.framework.keyboard.IMotionEventHandlerDelegate;
import com.google.android.apps.inputmethod.libs.framework.keyboard.SoftKeyboardView;

/** Automatic T+ stroke capture that yields taps until movement crosses touch slop. */
public final class StrokeFilterMotionEventHandler implements IMotionEventHandler {
    private Context context;
    private IMotionEventHandlerDelegate delegate;
    private IPopupViewManager popupManager;
    private SoftKeyboardView keyboardView;
    private StrokeFilterTrailView trailView;
    private float startX;
    private float startY;
    private float lastX;
    private float lastY;
    private float pathLength;
    private float maxOffsetSquare;
    private int touchSlop;
    private int trailYOffset;
    private boolean tracking;
    private boolean targetClaimed;

    @Override
    public void initialize(Context context, IMotionEventHandlerDelegate delegate) {
        this.context = context;
        this.delegate = delegate;
        this.popupManager = delegate.getPopupViewManager();
        this.touchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
    }

    @Override
    public void activate() {
        StrokeFilterCompat.activateTPlus();
    }

    @Override
    public void deactivate() {
        reset();
        StrokeFilterCompat.deactivateTPlus();
    }

    @Override
    public void close() {
        deactivate();
        dismissTrail();
        context = null;
        delegate = null;
        popupManager = null;
        keyboardView = null;
    }

    @Override
    public boolean acceptInitialEvent(MotionEvent event) {
        return event != null
                && event.getActionMasked() == MotionEvent.ACTION_DOWN
                && StrokeFilterCompat.isCaptureActive();
    }

    @Override
    public void handleInitialMotionEvent(MotionEvent event) {
        begin(event);
    }

    @Override
    public boolean preHandleAsTargetHandler(MotionEvent event) {
        handle(event);
        return true;
    }

    @Override
    public void handle(MotionEvent event) {
        if (event == null) {
            return;
        }
        // This handler exists only in the T+ keyboard and runs before the
        // shared Pinyin handlers, so refresh the layout token for this event.
        StrokeFilterCompat.activateTPlus();
        int action = event.getActionMasked();
        if (action == MotionEvent.ACTION_DOWN) {
            if (StrokeFilterCompat.isCaptureActive()) {
                begin(event);
            }
            return;
        }
        if (!tracking) {
            return;
        }
        if (action == MotionEvent.ACTION_MOVE || action == MotionEvent.ACTION_UP) {
            add(event.getX(), event.getY());
        }
        if (!targetClaimed && maxOffsetSquare >= touchSlop * touchSlop && delegate != null) {
            targetClaimed = true;
            delegate.declareTargetHandler();
        }
        if (action == MotionEvent.ACTION_UP) {
            if (targetClaimed) {
                finish();
            } else {
                reset();
            }
        } else if (action == MotionEvent.ACTION_CANCEL) {
            reset();
        }
    }

    private void begin(MotionEvent event) {
        startX = lastX = event.getX();
        startY = lastY = event.getY();
        pathLength = 0.0f;
        maxOffsetSquare = 0.0f;
        tracking = true;
        targetClaimed = false;
        showTrail();
        if (trailView != null) {
            trailView.startStroke(startX, startY + trailYOffset);
        }
    }

    private void add(float x, float y) {
        float dx = x - lastX;
        float dy = y - lastY;
        pathLength += (float) Math.sqrt(dx * dx + dy * dy);
        lastX = x;
        lastY = y;
        float offsetX = x - startX;
        float offsetY = y - startY;
        maxOffsetSquare = Math.max(maxOffsetSquare, offsetX * offsetX + offsetY * offsetY);
        if (trailView != null) {
            trailView.addPoint(x, y + trailYOffset);
        }
    }

    private void finish() {
        float dx = lastX - startX;
        float dy = lastY - startY;
        float direct = (float) Math.sqrt(dx * dx + dy * dy);
        if (direct >= touchSlop && delegate != null) {
            int width = keyboardView == null ? 1 : Math.max(1, keyboardView.getWidth());
            int height = keyboardView == null ? 1 : Math.max(1, keyboardView.getHeight());
            float nx = dx / width;
            float ny = dy / height;
            int stroke = classify(nx, ny, direct, pathLength);
            fireStroke(stroke);
        }
        if (trailView != null) {
            trailView.finishStroke();
        }
        resetTracking(false);
    }

    static int classify(float dx, float dy, float direct, float pathLength) {
        if (pathLength > direct * 1.45f) {
            return 5;
        }
        float ax = Math.abs(dx);
        float ay = Math.abs(dy);
        if (ax > ay * 1.25f) {
            return 1;
        }
        if (ay > ax * 1.25f) {
            return 2;
        }
        return dx * dy < 0.0f ? 3 : 4;
    }

    private void fireStroke(int stroke) {
        Event event = Event.b().a();
        event.a = Action.PRESS;
        KeyData key = new KeyData(StrokeFilterCompat.STROKE_EVENT_BASE - stroke, null, null);
        event.a(key);
        delegate.fireEvent(event);
    }

    @Override
    public void reset() {
        resetTracking(true);
    }

    private void resetTracking(boolean clearTrail) {
        tracking = false;
        targetClaimed = false;
        pathLength = 0.0f;
        maxOffsetSquare = 0.0f;
        if (clearTrail && trailView != null) {
            trailView.cancelStroke();
        }
    }

    @Override
    public void setSoftKeyboardView(SoftKeyboardView view) {
        if (keyboardView != view) {
            dismissTrail();
        }
        keyboardView = view;
    }

    @Override public void onKeyboardViewStateChanged(long oldState, long newState) {}
    @Override public void onSoftKeyboardViewAttachedToWindow() {}
    @Override public void onSoftKeyboardViewDetachedFromWindow() {
        reset();
        dismissTrail();
    }
    @Override public void onSoftKeyboardViewLayout(
            boolean changed, int left, int top, int right, int bottom) {}

    private void showTrail() {
        if (context == null || popupManager == null || keyboardView == null
                || keyboardView.getWindowToken() == null) {
            return;
        }
        if (trailView == null) {
            int layoutId = context.getResources().getIdentifier(
                    "stroke_filter_overlay_view", "layout", context.getPackageName());
            if (layoutId == 0) {
                return;
            }
            View inflated = popupManager.inflatePopupView(layoutId);
            if (!(inflated instanceof StrokeFilterTrailView)) {
                return;
            }
            trailView = (StrokeFilterTrailView) inflated;
            trailView.setEnabled(false);
        }
        View keyboardArea = delegate.getKeyboardArea();
        if (keyboardArea == null || keyboardArea.getHeight() <= 0 || keyboardView.getWidth() <= 0) {
            return;
        }
        int[] bodyLocation = new int[2];
        int[] areaLocation = new int[2];
        keyboardView.getLocationInWindow(bodyLocation);
        keyboardArea.getLocationInWindow(areaLocation);
        trailYOffset = bodyLocation[1] - areaLocation[1];
        trailView.setLayoutParams(new FrameLayout.LayoutParams(
                keyboardView.getWidth(), keyboardArea.getHeight()));
        if (!popupManager.isPopupViewShowing(trailView)) {
            popupManager.showPopupView(
                    trailView, keyboardView, 290, 0, -trailYOffset, null);
        }
    }

    private void dismissTrail() {
        if (trailView != null) {
            trailView.cancelStroke();
            if (popupManager != null) {
                popupManager.dismissPopupView(trailView, null, true);
            }
            trailView = null;
        }
        trailYOffset = 0;
    }
}
