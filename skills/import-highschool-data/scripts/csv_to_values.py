#!/usr/bin/env python3
"""Convert normalized CSV rows into a SQL VALUES block."""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path


def sql_literal(value: str) -> str:
    text = value.strip()
    if text == "":
        return "NULL"
    if re.fullmatch(r"0\d+", text):
        return "'" + text.replace("'", "''") + "'"
    if re.fullmatch(r"-?\d+", text):
        return text
    if re.fullmatch(r"-?\d+\.\d+", text):
        return text
    if text.lower() in {"true", "false"}:
        return text.lower()
    return "'" + text.replace("'", "''") + "'"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_path", type=Path)
    parser.add_argument("--columns", required=True, help="comma-separated CTE column names")
    parser.add_argument("--cte", default="src")
    parser.add_argument("--skip-header", action="store_true")
    args = parser.parse_args()

    rows: list[list[str]] = []
    with args.csv_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.reader(handle)
        for index, row in enumerate(reader):
            if index == 0 and args.skip_header:
                continue
            rows.append(row)

    columns = [col.strip() for col in args.columns.split(",") if col.strip()]
    print(f"WITH {args.cte}({', '.join(columns)}) AS (")
    print("VALUES")
    for index, row in enumerate(rows):
        suffix = "," if index < len(rows) - 1 else ""
        print("  (" + ", ".join(sql_literal(cell) for cell in row) + ")" + suffix)
    print(")")
    print(f"-- rows={len(rows)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
