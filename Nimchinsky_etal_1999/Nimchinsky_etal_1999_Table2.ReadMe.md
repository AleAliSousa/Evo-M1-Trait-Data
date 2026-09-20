# Nimchinsky et al. 1999 — Table 2 (soma volumes, ACC area 24, 5 hominoids)
Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999). *A neuronal morphologic type unique to humans and great apes.* Proc Natl Acad Sci USA 96(9):5268-5273. doi:10.1073/pnas.96.9.5268. PMID 10220455. PMC21853.
Full title (`__ReadMe.xlsx`): **"Table 2. Volumes of layer V spindle and pyramidal cells and small-layer VI fusiform cells"**

## Source->Snapshot
Open-access HTML, `https://pmc.ncbi.nlm.nih.gov/articles/PMC21853/`, `section#T2` (snapshot HOWTO method 2). `Nimchinsky_etal_1999_extract_snapshot.R` -> `..._Table2_snapshot.csv`: 5 rows, flat layout, cells verbatim including the thousands commas, the `±`, and the significance markers (`6,648 ± 2,667*†`).
Frozen page: `Nimchinsky_etal_1999_PMC21853.html` (PMC HTML as served 18 September 2026; both tables and the bold verified identical to the snapshots). The script prefers this local copy, so re-runs are offline; it was added after the 2026-09-18 sweep failed on a transient non-article response from PMC.

Transcription: read from the PMC HTML by the script (no table values are typed into it) on 10 September 2026; the script was written by Claude (AI assistant) and its output was checked cell by cell against a page image of the printed table supplied by M. Windley. Re-running the script re-reads the page and stops rather than overwrite if the frozen copy has drifted.

## Data readable
`..._Table2.R` -> `..._Table2.csv`/`.tsv` (use this): 5 rows, one per species. Each printed cell is split into `_mean` and `_sd`; the markers become `spindle_gt_pyramidal_p05` and `spindle_gt_fusiform_p01`. Species harmonized via `_keys/Allman/species_key.csv` (the table abbreviates the genus, so `P. pygmaeus` etc. have their own key rows); printed name kept as `species_as_published`.

Checks in the script: 5 rows, header as printed, markers on the spindle-cell column only, all five daggered, three asterisked, no missing volumes.

## Units
Kept in μm³ as published. The project standard of mm³ is for structure volumes; these are somata, so converting would print every value at ~1e-6 mm³ and invite pooling with structure volumes it does not belong with. `Measure` is `Vol.um3` in the definitions to keep the two classes apart. Say if you want it converted and I will change the script.

## Notes
- The caption's sample is 50 neurons per layer per case. Case counts per species are in `Nimchinsky_etal_1999_Table1` (`n_specimens`): *Pongo* 1, *Gorilla* 5, *P. troglodytes* 8, *P. paniscus* 1, *Homo* 6. Two of the five means rest on a single specimen.
- Layer V pyramidal and layer VI fusiform volumes are the paper's own within-section controls, which is why they are built alongside the spindle-cell column rather than dropped.
- The correlation with encephalization (r² = 0.98, P = 0.001) is in Fig. 4 and computed from brain residuals; it is derived, so it is not transcribed here.

## Comparisons
None. Founder item — no `__Public` value for these volumes to audit against.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
