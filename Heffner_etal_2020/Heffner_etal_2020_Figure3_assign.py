#!/usr/bin/env python3
"""Assign the printed species labels of Heffner et al. (2020) Figure 3 to the
extracted markers, and validate the assignment against an independent source.

Run after Heffner_etal_2020_Figure3_extract.py. Writes
reference_tables/Heffner_etal_2020_Figure3_label_assignment.csv.

Method: a label is joined to a marker by following its printed leader line when
one starts at the label box, otherwise by nearest marker to the label box.
Every assignment is then VALIDATED against Koay_etal_1998_Figure6.csv, which
plots the same two variables for many of the same species from an independent
digitisation: agreement within a few percent confirms the assignment, a large
disagreement flags it for visual checking (reported, never silently accepted).
"""
import pdfplumber, csv, os, math

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PDF = os.path.join(HERE, "Heffner-2020-Hearing and sound localization in.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2020_Figure3_snapshot.csv")
OUT = os.path.join(HERE, "reference_tables", "Heffner_etal_2020_Figure3_label_assignment.csv")
KOAY = os.path.join(ROOT, "Koay_etal_1998", "Koay_etal_1998_Figure6.csv")
PAGE = 5

# label text as printed (interleaved two-line labels repaired) -> printed form
FIXES = {"ildmouse": "Wild mouse", "Gmroausssheopper": "Grasshopper mouse"}
SKIP = ("Journal", "Log(y)", "r=", "n=74")

# printed label -> the species it names, for validation against Koay Fig 6
KOAY_MATCH = {
    "Human": "Homo sapiens", "Elephant": "Elephas maximus", "Cat": "Felis catus",
    "Horse": "Equus caballus", "Cattle": "Bos taurus", "Goat": "Capra hircus",
    "Pig": "Sus scrofa", "Chinchilla": "Chinchilla laniger", "Guineapig": "Cavia porcellus",
    "Gerbil": "Meriones unguiculatus", "Hamster": "Mesocricetus auritus",
    "Kangaroorat": "Dipodomys merriami", "Woodrat": "Neotoma floridana",
    "Cottonrat": "Sigmodon hispidus", "Grasshopper mouse": "Onychomys leucogaster",
    "Spinymouse": "Acomys cahirinus", "Darwin'smouse": "Phyllotis darwini",
    "Wild mouse": "Mus musculus", "Domesticmouse": "Mus musculus",
    "Hoodedrat": "Rattus norvegicus", "Foxsquirrel": "Sciureus niger",
    "Chipmunk": "Tamias striatus", "Groundhog": "Marmota monax",
    "White-tailed": "Cynomys leucurus", "Black-tailed": "Cynomys ludovicianus",
    "Nakedmolerat": "Heterocephalus glaber", "Gopher": "Geomys bursarius",
    "Blindmolerat": "Spalax ehrenbergi", "Domesticrabbit": "Oryctolagus cuniculus",
    "Cottontail": "Sylvilagus floridana", "Egyptianfruitbat": "Rousettus aegyptiacus",
    "Chimpanzee": "Pan troglodytes", "Porpoise": "Tursiops truncatus",
    "Killerwhale": "Orcina orca",
}

def label_blocks(page):
    chars = [c for c in page.chars if c["x0"] > 240 and c["top"] < 310 and c["text"].strip()]
    chars.sort(key=lambda c: (c["x0"], c["top"]))
    parent = list(range(len(chars)))
    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]; a = parent[a]
        return a
    for i, a in enumerate(chars):
        for j in range(i + 1, len(chars)):
            b = chars[j]
            if b["x0"] - a["x1"] > 4:
                break
            if (min(a["bottom"], b["bottom"]) - max(a["top"], b["top"])) > 1.5 \
               and -1.5 <= b["x0"] - a["x1"] <= 3.2:
                ra, rb = find(i), find(j)
                if ra != rb: parent[rb] = ra
    groups = {}
    for i, c in enumerate(chars):
        groups.setdefault(find(i), []).append(c)
    out = []
    for v in groups.values():
        v.sort(key=lambda c: c["x0"])
        txt = "".join(c["text"] for c in v)
        if any(txt.startswith(s) for s in SKIP):
            continue
        out.append({"text": FIXES.get(txt, txt),
                    "x0": min(c["x0"] for c in v), "x1": max(c["x1"] for c in v),
                    "top": min(c["top"] for c in v), "bottom": max(c["bottom"] for c in v)})
    return out

def main():
    markers = list(csv.DictReader(open(SNAP, newline="", encoding="utf-8")))
    with pdfplumber.open(PDF) as pdf:
        page = pdf.pages[PAGE]
        labels = label_blocks(page)
        # leader lines: thin segments inside the plot area that are not axis ticks
        leaders = []
        for l in page.lines + page.curves:
            x0, x1, t, b = l["x0"], l["x1"], l["top"], l["bottom"]
            length = math.hypot(x1 - x0, b - t)
            if 4 < length < 80 and x0 > 240 and t > 55 and b < 310:
                if (b - t) < 0.6 and (x1 - x0) < 8:   # y-axis tick
                    continue
                # a line object gives only a bounding box, so a diagonal segment
                # may run corner (x0,top)->(x1,bottom) OR (x0,bottom)->(x1,top);
                # pts carries the true endpoints when present
                pts = l.get("pts")
                if pts and len(pts) >= 2:
                    leaders.append((tuple(pts[0]), tuple(pts[-1])))
                else:
                    leaders.append(((x0, t), (x1, b)))
                    leaders.append(((x0, b), (x1, t)))

    def near_box(pt, lab, pad=3.0):
        return (lab["x0"] - pad <= pt[0] <= lab["x1"] + pad
                and lab["top"] - pad <= pt[1] <= lab["bottom"] + pad)

    rows = []
    for lab in labels:
        lcx = (lab["x0"] + lab["x1"]) / 2; lcy = (lab["top"] + lab["bottom"]) / 2
        target, how = (lcx, lcy), "nearest_to_label"
        for a, b in leaders:
            if near_box(a, lab):
                target, how = b, "leader_line"; break
            if near_box(b, lab):
                target, how = a, "leader_line"; break
        best, bestd = None, 1e9
        for m in markers:
            d = math.hypot(float(m["page_x"]) - target[0], float(m["page_y"]) - target[1])
            if d < bestd:
                best, bestd = m, d
        rows.append({
            "label_as_printed": lab["text"], "marker_id": best["marker_id"],
            "assignment_method": how, "distance_pt": round(bestd, 2),
            "functional_interaural_distance_us": best["functional_interaural_distance_us"],
            "high_freq_hearing_limit_60dB_kHz": best["high_freq_hearing_limit_60dB_kHz"],
        })

    # ---- shape override: the caption states rabbits are drawn as STARS, and the
    # figure contains exactly two star paths (11 anchor points) for its two rabbit
    # labels. That pins both unambiguously, overriding the leader-line geometry --
    # and both overrides are independently confirmed: the Cottontail star reads
    # 56.17 kHz against the paper's own text value of 56 kHz, and the other star
    # reads 247.7 us / 49.5 kHz against Koay 1998's Oryctolagus 252.9 / 49.2.
    stars = sorted((m for m in markers if int(m["n_path_points"]) >= 10),
                   key=lambda m: float(m["page_x"]))
    rabbit_labels = [lab for lab in labels if lab["text"] in ("Cottontail", "Domesticrabbit")]
    if len(stars) == 2 and len(rabbit_labels) == 2:
        rabbit_labels.sort(key=lambda lab: lab["x0"])
        for lab, star in zip(rabbit_labels, stars):
            for r in rows:
                if r["label_as_printed"] == lab["text"]:
                    r["marker_id"] = star["marker_id"]
                    r["assignment_method"] = "star_symbol_caption"
                    r["distance_pt"] = ""
                    r["functional_interaural_distance_us"] = star["functional_interaural_distance_us"]
                    r["high_freq_hearing_limit_60dB_kHz"] = star["high_freq_hearing_limit_60dB_kHz"]

    # ---- validation against Koay et al 1998 Figure 6 (independent digitisation)
    koay = {}
    if os.path.exists(KOAY):
        for k in csv.DictReader(open(KOAY, newline="", encoding="utf-8")):
            if k["functional_interaural_distance_us"]:
                koay[k["Species_Koay1998"].lower()] = k
    for r in rows:
        sp = KOAY_MATCH.get(r["label_as_printed"])
        k = koay.get(sp.lower()) if sp else None
        if not k:
            r["validation"] = "no_koay_counterpart"; r["koay_us"] = ""; r["koay_kHz"] = ""
            r["pct_diff_us"] = ""; r["pct_diff_kHz"] = ""
            continue
        du = (float(r["functional_interaural_distance_us"]) - float(k["functional_interaural_distance_us"])) \
             / float(k["functional_interaural_distance_us"]) * 100
        dk = (float(r["high_freq_hearing_limit_60dB_kHz"]) - float(k["high_freq_hearing_limit_60dB_kHz"])) \
             / float(k["high_freq_hearing_limit_60dB_kHz"]) * 100
        r["koay_us"] = k["functional_interaural_distance_us"]
        r["koay_kHz"] = k["high_freq_hearing_limit_60dB_kHz"]
        r["pct_diff_us"] = round(du, 1); r["pct_diff_kHz"] = round(dk, 1)
        r["validation"] = "consistent_with_Koay1998" if abs(du) < 12 and abs(dk) < 12 \
                          else "CHECK_disagrees_with_Koay1998"

    # one marker per label: a marker claimed by two labels means the geometry
    # cannot decide between them -- flag both rather than guess (dense cluster)
    from collections import Counter as _C
    claimed = _C(r["marker_id"] for r in rows)
    for r in rows:
        collision = claimed[r["marker_id"]] > 1
        if collision:
            r["confidence"] = "AMBIGUOUS_marker_claimed_by_2_labels"
        elif r["validation"] == "consistent_with_Koay1998":
            r["confidence"] = "validated_vs_Koay1998"
        elif r["validation"] == "CHECK_disagrees_with_Koay1998":
            r["confidence"] = "CHECK_value_differs_from_Koay1998"
        elif r["assignment_method"] == "star_symbol_caption":
            r["confidence"] = "validated_via_caption_symbol"
        elif r["assignment_method"] == "leader_line":
            r["confidence"] = "leader_line_unvalidated"
        else:
            r["confidence"] = "nearest_label_unvalidated"

    rows.sort(key=lambda r: r["label_as_printed"].lower())
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()), quoting=csv.QUOTE_ALL)
        w.writeheader(); w.writerows(rows)
    from collections import Counter
    print("labels:", len(rows), Counter(r["assignment_method"] for r in rows))
    print(Counter(r["validation"] for r in rows))
    print(Counter(r["confidence"] for r in rows))
    for r in rows:
        if r["validation"] == "CHECK_disagrees_with_Koay1998":
            print("  CHECK", r["label_as_printed"], r["functional_interaural_distance_us"],
                  r["high_freq_hearing_limit_60dB_kHz"], "| koay", r["koay_us"], r["koay_kHz"],
                  "| d%", r["pct_diff_us"], r["pct_diff_kHz"], "|", r["assignment_method"])

if __name__ == "__main__":
    main()
