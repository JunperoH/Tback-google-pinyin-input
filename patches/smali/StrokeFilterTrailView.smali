.class public final Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;
.super Landroid/view/View;
.source "StrokeFilterTrailView.java"

# interfaces
.implements Ljava/lang/Runnable;


# static fields
.field private static final FADE_DELAY_MS:J = 0x78L

.field private static final FADE_DURATION_MS:J = 0x1f4L

.field private static final FRAME_DELAY_MS:J = 0x19L


# instance fields
.field private drawing:Z

.field private fadeStartTime:J

.field private lastX:F

.field private lastY:F

.field private final paint:Landroid/graphics/Paint;

.field private final path:Landroid/graphics/Path;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 1

    const/4 v0, 0x0

    invoke-direct {p0, p1, v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 1

    const/4 v0, 0x0

    invoke-direct {p0, p1, p2, v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V
    .locals 1

    invoke-direct {p0, p1, p2, p3}, Landroid/view/View;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V

    new-instance p2, Landroid/graphics/Paint;

    invoke-direct {p2}, Landroid/graphics/Paint;-><init>()V

    iput-object p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->paint:Landroid/graphics/Paint;

    new-instance p3, Landroid/graphics/Path;

    invoke-direct {p3}, Landroid/graphics/Path;-><init>()V

    iput-object p3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->path:Landroid/graphics/Path;

    const/4 p3, 0x1

    invoke-virtual {p2, p3}, Landroid/graphics/Paint;->setAntiAlias(Z)V

    invoke-virtual {p2, p3}, Landroid/graphics/Paint;->setDither(Z)V

    sget-object p3, Landroid/graphics/Paint$Style;->STROKE:Landroid/graphics/Paint$Style;

    invoke-virtual {p2, p3}, Landroid/graphics/Paint;->setStyle(Landroid/graphics/Paint$Style;)V

    sget-object p3, Landroid/graphics/Paint$Cap;->ROUND:Landroid/graphics/Paint$Cap;

    invoke-virtual {p2, p3}, Landroid/graphics/Paint;->setStrokeCap(Landroid/graphics/Paint$Cap;)V

    sget-object p3, Landroid/graphics/Paint$Join;->ROUND:Landroid/graphics/Paint$Join;

    invoke-virtual {p2, p3}, Landroid/graphics/Paint;->setStrokeJoin(Landroid/graphics/Paint$Join;)V

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->getResources()Landroid/content/res/Resources;

    move-result-object p3

    invoke-virtual {p3}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object p3

    iget p3, p3, Landroid/util/DisplayMetrics;->density:F

    const/high16 v0, 0x40c00000    # 6.0f

    mul-float p3, p3, v0

    invoke-virtual {p2, p3}, Landroid/graphics/Paint;->setStrokeWidth(F)V

    invoke-static {p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->resolveGestureColor(Landroid/content/Context;)I

    move-result p1

    invoke-virtual {p2, p1}, Landroid/graphics/Paint;->setColor(I)V

    const/16 p1, 0xfa

    invoke-virtual {p2, p1}, Landroid/graphics/Paint;->setAlpha(I)V

    const/4 p1, 0x0

    invoke-virtual {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->setWillNotDraw(Z)V

    invoke-virtual {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->setClickable(Z)V

    invoke-virtual {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->setFocusable(Z)V

    return-void
.end method

.method private static resolveGestureColor(Landroid/content/Context;)I
    .locals 5

    nop

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "ColorGestureTrack"

    const-string v3, "attr"

    invoke-virtual {v0, v2, v3, v1}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    const v1, -0x222223

    if-nez v0, :cond_17

    return v1

    :cond_17
    new-instance v2, Landroid/util/TypedValue;

    invoke-direct {v2}, Landroid/util/TypedValue;-><init>()V

    invoke-virtual {p0}, Landroid/content/Context;->getTheme()Landroid/content/res/Resources$Theme;

    move-result-object v3

    const/4 v4, 0x1

    invoke-virtual {v3, v0, v2, v4}, Landroid/content/res/Resources$Theme;->resolveAttribute(ILandroid/util/TypedValue;Z)Z

    move-result v0

    if-nez v0, :cond_28

    return v1

    :cond_28
    iget v0, v2, Landroid/util/TypedValue;->type:I

    const/16 v3, 0x1c

    if-lt v0, v3, :cond_37

    iget v0, v2, Landroid/util/TypedValue;->type:I

    const/16 v3, 0x1f

    if-gt v0, v3, :cond_37

    iget p0, v2, Landroid/util/TypedValue;->data:I

    return p0

    :cond_37
    iget v0, v2, Landroid/util/TypedValue;->resourceId:I

    if-eqz v0, :cond_46

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    iget v0, v2, Landroid/util/TypedValue;->resourceId:I

    invoke-virtual {p0, v0}, Landroid/content/res/Resources;->getColor(I)I

    move-result p0

    return p0

    :cond_46
    return v1
.end method


# virtual methods
.method public addPoint(FF)V
    .locals 6

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->drawing:Z

    if-nez v0, :cond_8

    invoke-virtual {p0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->startStroke(FF)V

    return-void

    :cond_8
    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastX:F

    sub-float v0, p1, v0

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastY:F

    sub-float v1, p2, v1

    invoke-static {v0}, Ljava/lang/Math;->abs(F)F

    move-result v0

    const/high16 v2, 0x40000000    # 2.0f

    cmpg-float v0, v0, v2

    if-gez v0, :cond_23

    invoke-static {v1}, Ljava/lang/Math;->abs(F)F

    move-result v0

    cmpg-float v0, v0, v2

    if-gez v0, :cond_23

    return-void

    :cond_23
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->path:Landroid/graphics/Path;

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastX:F

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastY:F

    add-float v3, v1, p1

    const/high16 v4, 0x3f000000    # 0.5f

    mul-float v3, v3, v4

    add-float v5, v2, p2

    mul-float v5, v5, v4

    invoke-virtual {v0, v1, v2, v3, v5}, Landroid/graphics/Path;->quadTo(FFFF)V

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastX:F

    iput p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastY:F

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->invalidate()V

    return-void
.end method

.method public cancelStroke()V
    .locals 2

    invoke-virtual {p0, p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->removeCallbacks(Ljava/lang/Runnable;)Z

    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->drawing:Z

    const-wide/16 v0, 0x0

    iput-wide v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->fadeStartTime:J

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->path:Landroid/graphics/Path;

    invoke-virtual {v0}, Landroid/graphics/Path;->reset()V

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->paint:Landroid/graphics/Paint;

    const/16 v1, 0xfa

    invoke-virtual {v0, v1}, Landroid/graphics/Paint;->setAlpha(I)V

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->invalidate()V

    return-void
.end method

.method public finishStroke()V
    .locals 4

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->drawing:Z

    if-nez v0, :cond_5

    return-void

    :cond_5
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v0

    const-wide/16 v2, 0x78

    add-long/2addr v0, v2

    iput-wide v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->fadeStartTime:J

    invoke-virtual {p0, p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->removeCallbacks(Ljava/lang/Runnable;)Z

    invoke-virtual {p0, p0, v2, v3}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method

.method protected onDraw(Landroid/graphics/Canvas;)V
    .locals 2

    invoke-super {p0, p1}, Landroid/view/View;->onDraw(Landroid/graphics/Canvas;)V

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->drawing:Z

    if-eqz v0, :cond_e

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->path:Landroid/graphics/Path;

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->paint:Landroid/graphics/Paint;

    invoke-virtual {p1, v0, v1}, Landroid/graphics/Canvas;->drawPath(Landroid/graphics/Path;Landroid/graphics/Paint;)V

    :cond_e
    return-void
.end method

.method public run()V
    .locals 5

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->drawing:Z

    if-eqz v0, :cond_48

    iget-wide v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->fadeStartTime:J

    const-wide/16 v2, 0x0

    cmp-long v4, v0, v2

    if-nez v4, :cond_d

    goto :goto_48

    :cond_d
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v0

    iget-wide v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->fadeStartTime:J

    sub-long/2addr v0, v2

    const-wide/16 v2, 0x1f4

    cmp-long v4, v0, v2

    if-ltz v4, :cond_1e

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->cancelStroke()V

    return-void

    :cond_1e
    const/4 v2, 0x0

    long-to-float v0, v0

    invoke-static {v2, v0}, Ljava/lang/Math;->max(FF)F

    move-result v0

    const/high16 v1, 0x43fa0000    # 500.0f

    div-float/2addr v0, v1

    const/high16 v1, 0x3f800000    # 1.0f

    sub-float/2addr v1, v0

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->paint:Landroid/graphics/Paint;

    const/high16 v2, 0x437a0000    # 250.0f

    mul-float v1, v1, v2

    float-to-int v1, v1

    const/16 v2, 0xfa

    invoke-static {v2, v1}, Ljava/lang/Math;->min(II)I

    move-result v1

    const/4 v2, 0x0

    invoke-static {v2, v1}, Ljava/lang/Math;->max(II)I

    move-result v1

    invoke-virtual {v0, v1}, Landroid/graphics/Paint;->setAlpha(I)V

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->invalidate()V

    const-wide/16 v0, 0x19

    invoke-virtual {p0, p0, v0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void

    :cond_48
    :goto_48
    return-void
.end method

.method public startStroke(FF)V
    .locals 1

    invoke-virtual {p0, p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->removeCallbacks(Ljava/lang/Runnable;)Z

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->path:Landroid/graphics/Path;

    invoke-virtual {v0}, Landroid/graphics/Path;->reset()V

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->path:Landroid/graphics/Path;

    invoke-virtual {v0, p1, p2}, Landroid/graphics/Path;->moveTo(FF)V

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastX:F

    iput p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->lastY:F

    const-wide/16 p1, 0x0

    iput-wide p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->fadeStartTime:J

    const/4 p1, 0x1

    iput-boolean p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->drawing:Z

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->paint:Landroid/graphics/Paint;

    const/16 p2, 0xfa

    invoke-virtual {p1, p2}, Landroid/graphics/Paint;->setAlpha(I)V

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->invalidate()V

    return-void
.end method
