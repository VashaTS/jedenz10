#!/usr/bin/env python3
"""Convert Jeden‑z‑Dziesięciu question CSV.

Reads a CSV in the original format:
    question,answer
where some questions themselves may contain extra commas,
and writes a new file in the safer format:
    "question";"answer"

The split is always performed on the *last* comma in each line.
Lines without any comma are skipped (warning is printed to stderr).
"""

import sys
import pathlib


def convert(in_path: str | pathlib.Path = "pytania1z10.csv",
            out_path: str | pathlib.Path = "pytania_clean.csv") -> None:
    in_path = pathlib.Path(in_path)
    out_path = pathlib.Path(out_path)

    if not in_path.exists():
        sys.exit(f"Input file '{in_path}' not found.")

    skipped = 0
    written = 0
    with in_path.open(encoding="utf-8") as infile,             out_path.open("w", encoding="utf-8", newline="") as outfile:
        for lineno, line in enumerate(infile, 1):
            line = line.rstrip("\r\n")
            if not line.strip():
                continue  # ignore blank lines
            idx = line.rfind(",")
            if idx == -1:
                print(f"[WARN] Line {lineno}: no comma found – skipped", file=sys.stderr)
                skipped += 1
                continue
            question = line[:idx].strip()
            answer = line[idx + 1 :].strip()
            outfile.write(f'"{question}";"{answer}"\n')
            written += 1

    print(f"Written {written} lines to {out_path}")
    if skipped:
        print(f"Skipped {skipped} malformed lines (see warnings above)", file=sys.stderr)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Fix Jeden‑z‑Dziesięciu CSV file.")
    parser.add_argument("input", nargs="?", default="pytania1z10.csv", help="source CSV file")
    parser.add_argument("output", nargs="?", default="pytania_clean.csv", help="destination file")
    args = parser.parse_args()

    convert(args.input, args.output)
