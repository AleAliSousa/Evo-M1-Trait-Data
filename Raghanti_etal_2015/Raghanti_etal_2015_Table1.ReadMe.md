# Raghanti et al. 2015 — Table 1 (% VENs and fork cells, layer V, 4 regions, 8 species)
Raghanti MA, Spurlock LB, Treichler FR, Weigel SE, Stimmelmayr R, Butti C, Thewissen JGM, Hof PR (2015). *An analysis of von Economo neurons in the cerebral cortex of cetaceans, artiodactyls, and perissodactyls.* Brain Struct Funct 220(4):2303-2314. doi:10.1007/s00429-014-0792-y. PMID 24852852.
Full title (`__ReadMe.xlsx`): **"Table 1. Percentage of VENs and fork cells in layer V of each cortical region"**

## Source->Snapshot
Publisher HTML table page, `https://link.springer.com/article/10.1007/s00429-014-0792-y/tables/1` (snapshot HOWTO method 2) -> `..._Table1_snapshot.xlsx` (sheet `Table1`): two header rows, then eight species, row order kept.

Extraction and build are one script, `..._Table1.R`, in two sections. Section 1 reads the source page and compares it with the frozen copy: writes it if absent, reports a verification if identical, writes `..._REBUILD.xlsx` and stops if it differs, and warns and carries on if the page cannot be read. Section 2 always reads the frozen `.xlsx` from disk — never the object parsed in section 1 — so what is published is always what is committed. (Until 21 September 2026 the extract step was a separate file, `Raghanti_etal_2015_extract_snapshot.R`; once the frozen copy existed that script took its "already matches" branch on every run and produced no output, so it has been removed.)

`.xlsx`, not `.csv`: the header is two tiers deep — each of the four cortical regions spans a `% VEN` and a `% Fork cells` column, and `Species` spans both header rows. CSV flattens that. The merges are reproduced.

Transcription: read from the publisher HTML by the script (no table values are typed into it) on 10 September 2026; the script was written by Claude (AI assistant) and its output was checked cell by cell against a page image of the printed table supplied by M. Windley. Re-running the script re-reads the page and stops rather than overwrite if the frozen copy has drifted. Only the table page is open; the article body is paywalled, so the Materials and methods quoted below were supplied by M. Windley.

## Data readable
`..._Table1.R` -> `..._Table1.csv`/`.tsv` (use this): 8 rows, one per species. The two header tiers are combined into eight `<region>_<celltype>_pct` columns, built from the printed header text rather than a hardcoded list. Species harmonized via `_keys/Hof/species_key.csv`; printed common name kept as `species_as_published`.

Checks in the script: nine columns and ten rows in the snapshot, `Species` spanning both header rows, each region spanning two columns, the measure names in printed order, eight species, no missing values, every percentage between 0 and 100, exactly one non-adult, and all eight rock hyrax values zero.

## Values are percentages
The table reports ratios, not measured quantities: *"Percentages were calculated as the population estimate of VENs or fork cells divided by the total neuron population estimates"* (table footnote). A ratio would normally be recomputed downstream from its numerator and denominator rather than transcribed, but the population estimates behind these are published only as scatterplots (Figs 6–8) and are not tabulated anywhere. So the percentage is the only tabulated form of this result. Recorded as `pct.neurons` with a `Method:derived_values` row rather than treated as a measurement.

## Species notes
- The table prints common names. The binomials are from Materials and methods and live in `_keys/Hof/species_key.csv` as `variant_name` rows, so no common-to-binomial map appears in the script.
- Four accepted names are not in `species_reference.csv`: *Balaena mysticetus*, *Bos taurus*, *Equus ferus caballus*, *Ovis aries*. Proposed rows are drawn up but the hub is untouched.
- The horse is kept as the printed trinomial *Equus ferus caballus*. `species_reference.csv` already carries `Sus scrofa domesticus`, so trinomials for domesticates are the existing convention.
- The pig maps to `Sus scrofa domesticus`, which is already in the hub, exactly as the paper prints it.

## Sampling notes
- **One individual per species**, right hemisphere only. Every value in this table rests on a single brain, and the table has no `n` column, so `n_individuals` carries it.
- The cow is the only non-adult. Table 1 calls it "Cow"; the figure legends call the same specimen a calf. Both are the paper's own wording and neither is corrected here.
- The four regions are sampling positions, not homologues: *"These regions were chosen to provide consistency in anatomical sampling among diverse species and no homology of function was assumed."* There is a `Method:region_homology` row saying so.
- VENs also appear in layer II (Fig. 4) and layer III (Fig. 5) but are quantified only in layer V, so `cortical_layer` is carried explicitly.

## Comparisons
None. Founder item — no `__Public` value for VEN percentages to audit against.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
