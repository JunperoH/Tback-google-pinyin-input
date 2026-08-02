.class Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;
.super Ljava/lang/Object;
.source "StrokeFilterCandidateSession.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->request(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;ILjava/lang/String;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;)Z
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

.field final synthetic val$expectedComposing:I

.field final synthetic val$expectedFilter:I

.field final synthetic val$ime:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

.field final synthetic val$remaining:I


# direct methods
.method constructor <init>(Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;IILcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;I)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->this$0:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    iput p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$expectedComposing:I

    iput p3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$expectedFilter:I

    iput-object p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$ime:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    iput p5, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$remaining:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->this$0:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$expectedComposing:I

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$expectedFilter:I

    invoke-static {v0, v1, v2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->access$000(Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;II)Z

    move-result v0

    if-eqz v0, :cond_24

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$ime:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->this$0:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    invoke-static {v0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->shouldHandle(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)Z

    move-result v0

    if-nez v0, :cond_17

    goto :goto_24

    :cond_17
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->this$0:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    const/4 v1, 0x0

    iput-object v1, v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->pendingRunnable:Ljava/lang/Runnable;

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$ime:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;->val$remaining:I

    invoke-virtual {v0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->onRequestCandidates(I)Z

    return-void

    :cond_24
    :goto_24
    return-void
.end method
