#!/usr/bin/env python3
"""
add_quotes_qna.py

Re-add surrounding quotes to a semicolon-separated Q&A file
that currently looks like:
    question;answer

and convert it to:
    "question";"answer"

Assumptions
-----------
* Exactly one semicolon (;) separates the question from the answer.
  (If your answers contain additional semicolons, switch to rpartition.)
* Blank lines are skipped.
"""

import argparse
import csv
import sys
from pathlib import Path

ENCODING      = "utf-8"
IN_DELIMITER  = ";"         # current separator
OUT_DELIMITER = ";"         # desired separator (unchanged)
OUT_QUOTECHAR = '"'         # add these

def re_quote(src: Path, dst: Path) -> int:
    """
    Read src, write dst with added quotes.
    Returns the number of lines written.
    """
    written = 0

    with src.open(encoding=ENCODING) as fin, \
         dst.open("w", newline="", encoding=ENCODING) as fout:

        writer = csv.writer(fout,
                            delimiter=OUT_DELIMITER,
                            quotechar=OUT_QUOTECHAR,
                            quoting=csv.QUOTE_ALL)

        for lineno, raw in enumerate(fin, 1):
            line = raw.rstrip("\n")
            if not line.strip():
                continue         # skip blank lines

            if IN_DELIMITER not in line:
                print(f"⚠️  Line {lineno}: no semicolon → skipped", file=sys.stderr)
                continue

            # split on the FIRST semicolon; change to rpartition for last
            question, _, answer = line.partition(IN_DELIMITER)
            writer.writerow([question.strip(), answer.strip()])
            written += 1

    return written


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Add quotes around Q&A fields.")
    p.add_argument("input", help="Path to the semicolon Q&A file")
    p.add_argument("-o", "--output", metavar="FILE",
                   help="Output path (default: <input>_quoted.csv)")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    src = Path(args.input)

    if not src.is_file():
        sys.exit(f"❌ File not found: {src}")

    dst = Path(args.output) if args.output else src.with_stem(src.stem + "_quoted")

    rows = re_quote(src, dst)
    print(f"✅ Wrote {rows} lines to {dst.resolve()}")


if __name__ == "__main__":
    main()
