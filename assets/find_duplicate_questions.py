#!/usr/bin/env python3
"""
find_duplicate_questions.py

Detect duplicate questions in a "question";"answer" CSV and
(optionally) create a de-duplicated file.

Examples
--------
# Just list duplicates
python find_duplicate_questions.py questions.csv

# List duplicates and write a new file without them
python find_duplicate_questions.py questions.csv --remove
# or with a custom output path
python find_duplicate_questions.py questions.csv -r -o cleaned.csv
"""

import argparse
import csv
import sys
from collections import Counter
from pathlib import Path

DELIMITER = ";"
QUOTECHAR = '"'
ENCODING = "utf-8"


def find_duplicates(csv_path: Path) -> Counter:
    """Return a Counter of questions → frequency (only duplicates kept)."""
    counts: Counter[str] = Counter()

    with csv_path.open(newline="", encoding=ENCODING) as f:
        reader = csv.reader(f, delimiter=DELIMITER, quotechar=QUOTECHAR)
        for row in reader:
            if not row:
                continue
            question = row[0].strip()
            counts[question] += 1

    # Filter to those seen more than once
    return Counter({q: c for q, c in counts.items() if c > 1})


def remove_duplicates(csv_path: Path, output_path: Path) -> int:
    """
    Write a de-duplicated version of csv_path to output_path.
    Returns the number of duplicates removed.
    """
    seen: set[str] = set()
    duplicates_removed = 0

    with csv_path.open(newline="", encoding=ENCODING) as src, \
         output_path.open("w", newline="", encoding=ENCODING) as dst:

        reader = csv.reader(src, delimiter=DELIMITER, quotechar=QUOTECHAR)
        writer = csv.writer(dst, delimiter=DELIMITER, quotechar=QUOTECHAR)

        for row in reader:
            if not row:
                continue
            question = row[0].strip()
            if question in seen:
                duplicates_removed += 1
                continue            # skip duplicate record
            seen.add(question)
            writer.writerow(row)

    return duplicates_removed


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Find (and optionally remove) duplicate questions.")
    parser.add_argument("csv_file", help="Path to the input CSV file")
    parser.add_argument("-r", "--remove", action="store_true",
                        help="Remove duplicates and write a de-duplicated file")
    parser.add_argument("-o", "--output", metavar="FILE",
                        help="Output path (default: <input>_dedup.csv) – only when --remove is used")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    csv_path = Path(args.csv_file)

    if not csv_path.is_file():
        sys.exit(f"❌ File not found: {csv_path}")

    # 1. Find duplicates
    duplicates = find_duplicates(csv_path)
    if duplicates:
        print(f"🚩 Found {len(duplicates)} questions that repeat:")
        for q, n in duplicates.most_common():
            print(f"  {n}×  {q}")
    else:
        print("✅ No duplicate questions found.")

    # 2. Optionally remove them
    if args.remove:
        out_path = Path(args.output) if args.output else csv_path.with_stem(csv_path.stem + "_dedup")
        removed = remove_duplicates(csv_path, out_path)
        print(f"\n🗑️  Removed {removed} duplicate rows.")
        print(f"📄 De-duplicated file written to: {out_path.resolve()}")


if __name__ == "__main__":
    main()
