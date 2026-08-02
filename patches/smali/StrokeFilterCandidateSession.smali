.class public final Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;
.super Ljava/lang/Object;
.source "StrokeFilterCandidateSession.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;
    }
.end annotation


# static fields
.field static final CACHE_LIMIT:I = 0x2000

.field public static final IDLE:I = 0x0

.field public static final NO_MATCH:I = 0x3

.field public static final READY:I = 0x2

.field public static final SCANNING:I = 0x1

.field static final SCAN_BUDGET:I = 0x100


# instance fields
.field cacheLimitReached:Z

.field composingGeneration:I

.field filterGeneration:I

.field firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

.field private final handler:Landroid/os/Handler;

.field pendingRunnable:Ljava/lang/Runnable;

.field final rawCandidateCache:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;"
        }
    .end annotation
.end field

.field rawCursor:I

.field sourceExhausted:Z

.field sourceIterator:Ljava/util/Iterator;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Iterator<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;"
        }
    .end annotation
.end field

.field state:I

.field valid:Z


# direct methods
.method public constructor <init>()V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    const/4 v0, 0x0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->handler:Landroid/os/Handler;

    return-void
.end method

.method static synthetic access$000(Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;II)Z
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result p0

    return p0
.end method

.method private hasUnreadRawCandidate()Z
    .locals 4

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v1

    const/4 v2, 0x1

    if-ge v0, v1, :cond_c

    return v2

    :cond_c
    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    const/4 v1, 0x0

    if-nez v0, :cond_2c

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceIterator:Ljava/util/Iterator;

    if-nez v0, :cond_16

    goto :goto_2c

    :cond_16
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-nez v0, :cond_1f

    iput-boolean v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    return v1

    :cond_1f
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result v0

    const/16 v3, 0x2000

    if-ge v0, v3, :cond_2a

    goto :goto_2b

    :cond_2a
    const/4 v2, 0x0

    :goto_2b
    return v2

    :cond_2c
    :goto_2c
    return v1
.end method

.method private static isHan(I)Z
    .locals 1

    const/16 v0, 0x3007

    if-eq p0, v0, :cond_21

    const/16 v0, 0x3400

    if-lt p0, v0, :cond_c

    const/16 v0, 0x4dbf

    if-le p0, v0, :cond_21

    :cond_c
    const/16 v0, 0x4e00

    if-lt p0, v0, :cond_15

    const v0, 0x9fff

    if-le p0, v0, :cond_21

    :cond_15
    const/high16 v0, 0x20000

    if-lt p0, v0, :cond_1f

    const v0, 0x323af

    if-gt p0, v0, :cond_1f

    goto :goto_21

    :cond_1f
    const/4 p0, 0x0

    goto :goto_22

    :cond_21
    :goto_21
    const/4 p0, 0x1

    :goto_22
    return p0
.end method

.method private matches(Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;Ljava/lang/String;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;)Z
    .locals 2

    const/4 v0, 0x0

    if-eqz p1, :cond_24

    iget-object v1, p1, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;->a:Ljava/lang/CharSequence;

    if-eqz v1, :cond_24

    iget-object v1, p1, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;->a:Ljava/lang/CharSequence;

    invoke-interface {v1}, Ljava/lang/CharSequence;->length()I

    move-result v1

    if-nez v1, :cond_10

    goto :goto_24

    :cond_10
    iget-object p1, p1, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;->a:Ljava/lang/CharSequence;

    invoke-static {p1, v0}, Ljava/lang/Character;->codePointAt(Ljava/lang/CharSequence;I)I

    move-result p1

    invoke-static {p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->isHan(I)Z

    move-result v1

    if-eqz v1, :cond_23

    invoke-virtual {p3, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->matches(ILjava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_23

    const/4 v0, 0x1

    :cond_23
    return v0

    :cond_24
    :goto_24
    return v0
.end method

.method private nextRawCandidate(II)Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;
    .locals 4

    invoke-direct {p0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result v0

    const/4 v1, 0x0

    if-nez v0, :cond_8

    return-object v1

    :cond_8
    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    iget-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    const/4 v3, 0x1

    if-ge v0, v2, :cond_2a

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    iget v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    invoke-direct {p0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result p1

    if-nez p1, :cond_24

    return-object v1

    :cond_24
    iget p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    add-int/2addr p1, v3

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    return-object v0

    :cond_2a
    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    if-nez v0, :cond_69

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceIterator:Ljava/util/Iterator;

    if-nez v0, :cond_33

    goto :goto_69

    :cond_33
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-nez v0, :cond_42

    invoke-direct {p0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result p1

    if-eqz p1, :cond_41

    iput-boolean v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    :cond_41
    return-object v1

    :cond_42
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result v0

    const/16 v2, 0x2000

    if-lt v0, v2, :cond_4f

    iput-boolean v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cacheLimitReached:Z

    return-object v1

    :cond_4f
    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceIterator:Ljava/util/Iterator;

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    invoke-direct {p0, p1, p2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result p1

    if-nez p1, :cond_5e

    return-object v1

    :cond_5e
    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    iget p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    add-int/2addr p1, v3

    iput p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    return-object v0

    :cond_69
    :goto_69
    return-object v1
.end method

.method private tokensMatch(II)Z
    .locals 1

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    if-eqz v0, :cond_e

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->composingGeneration:I

    if-ne v0, p1, :cond_e

    iget p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    if-ne p1, p2, :cond_e

    const/4 p1, 0x1

    goto :goto_f

    :cond_e
    const/4 p1, 0x0

    :goto_f
    return p1
.end method


# virtual methods
.method public bind(Ljava/util/Iterator;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Iterator<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;)V"
        }
    .end annotation

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cancelPending()V

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->composingGeneration:I

    const/4 v1, 0x1

    add-int/2addr v0, v1

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->composingGeneration:I

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    add-int/2addr v0, v1

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceIterator:Ljava/util/Iterator;

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    const/4 v0, 0x0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    if-nez p1, :cond_1c

    const/4 v2, 0x1

    goto :goto_1d

    :cond_1c
    const/4 v2, 0x0

    :goto_1d
    iput-boolean v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    iput-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cacheLimitReached:Z

    const/4 v2, 0x0

    iput-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    if-eqz p1, :cond_29

    goto :goto_2a

    :cond_29
    const/4 v1, 0x0

    :goto_2a
    iput-boolean v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    return-void
.end method

.method public cancelPending()V
    .locals 2

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->pendingRunnable:Ljava/lang/Runnable;

    if-eqz v0, :cond_c

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->handler:Landroid/os/Handler;

    invoke-virtual {v1, v0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->pendingRunnable:Ljava/lang/Runnable;

    :cond_c
    return-void
.end method

.method public createReplayIterator()Ljava/util/Iterator;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Iterator<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;"
        }
    .end annotation

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cancelPending()V

    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    new-instance v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    iget-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceIterator:Ljava/util/Iterator;

    iget-boolean v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    invoke-direct {v0, v1, v2, v3}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;-><init>(Ljava/util/List;Ljava/util/Iterator;Z)V

    return-object v0
.end method

.method public destroy()V
    .locals 3

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cancelPending()V

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->composingGeneration:I

    const/4 v1, 0x1

    add-int/2addr v0, v1

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->composingGeneration:I

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    add-int/2addr v0, v1

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceIterator:Ljava/util/Iterator;

    iget-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCandidateCache:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->clear()V

    const/4 v2, 0x0

    iput v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    iput-boolean v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    iput-boolean v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cacheLimitReached:Z

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    iput v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    iput-boolean v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    return-void
.end method

.method public request(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;ILjava/lang/String;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;)Z
    .locals 10

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    const/4 v1, 0x0

    if-eqz v0, :cond_ad

    if-lez p2, :cond_ad

    if-eqz p3, :cond_ad

    invoke-virtual {p3}, Ljava/lang/String;->length()I

    move-result v0

    if-eqz v0, :cond_ad

    if-nez p4, :cond_13

    goto/16 :goto_ad

    :cond_13
    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cancelPending()V

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->composingGeneration:I

    iget v8, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    nop

    :goto_20
    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v3

    const/4 v9, 0x1

    if-ge v3, p2, :cond_52

    const/16 v3, 0x100

    if-ge v1, v3, :cond_52

    invoke-direct {p0, v0, v8}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result v3

    if-nez v3, :cond_32

    return v9

    :cond_32
    invoke-direct {p0, v0, v8}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->nextRawCandidate(II)Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    move-result-object v3

    if-nez v3, :cond_39

    goto :goto_52

    :cond_39
    add-int/lit8 v1, v1, 0x1

    invoke-direct {p0, v3, p3, p4}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->matches(Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;Ljava/lang/String;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;)Z

    move-result v4

    if-eqz v4, :cond_51

    invoke-direct {p0, v0, v8}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result v4

    if-nez v4, :cond_48

    return v9

    :cond_48
    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    iget-object v4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    if-nez v4, :cond_51

    iput-object v3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    :cond_51
    goto :goto_20

    :cond_52
    :goto_52
    iget-boolean p3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cacheLimitReached:Z

    if-eqz p3, :cond_5d

    invoke-static {p1, p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpenFromSession(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V

    invoke-virtual {p1, v9}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->doUpdateTextCandidates(Z)V

    return v9

    :cond_5d
    invoke-direct {p0, v0, v8}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result p3

    if-nez p3, :cond_64

    return v9

    :cond_64
    invoke-direct {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->hasUnreadRawCandidate()Z

    move-result p3

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result p4

    if-ge p4, p2, :cond_73

    if-eqz p3, :cond_73

    iput v9, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    goto :goto_82

    :cond_73
    iget-object p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    if-nez p4, :cond_7f

    iget-boolean p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->sourceExhausted:Z

    if-eqz p4, :cond_7f

    const/4 p4, 0x3

    iput p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    goto :goto_82

    :cond_7f
    const/4 p4, 0x2

    iput p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    :goto_82
    iget-object p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    invoke-virtual {p1, v2, p4, p3}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->doAppendTextCandidates(Ljava/util/List;Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;Z)V

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result p4

    if-ge p4, p2, :cond_ac

    if-eqz p3, :cond_ac

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result p3

    sub-int v7, p2, p3

    new-instance p2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;

    move-object v2, p2

    move-object v3, p0

    move v4, v0

    move v5, v8

    move-object v6, p1

    invoke-direct/range {v2 .. v7}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$1;-><init>(Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;IILcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;I)V

    invoke-direct {p0, v0, v8}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->tokensMatch(II)Z

    move-result p1

    if-eqz p1, :cond_ac

    iput-object p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->pendingRunnable:Ljava/lang/Runnable;

    iget-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->handler:Landroid/os/Handler;

    invoke-virtual {p1, p2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    :cond_ac
    return v9

    :cond_ad
    :goto_ad
    return v1
.end method

.method public resetFilter()V
    .locals 2

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cancelPending()V

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    add-int/lit8 v0, v0, 0x1

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    const/4 v0, 0x0

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->rawCursor:I

    const/4 v1, 0x0

    iput-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    iput v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I

    return-void
.end method
