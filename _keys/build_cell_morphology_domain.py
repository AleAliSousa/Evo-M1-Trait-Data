#!/usr/bin/env python3
"""build_cell_morphology_domain.py -- classify the __merging_cell_morphology variables.

WHY THIS IS GENERATED AND NOT TYPED OUT

The merge emits 270 app variables, one per region x layer x cell type x measure x
method. Typing 270 rows into variable_domain.csv by hand would (a) go stale the next
time the merge is rebuilt and (b) require me to decide, 270 times, what each variable
measures -- when the merge already records that in structured columns. Everything
below is DERIVED from the merge's own metadata:

    domain / measure_class   <- cell_morphology_definitions.csv `applies_to`
    Structure                <- the long table's `region`
    Measure, Unit            <- `measure`, `unit`
    poolable_family          <- `measure`            (the quantity)
    poolable_group           <- `measure` + `method_class`  (the quantity AS MEASURED)
    definition               <- cell_morphology_definitions.csv `definition`, via glossary

Nothing here invents a meaning. An `applies_to` value that is not in CLASS_OF stops
the build rather than being bucketed into a default, for the same reason
build_sensory_method_basis.py refuses an unrecorded basis: a silent default is how a
wrong classification gets shipped.

POOLABLE GROUP / FAMILY. Same contract as brain size and the sensory merge: the app
warns when two axes are candidate estimates of the SAME quantity obtained by
DIFFERENT methods. Here that is real for four measures -- soma_area (Golgi tracing vs
stereology), soma_volume (Nissl perikaryal volumetry vs stereology), spine_count
(Lucifer Yellow injection vs Golgi) and ven_pct (optical fractionator vs Nissl
counts). Two regions measured the same way do not warn; the same region measured two
ways does.

Outputs (both rewritten idempotently -- re-running replaces this merge's block and
leaves every other row alone):
  _keys/variable_domain.csv   270 rows tagged dataset = "cell morphology"
  _keys/glossary.csv          27 measure terms, so the definitions builder can compose
                              a definition for a label whose name matches no source Code

Run:  python3 _keys/build_cell_morphology_domain.py
Then: Rscript _keys/build_variable_definitions.R && Rscript __ShinyApp/build_data.R
"""
import csv
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)
MERGE = os.path.join(BASE, "__merging_cell_morphology")
LONG = os.path.join(MERGE, "cell_morphology_long.csv")
DEFS = os.path.join(MERGE, "cell_morphology_definitions.csv")
DOMAIN = os.path.join(HERE, "variable_domain.csv")
GLOSSARY = os.path.join(HERE, "glossary.csv")

DATASET = "cell morphology"
DOMAIN_NAME = "cellular morphology"

# `applies_to` (the merge's own grouping of its measures) -> measure_class.
# interlaminar_astrocytes and neuron_number already exist in variable_domain.csv and are
# reused rather than duplicated under a new name.
CLASS_OF = {
    "neuron soma": "soma_morphometry",
    "dendritic arbor": "dendritic_arbor",
    "basal dendritic arbor": "dendritic_arbor",
    "dendritic spines": "dendritic_spines",
    "VEN": "von_economo_neurons",
    "fork cell": "von_economo_neurons",
    "all neurons": "neuron_number",
    "interlaminar astrocyte": "interlaminar_astrocytes",
}

# method_class -> how that method obtained the number, for the tooltip's basis line.
# Taken from the `method` strings the merge records, condensed to one clause each.
METHOD_NOTE = {
    "golgi": "Golgi somatodendritic tracing",
    "LYinj": "intracellular Lucifer Yellow injection in tangential slices (Elston protocol)",
    "stereology": "unbiased stereology (nucleator/rotator probe)",
    "nissl_perikaryal": "Nissl perikaryal volumetry",
    "nissl_count": "Nissl counts in layer V",
    "fractionator": "optical fractionator, Nissl",
    "GFAP": "GFAP immunohistochemistry with Neurolucida 3-D reconstruction",
    "HRP": "retrograde HRP labelling from a spinal hemisection",
}


def read(path, **kw):
    with open(path, encoding="utf-8-sig", newline="") as fh:
        return list(csv.DictReader(fh, **kw))


def app_rows():
    """The rows the Shiny app actually shows.

    This mirrors the filter in std_cell_morphology() in __ShinyApp/app.R. If that
    filter changes, this must change with it -- the count assertion at the end is
    what catches a drift.
    """
    out = []
    for r in read(LONG):
        if (r["merge_default"] or "").strip().upper() not in ("TRUE", "1"):
            continue
        if r["statistic"] not in ("mean", "estimate", "value", "category"):
            continue
        if r["taxon_level"] != "species":
            continue
        if not ((r["value"] or "").strip() or (r["value_text"] or "").strip()):
            continue
        out.append(r)
    return out


def main():
    defs = {d["measure"]: d for d in read(DEFS)}
    rows = app_rows()

    unknown = sorted({d["applies_to"] for d in defs.values()} - set(CLASS_OF))
    if unknown:
        raise SystemExit(
            f"cell_morphology_definitions.csv has applies_to values with no measure_class "
            f"on record: {unknown}. Add them to CLASS_OF -- do not let them fall through.")

    # one variable_domain row per distinct app label
    seen, out = {}, []
    for r in rows:
        label = f"{r['variable_label']} ({r['unit']})"
        if label in seen:
            continue
        seen[label] = True
        meas = r["measure"]
        d = defs.get(meas)
        if d is None:
            raise SystemExit(f"measure {meas!r} has no row in cell_morphology_definitions.csv")
        mclass = CLASS_OF[d["applies_to"]]
        mc = r["method_class"]
        if mc not in METHOD_NOTE:
            raise SystemExit(f"method_class {mc!r} has no description on record; add it to "
                             f"METHOD_NOTE rather than shipping a variable with no basis")
        bits = [d["definition"]]
        if r["cell_type"]:
            bits.append(f"Cell type: {r['cell_type'].replace('_', ' ')}.")
        if r["layer"]:
            bits.append(f"Layer {r['layer']}.")
        bits.append(f"Measured by {METHOD_NOTE[mc]}.")
        out.append({
            "label": label,
            "dataset": DATASET,
            "domain": DOMAIN_NAME,
            "measure_class": mclass,
            "Structure": r["region"],
            "canonical_structure": r["region"],
            "Measure": meas,
            "Unit": r["unit"],
            "structure_qualifier": r["layer"],
            "structure_source": "__merging_cell_morphology/region_crosswalk.csv",
            "is_measurement": "TRUE",
            "note": " ".join(b for b in bits if b),
            # the quantity as measured / the quantity itself
            "poolable_group": f"{meas}__{mc}",
            "poolable_family": meas,
        })
    out.sort(key=lambda x: x["label"])

    # ---- write variable_domain.csv, replacing only this merge's block ----------------
    existing = read(DOMAIN)
    cols = list(existing[0].keys())
    missing = [c for c in out[0] if c not in cols]
    if missing:
        raise SystemExit(f"variable_domain.csv has no column(s) {missing}")
    kept = [r for r in existing if r.get("dataset") != DATASET]
    with open(DOMAIN, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=cols)
        w.writeheader()
        w.writerows(kept)
        w.writerows({c: r.get(c, "") for c in cols} for r in out)

    # ---- write the 27 measure terms into the glossary -------------------------------
    # The definitions builder resolves a label by looking for glossary terms inside it
    # (pass 3b), which is how a label like "ACC_fork_cell_fork_pct [nissl_count]" gets a
    # definition without matching any per-paper Code. The text is the merge's own.
    # Region names, for the structure half of the composed definition. ONLY the
    # crosswalk's canonical rows (region_printed == region), and only where the note is a
    # name rather than a provenance jotting -- three of the eight say "Raghanti 2015" or
    # name a table, which would otherwise be imported as if it were an anatomical name.
    import re as _re
    xw = read(os.path.join(MERGE, "region_crosswalk.csv"))
    region_name = {}
    for r in xw:
        if r["region_printed"].strip() != r["region"].strip():
            continue
        note = (r.get("note") or "").strip()
        if not note or _re.search(r"\b(19|20)\d{2}\b|printed label|Table", note):
            continue
        region_name[r["region"].strip()] = note

    gl = read(GLOSSARY)
    gcols = list(gl[0].keys())
    gkeep = [g for g in gl if g.get("source") != "__merging_cell_morphology/cell_morphology_definitions.csv"]
    gnew = []
    for meas, d in sorted(defs.items()):
        gnew.append({
            "term": meas,
            "expansion": d["definition"],
            "definition": d["definition"] + (f" Applies to: {d['applies_to']}."
                                             if d.get("applies_to") else ""),
            "kind": "measure code",
            "applies_to": DOMAIN_NAME,
            "common": "FALSE",
            "source": "__merging_cell_morphology/cell_morphology_definitions.csv",
            "note": d.get("note", ""),
        })
    for reg, name in sorted(region_name.items()):
        gnew.append({
            "term": reg, "expansion": name,
            "definition": f"{name} ({reg} in this repo's region vocabulary).",
            "kind": "structure", "applies_to": DOMAIN_NAME, "common": "FALSE",
            "source": "__merging_cell_morphology/cell_morphology_definitions.csv",
            "note": "canonical region name from __merging_cell_morphology/region_crosswalk.csv"})

    with open(GLOSSARY, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=gcols)
        w.writeheader()
        w.writerows(gkeep)
        w.writerows({c: g.get(c, "") for c in gcols} for g in gnew)

    from collections import Counter
    print(f"{len(out)} cell-morphology variables classified "
          f"({len(kept)} other variable_domain rows untouched)", file=sys.stderr)
    for k, n in sorted(Counter(r["measure_class"] for r in out).items()):
        print(f"  {k:26s} {n}", file=sys.stderr)
    split = {f: sorted({r['poolable_group'].split('__')[1] for r in out
                        if r['poolable_family'] == f})
             for f in {r["poolable_family"] for r in out}}
    multi = {f: m for f, m in split.items() if len(m) > 1}
    print(f"  quantities measured by more than one method (these warn when crossed): "
          f"{len(multi)}", file=sys.stderr)
    for f, m in sorted(multi.items()):
        print(f"    {f:26s} {m}", file=sys.stderr)
    print(f"  {len(gnew)} glossary terms written ({len(defs)} measures, "
          f"{len(region_name)} region names)", file=sys.stderr)


if __name__ == "__main__":
    main()
