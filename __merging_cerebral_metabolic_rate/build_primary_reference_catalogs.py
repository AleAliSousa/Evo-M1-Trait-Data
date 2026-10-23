#!/usr/bin/env python3
"""Build source-local cited-reference catalogs for the CMR compilations.

Kaufman (2004) and Karbowski (2007) are secondary compilations.  Their table
citations, rather than the compilation names, identify the candidate primary evidence.
This script joins every distinct table citation to the bibliography printed in
the corresponding source PDF, classifies whether that cited work is itself a
primary report, and writes a reference table beside each source.

The matching is deliberately local-only and conservative: exact table strings
are retained, checked OCR aliases are explicit below, and a missing bibliography
entry remains unresolved rather than being completed from the internet.
"""

from __future__ import annotations

import csv
import os
import re
import shutil
import subprocess
import sys
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path


HERE = Path(__file__).resolve().parent
BASE = HERE.parent
KAUFMAN = BASE / "Kaufman__2004"
KARBOWSKI = BASE / "Karbowski__2007"

KAUF_OUT = KAUFMAN / "reference_tables" / "Kaufman__2004_TablesA1-A14_references.csv"
KARB_OUT = KARBOWSKI / "reference_tables" / "Karbowski__2007_TablesS1-S23_references.csv"
ISSUES_OUT = HERE / "cerebral_metabolic_rate_reference_resolution_issues.csv"

YEAR_RX = re.compile(r"(?<!\d)((?:18|19|20)\d{2})([a-z]?)", re.I)

# These cited works are themselves syntheses, not the experimental reports that
# generated the table values.  They remain resolvable *source references* so the
# provenance chain is not lost, but they cannot populate a primary-only merge
# until their row-level experimental lineage is recovered from the supplied
# source materials.  The classifications are based on the bibliography entries
# printed in the local Kaufman and Karbowski PDFs.
NONPRIMARY_REFERENCE_METADATA = {
    "dastur_1985": {
        "reference_level": "secondary",
        "source_type": "review",
        "note": (
            "Review/reappraisal rather than a row-level experimental report; "
            "the compiled values are excluded until their primary lineage is resolved."
        ),
    },
    "clarke_1994": {
        "reference_level": "secondary",
        "source_type": "book_chapter",
        "note": (
            "Basic Neurochemistry chapter rather than a row-level experimental report; "
            "the compiled values are excluded until their primary lineage is resolved."
        ),
    },
    "sokoloff_1984": {
        "reference_level": "secondary",
        "source_type": "book",
        "note": (
            "Monograph rather than a row-level experimental report; the compiled "
            "values are excluded until their primary lineage is resolved."
        ),
    },
    "madsen_1993": {
        "reference_level": "secondary",
        "source_type": "pooled_reanalysis",
        "note": (
            "Author-led pooled methodological reanalysis of earlier study series, not "
            "an independent cohort. Kaufman Table A14 row 36 combines a corrected "
            "15-minute-subgroup CBF estimate with a pooled measured CMRO2 estimate; "
            "exclude until component-study lineage and compatible estimands are reconstructed. "
            "Bibliographic identity: J Cereb Blood Flow Metab 13:646-655, PMID 8314918, "
            "DOI 10.1038/jcbfm.1993.83; the citation field preserves the dissertation OCR."
        ),
    },
}


def reference_metadata(source_reference_id: str) -> dict[str, str]:
    return NONPRIMARY_REFERENCE_METADATA.get(
        source_reference_id,
        {"reference_level": "primary", "source_type": "primary_report", "note": ""},
    )


def combine_notes(*notes: str) -> str:
    return " ".join(note.strip() for note in notes if note and note.strip())

# Checked against the table pages and Literature Cited in the local dissertation.
AUTHOR_ALIASES = {
    "aikire": "alkire",
    "flawkins": "hawkins",
    "inlund": "enlund",
    "martinet": "martinot",
    "qri": "ori",
    "sadekaro": "kadekaro",
    "takamuxa": "nakamura",
    "vlacneill": "macneill",
    "vlillien": "millien",
    "vloore": "moore",
    "voikow": "volkow",
    "vorstmp": "vorstrup",
    "alombo": "palombo",
    "orrino": "porrino",
    "craneandporrino": "crane",
    "crossetat": "cross",
    "bums": "burns",
    "devoider": "devolder",
    "fomai": "fornai",
    "vemhiet": "vernhiet",
    # Karbowski table OCR variants.
    "bline": "blin",
    "nehling": "nehlig",
}

BIB_AUTHOR_ALIASES = {
    "bums": "burns",
    "devoider": "devolder",
    "fomai": "fornai",
    "reivieh": "reivich",
    "vemhiet": "vernhiet",
}

# Exact fragments whose missing author/year is recoverable from adjacent table
# content or a uniquely identified row in the source PDF.  The frozen snapshots
# are not edited; these repairs are recorded in the catalog and merge provenance.
EXACT_REFERENCE_REPAIRS = {
    "(": "Sokoloff et al., 1977",
    "1993)": "Delgado-Zygmunt et al., 1993",
    "1998)": "Poindessous-Jazat et al., 1998",
    "1981)": "Nowaczyk and Des Rosiers, 1981",
    "1988)": "McPherson and Traystman, 1988",
    "(McPherson and Traystman,": "McPherson and Traystman, 1988",
    "Hovda": "Hovda et al., 1996",
    "Petitjean 82": "Petitjean et al., 1982",
    "Triolo 90": "Triolo et al., 1990",
    "Yamaki 96": "Yamaki et al., 1996",
    "Present Study": "Kaufman, 2004",
    "’resent Study": "Kaufman, 2004",
    "(Perlmutter et al., 2987)": "Perlmutter et al., 1987",
}

REPAIR_NOTES = {
    "(": (
        "OCR column shift repaired from the table page: all 11 occurrences are "
        "Sokoloff et al. (1977); see merge ROW_REPAIRS for value/n repair."
    ),
    "1993)": "Split table citation reconstructed as Delgado-Zygmunt et al. (1993).",
    "1998)": "Split table citation reconstructed as Poindessous-Jazat et al. (1998).",
    "1981)": "Split table citation reconstructed as Nowaczyk and Des Rosiers (1981).",
    "1988)": "Split table citation reconstructed as McPherson and Traystman (1988).",
    "(McPherson and Traystman,": "Non-data continuation fragment; joined to the following 1988) row.",
    "Takamuxa et al., 1983)": "OCR author repaired to Nakamura; verified on dissertation PDF page 126.",
}


def ascii_letters(value: str) -> str:
    value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z]", "", value.lower())


def clean_space(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def pdftotext(pdf: Path, layout: bool = False) -> str:
    exe = os.environ.get("PDFTOTEXT") or shutil.which("pdftotext")
    if not exe:
        raise RuntimeError(
            "pdftotext is required to rebuild the reference catalogs; install Poppler "
            "or use the already-generated catalog CSVs."
        )
    args = [exe]
    args.append("-layout" if layout else "-raw")
    args.extend([str(pdf), "-"])
    return subprocess.run(args, check=True, text=True, stdout=subprocess.PIPE).stdout


def parse_kaufman_bibliography(text: str) -> list[dict[str, str]]:
    # Removing form feeds is important: the first citation on each PDF page then
    # has the same indentation as all other entry starts.
    lines = text.replace("\f", "").split("\n")
    start = max(i for i, line in enumerate(lines) if "Literature Cited" in line)
    entries: list[str] = []
    current: list[str] = []
    for line in lines[start + 1 :]:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))
        if (
            not stripped
            or stripped == "Literature Cited"
            or stripped.startswith("Reproduced with permission")
            or re.fullmatch(r"\d{3}", stripped)
        ):
            continue
        is_start = indent in {21, 22, 23} and stripped[0].isalpha()
        if is_start:
            if current:
                entries.append(clean_space(" ".join(current)))
            current = [stripped]
        elif current:
            current.append(stripped)
    if current:
        entries.append(clean_space(" ".join(current)))

    if len(entries) != 504:
        raise RuntimeError(f"Expected 504 Kaufman bibliography entries, found {len(entries)}")

    parsed = []
    for index, citation in enumerate(entries, 1):
        match = re.search(r"\(((?:18|19|20)\d{2})([a-z]?)\)", citation, re.I)
        if not match:
            raise RuntimeError(f"No parenthesized year in Kaufman bibliography entry {index}: {citation}")
        parsed.append(
            {
                "citation": citation,
                "year": match.group(1),
                "suffix": match.group(2).lower(),
                "author_block": citation[: match.start()],
                "locator": f"Literature Cited entry {index}",
            }
        )
    return parsed


def parse_numbered_bibliography(text: str) -> dict[int, str]:
    lines = text.replace("\f", "\n").splitlines()
    start = next(i for i, line in enumerate(lines) if line.strip() == "References")
    out: dict[int, list[str]] = {}
    current = None
    skip_prefixes = (
        "Publishwith BioMed Central", "scientist can read", '"BioMed Central',
        "Sir Paul Nurse", "Cancer Research UK", "Your research papers", "available free",
        "peer reviewed", "cited in PubMed", "yours ", "Submit your manuscript",
        "disseminating the results of biomedical research",
        "http://www.biomedcentral", "BioMedcentral", "BMC Biology 2007", "Page 11 of 11",
        "(page number not for citation purposes)",
    )
    for line in lines[start + 1 :]:
        stripped = line.strip()
        if not stripped or any(stripped.startswith(prefix) for prefix in skip_prefixes):
            continue
        match = re.match(r"^(\d{1,3})\.\s+(.*)$", stripped)
        if match:
            number = int(match.group(1))
            if number > 100:
                break
            current = number
            out[current] = [match.group(2)]
        elif current is not None:
            out[current].append(stripped)
    return {number: clean_space(" ".join(parts)) for number, parts in out.items()}


def reference_parts(raw: str) -> tuple[str, str, str, str]:
    """Return repaired core, normalized first-author candidate, year, suffix."""
    repaired = EXACT_REFERENCE_REPAIRS.get(raw.strip(), raw.strip())
    core = repaired.strip().strip('"').strip().strip("()")
    # Controlled Karbowski qualifiers describe a subregion/derivation, not a work.
    core = re.sub(
        r",\s*(?:estim\.?|auditory|CA1\s*\+\s*CA3|dorsal\s*\+\s*ventral)\s*$",
        "",
        core,
        flags=re.I,
    )
    year_match = YEAR_RX.search(core)
    if not year_match:
        return core, "", "", ""
    year, suffix = year_match.group(1), year_match.group(2).lower()
    if ascii_letters(core[: year_match.start()]).startswith("perlmutter") and year == "2987":
        year = "1987"
    author_part = core[: year_match.start()].strip(" ,")
    author_part = re.sub(
        r"(?i)\s*(?:e\s*t\s*a\s*l|etal|et\s*at)\.?\s*$", "", author_part
    ).strip(" ,")
    author_part = re.split(r"(?i)\s+and\s*", author_part)[0]
    author = ascii_letters(author_part)
    author = AUTHOR_ALIASES.get(author, author)
    return core, author, year, suffix


def bibliography_author_norm(author_block: str) -> str:
    value = ascii_letters(author_block)
    value = BIB_AUTHOR_ALIASES.get(value, value)
    # Aliases normally affect just the first surname while `value` also contains
    # initials/coauthors; handle those prefixes explicitly.
    for wrong, right in BIB_AUTHOR_ALIASES.items():
        if value.startswith(wrong):
            value = right + value[len(wrong) :]
            break
    return value


def bibliography_first_author(author_block: str) -> str:
    """Extract a first surname while retaining particles such as `De Volder`."""
    first = author_block.split(",", 1)[0].strip()
    first = re.sub(r"\s+[A-Z][A-Za-z.]*$", "", first).strip()
    # A few OCR entries join the final initial to the surname (e.g. SokoloffL).
    first = re.sub(r"(?<=[a-zà-ÿ])(?:[A-Z]{1,4})$", "", first)
    value = ascii_letters(first)
    value = AUTHOR_ALIASES.get(value, BIB_AUTHOR_ALIASES.get(value, value))
    return value


def match_kaufman(raw: str, bibliography: list[dict[str, str]]) -> dict[str, str]:
    core, author, year, suffix = reference_parts(raw)
    if raw.strip() in {"Present Study", "’resent Study"}:
        return {
            "primary_reference_id": "kaufman_2004_present_study",
            "citation": (
                "Kaufman JA. 2004. Pattern and scaling of regional cerebral glucose "
                "metabolism in mammals. Doctoral dissertation, Washington University."
            ),
            "status": "resolved_self_primary",
            "locator": "Kaufman__2004_dissertation.pdf",
            "core": core,
        }
    if not author or not year:
        return {"primary_reference_id": "", "citation": "", "status": "unresolved", "locator": "", "core": core}

    candidates = []
    for entry in bibliography:
        if entry["year"] != year:
            continue
        if suffix and entry["suffix"] != suffix:
            continue
        if bibliography_first_author(entry["author_block"]) == author:
            candidates.append(entry)
    # A source without a/b may match the sole same-author/year entry, including
    # one whose bibliography year carries a suffix.
    if len(candidates) != 1 and not suffix:
        candidates = [
            entry
            for entry in bibliography
            if entry["year"] == year
            and bibliography_first_author(entry["author_block"]) == author
        ]
    if len(candidates) != 1:
        status = "unresolved_missing_bibliography" if not candidates else "unresolved_ambiguous"
        return {"primary_reference_id": "", "citation": "", "status": status, "locator": "", "core": core}

    entry = candidates[0]
    canonical_suffix = entry["suffix"] or suffix
    primary_id = f"{author}_{year}{canonical_suffix}"
    return {
        "primary_reference_id": primary_id,
        "citation": entry["citation"],
        "status": "resolved",
        "locator": entry["locator"],
        "core": core,
    }


def kaufman_reference_counts() -> tuple[Counter, dict[str, set[str]]]:
    counts: Counter = Counter()
    tables: dict[str, set[str]] = defaultdict(set)
    paths = sorted(KAUFMAN.glob("Kaufman__2004_TableA*.csv"))
    paths = [p for p in paths if re.search(r"TableA(?:[1-9]|1[0-4])\.csv$", p.name)]
    for path in paths:
        table = re.search(r"TableA\d+", path.name).group(0)
        with path.open(newline="", encoding="utf-8-sig") as handle:
            for row in csv.DictReader(handle):
                raw = (row.get("Reference") or "").strip()
                if raw:
                    counts[raw] += 1
                    tables[raw].add(table)
    return counts, tables


def karbowski_reference_counts() -> tuple[Counter, dict[str, set[str]]]:
    counts: Counter = Counter()
    tables: dict[str, set[str]] = defaultdict(set)
    paths = sorted(KARBOWSKI.glob("Karbowski__2007_TableS*.csv"))
    for path in paths:
        table = re.search(r"TableS\d+", path.name).group(0)
        with path.open(newline="", encoding="utf-8-sig") as handle:
            for row in csv.DictReader(handle):
                raw_cell = (row.get("reference") or "").strip()
                if not raw_cell or re.fullmatch(r"N=\d+", raw_cell):
                    continue
                for raw in (part.strip() for part in raw_cell.split(";")):
                    if raw:
                        counts[raw] += 1
                        tables[raw].add(table)
    return counts, tables


def karbowski_number_for(author: str, year: str) -> int | None:
    if author == "clarke" and year == "1994":
        return 5
    mapping = {
        ("bouilleret", "2000"): 65, ("quelven", "2004"): 66,
        ("dube", "2001"): 67, ("nehlig", "1988"): 68,
        ("nehlig", "2000"): 69,
        ("levant", "2004"): 70, ("waschke", "1993"): 71,
        ("zocchi", "2001"): 72, ("blin", "1991"): 73,
        ("passero", "1981"): 74, ("frerichs", "1995"): 75,
        ("chugani", "1991"): 76, ("schwartzman", "1986"): 77,
        ("sokoloff", "1984"): 78, ("lydic", "1991"): 79,
        ("herdman", "1989"): 80, ("porrino", "2002"): 81,
        ("palombo", "1990"): 82, ("noda", "2002"): 83,
        ("kennedy", "1978"): 84, ("meguro", "1999"): 85,
        ("pelligrino", "1987"): 86, ("pell", "1983"): 87,
        ("maquet", "1992"): 88, ("heiss", "1985"): 89,
        ("haier", "1992"): 90, ("redies", "1989"): 91,
        ("devolder", "1997"): 92, ("blomqvist", "1998"): 93,
        ("linde", "1999"): 94, ("stingele", "1996"): 95,
        ("nakanishi", "1997"): 96, ("nemoto", "1994"): 97,
        ("sahlin", "1987"): 98, ("madsen", "1991"): 99,
    }
    return mapping.get((author, year))


def write_catalog(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "ref_key", "cited_in_column", "citation", "note",
        "source_reference_id", "reference_level", "source_type",
        "primary_reference_id", "reference_core", "resolution_status",
        "evidence_file", "evidence_locator", "cited_in_tables", "occurrence_count",
    ]
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def build() -> None:
    kauf_bib = parse_kaufman_bibliography(
        pdftotext(KAUFMAN / "Kaufman__2004_dissertation.pdf", layout=True)
    )
    kauf_counts, kauf_tables = kaufman_reference_counts()
    kauf_rows = []
    for raw in sorted(kauf_counts, key=str.casefold):
        match = match_kaufman(raw, kauf_bib)
        source_reference_id = match["primary_reference_id"]
        metadata = reference_metadata(source_reference_id)
        note = REPAIR_NOTES.get(raw, "")
        if raw in EXACT_REFERENCE_REPAIRS and not note:
            note = f"Table citation reconstructed as {EXACT_REFERENCE_REPAIRS[raw]}."
        note = combine_notes(note, metadata["note"])
        kauf_rows.append(
            {
                "ref_key": raw,
                "cited_in_column": "Reference",
                "citation": match["citation"],
                "note": note,
                "source_reference_id": source_reference_id,
                "reference_level": metadata["reference_level"] if source_reference_id else "unresolved",
                "source_type": metadata["source_type"] if source_reference_id else "unresolved",
                "primary_reference_id": (
                    source_reference_id if metadata["reference_level"] == "primary" else ""
                ),
                "reference_core": match["core"],
                "resolution_status": (
                    "resolved_secondary_without_primary_lineage"
                    if source_reference_id and metadata["reference_level"] == "secondary"
                    else match["status"]
                ),
                "evidence_file": "Kaufman__2004_dissertation.pdf",
                "evidence_locator": match["locator"],
                "cited_in_tables": "; ".join(sorted(kauf_tables[raw])),
                "occurrence_count": kauf_counts[raw],
            }
        )

    karb_bib = parse_numbered_bibliography(
        pdftotext(KARBOWSKI / "Karbowski-2007-Global and regional.pdf")
    )
    karb_counts, karb_tables = karbowski_reference_counts()
    karb_rows = []
    for raw in sorted(karb_counts, key=str.casefold):
        core, author, year, suffix = reference_parts(raw)
        number = karbowski_number_for(author, year)
        citation = karb_bib.get(number, "") if number else ""
        status = "resolved" if citation else "unresolved"
        # Cross-compilation identity: the full bibliography shows that Karbowski's
        # unsuffixed Madsen 1991 is Kaufman's Madsen 1991b (J Appl Physiol 70:2597).
        source_reference_id = f"{author}_{year}{suffix}" if status == "resolved" else ""
        if source_reference_id == "madsen_1991":
            source_reference_id = "madsen_1991b"
        metadata = reference_metadata(source_reference_id)
        qualifier = ""
        qmatch = re.search(
            r",\s*(estim\.?|auditory|CA1\s*\+\s*CA3|dorsal\s*\+\s*ventral)\s*$",
            raw,
            flags=re.I,
        )
        if qmatch:
            qualifier = qmatch.group(1)
        note = f"Table qualifier retained separately: {qualifier}." if qualifier else ""
        note = combine_notes(note, metadata["note"])
        karb_rows.append(
            {
                "ref_key": raw,
                "cited_in_column": "reference",
                "citation": citation,
                "note": note,
                "source_reference_id": source_reference_id,
                "reference_level": metadata["reference_level"] if source_reference_id else "unresolved",
                "source_type": metadata["source_type"] if source_reference_id else "unresolved",
                "primary_reference_id": (
                    source_reference_id if metadata["reference_level"] == "primary" else ""
                ),
                "reference_core": core,
                "resolution_status": (
                    "resolved_secondary_without_primary_lineage"
                    if source_reference_id and metadata["reference_level"] == "secondary"
                    else status
                ),
                "evidence_file": "Karbowski-2007-Global and regional.pdf",
                "evidence_locator": f"reference {number}" if number else "",
                "cited_in_tables": "; ".join(sorted(karb_tables[raw])),
                "occurrence_count": karb_counts[raw],
            }
        )

    kauf_source_ids = {r["source_reference_id"] for r in kauf_rows if r["source_reference_id"]}
    karb_source_ids = {r["source_reference_id"] for r in karb_rows if r["source_reference_id"]}
    kauf_primary_ids = {r["primary_reference_id"] for r in kauf_rows if r["primary_reference_id"]}
    karb_primary_ids = {r["primary_reference_id"] for r in karb_rows if r["primary_reference_id"]}
    unresolved_kauf = [r for r in kauf_rows if not r["source_reference_id"]]
    unresolved_karb = [r for r in karb_rows if not r["source_reference_id"]]
    if {r["ref_key"] for r in unresolved_kauf} != {"(Zimmer, 1975)"}:
        raise RuntimeError(
            "Unexpected unresolved Kaufman citations: "
            + "; ".join(r["ref_key"] for r in unresolved_kauf)
        )
    if unresolved_karb:
        raise RuntimeError(
            "Unexpected unresolved Karbowski citations: "
            + "; ".join(r["ref_key"] for r in unresolved_karb)
        )

    # Resolve and validate both source catalogs before replacing either output.
    write_catalog(KAUF_OUT, kauf_rows)
    write_catalog(KARB_OUT, karb_rows)
    with ISSUES_OUT.open("w", newline="", encoding="utf-8") as handle:
        fields = ["issue_id", "compilation", "reference_raw", "issue_type", "status",
                  "severity", "evidence_file", "notes"]
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        for index, row in enumerate(unresolved_kauf, 1):
            writer.writerow({
                "issue_id": f"CMR-REF-{index:03d}", "compilation": "Kaufman__2004",
                "reference_raw": row["ref_key"], "issue_type": row["resolution_status"],
                "status": "open", "severity": "warning", "evidence_file": row["evidence_file"],
                "notes": (
                    "The table citation is retained, but no matching bibliography entry exists "
                    "anywhere in the supplied Kaufman folder; do not guess a full citation."
                ),
            })
        issue_index = len(unresolved_kauf)
        secondary_groups: dict[tuple[str, str], list[dict[str, str]]] = defaultdict(list)
        for compilation, rows in (
            ("Kaufman__2004", kauf_rows), ("Karbowski__2007", karb_rows)
        ):
            for row in rows:
                if row["reference_level"] == "secondary":
                    secondary_groups[(compilation, row["source_reference_id"])].append(row)
        for (compilation, source_reference_id), rows in sorted(secondary_groups.items()):
            issue_index += 1
            writer.writerow({
                "issue_id": f"CMR-REF-{issue_index:03d}",
                "compilation": compilation,
                "reference_raw": " || ".join(sorted(r["ref_key"] for r in rows)),
                "issue_type": "secondary_source_without_primary_lineage",
                "status": "open",
                "severity": "warning",
                "evidence_file": rows[0]["evidence_file"],
                "notes": (
                    f"{source_reference_id} is a {rows[0]['source_type']}, not a row-level "
                    "primary experiment. Retain it as cited-source provenance but exclude its "
                    "values from the primary-only merge until primary lineage is recovered."
                ),
            })
    print(
        f"Kaufman: {len(kauf_rows)} raw aliases -> {len(kauf_source_ids)} resolved source IDs "
        f"({len(kauf_primary_ids)} primary; + Zimmer 1975 unresolved); Karbowski: "
        f"{len(karb_rows)} raw aliases -> {len(karb_source_ids)} source IDs "
        f"({len(karb_primary_ids)} primary); shared primary IDs: "
        f"{len(kauf_primary_ids & karb_primary_ids)}",
        file=sys.stderr,
    )


if __name__ == "__main__":
    build()
