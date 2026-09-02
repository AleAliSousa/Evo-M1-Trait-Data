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
import csv, os, re, math
from collections import defaultdict, Counter

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)

SRC = {
    "HH1992a": os.path.join(BASE, "Heffner_Heffner_1992_a", "Heffner_Heffner_1992_a_Table1.csv"),
    "HH1992a_footnotes": os.path.join(BASE, "Heffner_Heffner_1992_a", "reference_tables",
                                      "Heffner_Heffner_1992_a_Table1_footnotes.csv"),
    "VK2014":  os.path.join(BASE, "Veilleux_Kirk_2014", "Veilleux_Kirk_2014_SupplementalTable1.csv"),
    "VK2014_sources": os.path.join(BASE, "Veilleux_Kirk_2014", "reference_tables",
                                   "Veilleux_Kirk_2014_SupplementalTable1_data_sources.csv"),
    "VK2014_xwalk": os.path.join(BASE, "Veilleux_Kirk_2014", "reference_tables",
                                 "Veilleux_Kirk_2014_SupplementalTable1_species_crosswalk.csv"),
    "Koay1998": os.path.join(BASE, "Koay_etal_1998", "Koay_etal_1998_Figure6.csv"),
    "H2020_text": os.path.join(BASE, "Heffner_etal_2020", "reference_tables",
                               "Heffner_etal_2020_cottontail_values_from_text.csv"),
}
ITEM = {"HH1992a": "Heffner_Heffner_1992_a_Table1",
        "VK2014": "Veilleux_Kirk_2014_SupplementalTable1",
        "Koay1998": "Koay_etal_1998_Figure6",
        "H2020": "Heffner_etal_2020_Figure3"}

UNITS = {"Audible_freq_high_60dB.kHz": "kHz", "Audible_freq_low_60dB.kHz": "kHz",
         "Sound_localization_threshold.deg": "deg", "Visual_acuity.cdeg": "c/deg",
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

def main():
    rows = []   # study-level rows, before dedupe

    def add(species, measure, value, item, study_keys, origin, role, note="", medium="air",
            population=""):
        v = num(value) if not isinstance(value, float) else value
        if v is None or not species:
            return
        rows.append({"Species": canon_species(species), "Measure": measure, "Value": v,
                     "Medium": medium, "Source_item": item,
                     "Study_keys_list": list(study_keys),
                     "Study_key": "+".join(study_keys) if study_keys else "SELF",
                     "population": population,
                     "value_origin": origin, "Data_role": role, "note": note})

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
            [], "published", "primary", population=pop)
        add(sp, "Binocular_field.deg", r["binocular_field_deg"], ITEM["HH1992a"],
            [], "published", "primary", population=pop)
        # localization thresholds: all compiled, each with its printed footnote source
        add(sp, "Sound_localization_threshold.deg", r["sound_localization_threshold_deg"],
            ITEM["HH1992a"], hh_keys.get(r["threshold_footnote"], []),
            "published", "secondary", population=pop)
        # acuity: unfootnoted = this paper's own ganglion-cell estimate; footnoted = compiled
        if r["acuity_footnote"].strip():
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["HH1992a"],
                hh_keys.get(r["acuity_footnote"], []), "published", "secondary", population=pop)
        else:
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["HH1992a"],
                [], "published", "primary", population=pop)

    # ---- 2. Veilleux & Kirk 2014 Supplemental Table 1 ----------------------------------
    vk_src = {s["source_number"]: s["citation"] for s in read_csv(SRC["VK2014_sources"])}
    vk_xw = {x["species_as_published"].lower(): x["corrected_binomial"]
             for x in read_csv(SRC["VK2014_xwalk"])}
    for r in read_csv(SRC["VK2014"]):
        sp = vk_xw.get(r["Species_VK2014"].lower(), r["Species_VK2014"])
        src = r["src_VA"]
        if r["va_this_study"] == "TRUE":
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["VK2014"],
                [], "published", "primary")
        else:
            nums = re.findall(r"\d+", src)
            keys = []
            for n in nums:
                c = vk_src.get(n)
                if c:
                    k = ref_key(c)
                    if k and k not in keys: keys.append(k)
            add(sp, "Visual_acuity.cdeg", r["visual_acuity_cdeg"], ITEM["VK2014"],
                keys, "published", "secondary")

    # ---- 3. Koay et al 1998 Figure 6 ----------------------------------------------------
    for r in read_csv(SRC["Koay1998"]):
        sp = r["corrected_binomial"]
        keys = split_refs(r["audiogram_source"])
        primary = keys == ["SELF"]
        add(sp, "Audible_freq_high_60dB.kHz", r["high_freq_hearing_limit_60dB_kHz"],
            ITEM["Koay1998"], [] if primary else [k for k in keys if k != "SELF"],
            "digitised_from_figure", "primary" if primary else "secondary",
            medium=r["medium"] or "air", population=r["common_name_Koay1998"])

    # ---- 4. Heffner et al 2020 -- Cottontail values FROM TEXT ---------------------------
    tmap = {"audible_freq_high_60dBSPL": "Audible_freq_high_60dB.kHz",
            "audible_freq_low_60dBSPL": "Audible_freq_low_60dB.kHz",
            "sound_localization_threshold": "Sound_localization_threshold.deg"}
    for t in read_csv(SRC["H2020_text"]):
        meas = tmap.get(t["trait"])
        if not meas:
            continue                              # hearing_range is derived -- recomputed below
        add("Sylvilagus floridanus", meas, t["value"], ITEM["H2020"], [], "published", "primary",
            "value stated in the paper's text, not read off Figure 3")

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
                                "kept_value": clash["Value"],
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
    ITEM_YEAR = {ITEM["HH1992a"]: 1992, ITEM["VK2014"]: 2014,
                 ITEM["Koay1998"]: 1998, ITEM["H2020"]: 2020}
    HEFFNER_LAB_ITEMS = {ITEM["HH1992a"], ITEM["Koay1998"], ITEM["H2020"]}

    def study_year(r):
        yrs = [int(y) for k in r["Study_keys_list"] for y in re.findall(r"(1[89]\d{2}|20\d{2})", k)]
        return max(yrs) if yrs else ITEM_YEAR.get(r["Source_item"], 0)

    def heffner_lab(r):
        if not r["Study_keys_list"]:
            return r["Source_item"] in HEFFNER_LAB_ITEMS
        return all(re.match(r"(heffner|koay)", key_of(k)) for k in r["Study_keys_list"])

    superseded = []
    groups2 = defaultdict(list)
    for r in kept:
        groups2[(r["Species"], r["Measure"], r["Medium"])].append(r)
    kept2 = []
    for _, rs in groups2.items():
        if len(rs) > 1 and all(heffner_lab(r) for r in rs):
            newest = max(study_year(r) for r in rs)
            for r in rs:
                if study_year(r) < newest:
                    superseded.append({**r, "superseded_by_year": newest,
                                       "kept_value": [q["Value"] for q in rs
                                                      if study_year(q) == newest][0]})
                else:
                    kept2.append(r)
        else:
            kept2.extend(rs)
    kept = kept2

    # ---- 6. average across distinct primary studies -------------------------------------
    agg = defaultdict(list)
    for r in kept:
        agg[(r["Species"], r["Measure"], r["Medium"])].append(r)
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
        })

    # derived measure: hearing range in octaves, recomputed from the merged limits
    by_sp = defaultdict(dict)
    for r in long_rows:
        if r["Medium"] == "air":
            by_sp[r["Species"]][r["Measure"]] = r["Value"]
    for sp, m in sorted(by_sp.items()):
        hi, lo = m.get("Audible_freq_high_60dB.kHz"), m.get("Audible_freq_low_60dB.kHz")
        if hi and lo and lo > 0:
            long_rows.append({
                "Species": sp, "Measure": "Hearing_range.octaves", "Units": "octaves", "Medium": "air",
                "Value": round(math.log2(hi / lo), 6), "n_studies": 0,
                "Sources": "DERIVED from the merged limits", "Study_keys": "",
                "Data_role": "derived", "value_origin": "recomputed", "value_range": ""})

    long_rows.sort(key=lambda r: (r["Species"], r["Measure"], r["Medium"]))

    # ---- 7. write outputs ----------------------------------------------------------------
    def w(path, fieldnames, data):
        with open(os.path.join(HERE, path), "w", newline="", encoding="utf-8") as f:
            wr = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
            wr.writeheader(); wr.writerows(data)

    w("sensory_long.csv", ["Species", "Measure", "Units", "Value", "Medium", "n_studies",
                           "Sources", "Study_keys", "Data_role", "value_origin", "value_range"], long_rows)
    w("sensory_unfiltered.csv", ["Species", "Measure", "Value", "Medium", "population",
                                 "Source_item", "Study_key", "value_origin", "Data_role", "note"], rows)
    w("sensory_superseded_report.csv", ["Species", "Measure", "Value", "Medium", "Source_item",
                                        "Study_key", "superseded_by_year", "kept_value"], superseded)
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
