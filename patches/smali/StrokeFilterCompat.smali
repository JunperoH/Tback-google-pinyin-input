.class public final Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;
.super Ljava/lang/Object;
.source "StrokeFilterCompat.java"


# static fields
.field public static final PREF_KEY:Ljava/lang/String; = "tplus_stroke_filter_enabled"

.field private static final SESSIONS:Ljava/util/WeakHashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/WeakHashMap<",
            "Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;",
            "Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;",
            ">;"
        }
    .end annotation
.end field

.field public static final STROKE_EVENT_BASE:I = -0x9c40

.field private static applicationContext:Landroid/content/Context;

.field private static captureActive:Z

.field private static currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

.field private static prefix:Ljava/lang/String;

.field private static tplusActive:Z


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    const-string v0, ""

    sput-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static declared-synchronized activateTPlus()V
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    const/4 v1, 0x1

    :try_start_4
    sput-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z
    :try_end_6
    .catchall {:try_start_4 .. :try_end_6} :catchall_8

    monitor-exit v0

    return-void

    :catchall_8
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized appendStroke(I)Z
    .locals 4

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isCaptureActive()Z

    move-result v1

    if-eqz v1, :cond_35

    const/4 v1, 0x1

    if-lt p0, v1, :cond_35

    const/4 v2, 0x5

    if-gt p0, v2, :cond_35

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    if-lt v3, v2, :cond_18

    goto :goto_35

    :cond_18
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    add-int/lit8 p0, p0, 0x30

    int-to-char p0, p0

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->restartCurrentFilter()V
    :try_end_33
    .catchall {:try_start_3 .. :try_end_33} :catchall_38

    monitor-exit v0

    return v1

    :cond_35
    :goto_35
    monitor-exit v0

    const/4 p0, 0x0

    return p0

    :catchall_38
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method public static declared-synchronized deactivateTPlus()V
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    const/4 v1, 0x0

    :try_start_4
    sput-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    sput-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    const-string v1, ""

    sput-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->destroyAllSessions()V
    :try_end_f
    .catchall {:try_start_4 .. :try_end_f} :catchall_11

    monitor-exit v0

    return-void

    :catchall_11
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized deleteStroke()Z
    .locals 5

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1
    :try_end_9
    .catchall {:try_start_3 .. :try_end_9} :catchall_41

    const/4 v2, 0x0

    if-nez v1, :cond_e

    monitor-exit v0

    return v2

    :cond_e
    :try_start_e
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v3

    const/4 v4, 0x1

    sub-int/2addr v3, v4

    invoke-virtual {v1, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    sput-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_3c

    sput-boolean v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    sget-object v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v1, v2}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    if-eqz v1, :cond_3a

    sget-object v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-static {v2, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v1, v4}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->doUpdateTextCandidates(Z)V
    :try_end_3a
    .catchall {:try_start_e .. :try_end_3a} :catchall_41

    :cond_3a
    monitor-exit v0

    return v4

    :cond_3c
    :try_start_3c
    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->restartCurrentFilter()V
    :try_end_3f
    .catchall {:try_start_3c .. :try_end_3f} :catchall_41

    monitor-exit v0

    return v4

    :catchall_41
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method private static destroyAllSessions()V
    .locals 2

    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v0}, Ljava/util/WeakHashMap;->values()Ljava/util/Collection;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_a
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1a

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    invoke-virtual {v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->destroy()V

    goto :goto_a

    :cond_1a
    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v0}, Ljava/util/WeakHashMap;->clear()V

    const/4 v0, 0x0

    sput-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    return-void
.end method

.method private static failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V
    .locals 1

    iget v0, p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    add-int/lit8 v0, v0, 0x1

    iput v0, p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->filterGeneration:I

    invoke-virtual {p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->cancelPending()V

    invoke-virtual {p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->createReplayIterator()Ljava/util/Iterator;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->mTextCandidateIterator:Ljava/util/Iterator;

    sget-object p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {p1, p0}, Ljava/util/WeakHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    const/4 p0, 0x0

    sput-boolean p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    const-string p0, ""

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    return-void
.end method

.method static declared-synchronized failOpenFromSession(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v1, p0}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    if-ne v1, p1, :cond_e

    invoke-static {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V
    :try_end_e
    .catchall {:try_start_3 .. :try_end_e} :catchall_10

    :cond_e
    monitor-exit v0

    return-void

    :catchall_10
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method public static declared-synchronized getPrefix()Ljava/lang/String;
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_7

    monitor-exit v0

    return-object v1

    :catchall_7
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized getState()I
    .locals 3

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    sget-object v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v1, v2}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    if-nez v1, :cond_11

    const/4 v1, 0x0

    goto :goto_13

    :cond_11
    iget v1, v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->state:I
    :try_end_13
    .catchall {:try_start_3 .. :try_end_13} :catchall_15

    :goto_13
    monitor-exit v0

    return v1

    :catchall_15
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized handleFilteredCommit(Lcom/google/android/apps/inputmethod/libs/chinese/ime/hmm/AbstractHmmChineseDecodeProcessor;)Z
    .locals 4

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v1, p0}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    invoke-static {p0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->shouldHandle(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)Z

    move-result v2
    :try_end_f
    .catchall {:try_start_3 .. :try_end_f} :catchall_34

    if-nez v2, :cond_14

    monitor-exit v0

    const/4 p0, 0x0

    return p0

    :cond_14
    :try_start_14
    iget-object v2, v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->firstMatchedCandidateForFilter:Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;

    const/4 v3, 0x1

    if-nez v2, :cond_21

    invoke-static {p0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V

    invoke-virtual {p0, v3}, Lcom/google/android/apps/inputmethod/libs/chinese/ime/hmm/AbstractHmmChineseDecodeProcessor;->doUpdateTextCandidates(Z)V
    :try_end_1f
    .catchall {:try_start_14 .. :try_end_1f} :catchall_34

    monitor-exit v0

    return v3

    :cond_21
    :try_start_21
    invoke-virtual {p0, v2, v3}, Lcom/google/android/apps/inputmethod/libs/chinese/ime/hmm/AbstractHmmChineseDecodeProcessor;->onSelectTextCandidate(Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;Z)Z

    move-result v2

    if-nez v2, :cond_2f

    invoke-static {p0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V

    invoke-virtual {p0, v3}, Lcom/google/android/apps/inputmethod/libs/chinese/ime/hmm/AbstractHmmChineseDecodeProcessor;->doUpdateTextCandidates(Z)V
    :try_end_2d
    .catchall {:try_start_21 .. :try_end_2d} :catchall_34

    monitor-exit v0

    return v3

    :cond_2f
    :try_start_2f
    invoke-static {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->onResetInternalStates(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;)V
    :try_end_32
    .catchall {:try_start_2f .. :try_end_32} :catchall_34

    monitor-exit v0

    return v3

    :catchall_34
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method public static declared-synchronized initialize(Landroid/content/Context;)V
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    if-nez v1, :cond_f

    if-eqz p0, :cond_f

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;
    :try_end_f
    .catchall {:try_start_3 .. :try_end_f} :catchall_11

    :cond_f
    monitor-exit v0

    return-void

    :catchall_11
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method public static declared-synchronized isCaptureActive()Z
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    if-eqz v1, :cond_1d

    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    if-eqz v1, :cond_1d

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isSettingEnabled()Z

    move-result v1

    if-eqz v1, :cond_1d

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    if-eqz v1, :cond_1d

    invoke-virtual {v1}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->isComposing()Z

    move-result v1
    :try_end_19
    .catchall {:try_start_3 .. :try_end_19} :catchall_20

    if-eqz v1, :cond_1d

    const/4 v1, 0x1

    goto :goto_1e

    :cond_1d
    const/4 v1, 0x0

    :goto_1e
    monitor-exit v0

    return v1

    :catchall_20
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized isDataReady()Z
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    if-eqz v1, :cond_f

    invoke-static {v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->get(Landroid/content/Context;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

    move-result-object v1
    :try_end_b
    .catchall {:try_start_3 .. :try_end_b} :catchall_12

    if-eqz v1, :cond_f

    const/4 v1, 0x1

    goto :goto_10

    :cond_f
    const/4 v1, 0x0

    :goto_10
    monitor-exit v0

    return v1

    :catchall_12
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method private static isSettingEnabled()Z
    .locals 3

    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    const/4 v1, 0x0

    if-nez v0, :cond_6

    return v1

    :cond_6
    nop

    invoke-static {v0}, Landroid/preference/PreferenceManager;->getDefaultSharedPreferences(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v0

    const-string v2, "tplus_stroke_filter_enabled"

    invoke-interface {v0, v2, v1}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z

    move-result v0

    return v0
.end method

.method private static localized(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 3

    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    if-nez v0, :cond_5

    return-object p1

    :cond_5
    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "string"

    invoke-virtual {v0, p0, v2, v1}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    if-nez p0, :cond_18

    goto :goto_1e

    :cond_18
    sget-object p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    invoke-virtual {p1, p0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p1

    :goto_1e
    return-object p1
.end method

.method public static declared-synchronized onResetInternalStates(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;)V
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v1, p0}, Ljava/util/WeakHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    if-eqz v1, :cond_10

    invoke-virtual {v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->destroy()V

    :cond_10
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    if-ne v1, p0, :cond_1e

    const/4 p0, 0x0

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    const/4 p0, 0x0

    sput-boolean p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    const-string p0, ""

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;
    :try_end_1e
    .catchall {:try_start_3 .. :try_end_1e} :catchall_20

    :cond_1e
    monitor-exit v0

    return-void

    :catchall_20
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method public static declared-synchronized onSetTextCandidates(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Ljava/util/Iterator;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;",
            "Ljava/util/Iterator<",
            "Lcom/google/android/apps/inputmethod/libs/framework/core/Candidate;",
            ">;)V"
        }
    .end annotation

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    if-nez p0, :cond_7

    monitor-exit v0

    return-void

    :cond_7
    :try_start_7
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v1, p0}, Ljava/util/WeakHashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v2

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v1, p0}, Ljava/util/WeakHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    if-eqz v3, :cond_1a

    invoke-virtual {v3}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->destroy()V

    :cond_1a
    sget-boolean v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    if-eqz v3, :cond_4d

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isSettingEnabled()Z

    move-result v3

    if-eqz v3, :cond_4d

    if-nez p1, :cond_27

    goto :goto_4d

    :cond_27
    new-instance v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    invoke-direct {v3}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;-><init>()V

    invoke-virtual {v3, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->bind(Ljava/util/Iterator;)V

    invoke-virtual {v1, p0, v3}, Ljava/util/WeakHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    if-nez v2, :cond_4b

    sget-object p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result p1

    if-nez p1, :cond_4b

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->isComposing()Z

    move-result p0

    if-eqz p0, :cond_4b

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isDataReady()Z

    move-result p0

    if-eqz p0, :cond_4b

    const/4 p0, 0x1

    sput-boolean p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z
    :try_end_4b
    .catchall {:try_start_7 .. :try_end_4b} :catchall_56

    :cond_4b
    monitor-exit v0

    return-void

    :cond_4d
    :goto_4d
    const/4 p0, 0x0

    :try_start_4e
    sput-boolean p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    const-string p0, ""

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;
    :try_end_54
    .catchall {:try_start_4e .. :try_end_54} :catchall_56

    monitor-exit v0

    return-void

    :catchall_56
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method public static declared-synchronized requestCandidates(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;I)Z
    .locals 4

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    invoke-virtual {v1, p0}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    invoke-static {p0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->shouldHandle(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)Z

    move-result v2

    const/4 v3, 0x0

    if-nez v2, :cond_21

    if-eqz v1, :cond_1f

    sget-object p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result p1

    if-lez p1, :cond_1f

    invoke-static {p0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V
    :try_end_1f
    .catchall {:try_start_3 .. :try_end_1f} :catchall_3a

    :cond_1f
    monitor-exit v0

    return v3

    :cond_21
    :try_start_21
    sget-object v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->applicationContext:Landroid/content/Context;

    invoke-static {v2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->get(Landroid/content/Context;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

    move-result-object v2

    if-nez v2, :cond_32

    invoke-static {p0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->failOpen(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)V

    const/4 p1, 0x1

    invoke-virtual {p0, p1}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->doUpdateTextCandidates(Z)V
    :try_end_30
    .catchall {:try_start_21 .. :try_end_30} :catchall_3a

    monitor-exit v0

    return v3

    :cond_32
    :try_start_32
    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v1, p0, p1, v3, v2}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->request(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;ILjava/lang/String;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;)Z

    move-result p0
    :try_end_38
    .catchall {:try_start_32 .. :try_end_38} :catchall_3a

    monitor-exit v0

    return p0

    :catchall_3a
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method private static restartCurrentFilter()V
    .locals 2

    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v0, v1}, Ljava/util/WeakHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    if-eqz v0, :cond_1b

    iget-boolean v1, v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    if-nez v1, :cond_11

    goto :goto_1b

    :cond_11
    invoke-virtual {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->resetFilter()V

    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->doUpdateTextCandidates(Z)V

    return-void

    :cond_1b
    :goto_1b
    return-void
.end method

.method public static declared-synchronized shouldDisableTPlusGesture()Z
    .locals 2

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    if-eqz v1, :cond_f

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isSettingEnabled()Z

    move-result v1
    :try_end_b
    .catchall {:try_start_3 .. :try_end_b} :catchall_12

    if-eqz v1, :cond_f

    const/4 v1, 0x1

    goto :goto_10

    :cond_f
    const/4 v1, 0x0

    :goto_10
    monitor-exit v0

    return v1

    :catchall_12
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method static declared-synchronized shouldHandle(Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;)Z
    .locals 1

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    if-eqz p0, :cond_2c

    if-eqz p1, :cond_2c

    :try_start_7
    iget-boolean p1, p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->valid:Z

    if-eqz p1, :cond_2c

    sget-object p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    if-ne p0, p1, :cond_2c

    sget-boolean p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    if-eqz p1, :cond_2c

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isSettingEnabled()Z

    move-result p1

    if-eqz p1, :cond_2c

    sget-object p1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result p1

    if-lez p1, :cond_2c

    invoke-virtual {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->isComposing()Z

    move-result p0
    :try_end_25
    .catchall {:try_start_7 .. :try_end_25} :catchall_29

    if-eqz p0, :cond_2c

    const/4 p0, 0x1

    goto :goto_2d

    :catchall_29
    move-exception p0

    monitor-exit v0

    throw p0

    :cond_2c
    const/4 p0, 0x0

    :goto_2d
    monitor-exit v0

    return p0
.end method

.method public static declared-synchronized toggleCapture()Z
    .locals 5

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    :try_start_3
    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    const/4 v2, 0x0

    if-eqz v1, :cond_50

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isSettingEnabled()Z

    move-result v1

    if-eqz v1, :cond_50

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    if-eqz v1, :cond_50

    invoke-virtual {v1}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->isComposing()Z

    move-result v1

    if-eqz v1, :cond_50

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isDataReady()Z

    move-result v1

    if-nez v1, :cond_1f

    goto :goto_50

    :cond_1f
    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->SESSIONS:Ljava/util/WeakHashMap;

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v1, v3}, Ljava/util/WeakHashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_40

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    iget-object v3, v3, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->mTextCandidateIterator:Ljava/util/Iterator;

    if-eqz v3, :cond_40

    new-instance v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;

    invoke-direct {v3}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;-><init>()V

    sget-object v4, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    iget-object v4, v4, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->mTextCandidateIterator:Ljava/util/Iterator;

    invoke-virtual {v3, v4}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCandidateSession;->bind(Ljava/util/Iterator;)V

    sget-object v4, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    invoke-virtual {v1, v4, v3}, Ljava/util/WeakHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_40
    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    if-nez v1, :cond_45

    const/4 v2, 0x1

    :cond_45
    sput-boolean v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    if-nez v2, :cond_4c

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->restartCurrentFilter()V

    :cond_4c
    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z
    :try_end_4e
    .catchall {:try_start_3 .. :try_end_4e} :catchall_54

    monitor-exit v0

    return v1

    :cond_50
    :goto_50
    :try_start_50
    sput-boolean v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z
    :try_end_52
    .catchall {:try_start_50 .. :try_end_52} :catchall_54

    monitor-exit v0

    return v2

    :catchall_54
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method public static declared-synchronized updateToggle(Landroid/view/View;)V
    .locals 8

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;

    monitor-enter v0

    if-nez p0, :cond_7

    monitor-exit v0

    return-void

    :cond_7
    :try_start_7
    const-string v1, "compat_stroke_filter_toggle"

    invoke-virtual {p0, v1}, Landroid/view/View;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v1

    const-string v2, "compat_stroke_filter_holder"

    invoke-virtual {p0, v2}, Landroid/view/View;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v2
    :try_end_13
    .catchall {:try_start_7 .. :try_end_13} :catchall_cf

    if-nez v1, :cond_17

    monitor-exit v0

    return-void

    :cond_17
    :try_start_17
    sget-boolean v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->tplusActive:Z

    const/4 v4, 0x1

    const/4 v5, 0x0

    if-eqz v3, :cond_35

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isSettingEnabled()Z

    move-result v3

    if-eqz v3, :cond_35

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->currentIme:Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;

    if-eqz v3, :cond_35

    invoke-virtual {v3}, Lcom/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor;->isComposing()Z

    move-result v3

    if-eqz v3, :cond_35

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->isDataReady()Z

    move-result v3

    if-eqz v3, :cond_35

    const/4 v3, 0x1

    goto :goto_36

    :cond_35
    const/4 v3, 0x0

    :goto_36
    if-eqz v3, :cond_3a

    const/4 v6, 0x0

    goto :goto_3c

    :cond_3a
    const/16 v6, 0x8

    :goto_3c
    invoke-virtual {v1, v6}, Landroid/view/View;->setVisibility(I)V

    sget-boolean v6, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    invoke-virtual {v1, v6}, Landroid/view/View;->setSelected(Z)V

    if-eqz v2, :cond_6f

    if-eqz v3, :cond_5b

    invoke-virtual {v2}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v5

    iget v5, v5, Landroid/util/DisplayMetrics;->density:F

    const/high16 v6, 0x42400000    # 48.0f

    mul-float v5, v5, v6

    const/high16 v6, 0x3f000000    # 0.5f

    add-float/2addr v5, v6

    float-to-int v5, v5

    goto :goto_5c

    :cond_5b
    nop

    :goto_5c
    invoke-virtual {v2}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v6

    instance-of v7, v6, Landroid/view/ViewGroup$MarginLayoutParams;

    if-eqz v7, :cond_6f

    check-cast v6, Landroid/view/ViewGroup$MarginLayoutParams;

    iget v7, v6, Landroid/view/ViewGroup$MarginLayoutParams;->rightMargin:I

    if-eq v7, v5, :cond_6f

    iput v5, v6, Landroid/view/ViewGroup$MarginLayoutParams;->rightMargin:I

    invoke-virtual {v2, v6}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    :try_end_6f
    .catchall {:try_start_17 .. :try_end_6f} :catchall_cf

    :cond_6f
    if-nez v3, :cond_73

    monitor-exit v0

    return-void

    :cond_73
    :try_start_73
    instance-of v2, v1, Landroid/widget/TextView;

    if-eqz v2, :cond_c5

    move-object v2, v1

    check-cast v2, Landroid/widget/TextView;

    invoke-static {}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->getState()I

    move-result v3

    if-ne v3, v4, :cond_91

    sget-object v4, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    if-lez v4, :cond_91

    const-string v3, "stroke_filter_scanning"

    const-string v4, "\u7b5b\u9009\u2026"

    invoke-static {v3, v4}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->localized(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    goto :goto_c2

    :cond_91
    const/4 v4, 0x3

    if-ne v3, v4, :cond_a5

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    if-lez v3, :cond_a5

    const-string v3, "stroke_filter_no_match"

    const-string v4, "\u65e0\u5339\u914d"

    invoke-static {v3, v4}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->localized(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    goto :goto_c2

    :cond_a5
    sget-boolean v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->captureActive:Z

    if-eqz v3, :cond_ba

    sget-object v3, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->prefix:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    if-nez v3, :cond_ba

    const-string v3, "stroke_filter_capturing"

    const-string v4, "\u7b14\u00b7\u753b"

    invoke-static {v3, v4}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->localized(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    goto :goto_c2

    :cond_ba
    const-string v3, "stroke_filter_toggle_label"

    const-string v4, "\u7b14"

    invoke-static {v3, v4}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat;->localized(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    :goto_c2
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :cond_c5
    new-instance v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat$1;

    invoke-direct {v2, p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat$1;-><init>(Landroid/view/View;)V

    invoke-virtual {v1, v2}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    :try_end_cd
    .catchall {:try_start_73 .. :try_end_cd} :catchall_cf

    monitor-exit v0

    return-void

    :catchall_cf
    move-exception p0

    monitor-exit v0

    throw p0
.end method
