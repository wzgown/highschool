#!/usr/bin/env python3
"""
makeitdown wrapper for converting documents to markdown

Usage:
    python convert_to_markdown.py <input_file> [output_file]

Example:
    python convert_to_markdown.py raw/2025/source.pdf
    python convert_to_markdown.py raw/2025/source.pdf raw/2025/source.md
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path


def check_makeitdown():
    """Check if makeitdown is installed"""
    try:
        result = subprocess.run(
            ["makeitdown", "--help"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False


def convert_file(input_file, output_file=None):
    """
    Convert a document to markdown using makeitdown

    Args:
        input_file: Path to input file (PDF, Excel, etc.)
        output_file: Optional output path. If None, uses input_file.md
    """
    input_path = Path(input_file).resolve()

    if not input_path.exists():
        print(f"Error: Input file not found: {input_file}", file=sys.stderr)
        sys.exit(1)

    # Default output: input file with .md extension
    if output_file is None:
        output_path = input_path.with_suffix('.md')
    else:
        output_path = Path(output_file).resolve()

    # Create output directory if needed
    output_path.parent.mkdir(parents=True, exist_ok=True)

    print(f"Converting: {input_path}")
    print(f"Output: {output_path}")

    # Run makeitdown
    result = subprocess.run(
        ["makeitdown", str(input_path)],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"Error running makeitdown:", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)

    # Write output
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(result.stdout)

    print(f"✓ Converted successfully")

    # Report stats
    lines = result.stdout.count('\n')
    chars = len(result.stdout)
    print(f"  Lines: {lines}")
    print(f"  Characters: {chars}")


def convert_directory(input_dir, output_dir=None, pattern="*.pdf"):
    """
    Convert all matching files in a directory

    Args:
        input_dir: Directory containing source files
        output_dir: Optional output directory
        pattern: Glob pattern for files to convert (default: *.pdf)
    """
    input_path = Path(input_dir).resolve()

    if not input_path.is_dir():
        print(f"Error: Not a directory: {input_dir}", file=sys.stderr)
        sys.exit(1)

    if output_dir is None:
        output_path = input_path
    else:
        output_path = Path(output_dir).resolve()
        output_path.mkdir(parents=True, exist_ok=True)

    files = list(input_path.glob(pattern))
    if not files:
        print(f"No files matching '{pattern}' found in {input_dir}")
        return

    print(f"Found {len(files)} file(s) to convert")
    print("=" * 50)

    for i, file in enumerate(files, 1):
        print(f"\n[{i}/{len(files)}] {file.name}")
        out_file = output_path / file.with_suffix('.md').name
        convert_file(file, out_file)

    print("\n" + "=" * 50)
    print(f"✓ Converted {len(files)} file(s)")


def main():
    parser = argparse.ArgumentParser(
        description="Convert documents to markdown using makeitdown"
    )
    parser.add_argument(
        "input",
        help="Input file or directory"
    )
    parser.add_argument(
        "output",
        nargs="?",
        help="Output file or directory (optional)"
    )
    parser.add_argument(
        "-d", "--directory",
        action="store_true",
        help="Process all files in directory"
    )
    parser.add_argument(
        "-p", "--pattern",
        default="*.pdf",
        help="File pattern for directory mode (default: *.pdf)"
    )

    args = parser.parse_args()

    # Check makeitdown installation
    if not check_makeitdown():
        print("Error: makeitdown not found", file=sys.stderr)
        print("Install with: go install github.com/e-nikolov/makeitdown@latest", file=sys.stderr)
        sys.exit(1)

    if args.directory:
        convert_directory(args.input, args.output, args.pattern)
    else:
        convert_file(args.input, args.output)


if __name__ == "__main__":
    main()
