#!/usr/bin/env python3
"""
summarize_categories.py

Usage:
    python summarize_categories.py path/to/quiz.csv
"""

import csv
import sys
from collections import Counter
from pathlib import Path


def summarize(path: str) -> None:
    category_counts = Counter()
    uncategorized = 0
    uncategorized_rows: list[tuple[int, list[str]]] = []
    invalid_rows: list[tuple[int, list[str]]] = []

    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")
        for line_no, row in enumerate(reader, start=1):
            if not row or all(cell.strip() == "" for cell in row):
                continue

            if len(row) == 2:
                uncategorized += 1
                uncategorized_rows.append((line_no, row))
            elif len(row) == 3:
                category = row[2].strip()
                if category:
                    category_counts[category] += 1
                else:
                    uncategorized += 1
                    uncategorized_rows.append((line_no, row))
            else:
                invalid_rows.append((line_no, row))

    # ---------- Report ----------
    if invalid_rows:
        print("⚠️  Invalid rows (more than 3 fields):")
        for line_no, row in invalid_rows:
            print(f"  line {line_no}: {';'.join(row)}")
        print("-" * 60)

    if uncategorized_rows:
        print("❓ Uncategorized rows:")
        for line_no, row in uncategorized_rows:
            print(f"  line {line_no}: {';'.join(row)}")
        print("-" * 60)

    print("Category → # questions")
    for category, count in sorted(
            category_counts.items(),
            key=lambda x: (-x[1], x[0].casefold())):
        print(f"{category}: {count}")

    print(f"Uncategorized: {uncategorized}")
    total_valid = sum(category_counts.values()) + uncategorized
    print(f"Total valid questions: {total_valid}")
    print(f"Total invalid rows: {len(invalid_rows)}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        script = Path(sys.argv[0]).name
        print(f"Usage: python {script} path/to/quiz.csv")
        sys.exit(1)

    summarize(sys.argv[1])
