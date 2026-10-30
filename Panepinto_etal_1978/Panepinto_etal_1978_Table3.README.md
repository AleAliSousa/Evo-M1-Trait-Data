# Panepinto et al. 1978 — Table 3 — neonatal hematology of the Yucatan miniature pig

Panepinto, L. M., Phillips, R. W., Wheeler, L. R., & Will, D. H. (1978). *Laboratory Animal Science*, 28(3),
308–313. PMID 682579 (no DOI).

Registry: no row yet. Item name **`Panepinto_etal_1978_Table3`**; Item encoded **`PMID%3A682579_Table3`**
(house formula from col C `PMID:682579` + `Table 3`). Paste `Panepinto_etal_1978_Table3_registry_row.xlsx`.

## What the data are
Table 3 (printed p. 312), "Neonatal hematology values of 33 Yucatan miniature pigs": 11 age classes ×
plasma glucose (mg/dl), plasma protein (g/dl), packed cell volume (%), serum cholesterol, cholesterol
ester, phospholipids and triglycerides (mg/dl), each "mean ± SD" (footnote a). The four serum-lipid
columns are blank (not measured) at 0–10 days; those 12 blank cells are omitted from the long CSV.
Blood was drawn from the anterior vena cava every other week, alternating between the two halves of
the growth group; birth samples within 10 min of birth before nursing, all others nonfasting.
**Observation level:** age-class group means — not species means. Data role: **primary**.

## Source → Snapshot → Data
- Snapshot `Panepinto_etal_1978_Table3_snapshot.xlsx`: headers, row order, blanks and footnote as printed
  (age labels `0(birth)` and `1– 3` kept with their printed spacing). **Reader:** AI assistant, 28 Oct
  2026, from a 300-dpi render of p. 312, cross-checked against the OCR text layer (0 differences). The
  57–66 d glucose cell shows a speck before "99" (OCR reads ".99"); transcribed as `99 ± 7`
  (glucose is printed in whole mg/dl throughout). Human visual check pending.
- Build `Panepinto_etal_1978_Table3.R` → `Panepinto_etal_1978_Table3.csv` (65 rows) + public TSV
  `__Public/comparative-data/PMID%3A682579_Table3.tsv`. Units kept as printed (no project unit for blood
  chemistry).

## Notes for reviewers
- **Text/table disagreement (kept as printed):** text pp. 312–313 says packed cell volume "ranged from
  41.8 ± 3.7% at birth to 47.3 ± 2.1% at 66 days"; the table prints 42 ± 4 (birth) and 42 ± 2 (57–66 d).
  Candidate `publication_ambiguity` erratum for the owner; no errata file written in this pass.
- Serum phospholipids at 11–15 d print 12.8 ± 16.6 (SD larger than mean) — kept.

## Table checks
None: no totals or internal arithmetic.
