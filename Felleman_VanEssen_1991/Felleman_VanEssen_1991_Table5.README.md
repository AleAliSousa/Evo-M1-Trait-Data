# Felleman_VanEssen_1991_Table5 — Connectivity table for visual areas

Felleman, D. J., & Van Essen, D. C. (1991). Distributed hierarchical processing in the primate
cerebral cortex. *Cerebral Cortex*, 1(1), 1–47. https://doi.org/10.1093/cercor/1.1.1

## What this item is
Table 5 is a long-format list of macaque visual-cortex interareal pathways (182 (from_area,
to_area) pairs across 4 printed pages, `Felleman-1991-Distributed hierarchical process.pdf`
pages 18, 20, 22, 24 of the combined PDF — the publisher's own page numbers 19, 20, 22, 24).
For each pair, the table records the laminar origin, laminar termination pattern, and inferred
direction of the pathway, reported separately from studies of the source area's efferents
("Outputs") and studies of the target area's afferents ("Inputs"), plus the pair's assigned
hierarchical relationship and the number of hierarchical levels it traverses (Fig. 4 of the
paper).

## Why this needed a different method than Table 3
Table 3 (the dense 35×32 connection matrix) was reconstructed from this PDF's embedded text
layer, which carries exact character positions for every "+"/"."/"?"/"N"/"R" symbol. Table 5's
laminar-code columns (Origin, Termination, Direction — the S/B/I, F/C/M, A/L/D single-letter
codes) turned out to be **mostly absent from that same text layer**: a check of page 1 of this
table found only 2–37% of cells in those columns recoverable as text characters, even though
they are clearly printed. Rather than guess at partial text, every value in this item was
**read directly off the rendered page image** (one high-resolution render per page, at the
full row/column layout) and transcribed by hand, cross-checked against the "From"/"To"/
"Hierarchical relationship"/"Levels crossed" columns (which largely *are* reliable in the text
layer and were used as a row-alignment check).

## Coding (from the table's own caption, p. 24 of the article PDF)
- **Origin** (S, B, I): supragranular / bilaminar / infragranular.
- **Termination** (F, C, M): layer-4 predominant / columnar / multilayer avoiding layer 4.
- **Direction** (A, L, D): ascending / lateral / descending.
- **"u"**: the pathway has been demonstrated but its laminar features (hence direction) are
  unknown.
- **"?"** suffix on any code: uncertain.
- **Slash-joined codes** (e.g. "S/B", "F/C", "A/L?"): reported as one or the other across
  sources, or the pattern itself is split/ambiguous — printed verbatim, not resolved to one
  value.
- **HierRel**: "A-D" marks a pair where the laminar patterns in both directions are consistent
  with an ascending-descending hierarchical relationship; "NR"/"NR?" marks a (or uncertain)
  non-reciprocal pathway; "NC"/"NC?" marks a pair whose laminar evidence cannot be classified
  (or is uncertain) into a consistent hierarchical relationship.
- **Levels**: the number of hierarchical levels the pathway crosses in the paper's Fig. 4
  diagram, given only when the pair's hierarchical relationship is established.

## Known limitation — not built
The printed table also carries two reference columns (13–15 "Output References", 16–18 "Input
References") on facing pages, giving a literature-citation code per pathway (e.g. "LH, '84" =
Livingstone & Hubel, 1984a) plus a short reference key at the foot of the last data page. These
bibliographic citation columns were **not transcribed in this build** — this item covers the
laminar/direction/hierarchy data (columns 1–12) only, which is the table's primary scientific
content. Building the reference columns would be a reasonable future addition if the specific
literature support for a pathway is needed.

## Validation
- 182 rows, one per (from_area, to_area) pair appearing across the 4 data pages.
- Row-grouping checked against the "From" group-label structure (printed once per block, as in
  Table 3's group headers) and the row counts per block cross-checked against the rendered
  image before transcription.
- The reliable text-layer columns (To_out, From_in, HierRel, Levels, when present) were
  extracted programmatically first and used to catch row-alignment errors before the
  laminar-code columns were transcribed from the image.

## Files
- `Felleman_VanEssen_1991_Table5_snapshot.csv` — frozen, verbatim transcription (182 rows,
  long format), matching exactly what is printed (blanks kept as blanks).
- `Felleman_VanEssen_1991_Table5.csv` / public TSV — same content, published.

## Data role
**Primary** — the paper's own reported pathway-level connectivity data, transcribed from the
publisher's typeset PDF.
