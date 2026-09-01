#!/usr/bin/env python3
"""Compile pinned Conway Stroke Data into the compact T+ prefix index."""

from __future__ import annotations

import argparse
import hashlib
import itertools
import re
import struct
import tempfile
from collections.abc import Iterable
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "third_party/conway-stroke-data/codepoint-character-sequence.txt"
DEFAULT_OUTPUT = ROOT / "patches/res/raw/stroke_filter_data.bin"
SOURCE_COMMIT = "a657f5b7554ace8d97a4d9a87aca391b24363458"
SOURCE_SHA256 = "2da408c8982613020bda7ad16b76a3b28e93843afcd207e8bb2c9c743727f123"

MAGIC = b"TSF1"
FORMAT_VERSION = 1
FLAGS = 0
MAX_STROKES = 5
HEADER = struct.Struct("<4sHHII32s")
VARIANT = struct.Struct("<BH")

CAPTURE_GROUP = re.compile(r"\(([1-5|]*)\)")
BACK_REFERENCE = re.compile(r"\\([1-9])")
DATA_LINE = re.compile(
    r"U\+(?P<codepoint>[0-9A-F]{4,5})!?\t"
    r"(?P<character>\S)(?:[\^*])?\t"
    r"(?P<sequence>[1-5|()\\]+)\Z"
)


def source_digest(path: Path = SOURCE) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_pinned_source(path: Path = SOURCE) -> bytes:
    data = path.read_bytes()
    actual = hashlib.sha256(data).hexdigest()
    if actual != SOURCE_SHA256:
        raise ValueError(
            f"Conway source SHA-256 mismatch: expected {SOURCE_SHA256}, got {actual}"
        )
    return data


def to_sequence_set(sequence_regex: str) -> set[str]:
    """Expand Conway capture groups and back references like upstream generate.py."""
    alternatives: list[tuple[str, ...]] = []

    def store_group(match: re.Match[str]) -> str:
        # Sorting makes the generated binary independent from Python hash order.
        choices = tuple(sorted(set(match.group(1).split("|"))))
        alternatives.append(choices)
        return f"\\{len(alternatives)}"

    template = CAPTURE_GROUP.sub(store_group, sequence_regex)
    if "(" in template or ")" in template:
        raise ValueError(f"Unsupported nested or malformed group: {sequence_regex}")

    results: set[str] = set()
    for combination in itertools.product(*alternatives):
        def resolve(match: re.Match[str]) -> str:
            index = int(match.group(1)) - 1
            if index >= len(combination):
                raise ValueError(f"Unknown back reference in {sequence_regex}")
            return combination[index]

        realised = BACK_REFERENCE.sub(resolve, template)
        if not realised or not re.fullmatch(r"[1-5]+", realised):
            raise ValueError(f"Invalid realised stroke sequence: {sequence_regex!r}")
        results.add(realised)
    return results


def parse_source(data: bytes) -> dict[int, tuple[str, ...]]:
    records: dict[int, tuple[str, ...]] = {}
    for raw_line in data.decode("utf-8").splitlines():
        match = DATA_LINE.fullmatch(raw_line)
        if match is None:
            continue
        codepoint = int(match.group("codepoint"), 16)
        if ord(match.group("character")) != codepoint:
            raise ValueError(f"Character/code point mismatch at U+{codepoint:04X}")
        if codepoint in records:
            raise ValueError(f"Duplicate code point U+{codepoint:04X}")
        prefixes = {
            sequence[:MAX_STROKES]
            for sequence in to_sequence_set(match.group("sequence"))
        }
        records[codepoint] = tuple(sorted(prefixes))
    if not records:
        raise ValueError("No Conway stroke records parsed")
    return records


def pack_variant(strokes: str) -> tuple[int, int]:
    if not 1 <= len(strokes) <= MAX_STROKES or not re.fullmatch(r"[1-5]+", strokes):
        raise ValueError(f"Invalid packed stroke prefix: {strokes!r}")
    packed = 0
    for index, stroke in enumerate(strokes):
        packed |= int(stroke) << (index * 3)
    return len(strokes), packed


def build_binary(records: dict[int, tuple[str, ...]]) -> bytes:
    codepoints = sorted(records)
    offsets: list[int] = []
    counts: list[int] = []
    variants: list[tuple[int, int]] = []
    for codepoint in codepoints:
        codepoint_variants = records[codepoint]
        if not codepoint_variants or len(codepoint_variants) > 0xFFFF:
            raise ValueError(f"Invalid variant count for U+{codepoint:04X}")
        offsets.append(len(variants))
        counts.append(len(codepoint_variants))
        variants.extend(pack_variant(strokes) for strokes in codepoint_variants)

    output = bytearray(
        HEADER.pack(
            MAGIC,
            FORMAT_VERSION,
            FLAGS,
            len(codepoints),
            len(variants),
            bytes.fromhex(SOURCE_SHA256),
        )
    )
    output.extend(struct.pack(f"<{len(codepoints)}I", *codepoints))
    output.extend(struct.pack(f"<{len(offsets)}I", *offsets))
    output.extend(struct.pack(f"<{len(counts)}H", *counts))
    for length, packed in variants:
        output.extend(VARIANT.pack(length, packed))
    return bytes(output)


def generate(source: Path = SOURCE) -> tuple[bytes, dict[str, int]]:
    records = parse_source(require_pinned_source(source))
    data = build_binary(records)
    variant_count = sum(len(value) for value in records.values())
    return data, {
        "codepoints": len(records),
        "variants": variant_count,
        "max_variants": max(len(value) for value in records.values()),
        "bytes": len(data),
    }


def print_report(report: dict[str, int]) -> None:
    print(
        "Generated TSF1: "
        f"{report['codepoints']} code points, {report['variants']} variants, "
        f"max {report['max_variants']} variants/code point, {report['bytes']} bytes"
    )
    print(f"Source commit: {SOURCE_COMMIT}")
    print(f"Source SHA-256: {SOURCE_SHA256}")


def write_output(data: bytes, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(data)


def main(argv: Iterable[str] | None = None) -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)

    data, report = generate(args.source)
    print_report(report)
    output = args.output.resolve()
    if args.check:
        if not output.is_file():
            raise SystemExit(f"Missing generated asset: {output}")
        with tempfile.TemporaryDirectory(prefix="stroke-filter-") as temp_dir:
            temporary = Path(temp_dir) / output.name
            write_output(data, temporary)
            if temporary.read_bytes() != output.read_bytes():
                raise SystemExit(f"Generated asset is stale: {output}")
        print(f"Generated asset is reproducible: {output}")
    else:
        write_output(data, output)
        print(f"Wrote {output}")


if __name__ == "__main__":
    main()
