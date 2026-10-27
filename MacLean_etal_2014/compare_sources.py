"""Extract the main-paper bibliography and compare S1 ECV to the ECV merge."""
import csv
import re
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent


def write(name, rows, fields):
    with (ROOT / name).open("w", newline="") as file:
        out = csv.DictWriter(file, fieldnames=fields)
        out.writeheader()
        out.writerows(rows)


pages = PdfReader(ROOT / "MacLean-2014-The evolution of sel.pdf").pages
lines = "\n".join(page.extract_text() for page in pages).splitlines()
refs = []
for line in lines:
    match = re.match(r"^(\d{1,3})\.\s+(.+)", line)
    if match and int(match[1]) == len(refs) + 1:
        refs.append({"reference_number": int(match[1]), "citation_as_extracted": match[2]})
    elif refs and line.strip() and not re.match(r"^MacLean et al\.|^PNAS|^E\d{4}|^www\.pnas|^PSYCHOLOGICAL AND COGNITIVE SCIENCES", line):
        refs[-1]["citation_as_extracted"] += " " + line.strip()
assert len(refs) == 201, len(refs)
write("MacLean_etal_2014_MainPaperReferences.csv", refs, list(refs[0]))


si_lines = (ROOT / "MacLean_etal_2014_SIText_extracted.txt").read_text().splitlines()
si_refs = []
for line in si_lines:
    if line.startswith("Fig. S1."):
        break
    match = re.match(r"^(\d{1,2})\.\s+(.+)", line)
    if match and int(match[1]) == len(si_refs) + 1:
        si_refs.append({"reference_number": int(match[1]), "citation_as_extracted": match[2]})
    elif si_refs and line.strip() and not line.startswith("MacLean et al. www.pnas.org"):
        si_refs[-1]["citation_as_extracted"] += " " + line.strip()
assert len(si_refs) == 31, len(si_refs)
write("MacLean_etal_2014_SIReferences.csv", si_refs, list(si_refs[0]))
si_lookup = {str(row["reference_number"]): row["citation_as_extracted"] for row in si_refs}
for table, number_field in [("S1", "source_numbers_as_published"), ("S2", "reference_numbers_as_published")]:
    table_rows = list(csv.DictReader((ROOT / f"MacLean_etal_2014_Table{table}.csv").open()))
    links = []
    for row in table_rows:
        for number in row[number_field].split(","):
            number = number.strip()
            if number:
                links.append({"table": table, "source_row": row["source_row"], "species_as_published": row["species_as_published"], "si_reference_number": number, "si_citation_as_extracted": si_lookup[number]})
    write(f"MacLean_etal_2014_Table{table}_source_links.csv", links, list(links[0]))

s1 = list(csv.DictReader((ROOT / "MacLean_etal_2014_TableS1.csv").open()))
merge = list(csv.DictReader((REPO / "__merging_endocranial_volume/endocranial_volume_long.csv").open()))
by_species = {row["Species"]: row for row in merge if row["measure_class"] == "endocranial_volume"}
comparison = []
for row in s1:
    other = by_species.get(row["species_as_published"])
    maclean = float(row["ecv_cc"])
    merged = float(other["Value"]) if other else None
    comparison.append({
        "species_as_published": row["species_as_published"],
        "maclean_ecv_cc": row["ecv_cc"],
        "merge_species_exact_match": bool(other),
        "merge_ecv_ml": other["Value"] if other else "",
        "merge_teams": other["Teams"] if other else "",
        "difference_maclean_minus_merge_ml": round(maclean - merged, 6) if merged is not None else "",
        "maclean_source_numbers_unresolved": row["source_numbers_as_published"],
    })
write("MacLean_etal_2014_S1_vs_ECV_merge.csv", comparison, list(comparison[0]))
