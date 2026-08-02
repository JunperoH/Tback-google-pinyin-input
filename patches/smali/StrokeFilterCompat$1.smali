.class Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat$1;
.super Ljava/lang/Object;
.source "StrokeFilterCompat.java"

# interfaces
.implements Landroid/view/View$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->updateToggle(Landroid/view/View;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$root:Landroid/view/View;


# direct methods
.method constructor <init>(Landroid/view/View;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat$1;->val$root:Landroid/view/View;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 0

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->toggleCapture()Z

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat$1;->val$root:Landroid/view/View;

    invoke-static {p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->updateToggle(Landroid/view/View;)V

    return-void
.end method
