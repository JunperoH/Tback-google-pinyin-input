.class public final Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;
.super Ljava/lang/Object;
.source "StrokeFilterData.java"


# static fields
.field private static final FORMAT_VERSION:I = 0x1

.field private static final MAGIC:[B

.field private static final SOURCE_SHA256:[B

.field private static final TAG:Ljava/lang/String; = "TPlusStrokeFilter"

.field private static failureLogged:Z

.field private static instance:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

.field private static loadAttempted:Z


# instance fields
.field private final codePoints:[I

.field private final packedStrokes:[S

.field private final variantCounts:[I

.field private final variantLengths:[B

.field private final variantOffsets:[I


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const/4 v0, 0x4

    new-array v0, v0, [B

    fill-array-data v0, :array_12

    sput-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->MAGIC:[B

    const/16 v0, 0x20

    new-array v0, v0, [B

    fill-array-data v0, :array_18

    sput-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->SOURCE_SHA256:[B

    return-void

    :array_12
    .array-data 1
        0x54t
        0x53t
        0x46t
        0x31t
    .end array-data

    :array_18
    .array-data 1
        0x2dt
        -0x5ct
        0x8t
        -0x38t
        -0x68t
        0x26t
        0x13t
        0x2t
        0xbt
        -0x26t
        0x7at
        -0x2ft
        0x6bt
        0x76t
        -0x5dt
        -0x4et
        -0x72t
        -0x6dt
        -0x7ct
        0x3at
        -0x4t
        -0x2et
        0x7t
        -0x18t
        -0x45t
        0x2ct
        -0x64t
        0x74t
        0x37t
        0x27t
        -0xft
        0x23t
    .end array-data
.end method

.method private constructor <init>([I[I[I[B[S)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->codePoints:[I

    iput-object p2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->variantOffsets:[I

    iput-object p3, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->variantCounts:[I

    iput-object p4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->variantLengths:[B

    iput-object p5, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->packedStrokes:[S

    return-void
.end method

.method public static declared-synchronized get(Landroid/content/Context;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;
    .locals 3

    const-class v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

    monitor-enter v0

    :try_start_3
    sget-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->loadAttempted:Z

    if-nez v1, :cond_23

    const/4 v1, 0x1

    sput-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->loadAttempted:Z
    :try_end_a
    .catchall {:try_start_3 .. :try_end_a} :catchall_27

    :try_start_a
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    invoke-static {p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->load(Landroid/content/Context;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

    move-result-object p0

    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->instance:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;
    :try_end_14
    .catchall {:try_start_a .. :try_end_14} :catchall_15

    goto :goto_23

    :catchall_15
    move-exception p0

    :try_start_16
    sget-boolean v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->failureLogged:Z

    if-nez v2, :cond_23

    sput-boolean v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->failureLogged:Z

    const-string v1, "TPlusStrokeFilter"

    const-string v2, "Stroke data unavailable; filtering disabled"

    invoke-static {v1, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_23
    :goto_23
    sget-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->instance:Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;
    :try_end_25
    .catchall {:try_start_16 .. :try_end_25} :catchall_27

    monitor-exit v0

    return-object p0

    :catchall_27
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method private static load(Landroid/content/Context;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    const-string v1, "raw"

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object p0

    const-string v2, "stroke_filter_data"

    invoke-virtual {v0, v2, v1, p0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    if-eqz p0, :cond_28

    invoke-virtual {v0, p0}, Landroid/content/res/Resources;->openRawResource(I)Ljava/io/InputStream;

    move-result-object p0

    :try_start_16
    new-instance v0, Ljava/io/DataInputStream;

    invoke-direct {v0, p0}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    invoke-static {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->read(Ljava/io/DataInputStream;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

    move-result-object v0
    :try_end_1f
    .catchall {:try_start_16 .. :try_end_1f} :catchall_23

    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    return-object v0

    :catchall_23
    move-exception v0

    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    throw v0

    :cond_28
    new-instance p0, Ljava/io/IOException;

    const-string v0, "stroke_filter_data resource not found"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static read(Ljava/io/DataInputStream;)Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;
    .locals 18
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v0, p0

    const/4 v1, 0x4

    new-array v1, v1, [B

    invoke-virtual {v0, v1}, Ljava/io/DataInputStream;->readFully([B)V

    sget-object v2, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->MAGIC:[B

    invoke-static {v1, v2}, Ljava/util/Arrays;->equals([B[B)Z

    move-result v1

    if-eqz v1, :cond_138

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU16LE(Ljava/io/DataInputStream;)I

    move-result v1

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU16LE(Ljava/io/DataInputStream;)I

    move-result v2

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU32LE(Ljava/io/DataInputStream;)J

    move-result-wide v3

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU32LE(Ljava/io/DataInputStream;)J

    move-result-wide v5

    const/16 v7, 0x20

    new-array v7, v7, [B

    invoke-virtual {v0, v7}, Ljava/io/DataInputStream;->readFully([B)V

    const/4 v8, 0x1

    if-ne v1, v8, :cond_130

    if-nez v2, :cond_130

    sget-object v1, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->SOURCE_SHA256:[B

    invoke-static {v7, v1}, Ljava/util/Arrays;->equals([B[B)Z

    move-result v1

    if-eqz v1, :cond_130

    const-wide/16 v1, 0x0

    cmp-long v7, v3, v1

    if-lez v7, :cond_128

    const-wide/32 v1, 0x186a0

    cmp-long v7, v3, v1

    if-gtz v7, :cond_128

    cmp-long v1, v5, v3

    if-ltz v1, :cond_128

    const-wide/32 v1, 0x7a120

    cmp-long v7, v5, v1

    if-gtz v7, :cond_128

    long-to-int v1, v3

    long-to-int v2, v5

    new-array v10, v1, [I

    new-array v11, v1, [I

    new-array v12, v1, [I

    new-array v13, v2, [B

    new-array v14, v2, [S

    nop

    const/4 v5, 0x0

    const/4 v6, -0x1

    :goto_5b
    if-ge v5, v1, :cond_7d

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU32LE(Ljava/io/DataInputStream;)J

    move-result-wide v3

    const-wide/32 v15, 0x10ffff

    cmp-long v17, v3, v15

    if-gtz v17, :cond_75

    int-to-long v7, v6

    cmp-long v6, v3, v7

    if-lez v6, :cond_75

    long-to-int v6, v3

    aput v6, v10, v5

    nop

    add-int/lit8 v5, v5, 0x1

    const/4 v8, 0x1

    goto :goto_5b

    :cond_75
    new-instance v0, Ljava/io/IOException;

    const-string v1, "unsorted TSF1 code points"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_7d
    const/4 v3, 0x0

    :goto_7e
    if-ge v3, v1, :cond_97

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU32LE(Ljava/io/DataInputStream;)J

    move-result-wide v4

    int-to-long v6, v2

    cmp-long v8, v4, v6

    if-gtz v8, :cond_8f

    long-to-int v5, v4

    aput v5, v11, v3

    add-int/lit8 v3, v3, 0x1

    goto :goto_7e

    :cond_8f
    new-instance v0, Ljava/io/IOException;

    const-string v1, "TSF1 variant offset out of range"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_97
    const/4 v3, 0x0

    :goto_98
    if-ge v3, v1, :cond_bf

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU16LE(Ljava/io/DataInputStream;)I

    move-result v4

    aput v4, v12, v3

    if-nez v3, :cond_a4

    const/4 v6, 0x0

    goto :goto_ab

    :cond_a4
    add-int/lit8 v5, v3, -0x1

    aget v6, v11, v5

    aget v5, v12, v5

    add-int/2addr v6, v5

    :goto_ab
    if-eqz v4, :cond_b7

    aget v5, v11, v3

    if-ne v5, v6, :cond_b7

    add-int/2addr v5, v4

    if-gt v5, v2, :cond_b7

    add-int/lit8 v3, v3, 0x1

    goto :goto_98

    :cond_b7
    new-instance v0, Ljava/io/IOException;

    const-string v1, "invalid TSF1 variant range"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_bf
    const/4 v3, 0x1

    sub-int/2addr v1, v3

    aget v3, v11, v1

    aget v1, v12, v1

    add-int/2addr v3, v1

    if-ne v3, v2, :cond_120

    const/4 v1, 0x0

    :goto_c9
    if-ge v1, v2, :cond_10a

    invoke-virtual/range {p0 .. p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result v3

    invoke-static/range {p0 .. p0}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->readU16LE(Ljava/io/DataInputStream;)I

    move-result v4

    const/4 v5, 0x1

    if-lt v3, v5, :cond_102

    const/4 v5, 0x5

    if-gt v3, v5, :cond_102

    mul-int/lit8 v6, v3, 0x3

    ushr-int v6, v4, v6

    if-nez v6, :cond_102

    const/4 v6, 0x0

    :goto_e0
    if-ge v6, v3, :cond_f8

    mul-int/lit8 v7, v6, 0x3

    ushr-int v7, v4, v7

    and-int/lit8 v7, v7, 0x7

    const/4 v8, 0x1

    if-lt v7, v8, :cond_f0

    if-gt v7, v5, :cond_f0

    add-int/lit8 v6, v6, 0x1

    goto :goto_e0

    :cond_f0
    new-instance v0, Ljava/io/IOException;

    const-string v1, "invalid TSF1 stroke value"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_f8
    const/4 v8, 0x1

    int-to-byte v3, v3

    aput-byte v3, v13, v1

    int-to-short v3, v4

    aput-short v3, v14, v1

    add-int/lit8 v1, v1, 0x1

    goto :goto_c9

    :cond_102
    new-instance v0, Ljava/io/IOException;

    const-string v1, "invalid TSF1 packed variant"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_10a
    invoke-virtual/range {p0 .. p0}, Ljava/io/DataInputStream;->read()I

    move-result v0

    const/4 v1, -0x1

    if-ne v0, v1, :cond_118

    new-instance v0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;

    move-object v9, v0

    invoke-direct/range {v9 .. v14}, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;-><init>([I[I[I[B[S)V

    return-object v0

    :cond_118
    new-instance v0, Ljava/io/IOException;

    const-string v1, "trailing TSF1 data"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_120
    new-instance v0, Ljava/io/IOException;

    const-string v1, "incomplete TSF1 variant section"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_128
    new-instance v0, Ljava/io/IOException;

    const-string v1, "invalid TSF1 counts"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_130
    new-instance v0, Ljava/io/IOException;

    const-string v1, "unsupported TSF1 header"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_138
    new-instance v0, Ljava/io/IOException;

    const-string v1, "invalid TSF1 magic"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    goto :goto_141

    :goto_140
    throw v0

    :goto_141
    goto :goto_140
.end method

.method private static readU16LE(Ljava/io/DataInputStream;)I
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result v0

    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result p0

    shl-int/lit8 p0, p0, 0x8

    or-int/2addr p0, v0

    return p0
.end method

.method private static readU32LE(Ljava/io/DataInputStream;)J
    .locals 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result v0

    int-to-long v0, v0

    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result v2

    int-to-long v2, v2

    const/16 v4, 0x8

    shl-long/2addr v2, v4

    or-long/2addr v0, v2

    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result v2

    int-to-long v2, v2

    const/16 v4, 0x10

    shl-long/2addr v2, v4

    or-long/2addr v0, v2

    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUnsignedByte()I

    move-result p0

    int-to-long v2, p0

    const/16 p0, 0x18

    shl-long/2addr v2, p0

    or-long/2addr v0, v2

    return-wide v0
.end method


# virtual methods
.method public matches(ILjava/lang/String;)Z
    .locals 7

    const/4 v0, 0x0

    if-eqz p2, :cond_68

    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    if-eqz v1, :cond_68

    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    const/4 v2, 0x5

    if-le v1, v2, :cond_11

    goto :goto_68

    :cond_11
    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->codePoints:[I

    invoke-static {v1, p1}, Ljava/util/Arrays;->binarySearch([II)I

    move-result p1

    if-gez p1, :cond_1a

    return v0

    :cond_1a
    nop

    const/4 v1, 0x0

    const/4 v3, 0x0

    :goto_1d
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v4

    const/4 v5, 0x1

    if-ge v1, v4, :cond_37

    invoke-virtual {p2, v1}, Ljava/lang/String;->charAt(I)C

    move-result v4

    add-int/lit8 v4, v4, -0x30

    if-lt v4, v5, :cond_36

    if-le v4, v2, :cond_2f

    goto :goto_36

    :cond_2f
    mul-int/lit8 v5, v1, 0x3

    shl-int/2addr v4, v5

    or-int/2addr v3, v4

    add-int/lit8 v1, v1, 0x1

    goto :goto_1d

    :cond_36
    :goto_36
    return v0

    :cond_37
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    mul-int/lit8 v1, v1, 0x3

    shl-int v1, v5, v1

    sub-int/2addr v1, v5

    iget-object v2, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->variantOffsets:[I

    aget v2, v2, p1

    iget-object v4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->variantCounts:[I

    aget p1, v4, p1

    add-int/2addr p1, v2

    nop

    :goto_4a
    if-ge v2, p1, :cond_67

    iget-object v4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->variantLengths:[B

    aget-byte v4, v4, v2

    and-int/lit16 v4, v4, 0xff

    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v6

    if-lt v4, v6, :cond_64

    iget-object v4, p0, Lcom/google/android/apps/inputmethod/libs/hmm/StrokeFilterData;->packedStrokes:[S

    aget-short v4, v4, v2

    const v6, 0xffff

    and-int/2addr v4, v6

    and-int/2addr v4, v1

    if-ne v4, v3, :cond_64

    return v5

    :cond_64
    add-int/lit8 v2, v2, 0x1

    goto :goto_4a

    :cond_67
    return v0

    :cond_68
    :goto_68
    return v0
.end method
