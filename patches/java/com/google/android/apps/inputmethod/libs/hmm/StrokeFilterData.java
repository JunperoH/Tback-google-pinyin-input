package com.google.android.apps.inputmethod.libs.hmm;

import android.content.Context;
import android.content.res.Resources;
import android.util.Log;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;

/** Immutable, lazily loaded Conway five-stroke prefix index. */
public final class StrokeFilterData {
    private static final String TAG = "TPlusStrokeFilter";
    private static final byte[] MAGIC = { 'T', 'S', 'F', '1' };
    private static final int FORMAT_VERSION = 1;
    private static final byte[] SOURCE_SHA256 = {
            0x2d, (byte) 0xa4, 0x08, (byte) 0xc8, (byte) 0x98, 0x26, 0x13, 0x02,
            0x0b, (byte) 0xda, 0x7a, (byte) 0xd1, 0x6b, 0x76, (byte) 0xa3, (byte) 0xb2,
            (byte) 0x8e, (byte) 0x93, (byte) 0x84, 0x3a, (byte) 0xfc, (byte) 0xd2, 0x07, (byte) 0xe8,
            (byte) 0xbb, 0x2c, (byte) 0x9c, 0x74, 0x37, 0x27, (byte) 0xf1, 0x23
    };

    private static StrokeFilterData instance;
    private static boolean loadAttempted;
    private static boolean failureLogged;

    private final int[] codePoints;
    private final int[] variantOffsets;
    private final int[] variantCounts;
    private final byte[] variantLengths;
    private final short[] packedStrokes;

    private StrokeFilterData(
            int[] codePoints,
            int[] variantOffsets,
            int[] variantCounts,
            byte[] variantLengths,
            short[] packedStrokes) {
        this.codePoints = codePoints;
        this.variantOffsets = variantOffsets;
        this.variantCounts = variantCounts;
        this.variantLengths = variantLengths;
        this.packedStrokes = packedStrokes;
    }

    public static synchronized StrokeFilterData get(Context context) {
        if (!loadAttempted) {
            loadAttempted = true;
            try {
                instance = load(context.getApplicationContext());
            } catch (Throwable error) {
                if (!failureLogged) {
                    failureLogged = true;
                    Log.w(TAG, "Stroke data unavailable; filtering disabled", error);
                }
            }
        }
        return instance;
    }

    private static StrokeFilterData load(Context context) throws IOException {
        Resources resources = context.getResources();
        int id = resources.getIdentifier("stroke_filter_data", "raw", context.getPackageName());
        if (id == 0) {
            throw new IOException("stroke_filter_data resource not found");
        }
        InputStream raw = resources.openRawResource(id);
        try {
            return read(new DataInputStream(raw));
        } finally {
            raw.close();
        }
    }

    static StrokeFilterData read(DataInputStream input) throws IOException {
        byte[] magic = new byte[4];
        input.readFully(magic);
        if (!Arrays.equals(magic, MAGIC)) {
            throw new IOException("invalid TSF1 magic");
        }
        int version = readU16LE(input);
        int flags = readU16LE(input);
        long codePointCountLong = readU32LE(input);
        long variantCountLong = readU32LE(input);
        byte[] digest = new byte[32];
        input.readFully(digest);
        if (version != FORMAT_VERSION || flags != 0 || !Arrays.equals(digest, SOURCE_SHA256)) {
            throw new IOException("unsupported TSF1 header");
        }
        if (codePointCountLong <= 0 || codePointCountLong > 100000
                || variantCountLong < codePointCountLong || variantCountLong > 500000) {
            throw new IOException("invalid TSF1 counts");
        }
        int codePointCount = (int) codePointCountLong;
        int variantCount = (int) variantCountLong;
        int[] codePoints = new int[codePointCount];
        int[] offsets = new int[codePointCount];
        int[] counts = new int[codePointCount];
        byte[] lengths = new byte[variantCount];
        short[] packed = new short[variantCount];

        int previous = -1;
        for (int i = 0; i < codePointCount; i++) {
            long value = readU32LE(input);
            if (value > Character.MAX_CODE_POINT || value <= previous) {
                throw new IOException("unsorted TSF1 code points");
            }
            codePoints[i] = (int) value;
            previous = (int) value;
        }
        for (int i = 0; i < codePointCount; i++) {
            long value = readU32LE(input);
            if (value > variantCount) {
                throw new IOException("TSF1 variant offset out of range");
            }
            offsets[i] = (int) value;
        }
        for (int i = 0; i < codePointCount; i++) {
            counts[i] = readU16LE(input);
            int expectedOffset = i == 0 ? 0 : offsets[i - 1] + counts[i - 1];
            if (counts[i] == 0 || offsets[i] != expectedOffset
                    || offsets[i] + counts[i] > variantCount) {
                throw new IOException("invalid TSF1 variant range");
            }
        }
        if (offsets[codePointCount - 1] + counts[codePointCount - 1] != variantCount) {
            throw new IOException("incomplete TSF1 variant section");
        }
        for (int i = 0; i < variantCount; i++) {
            int length = input.readUnsignedByte();
            int value = readU16LE(input);
            if (length < 1 || length > 5 || (value >>> (length * 3)) != 0) {
                throw new IOException("invalid TSF1 packed variant");
            }
            for (int stroke = 0; stroke < length; stroke++) {
                int digit = (value >>> (stroke * 3)) & 7;
                if (digit < 1 || digit > 5) {
                    throw new IOException("invalid TSF1 stroke value");
                }
            }
            lengths[i] = (byte) length;
            packed[i] = (short) value;
        }
        if (input.read() != -1) {
            throw new IOException("trailing TSF1 data");
        }
        return new StrokeFilterData(codePoints, offsets, counts, lengths, packed);
    }

    private static int readU16LE(DataInputStream input) throws IOException {
        return input.readUnsignedByte() | (input.readUnsignedByte() << 8);
    }

    private static long readU32LE(DataInputStream input) throws IOException {
        return ((long) input.readUnsignedByte())
                | ((long) input.readUnsignedByte() << 8)
                | ((long) input.readUnsignedByte() << 16)
                | ((long) input.readUnsignedByte() << 24);
    }

    public boolean matches(int codePoint, String prefix) {
        if (prefix == null || prefix.length() == 0 || prefix.length() > 5) {
            return false;
        }
        int index = Arrays.binarySearch(codePoints, codePoint);
        if (index < 0) {
            return false;
        }
        int prefixPacked = 0;
        for (int i = 0; i < prefix.length(); i++) {
            int stroke = prefix.charAt(i) - '0';
            if (stroke < 1 || stroke > 5) {
                return false;
            }
            prefixPacked |= stroke << (i * 3);
        }
        int mask = (1 << (prefix.length() * 3)) - 1;
        int end = variantOffsets[index] + variantCounts[index];
        for (int i = variantOffsets[index]; i < end; i++) {
            if ((variantLengths[i] & 0xff) >= prefix.length()
                    && ((packedStrokes[i] & 0xffff) & mask) == prefixPacked) {
                return true;
            }
        }
        return false;
    }
}
