#!/usr/bin/env python3
"""Offline Python mirror of Heffner_etal_2020_Figure3.R (canonical).

No R in the build sandbox: this mirror generated the committed outputs using R's
write.csv/write.table conventions. Running the .R must reproduce them
byte-for-byte; delete this file once verified.

Inputs : Heffner_etal_2020_Figure3_snapshot.csv        (79 markers, vector-extracted)
         reference_tables/..._label_assignment.csv     (printed labels -> markers)
         reference_tables/..._cottontail_values_from_text.csv
Outputs: Heffner_etal_2020_Figure3.csv
         __Public/comparative-data/10.1007%2Fs00359-020-01424-8_Figure3.tsv
         comparison/..._vs_SensoryData_compiled.csv
"""
import csv, os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SNAP = os.path.join(HERE, "Heffner_etal_2020_Figure3_snapshot.csv")
ASSIGN = os.path.join(HERE, "reference_tables", "Heffner_etal_2020_Figure3_label_assignment.csv")
TEXTVALS = os.path.join(HERE, "reference_tables", "Heffner_etal_2020_cottontail_values_from_text.csv")
OUT_CSV = os.path.join(HERE, "Heffner_etal_2020_Figure3.csv")
OUT_TSV = os.path.join(ROOT, "__Public", "comparative-data",
                       "10.1007%2Fs00359-020-01424-8_Figure3.tsv")
CHECK = os.path.join(ROOT, "____Sensory_audiovisual", "SensoryData_compiled_check",
                     "SensoryData_compiled.csv")

# labels that are not species: a group heading, and two adjacent labels the
# character clustering merged into one block
GROUP_HEADERS = {"Prairiedogs"}
MERGED_LABELS = {"PigReindeer": "Pig / Reindeer (two adjacent labels; marker not resolvable between them)"}
# printed label -> readable species name (the figure prints common names only)
READABLE = {
    "Blindmolerat": "Blind mole rat", "Commonvampirebat": "Common vampire bat",
    "Cottonrat": "Cotton rat", "Darwin'smouse": "Darwin's mouse",
    "Dog-facedfruitbat": "Dog-faced fruit bat", "Domesticmouse": "Domestic mouse",
    "Domesticrabbit": "Domestic rabbit", "Egyptianfruitbat": "Egyptian fruit bat",
    "Foxsquirrel": "Fox squirrel", "Guineapig": "Guinea pig", "Hoodedrat": "Hooded rat",
    "Jamaicanfruitbat": "Jamaican fruit bat", "Kangaroorat": "Kangaroo rat",
    "Killerwhale": "Killer whale", "Nakedmolerat": "Naked mole rat",
    "Short-tailedfruitbat": "Short-tailed fruit bat",
    "Straw-coloredfruitbat": "Straw-colored fruit bat", "White-taileddeer": "White-tailed deer",
    "Woodrat": "Wood rat", "Black-tailed": "Black-tailed prairie dog",
    "White-tailed": "White-tailed prairie dog",
}
# caption symbol scheme, applied from the species (not from the drawn path)
SUBTERRANEAN = {"Naked mole rat", "Gopher", "Blind mole rat"}
AQUATIC = {"Porpoise", "Killer whale"}
BATS = {"Short-tailed fruit bat", "Jamaican fruit bat", "Common vampire bat",
        "Egyptian fruit bat", "Dog-faced fruit bat", "Straw-colored fruit bat"}
RABBITS = {"Cottontail", "Domestic rabbit"}

def read_csv(p):
    with open(p, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def main():
    snap = read_csv(SNAP)
    assign = read_csv(ASSIGN)
    by_marker = {}
    for a in assign:
        by_marker.setdefault(a["marker_id"], []).append(a)

    header = ["marker_id", "functional_interaural_distance_us", "high_freq_hearing_limit_60dB_kHz",
              "species_label_as_printed", "label_confidence", "caption_group",
              "excluded_from_regression", "marker_filled", "marker_grey_fill",
              "value_origin", "note"]
    numeric = {"functional_interaural_distance_us", "high_freq_hearing_limit_60dB_kHz"}
    out = []
    for m in snap:
        labs = by_marker.get(m["marker_id"], [])
        names, conf, note = [], "", ""
        for a in labs:
            raw = a["label_as_printed"]
            if raw in GROUP_HEADERS:
                note = "printed group heading '%s' resolves here; the species labels are the two prairie dogs" % raw
                continue
            names.append(READABLE.get(raw, raw))
            conf = a["confidence"]
            if raw in MERGED_LABELS:
                note = MERGED_LABELS[raw]
        if len(names) > 1:
            conf = "AMBIGUOUS_marker_claimed_by_2_labels"
            note = (note + "; " if note else "") + "two printed labels resolve to this marker"
        name = " | ".join(names)
        grp = ""
        if name in SUBTERRANEAN: grp = "subterranean rodent (diamond)"
        elif name in AQUATIC: grp = "aquatic/amphibious (triangle)"
        elif name in BATS: grp = "bat (square)"
        elif name in RABBITS: grp = "rabbit (star)"
        elif name and m["grey_fill"] == "TRUE": grp = "rodent (grey fill)"
        out.append({
            "marker_id": m["marker_id"],
            "functional_interaural_distance_us": m["functional_interaural_distance_us"],
            "high_freq_hearing_limit_60dB_kHz": m["high_freq_hearing_limit_60dB_kHz"],
            "species_label_as_printed": name,
            "label_confidence": conf if name else "unlabelled_in_figure",
            "caption_group": grp,
            "excluded_from_regression": "TRUE" if name in SUBTERRANEAN else "",
            "marker_filled": m["filled"], "marker_grey_fill": m["grey_fill"],
            "value_origin": "digitised_from_figure",
            "note": note,
        })

    def write_r_style(path, sep):
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(sep.join('"%s"' % h for h in header) + "\n")
            for row in out:
                f.write(sep.join(row[h] if h in numeric else '"%s"' % row[h].replace('"', '""')
                                 for h in header) + "\n")
    write_r_style(OUT_CSV, ",")
    if os.path.isdir(os.path.dirname(OUT_TSV)):
        write_r_style(OUT_TSV, "\t")

    # ---- comparison vs the compiled sensory check fixture ---------------------
    os.makedirs(os.path.join(HERE, "comparison"), exist_ok=True)
    tv = {t["trait"]: t for t in read_csv(TEXTVALS)}
    check = [c for c in read_csv(CHECK) if "Heffner et al 2020" in c["reference"]]
    rep = []
    for c in check:
        t = tv.get(c["trait"])
        if t and "%.15g" % float(t["value"]) == "%.15g" % float(c["value_num"]):
            status = "agree_with_text_value"
        elif t:
            status = "differs_from_text_value"
        else:
            status = "trait_not_stated_in_text"
        rep.append([c["value_id"], c["Species_SensoryData"], c["trait"], c["value"],
                    t["value"] if t else "", status, c["comment"]])
    with open(os.path.join(HERE, "comparison",
                           "Heffner_etal_2020_Figure3_vs_SensoryData_compiled.csv"),
              "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, quoting=csv.QUOTE_ALL)
        w.writerow(["check_value_id", "check_species", "check_trait", "check_value",
                    "paper_text_value", "status", "check_comment"])
        w.writerows(rep)

    from collections import Counter
    print("markers:", len(out), "| labelled:", sum(1 for r in out if r["species_label_as_printed"]))
    print(Counter(r["label_confidence"] for r in out))
    print("check rows:", len(rep), Counter(r[5] for r in rep))

if __name__ == "__main__":
    main()
