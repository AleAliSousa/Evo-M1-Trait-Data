# Shoshani et al. 2006 — Table 1 (brains and endocasts of proboscideans and other taxa; 44 samples)

Shoshani J, Kupsky WJ, Marchant GH (2006). *Elephant brain. Part I: gross morphology, functions, comparative anatomy, and evolution.* Brain Res Bull 70(2):124-157. doi:10.1016/j.brainresbull.2006.03.016

## Source -> snapshot
`Shoshani_etal_2006.pdf` (EndNote 4687). Table 1 spans PDF pp.3-4 (journal pp.125-126); text layer is scrambled, so `..._Table1_snapshot.csv` is a **transcribed snapshot** from a 2.2x render: 44 rows, columns as printed, superscript footnote tags written `^f1`, blanks blank. One column, "Section (group heading, added)", records the printed group headings (A-E). Rows are **specimens/records, not species**.

## Sections
A: 7 elephant brains examined by the authors (primary: brain, body, cerebellum, dura). B: 15 adult elephants from the literature (brain/body/EQ). C: 7 records of whole brains/cerebella only illustrated by others (no numbers). D: 4 extinct proboscideans (endocast-based estimates; excluded by the authors from averages). E: 11 non-elephant specimens (human, chimpanzee, talapoin, sheep, kudu, zebra, hyrax, maned wolf, cat, chinchilla, guinea pig); only humans, chimp, talapoin and sheep carry brain weights.

## Fidelity checks (see build script output)
- 44 rows = printed sample numbers 1-44.
- EQ recomputed from printed body and brain weights with the paper's formula (EQ = E/[0.12 P^(2/3)], footnote j): 15 rows agree within 0.024 (printed slightly higher). Also confirms the body weights.
- Cerebellum ratio C/B recomputed: matches printed ratios for samples 1, 2, 3, 5, 34-37 (within rounding).
- **Flags (kept as printed):** sample 6 body weight prints `1793.300` (EQ check shows 1,793,300 g is meant; numeric column holds 1793.3); sample 7 cerebellum `858/19` repeats specimen C's 858 g (858/1724 = 49.8%, not 19%); sample 11 and 12 share body weight 3,048,000 g (footnote f7 says probably the same individual); sample 33 body weight is a range "3,049,760 or 4,250,000" and EQ "[2.18 or 1.75]" (numeric columns NA); bracketed EQs ([18.5], [2.83], [0.2], [2.2], [2.18 or 1.75]) are NA in `EQ`, kept in `EQ_printed`.

## Caveats
- Brain weights **include dura fragments and variable lengths of brain stem** (footnote g); not comparable with clean whole-brain weights. Samples 8, 9 and 14 (7475, 6500, 9000 g) are flagged by the authors as out-of-range/rough and excluded from their averages.
- Body weights are partly converted from lbs or estimated (footnotes f1-f8; f4/f2 = estimates, f5 = actual).
- Rows 8-33 and EQ for 34-44 are literature compilations (secondary): prefer the cited originals. Only samples 1-7 (A-G) are primary.
- Species names kept as printed (common names for 34-44; binomials only in footnotes c15-c25, listed in the definitions).

## Lewitus et al. 2014 (ref 54)
Comparable quantities: `brain_mass_g` and `body_mass_g` for Elephas maximus / Loxodonta africana (samples 1-22, average of the adult rows; the authors give 4648 g as the mean of five adult brains in the text) and `EQ`.

## Build
`Shoshani_etal_2006_Table1.R` -> `..._Table1.csv` (44 rows). TSV skipped until the registry row (`..._Table1_registry_row.xlsx`) is pasted into `__ReadMe.xlsx`. RA side-by-side check of the render vs snapshot still pending.
