#!/usr/bin/env python3
"""build_cerebral_metabolic_rate_merge.py -- the tested builder for the cerebral
metabolic-rate merge. House twin: cerebral_metabolic_rate_compiled.R (same
pipeline, tidyverse idiom). See README__merging.md.

Sources (all BRAIN-only; whole-body BMR lives in __merging_body_ecology):
  Heiss_etal_2004  PRIMARY    Homo sapiens regional CMRgl (PET)
  Kaufman__2004    SECONDARY  A1-A14, one row per primary study (+ anesthesia state)
  Karbowski__2007  SECONDARY  S1-S23, one row per primary reference

Two direct-measurement classes are emitted:
  cerebral_metabolic_rate / cerebral_perfusion
      MASS-SPECIFIC rates: CMRgl, CMRO2 (umol/100g/min), CBF (mL/100g/min).
      Compilation-aware: both compilations are pulled down to primary-study level
      and studies they share are deduped before averaging.
Karbowski's compiler averages, cross-area summaries, estimates, compound-source
values, and derived whole-brain totals remain in the provenance output, with
their lineage where it can be stated, but do not enter the primary-only means.
"""
import csv, glob, math, os, re, sys
from collections import defaultdict

# Order-independent mean. Naive float accumulation makes a cell mean depend on the
# order the study values happen to be visited, and a few cell means (e.g. Mus
# musculus whole-brain CMRgl = 73.2075) sit on a .0005 decimal boundary where that
# last-bit difference flips the 3rd decimal. math.fsum returns the exactly-rounded
# sum whatever the order, so the cell mean no longer depends on file-read order.
def mean(xs):
    return math.fsum(xs) / len(xs)


def round3(x):
    """Round to 3 dp, half away from zero, IDENTICALLY in R and Python.

    Neither language's native rounding will do. Python's round() rounds the stored
    double (73.2074999... -> 73.207); R's round() rounds the shortest decimal you
    would print (73.2075 -> 73.208). Both are defensible and they disagree on a few
    percent of multi-study means, so the twin builders would silently diverge.

    So the rule is written out explicitly and identically in both: format to 9 dp
    with C printf (both languages call the same libc routine), then round half-up at
    the 4th decimal using exact INTEGER arithmetic. The double-rounding window this
    leaves is 5e-10 wide -- six orders of magnitude below the 2-3 decimals the
    sources print -- and R/Python agreement was checked over 200,000 simulated
    multi-study means with zero disagreements. See cerebral_metabolic_rate_compiled.R,
    which carries the same function.
    """
    s = "%.9f" % x
    neg = s.startswith("-")
    i, f = s.lstrip("-").split(".")
    n = int(i) * 10**9 + int(f)              # exact integer of value * 1e9
    v = ((n + 500_000) // 1_000_000) / 1000.0
    return -v if neg else v

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)

# ---- crosswalks -------------------------------------------------------------
REGION_CANON = {
    "Whole Brain (direct measurement)": "Whole_brain", "Brain": "Whole_brain",
    "Whole Brain": "Whole_brain",
    "Neocortex": "Neocortex", "Cerebral cortex": "Neocortex",
    "Cerebral cortex (global average)": "Neocortex", "Cortex": "Neocortex",
    "Frontal Cortex": "Frontal_cortex", "Frontal cortex": "Frontal_cortex",
    "Frontal lobe": "Frontal_cortex", "Prefrontal cortex": "Prefrontal_cortex",
    "Parietal Cortex": "Parietal_cortex", "Parietal cortex": "Parietal_cortex",
    "Parietal lobe": "Parietal_cortex",
    "Temporal Cortex": "Temporal_cortex", "Temporal cortex": "Temporal_cortex",
    "Temporal lobe": "Temporal_cortex",
    "Occipital Cortex": "Occipital_cortex", "Occipital cortex": "Occipital_cortex",
    "Occipital lobe": "Occipital_cortex",
    "Visual cortex": "Visual_cortex", "Auditory Cortex": "Auditory_cortex",
    "Sensorimotor Cortex": "Sensorimotor_cortex", "Sensorimotor cortex": "Sensorimotor_cortex",
    "Cingulate Cortex": "Cingulate_cortex", "Cingulate cortex": "Cingulate_cortex",
    "Insular lobe": "Insula",
    "Thalamus": "Thalamus", "Nucleus medial thalami": "Thalamus_medial_nucleus",
    "Hypothalamus": "Hypothalamus", "Hippocampus": "Hippocampus",
    "Amygdala": "Amygdala", "Corpus amygdaloideum": "Amygdala", "Septum": "Septum",
    "Basal Ganglia": "Basal_ganglia", "Caudate": "Caudate_nucleus",
    "Caudatum": "Caudate_nucleus", "Putamen": "Putamen",
    "Globus pallidus": "Pallidum", "Pallidum": "Pallidum",
    "Nucleus accumbens": "Nucleus_accumbens", "Substantia nigra": "Substantia_nigra",
    "Nucleus subthalamicus": "Nucleus_subthalamicus", "Nucleus ruber": "Nucleus_ruber",
    "Basal forebrain": "Basal_forebrain",
    "Corpus geniculatum laterale": "Corpus_geniculatum_laterale",
    "Corpus geniculatum mediale": "Corpus_geniculatum_mediale",
    "Colliculus superior": "Colliculus_superior",
    "Colliculus inferior": "Colliculus_inferior",
    "Superior colliculus": "Colliculus_superior",
    "Inferior colliculus": "Colliculus_inferior",
    "Cerebellum": "Cerebellum", "Cerebellar cortex": "Cerebellar_cortex",
    "Nucleus dentatus cerebelli": "Nucleus_dentatus_cerebelli", "Vermis": "Vermis",
    "Brain stem": "Brain_stem",
    "White Matter": "White_matter", "White matter": "White_matter",
    "Capsula interna": "Capsula_interna", "Centrum semiovale": "Centrum_semiovale",
    "Internal capsule": "Capsula_interna", "Corpus callosum": "Corpus_callosum",
    "Mammilary body": "Mammillary_body",
}
VOLUME_TERM = {
    "Neocortex": "Neocortex_Vol.mm3", "Cerebellum": "Cerebellum_Vol.mm3",
    "Thalamus": "Thalamus_Vol.mm3", "Hippocampus": "Hippocampus_Vol.mm3",
    "Amygdala": "Amygdala_Vol.mm3", "Pallidum": "Pallidum_Vol.mm3",
    "Nucleus_subthalamicus": "Nucleus_subthalamicus_Vol.mm3",
    "Corpus_geniculatum_laterale": "Corpus_geniculatum_laterale_Vol.mm3",
    "Whole_brain": "Total_brain_net_volume_Vol.mm3",
}
SPECIES_CANON = {
    "Homo": "Homo sapiens", "M mulatta": "Macaca mulatta", "M fascic": "Macaca fascicularis",
    "Macaca": "Macaca sp.", "Papio": "Papio anubis", "Saimiri": "Saimiri sciureus",
    "Canis": "Canis lupus familiaris", "Felis": "Felis catus", "Rattus": "Rattus norvegicus",
    "Mus": "Mus musculus", "Meriones": "Meriones unguiculatus",
    "Gerbil": "Meriones unguiculatus", "Ovis": "Ovis aries",
    "Capra": "Capra aegagrus hircus", "Sus": "Sus scrofa", "Equus": "Equus caballus",
    "Lepus": "Lepus sp.",
}
O2_UMOL_PER_ML = 44.64
# measure -> (unit, measure_class, scale applied to the printed value)
MEASURES = {
    "CMRgl": ("umol/100g/min", "cerebral_metabolic_rate", 1.0),
    "CMRO2": ("umol/100g/min", "cerebral_metabolic_rate", 1.0),
    "CBF":   ("mL/100g/min",   "cerebral_perfusion",      1.0),
    "Total_glucose_utilization": ("umol/min", "cerebral_absolute_rate", 1.0),
    "Total_O2_consumption":     ("mL/min",   "cerebral_absolute_rate", 1.0),
}
KARBOWSKI_SCALE_BY_MEASURE_UNIT = {
    ("CMRgl", "umol/g/min"): 100.0,
    ("CMRO2", "ml/g/min"): 100.0 * O2_UMOL_PER_ML,
    ("Total_glucose_utilization", "umol/min"): 1.0,
    ("Total_O2_consumption", "ml/min"): 1.0,
}
KAUF_GENUS_ASSIGNED = {"Homo", "Papio", "Canis", "Felis", "Rattus", "Mus", "Meriones",
                       "Gerbil", "Ovis", "Capra", "Sus", "Equus", "Lepus", "Saimiri"}
# A direct primary report always governs a reprint of that same work. Between
# the two secondary compilations, Kaufman remains the deterministic preference.
COMP_PRIORITY = {"Heiss_etal_2004": 0, "Kaufman__2004": 1, "Karbowski__2007": 2}

# Use the current shared species resolver and paper-scoped keys.
sys.path.insert(0, os.path.join(BASE, "_keys"))
from resolve_species import resolve_species  # noqa: E402
_RS = {}
def canon_species(printed, compilation):
    k = (compilation, printed)
    if k not in _RS:
        r = resolve_species([printed], compilation)
        a = r.accepted_name.iloc[0]
        _RS[k] = "" if a is None else a
    return _RS[k]

canon_region = lambda s: REGION_CANON.get(s, s)


def conscious_kauf(a):
    if a is None or str(a).strip() == "" or str(a).strip().lower() == "na":
        return "unknown"
    a = str(a).strip().lower()
    return "conscious" if (a.startswith("none") or "awake" in a) else "anesthetized"


def num(x):
    try:
        v = float(str(x).strip())
        return None if v != v else v
    except (TypeError, ValueError):
        return None


def rows_of(path):
    with open(path, newline="", encoding="utf-8-sig") as fh:
        return list(csv.DictReader(fh))


def load_catalog(path):
    rows = rows_of(path)
    by_raw = {r["ref_key"].strip(): r for r in rows}
    if len(by_raw) != len(rows):
        raise RuntimeError(f"Duplicate ref_key in {path}")
    return by_raw, rows


KAUF_CATALOG_PATH = os.path.join(
    BASE, "Kaufman__2004", "reference_tables",
    "Kaufman__2004_TablesA1-A14_references.csv",
)
KARB_CATALOG_PATH = os.path.join(
    BASE, "Karbowski__2007", "reference_tables",
    "Karbowski__2007_TablesS1-S23_references.csv",
)
KAUF_CATALOG, KAUF_CATALOG_ROWS = load_catalog(KAUF_CATALOG_PATH)
KARB_CATALOG, KARB_CATALOG_ROWS = load_catalog(KARB_CATALOG_PATH)

CATALOG_BY_SOURCE_ID = defaultdict(list)
for catalog_row in KAUF_CATALOG_ROWS + KARB_CATALOG_ROWS:
    if catalog_row["source_reference_id"]:
        CATALOG_BY_SOURCE_ID[catalog_row["source_reference_id"]].append(catalog_row)


def reference_lookup(compilation, raw_cell):
    """Resolve one table citation cell through its checked source-local catalog."""
    catalog = KAUF_CATALOG if compilation == "Kaufman__2004" else KARB_CATALOG
    raw_cell = (raw_cell or "").strip()
    parts = [raw_cell] if compilation == "Kaufman__2004" else [
        part.strip() for part in raw_cell.split(";") if part.strip()
    ]
    entries = [catalog.get(part) for part in parts]
    source_pairs = []
    seen_source_ids = set()
    primary_pairs = []
    seen_primary_ids = set()
    for entry in entries:
        if entry and entry["source_reference_id"]:
            source_id = entry["source_reference_id"]
            if source_id not in seen_source_ids:
                seen_source_ids.add(source_id)
                source_pairs.append((
                    source_id, entry["citation"], entry["reference_level"], entry["source_type"]
                ))
            primary_id = entry["primary_reference_id"]
            if primary_id and primary_id not in seen_primary_ids:
                seen_primary_ids.add(primary_id)
                primary_pairs.append((primary_id, entry["citation"]))
    cores = [e["reference_core"] for e in entries if e and e["reference_core"]]
    statuses = [e["resolution_status"] if e else "missing_catalog_alias" for e in entries]
    return {
        "source_ids": [source_id for source_id, _, _, _ in source_pairs],
        "source_citations": [citation for _, citation, _, _ in source_pairs],
        "source_levels": [level for _, _, level, _ in source_pairs],
        "source_types": [source_type for _, _, _, source_type in source_pairs],
        "ids": [primary_id for primary_id, _ in primary_pairs],
        "citations": [citation for _, citation in primary_pairs],
        "cores": cores,
        "status": "; ".join(dict.fromkeys(statuses)) if statuses else "no_reference",
        "reference_parts": parts,
        "all_reference_parts_resolved": bool(parts) and all(
            entry is not None and bool(entry["source_reference_id"])
            for entry in entries
        ),
        "all_reference_parts_primary": bool(parts) and all(
            entry is not None
            and entry["reference_level"] == "primary"
            and bool(entry["primary_reference_id"])
            for entry in entries
        ),
    }


def citation_for(source_id):
    rows = CATALOG_BY_SOURCE_ID.get(source_id, [])
    # Karbowski's typeset bibliography is cleaner than the OCR bibliography in
    # the Kaufman dissertation. Both source renderings remain in the registry.
    rows = sorted(rows, key=lambda r: (r["evidence_file"].startswith("Kaufman"), -len(r["citation"])))
    return rows[0]["citation"] if rows else ""


def reference_level_for(source_id):
    rows = CATALOG_BY_SOURCE_ID.get(source_id, [])
    levels = {row["reference_level"] for row in rows}
    if len(levels) > 1:
        raise RuntimeError(f"Conflicting reference levels for {source_id}: {sorted(levels)}")
    return next(iter(levels), "")


def source_type_for(source_id):
    rows = CATALOG_BY_SOURCE_ID.get(source_id, [])
    source_types = {row["source_type"] for row in rows}
    if len(source_types) > 1:
        raise RuntimeError(f"Conflicting source types for {source_id}: {sorted(source_types)}")
    return next(iter(source_types), "")


# Corrections to eleven rows whose PDF-to-table extraction shifted Reference,
# n, CMRgl and SD across columns.  Keys use the 1-based data-row number in the
# analysis CSV (header excluded); the frozen snapshots remain untouched.
KAUF_SOKOLOFF_REPAIRS = {
    ("TableA1", 109): (84.5, 2.5, "Sokoloff"),
    ("TableA2", 69): (79.0, 1.0, "Sokoloff"),
    ("TableA3", 111): (104.0, 2.0, "Sokoloff"),
    ("TableA4", 77): (61.0, 2.0, "Sokoloff"),
    ("TableA5", 73): (36.0, 2.0, "Sokoloff"),
    ("TableA6", 130): (124.4, 3.6, "Sokoloff"),
    ("TableA7", 109): (112.0, 4.0, "Sokoloff"),
    ("TableA8", 97): (110.0, 3.0, "Sokoloff"),
    ("TableA10", 39): (163.0, 4.0, "Sokoloff"),
    ("TableA11", 103): (113.0, 4.0, "Sokoloff"),
    ("TableA12", 64): (124.0, 3.0, "PET"),
}
KAUF_SOKOLOFF_PRINTED = {
    ("TableA1", 109): ("84.5", "2.5"),
    ("TableA2", 69): ("79.0", "1.0"),
    ("TableA3", 111): ("104.0", "2.0"),
    ("TableA4", 77): ("61.0", "2.0"),
    ("TableA5", 73): ("36.0", "2.0"),
    ("TableA6", 130): ("124.4", "3.6"),
    ("TableA7", 109): ("112.0", "4.0"),
    ("TableA8", 97): ("110.0", "3.0"),
    ("TableA10", 39): ("163.0", "4.0"),
    ("TableA11", 103): ("113.0", "4.0"),
    ("TableA12", 64): ("124.00", "3.00"),
}
KAUF_CONDITION_REPAIRS = {
    ("TableA7", 101): (6, "‘ none", "(Moore et al., 2000)", "Sokoloff", 79.0, 9.7),
    ("TableA10", 5): (6, "6 none", "(Schwartzman et al., 1988)", "Sokoloff", 70.3, 12.2),
    ("TableA10", 6): (3, "3 none", "(Choki et al., 1984)", "Sokoloff", 79.0, 12.0),
}
KAUF_EXTRACTION_REPAIRS = {
    ("TableA1", 60): dict(
        snapshot_row=60, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="Sevoflurane", mode_raw="MicTospheres",
        anesthesia="Sevoflurane", mode="Microspheres",
        snapshot_measurements={"BloodFlow": "86.0", "BloodFlow_SD": "7.3"},
        printed={"CBF": ("86.0", "7.3")},
        evidence="dissertation PDF physical p. 118 (printed p. 110)",
    ),
    ("TableA1", 120): dict(
        snapshot_row=120, species="Mus", reference="(Zocchi et al., 2001)", n=4,
        anesthesia_raw="none", mode_raw="Sokoloff", anesthesia="none", mode="Sokoloff",
        snapshot_measurements={"Glucose": "73", "Glucose_SD": "4", "Oxygen": "5.2"},
        printed={"CMRgl": ("73.4", "5.2")},
        evidence="dissertation PDF physical p. 120 (printed p. 112)",
    ),
    ("TableA3", 52): dict(
        snapshot_row=52, species="M mulatta", reference="inlund et al., 1997)", n=4,
        anesthesia_raw="Ketamine, N 20", mode_raw="PET",
        anesthesia="Ketamine, N 20", mode="PET",
        printed={"CMRO2": ("245.0", "34.0"), "CBF": ("70.5", "15.0")},
        evidence="dissertation PDF physical p. 127 (printed p. 119)",
    ),
    ("TableA3", 59): dict(
        snapshot_row=59, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="none 76.8 4.5", mode_raw="", anesthesia="none", mode="",
        printed={"CBF": ("76.8", "4.5")},
        evidence="dissertation PDF physical p. 127 (printed p. 119)",
    ),
    ("TableA3", 60): dict(
        snapshot_row=60, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="Sevoflurane 46.2 3.0", mode_raw="",
        anesthesia="Sevoflurane", mode="", printed={"CBF": ("46.2", "3.0")},
        evidence="dissertation PDF physical p. 127 (printed p. 119)",
    ),
    ("TableA3", 61): dict(
        snapshot_row=61, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="Sevoflurane 59.0 5.5", mode_raw="",
        anesthesia="Sevoflurane", mode="", printed={"CBF": ("59.0", "5.5")},
        evidence="dissertation PDF physical p. 127 (printed p. 119)",
    ),
    ("TableA3", 69): dict(
        snapshot_row=69, species="Meriones", reference="(Mies et al., 1990)", n=4,
        anesthesia_raw="Halothane", mode_raw="Sokoloff",
        anesthesia="Halothane", mode="Sokoloff", printed={"CBF": ("139.5", "22.0")},
        evidence="dissertation PDF physical p. 127 (printed p. 119)",
    ),
    ("TableA6", 67): dict(
        snapshot_row=67, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="342.0 20.1 108.2 6.3", mode_raw="", anesthesia="", mode="",
        printed={"CMRO2": ("342.0", "20.1"), "CBF": ("108.2", "6.3")},
        evidence="dissertation PDF physical p. 140 (printed p. 132)",
    ),
    ("TableA6", 68): dict(
        snapshot_row=68, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="Sevoflurane 171.9 7.6 68.4 3.5", mode_raw="",
        anesthesia="Sevoflurane", mode="",
        printed={"CMRO2": ("171.9", "7.6"), "CBF": ("68.4", "3.5")},
        evidence="dissertation PDF physical p. 140 (printed p. 132)",
    ),
    ("TableA6", 69): dict(
        snapshot_row=69, species="Sus", reference="(Manohar, 1986)", n=6,
        anesthesia_raw="Sevoflurane 162.5 19.2 77.7 8.7", mode_raw="",
        anesthesia="Sevoflurane", mode="",
        printed={"CMRO2": ("162.5", "19.2"), "CBF": ("77.7", "8.7")},
        evidence="dissertation PDF physical p. 140 (printed p. 132)",
    ),
    ("TableA6", 71): dict(
        snapshot_row=71, species="Lepus", reference="(Drummond et al., 1986)", n=12,
        anesthesia_raw="Morphine 55.0 12.0", mode_raw="", anesthesia="Morphine", mode="",
        printed={"CBF": ("55.0", "12.0")},
        evidence="dissertation PDF physical p. 140 (printed p. 132)",
    ),
    ("TableA6", 72): dict(
        snapshot_row=72, species="Lepus", reference="(Kaieda et al., 1989)", n=8,
        anesthesia_raw="Halothane 69.0 23.0", mode_raw="", anesthesia="Halothane", mode="",
        printed={"CBF": ("69.0", "23.0")},
        evidence="dissertation PDF physical p. 140 (printed p. 132)",
    ),
    ("TableA6", 73): dict(
        snapshot_row=73, species="Lepus", reference="(Kaieda et al., 1989)", n=8,
        anesthesia_raw="Isoflurane 41.0 16.0", mode_raw="",
        anesthesia="Isoflurane", mode="", printed={"CBF": ("41.0", "16.0")},
        evidence="dissertation PDF physical p. 140 (printed p. 132)",
    ),
    ("TableA11", 75): dict(
        snapshot_row=75, species="Rattus", reference="(Dam et al., 1990)", n=5,
        anesthesia_raw="none Sokoldff 92.0 17.9", mode_raw="",
        anesthesia="none", mode="Sokoloff", printed={"CMRgl": ("92.0", "17.9")},
        evidence="dissertation PDF physical p. 155 (printed p. 147)",
    ),
    ("TableA11", 99): dict(
        snapshot_row=99, species="Rattus",
        reference="(Poindessous-Jazat et al., 1998)", n=5,
        snapshot_n="", anesthesia_raw="none", mode_raw="Sokoloff",
        anesthesia="none", mode="Sokoloff",
        snapshot_measurements={"Glucose": "83.3", "Glucose_SD": "10.0"},
        printed={"CMRgl": ("83.3", "10.0")},
        evidence="dissertation PDF physical p. 156 (printed p. 148)",
    ),
    ("TableA13", 13): dict(
        snapshot_row=13, species="Homo", reference="(Langsjo et al., 2003)", n=10,
        anesthesia_raw="none", mode_raw="PET", anesthesia="none", mode="PET",
        snapshot_measurements={"Glucose": "27.2", "Glucose_SD": "185.0"},
        printed={"CMRO2": ("185.0", "27.2")},
        evidence="dissertation PDF physical p. 159 (printed p. 151)",
    ),
    ("TableA13", 14): dict(
        snapshot_row=14, species="Homo", reference="(Perlmutter et al., 1987)", n=32,
        anesthesia_raw="none", mode_raw="PET", anesthesia="none", mode="PET",
        snapshot_measurements={"Glucose": "31.9", "Glucose_SD": "111.6"},
        printed={"CMRO2": ("111.6", "31.9")},
        evidence="dissertation PDF physical p. 159 (printed p. 151)",
    ),
    ("TableA13", 15): dict(
        snapshot_row=15, species="Homo", reference="(Sasaki et al., 1986)", n=7,
        anesthesia_raw="none", mode_raw="PET", anesthesia="none", mode="PET",
        snapshot_measurements={"Glucose": "21.1", "Glucose_SD": "155.8"},
        printed={"CMRO2": ("155.8", "21.1")},
        evidence="dissertation PDF physical p. 159 (printed p. 151)",
    ),
    # Table A14 cleaned rows are one lower than their frozen rows because the
    # correction overlay removes bibliography-continuation row 102.
    ("TableA14", 84): dict(
        snapshot_row=84, species="Canis", reference="(Zimmer, 1975)", n=13,
        anesthesia_raw="& Ethylene urea", mode_raw="Kety-Schmidt",
        anesthesia="Allobarbital, Urethan, & Ethylene urea", mode="Kety-Schmidt",
        snapshot_measurements={
            "Glucose": "27.67", "Glucose_SD": "3.99",
            "Oxygen": "167.40", "Oxygen_SD": "53.00",
            "BloodFlow": "45.60", "BloodFlow_SD": "7.20",
        },
        printed={
            "CMRgl": ("27.67", "3.99"), "CMRO2": ("167.40", "53.00"),
            "CBF": ("45.60", "7.20"),
        },
        evidence="dissertation PDF physical p. 164 (printed p. 156)",
    ),
    ("TableA14", 110): dict(
        snapshot_row=111, species="Canis", reference="(Boarini et al., 1984)", n=10,
        anesthesia_raw="N 20", mode_raw="Kety-Schmidt",
        anesthesia="N 20", mode="Kety-Schmidt",
        snapshot_measurements={
            "Oxygen": "218.75", "Oxygen_SD": "20",
            "BloodFlow": "57.00", "BloodFlow_SD": "4.00",
        },
        printed={"CMRO2": ("218.75", ".20"), "CBF": ("57.00", "4.00")},
        affected_measures={"CMRO2"},
        evidence="dissertation PDF physical p. 165 (printed p. 157)",
    ),
    ("TableA14", 194): dict(
        snapshot_row=195, species="Capra", reference="(Schwedler et al., 1982)", n=17,
        anesthesia_raw="none Probe 192.40 16.10 77.00 7.00", mode_raw="",
        anesthesia="none", mode="Probe",
        printed={"CMRO2": ("192.40", "16.10"), "CBF": ("77.00", "7.00")},
        evidence="dissertation PDF physical p. 168 (printed p. 160)",
    ),
    ("TableA14", 195): dict(
        snapshot_row=196, species="Capra", reference="(Stanley and Chemiack, 1976)", n=6,
        anesthesia_raw="none Probe 154.46 4.50", mode_raw="",
        anesthesia="none", mode="Probe", printed={"CMRO2": ("154.46", "4.50")},
        evidence="dissertation PDF physical p. 168 (printed p. 160)",
    ),
}

KAUF_MEASURE_FIELDS = {
    "CMRgl": ("CMRgl_umol_100g_min", "CMRgl_SD", "Glucose", "Glucose_SD"),
    "CMRO2": ("CMRO2_umol_100g_min", "CMRO2_SD", "Oxygen", "Oxygen_SD"),
    "CBF": ("CBF_ml_100g_min", "CBF_SD", "BloodFlow", "BloodFlow_SD"),
}
KAUF_PRIMARY_SPECIES_OVERRIDES = {
    ("kennedy_1978", "M fascic"): "Macaca mulatta",
    ("passero_1981", "Lepus"): "Oryctolagus cuniculus",
}
KARB_PRIMARY_CONDITION_OVERRIDES = {
    "stingele_1996": {
        "condition": "anesthetized",
        "evidence": (
            "Primary experiment used fluorocarbon-perfused cats; Kaufman Table A14 "
            "identifies the matching CMRO2 observation as Fentanyl-anesthetized."
        ),
    },
    "nakanishi_1997": {
        "condition": "anesthetized",
        "evidence": (
            "Karbowski's 0.061 mL/g/min baseline matches Kaufman Table A14's "
            "Halothane-anesthetized Nakanishi cohort."
        ),
    },
    "sahlin_1987": {
        "condition": "anesthetized",
        "evidence": (
            "Primary experimental-SAH baboon study and Kaufman Table A14 identify "
            "the observation as obtained under N2O."
        ),
    },
    "meguro_1999": {
        "condition": "anesthetized",
        "evidence": (
            "Primary PET experiment and matching Kaufman rows identify the baboons "
            "as phencyclidine-anesthetized."
        ),
    },
    "haier_1992": {
        "condition": "awake_task_active",
        "evidence": (
            "The four Karbowski regional values reproduce Haier et al. 1992 Table I's "
            "naive-Tetris condition; subjects played throughout FDG uptake rather than "
            "resting (primary PDF Methods and Table I, pp. 1-4)."
        ),
    },
    "lydic_1991": {
        "condition": "condition_arm_unresolved",
        "evidence": (
            "Primary abstract reports quiet-wakefulness and REM-sleep arms in intact "
            "unanesthetized cats, but the available source materials do not expose the "
            "numeric table needed to identify which arm Karbowski copied (PMID 2013648; "
            "DOI 10.1002/cne.903040402)."
        ),
    },
}
KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE = {
    "maquet_1992": (
        "Primary-source arm verified: the Karbowski values reproduce the wakefulness "
        "control column of Maquet et al. 1992 Table I, not the stage-2-sleep column."
    ),
    "schwartzman_1986": (
        "Primary-source arm verified: the Karbowski values reproduce Schwartzman et al. "
        "1986 Tables II-III awake controls, sitting on a stationary treadmill and kept "
        "from sleeping, rather than the walking arm (primary scan leaves 118-122)."
    ),
    "passero_1981": (
        "Primary-source arm verified as the normal conscious-control rabbits, distinct "
        "from hypnotized animals (PMID 7219882; DOI 10.1016/0304-3940(81)90228-7); "
        "Kaufman independently attributes n=5/anesthesia-none rows to Passero: four "
        "overlapping cells agree within printed precision, while the broader "
        "neocortex/cerebral-cortex mapping differs."
    ),
}


def joined(values, sep="; "):
    return sep.join(sorted(dict.fromkeys(v for v in values if v)))


def conscious_status_for_condition(condition_group):
    return {
        "anesthetized": "anesthetized",
        "awake_task_active": "conscious",
        "nonanesthetized_unspecified_arm": "not_reported",
        "mixed": "mixed",
    }.get(condition_group, "not_reported")


# ---- 1. load, retain source roles, and standardise values -------------------
U = []

kauf_files = sorted(p for p in glob.glob(os.path.join(BASE, "Kaufman__2004", "Kaufman__2004_TableA*.csv"))
                    if re.search(r"TableA([1-9]|1[0-4])\.csv$", p))
for f in kauf_files:
    table = re.search(r"TableA[0-9]+", os.path.basename(f)).group(0)
    snapshot_file = f.replace(".csv", "_snapshot.csv")
    snapshot_rows = rows_of(snapshot_file)
    for source_row, r in enumerate(rows_of(f), 1):
        # Table A14 snapshot row 102 is a citation continuation fragment, so
        # cleaned rows from 102 onward map one row later in the frozen capture.
        source_snapshot_row = source_row + (1 if table == "TableA14" and source_row >= 102 else 0)
        snapshot = snapshot_rows[source_snapshot_row - 1]
        if (r.get("Species") or "").strip() != (snapshot.get("Species") or "").strip():
            raise RuntimeError(
                f"Kaufman cleaned/snapshot row alignment drifted at {table}:{source_row}"
            )
        printed = (r.get("Species") or "").strip()
        if not printed:
            continue
        genus = ("Macaca" if printed in ("M mulatta", "M fascic")
                 else "Meriones" if printed == "Gerbil" else printed.split()[0])
        species = canon_species(printed, "Kaufman__2004")
        reg_raw = (r.get("Region") or "").strip()
        ref_raw = r.get("Reference") or ""
        ref = reference_lookup("Kaufman__2004", ref_raw)
        if len(ref["ids"]) == 1:
            species = KAUF_PRIMARY_SPECIES_OVERRIDES.get(
                (ref["ids"][0], printed), species
            )
        repair = KAUF_SOKOLOFF_REPAIRS.get((table, source_row))
        extraction_repair = KAUF_EXTRACTION_REPAIRS.get((table, source_row))
        if repair and extraction_repair:
            raise RuntimeError(f"Overlapping Kaufman repairs at {table}:{source_row}")
        if repair:
            if ref_raw.strip() not in {"(", "(Sokoloff et al., 1977)"}:
                raise RuntimeError(
                    f"Unexpected citation at checked correction row {table}:{source_row}: {ref_raw!r}"
                )
            if ref_raw.strip() == "(":
                # Defensive fallback for an analysis CSV that has not yet been
                # regenerated from the correction overlay.
                ref_raw = "(Sokoloff et al., 1977)"
                ref = reference_lookup("Kaufman__2004", ref_raw)
                source_values = {
                    "CMRgl_umol_100g_min": "%g" % repair[0],
                    "CMRgl_SD": "%g" % repair[1],
                    "CMRO2_umol_100g_min": None, "CMRO2_SD": None,
                    "CBF_ml_100g_min": None, "CBF_SD": None,
                }
                n_value, anesthesia, mode = 10, "none", repair[2]
                printed_values = source_values
            else:
                # The checked overlay has already corrected the analysis CSV.
                # Retain its strings verbatim so Value_raw/SD_raw do not gain
                # artificial decimal places during a float round trip.
                source_values = r
                n_value = num(r.get("n"))
                anesthesia = r.get("Anesthesia")
                mode = r.get("Mode") or ""
                corrected_value = num(r.get("CMRgl_umol_100g_min"))
                corrected_sd = num(r.get("CMRgl_SD"))
                if (
                    corrected_value is None
                    or not math.isclose(corrected_value, repair[0], rel_tol=0, abs_tol=1e-9)
                    or corrected_sd is None
                    or not math.isclose(corrected_sd, repair[1], rel_tol=0, abs_tol=1e-9)
                    or n_value != 10
                    or conscious_kauf(anesthesia) != "conscious"
                    or mode != repair[2]
                ):
                    raise RuntimeError(
                        f"Checked Sokoloff correction drifted at {table}:{source_row}"
                    )
                printed_values = source_values
            printed_values = dict(printed_values)
            (printed_values["CMRgl_umol_100g_min"],
             printed_values["CMRgl_SD"]) = KAUF_SOKOLOFF_PRINTED[(table, source_row)]
            correction = (
                "Repaired column-shifted Sokoloff et al. (1977) row from the "
                "dissertation table page; frozen snapshot unchanged."
            )
        else:
            source_values = r
            printed_values = snapshot
            n_value = num(r.get("n"))
            anesthesia = r.get("Anesthesia")
            mode = r.get("Mode") or ""
            correction = ""
        condition_repair = KAUF_CONDITION_REPAIRS.get((table, source_row))
        if condition_repair:
            (expected_n, expected_anesthesia_raw, expected_reference, expected_mode,
             expected_value, expected_sd) = condition_repair
            if (
                (snapshot.get("n") or "").strip() not in {"", str(expected_n)}
                or (snapshot.get("Anesthesia") or "").strip() != expected_anesthesia_raw
                or (snapshot.get("Reference") or "").strip() != expected_reference
                or (snapshot.get("Mode") or "").strip() != expected_mode
                or not math.isclose(num(snapshot.get("Glucose")) or math.nan,
                                    expected_value, rel_tol=0, abs_tol=1e-9)
                or not math.isclose(num(snapshot.get("Glucose_SD")) or math.nan,
                                    expected_sd, rel_tol=0, abs_tol=1e-9)
                or num(r.get("n")) != expected_n
                or conscious_kauf(r.get("Anesthesia")) != "conscious"
                or (r.get("Mode") or "").strip() != expected_mode
            ):
                raise RuntimeError(
                    f"Checked Kaufman condition-token correction drifted at {table}:{source_row}"
                )
            correction = (
                f"Repaired OCR-shifted n/anesthesia token {expected_anesthesia_raw!r} "
                "against the dissertation table page; frozen snapshot unchanged."
            )
        if extraction_repair:
            expected_snapshot = {
                "Species": extraction_repair["species"],
                "Reference": extraction_repair["reference"],
                "n": extraction_repair.get("snapshot_n", str(extraction_repair["n"])),
                "Anesthesia": extraction_repair["anesthesia_raw"],
                "Mode": extraction_repair["mode_raw"],
            }
            expected_snapshot.update({
                field: extraction_repair.get("snapshot_measurements", {}).get(field, "")
                for fields in KAUF_MEASURE_FIELDS.values() for field in fields[2:]
            })
            if source_snapshot_row != extraction_repair["snapshot_row"] or any(
                (snapshot.get(field) or "").strip() != expected
                for field, expected in expected_snapshot.items()
            ):
                raise RuntimeError(
                    f"Frozen Kaufman extraction-repair row drifted at {table}:{source_row}"
                )
            if (
                (r.get("Reference") or "").strip() != extraction_repair["reference"]
                or num(r.get("n")) != extraction_repair["n"]
                or (r.get("Anesthesia") or "").strip() != extraction_repair["anesthesia"]
                or (r.get("Mode") or "").strip() != extraction_repair["mode"]
            ):
                raise RuntimeError(
                    f"Corrected Kaufman extraction-repair metadata drifted at {table}:{source_row}"
                )
            for repair_measure, fields in KAUF_MEASURE_FIELDS.items():
                value_field, sd_field, _, _ = fields
                expected_pair = extraction_repair["printed"].get(repair_measure)
                observed_pair = (num(r.get(value_field)), num(r.get(sd_field)))
                if expected_pair is None:
                    if observed_pair != (None, None):
                        raise RuntimeError(
                            f"Unexpected corrected value at {table}:{source_row}:{repair_measure}"
                        )
                elif any(
                    observed is None
                    or not math.isclose(observed, float(expected), rel_tol=0, abs_tol=1e-9)
                    for observed, expected in zip(observed_pair, expected_pair)
                ):
                    raise RuntimeError(
                        f"Corrected Kaufman value drifted at {table}:{source_row}:{repair_measure}"
                    )
            printed_values = dict(r)
            for repair_measure, printed_pair in extraction_repair["printed"].items():
                value_field, sd_field, _, _ = KAUF_MEASURE_FIELDS[repair_measure]
                printed_values[value_field], printed_values[sd_field] = printed_pair
            correction = (
                "Repaired PDF-extraction omitted/collapsed/misaligned measurement, "
                f"sample-size, or method fields against {extraction_repair['evidence']}; "
                "frozen snapshot unchanged."
            )
        for col, sd_col, printed_col, printed_sd_col, meas, raw_unit in (
            ("CMRgl_umol_100g_min", "CMRgl_SD", "Glucose", "Glucose_SD",
             "CMRgl", "umol/100g/min"),
            ("CMRO2_umol_100g_min", "CMRO2_SD", "Oxygen", "Oxygen_SD",
             "CMRO2", "umol/100g/min"),
            ("CBF_ml_100g_min", "CBF_SD", "BloodFlow", "BloodFlow_SD",
             "CBF", "mL/100g/min"),
        ):
            value_source = source_values.get(col)
            sd_source = source_values.get(sd_col)
            v = num(value_source)
            if v is None:
                continue
            value_raw = printed_values.get(
                col if repair or extraction_repair else printed_col
            )
            sd_raw = printed_values.get(
                sd_col if repair or extraction_repair else printed_sd_col
            )
            unit, mclass, _ = MEASURES[meas]
            conscious = conscious_kauf(anesthesia)
            condition_group = {
                "conscious": "nonanesthetized_unspecified_arm",
                "anesthetized": "anesthetized",
                "unknown": "unknown",
            }[conscious]
            eligible = (
                len(ref["ids"]) == 1
                and len(ref["source_ids"]) == 1
                and ref["all_reference_parts_resolved"]
                and ref["all_reference_parts_primary"]
                and condition_group == "nonanesthetized_unspecified_arm"
            )
            reasons = []
            if not ref["all_reference_parts_resolved"]:
                reasons.append("unresolved_or_non_singleton_reference")
            elif not ref["all_reference_parts_primary"]:
                reasons.append("secondary_source_without_primary_lineage")
            elif len(ref["source_ids"]) != 1 or len(ref["ids"]) != 1:
                reasons.append("unresolved_or_non_singleton_reference")
            if condition_group != "nonanesthetized_unspecified_arm":
                reasons.append(
                    "explicitly_anesthetized"
                    if conscious == "anesthetized" else "condition_outside_primary_pool"
                )
            primary_id = ref["ids"][0] if len(ref["ids"]) == 1 else ""
            role = (
                "self_primary_reported_in_compilation"
                if primary_id == "kaufman_2004_present_study"
                else "reported_via_secondary_source"
                if ref["source_levels"] == ["secondary"]
                else "reported_via_secondary_compilation"
            )
            measure_correction = correction
            if extraction_repair and meas not in extraction_repair.get(
                "affected_measures", set(extraction_repair["printed"])
            ):
                measure_correction = ""
            U.append(dict(
                record_id=f"Kaufman__2004:{table}:{source_row}:{meas}",
                Compilation="Kaufman__2004", compilation_role="secondary_compilation",
                Species_printed=printed, Species=species, genus=genus,
                Region_raw=reg_raw, Subregion_raw=reg_raw, Region=canon_region(reg_raw),
                Measure=meas, measure_class=mclass, Value_raw=value_raw, SD_raw=sd_raw,
                Units_raw=raw_unit, Value=v, SD=num(sd_source), n=n_value,
                n_areas=None, Units=unit, conscious=conscious, Anesthesia_raw=anesthesia or "",
                condition_group=condition_group,
                condition_evidence=(
                    "Kaufman table row Anesthesia field only; a none/awake token does not "
                    "resolve control, treatment, disease, task, age, or temperature arm."
                ),
                Mode=mode, primary_reference_raw=ref_raw, ref_raw=ref_raw,
                source_reference_ids=ref["source_ids"],
                source_references=ref["source_citations"],
                source_reference_levels=ref["source_levels"],
                source_reference_types=ref["source_types"],
                primary_reference_ids=ref["ids"], primary_references=ref["citations"],
                reference_core="; ".join(ref["cores"]), reference_resolution_status=ref["status"],
                source_granularity=(
                    "single_primary_reference"
                    if ref["all_reference_parts_primary"] and len(ref["ids"]) == 1
                    else "single_secondary_reference"
                    if ref["source_levels"] == ["secondary"]
                    else "unresolved_reference"
                ),
                derivation_role=role, include_in_primary_merge=eligible,
                exclusion_reason="; ".join(reasons), source_correction=measure_correction,
                reference_roles=["reported_data_source"] if ref["source_ids"] else [],
                Table=table, source_row=source_row, source_snapshot_row=source_snapshot_row,
            ))

karb_files = sorted(glob.glob(os.path.join(BASE, "Karbowski__2007", "Karbowski__2007_TableS*.csv")))
karb_files = [p for p in karb_files if re.search(r"TableS[0-9]+\.csv$", p)]
for f in karb_files:
    table = re.search(r"TableS[0-9]+", os.path.basename(f)).group(0)
    for source_row, r in enumerate(rows_of(f), 1):
        source_snapshot_row = int(r.get("source_snapshot_row") or 0)
        if source_snapshot_row < 1:
            raise RuntimeError(f"Missing Karbowski snapshot locator at {table}:{source_row}")
        meas = (r.get("measure") or "").strip()
        if meas not in MEASURES:
            continue
        v = num(r.get("value"))
        if v is None:
            continue
        unit, mclass, _ = MEASURES[meas]
        raw_unit = (r.get("units") or "").strip()
        scale_key = (meas, raw_unit.lower())
        if scale_key not in KARBOWSKI_SCALE_BY_MEASURE_UNIT:
            raise RuntimeError(
                f"Unexpected Karbowski measure/unit pair at {table}:{source_row}: {scale_key!r}"
            )
        scale = KARBOWSKI_SCALE_BY_MEASURE_UNIT[scale_key]
        sd = num(r.get("sd"))
        species = canon_species(re.sub(r"^average\s+", "", (r.get("species_printed") or "").strip()), "Karbowski__2007")
        reg_raw = (r.get("structure") or "").strip()
        subreg_raw = (r.get("subregion") or "").strip()
        region_basis = subreg_raw if subreg_raw and subreg_raw != reg_raw else reg_raw
        ref_raw = r.get("reference") or ""
        is_average = str(r.get("is_average", "")).strip().upper() == "TRUE"
        if is_average or table == "TableS11":
            ref = {
                "source_ids": [], "source_citations": [], "source_levels": [],
                "source_types": [], "ids": [], "citations": [], "cores": [],
                "status": "compiler_average_no_direct_row_citation",
                "all_reference_parts_resolved": False,
                "all_reference_parts_primary": False,
            }
        else:
            ref = reference_lookup("Karbowski__2007", ref_raw)

        if is_average:
            derivation_role = "compiler_average"
            granularity = "derived_summary"
            reason = "compiler_average"
        elif table == "TableS11":
            derivation_role = "derived_cross_area_summary"
            granularity = "derived_summary"
            reason = "TableS11_cross_source_average_without_row_citation"
        elif meas.startswith("Total_"):
            derivation_role = "compiler_derived_total"
            granularity = "derived_value"
            reason = "compiler_derived_total"
        elif "estim" in ref_raw.lower():
            derivation_role = "compiler_estimate"
            granularity = "derived_value"
            reason = "compiler_estimate"
            # Karbowski states that Quelven ratios were calibrated to the
            # Bouilleret absolute value.  Preserve both sources in the lineage.
            if (
                "quelven_2004" in ref["source_ids"]
                and "bouilleret_2000" not in ref["source_ids"]
            ):
                ref["source_ids"].append("bouilleret_2000")
                ref["source_citations"].append(citation_for("bouilleret_2000"))
                ref["source_levels"].append(reference_level_for("bouilleret_2000"))
                ref["source_types"].append(source_type_for("bouilleret_2000"))
                ref["ids"].append("bouilleret_2000")
                ref["citations"].append(citation_for("bouilleret_2000"))
        elif len(ref["source_ids"]) > 1:
            derivation_role = "compound_source_summary"
            granularity = "compound_source_references"
            reason = "one_value_cites_multiple_source_references"
        elif len(ref["source_ids"]) != 1 or not ref["all_reference_parts_resolved"]:
            derivation_role = "reported_via_secondary_compilation"
            granularity = "unresolved_reference"
            reason = "unresolved_reference"
        elif not ref["all_reference_parts_primary"]:
            derivation_role = "reported_via_secondary_source"
            granularity = "single_secondary_reference"
            reason = "secondary_source_without_primary_lineage"
        else:
            derivation_role = "reported_via_secondary_compilation"
            granularity = "single_primary_reference"
            reason = ""
        condition_override_ids = [
            source_id for source_id in ref["source_ids"]
            if source_id in KARB_PRIMARY_CONDITION_OVERRIDES
        ]
        if condition_override_ids:
            condition_states = {
                KARB_PRIMARY_CONDITION_OVERRIDES[source_id]["condition"]
                for source_id in condition_override_ids
            }
            condition_group = next(iter(condition_states)) if (
                len(condition_states) == 1
                and set(ref["source_ids"]).issubset(KARB_PRIMARY_CONDITION_OVERRIDES)
            ) else "mixed"
            conscious = conscious_status_for_condition(condition_group)
            condition_evidence = " ".join(
                KARB_PRIMARY_CONDITION_OVERRIDES[source_id]["evidence"]
                for source_id in condition_override_ids
            )
            if not reason:
                reason = "primary_source_condition_conflicts_with_compilation_claim"
        elif ref["source_ids"] and set(ref["source_ids"]).issubset(
                KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE):
            conscious = "conscious"
            condition_group = "nonanesthetized_unspecified_arm"
            condition_evidence = " ".join(
                KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE[source_id]
                for source_id in ref["source_ids"]
            )
        else:
            conscious = "not_reported"
            condition_group = "nonanesthetized_unspecified_arm"
            condition_evidence = (
                "Secondary-compilation claim only: Karbowski 2007 main-paper Methods, "
                "PDF p.8, describes unanesthetized adult animals at resting conditions; "
                "it does not establish awake state for every cited primary experiment."
            )
        eligible = not reason
        roles = []
        for source_id in ref["source_ids"]:
            if derivation_role == "compiler_estimate":
                roles.append("ratio_source" if source_id == "quelven_2004" else "calibration_source")
            elif derivation_role.startswith("compiler_"):
                roles.append("upstream_source")
            else:
                roles.append("reported_data_source")
        U.append(dict(
            record_id=f"Karbowski__2007:{table}:{source_row}:{meas}",
            Compilation="Karbowski__2007", compilation_role="secondary_compilation",
            Species_printed=(r.get("species_printed") or "").strip(), Species=species,
            genus=species.split()[0] if species else "", Region_raw=reg_raw,
            Subregion_raw=subreg_raw, Region=canon_region(region_basis), Measure=meas,
            measure_class=mclass, Value_raw=(r.get("value_printed") or "").strip(),
            SD_raw=(r.get("sd_printed") or "").strip(), Units_raw=raw_unit, Value=v * scale,
            SD=None if sd is None else sd * scale, n=None, n_areas=num(r.get("n_areas")),
            Units=unit, conscious=conscious, Anesthesia_raw="", Mode="",
            condition_group=condition_group,
            condition_evidence=condition_evidence,
            primary_reference_raw=ref_raw, ref_raw=ref_raw,
            source_reference_ids=ref["source_ids"],
            source_references=ref["source_citations"],
            source_reference_levels=ref["source_levels"],
            source_reference_types=ref["source_types"],
            primary_reference_ids=ref["ids"], primary_references=ref["citations"],
            reference_core="; ".join(ref["cores"]), reference_resolution_status=ref["status"],
            source_granularity=granularity, derivation_role=derivation_role,
            include_in_primary_merge=eligible, exclusion_reason=reason, source_correction="",
            reference_roles=roles, Table=table, source_row=source_row,
            source_snapshot_row=source_snapshot_row,
        ))


def inherit_component_lineage(target, candidates):
    """Attach an ordered union of upstream cited works to a derived row."""
    pairs = []
    seen = set()
    for component in sorted(candidates, key=lambda x: (int(x["Table"][6:]), x["source_row"])):
        for source_id, citation, level, source_type in zip(
                component["source_reference_ids"], component["source_references"],
                component["source_reference_levels"], component["source_reference_types"]):
            if source_id not in seen:
                seen.add(source_id)
                pairs.append((source_id, citation or citation_for(source_id), level, source_type))
    if not pairs:
        raise RuntimeError(f"No component lineage found for {target['record_id']}")
    target["source_reference_ids"] = [source_id for source_id, _, _, _ in pairs]
    target["source_references"] = [citation for _, citation, _, _ in pairs]
    target["source_reference_levels"] = [level for _, _, level, _ in pairs]
    target["source_reference_types"] = [source_type for _, _, _, source_type in pairs]
    target["primary_reference_ids"] = [
        source_id for source_id, _, level, _ in pairs if level == "primary"
    ]
    target["primary_references"] = [
        citation for _, citation, level, _ in pairs if level == "primary"
    ]
    target["reference_roles"] = ["component_source"] * len(pairs)
    target["reference_resolution_status"] = "resolved_transitive_component_lineage"

    condition_override_ids = [
        source_id for source_id in target["source_reference_ids"]
        if source_id in KARB_PRIMARY_CONDITION_OVERRIDES
    ]
    if condition_override_ids:
        condition_states = {
            KARB_PRIMARY_CONDITION_OVERRIDES[source_id]["condition"]
            for source_id in condition_override_ids
        }
        target["condition_group"] = next(iter(condition_states)) if (
            len(condition_states) == 1
            and set(target["source_reference_ids"]).issubset(KARB_PRIMARY_CONDITION_OVERRIDES)
        ) else "mixed"
        target["conscious"] = conscious_status_for_condition(target["condition_group"])
        known_condition_ids = [
            source_id for source_id in target["source_reference_ids"]
            if source_id in KARB_PRIMARY_CONDITION_OVERRIDES
            or source_id in KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE
        ]
        target["condition_evidence"] = "Inherited component lineage: " + " ".join(
            KARB_PRIMARY_CONDITION_OVERRIDES[source_id]["evidence"]
            if source_id in KARB_PRIMARY_CONDITION_OVERRIDES
            else KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE[source_id]
            for source_id in known_condition_ids
        )
    else:
        retained_condition_ids = [
            source_id for source_id in target["source_reference_ids"]
            if source_id in KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE
        ]
        if retained_condition_ids and set(target["source_reference_ids"]).issubset(
                KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE):
            target["condition_group"] = "nonanesthetized_unspecified_arm"
            target["conscious"] = "conscious"
            target["condition_evidence"] = "Inherited component lineage: " + " ".join(
                KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE[source_id]
                for source_id in retained_condition_ids
            )
        elif retained_condition_ids:
            target["condition_evidence"] += (
                " Inherited verified nonanesthetized/control component(s): "
                + " ".join(
                    KARB_PRIMARY_RETAINED_CONDITION_EVIDENCE[source_id]
                    for source_id in retained_condition_ids
                )
            )


karbowski_rows = [u for u in U if u["Compilation"] == "Karbowski__2007"]
for target in karbowski_rows:
    if target["derivation_role"] == "compiler_average":
        components = [
            u for u in karbowski_rows
            if u["Table"] == target["Table"]
            and u["Species"] == target["Species"]
            and u["Region"] == target["Region"]
            and u["Measure"] == target["Measure"]
            and u["derivation_role"] != "compiler_average"
        ]
        inherit_component_lineage(target, components)
    elif target["derivation_role"] == "derived_cross_area_summary":
        components = [
            u for u in karbowski_rows
            if 3 <= int(u["Table"][6:]) <= 10
            and u["Species"] == target["Species"]
            and u["Measure"] == target["Measure"]
            and u["derivation_role"] != "compiler_average"
        ]
        inherit_component_lineage(target, components)


HEISS_CITATION = (
    "Heiss WD, Habedank B, Klein JC, Herholz K, Wienhard K, Lenox M, Nutt R. "
    "2004. Metabolic rates in small brain nuclei determined by high-resolution PET. "
    "Journal of Nuclear Medicine 45:1811-1815."
)
for source_row, r in enumerate(rows_of(os.path.join(
        BASE, "Heiss_etal_2004", "Heiss_etal_2004_TABLE1.csv")), 1):
    value_raw = r.get("Both hemispheres Mean")
    sd_raw = r.get("Both hemispheres SD")
    v = num(value_raw)
    if v is None:
        continue
    reg_raw = (r.get("Region") or "").strip()
    U.append(dict(
        record_id=f"Heiss_etal_2004:TABLE1:{source_row}:CMRgl",
        Compilation="Heiss_etal_2004", compilation_role="primary_study",
        Species_printed="Homo sapiens", Species="Homo sapiens", genus="Homo",
        Region_raw=reg_raw, Subregion_raw=reg_raw, Region=canon_region(reg_raw),
        Measure="CMRgl", measure_class="cerebral_metabolic_rate", Value_raw=value_raw,
        SD_raw=sd_raw, Units_raw="umol/100g/min", Value=v,
        SD=num(sd_raw), n=None, n_areas=None,
        conscious="conscious", condition_group="nonanesthetized_unspecified_arm",
        Anesthesia_raw="", Mode="PET",
        condition_evidence="Heiss et al. 2004 primary-study protocol",
        primary_reference_raw="Heiss et al. 2004",
        ref_raw="Heiss et al. 2004",
        source_reference_ids=["heiss_2004"], source_references=[HEISS_CITATION],
        source_reference_levels=["primary"], source_reference_types=["primary_report"],
        primary_reference_ids=["heiss_2004"],
        primary_references=[HEISS_CITATION], reference_core="Heiss et al. 2004",
        reference_resolution_status="direct_primary", source_granularity="single_primary_reference",
        derivation_role="direct_primary", include_in_primary_merge=True, exclusion_reason="",
        source_correction="", reference_roles=["reported_data_source"], Units="umol/100g/min",
        Table="TABLE1", source_row=source_row, source_snapshot_row=source_row,
    ))

# The compilation carriers do not identify control/treatment/disease/task/age
# arms reliably enough to combine multiple rows from one primary work. Quarantine
# every otherwise-eligible within-compilation full-key collision rather than
# averaging incompatible arms. All source rows remain in the provenance output.
for u in U:
    u["arm_identity_status"] = "not_applicable_preexisting_exclusion"
    u["arm_ambiguity_group_id"] = ""

eligible_arm_groups = defaultdict(list)
for index, u in enumerate(U):
    if not u["include_in_primary_merge"]:
        continue
    primary_id = u["primary_reference_ids"][0]
    key = (
        u["Compilation"], u["Species"], u["Region"], u["Measure"], u["Units"],
        u["measure_class"], u["condition_group"], primary_id,
    )
    eligible_arm_groups[key].append(index)

arm_ambiguity_report = []
for group_number, (key, indices) in enumerate(sorted(eligible_arm_groups.items()), 1):
    if len(indices) == 1:
        U[indices[0]]["arm_identity_status"] = "singleton_within_compilation_source_cell"
        continue
    group_id = f"CMR-ARM-{group_number:04d}"
    rows = [U[index] for index in indices]
    for index in indices:
        U[index]["include_in_primary_merge"] = False
        U[index]["exclusion_reason"] = "ambiguous_within_primary_source_multiple_rows"
        U[index]["arm_identity_status"] = (
            "ambiguous_multiple_rows_same_source_cell_condition_unit"
        )
        U[index]["arm_ambiguity_group_id"] = group_id
    compilation, species, region, measure, unit, mclass, condition_group, primary_id = key
    distinct_values = {round(row["Value"], 12) for row in rows}
    arm_ambiguity_report.append({
        "arm_ambiguity_group_id": group_id,
        "Compilation": compilation,
        "Species": species,
        "Region": region,
        "Measure": measure,
        "Units": unit,
        "measure_class": mclass,
        "condition_group": condition_group,
        "primary_reference_id": primary_id,
        "primary_reference_citation": rows[0]["primary_references"][0],
        "n_rows": len(rows),
        "n_distinct_standardized_values": len(distinct_values),
        "record_ids": "; ".join(sorted(row["record_id"] for row in rows)),
        "Values_raw": "; ".join(str(row["Value_raw"]) for row in rows),
        "Values_standardized": "; ".join(format(row["Value"], ".15g") for row in rows),
        "merge_action": "exclude_until_primary_study_arms_are_reconstructed",
    })

for u in U:
    # These ordered views correspond exactly to reference_order in the link
    # table. Merge-level reference lists are sorted separately below.
    u["source_reference_ids_str"] = "; ".join(u["source_reference_ids"])
    u["source_references_str"] = " || ".join(u["source_references"])
    u["source_reference_levels_str"] = "; ".join(u["source_reference_levels"])
    u["source_reference_types_str"] = "; ".join(u["source_reference_types"])
    u["primary_reference_ids_str"] = "; ".join(u["primary_reference_ids"])
    u["primary_references_str"] = " || ".join(u["primary_references"])
    # Back-compatible alias for checked cited-source IDs.
    u["ref_keys_str"] = u["source_reference_ids_str"]

missing_aliases = sorted({
    (u["Compilation"], u["Table"], u["primary_reference_raw"])
    for u in U if "missing_catalog_alias" in u["reference_resolution_status"]
})
if missing_aliases:
    raise RuntimeError("Reference aliases missing from a source catalog: " + repr(missing_aliases))
expected_correction_records = 14 + sum(
    len(repair.get("affected_measures", set(repair["printed"])))
    for repair in KAUF_EXTRACTION_REPAIRS.values()
)
if sum(bool(u["source_correction"]) for u in U) != expected_correction_records:
    raise RuntimeError(
        "Kaufman correction-record count drifted from the checked repair manifests"
    )
if any(
    len(u["source_reference_ids"]) != len(u["source_references"])
    or len(u["source_reference_ids"]) != len(u["source_reference_levels"])
    or len(u["source_reference_ids"]) != len(u["source_reference_types"])
    or len(u["source_reference_ids"]) != len(u["reference_roles"])
    or len(u["primary_reference_ids"]) != len(u["primary_references"])
    for u in U
):
    raise RuntimeError("Source/primary reference IDs, citations, levels, types, or roles are not aligned")
if sum(u["reference_resolution_status"] == "resolved_transitive_component_lineage" for u in U) != 80:
    raise RuntimeError("Expected transitive lineage for 73 compiler averages and 7 S11 summaries")

# Validate the primary-only pool and unit sentinels before replacing any output.
F = [u for u in U if u["include_in_primary_merge"]]
if any(len(u["primary_reference_ids"]) != 1 for u in F):
    raise RuntimeError("Primary merge contains a non-singleton source reference")
if any(u["condition_group"] != "nonanesthetized_unspecified_arm" for u in F):
    raise RuntimeError(
        "Primary merge contains a measurement outside the accepted nonanesthetized pool"
    )
if any(u["Compilation"] == "Karbowski__2007" and u["Table"] == "TableS11" for u in F):
    raise RuntimeError("Karbowski Table S11 derived summaries entered the primary merge")
known_oxygen = {u["primary_reference_ids_str"]: u["Value"] for u in U
                if u["Compilation"] == "Karbowski__2007" and u["Table"] == "TableS1"
                and u["Measure"] == "CMRO2"}
for primary_id, expected in {"linde_1999": 374.976, "nemoto_1994": 267.84}.items():
    if not math.isclose(known_oxygen.get(primary_id, math.nan), expected, rel_tol=0, abs_tol=1e-9):
        raise RuntimeError(f"Karbowski CMRO2 conversion regression for {primary_id}")

# ---- 2. unfiltered long table (full provenance) -----------------------------
UF_COLS = [
    "record_id", "Species", "Species_printed", "Compilation", "compilation_role",
    "Table", "source_row", "source_snapshot_row", "Region", "Region_raw", "Subregion_raw", "Measure",
    "measure_class", "Value_raw", "SD_raw", "Units_raw", "Value", "SD", "n",
    "n_areas", "Units", "conscious", "condition_group", "Anesthesia_raw",
    "condition_evidence", "Mode",
    "derivation_role",
    "source_granularity", "arm_identity_status", "arm_ambiguity_group_id",
    "include_in_primary_merge", "exclusion_reason",
    "source_reference_ids", "source_references", "source_reference_levels",
    "source_reference_types",
    "primary_reference_raw", "reference_core", "primary_reference_ids",
    "primary_references", "reference_resolution_status", "source_correction",
    "ref_raw", "ref_keys_str",
]
uf = sorted(U, key=lambda u: (u["Measure"], u["Species"], u["Region"], u["Compilation"]))
with open(os.path.join(HERE, "cerebral_metabolic_rate_unfiltered.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=UF_COLS, extrasaction="ignore", lineterminator="\n")
    w.writeheader()
    for u in uf:
        out = {c: ("" if u.get(c) is None else u[c]) for c in UF_COLS}
        out["source_reference_ids"] = u["source_reference_ids_str"]
        out["source_references"] = u["source_references_str"]
        out["source_reference_levels"] = u["source_reference_levels_str"]
        out["source_reference_types"] = u["source_reference_types_str"]
        out["primary_reference_ids"] = u["primary_reference_ids_str"]
        out["primary_references"] = u["primary_references_str"]
        w.writerow(out)

with open(os.path.join(HERE, "cerebral_metabolic_rate_arm_ambiguity_report.csv"), "w",
          newline="", encoding="utf-8") as fh:
    fields = [
        "arm_ambiguity_group_id", "Compilation", "Species", "Region", "Measure",
        "Units", "measure_class", "condition_group", "primary_reference_id",
        "primary_reference_citation", "n_rows", "n_distinct_standardized_values",
        "record_ids", "Values_raw", "Values_standardized", "merge_action",
    ]
    w = csv.DictWriter(fh, fieldnames=fields, lineterminator="\n")
    w.writeheader()
    w.writerows(arm_ambiguity_report)

# ---- 3. relational value -> cited-reference links ---------------------------
with open(os.path.join(HERE, "cerebral_metabolic_rate_value_reference_links.csv"), "w",
          newline="", encoding="utf-8") as fh:
    fields = ["record_id", "Compilation", "Table", "source_row", "source_snapshot_row", "Measure",
              "reference_id", "reference_citation", "reference_level", "source_type",
              "reference_order",
              "lineage_type", "reference_role"]
    w = csv.DictWriter(fh, fieldnames=fields, lineterminator="\n")
    w.writeheader()
    for u in sorted(U, key=lambda x: x["record_id"]):
        for order, source_id in enumerate(u["source_reference_ids"], 1):
            w.writerow({
                "record_id": u["record_id"], "Compilation": u["Compilation"],
                "Table": u["Table"], "source_row": u["source_row"],
                "source_snapshot_row": u["source_snapshot_row"], "Measure": u["Measure"],
                "reference_id": source_id,
                "reference_citation": citation_for(source_id) or (
                    HEISS_CITATION if source_id == "heiss_2004" else ""
                ),
                "reference_level": u["source_reference_levels"][order - 1],
                "source_type": u["source_reference_types"][order - 1],
                "reference_order": order, "lineage_type": u["derivation_role"],
                "reference_role": u["reference_roles"][order - 1],
            })

# ---- 4. union catalogs (all cited sources, then true primaries only) --------
source_registry = []
all_source_ids = sorted(set(CATALOG_BY_SOURCE_ID) | {"heiss_2004"})
for source_id in all_source_ids:
    source_rows = CATALOG_BY_SOURCE_ID.get(source_id, [])
    kauf_cites = {r["citation"] for r in source_rows if r["evidence_file"].startswith("Kaufman")}
    karb_cites = {r["citation"] for r in source_rows if r["evidence_file"].startswith("Karbowski")}
    comps = []
    if kauf_cites:
        comps.append("Kaufman__2004")
    if karb_cites:
        comps.append("Karbowski__2007")
    if source_id == "heiss_2004":
        comps.append("Heiss_etal_2004")
    levels = {r["reference_level"] for r in source_rows}
    source_types = {r["source_type"] for r in source_rows}
    if len(levels) > 1 or len(source_types) > 1:
        raise RuntimeError(f"Conflicting source classification for {source_id}")
    reference_level = "primary" if source_id == "heiss_2004" else next(iter(levels))
    source_type = "primary_report" if source_id == "heiss_2004" else next(iter(source_types))
    canonical = HEISS_CITATION if source_id == "heiss_2004" else citation_for(source_id)
    source_registry.append({
        "reference_id": source_id,
        "reference_citation": canonical,
        "reference_level": reference_level,
        "source_type": source_type,
        "citation_as_printed_Kaufman_2004": joined(kauf_cites, sep=" || "),
        "citation_as_printed_Karbowski_2007": joined(karb_cites, sep=" || "),
        "reported_by_compilations": "; ".join(comps),
        "resolution_status": (
            "direct_primary" if source_id == "heiss_2004"
            else "resolved" if reference_level == "primary"
            else "resolved_secondary_without_primary_lineage"
        ),
        "note": joined({r["note"] for r in source_rows}, sep=" "),
    })
with open(os.path.join(HERE, "cerebral_metabolic_rate_cited_references.csv"), "w",
          newline="", encoding="utf-8") as fh:
    fields = ["reference_id", "reference_citation", "reference_level", "source_type",
              "citation_as_printed_Kaufman_2004", "citation_as_printed_Karbowski_2007",
              "reported_by_compilations", "resolution_status", "note"]
    w = csv.DictWriter(fh, fieldnames=fields, lineterminator="\n")
    w.writeheader()
    w.writerows(source_registry)

registry = [{
    "primary_reference_id": row["reference_id"],
    "primary_reference_citation": row["reference_citation"],
    "reference_level": row["reference_level"],
    "source_type": row["source_type"],
    "citation_as_printed_Kaufman_2004": row["citation_as_printed_Kaufman_2004"],
    "citation_as_printed_Karbowski_2007": row["citation_as_printed_Karbowski_2007"],
    "reported_by_compilations": row["reported_by_compilations"],
    "resolution_status": row["resolution_status"],
    "note": row["note"],
} for row in source_registry if row["reference_level"] == "primary"]
with open(os.path.join(HERE, "cerebral_metabolic_rate_primary_references.csv"), "w",
          newline="", encoding="utf-8") as fh:
    fields = ["primary_reference_id", "primary_reference_citation", "reference_level", "source_type",
              "citation_as_printed_Kaufman_2004", "citation_as_printed_Karbowski_2007",
              "reported_by_compilations", "resolution_status", "note"]
    w = csv.DictWriter(fh, fieldnames=fields, lineterminator="\n")
    w.writeheader()
    w.writerows(registry)

# ---- 5. study reports, then compilation-aware dedupe ------------------------
reports_by_key_comp = defaultdict(lambda: {"vals": [], "records": [], "citation": ""})
for u in F:
    primary_id = u["primary_reference_ids"][0]
    key = (u["Species"], u["Region"], u["Measure"], u["Units"],
           u["measure_class"], u["condition_group"], primary_id, u["Compilation"])
    reports_by_key_comp[key]["vals"].append(u["Value"])
    reports_by_key_comp[key]["records"].append(u["record_id"])
    reports_by_key_comp[key]["citation"] = u["primary_references"][0]

study_reports = []
for (sp, reg, meas, unit, mclass, condition_group, primary_id, comp), values in reports_by_key_comp.items():
    study_reports.append({
        "Species": sp, "Region": reg, "Measure": meas, "Units": unit,
        "measure_class": mclass, "condition_group": condition_group,
        "primary_reference_id": primary_id,
        "primary_reference_citation": values["citation"], "Compilation": comp,
        "Value": mean(values["vals"]), "record_ids": values["records"],
    })

by_primary_cell = defaultdict(list)
for index, row in enumerate(study_reports):
    by_primary_cell[(row["Species"], row["Region"], row["Measure"], row["Units"],
                     row["measure_class"], row["condition_group"],
                     row["primary_reference_id"])].append(index)

drop, report = set(), []
for (sp, reg, meas, unit, mclass, condition_group, primary_id), indices in by_primary_cell.items():
    comps = {study_reports[i]["Compilation"] for i in indices}
    if len(comps) < 2:
        continue
    keep_comp = min(comps, key=lambda c: COMP_PRIORITY.get(c, 99))
    kept_rows = [study_reports[i] for i in indices if study_reports[i]["Compilation"] == keep_comp]
    dropped = sorted(c for c in comps if c != keep_comp)
    for i in indices:
        if study_reports[i]["Compilation"] != keep_comp:
            drop.add(i)
    values_by_comp = {study_reports[i]["Compilation"]: study_reports[i]["Value"] for i in indices}
    kauf_value = values_by_comp.get("Kaufman__2004")
    karb_value = values_by_comp.get("Karbowski__2007")
    absolute_difference = (
        round3(abs(karb_value - kauf_value))
        if kauf_value is not None and karb_value is not None else None
    )
    report.append({
        "Species": sp, "Region": reg, "Measure": meas, "Units": unit,
        "measure_class": mclass, "condition_group": condition_group,
        "primary_reference_id": primary_id,
        "primary_reference_citation": (
            HEISS_CITATION if primary_id == "heiss_2004" else citation_for(primary_id)
        ),
        "reported_by_compilations": "; ".join(sorted(comps)),
        "kept_compilation": keep_comp, "dropped_compilations": "; ".join(dropped),
        "Kaufman_value_standardized": round3(kauf_value) if kauf_value is not None else None,
        "Karbowski_value_standardized": round3(karb_value) if karb_value is not None else None,
        "absolute_difference": absolute_difference,
        "merge_action": "retain_one_primary_study_report; preserve_both_compilation_reports",
    })
report.sort(key=lambda r: (
    r["Species"], r["Region"], r["Measure"], r["Units"], r["measure_class"],
    r["condition_group"], r["primary_reference_id"],
))
with open(os.path.join(HERE, "cerebral_metabolic_rate_dedupe_report.csv"), "w", newline="",
          encoding="utf-8") as fh:
    fields = ["Species", "Region", "Measure", "Units", "measure_class", "condition_group",
              "primary_reference_id",
              "primary_reference_citation", "reported_by_compilations", "kept_compilation",
              "dropped_compilations", "Kaufman_value_standardized",
              "Karbowski_value_standardized", "absolute_difference", "merge_action"]
    w = csv.DictWriter(fh, fieldnames=fields, lineterminator="\n")
    w.writeheader()
    w.writerows(report)
D = [row for i, row in enumerate(study_reports) if i not in drop]

# ---- 6. aggregate across distinct primary sources --------------------------
cells = defaultdict(lambda: {"vals": [], "ids": set(), "used": set(), "reported": set()})
reporting_by_cell_id = defaultdict(set)
for row in study_reports:
    reporting_by_cell_id[(row["Species"], row["Region"], row["Measure"], row["Units"],
                          row["measure_class"], row["condition_group"],
                          row["primary_reference_id"])].add(row["Compilation"])
for row in D:
    key = (row["Species"], row["Region"], row["Measure"], row["Units"], row["measure_class"])
    c = cells[key]
    c["vals"].append(row["Value"])
    c["ids"].add(row["primary_reference_id"])
    c["used"].add(row["Compilation"])
    c["reported"] |= reporting_by_cell_id[(
        row["Species"], row["Region"], row["Measure"], row["Units"],
        row["measure_class"], row["condition_group"], row["primary_reference_id"],
    )]
merged = [dict(Species=sp, Region=reg, Measure=meas, measure_class=mclass, Units=unit,
               Value=round3(mean(c["vals"])), n_studies=len(c["ids"]),
               n_primary_references=len(c["ids"]),
               Primary_reference_ids="; ".join(sorted(c["ids"])),
               Primary_references=" || ".join(citation_for(i) if i != "heiss_2004" else HEISS_CITATION
                                               for i in sorted(c["ids"])),
               Compilations="; ".join(sorted(c["reported"])),
               Compilations_reporting="; ".join(sorted(c["reported"])),
               Compilations_used="; ".join(sorted(c["used"])),
               Volume_term=VOLUME_TERM.get(reg, ""))
          for (sp, reg, meas, unit, mclass), c in cells.items()]
merged.sort(key=lambda m: (m["Species"], m["Region"], m["Measure"]))
for row in merged:
    if row["n_primary_references"] != len(row["Primary_reference_ids"].split("; ")):
        raise RuntimeError("Merged reference count/list mismatch")
LONG_COLS = ["Species", "Region", "Measure", "measure_class", "Units", "Value",
             "n_studies", "n_primary_references", "Primary_reference_ids",
             "Primary_references", "Compilations", "Compilations_reporting",
             "Compilations_used", "Volume_term"]
with open(os.path.join(HERE, "cerebral_metabolic_rate_long.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=LONG_COLS, lineterminator="\n")
    w.writeheader()
    w.writerows(merged)

# ---- 7. wide ----------------------------------------------------------------
cols, wide = [], defaultdict(dict)
for m in merged:
    col = f"{m['Region']}__{m['Measure']}"
    if col not in cols:
        cols.append(col)
    wide[m["Species"]][col] = m["Value"]
with open(os.path.join(HERE, "cerebral_metabolic_rate_wide.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.writer(fh, lineterminator="\n")
    w.writerow(["Species"] + cols)
    for sp in sorted(wide):
        w.writerow([sp] + [wide[sp].get(c, "NA") for c in cols])

# ---- 8. species id / crosswalk ---------------------------------------------
sid_rows = defaultdict(lambda: {"comps": set(), "n": 0})
for u in U:
    s = sid_rows[(u["Species"], u["Species_printed"])]
    s["comps"].add(u["Compilation"])
    s["n"] += 1
with open(os.path.join(HERE, "cerebral_metabolic_rate_source_species_ids.csv"), "w",
          newline="", encoding="utf-8") as fh:
    w = csv.writer(fh, lineterminator="\n")
    w.writerow(["Species", "Species_printed", "Compilations", "n_rows", "note"])
    for (sp, pr) in sorted(sid_rows):
        s = sid_rows[(sp, pr)]
        note = (
            "Primary-source override: Kennedy et al. (1978) studied Macaca mulatta; "
            "Kaufman printed M fascic."
            if (sp, pr) == ("Macaca mulatta", "M fascic") else
            "Primary-source override: Passero et al. (1981) studied rabbit "
            "(Oryctolagus cuniculus); Kaufman printed Lepus."
            if (sp, pr) == ("Oryctolagus cuniculus", "Lepus") else
            "Kaufman genus label; binomial assigned by standard-lab-species convention"
            if pr in KAUF_GENUS_ASSIGNED else
            "generic Macaca kept as Macaca sp." if pr == "Macaca" else ""
        )
        w.writerow([sp, pr, "; ".join(sorted(s["comps"])), s["n"], note])

n_sp = len({m["Species"] for m in merged})
n_reg = len({m["Region"] for m in merged})
print(f"{len(merged)} merged cells | {n_sp} species | {n_reg} regions", file=sys.stderr)
role_counts = defaultdict(int)
for u in U:
    role_counts[u["derivation_role"]] += 1
print(f"  {len(U)} provenance rows | {len(F)} primary-pool rows", file=sys.stderr)
print(
    f"  {len(arm_ambiguity_report)} unresolved within-primary arm groups | "
    f"{sum(row['n_rows'] for row in arm_ambiguity_report)} quarantined rows",
    file=sys.stderr,
)
for role in sorted(role_counts):
    print(f"  role {role}: {role_counts[role]}", file=sys.stderr)
for mc in sorted({m["measure_class"] for m in merged}):
    sub = [m for m in merged if m["measure_class"] == mc]
    print(f"  {mc}: {len(sub)} cells, {len({m['Species'] for m in sub})} species,"
          f" measures {sorted({m['Measure'] for m in sub})}", file=sys.stderr)
