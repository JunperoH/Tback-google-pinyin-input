.class public final Lcom/google/android/apps/inputmethod/libs/hmm/TPlusKeyMapping;
.super Ljava/lang/Object;
.source "TPlusKeyMapping.java"


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static getLetters(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)Ljava/lang/String;
    .locals 4

    iget-object v0, p0, Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;->a:Ljava/lang/Object;

    instance-of v1, v0, Ljava/lang/String;

    if-eqz v1, :invalid

    check-cast v0, Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    if-lez v1, :invalid

    const/4 v2, 0x2

    if-gt v1, v2, :invalid

    const/4 v1, 0x0

    :check_character
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v2

    if-ge v1, v2, :valid

    invoke-virtual {v0, v1}, Ljava/lang/String;->charAt(I)C

    move-result v2

    const/16 v3, 0x41

    if-lt v2, v3, :check_lowercase

    const/16 v3, 0x5a

    if-le v2, v3, :next_character

    :check_lowercase
    const/16 v3, 0x61

    if-lt v2, v3, :invalid

    const/16 v3, 0x7a

    if-gt v2, v3, :invalid

    :next_character
    add-int/lit8 v1, v1, 0x1

    goto :check_character

    :valid
    return-object v0

    :invalid
    const/4 v0, 0x0

    return-object v0
.end method


# virtual methods
.method public static containsKey(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)Z
    .locals 1

    invoke-static {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/TPlusKeyMapping;->getLetters(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :not_found

    const/4 v0, 0x1

    return v0

    :not_found
    const/4 v0, 0x0

    return v0
.end method

.method public static mapKeyData(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)[Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;
    .locals 8

    invoke-static {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/TPlusKeyMapping;->getLetters(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :invalid

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    new-array v1, v1, [Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;

    const/4 v2, 0x0

    :map_character
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v3

    if-ge v2, v3, :done

    invoke-virtual {v0, v2}, Ljava/lang/String;->charAt(I)C

    move-result v3

    const/16 v4, 0x61

    if-lt v3, v4, :uppercase

    add-int/lit8 v4, v3, -0x44

    goto :keycode_ready

    :uppercase
    add-int/lit8 v4, v3, -0x24

    :keycode_ready
    invoke-static {v3}, Ljava/lang/String;->valueOf(C)Ljava/lang/String;

    move-result-object v5

    new-instance v6, Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;

    sget-object v7, Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData$a;->DECODE:Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData$a;

    invoke-direct {v6, v4, v7, v5}, Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;-><init>(ILcom/google/android/apps/inputmethod/libs/framework/core/KeyData$a;Ljava/lang/Object;)V

    aput-object v6, v1, v2

    add-int/lit8 v2, v2, 0x1

    goto :map_character

    :done
    return-object v1

    :invalid
    const/4 v0, 0x0

    return-object v0
.end method

.method public static mapScores(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)[F
    .locals 1

    invoke-static {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/TPlusKeyMapping;->getLetters(Lcom/google/android/apps/inputmethod/libs/framework/core/KeyData;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :invalid

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    new-array v0, v0, [F

    return-object v0

    :invalid
    const/4 v0, 0x0

    return-object v0
.end method
