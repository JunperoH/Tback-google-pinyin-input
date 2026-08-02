#!/usr/bin/env python3
"""Verify that two patched apktool trees are byte-for-byte identical."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


def snapshot(root: Path) -> dict[str, str]:
    if not root.is_dir():
        raise SystemExit(f"Not a directory: {root}")
    result: dict[str, str] = {}
    for path in sorted(item for item in root.rglob("*") if item.is_file()):
        relative = path.relative_to(root).as_posix()
        if relative == "build" or relative.startswith("build/"):
            continue
        result[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("first", type=Path)
    parser.add_argument("second", type=Path)
    args = parser.parse_args()
    first = snapshot(args.first.resolve())
    second = snapshot(args.second.resolve())
    missing = sorted(first.keys() - second.keys())
    extra = sorted(second.keys() - first.keys())
    changed = sorted(name for name in first.keys() & second.keys() if first[name] != second[name])
    if missing or extra or changed:
        details = []
        if missing:
            details.append(f"missing from second: {missing[:10]}")
        if extra:
            details.append(f"extra in second: {extra[:10]}")
        if changed:
            details.append(f"different bytes: {changed[:10]}")
        raise SystemExit("Patched trees are not reproducible; " + "; ".join(details))
    print(f"Reproducible patch verification passed ({len(first)} files)")


if __name__ == "__main__":
    main()
