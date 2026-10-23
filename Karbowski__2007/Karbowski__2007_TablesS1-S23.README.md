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
- Per table: local `Karbowski__2007_Table S<N>.csv` and DOI-encoded public TSV
  `__Public/comparative-data/10.1186%2F1741-7007-5-18_Table S<N>.tsv`
  (code looked up from `__ReadMe.xlsx` Sheet1, `Item encoded` matched on `Item name`).

### Tidy long schema (all 23 tables, one row per printed value × measure)
`table, source_snapshot_row, structure, subregion, species_printed, species, is_average,`
`measure, value, value_printed, sd, sd_printed, units, n_areas, reference`

- `species_printed` keeps Karbowski's common name verbatim (incl. `average <species>`);
  `species` is the harmonised binomial (key token **Karbowski2007** in
  `_keys/Stephan/species_key.csv`).
- `measure`: `CMRgl` (µmol/g·min) for S2–S23; `CMRO2` (ml/g·min) for S1; plus whole-brain
  `Total_glucose_utilization` (µmol/min) and `Total_O2_consumption` (ml/min) for S1/S2.
- `subregion` captures printed subdivisions: S15 *Mammilary body* (spelling as printed),
  S22 *Superior/Inferior colliculus*, S23 *Corpus callosum/Internal capsule*.
- `n_areas` = number of cortical areas averaged (S11, S12 only). S11 has no
  row-level source citation: its `N=4/6/8` strings are retained only as counts,
  while the merge records transitive component-source links from Tables S3-S10.
- Multiple references for one value are joined with `; ` (e.g. S1 human = Clarke + Madsen;
  S2 rat = Nehlig + Waschke + Levant).
- `source_snapshot_row` is the one-based data-row position after the two caption/header
  rows (physical worksheet row = `source_snapshot_row + 2`). It remains exact when a
  workbook row expands to both a mass-specific and total record or when subdivision rows
  are skipped. `value_printed` and `sd_printed` preserve the numeric lexemes printed in
  the published supplement PDF, including trailing zeros. The frozen workbook remains
  the numeric carrier and row locator, but numeric cells there do not retain all display
  formatting (S1 is printed to three decimals; S2–S23 to two).

## House-keeping notes
- **Data role = secondary.** These tables are Karbowski's compilation of *other* labs'
  CMR measurements. The canonical `__merging_cerebral_metabolic_rate` build joins
  direct singleton rows to the cited works in
  `reference_tables/Karbowski__2007_TablesS1-S23_references.csv`; it does not treat
  Karbowski as an independent primary team. The reference catalog distinguishes a true
  primary report from a secondary cited source. Clarke 1994 is a textbook chapter and
  Sokoloff 1984 is a monograph; their direct compiled values remain traceable but are not
  primary evidence unless row-level experimental lineage is recovered.
- **Condition evidence is compilation-level unless overridden.** The main-paper Methods
  (PDF p. 8) says unanesthetized adult animals at resting conditions; it does not establish
  awake state for every cited primary experiment. S1/S2 captions say awake and
  unanesthetized for those tables. The merge retains this distinction, overrides rows when
  primary-specific evidence contradicts or fails to resolve the blanket claim (including
  anesthetized and task-active values, plus Lydic's unresolved quiet-wake versus REM arm),
  and propagates those conditions into derived-row lineage. Positive evidence is retained
  as well: Passero's values are normal conscious controls, Maquet's are wakefulness controls,
  and Schwartzman's are awake stationary controls. Ordinary rows remain in the deliberately
  broad `nonanesthetized_unspecified_arm` category rather than being mislabeled baseline.
- Karbowski compiler averages, S11 cross-area summaries, Quelven-based estimates,
  compound-source rows, and derived whole-brain totals remain in merge provenance but are
  excluded from the primary-only means. Recoverable primary-source lineage for compiler
  averages and S11 summaries is retained in the merge's value-reference link table.
- For project-standard CMRO2, S1's mL O2/g/min values are multiplied by 100 and by
  44.64 µmol/mL. Raw value/unit columns are retained beside the standardized values.
- Registry: 23 rows (Table S1–S23) added to `__ReadMe.xlsx` Sheet1 after the existing
  Karbowski Table 1 row.
- `squirrel` → *Spermophilus tridecemlineatus* is provisional (Frerichs et al 1995 used
  ground squirrels; only appears in Table S2).
- Mouse values attributed to Quelven et al 2004 are estimates (Karbowski derived absolute
  values from a corpus-callosum reference frame; see S23 Supplementary Methods).
- **Generated TSV-list refresh:** run `_tools/file_list.R` so `__ReadMe.xlsx`
  `AUTO_Public_TSV_FileList` is rebuilt from the public directory.

## Checks
- Row counts per table match the snapshot blocks; 410 data rows total across S1–S23.
- Values cross-checked against the supplement PDF captions and spot values.
