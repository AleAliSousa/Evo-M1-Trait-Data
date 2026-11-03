# Püschel et al. 2026: S1 Data, primate handedness meta-analysis dataset (71 study × species rows, 41 anthropoid species)

Püschel, T. A., Hurwitz, R. M., & Venditti, C. (2026). Bipedalism and brain expansion explain human handedness. *PLoS Biology*, 24(4), e3003771. https://doi.org/10.1371/journal.pbio.3003771

**Registry:** row 972 exists. Item name **`Püschel_etal_2026_S1Data`**; Item encoded **`10.1371%2Fjournal.pbio.3003771_S1Data`**. The script looks both up live. The row was updated on 2026-11-03:
- The citation is now spelled with the umlaut. It was "Puschel", so the Item name was `Puschel_etal_2026_S1Data`.
- The descriptive columns are filled.
- *Human visual check of snapshot* = *Not applicable: tabulated and digital already*.

*Public TSV match* stays `notfound` until `_tools/file_list.R` is rerun.

## Frozen source (born-digital, no derived snapshot)
The source is `journal.pbio.3003771.s010.csv`, the journal's S1 Data file. It is the 10th supporting file in the paper's order: S1–S3 Table, S1–S2 Fig, S1–S2 Section, S1–S2 Code, S1 Data, S2 Data. PDF p. 14 describes it as "S1 Data. Dataset analyzed in the present study. (CSV)". It is kept verbatim (sha256 `0ff81cea1f63ac7a2dc84f77c6bb363a63d0b589632775db51dccab67c541dd2`).

The R script reads this download directly. Under build HOWTO §0a there is no copy-renamed `_snapshot`, so `audit_dataset_item()` reports the snapshot as MISSING. That is expected for a digital-native item.

The script handles these quirks on read and never repairs them in the file:
- Mac Roman encoding (0x87 á, 0x92 í, 0xD0 en dash, 0xD5 right quote).
- CRLF line endings.
- 1 header row + 71 data rows × 42 columns. Six header cells read `reference`. The last four columns are unnamed and empty; one cell holds a single space.
- Five citations start with a space, and the *Nomascus siki* diet citation prints `);  Geissmann`.

## What the data are
One row is one handedness study sample × species: 71 rows, 41 anthropoid species including *Homo sapiens*. The orang-utans are printed at genus level as `Pongo_sp.`. The `sample_size` values sum to 2,025 individuals, as the Methods state (PDF p. 11).

Per study, the table gives MHI (direction, −1 to +1) and MABSHI (strength, 0–1), each with SD, SE and n. All are from the coordinated bimanual "tube task". The rows were combined from Caspar et al. 2022 (eLife; 26 rows of its own samples) and the Soto et al. 2022 meta-analysis.

Per species, repeated on every row of the species, each with its own printed reference column:
- body mass (kg)
- ECV (cm³)
- tool use
- substrate (AR/BOTH/T)
- % fruit
- % fruit + animal
- social system
- IMI
- competition level (1–4)
- extractive foraging (0/1)
- social learning (0/1)
- body-mass dimorphism (M/F)

`imputed_imi`, `imputed_dimo` and `imputed_extractive_social_learning` flag the authors' own estimates. Imputed values are model output, never data.

**Data role: secondary.** The authors compiled every value from the work printed in the matching reference column.

## Build
`Püschel_etal_2026_S1Data.R` (run: `LANG=en_US.UTF-8 Rscript --vanilla Püschel_etal_2026/Püschel_etal_2026_S1Data.R`) writes two files:
- `Püschel_etal_2026_S1Data.csv`: 71 rows × 44 columns.
- The public TSV `__Public/comparative-data/10.1371%2Fjournal.pbio.3003771_S1Data.tsv`.

Columns keep the printed order. Each `reference` header is named after the variable printed before it (`handedness_reference`, `body_mass_ref`, `ecv_reference`, …). Printed units are kept, and project units are added beside them: `body_mass_g` = kg × 1000 and `ecv_mm3` = cm³ × 1000. Codes stay as printed. Text is trimmed and runs of white space are collapsed; nothing else is changed. Definitions: `reference_tables/Püschel_etal_2026_S1Data_definitions.csv` (44 columns plus 4 `Method:` rows).

**R NOT RUN.** Cowork has no R. A Python mirror of this script wrote the CSV and TSV on 2026-11-03, using the same read, renaming, species mapping and `write.csv`/`write.table` formatting. Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Species.** Each printed name, with its underscore, maps through `_keys/General/species_key.csv`: 41 rows, `source_publication = Püschel_etal_2026`, basis `verbatim`. 39 names were already in the hub. Two hub rows were added to `_keys/species_reference.csv`: *Macaca leonina* (NCBI 90387) and *Nomascus siki* (NCBI 9586). `Pongo_sp.` maps to the hub's genus-level `Pongo sp.`, as printed.

**References.** `reference_tables/Püschel_etal_2026_S1Data_references.csv` lists 54 works, one per printed citation (`ref_key` = the citation as printed, white space normalised). For each it gives:
- the columns that cite it;
- row counts and the `reference_name_in_analyses` labels;
- its repo status and main-text reference number.

`_reference_columns.csv` declares the 13 reference columns. The script does not call `build_source_match()`. The keys are full citations, so its dictionary match leaves a trailing "." on every cell and "computed as M F" in `bm_dimo_reference` as residual text. Expect those residuals if you run it; they are not unknown references. The Fleagle citation prints "Amsterdam_; Boston" and is one work, not two.

## Table checks
Script section 5 runs 754 checks: 750 pass and 4 do not. The results stay in `table_checks` and are never written to the CSV or TSV. Values are kept as printed.
- **Totals (2):** n sums to 2,025, and there are 41 distinct species, as the Methods state. Pass.
- **SE = SD/√n (142):** MHI and MABSHI, every row. All pass within the rounding of two printed decimals.
- **MABSHI ≥ |MHI| (71):** all pass.
- **Species-level covariates identical on every row of a species (255; 17 species with 2+ rows × 15 columns):** 2 mismatches.
  - *Ateles fusciceps* body mass is 9.03 on row 1 and 9 on rows 2–3.
  - *Sapajus apella* `imputed_extractive_social_learning` is Yes on row 61 only; rows 55–60 say No.
- **Imputed flag = Yes exactly when the reference is blank (284):** 2 mismatches. *Homo sapiens* (row 15) has blank extractive-foraging and social-learning references but is not flagged as imputed.

## Printed-data observations (reported, not corrected)
- *Sapajus apella* rows 59 (Phillips & Sherwood 2007) and 60 (Phillips, Sherwood & Lilak 2007) print identical MHI, MABSHI, SD, SE and n = 13. This is probably one sample entered twice. Both rows are kept.
- The Methods (PDF p. 11) describe PhyloPars imputation for IMI and dimorphism only. S1 Data also flags 9 species as imputed for extractive foraging and social learning: 8 on every row, plus *Sapajus apella* on row 61 only. The method for those is not described.
- The Fig 2 legend and the Methods define competition level "sensu [1–4,70]". Refs 1–4 are handedness papers. S1 Data cites ref 70 (Plavcan et al. 1995), plus Plavcan & van Schaik 1997 for *Homo*.
- *Homo sapiens* substrate and dimorphism cite Galán-Acedo et al. 2019, which has no *Homo sapiens* row.

## App wiring (2026-11-03; R NOT RUN)
- **Source-table browser:** a `__ShinyApp/data/source_manifest.csv` row for `10.1371%2Fjournal.pbio.3003771_S1Data.tsv`, with the source note `__Public/comparative-data/10.1371%2Fjournal.pbio.3003771_S1Data.ReadMe.md`. The row is in `build_data.R`'s format; rerun `build_data.R` to regenerate the manifest.
- **Compiled database:** `__merging_supplementary` gains two `distinct` labels, `Handedness_index_mean_Püschel2026 (HI)` and `Handedness_strength_mean_Püschel2026 (abs(HI))`.
  - Per species, each is the sample-size-weighted mean of the study rows (new aggregate `wmean:sample_size`). That weighting reproduces Caspar 2022 Table 1 where the same samples are pooled.
  - They are secondary and never pooled with the behaviour merge's Caspar 2022 labels, because 26 S1 Data rows are Caspar's own samples and 23 more are literature samples Caspar pooled.
  - The covariates are not wired. They reprint other works, which the repo builds, or should build, from the original sources.
  - See `__merging_supplementary/README__merging.md`.

## Cross-source comparison (restricted repo)
`Evo-M1-Trait-Data-restricted/restricted_checks/Püschel_etal_2026/comparison/` compares S1 Data with the five cited works the repo already holds:
- **Caspar 2022:** 34 of 38 species reproduce Table 1, and tool use matches for all 38.
- **Galán-Acedo 2019:** body mass, dimorphism and substrate show no disagreements.
- **Reader 2011:** extractive foraging and social learning show no disagreements.
- **Powell 2017:** % fruit differs for 18 of 34 species. This is a provenance question for the authors.

That folder lists the sources still needed to check the remaining 49 cited works.

## Not built
S2 Data (the numbers plotted in Figs 2–4) and the S1–S3 Tables, S1–S2 Figs, S1–S2 Sections and S1–S2 Code are model output and code, not trait data, and none of them is in the source folder.

Assistant build; no human sign-off is claimed or needed (born-digital).
