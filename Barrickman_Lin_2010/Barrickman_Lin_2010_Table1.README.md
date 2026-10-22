# Barrickman & Lin 2010 — Table 1 (brain mass, body mass, gestation, weaning, resting metabolic rate, intestinal size; 26 strepsirrhines)

Barrickman NL, Lin MJ (2010). *Encephalization, expensive tissues, and energetics: an examination of the relative costs of brain size in strepsirrhines.* Am J Phys Anthropol 143(4):579-590. doi:10.1002/ajpa.21354

Added 2026-10-21 because Lewitus et al. 2014 (ref 28) cites it for 12 species' resting metabolic rate (Lewitus External Database S1).

## Source -> snapshot
`Barrickman_Lin_2010.pdf` (copied from EndNote record 480). Table 1 is on PDF p.4 (journal p.582); the text layer is scrambled, so `..._Table1_snapshot.csv` is a **constructed (transcribed) snapshot** read from a render: 26 species, column order as printed, blank cells blank, superscript footnote letters kept on the headers.

## Provenance — read before pooling
- The table is mostly a **secondary compilation** (Isler et al. 2008, Gordon 2006, Kappeler & Pereira 2003, Isler & van Schaik 2006b, Hanna 2006, Campbell 2000/2003).
- **Primary** (measured by this study at the Duke Lemur Center): RMR of *Daubentonia madagascariensis*, *Lemur catta*, *Propithecus coquereli*; body mass of *D. madagascariensis* and *P. coquereli*; brain mass of *P. coquereli*; some intestinal values for the same three species.
- **Gestation and weaning are divided by 2** by the authors for the 7 twinning species (*Mirza coquereli, Microcebus murinus, Varecia variegata variegata, Cheirogaleus medius, Galago demidovii, Otolemur crassicaudatus, Nycticebus pygmaeus*). Do **not** pool those cells with raw gestation/weaning values.
- Units: months for gestation/weaning, VO2 ml/h for RMR (convert to the merge unit downstream).

## Build
`Barrickman_Lin_2010_Table1.R` -> `..._Table1.csv`. TSV is written once the registry row is pasted into `__ReadMe.xlsx`.

## RA check still to do
Side-by-side read of the render against the snapshot (26 rows x 10 columns); no automated cross-check exists for this table (the table has 26 species; the paper's regressions report d.f. = 26 for fits that include extra points, so row count is not a check).
