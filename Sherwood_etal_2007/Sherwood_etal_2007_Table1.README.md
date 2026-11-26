# Sherwood_etal_2007_Table1

Table 1 | Individual Subject Data. Source: `fulltext.html` (PMC author manuscript, PMC2680156), DOI in `__ReadMe.xlsx`.

## Build

Table 1 gives per-individual data for 18 Yerkes chimpanzees (8 female, 10 male; identified by Yerkes code only, never named): sex, age at death, handedness index (HI) and handedness classification (HC: R/L/A) from the coordinated bimanual tube task, and asymmetry quotients (AQs) for 11 neuroanatomical variables of the primary motor cortex hand representation — hand knob volume (from postmortem MRI), neuron and glia density in layer II/III, areal fraction (AF) of Nissl-stained tissue in layers II/III and V/VI, relative thickness of layers I, II/III and V/VI, parvalbumin-immunoreactive (PV-ir) interneuron density and mean cell volume in layer II/III, and NPNFP-ir mean cell volume in layer II/III. AQ = (R − L)/((R + L) × 0.5); positive = right-hemisphere dominance.

From the paper folder, run:

```sh
Rscript Sherwood_etal_2007_Table1_snapshot.R
Rscript Sherwood_etal_2007_Table1.R
```

The snapshot script captures the table programmatically from the frozen PMC author-manuscript HTML in this folder (Europe PMC's full-text XML endpoint returns an error for this article, so the PMC HTML rendering is the capture source) and refuses to overwrite a differing frozen snapshot. The PMC HTML loses some spaces inside the printed headings ("YerkesCode", "Age atDeath"); the script asserts the extracted headings equal the printed headings once spaces are removed and writes the snapshot with the printed headings — every value is captured verbatim. It was run once for this build. On subsequent runs, run only `Rscript Sherwood_etal_2007_Table1.R`. The R script reads only its item snapshot and writes `Sherwood_etal_2007_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **AQ-only data.** No per-hemisphere raw values are printed anywhere in this paper; nothing here can enter a merge as a raw per-hemisphere measure. The per-animal ingredients for species-level indices are all present: HI, classification, sex and age for every animal, and each AQ as printed.
- **The same 18 animals are in Sherwood et al. (2010), with identical HIs** — the behavioural data are the same dataset. Three demographic conflicts stand between the two papers and are carried as printed in both, flagged on the affected rows: C0576 is F, 20 y here but M, 19 y in 2010; C0573 is 15 y here but 28 y in 2010; C0406 is 41 y here but 42 y in 2010. Identical HIs make "same animal, misprinted demographics in one paper" far more likely than code reuse, but neither paper can be preferred from the texts alone.
- **Methods prose slip (table unaffected).** The Methods say HI was derived "by subtracting the number of right-handed responses from the number of left-handed responses" and then print HI = (R − L)/(R + L), positive = right preference. The prose describes (L − R); the formula, the sign statement and this table's classifications (HI −1.00 → L; HI 1.00 → R) all agree with each other. The formula governs — do not "correct" the sign.
- **Cross-check.** Sherwood_etal_2007_Table2's printed group means and SDs were recomputed from this table's values in the Table 2 build: maximum deviation 0.006, within the printed rounding — this table's capture is consistent with the paper's own statistics.
- All 18 Yerkes codes are registered in the specimen crosswalk; 12 link to Schenker 2010 and six have Sherwood canonicals. Cross-paper adjudication is documented in the restricted comparison. The snapshot was captured programmatically and checked against an independent extraction of the same HTML; human visual signoff remains pending in the registry. No merge is performed by this build.
