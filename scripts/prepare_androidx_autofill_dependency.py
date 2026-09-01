#!/usr/bin/env python3
"""Fetch and verify the pinned AndroidX Autofill compile-time dependency."""

from __future__ import annotations

import argparse
import hashlib
import tempfile
import urllib.request
from pathlib import Path
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
VERSION = "1.3.0"
AAR_URL = (
    "https://dl.google.com/dl/android/maven2/androidx/autofill/autofill/"
    f"{VERSION}/autofill-{VERSION}.aar"
)
AAR_SHA256 = "b5a217cee7724ea42a382965a9b22a330b988d62cb97abe1b1af50e54370c322"
DEFAULT_OUTPUT = ROOT / "work/inline-autofill-synthetic-provider/libs/classes.jar"


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--aar",
        type=Path,
        help="use an already downloaded autofill AAR instead of Google Maven",
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    temporary: tempfile.TemporaryDirectory[str] | None = None
    if args.aar is None:
        temporary = tempfile.TemporaryDirectory(prefix="androidx-autofill-")
        aar = Path(temporary.name) / f"autofill-{VERSION}.aar"
        print(f"Downloading {AAR_URL}")
        urllib.request.urlretrieve(AAR_URL, aar)
    else:
        aar = args.aar.resolve()
        if not aar.is_file():
            raise FileNotFoundError(aar)

    try:
        actual = digest(aar)
        if actual != AAR_SHA256:
            raise RuntimeError(
                f"AndroidX Autofill AAR SHA-256 mismatch: expected {AAR_SHA256}, got {actual}"
            )
        with ZipFile(aar) as archive:
            classes = archive.read("classes.jar")
        output = args.output.resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(classes)
        print(
            f"Prepared AndroidX Autofill {VERSION} classes: {output} "
            f"(SHA-256 {hashlib.sha256(classes).hexdigest()})"
        )
        return 0
    finally:
        if temporary is not None:
            temporary.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
