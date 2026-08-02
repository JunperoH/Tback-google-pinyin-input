.class public final Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;
.super Ljava/lang/Object;
.source "StrokeFilterMotionEventHandler.java"

# interfaces
.implements Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandler;


# instance fields
.field private context:Landroid/content/Context;

.field private delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

.field private keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

.field private lastX:F

.field private lastY:F

.field private maxOffsetSquare:F

.field private pathLength:F

.field private popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

.field private startX:F

.field private startY:F

.field private targetClaimed:Z

.field private touchSlop:I

.field private tracking:Z

.field private trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

.field private trailYOffset:I


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private add(FF)V
    .locals 3

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastX:F

    sub-float v0, p1, v0

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastY:F

    sub-float v1, p2, v1

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->pathLength:F

    mul-float v0, v0, v0

    mul-float v1, v1, v1

    add-float/2addr v0, v1

    float-to-double v0, v0

    invoke-static {v0, v1}, Ljava/lang/Math;->sqrt(D)D

    move-result-wide v0

    double-to-float v0, v0

    add-float/2addr v2, v0

    iput v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->pathLength:F

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastX:F

    iput p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastY:F

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startX:F

    sub-float v0, p1, v0

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startY:F

    sub-float v1, p2, v1

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->maxOffsetSquare:F

    mul-float v0, v0, v0

    mul-float v1, v1, v1

    add-float/2addr v0, v1

    invoke-static {v2, v0}, Ljava/lang/Math;->max(FF)F

    move-result v0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->maxOffsetSquare:F

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-eqz v0, :cond_3c

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailYOffset:I

    int-to-float v1, v1

    add-float/2addr p2, v1

    invoke-virtual {v0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->addPoint(FF)V

    :cond_3c
    return-void
.end method

.method private begin(Landroid/view/MotionEvent;)V
    .locals 3

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getX()F

    move-result v0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastX:F

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startX:F

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getY()F

    move-result p1

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastY:F

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startY:F

    const/4 p1, 0x0

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->pathLength:F

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->maxOffsetSquare:F

    const/4 p1, 0x1

    iput-boolean p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->tracking:Z

    const/4 p1, 0x0

    iput-boolean p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->targetClaimed:Z

    invoke-direct {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->showTrail()V

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-eqz p1, :cond_2d

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startX:F

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startY:F

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailYOffset:I

    int-to-float v2, v2

    add-float/2addr v1, v2

    invoke-virtual {p1, v0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->startStroke(FF)V

    :cond_2d
    return-void
.end method

.method static classify(FFFF)I
    .locals 2

    const v0, 0x3fb9999a    # 1.45f

    mul-float p2, p2, v0

    cmpl-float p2, p3, p2

    if-lez p2, :cond_b

    const/4 p0, 0x5

    return p0

    :cond_b
    invoke-static {p0}, Ljava/lang/Math;->abs(F)F

    move-result p2

    invoke-static {p1}, Ljava/lang/Math;->abs(F)F

    move-result p3

    const/high16 v0, 0x3fa00000    # 1.25f

    mul-float v1, p3, v0

    cmpl-float v1, p2, v1

    if-lez v1, :cond_1d

    const/4 p0, 0x1

    return p0

    :cond_1d
    mul-float p2, p2, v0

    cmpl-float p2, p3, p2

    if-lez p2, :cond_25

    const/4 p0, 0x2

    return p0

    :cond_25
    mul-float p0, p0, p1

    const/4 p1, 0x0

    cmpg-float p0, p0, p1

    if-gez p0, :cond_2e

    const/4 p0, 0x3

    goto :goto_2f

    :cond_2e
    const/4 p0, 0x4

    :goto_2f
    return p0
.end method

.method private dismissTrail()V
    .locals 4

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-eqz v0, :cond_14

    invoke-virtual {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->cancelStroke()V

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    const/4 v1, 0x0

    if-eqz v0, :cond_12

    iget-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    const/4 v3, 0x1

    invoke-interface {v0, v2, v1, v3}, Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;->dismissPopupView(Landroid/view/View;Landroid/animation/Animator;Z)V

    :cond_12
    iput-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    :cond_14
    const/4 v0, 0x0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailYOffset:I

    return-void
.end method

.method private finish()V
    .locals 6

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastX:F

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startX:F

    sub-float/2addr v0, v1

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->lastY:F

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->startY:F

    sub-float/2addr v1, v2

    mul-float v2, v0, v0

    mul-float v3, v1, v1

    add-float/2addr v2, v3

    float-to-double v2, v2

    invoke-static {v2, v3}, Ljava/lang/Math;->sqrt(D)D

    move-result-wide v2

    double-to-float v2, v2

    iget v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->touchSlop:I

    int-to-float v3, v3

    cmpl-float v3, v2, v3

    if-ltz v3, :cond_49

    iget-object v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

    if-eqz v3, :cond_49

    iget-object v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    const/4 v4, 0x1

    if-nez v3, :cond_27

    const/4 v3, 0x1

    goto :goto_2f

    :cond_27
    invoke-virtual {v3}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;->getWidth()I

    move-result v3

    invoke-static {v4, v3}, Ljava/lang/Math;->max(II)I

    move-result v3

    :goto_2f
    iget-object v5, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    if-nez v5, :cond_34

    goto :goto_3c

    :cond_34
    invoke-virtual {v5}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;->getHeight()I

    move-result v5

    invoke-static {v4, v5}, Ljava/lang/Math;->max(II)I

    move-result v4

    :goto_3c
    int-to-float v3, v3

    div-float/2addr v0, v3

    int-to-float v3, v4

    div-float/2addr v1, v3

    iget v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->pathLength:F

    invoke-static {v0, v1, v2, v3}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->classify(FFFF)I

    move-result v0

    invoke-direct {p0, v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->fireStroke(I)V

    :cond_49
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-eqz v0, :cond_50

    invoke-virtual {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->finishStroke()V

    :cond_50
    const/4 v0, 0x0

    invoke-direct {p0, v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->resetTracking(Z)V

    return-void
.end method

.method private fireStroke(I)V
    .locals 3

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/framework/core/Event;->b()Lcom/google/android/apps/inputmethod/libs/framework/core/Event;

    move-result-object v0

    invoke-virtual {v0}, Lcom/google/android/apps/inputmethod/libs/framework/core/Event;->a()Lcom/google/android/apps/inputmethod/libs/framework/core/Event;

    move-result-object v0

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/framework/core/Action;->PRESS:Lcom/google/android/apps/inputmethod/libs/framework/core/Action;

    iput-object v1, v0, Lcom/google/android/apps/inputmethod/libs/framework/core/Event;->a:Lcom/google/android/apps/inputmethod/libs/framework/core/Action;

    new-instance v1, Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;

    const v2, -0x9c40

    sub-int/2addr v2, p1

    const/4 p1, 0x0

    invoke-direct {v1, v2, p1, p1}, Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;-><init>(ILcom/google/android/apps/inputmethod/libs/framework/core/KeyData$a;Ljava/lang/Object;)V

    invoke-virtual {v0, v1}, Lcom/google/android/apps/inputmethod/libs/framework/core/Event;->a(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)Lcom/google/android/apps/inputmethod/libs/framework/core/Event;

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

    invoke-interface {p1, v0}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;->fireEvent(Lcom/google/android/apps/inputmethod/libs/framework/core/Event;)V

    return-void
.end method

.method private resetTracking(Z)V
    .locals 1

    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->tracking:Z

    iput-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->targetClaimed:Z

    const/4 v0, 0x0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->pathLength:F

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->maxOffsetSquare:F

    if-eqz p1, :cond_13

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-eqz p1, :cond_13

    invoke-virtual {p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->cancelStroke()V

    :cond_13
    return-void
.end method

.method private showTrail()V
    .locals 8

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->context:Landroid/content/Context;

    if-eqz v0, :cond_9e

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    if-eqz v0, :cond_9e

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    if-eqz v0, :cond_9e

    invoke-virtual {v0}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;->getWindowToken()Landroid/os/IBinder;

    move-result-object v0

    if-nez v0, :cond_14

    goto/16 :goto_9e

    :cond_14
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-nez v0, :cond_42

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->context:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->context:Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "stroke_filter_overlay_view"

    const-string v3, "layout"

    invoke-virtual {v0, v2, v3, v1}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_2f

    return-void

    :cond_2f
    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    invoke-interface {v1, v0}, Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;->inflatePopupView(I)Landroid/view/View;

    move-result-object v0

    instance-of v1, v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    if-nez v1, :cond_3a

    return-void

    :cond_3a
    check-cast v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->setEnabled(Z)V

    :cond_42
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

    invoke-interface {v0}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;->getKeyboardArea()Landroid/view/View;

    move-result-object v0

    if-eqz v0, :cond_9d

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I

    move-result v1

    if-lez v1, :cond_9d

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    invoke-virtual {v1}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;->getWidth()I

    move-result v1

    if-gtz v1, :cond_59

    goto :goto_9d

    :cond_59
    const/4 v1, 0x2

    new-array v2, v1, [I

    new-array v1, v1, [I

    iget-object v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    invoke-virtual {v3, v2}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;->getLocationInWindow([I)V

    invoke-virtual {v0, v1}, Landroid/view/View;->getLocationInWindow([I)V

    const/4 v3, 0x1

    aget v2, v2, v3

    aget v1, v1, v3

    sub-int/2addr v2, v1

    iput v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailYOffset:I

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    new-instance v2, Landroid/widget/FrameLayout$LayoutParams;

    iget-object v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    invoke-virtual {v3}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;->getWidth()I

    move-result v3

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I

    move-result v0

    invoke-direct {v2, v3, v0}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v1, v2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    invoke-interface {v0, v1}, Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;->isPopupViewShowing(Landroid/view/View;)Z

    move-result v0

    if-nez v0, :cond_9c

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    iget-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailView:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterTrailView;

    iget-object v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    const/16 v4, 0x122

    const/4 v5, 0x0

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->trailYOffset:I

    neg-int v6, v0

    const/4 v7, 0x0

    invoke-interface/range {v1 .. v7}, Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;->showPopupView(Landroid/view/View;Landroid/view/View;IIILandroid/animation/Animator;)V

    :cond_9c
    return-void

    :cond_9d
    :goto_9d
    return-void

    :cond_9e
    :goto_9e
    return-void
.end method


# virtual methods
.method public acceptInitialEvent(Landroid/view/MotionEvent;)Z
    .locals 0

    if-eqz p1, :cond_10

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getActionMasked()I

    move-result p1

    if-nez p1, :cond_10

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isCaptureActive()Z

    move-result p1

    if-eqz p1, :cond_10

    const/4 p1, 0x1

    goto :goto_11

    :cond_10
    const/4 p1, 0x0

    :goto_11
    return p1
.end method

.method public activate()V
    .locals 0

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->activateTPlus()V

    return-void
.end method

.method public close()V
    .locals 1

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->deactivate()V

    invoke-direct {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->dismissTrail()V

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->context:Landroid/content/Context;

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    return-void
.end method

.method public deactivate()V
    .locals 0

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->reset()V

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->deactivateTPlus()V

    return-void
.end method

.method public handle(Landroid/view/MotionEvent;)V
    .locals 3

    if-nez p1, :cond_3

    return-void

    :cond_3
    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->activateTPlus()V

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getActionMasked()I

    move-result v0

    if-nez v0, :cond_16

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isCaptureActive()Z

    move-result v0

    if-eqz v0, :cond_15

    invoke-direct {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->begin(Landroid/view/MotionEvent;)V

    :cond_15
    return-void

    :cond_16
    iget-boolean v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->tracking:Z

    if-nez v1, :cond_1b

    return-void

    :cond_1b
    const/4 v1, 0x2

    const/4 v2, 0x1

    if-eq v0, v1, :cond_21

    if-ne v0, v2, :cond_2c

    :cond_21
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getX()F

    move-result v1

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getY()F

    move-result p1

    invoke-direct {p0, v1, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->add(FF)V

    :cond_2c
    iget-boolean p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->targetClaimed:Z

    if-nez p1, :cond_44

    iget p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->maxOffsetSquare:F

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->touchSlop:I

    mul-int v1, v1, v1

    int-to-float v1, v1

    cmpl-float p1, p1, v1

    if-ltz p1, :cond_44

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

    if-eqz p1, :cond_44

    iput-boolean v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->targetClaimed:Z

    invoke-interface {p1}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;->declareTargetHandler()V

    :cond_44
    if-ne v0, v2, :cond_52

    iget-boolean p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->targetClaimed:Z

    if-eqz p1, :cond_4e

    invoke-direct {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->finish()V

    goto :goto_58

    :cond_4e
    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->reset()V

    goto :goto_58

    :cond_52
    const/4 p1, 0x3

    if-ne v0, p1, :cond_58

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->reset()V

    :cond_58
    :goto_58
    return-void
.end method

.method public handleInitialMotionEvent(Landroid/view/MotionEvent;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->begin(Landroid/view/MotionEvent;)V

    return-void
.end method

.method public initialize(Landroid/content/Context;Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;)V
    .locals 0

    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->context:Landroid/content/Context;

    iput-object p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->delegate:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;

    invoke-interface {p2}, Lcom/google/android/apps/inputmethod/libs/framework/keyboard/IMotionEventHandlerDelegate;->getPopupViewManager()Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    move-result-object p2

    iput-object p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->popupManager:Lcom/google/android/apps/inputmethod/libs/framework/core/IPopupViewManager;

    invoke-static {p1}, Landroid/view/ViewConfiguration;->get(Landroid/content/Context;)Landroid/view/ViewConfiguration;

    move-result-object p1

    invoke-virtual {p1}, Landroid/view/ViewConfiguration;->getScaledTouchSlop()I

    move-result p1

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->touchSlop:I

    return-void
.end method

.method public onKeyboardViewStateChanged(JJ)V
    .locals 0

    return-void
.end method

.method public onSoftKeyboardViewAttachedToWindow()V
    .locals 0

    return-void
.end method

.method public onSoftKeyboardViewDetachedFromWindow()V
    .locals 0

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->reset()V

    invoke-direct {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->dismissTrail()V

    return-void
.end method

.method public onSoftKeyboardViewLayout(ZIIII)V
    .locals 0

    return-void
.end method

.method public preHandleAsTargetHandler(Landroid/view/MotionEvent;)Z
    .locals 0

    invoke-virtual {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->handle(Landroid/view/MotionEvent;)V

    const/4 p1, 0x1

    return p1
.end method

.method public reset()V
    .locals 1

    const/4 v0, 0x1

    invoke-direct {p0, v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->resetTracking(Z)V

    return-void
.end method

.method public setSoftKeyboardView(Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;)V
    .locals 1

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    if-eq v0, p1, :cond_7

    invoke-direct {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->dismissTrail()V

    :cond_7
    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterMotionEventHandler;->keyboardView:Lcom/google/android/apps/inputmethod/libs/framework/keyboard/SoftKeyboardView;

    return-void
.end method
