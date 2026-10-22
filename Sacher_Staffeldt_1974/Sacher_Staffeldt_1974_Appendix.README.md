# Sacher & Staffeldt 1974 — Appendix table (neonatal/adult brain and body weights, gestation, litter size; 105 mammals)

Sacher GA, Staffeldt EF (1974). *Relation of gestation time to brain weight for placental mammals: implications for the theory of vertebrate growth.* Am Nat 108(963):593-615. https://www.jstor.org/stable/2459589

Added 2026-10-21 because Lewitus et al. 2014 (ref 11) cites it for 31 species' adult/neonatal body and brain weights (Lewitus External Database S1); it is the **original** source, so it should be preferred over the Lewitus copy.

## Source -> snapshot
PDF `Sacher_Staffeldt_1974.pdf` (copied from the owner's EndNote library, record 9161). The Appendix table is a scanned landscape printout (journal pp. 609-612 = PDF pp. 18-21); the PDF text layer is garbage there, so `..._Appendix_snapshot.csv` is a **constructed (transcribed) snapshot**: row order, group headers, asterisks and reference numbers as printed. 105 rows = the paper's "105 species"; 13 asterisked (excluded by the authors) = the paper's "13".

## Fidelity checks
- Row count 105 and asterisk count 13 match the paper's statement.
- The two advancement-factor columns were recomputed from the transcribed neonatal/adult weights: **0 of 92 complete rows disagree** (so adult and neonatal brain/body values are transcribed correctly; gestation, litter size and reference numbers are not covered by this check and need the RA side-by-side read).
- Two stray margin numbers print beside a few reference numbers (*Macaca maurus* "19 2", *Papio hamadryas* "12 2", *Felis catus* "19 29", *Sus scrofa* dom. "8 19", *Cervus canadensis* "8 36", *Bos grunniens* "25 4", *Ovis aries* "8 19"); kept verbatim in `reference_numbers`.
- *Macaca mulatta* appears twice by design (two independent data sets; the paper's n = 92).
- Ref 11 prints as "(citation missing)" in the paper.

## Build
`Sacher_Staffeldt_1974_Appendix.R` -> `..._Appendix.csv` (species sentence-cased; `species_as_printed` kept; asterisk -> `excluded_from_analysis`). Public TSV is written once the registry row is pasted into `__ReadMe.xlsx` (`Item encoded`).

## Notes for use
- Gestation is "active fetal development" (delayed implantation excluded).
- Neonatal weights: 39 species were weighed by the authors (refs 3, 4, 13, 26, 31) — primary for those rows; the rest are literature.
- Printed spellings (e.g. *Alouatta paliatta*) are kept as printed; harmonise downstream.
