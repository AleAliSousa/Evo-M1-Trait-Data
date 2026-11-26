# Sherwood_etal_2010_Table1

Table 1 | Data used in this study. Source: `fulltext.html` (PMC author manuscript, PMC4676573), DOI in `__ReadMe.xlsx`.

## Build

Table 1 gives per-individual data for 33 chimpanzees (15 female, 18 male; Yerkes National Primate Research Center and UT MD Anderson Cancer Center, Bastrop; identified by code only, never named): sex, age at death, postmortem interval (PMI, hours), rearing history (C = captive-born, W = wild-born), synaptophysin (SY)-immunoreactive puncta density asymmetry quotient (AQ), SY protein expression level AQ (Western blot), handedness index (HI) for the coordinated bimanual tube task, and handedness category (R/L/NP — NP = no preference, this paper's term for the ambidextrous construct called "A" in Sherwood_etal_2007). AQ = (R − L)/((R + L) × 0.5); positive AQ and HI values indicate rightward asymmetry. The per-hemisphere densities behind the density AQs are in Sherwood_etal_2010_SupplementaryTableS1.

From the paper folder, run:

```sh
Rscript Sherwood_etal_2010_Table1_snapshot.R
Rscript Sherwood_etal_2010_Table1.R
```

The snapshot script captures the table programmatically from the frozen PMC author-manuscript HTML in this folder (Europe PMC's full-text XML endpoint returns an error for this article, so the PMC HTML rendering is the capture source) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Sherwood_etal_2010_Table1.R`. The R script reads only its item snapshot and writes `Sherwood_etal_2010_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Missingness is real data.** The protein-expression AQ is blank (a printed en dash) for 12 of the 33 animals in the PMC author manuscript — the Western blot subset is n = 21 — and PMI is printed "N/A" for 4 animals (C0594, C0342, C2105, C0200). The build carries both as missing, never zero; the PMI rows are flagged in the Note column. (An earlier prep count of 14 blanks / n = 19 does not match the PMC manuscript as captured; the counts here are from the captured table itself.)
- **The same 18 animals as Sherwood et al. (2007), with identical HIs** — asserted in the build against the 2007 values. Three demographic conflicts stand between the papers and are carried as printed in both, flagged on the affected rows: C0576 is M, 19 y here but F, 20 y in 2007; C0573 is 28 y here but 15 y in 2007; C0406 is 42 y here but 41 y in 2007.
- **Sign conventions verified.** The AQ formula is printed in the stereology methods (AQ = (R − L)/[(R + L) × 0.5], positive = right-hemisphere dominance), and the table is consistent with it: protein-expression AQs are predominantly positive, matching the reported significantly higher right-hemisphere expression, and Figure 3's caption repeats the convention. No sign mismatch in this paper (the cluster's one prose slip is in the 2007 paper's Methods).
- All 33 codes are registered in the specimen crosswalk; 18 link to Sherwood 2007, including 12 also in Schenker 2010. Of 15 additional cases, NCBR assigns C0200 to Yerkes and 14 have no individually reported source institution. Cross-paper adjudication is documented in the restricted comparison. The snapshot was captured programmatically and checked against an independent extraction of the same HTML; human visual signoff remains pending in the registry. No merge is performed by this build.
