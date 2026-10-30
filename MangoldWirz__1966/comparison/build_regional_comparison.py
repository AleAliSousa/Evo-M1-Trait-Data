#!/usr/bin/env python3
"""Rebuild the source-only Mangold-Wirz regional comparison and provenance audit."""
import csv
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
SOURCE = ROOT / "MangoldWirz__1966" / "MangoldWirz__1966_TableII_source.tsv"


def read(path, delimiter=","):
    with path.open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle, delimiter=delimiter))


def write(name, rows, fields):
    with (OUT / name).open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def number(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def fmt(value):
    return "" if value is None else f"{value:.6f}".rstrip("0").rstrip(".")


mw = read(SOURCE, "\t")
assert len(mw) == 93

# Retain each published index/percentage as a separate historical measure.
MEASURES = {
    "NI": ("Neopallium", "author allometric index", "", "dimensionless"),
    "RhI": ("Riechrinde (olfactory cortex)", "author allometric index", "", "dimensionless"),
    "CI": ("Cerebellum", "author allometric index", "", "dimensionless"),
    "StI": ("Stammrest", "author allometric index", "", "dimensionless"),
    "N_over_TH_pct": ("Neopallium", "reported part-to-whole proportion", "total brain", "percent"),
    "Rh_over_N_pct": ("Riechrinde (olfactory cortex)", "reported part-to-part proportion", "Neopallium", "percent"),
    "C_over_TH_pct": ("Cerebellum", "reported part-to-whole proportion", "total brain", "percent"),
    "St_over_TH_pct": ("Stammrest", "reported part-to-whole proportion", "total brain", "percent"),
}
long = []
for source_row, row in enumerate(mw, 1):
    for code, (structure, measure_type, denominator, unit) in MEASURES.items():
        value = row[code].strip()
        long.append(dict(source_row=source_row, printed_page=row["page"], group=row["group"],
                         species_as_printed=row["species_as_printed"], measure_code=code,
                         structure_as_source=structure, measure_type=measure_type,
                         denominator=denominator, value_as_printed=value,
                         value_numeric=fmt(number(value)), unit=unit,
                         value_status="reported" if value else "blank_in_table",
                         source_role="historical derived/compiled value; underlying specimen source unresolved",
                         source_item="MangoldWirz__1966_TableII"))
assert len(long) == 93 * 8
write("MangoldWirz__1966_regional_index_proportion_long.csv", long, list(long[0]))

# Later Dunbar tables use a volume-based neocortex/(brain - neocortex) ratio.
# An algebraic analogue can be calculated from Mangold-Wirz's printed N/TH %, but
# mass/volume basis, anatomical delineation, and row grain remain different.
COMPARATORS = [
    ("Dunbar__1992_Table1", ROOT / "Dunbar__1992" / "Dunbar__1992_Table1.csv",
     "genus", "neocortex_ratio", "genus_only", "Stephan et al. 1981"),
    ("Dunbar_Bever_1998_Table1", ROOT / "Dunbar_Bever_1998" / "Dunbar_Bever_1998_Table1.csv",
     "species", "neocortex_ratio_CR", "exact_printed_species", "Rohrs 1986a; Kamiya & Pirlot 1988"),
    ("Dunbar_Bever_1998_Table2", ROOT / "Dunbar_Bever_1998" / "Dunbar_Bever_1998_Table2.csv",
     "species", "neocortex_ratio_CR", "exact_printed_species", "Rohrs 1986b; Rohrs et al. 1989; estimated neocortex"),
    ("Dunbar_Bever_1998_Table3", ROOT / "Dunbar_Bever_1998" / "Dunbar_Bever_1998_Table3.csv",
     "genus", "neocortex_ratio_CR", "genus_only", "Frahm et al. 1982; Stephan et al. 1981/1984"),
]
index = defaultdict(list)
for label, path, name_field, ratio_field, level, cited_source in COMPARATORS:
    for comp in read(path):
        name = re.sub(r"\d+$", "", comp[name_field]).strip()  # printed footnote digits
        index[(level, name)].append((label, name, comp[ratio_field], cited_source, level))

comparisons = []
for source_row, row in enumerate(mw, 1):
    species = row["species_as_printed"].strip()
    genus = species.split()[0]
    percent = number(row["N_over_TH_pct"])
    analogue = percent / (100 - percent) if percent is not None and 0 < percent < 100 else None
    matches = index[("exact_printed_species", species)] + index[("genus_only", genus)]
    if not matches:
        matches = [("", "", "", "", "none")]
    for label, matched, reported, cited_source, level in matches:
        published_ratio = number(reported)
        delta = analogue - published_ratio if analogue is not None and published_ratio is not None else None
        comparisons.append(dict(
            mw_source_row=source_row, mw_printed_page=row["page"], mw_group=row["group"],
            mw_species_as_printed=species, mw_N_over_TH_pct_as_printed=row["N_over_TH_pct"],
            mw_N_over_rest_algebraic_analogue=fmt(analogue),
            comparator_item=label, comparator_taxon_as_printed=matched,
            match_level=level,
            comparator_neocortex_ratio_as_printed=reported,
            comparator_minus_mw_analogue=fmt(-delta) if delta is not None else "",
            comparator_underlying_source=cited_source,
            comparison_basis="1966 printed brain-part proportion vs later neocortex volume ratio",
            provenance_conclusion=("No direct Mangold-Wirz attribution in comparator's methods/table"
                                   if label else "No exact species or same-genus comparator row")))
assert len(comparisons) == 96
write("MangoldWirz__1966_neocortex_ratio_comparison.csv", comparisons, list(comparisons[0]))

audit = [
    ("Shultz_Dunbar_2006", "10.1098/rspb.2005.3283", "ungulate brain/body and neocortex mass",
     "article Methods, Data collection", "Explicitly lists Mangold-Wirz 1966 among five brain/body sources; computes neocortex ratios from brain and neocortex estimates",
     "direct paper-level citation", "individual source-to-species rows unresolved"),
    ("Dunbar__1992_Table1", "10.1016/0047-2484(92)90081-J", "primate genus neocortex/whole-brain volumes and C_R",
     "article Methods, PDF p. 5; Table 1", "Attributes neocortex and whole-brain volumes to Stephan et al. 1981",
     "no direct Mangold-Wirz attribution", "genus-level numeric comparison only"),
    ("Dunbar_Bever_1998_Table1", "10.1111/j.1439-0310.1998.tb00103.x", "carnivore brain/neocortex volumes and C_R",
     "Table 1 caption and footnote, journal p. 697", "Attributes volumes to Rohrs and Kamiya & Pirlot",
     "no direct Mangold-Wirz attribution", "exact printed species comparisons possible"),
    ("Dunbar_Bever_1998_Table2", "10.1111/j.1439-0310.1998.tb00103.x", "carnivore estimated neocortex volumes and C_R",
     "Table 2 caption/footnote and Methods, journal pp. 697-698", "Brain volumes from Rohrs; neocortex volumes estimated by authors' regression",
     "no direct Mangold-Wirz attribution", "exact printed species comparisons possible"),
    ("Dunbar_Bever_1998_Table3", "10.1111/j.1439-0310.1998.tb00103.x", "insectivore genus volumes and C_R",
     "Table 3 caption and Methods, journal pp. 697-699", "Attributes values to Frahm et al. 1982 and Stephan et al. 1981/1984",
     "no direct Mangold-Wirz attribution", "genus-level numeric comparison only"),
    ("Shultz_Dunbar_2010", "10.1037/a0018894", "nonhuman primate neocortex and brain volumes",
     "article Brain Measures, PDF p. 3", "Attributes absolute neocortex and total brain volumes to Stephan, Frahm & Baron 1981",
     "no direct Mangold-Wirz attribution", "no species data table in local repository"),
    ("Hofman__1985_Table1", "10.1159/000118718", "compiled prosencephalon volumes",
     "paper methods and local Table I definitions", "Uses literature fractions including Mangold-Wirz 1966 for some calculated forebrain values",
     "secondary use of Mangold-Wirz", "reference braces are block-level; contributing rows unresolved"),
    ("Baron_etal_1996_Table5", "", "compiled bat brain/body measurements",
     "Table 5 source-code key 9", "Source code 9 denotes Mangold-Wirz 1966",
     "direct source-code attribution", "Myotis myotis and Nyctalus noctula brain/body rows; regional-index reuse not established"),
    ("Sacher_Staffeldt_1974_Appendix", "", "compiled adult brain/body masses",
     "Appendix reference key 2", "Reference key 2 denotes Mangold-Wirz 1966 on 14 rows",
     "direct source-code attribution", "brain/body reuse, not a regional-index dataset"),
    ("Stephan_etal_1991_Table5", "", "compiled insectivore body/brain mass summaries",
     "Table 5 reference key 41", "Reference key 41 denotes Mangold-Wirz 1966 on four records for two taxa",
     "direct source-code attribution", "four records comprise S. minutus and N. fodiens variants; no regional-index reuse established"),
]
fields = ["dataset_item", "doi", "trait_channel", "evidence_location", "source_statement_summary",
          "mangold_wirz_provenance", "row_level_limit"]
write("MangoldWirz__1966_downstream_provenance_audit.csv",
      [dict(zip(fields, row)) for row in audit], fields)

print("regional measures:", len(long), "| comparison rows:", len(comparisons),
      "| candidates by comparator:", dict(Counter(r["comparator_item"] for r in comparisons if r["comparator_item"])))
