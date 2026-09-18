# Butti et al. 2009 — Table 5 (total VEN numbers by species and region)
Butti C, Sherwood CC, Hakeem AY, Allman JM, Hof PR (2009). *Total number and volume of Von Economo neurons in the cerebral cortex of cetaceans.* J Comp Neurol 515(2):243-259. doi:10.1002/cne.22055. PMID 19412956.
Full title (`__ReadMe.xlsx`): **"Table 5. Results of Stereologic Estimates of Total VEN Numbers in the Investigated Species and Cortical Regions"**

## Source->Snapshot
`..._Table5_snapshot.csv`: 9 rows as printed, species × region. The species name is printed once per block and left blank on the rows beneath it, exactly as on the page; the build carries it down. Hand transcription, as for Table 1.

## Data readable
`..._Table5.R` -> `..._Table5.csv`/`.tsv` (use this): 9 rows, one per printed row. Both hemisphere columns are kept as printed, with `hemisphere_available` recording which one carried the estimate.

## Two things the footnote settles, and one it does not
**Hemispheres.** *"the estimates were obtained in the only available hemisphere in each specimen. The right hemisphere of T. truncatus and the left hemispheres of G. griseus, D. leucas, and M. novaeangliae as well as the FP in the odontocetes were not available."* Exactly one count column is filled on every printed row, and on all nine it is the one the footnote predicts. The build asserts this — it is the strongest check available on the transcription.

**Underestimates.** *"VEN numbers in the odontocetes represent only the available blocks from the ROI and are therefore underestimates."* `underestimate` is TRUE for *T. truncatus*, *G. griseus* and *D. leucas*, FALSE for the humpback.

**Where the percentages belong — flagged, not reconciled.** Five of the nine rows carry a `VENs (%)`. They are transcribed exactly where they are printed: *T. truncatus* SUBG, *G. griseus* SUBG, *D. leucas* ACC, *D. leucas* AI, *M. novaeangliae* AI.

The paper's Table 3 gives total-neuron sampling parameters only for *T. truncatus* ACC, *G. griseus* ACC, *D. leucas* ACC, *D. leucas* AI and *M. novaeangliae* AI — which would put the first two percentages on ACC rather than SUBG. But SUBG appears in **neither Table 2 nor Table 3**, while Table 5 reports SUBG VEN counts of 580 and 600. Those parameter tables are therefore incomplete and cannot settle the question. Transcribed as printed, with the discrepancy in the definitions.

## Read before using the CEs
Three rows exceed 0.1: both SUBG rows (0.13) and *D. leucas* ACC (0.16). The caption says so itself — *"Because of the uneven and clustered distribution of VENs and their low numbers, CE values are sometimes higher than desirable (>0.1) and are not optimal indicators of the accuracy of the estimates, which in these cases resulted from exhaustive enumerations."*

## Notes
- The four regions are separate loci and are not pooled. One specimen per species, one hemisphere per specimen.
- `Structure` is recorded as `Cerebral_cortex_region` pending a canonical name per region — ACC, subgenual, anterior insula and frontopolar are all absent from `_keys/anatomy_reference.csv`.

## Comparisons
None. Founder item — no `__Public` value for cetacean VEN counts to audit against.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
