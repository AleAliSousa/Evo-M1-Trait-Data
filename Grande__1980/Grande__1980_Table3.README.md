# Grande__1980_Table3

**Item name** `Grande__1980_Table3` · **Item number** `Table 3` · **Item encoded** `AssessEnergyMetab%3A1980%3A88-92_Table3` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx` — checked by Item name on 2026-11-03; code derived as the registry formula builds it from column C: no DOI exists, so the alternate code `AssessEnergyMetab:1980:88-92` is percent-encoded + `_` + locus, the `Babushina_etal_1991` / `Brodmann__1913` convention. Paste `Grande__1980_Table3_registry_row.xlsx` (sets column C to the alternate code), run `_tools/file_list.R`, rename the TSV if the registry differs.)

Grande, F. (1980). Energy expenditure of organs and tissues. In *Assessment of energy metabolism in health and disease: Report of the First Ross Conference on Medical Research* (pp. 88-92). Columbus, Ohio: Ross Laboratories. No DOI. (Editor not printed on the supplied pages.)

**Item full original title:** Table 3. Brain O2 uptake as percentage of total O2 consumption* (BMR) in mammalian species. p. 90.

## Source

PDF in this folder: `Grande_1980.pdf` (British Library On Demand copy; PDF page 4 = printed p. 90; copied here from `/Users/crossmodal/Documents/References.Data/PDF/0304089163/`).

## Pipeline

```
Source (PDF)
  -> Grande__1980_extract_snapshot.R   writes the frozen snapshot(s) (verbatim printed-layout blocks; refuses to overwrite)
  -> Grande__1980_Table3_snapshot.csv   FROZEN: 19 rows x 6 cols (caption, 3 header tiers, 14 species rows, footnote)
  -> Grande__1980_Table3.R   clean + parse + convert units + table checks
  -> Grande__1980_Table3.csv   14 rows x 18 cols  ("use this")
  -> __Public/comparative-data/AssessEnergyMetab%3A1980%3A88-92_Table3.tsv
  -> reference_tables/Grande__1980_Table3_definitions.csv, _references.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 170-450-dpi renders and crops of PDF page 4 (printed p. 90) (pymupdf; read as page images and zoomed crops), typed as a verbatim printed-layout block into the folder's `*_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The text layer of the British Library scan is partly usable: as a presence check only (not positional), 69 of the 70 numeric cells occur as tokens on the page text (the absent `19`, Rabbit brain weight, has a scan speck beside it; confirmed on the image). Every value was **re-read cell by cell from the page image at high zoom** and, for the species tables, compared by script with an earlier transcription held in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (used only as a starting point): 0 differences. The build `*.R` reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row: caption, the three-tier header (spanner 'Total O2 / Consumption BMR' and 'Brain O2 Uptake' over Total and % of BMR; units on the third tier), 14 species rows in printed order, the footnote. English number format kept (`6,650` = 6650 kg; `0.800`); O2 subscripts written `O2`.
* The analysis CSV has one row per printed species row (representative animals, **not** species means from a sample; two Elephant and two Horse rows as printed), `*_printed` text columns plus numeric project-unit columns (body g, brain mg, umol O2).
* **Brain O2 is not measured.** The footnote prints 'Brain O2 consumption = 3.5 ml/100 g/min for all the species'; `Brain_O2_rate_assumed.umol_100g_min` = 156.24 records the input. Same 14 species rows as Grande 1950 Tabla VI but with 3.5 instead of 3.7, so brain O2 values and % are ~5 % lower (e.g. Man 49 vs 52 mL/min; 19.6 vs 20.8 %). All printed body/brain/BMR cells are identical to Tabla VI (the Elephant, Horse, Pig, Man ... rows), which is why the two items are not independent.

## Table checks

Result of an actual R run (2026-11-03): **28 pass, 0 mismatch, 0 not evaluable**, of 28 checks.

All checks pass.

All 28 checks pass under propagated rounding of the printed cells. Several printed percentages differ by 0.1 from a naive recomputation from the printed brain O2 (Pig 1.0, Chimpanzee 8.6, Monkey 8.8, Rabbit 3.1: Grande computed the % from the unrounded brain O2, e.g. Rabbit 19 g x 3.5/100 = 0.665 -> 3.06 % -> 3.1; from the printed 0.7 it would be 3.2). Dog brain O2 prints 2.4 for an exact 2.45 (round-half). These are rounding, not errors; nothing was changed. Man: 49 mL/min = 1,400 g x 3.5/100 exactly; 49/250 = 19.6 %.

## Data role

**secondary** — secondary compilation/calculation (same underlying rows as Grande 1950 Tabla VI; brain O2 is a calculation from an assumed constant rate). Per-row source citations are in `reference_tables/Grande__1980_Table3_references.csv`; use them as a roadmap to the primary measurements, never re-ingest these compiled figures as if primary. Not merged (`__merging_cerebral_metabolic_rate` is untouched).

## Species names

`species_as_published` keeps the printed English common name; 'Monkey (Ateles)' as printed (see the Grande__1950 note on a possible genus mismatch, not verified). No `_keys/` file was edited; proposals are in `reference_tables/Grande__1980_species_key_proposed.csv` (collection `General`, `source_publication` = `Grande__1980`).

## Per-row sources

The table prints no per-row references. The text immediately above (p. 90) names the sources behind the 3.5 ml/100 g/min value: Schmidt, Kety & Pennes (ref 26, small 3.8 kg monkeys) and Kety & Schmidt (refs 25, 39, human). They are recorded in `reference_tables/Grande__1980_Table3_references.csv` as **text-derived** entries, not table-printed ones. The sources of the body weights, brain weights and BMRs are not stated; the rows are those of Grande 1950 Tabla VI (his ref 15).

## Compilation comparison (done AFTER the snapshot was frozen)

Compared by script with `classic_energetics_compilations/grande_1950_1980_species_tables.csv` only after freezing; no printed value changed. All 14 species rows x 5 numeric cells agree (0 differences). That file's `brain_O2_check` / `pct_check` labels (e.g. 'differs') used tighter tolerances than the propagated-rounding tolerance of `table_checks` here; the rows it flagged reproduce under rounding except the one listed under Table checks.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
<!-- errata:end -->
