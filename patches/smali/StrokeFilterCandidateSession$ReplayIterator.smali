.class final Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;
.super Ljava/lang/Object;
.source "StrokeFilterCandidateSession.java"

# interfaces
.implements Ljava/util/Iterator;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "ReplayIterator"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/util/Iterator<",
        "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
        ">;"
    }
.end annotation


# instance fields
.field private final cache:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;"
        }
    .end annotation
.end field

.field private cursor:I

.field private final source:Ljava/util/Iterator;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Iterator<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;"
        }
    .end annotation
.end field

.field private final sourceWasExhausted:Z


# direct methods
.method constructor <init>(Ljava/util/List;Ljava/util/Iterator;Z)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;",
            "Ljava/util/Iterator<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;Z)V"
        }
    .end annotation

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0, p1}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    iput-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cache:Ljava/util/List;

    iput-object p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->source:Ljava/util/Iterator;

    iput-boolean p3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->sourceWasExhausted:Z

    return-void
.end method


# virtual methods
.method public hasNext()Z
    .locals 2

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cursor:I

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cache:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-lt v0, v1, :cond_1b

    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->sourceWasExhausted:Z

    if-nez v0, :cond_19

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->source:Ljava/util/Iterator;

    if-eqz v0, :cond_19

    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_19

    goto :goto_1b

    :cond_19
    const/4 v0, 0x0

    goto :goto_1c

    :cond_1b
    :goto_1b
    const/4 v0, 0x1

    :goto_1c
    return v0
.end method

.method public next()Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;
    .locals 3

    iget v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cursor:I

    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cache:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_19

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cache:Ljava/util/List;

    iget v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cursor:I

    add-int/lit8 v2, v1, 0x1

    iput v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->cursor:I

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    return-object v0

    :cond_19
    iget-boolean v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->sourceWasExhausted:Z

    if-nez v0, :cond_28

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->source:Ljava/util/Iterator;

    if-eqz v0, :cond_28

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    return-object v0

    :cond_28
    new-instance v0, Ljava/util/NoSuchElementException;

    invoke-direct {v0}, Ljava/util/NoSuchElementException;-><init>()V

    throw v0
.end method

.method public bridge synthetic next()Ljava/lang/Object;
    .locals 1

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession$ReplayIterator;->next()Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    move-result-object v0

    return-object v0
.end method

.method public remove()V
    .locals 1

    new-instance v0, Ljava/lang/UnsupportedOperationException;

    invoke-direct {v0}, Ljava/lang/UnsupportedOperationException;-><init>()V

    throw v0
.end method
