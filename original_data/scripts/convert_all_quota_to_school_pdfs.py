#!/usr/bin/env python3
"""
Convert all quota-to-school PDFs to markdown using Docker MarkItDown

This script identifies which PDFs need to be converted and runs Docker MarkItDown
to convert them to markdown for parsing.
"""

import os
import subprocess
from pathlib import Path
import re

# ============================================================================
# Configuration
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(BASE_DIR, "raw", "2025", "quota_district")
MD_DIR = os.path.join(RAW_DIR, "markdown")

# Ensure markdown directory exists
Path(MD_DIR).mkdir(parents=True, exist_ok=True)

# Mapping of PDF files to their target district names
PDF_TO_DISTRICT = {
    # Quota to school PDFs
    "2025_quota_to_school_songjiang.pdf": "松江区",
    "2025_quota_to_school_jingan.pdf": "静安区",
    "2025_quota_to_school_minhang.pdf": "闵行区",
    "2025_huangpu_quota_to_school_plan.pdf": "黄浦区",

    # Quota to district PDFs
    "2025_quota_to_district_chongming.mhtml": "崇明区",
    "2025_quota_to_district_huangpu.pdf": "黄浦区",
    "2025_quota_to_district_jingan.pdf": "静安区",
    "2025_quota_to_district_minhang.pdf": "闵行区",
    "2025_quota_to_district_songjiang.pdf": "松江区",

    # Unknown PDFs - check content first
    "0529_170347_127.pdf": None,
    "0529_170504_316.pdf": None,
    "2a3e81c497204f7898759f0f37014b98.pdf": None,
    "5e4da5a43b8b4460a80dc42418383b75.pdf": None,
    "7a98be7f06bc4dbdbbbaf6287bac3e1e.pdf": None,
    "7fabeb26a4355c4483146c7a7d6da8d8.pdf": None,
    "8b899738ea954dceabee7870c1b2ff2a.pdf": None,
    "96bfeec7871b139e4361531e69646c4c.pdf": None,
    "745db2c8ad1c454bb41911f196a5e32d.pdf": None,
    "1591dc2cfb82434c9221f328571be442.pdf": None,
    "29121912hh2x.pdf": None,
    "291219117syl.pdf": None,
    "_upload_jiaoyu_InfoPublicity_PublicInformation_File_9385bb260de44f96873d5d5d8c3db934.pdf": None,
    "_upload_jiaoyu_InfoPublicity_PublicInformation_File_f15d214aeec94759852f8ad1ec2b7a28.pdf": None,
    "a04d2ef7222c435fa73ecfa345cd6820.pdf": None,
    "cd24c4225546947.pdf": None,
    "dc3196599a65770.pdf": None,
}

# Districts we need quota-to-school data for
ALL_DISTRICTS = [
    '黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区',
    '闵行区', '宝山区', '嘉定区', '浦东新区', '金山区', '松江区', '青浦区',
    '奉贤区', '崇明区'
]

# ============================================================================
# Functions
# ============================================================================

def convert_pdf_to_markdown(pdf_path, md_path):
    """Convert PDF to markdown using Docker MarkItDown"""
    # Check if docker is available
    try:
        result = subprocess.run(
            ["docker", "--version"],
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode != 0:
            print("  ⚠ Docker not available, skipping conversion")
            return False
    except Exception as e:
        print(f"  ⚠ Docker check failed: {e}")
        return False

    # Convert using MarkItDown Docker
    # Output markdown to stdout, redirect to file
    try:
        cmd = [
            "docker", "run", "--rm",
            "-v", f"{os.path.dirname(pdf_path)}:/data",
            "adeuxy/markitdown:latest",
            f"/data/{os.path.basename(pdf_path)}"
        ]

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(result.stdout)
            return True
        else:
            print(f"  ⚠ Conversion failed: {result.stderr}")
            return False

    except Exception as e:
        print(f"  ⚠ Conversion error: {e}")
        return False


def identify_district_from_pdf(pdf_path):
    """Try to identify which district a PDF is for by checking content"""
    try:
        # Try to read first page using pdftotext or similar
        result = subprocess.run(
            ["python3", "-c", f"""
import sys
try:
    import fitz  # PyMuPDF
    doc = fitz.open('{pdf_path}')
    text = doc[0].get_text()
    print(text[:1000])
except ImportError:
    # Try pymupdf4
    try:
        import pypdf
        with open('{pdf_path}', 'rb') as f:
            reader = pypdf.PdfReader(f)
            text = reader.pages[0].extract_text()
            print(text[:1000])
    except ImportError:
        print('No PDF library available')
"""],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            text = result.stdout
            # Check for district names
            for district in ALL_DISTRICTS:
                if district in text:
                    return district.replace('区', '')  # Remove '区' suffix

    except Exception as e:
        pass

    return None


def main():
    print("=" * 60)
    print("Converting PDFs to Markdown")
    print("=" * 60)

    # Get all PDF files
    pdf_files = []
    for f in os.listdir(RAW_DIR):
        if f.endswith('.pdf') or f.endswith('.mhtml'):
            pdf_files.append(f)

    print(f"Found {len(pdf_files)} files to potentially convert")

    # Track which districts we have data for
    districts_with_data = set()

    # First, check existing markdown files
    for f in os.listdir(MD_DIR):
        if f.endswith('.md'):
            for district in ALL_DISTRICTS:
                if district in f or district.replace('区', '') in f:
                    districts_with_data.add(district)

    print(f"Already have markdown for: {sorted([d.replace('区', '') for d in districts_with_data])}")

    # Convert known PDFs
    for pdf_name, district in PDF_TO_DISTRICT.items():
        if district is None:
            continue

        pdf_path = os.path.join(RAW_DIR, pdf_name)

        # Skip if not a PDF
        if not pdf_name.endswith('.pdf'):
            continue

        # Generate markdown filename
        md_name = pdf_name.replace('.pdf', '.md')
        md_path = os.path.join(MD_DIR, md_name)

        # Skip if markdown exists and is not empty
        if os.path.exists(md_path) and os.path.getsize(md_path) > 0:
            print(f"✓ Already converted: {pdf_name}")
            districts_with_data.add(district)
            continue

        print(f"Converting: {pdf_name}")
        if convert_pdf_to_markdown(pdf_path, md_path):
            print(f"  ✓ Success")
            districts_with_data.add(district)
        else:
            print(f"  ✗ Failed")

    # Try to identify and convert unknown PDFs
    for pdf_name in pdf_files:
        if pdf_name in PDF_TO_DISTRICT:
            continue  # Already handled

        if not pdf_name.endswith('.pdf'):
            continue

        pdf_path = os.path.join(RAW_DIR, pdf_name)
        md_name = f"{os.path.splitext(pdf_name)[0]}.md"
        md_path = os.path.join(MD_DIR, md_name)

        # Skip if markdown exists
        if os.path.exists(md_path) and os.path.getsize(md_path) > 0:
            continue

        print(f"Identifying: {pdf_name}")
        district = identify_district_from_pdf(pdf_path)
        if district:
            print(f"  → Detected: {district}")
        else:
            print(f"  → Unknown district")

        # Try converting anyway
        print(f"Converting: {pdf_name}")
        if convert_pdf_to_markdown(pdf_path, md_path):
            print(f"  ✓ Success")
        else:
            print(f"  ✗ Failed")

    # Summary
    print("\n" + "=" * 60)
    print("Conversion Summary")
    print("=" * 60)
    print(f"Districts with data: {len(districts_with_data)}/16")

    missing = [d.replace('区', '') for d in ALL_DISTRICTS if d not in districts_with_data]
    if missing:
        print(f"Missing districts: {', '.join(missing)}")
    else:
        print("✓ All 16 districts have quota-to-school data!")


if __name__ == '__main__':
    main()
