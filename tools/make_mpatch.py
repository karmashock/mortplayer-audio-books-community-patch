#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""make_mpatch.py - turn "original file" + "your edited file" into an .mpatch section.

For contributors. Usage:
    python3 make_mpatch.py ORIGINAL EDITED --project app --file smali/de/.../Foo.smali >> patches/07-my-fix.mpatch

The output contains ONLY your new lines plus line numbers and a checksum of the
original file - never the lines you removed and never surrounding context - so
the patch can be shared without copying anyone else's code. Read the result
before sharing anyway: lines you merely *changed* still appear in their new form.
"""
import argparse, difflib, hashlib


def read_lines(path):
    # Same normalisation as MortPatch.java: UTF-8, CRLF -> LF.
    text = open(path, encoding="utf-8", newline="").read().replace("\r\n", "\n")
    return text, text.split("\n")[:-1] if text.endswith("\n") else text.split("\n")


def opcodes(a, b):
    """Changed regions (i1, i2, j1, j2), 0-based, with gaps of blank-only lines merged.

    Merging over blank lines costs nothing (no foreign content) and gives fewer, more readable hunks.
    """
    ops = [o for o in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes() if o[0] != "equal"]
    merged = []
    for _, i1, i2, j1, j2 in ops:
        if merged:
            pi1, pi2, pj1, pj2 = merged[-1]
            if all(not l.strip() for l in a[pi2:i1]) and (i1 - pi2) == (j1 - pj2):
                merged[-1] = (pi1, i2, pj1, j2)
                continue
        merged.append((i1, i2, j1, j2))
    return merged


def hunk_text(i1, i2, body, comments=()):
    """Render one hunk. i1/i2 are 0-based [i1, i2) indexes into the original."""
    out = []
    if i2 > i1:
        out.append(f"replace {i1 + 1}-{i2}" if i2 - i1 > 1 else f"replace {i1 + 1}")
    else:
        out.append(f"insert-after {i1}")
    out += ["+" + c for c in comments]
    out += ["+" + l for l in body]
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("original"); ap.add_argument("edited")
    ap.add_argument("--project", default="app", help="app (apktool d -r tree) or manifest (full decode)")
    ap.add_argument("--file", required=True, help="path of the file inside the project folder")
    args = ap.parse_args()
    text, a = read_lines(args.original)
    _, b = read_lines(args.edited)
    print(f"project: {args.project}")
    print(f"file: {args.file}")
    print(f"sha256: {hashlib.sha256(text.encode('utf-8')).hexdigest()}")
    for i1, i2, j1, j2 in opcodes(a, b):
        print("\n".join(hunk_text(i1, i2, b[j1:j2])))


if __name__ == "__main__":
    main()
