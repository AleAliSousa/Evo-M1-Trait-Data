# Panepinto et al. 1978 — Table 1 — neonatal growth of the Yucatan miniature pig

Panepinto, L. M., Phillips, R. W., Wheeler, L. R., & Will, D. H. (1978). The Yucatan miniature pig as a
laboratory animal. *Laboratory Animal Science*, 28(3), 308–313. PMID 682579 (no DOI).
PDF: `Panepinto-1978-The Yucatan minature pig as a l.pdf` (Auburn ILL scan; article pp. 308–313 = PDF pp. 3–8).

Registry: no row yet. Item name **`Panepinto_etal_1978_Table1`**; Item encoded **`PMID%3A682579_Table1`**,
derived with the house formula (col C override `PMID:682579`, url-encoded, + `_` + compacted Item number
`Table 1`). Paste `Panepinto_etal_1978_Table1_registry_row.xlsx` (see its HOW_TO_PASTE sheet).

## What the data are
Table 1 (printed p. 311), "Neonatal growth characteristics of 33 Yucatan miniature pigs": 11 age classes
(0 to 57–66 days) × shoulder height, girth, length (cm) and weight (kg), each printed "mean ± SD"
(footnote a). Age class 57–66 d carries footnote b, "Winter weather period". 33 piglets from six litters,
weighed and measured at birth and every other week to weaning by one technician (text p. 311).
**Observation level:** age-class group means of one colony — not species means; per-age n not printed.
Data role: **primary**.

## Source → Snapshot → Data
- Snapshot `Panepinto_etal_1978_Table1_snapshot.xlsx` (sheet `Table1`): caption, title, headers, 11 rows and
  both footnotes in printed order; footnote marks as superscripts; en dashes in age ranges as printed.
  **Reader:** transcribed by AI assistant on 28 Oct 2026 from a 300-dpi render of p. 311 (the OCR text layer
  scrambles the Weight column), then every number cross-checked against the OCR text layer
  (0 differences in the 44 measurement cells). Human visual check pending.
- Build `Panepinto_etal_1978_Table1.R` → `Panepinto_etal_1978_Table1.csv` (long: 44 rows = 11 ages × 4
  measures) and public TSV `__Public/comparative-data/PMID%3A682579_Table1.tsv`. Splits mean/SD, strips
  footnote marks into `footnote_marks`, parses age bounds; weight kg × 1000 → **g** (project unit), lengths
  kept in cm. Until the registry row is pasted, the script derives Item encoded from the registry_row.xlsx
  (warning printed) — the Filiminoff_1932 pattern.
- Species: printed "Yucatan miniature pig" → `Sus scrofa domesticus` via `_keys/General/species_key.csv`
  (`source_publication = Panepinto_etal_1978`, basis `our_judgment`).

## Not built
- Table 2 (diet composition) is not a trait table.
- Text-only values (birth weight 0.74 ± 0.17 kg, n = 580; weaning weight 6.47 ± 2.10 kg at 60 d; weight at
  1 y 49 ± 9 kg; mature boars 83 ± 12 kg, range 59–105; sows 70 ± 12 kg, range 40–90; mature height 57 ± 4 cm and
  length 76 ± 5 cm; litter size 6.12 ± 1.78) could form a `Panepinto_etal_1978_text_snapshot.csv` later.

## Table checks
None: the table has no totals or other internal arithmetic.
