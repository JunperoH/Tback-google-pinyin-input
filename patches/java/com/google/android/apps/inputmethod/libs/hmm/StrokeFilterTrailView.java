package com.google.android.apps.inputmethod.libs.hmm;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.SystemClock;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;

/** Theme-aware, non-interactive trail used by automatic T+ stroke capture. */
public final class StrokeFilterTrailView extends View implements Runnable {
    private static final long FADE_DELAY_MS = 120L;
    private static final long FADE_DURATION_MS = 500L;
    private static final long FRAME_DELAY_MS = 25L;

    private final Paint paint = new Paint();
    private final Path path = new Path();
    private float lastX;
    private float lastY;
    private long fadeStartTime;
    private boolean drawing;

    public StrokeFilterTrailView(Context context) {
        this(context, null);
    }

    public StrokeFilterTrailView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public StrokeFilterTrailView(Context context, AttributeSet attrs, int style) {
        super(context, attrs, style);
        paint.setAntiAlias(true);
        paint.setDither(true);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeCap(Paint.Cap.ROUND);
        paint.setStrokeJoin(Paint.Join.ROUND);
        paint.setStrokeWidth(6.0f * getResources().getDisplayMetrics().density);
        paint.setColor(resolveGestureColor(context));
        paint.setAlpha(250);
        setWillNotDraw(false);
        setClickable(false);
        setFocusable(false);
    }

    private static int resolveGestureColor(Context context) {
        int fallback = 0xffdddddd;
        int attr = context.getResources().getIdentifier(
                "ColorGestureTrack", "attr", context.getPackageName());
        if (attr == 0) {
            return fallback;
        }
        TypedValue value = new TypedValue();
        if (!context.getTheme().resolveAttribute(attr, value, true)) {
            return fallback;
        }
        if (value.type >= TypedValue.TYPE_FIRST_COLOR_INT
                && value.type <= TypedValue.TYPE_LAST_COLOR_INT) {
            return value.data;
        }
        if (value.resourceId != 0) {
            return context.getResources().getColor(value.resourceId);
        }
        return fallback;
    }

    public void startStroke(float x, float y) {
        removeCallbacks(this);
        path.reset();
        path.moveTo(x, y);
        lastX = x;
        lastY = y;
        fadeStartTime = 0L;
        drawing = true;
        paint.setAlpha(250);
        invalidate();
    }

    public void addPoint(float x, float y) {
        if (!drawing) {
            startStroke(x, y);
            return;
        }
        float dx = x - lastX;
        float dy = y - lastY;
        if (Math.abs(dx) < 2.0f && Math.abs(dy) < 2.0f) {
            return;
        }
        path.quadTo(lastX, lastY, (lastX + x) * 0.5f, (lastY + y) * 0.5f);
        lastX = x;
        lastY = y;
        invalidate();
    }

    public void finishStroke() {
        if (!drawing) {
            return;
        }
        fadeStartTime = SystemClock.uptimeMillis() + FADE_DELAY_MS;
        removeCallbacks(this);
        postDelayed(this, FADE_DELAY_MS);
    }

    public void cancelStroke() {
        removeCallbacks(this);
        drawing = false;
        fadeStartTime = 0L;
        path.reset();
        paint.setAlpha(250);
        invalidate();
    }

    @Override
    public void run() {
        if (!drawing || fadeStartTime == 0L) {
            return;
        }
        long elapsed = SystemClock.uptimeMillis() - fadeStartTime;
        if (elapsed >= FADE_DURATION_MS) {
            cancelStroke();
            return;
        }
        float remaining = 1.0f - Math.max(0.0f, elapsed) / (float) FADE_DURATION_MS;
        paint.setAlpha(Math.max(0, Math.min(250, (int) (250.0f * remaining))));
        invalidate();
        postDelayed(this, FRAME_DELAY_MS);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (drawing) {
            canvas.drawPath(path, paint);
        }
    }
}
