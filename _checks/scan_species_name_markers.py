#!/usr/bin/env python3
"""
Scan the repo for species names carrying a meaningful trailing marker.

A printed table's superscript footnote survives flattening as a glued character:
"Homo sapiensb" is Homo sapiens + footnote b, not a typo. Same for trailing
specimen digits ("Ornithorhynchus anatinus 1") and for dagger/asterisk symbols.
This script finds them so they can be split into their own column instead of
being silently deleted.

Six passes:

  A  glued footnote LETTER    "Homo sapiensb"  -- base binomial is far more common
  B  trailing NUMBER          "Tachyglossus aculeatus 1"
  C  SYMBOL or unicode superscript  "Macaca tonkeana†", "Erinaceus algirus¹"
  D  xlsx SUPERSCRIPT RUNS    reads xl/sharedStrings.xml for vertAlign=superscript
                              -- catches markers that every flattening reader drops
  E  OCR CORRUPTION           digits inside epithets, ligature damage
  F  PDF PRINTED PAGE         pdftotext over every PDF -- the only witness once a
                              snapshot has already dropped the marker

Passes D and F are the ones that matter. D recovers markers from a publisher .xlsx
BEFORE the snapshot is built, because the snapshot is where typography dies. F is
the backstop for scanned tables: Frahm_etal_1984's "Lemur albifrons 1)" and
Baron_etal_1988's "Potamogale velox*)" exist nowhere except the printed page, and
an earlier version of this scanner missed both by not reading PDFs.

Usage:  python3 _checks/scan_species_name_markers.py [repo_root]
Writes: _checks/species_name_marker_scan_<date>.csv
"""

import collections
import csv
import datetime
import os
import re
import sys
import warnings
import zipfile

warnings.filterwarnings("ignore")

try:
    import openpyxl
except ImportError:
    openpyxl = None
try:
    import xlrd
except ImportError:
    xlrd = None

SKIP_DIRS = {".git", ".Rproj.user", "node_modules", "__pycache__"}
EXTS = (".tsv", ".csv", ".xlsx", ".xlsm", ".xls", ".r", ".py", ".md")
# This audit's own outputs quote every marker they document. Left in scope they
# inflate the "how many files is this string in?" counts that pass A relies on,
# and the scanner stops flagging the very cells it was written to find.
SKIP_NAMES = re.compile(r"^species_name_marker_(audit|scan)")
BINOMIAL = re.compile(r"^[A-Z][a-z]{2,}[ _][a-z][a-z\-\.]{1,}")
SUPERSCRIPT_CHARS = set("ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻ¹²³⁴⁵⁶⁷⁸⁹⁰*∗†‡§¶#")

# Words that look binomial but are prose/headers; keeps the report readable.
NOT_A_TAXON = re.compile(
    r"^(Body|Brain|Total|Whole|Rest|Mean|Data|Source|Table|Figure|Supplementary|"
    r"Area|Volume|Number|Great|Frontal|Occipital|Anterior|Among|Age|Additional|"
    r"Accessory|Agranular|Amygdala|Amygdaloid|Granular|Dysgranular|Species|Genus|"
    r"Stephan (code|collection|unpublished)|Percentage|Cranial|Intermembral|Grid|"
    r"Maximum|Middle|Primary|Synapse|Structure|Ventral|Gyrification|Fossil|Group)\b"
)


def normalise(value):
    return re.sub(r"\s+", " ", value.replace("_", " ")).strip()


def is_candidate(value):
    if not isinstance(value, str):
        return False
    value = value.strip().strip('"').strip()
    return bool(value) and len(value) <= 70 and bool(BINOMIAL.match(value))


def collect_files(root):
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if name.startswith("~$") or SKIP_NAMES.match(name):
                continue
            if name.lower().endswith(EXTS):
                found.append(os.path.join(dirpath, name))
    return found


def read_values(path):
    """Yield every string cell that could be a binomial."""
    low = path.lower()
    try:
        if low.endswith((".tsv", ".csv")):
            delim = "\t" if low.endswith(".tsv") else ","
            with open(path, newline="", encoding="utf-8-sig", errors="replace") as fh:
                for row in csv.reader(fh, delimiter=delim):
                    yield from row
        elif low.endswith((".xlsx", ".xlsm")) and openpyxl:
            book = openpyxl.load_workbook(path, read_only=True, data_only=True)
            for sheet in book.worksheets:
                for row in sheet.iter_rows(values_only=True):
                    yield from row
            book.close()
        elif low.endswith(".xls") and xlrd:
            book = xlrd.open_workbook(path)
            for sheet in book.sheets():
                for r in range(sheet.nrows):
                    yield from sheet.row_values(r)
        else:  # .R / .py / .md -- quoted string literals only
            text = open(path, encoding="utf-8", errors="replace").read()
            for match in re.finditer(r"[\"']([^\"'\n]{5,70})[\"']", text):
                yield match.group(1)
    except Exception:
        return


def superscript_runs(path):
    """Recover superscript-formatted runs from an xlsx, pre-flattening.

    Returns (full_text, superscript_part) pairs for binomial-looking cells.
    """
    try:
        archive = zipfile.ZipFile(path)
        if "xl/sharedStrings.xml" not in archive.namelist():
            return
        xml = archive.read("xl/sharedStrings.xml").decode("utf8", "replace")
        if "superscript" not in xml:
            return
        for si in re.findall(r"<si>.*?</si>", xml, re.S):
            if "superscript" not in si:
                continue
            runs = re.findall(r"<r>(.*?)</r>", si, re.S)
            if not runs:
                continue
            strip = lambda s: re.sub(r"<.*?>", "", s)
            text = "".join(strip(r) for r in runs).strip()
            sup = "".join(strip(r) for r in runs if "superscript" in r).strip()
            if sup and len(text) < 60 and BINOMIAL.match(text):
                yield text, sup
    except Exception:
        return


# A binomial followed by a marker on the printed page. Covers the three shapes
# seen in this corpus: "Lemur albifrons 1)", "Potamogale velox*)", "Homo sapiensb".
PDF_MARKER = re.compile(
    r"\b([A-Z][a-z]{3,} [a-z]{4,})"
    r"(\s?\d{1,2}\)|\s?\*+\)|\s?[†‡§¶]+\)?|\s?[¹²³⁴⁵⁶⁷⁸⁹⁰]+)"
)


def pdf_markers(path):
    """Yield (binomial, marker, context) for markers printed on the page."""
    import subprocess

    try:
        text = subprocess.run(
            ["pdftotext", "-layout", "-q", path, "-"],
            capture_output=True, timeout=180,
        ).stdout.decode("utf8", "replace")
    except Exception:
        return
    for line in text.splitlines():
        for match in PDF_MARKER.finditer(line):
            name, marker = match.group(1), match.group(2).strip()
            if NOT_A_TAXON.match(name) or not marker:
                continue
            yield name, marker, line.strip()[:110]


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(
        os.path.dirname(os.path.abspath(__file__))
    )
    paths = collect_files(root)

    occurrences = collections.defaultdict(set)   # value -> {relative path}
    sup_hits = []                                # (relpath, text, superscript)
    pdf_hits = []                                # (relpath, name, marker, context)

    for path in paths:
        rel = os.path.relpath(path, root)
        for value in read_values(path):
            if is_candidate(value):
                occurrences[value.strip().strip('"').strip()].add(rel)
        if path.lower().endswith((".xlsx", ".xlsm")):
            for text, sup in superscript_runs(path):
                sup_hits.append((rel, text, sup))

    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if not name.lower().endswith(".pdf"):
                continue
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, root)
            seen = set()
            for taxon, marker, context in pdf_markers(full):
                if (taxon, marker) in seen:
                    continue
                seen.add((taxon, marker))
                pdf_hits.append((rel, taxon, marker, context))

    # Fold _ / whitespace variants together so frequency counts are meaningful.
    by_norm = collections.defaultdict(set)
    for value, files in occurrences.items():
        by_norm[normalise(value)] |= files
    breadth = {name: len(files) for name, files in by_norm.items()}

    rows = []

    def record(pass_id, value, marker, note, files):
        rows.append(
            {
                "pass": pass_id,
                "value": value,
                "marker": marker,
                "note": note,
                "n_files": len(files),
                "files": "; ".join(sorted(files)[:5]),
            }
        )

    for value in sorted(occurrences):
        norm = normalise(value)
        files = occurrences[value]
        if NOT_A_TAXON.match(norm):
            continue

        # C -- symbol or unicode superscript anywhere in the cell
        if any(ch in SUPERSCRIPT_CHARS for ch in norm):
            marker = "".join(ch for ch in norm if ch in SUPERSCRIPT_CHARS)
            record("C_symbol", value, marker, "symbol/superscript marker", files)
            continue

        # B -- trailing specimen number
        match = re.match(r"^([A-Z][a-z]+ (?:[a-z\-]+\.?|sp\.?)(?: [a-z\-]+)?) ?(\d{1,4})$", norm)
        if match:
            base, num = match.group(1), match.group(2)
            if breadth.get(base, 0) > 0:
                record("B_number", value, num,
                       f"trailing number; base '{base}' seen in {breadth[base]} files", files)
                continue

        # A -- glued footnote letter: base binomial must be much more widespread
        match = re.match(r"^([A-Z][a-z]+ [a-z]{3,})([a-z])$", norm)
        if match:
            base, letter = match.group(1), match.group(2)
            here = breadth.get(norm, 1)
            there = breadth.get(base, 0)
            if there >= 3 * max(1, here) and here <= 3:
                record("A_letter", value, letter,
                       f"glued letter; base '{base}' in {there} files vs {here}", files)
                continue

        # E -- OCR corruption
        if re.search(r"[a-z]\d[a-z]", norm) or re.search(r"\bj[lf][a-z]", norm):
            record("E_ocr", value, "", "possible OCR corruption", files)

    for rel, text, sup in sup_hits:
        rows.append(
            {
                "pass": "D_xlsx_superscript",
                "value": text,
                "marker": sup,
                "note": "superscript run preserved in xl/sharedStrings.xml",
                "n_files": 1,
                "files": rel,
            }
        )

    for rel, taxon, marker, context in pdf_hits:
        rows.append(
            {
                "pass": "F_pdf_printed",
                "value": taxon,
                "marker": marker,
                "note": f"marker on the printed page: {context}",
                "n_files": 1,
                "files": rel,
            }
        )

    stamp = datetime.date.today().isoformat()
    out = os.path.join(root, "_checks", f"species_name_marker_scan_{stamp}.csv")
    with open(out, "w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(
            fh, fieldnames=["pass", "value", "marker", "note", "n_files", "files"]
        )
        writer.writeheader()
        writer.writerows(rows)

    counts = collections.Counter(r["pass"] for r in rows)
    print(f"scanned {len(paths)} files, {len(occurrences)} distinct binomial-like strings")
    for pass_id in sorted(counts):
        print(f"  {pass_id:22} {counts[pass_id]}")
    print(f"wrote {os.path.relpath(out, root)}")
    print("\nA hit is not automatically an error. Confirm each marker against the "
          "source table legend, then split it into its own column -- never store "
          "it in both the name and the marker column.")


if __name__ == "__main__":
    main()
