# Chugani et al. (1987) — Table 1, patient summary

Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). *Positron emission tomography study of
human brain functional development.* Annals of Neurology, 22(4), 487-497.
https://doi.org/10.1002/ana.410220408

**Item:** `Chugani_etal_1987_Table1` · **Item encoded:** `10.1002%2Fana.410220408_Table1` ·
**Public TSV:** `__Public/comparative-data/10.1002%2Fana.410220408_Table1.tsv`

**Table 1** (pp. 488–489), "Patient Summary". The 29 infants and children studied with FDG‑PET: age
and sex, clinical information, laboratory data, medication on the day of study, and period of
follow‑up. The table carries **no lCMRGlc value**. It matters because it is the roster that supplies
the abscissa of Figure 2 — every point plotted there belongs to one of these 29 patients — and the
membership of the four age bins of Table 2 (n = 7 / 4 / 12 / 6).

## Source and transcription

- **Frozen source:** `Chugani_etal_1987_Table1_snapshot.csv`. The PDF is a grey page scan
  (2400 × 3449 px) whose OCR text layer is column‑shuffled and misspells drug names
  ("Cubamazepine", "Ph,enobarbital"), so it was not usable. The table was **transcribed by an AI
  assistant on 2026‑10‑31 from 290‑ppi renders of the embedded page bitmaps** (PDF pp. 2–3), typed
  into the frozen file as printed.
- The snapshot has **31 rows for 31 printed rows**: the 29 patients in printed order, the
  `Table I. (Continued)` header where the table breaks across the page, and the footnote line.
  Column order and the printed five headers are preserved.
- Printed oddity kept verbatim: the 7.5‑year patient's medication is printed
  `Phenobarbital carbamazepine` with no comma, unlike the other two‑drug cells.

## Pipeline

| file | role |
|---|---|
| `Chugani_etal_1987_Table1_snapshot.csv` | frozen snapshot (as printed) |
| `Chugani_etal_1987_Table1.R` | snapshot → analysis CSV + public TSV; `table_checks` |
| `Chugani_etal_1987_Table1.csv` | analysis data, 29 rows × 16 cols |
| `reference_tables/Chugani_etal_1987_Table1_definitions.csv` | data dictionary |
| public TSV | `__Public/comparative-data/10.1002%2Fana.410220408_Table1.tsv` |

## Table checks (actual R run, 2026‑10‑31) — 10 checks, **10 pass**

The table has no arithmetic of its own, so it is checked against the counts the Methods print (p. 489).

| check | observed | printed | status |
|---|---|---|---|
| patients | 29 | 29 | pass |
| males | 16 | 16 | pass |
| females | 13 | 13 | pass |
| on daily anticonvulsants | 18 | 18 | pass |
| youngest / oldest | 5 days / 15.1 y | 5 days / 15.1 y | pass |
| Table 2 bin sizes | 7 / 4 / 12 / 6 | 7 / 4 / 12 / 6 | pass |

The bin‑size check is the strong one: it confirms that all 29 ages were transcribed correctly and in
the right order, because any single mis‑keyed age would move a patient between bins.

## Observation level and data role

**primary.** One row per **individual patient**, not per species — 29 clinical cases, not a species
sample. `species_as_published = "human"` on every row (the paper prints no species name; the title
and Methods state human), resolved to *Homo sapiens* through
`_keys/General/species_key.csv` (`source_publication = Chugani_etal_1987`).

Precision/caveat: ages are printed to the precision the paper used (days, weeks, months or years, to
one or two decimals) and are kept verbatim in `age_as_printed`; `age_years` is this build's decimal
conversion (days/365.25, weeks×7/365.25, months/12).

<!-- errata:begin -->
<!-- errata:end -->
