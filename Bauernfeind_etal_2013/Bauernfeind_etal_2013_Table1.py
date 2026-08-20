#!/usr/bin/env python3
"""Offline mirror of Bauernfeind_etal_2013_Table1.R (the .R is canonical).
Applies the footnote split to the already-correct per-individual CSV, since the snapshot
xlsx has no sharedStrings part this reader can use; the numeric columns are unchanged."""
import csv, os, re, collections

BASE = "/sessions/practical-tender-fermat/mnt/Evo-M1-Trait-Data"
FOLDER = os.path.join(BASE, "Bauernfeind_etal_2013")
SRC = os.path.join(FOLDER, "_prerun_backup_2026-08-19", "Bauernfeind_etal_2013_Table1.csv")

FOOTNOTES = {"a": "Volumes estimated using StereoInvestigator software",
             "b": "Volumes estimated using ImageJ software",
             "c": "The left hemisphere was unavailable"}
MARK = re.compile(r"((?:a|b|c)(?:,(?:a|b|c))*)$")

rows = list(csv.DictReader(open(SRC, encoding="utf-8")))
out = []
for r in rows:
    pub = re.sub(r"\s+", " ", r["Individual"]).strip()
    m = MARK.search(pub)
    fn = m.group(1) if m else None
    ind = MARK.sub("", pub).strip()
    sw = ("StereoInvestigator" if fn and "a" in fn else
          "ImageJ" if fn and "b" in fn else None)
    rec = {"Species": r["Species"], "Individual": ind, "individual_as_published": pub,
           "footnote_ref": fn, "measurement_software": sw,
           "left_hemisphere_unavailable": "TRUE" if (fn and "c" in fn) else "FALSE"}
    for c in ["Collection", "section_thickness_mm", "age", "sex", "body_mass_g",
              "social_group_size", "brain_mass_mg", "brain_volume_mm3",
              "granular_L_mm3", "dysgranular_L_mm3", "agranular_L_mm3", "FI_L_mm3",
              "total_insula_L_mm3"]:
        rec[c] = r[c]
    out.append(rec)

assert all(r["footnote_ref"] for r in out), "a printed label carried no footnote marker"
assert all(r["measurement_software"] for r in out)
assert all(r["Individual"] for r in out)
keys = [(r["Species"], r["Individual"]) for r in out]
assert len(keys) == len(set(keys)), "duplicate Species x Individual"

# The point of the split: Table 2's individuals must now match Table 1's.
t2 = list(csv.DictReader(open(os.path.join(FOLDER, "Bauernfeind_etal_2013_Table2.csv"),
                              encoding="utf-8")))
left = {(r["Species"], r["Individual"]) for r in out}
unmatched = [(r["Species"], r["Individual"]) for r in t2
             if (r["Species"], r["Individual"]) not in left]
assert not unmatched, "Table 2 individuals with no Table 1 match: %s" % unmatched

COLS = (["Species", "Individual", "individual_as_published", "footnote_ref",
         "measurement_software", "left_hemisphere_unavailable", "Collection",
         "section_thickness_mm", "age", "sex", "body_mass_g", "social_group_size",
         "brain_mass_mg", "brain_volume_mm3", "granular_L_mm3", "dysgranular_L_mm3",
         "agranular_L_mm3", "FI_L_mm3", "total_insula_L_mm3"])
CHAR = {"Species", "Individual", "individual_as_published", "footnote_ref",
        "measurement_software", "Collection", "sex"}


def fmt(v, name):
    if v is None or v == "" or v == "NA":
        return "NA"
    if v in ("TRUE", "FALSE"):
        return v
    if name in CHAR:
        return '"%s"' % str(v).replace('"', '""')
    return "%.15g" % float(v)


def write_table(path, cols, recs, sep=","):
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(sep.join('"%s"' % c for c in cols) + "\n")
        for r in recs:
            f.write(sep.join(fmt(r.get(c), c) for c in cols) + "\n")


write_table(os.path.join(FOLDER, "Bauernfeind_etal_2013_Table1.csv"), COLS, out)
write_table(os.path.join(BASE, "__Public", "comparative-data",
                         "10.1016%2Fj.jhevol.2012.12.003_Table1.tsv"), COLS, out, sep="\t")
print("Wrote Bauernfeind_etal_2013_Table1.csv  (%d individuals, %d species)"
      % (len(out), len({r["Species"] for r in out})))
fc = collections.Counter(r["footnote_ref"] for r in out)
sc = collections.Counter(r["measurement_software"] for r in out)
print("  footnotes split off the specimen ID: "
      + ", ".join("%s=%d" % kv for kv in sorted(fc.items()))
      + "  ->  software: " + ", ".join("%s=%d" % kv for kv in sorted(sc.items())))
for k, v in FOOTNOTES.items():
    print("    %s = %s" % (k, v))
print("  Table 2 individuals matched into Table 1: %d/%d" % (len(t2), len(t2)))
