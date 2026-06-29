#!/usr/bin/env python3
"""Best-effort PDF table probe for inspection, not authoritative import."""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path

try:
    import pdfplumber
except ImportError as exc:
    raise SystemExit("pdfplumber is required: python3 -m pip install pdfplumber") from exc

DEFAULT_WATERMARK_TOKENS = {"上", "海", "市", "教", "育", "考", "试", "院"}


def clean_cell(value: object, watermark_tokens: set[str]) -> str:
    if value is None:
        return ""
    parts: list[str] = []
    for part in str(value).splitlines():
        text = part.strip()
        if not text or text in watermark_tokens:
            continue
        parts.append(text)
    return "".join(parts).strip()


def extract_rows(pdf_path: Path, first_column_digits: bool, watermark_tokens: set[str]) -> list[list[str]]:
    rows: list[list[str]] = []
    with pdfplumber.open(str(pdf_path)) as pdf:
        for page in pdf.pages:
            for table in page.extract_tables():
                for raw_row in table:
                    row = [clean_cell(cell, watermark_tokens) for cell in raw_row]
                    while row and row[-1] == "":
                        row.pop()
                    if not row or all(cell == "" for cell in row):
                        continue
                    if first_column_digits and not re.fullmatch(r"\d+", row[0] if row else ""):
                        continue
                    rows.append(row)
    return rows


def write_csv(rows: list[list[str]], out_path: Path | None) -> None:
    handle = out_path.open("w", newline="", encoding="utf-8") if out_path else sys.stdout
    try:
        writer = csv.writer(handle)
        writer.writerows(rows)
    finally:
        if out_path:
            handle.close()


def write_json(rows: list[list[str]], out_path: Path | None) -> None:
    text = json.dumps(rows, ensure_ascii=False, indent=2)
    if out_path:
        out_path.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Probe PDF table rows for inspection. Do not use this output as final import "
            "data without a source-specific parser and independent row/total validation."
        )
    )
    parser.add_argument("pdf", type=Path)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--format", choices=("csv", "json"), default="csv")
    parser.add_argument("--first-column-digits", action="store_true", help="drop header rows unless column 1 is numeric")
    parser.add_argument("--watermark-token", action="append", default=[], help="extra single-token watermark text to drop")
    args = parser.parse_args()

    tokens = set(DEFAULT_WATERMARK_TOKENS)
    tokens.update(args.watermark_token)
    rows = extract_rows(args.pdf, args.first_column_digits, tokens)

    if args.format == "csv":
        write_csv(rows, args.out)
    else:
        write_json(rows, args.out)

    print(f"rows={len(rows)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
