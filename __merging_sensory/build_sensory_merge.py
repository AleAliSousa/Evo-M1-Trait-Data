#!/usr/bin/env python3
"""Compile the comparative SENSORY PERFORMANCE dataset (percepts only).

House-style counterpart of __merging_cerebral_metabolic_rate/build_cerebral_metabolic_rate_merge.py:
this is the script that actually generates the shipped CSVs (no R in the build
environment); sensory_compiled.R is the canonical R equivalent of the same pipeline.

COMPILATION-AWARE resolution (README__merging.md, __HOWTO section 9). Three of the four
sources are papers whose comparative values are compiled from OTHER labs' audiograms
and acuity measurements, but which print a reference for every value. Rather than
average those published values as if each paper were an independent measurement, the
pipeline pulls every value down to the PRIMARY-STUDY level, keys each study by
first-author + first initial + year (+ a/b/c suffix), dedupes studies that two sources
both report for the same Species x Measure, and averages across DISTINCT studies.

Excluded by design:
  * Heffner_etal_2020 Figure 3 comparative points -- that figure prints NO per-point
    references, so its values have no traceable primary (only its Cottontail text
    values enter).
  * derived measures (hearing range in octaves) -- recomputed here from the limits.
  * non-percept covariates (functional interaural distance, eye diameter) and ecology
    (trophic level, activity pattern, diet, running speed, body mass).
  * non-mammals -- class gate, though all four current sources are mammal-only.
"""
import csv, os, re, math, sys
from collections import defaultdict, Counter

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)

SRC = {
    "HH1992a": os.path.join(BASE, "Heffner_Heffner_1992_a", "Heffner_Heffner_1992_a_TABLE1.csv"),
    "HH1992a_footnotes": os.path.join(BASE, "Heffner_Heffner_1992_a", "reference_tables",
                                      "Heffner_Heffner_1992_a_TABLE1_footnotes.csv"),
    "VK2014":  os.path.join(BASE, "Veilleux_Kirk_2014", "Veilleux_Kirk_2014_SupplementalTable1.csv"),
    "VK2014_sources": os.path.join(BASE, "Veilleux_Kirk_2014", "reference_tables",
                                   "Veilleux_Kirk_2014_SupplementalTable1_data_sources.csv"),
    "VK2014_xwalk": os.path.join(BASE, "Veilleux_Kirk_2014", "reference_tables",
                                 "Veilleux_Kirk_2014_SupplementalTable1_species_crosswalk.csv"),
    "Koay1998": os.path.join(BASE, "Koay_etal_1998", "Koay_etal_1998_Figure6.csv"),
    "H2020_text": os.path.join(BASE, "Heffner_etal_2020", "reference_tables",
                               "Heffner_etal_2020_cottontail_values_from_text.csv"),
    "Haarlem2026": os.path.join(BASE, "Haarlem_etal_2026", "Haarlem_etal_2026_CFFdataset.csv"),
    "basis_key": os.path.join(BASE, "_keys", "sensory_method_basis.csv"),
}
ITEM = {"HH1992a": "Heffner_Heffner_1992_a_TABLE1",
        "VK2014": "Veilleux_Kirk_2014_SupplementalTable1",
        "Koay1998": "Koay_etal_1998_Figure6",
        "H2020": "Heffner_etal_2020_Figure3",
        "Haarlem2026": "Haarlem_etal_2026_CFFdataset"}

# ---- MEASUREMENT METHOD IS PART OF THE MEASURE NAME -------------------------------
# A behavioural threshold and a number computed from retinal cell density are not the
# same measurement, so they are emitted as PARALLEL measures and never averaged into
# one species value. Which basis each source column carries is recorded, with the
# source's own words, in _keys/sensory_method_basis.csv (built by
# _keys/build_sensory_method_basis.py); this pipeline reads that key and aborts on a
# harvested row whose basis is not on record, so the two cannot drift apart.
#
# Only visual acuity and CFF actually need splitting -- the other five measures each
# carry one basis. Acuity splits three ways because Heffner & Heffner's footnotes do:
# the column default is a ganglion-cell computation, one row is an average of an
# anatomical estimate with an evoked potential, and five rows cite another study
# without saying how it measured.
BASIS_MEASURE = {
    "acuity_anatomical":                          "Visual_acuity_anatomical.cdeg",
    "acuity_mixed_anatomical_electrophysiological": "Visual_acuity_mixed_method.cdeg",
    "acuity_method_unstated":                     "Visual_acuity_method_unstated.cdeg",
    "cff_behavioural":                            "CFF_behavioural.Hz",
    "cff_electrophysiological":                   "CFF_electrophysiological.Hz",
}

UNITS = {"Audible_freq_high_60dB.kHz": "kHz", "Audible_freq_low_60dB.kHz": "kHz",
         "Sound_localization_threshold.deg": "deg",
         "Visual_acuity_anatomical.cdeg": "c/deg",
         "Visual_acuity_mixed_method.cdeg": "c/deg",
         "Visual_acuity_method_unstated.cdeg": "c/deg",
         "CFF_behavioural.Hz": "Hz", "CFF_electrophysiological.Hz": "Hz",
         "Interaural_distance_functional.us": "us",
         "Field_of_best_vision.deg": "deg", "Binocular_field.deg": "deg"}

# printed / older names -> the name used in the merge (from each source's own crosswalk)
SPECIES_CANON = {
    "felis domesticus": "Felis catus", "canis familiaris": "Canis lupus familiaris",
    "sylvilagus floridana": "Sylvilagus floridanus", "orcina orca": "Orcinus orca",
    "mesocricetus auritus": "Mesocricetus auratus", "chinchilla laniger": "Chinchilla lanigera",
    "sciureus niger": "Sciurus niger", "macaca irus": "Macaca fascicularis",
    "lemur fulvus": "Eulemur fulvus", "marmosa elegans": "Thylamys elegans",
    "spalax ehrenbergi": "Nannospalax ehrenbergi", "cercopithecus aithiops": "Chlorocebus aethiops",
    "agouti paca": "Cuniculus paca", "myotis dabentonii": "Myotis daubentonii",
    "sarcrophilus harrisii": "Sarcophilus harrisii", "macropus fulginosus": "Macropus fuliginosus",
    "setonyx brachyurus": "Setonix brachyurus", "dasyprocta leoporina": "Dasyprocta leporina",
    "sciurus caroliniensis": "Sciurus carolinensis", "rhinolophus rouxi": "Rhinolophus rouxii",
    "mustela putorius furo": "Mustela putorius", "capra hircus": "Capra hircus",
}
STOP = {"and", "et", "al", "the", "in", "press", "of", "&"}

# Species identity: the shared resolver (_keys/resolve_species.py, mirror of resolve_species.R).
# Every other merge's long table carries these columns per SPECIES_NAMING.md; this one was
# behind, and the R twin had already been given the layer.
sys.path.insert(0, os.path.join(BASE, "_keys"))
from resolve_species import resolve_species  # noqa: E402

_RS = {}


def resolve_one(printed, item):
    """-> (accepted_name, species_basis, reidentified) for one printed label of one item."""
    k = (printed, item)
    if k not in _RS:
        r = resolve_species([printed], item)
        a = r.accepted_name.iloc[0]
        _RS[k] = ("" if a is None else a, r.species_basis.iloc[0], bool(r.reidentified.iloc[0]))
    return _RS[k]


def canon_species(s):
    s = re.sub(r"\s+", " ", (s or "")).strip()
    return SPECIES_CANON.get(s.lower(), s)

def ref_key(text):
    """first author surname + first initial + year (+ a/b/c) -> dedupe token.

    Handles all three printed conventions in these sources:
      "R. S. Heffner & Heffner, 1985b"      -> heffner_r1985b
      "R. Heffner and Heffner ('82)"        -> heffner_r1982
      "Hebel R (1976): Distribution of ..." -> hebel_r1976
      "Cavonius and Robbins ('73)"          -> cavonius1973
    Only the FIRST initial is kept, so "R. Heffner" and "R. S. Heffner" (the same
    author printed two ways across papers) collapse to one study key.
    """
    t = re.sub(r"\s+", " ", (text or "")).strip()
    if not t:
        return ""
    low = t.lower()
    if "present report" in low or "present study" in low:
        return "SELF"
    m = re.search(r"\((\d{2})([a-c])?\)", t)          # ('82) / ('88c)
    if m:
        year = "19" + m.group(1); suf = m.group(2) or ""
        head = t[:m.start()]
    else:
        m = re.search(r"(1[89]\d{2}|20\d{2})([a-c])?", t)
        if not m:
            return "unkeyed:" + low[:40]
        year = m.group(1); suf = m.group(2) or ""
        head = t[:m.start()]
    toks = re.findall(r"[A-Za-zÀ-ÿ'\.]+", head)
    surname, initial = None, ""
    for i, tok in enumerate(toks):
        bare = tok.replace(".", "")
        if not bare or bare.lower() in STOP:
            continue
        if len(bare) <= 2 and bare.isupper():            # an initials group
            if surname is None:
                initial = initial or bare[0].lower()     # initials BEFORE the surname
            else:
                initial = initial or bare[0].lower()     # or AFTER it (VK style)
                break
            continue
        if surname is None and len(bare) >= 3:
            surname = bare.lower()
    if surname is None:
        return "unkeyed:" + low[:40]
    # the initial is returned separately: sources print it inconsistently
    # ("Belleville and Wilkinson ('86)" vs "Belleville S, Wilkinson F (1986)"),
    # so it must not be part of the key -- it only disambiguates same-surname,
    # same-year authors (e.g. H. E. Heffner vs R. S. Heffner, 1980).
    return surname + year + suf + ("|" + initial if initial else "")

def key_of(k):      return k.split("|")[0]
def initial_of(k):  return k.split("|")[1] if "|" in k else ""

def compatible(a, b):
    """same study? same surname+year+suffix, and initials do not contradict"""
    if key_of(a) != key_of(b):
        return False
    ia, ib = initial_of(a), initial_of(b)
    return (not ia) or (not ib) or ia == ib

def split_refs(text):
    """one printed source cell may name several studies"""
    t = re.sub(r"\s+", " ", (text or "")).strip()
    if not t:
        return []
    parts = re.split(r";|\band\b|,(?=\s*[A-Z][a-z]*\s*(?:[A-Z]\.|\())", t)
    parts = [p.strip(" ,;") for p in parts if p.strip(" ,;")]
    keys, seen = [], set()
    for p in parts:
        k = ref_key(p)
        if k and k not in seen:
            seen.add(k); keys.append(k)
    return keys or [ref_key(t)]

def read_csv(p):
    with open(p, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def num(x):
    x = (x or "").strip()
    if x in ("", "NA", "-"): return None
    try: return float(x)
    except ValueError: return None

# ---- MORE OF THE HEFFNER LAB ------------------------------------------------------------
# The repo holds 33 Heffner-lab folders; the merge originally read 4 items. These are the
# rest of the ones whose values are attributable PER ROW, which is what the repo's "no value
# without a traceable source" rule requires. Each is declared rather than coded, because the
# only thing that varies between them is which column holds what: every paper keeps its own
# column names, and every one of these measured at the same 60 dB SPL criterion already used
# by Koay Figure 6 -- which is what makes them poolable with the values already merged.
#
# `scale` converts to the merge's unit (some papers print the low limit in Hz, not kHz).
# `role_col`/`src_col` are the curated per-row columns: data_role says whether the paper
# measured the species itself, and source names the study when it did not.
HEFFNER_EXTRA = [
    # (folder, table, species_col, [(value_col, measure, scale), ...])
    ("Heffner_Heffner_1992_c", "TableI", "binomial", [
        ("high_frequency_limit_kHz", "Audible_freq_high_60dB.kHz", 1.0),
        ("low_frequency_limit_kHz",  "Audible_freq_low_60dB.kHz",  1.0)]),
    ("Heffner_Heffner_1982", "ResultsText", "binomial", [
        ("high_freq_limit_60dB_kHz", "Audible_freq_high_60dB.kHz", 1.0),
        ("low_freq_limit_60dB_Hz",   "Audible_freq_low_60dB.kHz",  0.001)]),
    ("Heffner_Heffner_1985", "Resultstext", "binomial", [
        ("audible_freq_high_60dBSPL_khz", "Audible_freq_high_60dB.kHz", 1.0),
        ("audible_freq_low_60dBSPL_khz",  "Audible_freq_low_60dB.kHz",  1.0)]),
    ("Heffner_Heffner_2010", "ResultsText", "binomial", [
        ("high_freq_limit_60dB_kHz", "Audible_freq_high_60dB.kHz", 1.0),
        ("low_freq_limit_60dB_Hz",   "Audible_freq_low_60dB.kHz",  0.001)]),
    ("Heffner_etal_2001", "ResultsText", "species_sci", [
        ("hearing_range_high_khz", "Audible_freq_high_60dB.kHz", 1.0),
        ("hearing_range_low_khz",  "Audible_freq_low_60dB.kHz",  1.0)]),
    ("Heffner_etal_2003", "Resultstext", "binomial", [
        ("hearing_range_high_60dBSPL_kHz",   "Audible_freq_high_60dB.kHz", 1.0),
        ("hearing_range_low_60dBSPL_kHz",    "Audible_freq_low_60dB.kHz",  1.0),
        ("interaural_distance_functional_us", "Interaural_distance_functional.us", 1.0)]),
    ("Heffner_etal_2006", "ResultsText", "binomial", [
        ("high_freq_limit_60dB_kHz", "Audible_freq_high_60dB.kHz", 1.0),
        ("low_freq_limit_60dB_kHz",  "Audible_freq_low_60dB.kHz",  1.0)]),
    ("Heffner_etal_2013", "Resultstext", "binomial", [
        ("hearing_range_high_60dBSPL_kHz",   "Audible_freq_high_60dB.kHz", 1.0),
        ("hearing_range_low_60dBSPL_kHz",    "Audible_freq_low_60dB.kHz",  1.0),
        ("interaural_distance_functional_us", "Interaural_distance_functional.us", 1.0)]),
    ("Heffner_etal_1994_c", "Table1", "binomial", [
        ("localization_threshold_deg", "Sound_localization_threshold.deg", 1.0)]),
    ("Heffner_etal_2008", "Table1", "binomial", [
        ("localization_threshold_deg", "Sound_localization_threshold.deg", 1.0)]),
    ("Heffner_etal_2015", "TableI", "binomial", [
        ("minimum_audible_angle_deg", "Sound_localization_threshold.deg", 1.0),
        ("functional_head_size_us",   "Interaural_distance_functional.us", 1.0)]),
    ("Koay_etal_1998_b", "Resultstext", "binomial", [
        ("sound_localization_threshold_deg", "Sound_localization_threshold.deg", 1.0)]),
]


# ---- ERRATA FLAGS (ERRATA_CONVENTION.md, rendering 3) --------------------------------------
# Every paper folder may carry reference_tables/<Paper>_errata.csv. A merge never substitutes a
# proposed value; it FLAGS the study rows an erratum is about, so the flag rides through dedupe
# and averaging into sensory_long.csv. A row is flagged when the erratum's item is the row's
# Source_item, its variable is `*` or the column the row was read from, and its locator (which
# by convention names the printed row label) contains the species as printed.
def load_errata(base):
    out = []
    for paper in sorted(os.listdir(base)):
        f = os.path.join(base, paper, "reference_tables", paper + "_errata.csv")
        if not os.path.isfile(f):
            continue
        for e in read_csv(f):
            e["paper"] = paper
            out.append(e)
    return out

def errata_for_row(r, errata):
    hits = []
    sp_printed = (r.get("species_printed") or "").strip().lower()
    sp_canon = (r.get("Species") or "").strip().lower()
    for e in errata:
        if e["status"] == "withdrawn" or e["item"] != r["Source_item"]:
            continue
        if e["variable"] != "*" and r.get("source_column") and e["variable"] != r["source_column"]:
            continue
        loc = e["locator"].lower()
        if (sp_printed and sp_printed in loc) or (sp_canon and sp_canon in loc):
            hits.append(e)
    return hits

def attach_errata(rows, errata):
    for r in rows:
        hits = errata_for_row(r, errata)
        r["errata_id"] = "; ".join(sorted(e["errata_id"] for e in hits))
        r["errata_status"] = "; ".join(sorted({e["status"] for e in hits}))
        r["errata_issue_type"] = "; ".join(sorted({e["issue_type"] for e in hits}))
    return rows

def main():
    rows = []   # study-level rows, before dedupe

    # measurement-method basis, from the authored key. `col_basis` is the column-level
    # basis; `row_basis` holds the per-row rules for the columns that carry more than
    # one (keyed by the selector value the source prints).
    basis_key = read_csv(SRC["basis_key"])
    col_basis, row_basis, basis_group = {}, {}, {}
    for b in basis_key:
        k = (b["item"], b["column"])
        basis_group[b["method_basis"]] = b["poolable_group"]
        if b["row_rule"] == "TRUE" and b["selector"]:
            for v in b["selector_value"].split("|"):
                row_basis[(k[0], k[1], v)] = (b["method_basis"], b["poolable_group"])
        elif b["row_rule"] == "FALSE":
            col_basis[k] = (b["method_basis"], b["poolable_group"])

    def basis_of(item, column, selector_value=None):
        """Resolve a harvested value's method basis, or abort. Never guess a basis:
        an unrecorded (item, column) is a key that has not caught up with the data."""
        if selector_value is not None:
            hit = row_basis.get((item, column, selector_value))
            if hit:
                return hit
        hit = col_basis.get((item, column))
        if hit:
            return hit
        raise SystemExit(
            f"no measurement-method basis on record for {item} / {column}"
            + (f" (selector value {selector_value!r})" if selector_value is not None else "")
            + ". Add it to _keys/build_sensory_method_basis.py and re-run that builder.")

    def add(species, measure, value, item, study_keys, origin, role, note="", medium="air",
            population="", basis=None, group=None, column=None, selector=None):
        v = num(value) if not isinstance(value, float) else value
        if v is None or not species:
            return
        if basis is None:
            basis, group = basis_of(item, column, selector)
        # a split measure takes its name from the basis, so two methods can never be
        # averaged into one species value downstream
        measure = BASIS_MEASURE.get(group, measure)
        acc, sp_basis, sp_reid = resolve_one(species, item)
        rows.append({"Species": canon_species(species), "Measure": measure, "Value": v,
                     "species_printed": species, "accepted_name": acc,
                     "species_basis": sp_basis, "reidentified": sp_reid,
                     "Medium": medium, "Source_item": item,
                     "Study_keys_list": list(study_keys),
                     "Study_key": "+".join(study_keys) if study_keys else "SELF",
                     "population": population, "method_basis": basis,
                     "poolable_group": group,
                     "value_origin": origin, "Data_role": role, "note": note,
                     "source_column": column or ""})

    # ---- 1. Heffner & Heffner 1992a Table 1 --------------------------------------------
    # its footnotes mix prose with citations ("Average of ganglion cell density and
    # evoked potential measure, Silveira, et al., ('82)"), so the study keys are
    # CURATED in the footnotes reference table rather than parsed from the text.
    hh_keys = {f["footnote"]: [k for k in f["primary_study_keys"].split(";") if k]
               for f in read_csv(SRC["HH1992a_footnotes"])}
    for r in read_csv(SRC["HH1992a"]):
        sp = r["binomial"]
        pop = r["Species_HH1992a"]          # e.g. "norway rat wild" vs "norway rat domestic"
        if sp.endswith(" sp."):                      # Macaca sp. -- not a resolvable species
            continue
        # own measurements (primary)
        add(sp, "Field_of_best_vision.deg", r["field_of_best_vision_deg"], ITEM["HH1992a"],
            [], "published", "primary", population=pop, column="field_of_best_vision_deg")
        add(sp, "Binocular_field.deg", r["binocular_field_deg"], ITEM["HH1992a"],
            [], "published", "primary", population=pop, column="binocular_field_deg")
        # localization thresholds: all compiled, each with its printed footnote source
        add(sp, "Sound_localization_threshold.deg", r["sound_localization_threshold_deg"],
            ITEM["HH1992a"], hh_keys.get(r["threshold_footnote"], []),
            "published", "secondary", population=pop,
            column="sound_localization_threshold_deg")
        # functional interaural distance -- this paper's own head measurements, printed under
        # its own column name (delta_t) for the same quantity Koay calls functional
        # interaural distance
        add(sp, "Interaural_distance_functional.us", r["delta_t_us"], ITEM["HH1992a"],
            [], "published", "primary", population=pop, column="delta_t_us")
        # acuity: unfootnoted = this paper's own ganglion-cell estimate; footnoted = compiled.
        # The printed footnote also decides the METHOD BASIS, so it is passed as the
        # selector: footnote 29 is another ganglion-cell count (pools with the default),
        # 26 is an anatomical/evoked-potential average, and 24/25/27/28/30 state no method.
        fn = r["acuity_footnote"].strip()
        if fn:
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["HH1992a"],
                hh_keys.get(fn, []), "published", "secondary", population=pop,
                column="visual_acuity_cdeg", selector=fn)
        else:
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["HH1992a"],
                [], "published", "primary", population=pop,
                column="visual_acuity_cdeg", selector="")

    # ---- 2. Veilleux & Kirk 2014 Supplemental Table 1 ----------------------------------
    vk_src = {s["source_number"]: s["citation"] for s in read_csv(SRC["VK2014_sources"])}
    vk_xw = {x["species_as_published"].lower(): x["corrected_binomial"]
             for x in read_csv(SRC["VK2014_xwalk"])}
    for r in read_csv(SRC["VK2014"]):
        sp = vk_xw.get(r["Species_VK2014"].lower(), r["Species_VK2014"])
        src = r["src_VA"]
        cone = r["va_cone_density_footnote2"].strip() or "FALSE"
        if r["va_this_study"] == "TRUE":
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["VK2014"],
                [], "published", "primary", column="visual_acuity_cdeg", selector=cone)
        else:
            nums = re.findall(r"\d+", src)
            keys = []
            for n in nums:
                c = vk_src.get(n)
                if c:
                    k = ref_key(c)
                    if k and k not in keys: keys.append(k)
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["VK2014"],
                keys, "published", "secondary", column="visual_acuity_cdeg", selector=cone)

    # ---- 3. Koay et al 1998 Figure 6 ----------------------------------------------------
    for r in read_csv(SRC["Koay1998"]):
        sp = r["corrected_binomial"]
        keys = split_refs(r["audiogram_source"])
        primary = keys == ["SELF"]
        add(sp, "Audible_freq_high_60dB.kHz", r["high_freq_hearing_limit_60dB_kHz"],
            ITEM["Koay1998"], [] if primary else [k for k in keys if k != "SELF"],
            "digitised_from_figure", "primary" if primary else "secondary",
            medium=r["medium"] or "air", population=r["common_name_Koay1998"],
            column="high_freq_hearing_limit_60dB_kHz")
        # the head-size covariate printed alongside each point. Its source is this paper's
        # own measurement even where the audiogram beside it is compiled, so it is primary.
        add(r["corrected_binomial"], "Interaural_distance_functional.us",
            r["functional_interaural_distance_us"], ITEM["Koay1998"], [],
            "digitised_from_figure", "primary", population=r["common_name_Koay1998"],
            column="functional_interaural_distance_us")

    # ---- 4. Heffner et al 2020 -- Cottontail values FROM TEXT ---------------------------
    tmap = {"audible_freq_high_60dBSPL": "Audible_freq_high_60dB.kHz",
            "audible_freq_low_60dBSPL": "Audible_freq_low_60dB.kHz",
            "sound_localization_threshold": "Sound_localization_threshold.deg"}
    for t in read_csv(SRC["H2020_text"]):
        meas = tmap.get(t["trait"])
        if not meas:
            continue                              # hearing_range is derived -- recomputed below
        add("Sylvilagus floridanus", meas, t["value"], ITEM["H2020"], [], "published", "primary",
            "value stated in the paper's text, not read off Figure 3",
            basis="behavioural_audiogram" if meas.startswith("Audible") else "behavioural_threshold",
            group="audiogram_behavioural" if meas.startswith("Audible")
                  else "localization_behavioural")

    # ---- 4b. van Haarlem et al 2026 -- critical flicker fusion --------------------------
    # A SECONDARY compilation: 280 published CFF measurements, each row naming the primary
    # study it came from in `primary_reference`. Handled like Kaufman/Karbowski in the
    # cerebral-metabolic-rate merge -- pulled down to primary-study level so that a value
    # this compilation shares with a future directly-harvested primary dedupes rather than
    # being averaged twice. No CFF primaries are built in the repo yet, so every value here
    # is currently compilation-sourced with its primary named; per the folder README the
    # high-value primaries should be built from `primary_reference` and preferred, at which
    # point this item becomes the comparison fixture.
    #
    # The `method` column splits the measure in two: a behavioural CFF is a psychophysical
    # threshold, a flicker electroretinogram is an evoked electrical response, and the two
    # are not averaged. MAMMAL GATE: the source spans 16 classes (insects, fish and
    # crustaceans outnumber mammals), and this repo is mammal-scoped, so non-mammals stay
    # in the source table -- they are not harvested here.
    for r in read_csv(SRC["Haarlem2026"]):
        if r["class"].strip().lower() != "mammalia":
            continue
        meth = r["method"].strip()
        prim = ref_key(r["primary_reference"])
        add(r["Species"], "CFF.Hz", r["cff_hz"], ITEM["Haarlem2026"],
            [prim] if prim else [], "published", "secondary",
            population=r["common_name"], column="cff_hz", selector=meth)

    # ---- 4d. the rest of the attributable Heffner-lab items ----------------------------
    for folder, table, spcol, cols in HEFFNER_EXTRA:
        path = os.path.join(BASE, folder, f"{folder}_{table}.csv")
        if not os.path.exists(path):
            raise SystemExit(f"declared Heffner item not found: {path}")
        item = f"{folder}_{table}"
        for r in read_csv(path):
            sp = r.get(spcol, "").strip()
            if not sp:
                continue
            role = (r.get("data_role") or "").strip().lower()
            # "secondary (derived)" is a recomputed value, not a measurement -- the merge
            # recomputes hearing range itself, so a derived row would double-count
            if role.startswith("secondary (derived)"):
                continue
            keys = split_refs(r.get("source", ""))
            own = (not keys) or keys == ["SELF"]
            for vcol, meas, scale in cols:
                raw = r.get(vcol, "")
                v = num(raw)
                if v is None:
                    continue
                add(sp, meas, v * scale, item,
                    [] if own else [k for k in keys if k != "SELF"],
                    "published", "primary" if own else "secondary",
                    note="" if scale == 1.0 else f"converted to {UNITS[meas]} from the printed {vcol}",
                    population=r.get("common_name", ""), column=vcol)

    # ---- 4c. resolve an unstated method from another source that states it --------------
    # A primary study's method does not change depending on which compilation cites it.
    # Heffner & Heffner's footnoted acuities name the study they took each value from but
    # not how it measured, while Veilleux & Kirk's printed cone-density footnote asserts a
    # basis for every acuity it carries, including the ones it compiled. Where the two
    # report the SAME primary study for the same species, the stated basis resolves the
    # unstated one -- otherwise the same measurement sits under two different measures and
    # escapes the dedupe below, which is how it behaved before this pass existed
    # (Felis catus via jacobson1976, Meriones unguiculatus via baker1983).
    #
    # Recorded, not silent: every upgrade goes to sensory_method_resolution_report.csv.
    stated = defaultdict(set)     # (species, measure family) -> stated (basis, group)
    for r in rows:
        if r["method_basis"] != "unstated_external_source":
            for k in r["Study_keys_list"]:
                stated[(r["Species"], r["Measure"].split("_")[0], key_of(k))].add(
                    (r["method_basis"], r["poolable_group"]))
    resolved = []
    for r in rows:
        if r["method_basis"] != "unstated_external_source":
            continue
        cands = set()
        for k in r["Study_keys_list"]:
            cands |= stated.get((r["Species"], r["Measure"].split("_")[0], key_of(k)), set())
        if len(cands) == 1:                       # unambiguous: adopt it
            basis, group = cands.pop()
            resolved.append(dict(Species=r["Species"], Measure_before=r["Measure"],
                                 Source_item=r["Source_item"], Study_key=r["Study_key"],
                                 basis_before=r["method_basis"], basis_after=basis,
                                 Measure_after=BASIS_MEASURE.get(group, r["Measure"]),
                                 basis_stated_by="another source reporting the same "
                                                 "primary study"))
            r["method_basis"], r["poolable_group"] = basis, group
            r["Measure"] = BASIS_MEASURE.get(group, r["Measure"])


    # ---- 4e. errata flags on the study rows (see ERRATA FLAGS above) ------------------
    errata = load_errata(BASE)
    attach_errata(rows, errata)
    items_in_merge = {r["Source_item"] for r in rows}
    flagged_by_id = Counter(eid for r in rows if r["errata_id"] for eid in r["errata_id"].split("; "))
    errata_report = sorted(({"paper": e["paper"], "errata_id": e["errata_id"], "item": e["item"],
                             "variable": e["variable"], "locator": e["locator"],
                             "issue_type": e["issue_type"], "status": e["status"],
                             "proposed_value": e["proposed_value"],
                             "item_in_merge": e["item"] in items_in_merge,
                             "study_rows_flagged": flagged_by_id.get(e["errata_id"], 0)}
                            for e in errata), key=lambda d: d["errata_id"])

    # ---- 5. dedupe studies reported by more than one source ----------------------------
    for r in rows:
        if r["Study_key"] == "SELF":
            # the paper's own measurement: unique per printed row, so two populations
            # measured in one paper are not mistaken for one study reported twice
            r["Study_key"] = "SELF:" + r["Source_item"] + (":" + r["population"] if r["population"] else "")
    # Two reported values are the SAME underlying measurement when they share at
    # least one primary study, so dedupe on set intersection rather than on an
    # exact key string (a source may cite one study where another cites two).
    # Rows from the SAME source item are never collapsed -- within one paper, two
    # rows for a species are two distinct measurements (e.g. wild vs domestic rat).
    groups = defaultdict(list)
    for r in rows:
        groups[(r["Species"], r["Measure"], r["Medium"])].append(r)
    kept, dropped = [], []
    for _, rs in groups.items():
        keep_here = []
        for r in rs:
            mine = [k for k in r["Study_keys_list"]]
            clash = None
            if mine:
                for q in keep_here:
                    if q["Source_item"] == r["Source_item"]:
                        continue
                    if any(compatible(a, b) for a in mine for b in q["Study_keys_list"]):
                        clash = q; break
            if clash is not None:
                dropped.append({**r, "kept_from": clash["Source_item"],
                                # match R's write.csv, which prints an integral double
                                # without a trailing ".0"
                                "kept_value": int(clash["Value"])
                                if float(clash["Value"]).is_integer() else clash["Value"],
                                "shared_study": next(key_of(a) for a in mine
                                                     for b in clash["Study_keys_list"]
                                                     if compatible(a, b)),
                                "agrees": "TRUE" if abs(clash["Value"] - r["Value"]) <=
                                          0.05 * max(abs(clash["Value"]), 1e-9) else "FALSE"})
                continue
            keep_here.append(r)
        kept.extend(keep_here)

    # ---- 5b. within ONE lab, the most recent measurement supersedes ----------------------
    # __HOWTO section 10 conflict rubric: within a single collection/lab, a revised value
    # supersedes the earlier one (rules 1 + 4); across independent labs, average. The
    # Heffner/Koay lab produced most of this corpus and re-measured some species across
    # decades, so those cells are resolved by date rather than averaged.
    ITEM_YEAR = {f"{f}_{t}": int(re.search(r"(19|20)\d{2}", f).group(0))
                 for f, t, _, _ in HEFFNER_EXTRA}
    ITEM_YEAR.update({ITEM["HH1992a"]: 1992, ITEM["VK2014"]: 2014,
                      ITEM["Koay1998"]: 1998, ITEM["H2020"]: 2020,
                      ITEM["Haarlem2026"]: 2026})
    # every declared item above is from the same lab, so the "a later measurement by the
    # same lab supersedes an earlier one" rule has to cover them too
    HEFFNER_LAB_ITEMS = ({ITEM["HH1992a"], ITEM["Koay1998"], ITEM["H2020"]}
                         | {f"{f}_{t}" for f, t, _, _ in HEFFNER_EXTRA})

    def study_year(r):
        yrs = [int(y) for k in r["Study_keys_list"] for y in re.findall(r"(1[89]\d{2}|20\d{2})", k)]
        return max(yrs) if yrs else ITEM_YEAR.get(r["Source_item"], 0)

    def heffner_lab(r):
        if not r["Study_keys_list"]:
            return r["Source_item"] in HEFFNER_LAB_ITEMS
        return all(re.match(r"(heffner|koay)", key_of(k)) for k in r["Study_keys_list"])

    # Recency only decides between values of COMPARABLE provenance. A number read off a
    # figure is a reading of a plotted point, so it carries the digitisation error on top of
    # whatever the lab measured; a number printed in a table does not. Letting the later
    # paper win regardless would have replaced Heffner & Heffner 1992a's printed interaural
    # distances (Elephas 3350 us, Homo 875 us) with Koay 1998's digitised readings of the
    # same lab's figure (3378.09, 870.54) for 23 species -- a later value, but a less exact
    # one. So a printed value is never superseded by a digitised one; within one provenance
    # tier, the later measurement still wins.
    ORIGIN_RANK = {"published": 2, "recomputed": 1, "digitised_from_figure": 0}

    superseded = []
    groups2 = defaultdict(list)
    for r in kept:
        groups2[(r["Species"], r["Measure"], r["Medium"])].append(r)
    kept2 = []
    for _, rs in groups2.items():
        if len(rs) > 1 and all(heffner_lab(r) for r in rs):
            best_rank = max(ORIGIN_RANK.get(r["value_origin"], 0) for r in rs)
            tier = [r for r in rs if ORIGIN_RANK.get(r["value_origin"], 0) == best_rank]
            newest = max(study_year(r) for r in tier)
            winners = [q for q in tier if study_year(q) == newest]
            for r in rs:
                if r in winners:
                    kept2.append(r)
                else:
                    superseded.append({
                        **r, "superseded_by_year": newest,
                        "kept_value": winners[0]["Value"],
                        "superseded_reason": "lower-precision value origin"
                        if ORIGIN_RANK.get(r["value_origin"], 0) < best_rank
                        else "earlier measurement by the same lab"})
        else:
            kept2.extend(rs)
    kept = kept2

    # ---- 6. average across distinct primary studies -------------------------------------
    agg = defaultdict(list)
    for r in kept:
        agg[(r["Species"], r["Measure"], r["Medium"])].append(r)
    # merged cells pool rows across sources, so species_printed / species_basis list the
    # distinct printed labels / bases that resolved to the Species (SPECIES_NAMING.md v1)
    sp_cols = defaultdict(lambda: {"printed": set(), "acc": set(), "basis": set(), "reid": False})
    for r in rows:
        c = sp_cols[r["Species"]]
        c["printed"].add(r["species_printed"]); c["acc"].add(r["accepted_name"])
        c["basis"].add(r["species_basis"]); c["reid"] |= bool(r["reidentified"])

    def sp_summary(sp):
        c = sp_cols[sp]
        acc = sorted(a for a in c["acc"] if a)
        return {"species_printed": "; ".join(sorted(c["printed"])),
                "accepted_name": acc[0] if len(acc) == 1 else "; ".join(acc),
                "species_basis": "; ".join(sorted(b for b in c["basis"] if b)),
                "reidentified": c["reid"]}

    long_rows = []
    for (sp, meas, medium), rs in sorted(agg.items()):
        vals = [r["Value"] for r in rs]
        long_rows.append({
            "Species": sp, "Measure": meas, "Units": UNITS[meas], "Medium": medium,
            "Value": round(sum(vals) / len(vals), 6),
            "n_studies": len(rs),
            "Sources": "; ".join(sorted({r["Source_item"] for r in rs})),
            "Study_keys": "; ".join(sorted({r["Study_key"] for r in rs})),
            "Data_role": "primary" if all(r["Data_role"] == "primary" for r in rs)
                         else ("secondary" if all(r["Data_role"] == "secondary" for r in rs) else "mixed"),
            "value_origin": "; ".join(sorted({r["value_origin"] for r in rs})),
            "value_range": "" if len(set(vals)) == 1 else "%g-%g" % (min(vals), max(vals)),
            "method_basis": "; ".join(sorted({r["method_basis"] for r in rs})),
            "poolable_group": "; ".join(sorted({r["poolable_group"] for r in rs})),
            "errata_id": "; ".join(sorted({i for r in rs if r["errata_id"] for i in r["errata_id"].split("; ")})),
            "errata_status": "; ".join(sorted({x for r in rs if r["errata_status"] for x in r["errata_status"].split("; ")})),
            **sp_summary(sp),
        })

    # derived measure: hearing range in octaves, recomputed from the merged limits
    by_sp = defaultdict(dict)
    for r in long_rows:
        if r["Medium"] == "air":
            by_sp[r["Species"]][r["Measure"]] = r["Value"]
    flags_sp = defaultdict(lambda: {"errata_id": set(), "errata_status": set()})
    for r in long_rows:
        if r["Medium"] == "air" and r["Measure"] in ("Audible_freq_high_60dB.kHz", "Audible_freq_low_60dB.kHz"):
            for c in ("errata_id", "errata_status"):
                flags_sp[r["Species"]][c] |= set(x for x in r[c].split("; ") if x)
    for sp, m in sorted(by_sp.items()):
        hi, lo = m.get("Audible_freq_high_60dB.kHz"), m.get("Audible_freq_low_60dB.kHz")
        if hi and lo and lo > 0:
            long_rows.append({
                "Species": sp, "Measure": "Hearing_range.octaves", "Units": "octaves", "Medium": "air",
                "Value": round(math.log2(hi / lo), 6), "n_studies": 0,
                "Sources": "DERIVED from the merged limits", "Study_keys": "",
                "Data_role": "derived", "value_origin": "recomputed", "value_range": "",
                # recomputed from two behavioural audiogram limits, so it inherits their basis
                "method_basis": "behavioural_audiogram",
                "poolable_group": "audiogram_behavioural",
                "errata_id": "; ".join(sorted(flags_sp[sp]["errata_id"])),
                "errata_status": "; ".join(sorted(flags_sp[sp]["errata_status"])),
                **sp_summary(sp)})

    long_rows.sort(key=lambda r: (r["Species"], r["Measure"], r["Medium"]))

    # ---- 7. write outputs ----------------------------------------------------------------
    def w(path, fieldnames, data):
        with open(os.path.join(HERE, path), "w", newline="", encoding="utf-8") as f:
            wr = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
            wr.writeheader(); wr.writerows(data)

    w("sensory_long.csv", ["Species", "Measure", "Units", "Value", "Medium", "method_basis",
                           "poolable_group", "n_studies", "Sources", "Study_keys", "Data_role",
                           "value_origin", "value_range",
                           "species_printed", "accepted_name", "species_basis",
                           "reidentified", "errata_id", "errata_status"], long_rows)
    w("sensory_unfiltered.csv", ["Species", "Measure", "Value", "Medium", "method_basis",
                                 "poolable_group", "population", "Source_item", "Study_key",
                                 "value_origin", "Data_role", "note",
                                 "errata_id", "errata_status", "errata_issue_type"], rows)
    w("sensory_errata_report.csv", ["paper", "errata_id", "item", "variable", "locator", "issue_type",
                                    "status", "proposed_value", "item_in_merge", "study_rows_flagged"],
      errata_report)
    w("sensory_method_resolution_report.csv",
      ["Species", "Measure_before", "Measure_after", "Source_item", "Study_key",
       "basis_before", "basis_after", "basis_stated_by"], resolved)
    w("sensory_superseded_report.csv", ["Species", "Measure", "Value", "Medium", "Source_item",
                                        "Study_key", "value_origin", "superseded_reason",
                                        "superseded_by_year", "kept_value"], superseded)
    w("sensory_dedupe_report.csv", ["Species", "Measure", "Value", "Medium", "Source_item",
                                    "Study_key", "shared_study", "kept_from", "kept_value",
                                    "agrees"], dropped)

    measures = sorted({r["Measure"] for r in long_rows})
    species = sorted(by_sp) or []
    all_sp = sorted({r["Species"] for r in long_rows})
    with open(os.path.join(HERE, "sensory_wide.csv"), "w", newline="", encoding="utf-8") as f:
        wr = csv.writer(f)
        wr.writerow(["Species"] + measures)
        idx = defaultdict(dict)
        for r in long_rows:
            if r["Medium"] == "air":          # wide table is in-air only; see sensory_long.csv
                idx[r["Species"]][r["Measure"]] = r["Value"]
        for sp in all_sp:
            wr.writerow([sp] + [idx[sp].get(m, "") for m in measures])

    print("study-level rows:", len(rows), "| dropped as shared studies:", len(dropped),
          "| superseded within the Heffner lab:", len(superseded), "| kept:", len(kept))
    print("species:", len(all_sp), "| merged rows:", len(long_rows))
    print(Counter(r["Measure"] for r in long_rows))
    print("multi-study cells:", sum(1 for r in long_rows if r["n_studies"] > 1))

if __name__ == "__main__":
    main()
