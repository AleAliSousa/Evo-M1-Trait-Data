# Karbowski (2007) Supplementary Tables S1–S23

**Citation.** Karbowski, J. (2007). Global and regional brain metabolic scaling and its
functional consequences. *BMC Biol*, 5, 18. https://doi.org/10.1186/1741-7007-5-18

**What this is.** The 23 supplementary data tables (S1–S23) that underlie Karbowski's
metabolic-scaling analysis: compiled brain **oxygen consumption** (Table S1) and regional
**glucose utilization rates (CMRglc)** across mammals (Tables S2–S23). Each table lists,
per species, one or more literature values (mean ± SD) with the original reference, plus
Karbowski's per-species averages.

## Source → snapshot
- Raw provenance: `12915_2006_114_MOESM1_ESM.pdf` (published supplement) and the publisher
  spreadsheet `12915_2006_114_MOESM1_ESM.xlsx`.
- The publisher xlsx stores the 23 tables across **18 sheets** — five sheets carry two
  tables each: sheet `Table 1` = S1 + S2; `Table 2` = S3 + S4; `Table 3` = S5 + S6;
  `Table 5` = S8 + S9; `Table 6` = S10 + S11. (Sheet name ≠ table number.)
- Frozen snapshot: **`Karbowski__2007_TablesS1-S23_snapshot.xlsx`** — one sheet per table
  (`Table S1` … `Table S23`), caption + header + data rows in printed order, original
  units, `average <species>` summary rows and printed subdivision labels kept.

## Reformat → analysis CSV + public TSV
- Script: `Karbowski__2007_TablesS1-S23.R` (reads the frozen snapshot).
  Generated in this session with `build_karbowski_S.py` (R not available in the build
  environment); both read the frozen snapshot and produce identical output.
- Per table: local `Karbowski__2007_Table S<N>.csv` and DOI-encoded public TSV
  `__Public/comparative-data/10.1186%2F1741-7007-5-18_Table S<N>.tsv`
  (code looked up from `__ReadMe.xlsx` Sheet1, `Item encoded` matched on `Item name`).

### Tidy long schema (all 23 tables, one row per printed value × measure)
`table, structure, subregion, species_printed, species, is_average, measure, value, sd,`
`units, n_areas, reference`

- `species_printed` keeps Karbowski's common name verbatim (incl. `average <species>`);
  `species` is the harmonised binomial (key token **Karbowski2007** in
  `_keys/Stephan/species_key.csv`).
- `measure`: `CMRgl` (µmol/g·min) for S2–S23; `CMRO2` (ml/g·min) for S1; plus whole-brain
  `Total_glucose_utilization` (µmol/min) and `Total_O2_consumption` (ml/min) for S1/S2.
- `subregion` captures printed subdivisions: S15 *Mammilary body* (spelling as printed),
  S22 *Superior/Inferior colliculus*, S23 *Corpus callosum/Internal capsule*.
- `n_areas` = number of cortical areas averaged (S11, S12 only).
- Multiple references for one value are joined with `; ` (e.g. S1 human = Clarke + Madsen;
  S2 rat = Nehlig + Waschke + Levant).

## House-keeping notes
- **Data role = secondary.** These tables are Karbowski's compilation of *other* labs'
  primary CMR measurements, so they are built for provenance but are **not merged** into
  `__merging_*` (see HOWTO §9). A dedicated metabolic merge, if built, should draw on the
  primary sources, not on this compilation.
- Registry: 23 rows (Table S1–S23) added to `__ReadMe.xlsx` Sheet1 after the existing
  Karbowski Table 1 row.
- `squirrel` → *Spermophilus tridecemlineatus* is provisional (Frerichs et al 1995 used
  ground squirrels; only appears in Table S2).
- Mouse values attributed to Quelven et al 2004 are estimates (Karbowski derived absolute
  values from a corpus-callosum reference frame; see S23 Supplementary Methods).
- **Generated TSV-list refresh:** run `_tools/__file_list.R` so `__ReadMe.xlsx`
  `AUTO_Public_TSV_FileList` is rebuilt from the public directory.

## Checks
- Row counts per table match the snapshot blocks; 410 data rows total across S1–S23.
- Values cross-checked against the supplement PDF captions and spot values.
