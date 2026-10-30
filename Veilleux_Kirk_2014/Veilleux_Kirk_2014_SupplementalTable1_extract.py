#!/usr/bin/env python3
"""Builds the frozen snapshot of Veilleux & Kirk (2014) Supplemental Table 1
from the born-digital supplementary PDF (positional extraction).

Veilleux, C. C., & Kirk, E. C. (2014). Visual acuity in mammals: effects of eye
size and ecology. Brain Behav Evol 83(1):43-53. doi:10.1159/000357830

The PDF has a clean text layer, but plain text extraction loses empty-cell
positions (rows differ in which of MRS/AP/D1 are filled), so words are binned
by x-coordinate into the printed columns. Pages 1-4 = table; the table legend
(bottom of p.4) and Data Sources 1-122 (pp.5-12) are captured to
reference_tables/ by this same script.

The snapshot is the frozen copy (HOWTO invariant 1, printed-source case): after
building, it was hand-verified against rendered page images and audited in full
against two independent extractions (see comparison/).
"""
import pdfplumber, csv, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Veilleaux_Kirk_2014_supptable.pdf")
SNAP = os.path.join(HERE, "Veilleux_Kirk_2014_SupplementalTable1_snapshot.csv")
SRCS = os.path.join(HERE, "reference_tables", "Veilleux_Kirk_2014_SupplementalTable1_data_sources.csv")

# x-coordinate bins for the printed columns (stable across pages 1-4)
BINS = [("Species", 0, 205), ("AD", 205, 252), ("VA", 252, 297), ("BM", 297, 342),
        ("MT", 342, 377), ("MRS", 377, 417), ("AP", 417, 447), ("D1", 447, 475),
        ("src_VA", 475, 592), ("src_AD_BM", 592, 660), ("src_D_AP", 660, 712),
        ("src_MRS", 712, 9999)]
ORDERS = {"Artiodactyla","Carnivora","Chiroptera","Cingulata","Dasyuromorphia",
          "Didelphimorphia","Diprotodontia","Hyracoidea","Lagomorpha","Macroscelidea",
          "Monotremata","Peramelemorphia","Perissodactyla","Pilosa","Primates",
          "Proboscidea","Rodentia","Scandentia","Soricomorpha","Xenarthra",
          "Afrosoricida","Erinaceomorpha","Cetacea","Pholidota","Tubulidentata",
          "Sirenia","Notoryctemorphia","Microbiotheria","Paucituberculata","Dermoptera"}

def main():
    rows_out, sources = [], []
    with pdfplumber.open(PDF) as pdf:
        current_order = ""
        for pi in range(4):
            words = pdf.pages[pi].extract_words()
            # cluster words into printed lines by top coordinate
            lines = []
            for w in sorted(words, key=lambda w: (w["top"], w["x0"])):
                if lines and abs(w["top"] - lines[-1][0]) <= 2.5:
                    lines[-1][1].append(w)
                else:
                    lines.append([w["top"], [w]])
            for _, ws in lines:
                ws.sort(key=lambda w: w["x0"])
                text = " ".join(w["text"] for w in ws)
                if text.startswith(("Supplemental Table", "Sources", "Species AD",
                                    "Abbreviations", "Data Sources")):
                    if text.startswith(("Abbreviations", "Data Sources")):
                        break
                    continue
                first = ws[0]["text"]
                ## group-header rows: an order name, or the split Primates
                ## subgroups printed as "Primates- Haplorhines*" / "Primates- Strepsirrhines"
                if (len(ws) == 1 and first in ORDERS) or first == "Primates-":
                    current_order = text
                    continue
                if first in ("Abbreviations:", "1Species", "2", "*", "**"):
                    break
                cells = {name: [] for name, *_ in BINS}
                for w in ws:
                    for name, lo, hi in BINS:
                        if lo <= w["x0"] < hi:
                            cells[name].append(w["text"]); break
                sp = " ".join(cells["Species"])
                if not sp or not any(cells[c] for c in ("AD", "VA", "BM")):
                    continue  # stray line
                rows_out.append([current_order, sp] +
                                [" ".join(cells[n]) for n, *_ in BINS[1:]])
        # data sources, pages 5-12: lines starting with a number
        buf = None
        for pi in range(4, 12):
            t = pdf.pages[pi].extract_text() or ""
            for line in t.split("\n"):
                if line.startswith("Data Sources"):
                    continue
                m = re.match(r"^(\d{1,3})\.?\s+(.*)$", line)
                if m and int(m.group(1)) <= 122 and (buf is None or int(m.group(1)) == buf[0] + 1):
                    if buf: sources.append(buf)
                    buf = [int(m.group(1)), m.group(2)]
                elif buf:
                    buf[1] += " " + line.strip()
        if buf: sources.append(buf)

    os.makedirs(os.path.dirname(SRCS), exist_ok=True)
    with open(SNAP, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Order", "Species", "AD", "VA", "BM", "MT", "MRS", "AP", "D1",
                    "src_VA", "src_AD_BM", "src_D_AP", "src_MRS"])
        w.writerows(rows_out)
    with open(SRCS, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, quoting=csv.QUOTE_ALL)
        w.writerow(["source_number", "citation"])
        w.writerows(sources)
    print("species rows:", len(rows_out), "| sources:", len(sources),
          "| orders seen:", len({r[0] for r in rows_out}))

if __name__ == "__main__":
    main()
