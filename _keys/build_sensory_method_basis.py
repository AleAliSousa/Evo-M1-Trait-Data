#!/usr/bin/env python3
"""build_sensory_method_basis.py -- author _keys/sensory_method_basis.csv.

The sibling of build_brain_size_basis.py, for sensory measures. One row per
(registry item, source column) that feeds __merging_sensory, recording HOW the
value was obtained, so "which of these may be pooled or plotted against each
other" is a lookup rather than a judgement call.

Why this key exists. `measure_class = psychophysics` was applied to all seven
sensory measures, but only some are psychophysics. By their own definitions
files, visual acuity is "Calculated based on peak density of ganglion cells
except as otherwise noted", the field of best vision comes "from retinal
ganglion cell isodensity contours", and the binocular field is the "angle of
overlap of the left and right retinal fields" -- three retinal or optical
quantities, not behavioural thresholds. The audiogram limits and the sound
localization threshold are behavioural. Critical flicker fusion is BOTH: the
Haarlem compilation carries a per-row `method` of Electrophysiology or
Behavioural. A behavioural threshold and a number computed from cell density
are not the same measurement and must not be averaged into one species value.

Granularity. The basis is recorded finely (which cell class, which criterion)
and the poolable_group coarsely, so cone-density and ganglion-cell acuity pool
-- both are a peak-sampling-density estimate, and the source chooses between
them per taxon on stated grounds -- while an evoked-potential average does not.
This is the brain-size rule: `state` records fresh vs fixed, `poolable_group`
decides what may be averaged.

Honesty rule, same as the brain-size key. A basis is recorded only where the
source SAYS it. Heffner & Heffner's acuity footnotes 24, 25, 27, 28 and 30 name
another study ("Schusterman ('72)", "Baker and Emerson ('83)") without saying
how that study measured; those rows are `unstated_external_source`, not
"behavioural", however well known the cited work is. Footnotes 26 and 29 do
state a method and are recorded from their own words.

Every `statement` below is checked against the file named in
`statement_source`; the build FAILS if one is not there verbatim. The statements
come from repo CSVs rather than PDFs, so unlike the brain-size key the check is
exact and runs inside the builder -- it cannot be skipped.
"""
import csv
import os
import re
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)

HH = os.path.join("Heffner_Heffner_1992_a", "reference_tables",
                  "Heffner_Heffner_1992_a_Table1_definitions.csv")
HHF = os.path.join("Heffner_Heffner_1992_a", "reference_tables",
                   "Heffner_Heffner_1992_a_Table1_footnotes.csv")
VK = os.path.join("Veilleux_Kirk_2014", "reference_tables",
                  "Veilleux_Kirk_2014_SupplementalTable1_definitions.csv")
KO = os.path.join("Koay_etal_1998", "reference_tables",
                  "Koay_etal_1998_Figure6_definitions.csv")
HA = os.path.join("Haarlem_etal_2026", "reference_tables",
                  "Haarlem_etal_2026_CFFdataset_definitions.csv")

# method basis -> what it means
BASIS_NOTES = {
    "behavioural_audiogram":
        "a behavioural audiogram threshold: the animal was trained or conditioned and the "
        "frequency limit read at a stated sound-pressure criterion",
    "behavioural_threshold":
        "a behavioural discrimination threshold at a stated percent-correct or detection criterion",
    "anatomical_ganglion_cell":
        "not a measured percept: computed from peak retinal ganglion cell density (or an "
        "isodensity contour of it)",
    "anatomical_cone_density":
        "not a measured percept: computed from peak cone density, used where retinal summation "
        "is absent so cones rather than ganglion cells set the sampling limit",
    "optical_field_geometry":
        "not a measured percept: the angular geometry of the two retinal fields, from eye "
        "position and field overlap",
    "electrophysiological":
        "an evoked electrical response of the visual system (electroretinogram or evoked "
        "potential), not a behavioural report",
    "anatomical_and_electrophysiological_mixed":
        "a single printed value averaging an anatomical estimate with an evoked-potential "
        "measure; neither component is recoverable",
    "unstated_external_source":
        "the source names the study the value came from but does not state how that study "
        "measured it",
}

# (item, column) -> (quantity, basis, poolable_group, statement, statement_source, is_percept)
A_GANGLION = "acuity_anatomical"
ASSIGN = {
    ("Heffner_Heffner_1992_a_TABLE1", "sound_localization_threshold_deg"): (
        "sound localization threshold", "behavioural_threshold", "localization_behavioural",
        "75% correct for two-choice procedures, 50% detection for conditioned avoidance", HH, True),
    ("Heffner_Heffner_1992_a_TABLE1", "field_of_best_vision_deg"): (
        "field of best vision", "anatomical_ganglion_cell", "field_of_best_vision_anatomical",
        "Horizontal width of the field of best vision from retinal ganglion cell isodensity "
        "contours (75% of maximum density criterion)", HH, False),
    ("Heffner_Heffner_1992_a_TABLE1", "binocular_field_deg"): (
        "binocular field", "optical_field_geometry", "binocular_field_optical",
        "Width of the angle of overlap of the left and right retinal fields, in degrees",
        HH, False),
    ("Heffner_Heffner_1992_a_TABLE1", "visual_acuity_cdeg"): (
        "visual acuity", "anatomical_ganglion_cell", A_GANGLION,
        "Calculated based on peak density of ganglion cells except as otherwise noted",
        HHF, False),
    ("Veilleux_Kirk_2014_SupplementalTable1", "visual_acuity_cdeg"): (
        "visual acuity", "anatomical_ganglion_cell", A_GANGLION,
        "TRUE where the printed superscript 2 marks acuity calculated from peak cone density "
        "(haplorhines, no retinal summation) rather than ganglion cell density", VK, False),
    ("Koay_etal_1998_Figure6", "high_freq_hearing_limit_60dB_kHz"): (
        "high-frequency hearing limit", "behavioural_audiogram", "audiogram_behavioural",
        "High-frequency hearing limit: highest frequency audible at 60 dB SPL, kHz", KO, True),
    ("Haarlem_etal_2026_CFFdataset", "cff_hz"): (
        "critical flicker fusion frequency", "SPLIT_BY_ROW", "SPLIT_BY_ROW",
        "CFF measurement method: Electrophysiology (n=221) / Behavioural (n=59)", HA, True),
}

# Row-level rules, where one column carries more than one basis and the source marks
# which per row. The merge applies these; the key records them so the rule is auditable.
ROW_RULES = [
    dict(item="Heffner_Heffner_1992_a_TABLE1", column="visual_acuity_cdeg",
         selector="acuity_footnote", when="", basis="anatomical_ganglion_cell",
         poolable_group=A_GANGLION,
         statement="Calculated based on peak density of ganglion cells except as otherwise noted",
         statement_source=HHF,
         note="unfootnoted rows take the column header's default"),
    dict(item="Heffner_Heffner_1992_a_TABLE1", column="visual_acuity_cdeg",
         selector="acuity_footnote", when="29", basis="anatomical_ganglion_cell",
         poolable_group=A_GANGLION,
         statement="Based on peak density of ganglion cells in Hughes and Witteridge ('73)",
         statement_source=HHF,
         note="a different paper's ganglion-cell count, same estimator"),
    dict(item="Heffner_Heffner_1992_a_TABLE1", column="visual_acuity_cdeg",
         selector="acuity_footnote", when="26",
         basis="anatomical_and_electrophysiological_mixed",
         poolable_group="acuity_mixed_anatomical_electrophysiological",
         statement="Average of ganglion cell density and evoked potential measure, Silveira, "
                   "et al., ('82)",
         statement_source=HHF,
         note="the printed value is already an average of two methods"),
    dict(item="Heffner_Heffner_1992_a_TABLE1", column="visual_acuity_cdeg",
         selector="acuity_footnote", when="24|25|27|28|30",
         basis="unstated_external_source", poolable_group="acuity_method_unstated",
         statement="", statement_source="",
         note="footnotes 24 (Cavonius and Robbins), 25 (Schusterman), 27 (Cowey and Ellis; "
              "Cavonius and Robbins), 28 (Belleville and Wilkinson; Jacobson et al.) and 30 "
              "(Baker and Emerson) give a citation only, with no method stated. Do not infer "
              "a method from the cited paper -- resolve it by reading that paper and adding "
              "it here."),
    dict(item="Veilleux_Kirk_2014_SupplementalTable1", column="visual_acuity_cdeg",
         selector="va_cone_density_footnote2", when="TRUE",
         basis="anatomical_cone_density", poolable_group=A_GANGLION,
         statement="TRUE where the printed superscript 2 marks acuity calculated from peak cone "
                   "density (haplorhines, no retinal summation) rather than ganglion cell density",
         statement_source=VK,
         note="pools with ganglion-cell acuity: both estimate the peak sampling density that "
              "sets the acuity limit, and the source chooses between them per taxon on stated "
              "grounds (absence of retinal summation)"),
    dict(item="Veilleux_Kirk_2014_SupplementalTable1", column="visual_acuity_cdeg",
         selector="va_cone_density_footnote2", when="FALSE",
         basis="anatomical_ganglion_cell", poolable_group=A_GANGLION,
         statement="TRUE where the printed superscript 2 marks acuity calculated from peak cone "
                   "density (haplorhines, no retinal summation) rather than ganglion cell density",
         statement_source=VK,
         note="the FALSE arm of the same printed footnote"),
    dict(item="Haarlem_etal_2026_CFFdataset", column="cff_hz",
         selector="method", when="Behavioural", basis="behavioural_threshold",
         poolable_group="cff_behavioural",
         statement="CFF measurement method: Electrophysiology (n=221) / Behavioural (n=59)",
         statement_source=HA,
         note="the psychophysical arm: 59 of 280 rows"),
    dict(item="Haarlem_etal_2026_CFFdataset", column="cff_hz",
         selector="method", when="Electrophysiology", basis="electrophysiological",
         poolable_group="cff_electrophysiological",
         statement="CFF measurement method: Electrophysiology (n=221) / Behavioural (n=59)",
         statement_source=HA,
         note="the flicker electroretinogram arm: 221 of 280 rows"),
]

# Audible_freq_* also reach the merge from Heffner_Heffner_1992_a's audiogram-derived
# companion items; the two limits share one stated criterion, recorded once here.
EXTRA = [
    dict(item="Heffner_etal_2020_cottontail_values_from_text", column="high_freq_hearing_limit_60dB_kHz",
         quantity="high-frequency hearing limit", basis="behavioural_audiogram",
         poolable_group="audiogram_behavioural", is_percept=True,
         statement="High-frequency hearing limit: highest frequency audible at 60 dB SPL, kHz "
                   "(figure y-axis, log scale)",
         statement_source=os.path.join("Heffner_etal_2020", "reference_tables",
                                       "Heffner_etal_2020_Figure3_definitions.csv"),
         note="same stated criterion as Koay et al. 1998; the paper's own cottontail values"),
]


def file_text(rel):
    p = os.path.join(BASE, rel)
    if not os.path.exists(p):
        sys.exit(f"missing source file for a statement: {rel}")
    with open(p, encoding="utf-8-sig", errors="replace") as fh:
        return re.sub(r"\s+", " ", fh.read())


def check(statement, rel):
    """Fail the build if a quoted statement is not verbatim in the file it is credited to."""
    if not statement:
        return ""
    if re.sub(r"\s+", " ", statement) not in file_text(rel):
        sys.exit(f"statement not found verbatim in {rel}:\n  {statement}")
    return rel


out = []
for (item, col), (qty, basis, grp, stmt, srcfile, percept) in sorted(ASSIGN.items()):
    check(stmt, srcfile)
    out.append(dict(
        item=item, column=col, quantity=qty, method_basis=basis, poolable_group=grp,
        row_rule="TRUE" if basis == "SPLIT_BY_ROW" else "FALSE",
        is_percept="TRUE" if percept else "FALSE",
        basis_note="" if basis == "SPLIT_BY_ROW" else BASIS_NOTES[basis],
        statement=stmt, statement_source=srcfile, selector="", selector_value="", note=""))

for r in EXTRA:
    check(r["statement"], r["statement_source"])
    out.append(dict(
        item=r["item"], column=r["column"], quantity=r["quantity"],
        method_basis=r["basis"], poolable_group=r["poolable_group"], row_rule="FALSE",
        is_percept="TRUE" if r["is_percept"] else "FALSE",
        basis_note=BASIS_NOTES[r["basis"]], statement=r["statement"],
        statement_source=r["statement_source"], selector="", selector_value="",
        note=r["note"]))

for r in ROW_RULES:
    check(r["statement"], r["statement_source"])
    base = ASSIGN.get((r["item"], r["column"]))
    out.append(dict(
        item=r["item"], column=r["column"],
        quantity=base[0] if base else "", method_basis=r["basis"],
        poolable_group=r["poolable_group"], row_rule="TRUE",
        is_percept=base[5] and "TRUE" or "FALSE" if base else "",
        basis_note=BASIS_NOTES[r["basis"]], statement=r["statement"],
        statement_source=r["statement_source"],
        selector=r["selector"], selector_value=r["when"], note=r["note"]))

COLS = ["item", "column", "quantity", "method_basis", "poolable_group", "row_rule", "selector",
        "selector_value", "is_percept", "basis_note", "statement", "statement_source", "note"]
out.sort(key=lambda r: (r["item"], r["column"], r["selector_value"]))
with open(os.path.join(HERE, "sensory_method_basis.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=COLS)
    w.writeheader()
    w.writerows(out)

grp = defaultdict(int)
for r in out:
    grp[r["poolable_group"]] += 1
print(f"{len(out)} rows: {len(ASSIGN) + len(EXTRA)} column-level, {len(ROW_RULES)} row-level rules",
      file=sys.stderr)
for g in sorted(grp):
    print(f"  {g:48s} {grp[g]}", file=sys.stderr)
nb = sorted({r["method_basis"] for r in out if r["method_basis"] != "SPLIT_BY_ROW"})
print(f"  bases in use: {nb}", file=sys.stderr)
print("  every statement verified verbatim against its source file", file=sys.stderr)
