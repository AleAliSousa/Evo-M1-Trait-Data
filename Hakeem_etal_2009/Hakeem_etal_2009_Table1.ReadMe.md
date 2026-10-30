# Hakeem et al. 2009 — Table 1 (VEN and neuron counts, area FI, African elephant)
Hakeem AY, Sherwood CC, Bonar CJ, Butti C, Hof PR, Allman JM (2009). *Von Economo neurons in the elephant brain.* Anat Rec 292(2):242-248. doi:10.1002/ar.20829. PMID 19089889.
Full title (`__ReadMe.xlsx`): **"Table 1. Results of stereological counts of VENs and total neurons in area FI of the left and right hemispheres of Elephant 1"**

## Source->Snapshot
`..._Table1_snapshot.csv`: two rows as printed, one per hemisphere, eight columns, values verbatim including the thousands commas and the per cent signs. The first column has no header in the print and is left blank.

**Hand transcription, not a scrape.** The paper is not open access and has no PMC copy, so there is no machine-readable version to pull from. Typed into the frozen file by Claude (AI assistant) on 10 September 2026 from page images supplied by M. Windley. Checked by recomputing both printed percentages from the printed counts:

- right hemisphere: 10,200 / 1,300,000 = 0.785%, printed 0.78%
- left hemisphere: 9,110 / 348,000 = 2.618%, printed 2.6%

Both agree to the precision each was printed at, which means the four counts and the two percentages are mutually consistent — a wrong digit in any of them would break the arithmetic. The `.R` repeats this check on every run. The eight CE values have no such cross-check and rest on the page images alone.

There is no extract script here; with nothing to scrape, one would only re-type the values a second time.

## Data readable
`..._Table1.R` -> `..._Table1.csv`/`.tsv` (use this): one row, Elephant 1. The printed rows are hemispheres, so per build HOWTO §6 they become `_L` / `_R` columns with a computed `_total`. Species harmonized via `_keys/Hof/species_key.csv`.

## The percentage
Printed per hemisphere, but both numerator and denominator are printed too, so `ven_pct_*` is recomputed from the counts rather than transcribed (§7) and checked against the printed value.

The combined figure is **19,310 / 1,648,000 = 1.17%**. Averaging the two printed percentages gives 1.69%. Anyone reading the table without the counts will reach for the average, so `ven_pct_FI_total` is in the file to stop that happening.

## Read before using the neuron counts
Area FI holds **1,300,000 neurons in the right hemisphere and 348,000 in the left** — a 3.7-fold difference within one animal — while the VEN counts are close, 10,200 and 9,110. The CEs are all ≤ 0.09, so the paper presents both as sound. Printed as published and not reconciled here, but any per-hemisphere VEN density inherits it, and the two hemispheres will not agree.

## Notes
- Area FI is frontoinsular cortex, which is `fronto_insular_cortex` in `_keys/anatomy_reference.csv` — no new structure name needed for this item.
- The table covers Elephant 1 only. The paper also examined Elephant 2 (African, 16–17 years) and an adult female Indian elephant (*Elephas maximus*), plus dolphin, manatee, hyrax, tenrec, armadillo, elephant shrew, sloth, anteater and bontebok material. None of that is in Table 1.
- `Loxodonta africana` is already in `species_reference.csv` (taxid 9785), so no hub addition is needed.
- The CE columns print "Gunderson"; the estimator is Gundersen. The code uses the correct spelling and the definitions record the printed one.

## Comparisons
None. Founder item — no `__Public` value for VEN counts to audit against.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
