# Grande__1950_TablaVI

**Item name** `Grande__1950_TablaVI` · **Item number** `Tabla VI` · **Item encoded** `RevClinEsp%3A39%3A1-17_TablaVI` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx` — checked by Item name on 2026-11-03; code derived as the registry formula builds it from column C: no DOI exists, so the alternate code `RevClinEsp:39:1-17` is percent-encoded + `_` + locus, the `Babushina_etal_1991` / `Brodmann__1913` convention. Paste `Grande__1950_TablaVI_registry_row.xlsx` (sets column C to the alternate code), run `_tools/file_list.R`, rename the TSV if the registry differs.)

Grande, F. (1950). El consumo de oxígeno del cerebro. *Revista Clínica Española*, 39(1), 1-17 (15 octubre 1950). No DOI.

**Item full original title:** TABLA VI. Metabolismo cerebral en tanto por ciento del metabolismo total en reposo del organismo adulto, en varias especies de mamíferos. Las cifras de consumo de oxígeno cerebral calculadas con el valor de 3,7 c. c. por 100 g. y minuto (Schmidt, Kety y Pennes). p. 6.

## Source

PDF in this folder: `Grande-1950-[Cerebral consumption of oxygen].pdf` (17 pages = printed pp. 1-17; copied here from `/Users/crossmodal/Documents/References.Data/PDF/3829176228/`). Tabla VI is on PDF page 6 (printed p. 6). Not built from this paper (outside the requested scope): Tablas I-V and VII (animal organ O2, blood flow, Krebs-based comparison) and Tabla X (drug effects). Tabla VIII and IX are separate items.

## Pipeline

```
Source (PDF)
  -> Grande__1950_extract_snapshot.R   writes the frozen snapshot(s) (verbatim printed-layout blocks; refuses to overwrite)
  -> Grande__1950_TablaVI_snapshot.csv   FROZEN: 19 rows x 6 cols (3 caption rows, header, 15 species rows)
  -> Grande__1950_TablaVI.R   clean + parse + convert units + table checks
  -> Grande__1950_TablaVI.csv   15 rows x 20 cols  ("use this")
  -> __Public/comparative-data/RevClinEsp%3A39%3A1-17_TablaVI.tsv
  -> reference_tables/Grande__1950_TablaVI_definitions.csv, _references.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 170-450-dpi renders and crops of PDF page 6 (pymupdf; read as page images and zoomed crops), typed as a verbatim printed-layout block into the folder's `*_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The PDF text layer is OCR of a 1950 scan and is not a usable second reading; as a weak presence check only, 73 of the 75 numeric cells occur as tokens on the page text (the two absent, `21,7` and `0,014`, are OCR misreads and were confirmed on the image). Every value was **re-read cell by cell from the page image at high zoom** and, for the species tables, compared by script with an earlier transcription held in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (used only as a starting point): 0 differences. The build `*.R` reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row: caption lines (title, caption, subtitle with the 3,7 rate), the six-column header (line breaks kept as `\n`), 15 species rows in printed order. Spanish number format is kept in the snapshot (`6.650` = 6650 kg; `1.296` = 1296 c.c.; `3,80` = 3.80) and parsed only in the build. Leader dots after labels omitted; O2 subscript written `O2`.
* The analysis CSV has one row per printed species row (observation level: a representative animal per row, **not** a species mean from a sample; two rows each for Elefante and Caballo, as printed). `*_printed` columns keep the printed text; numeric columns are in project units (body g, brain mg) and umol O2 (mL x 44.64 = 1000/22.4).
* **Brain O2 is not measured.** The caption states the cerebral O2 figures were calculated with 3,7 c.c./100 g/min (Schmidt, Kety & Pennes) for every species; `Brain_O2_rate_assumed.umol_100g_min` = 165.168 records the input, `brain_O2_basis` flags every row. The informative columns are body mass, brain mass and total O2 (compiled; the source of each is not stated in the table).
* Hombre row: brain 1.400 g, total 250 c.c./min, 52 c.c./min, 20,8 % (the share Tabla VI prints for man; Tabla IX prints 19 % for the brain from the measured 3,30 rate instead).

## Table checks

Result of an actual R run (2026-11-03): **29 pass, 1 mismatch, 0 not evaluable**, of 30 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `brainO2_2_Elefante` | brain weight x 3.7/100 vs printed brain O2 c.c./min, row 'Elefante' | 181.152 | 182 | -0.848 | 0.5185 | mismatch |

The only mismatch is the **second Elefante row's brain O2**: 4.896 g x 3,7/100 = 181.15 c.c./min vs printed **182** (the first Elefante row, 5.700 g, reproduces: 210.9 vs 211). Raised as errata `Grande__1950-E001` (publication_error, proposed); the printed value is kept. The printed 'Metabolismo cerebral en % del total' column reproduces on all 15 rows within propagated rounding of the printed cells (e.g. Monos 3,4/36,0 = 9.44 vs 9,5; Cobayo 0,17/10,3 = 1.65 vs 1,6: Grande computed the % from unrounded brain O2). Nothing was changed to make a check pass.

**Printed-vs-recomputed, strict view (rounding the recomputed value to the printed decimals):** brain O2 differs from print only for Elefante 2 (181 vs 182). The % column, recomputed from the printed brain O2, differs by 0.1 in Elefante 2 (3,1 vs 3,0), Chimpancé (9,1 vs 9,0), Monos (9,4 vs 9,5), Cobayo (1,7 vs 1,6) and Ratón (1,9 vs 1,8); from the unrounded product it differs in Hombre (20,7 vs 20,8), Chimpancé, Monos, Cobayo only by that same 0.1 - i.e. last-digit rounding in the printed %, not errors.

## Data role

**secondary** — secondary compilation/calculation (older literature; brain O2 is a calculation from an assumed constant rate). Per-row source citations are in `reference_tables/Grande__1950_TablaVI_references.csv`; use them as a roadmap to the primary measurements, never re-ingest these compiled figures as if primary. Not merged (`__merging_cerebral_metabolic_rate` is untouched).

## Species names

`species_as_published` keeps the printed Spanish common name (no binomial is printed). 'Monos (ateles)' is printed with the genus name of the spider monkeys; the text attributes the monkey data to Schmidt, Kety & Pennes (1945), whose animals may be another genus — not verified. No `_keys/` file was edited; proposals are in `reference_tables/Grande__1950_species_key_proposed.csv` (collection `General`, `source_publication` = `Grande__1950`).

## Per-row sources

Only two per-row sources are discernible, both outside the table: the caption names Schmidt, Kety & Pennes as the source of the rate (every row), and the running text (p. 6) names Schmidt, Kety & Pennes for the monkey rows (11 animals, 3,8 kg) and Himwich & Nahum for the dog row (13 dogs, 16,4 kg). The sources of the body weights, brain weights and total O2 of the other 13 rows are **not stated** in the pages read (pp. 4-7), so they are not recorded; this is unverifiable from the PDF alone.

## Compilation comparison (done AFTER the snapshot was frozen)

Compared by script with `classic_energetics_compilations/grande_1950_1980_species_tables.csv` only after freezing; no printed value changed. All 15 species rows x 5 numeric cells agree (0 differences). That file's `brain_O2_check` / `pct_check` labels (e.g. 'differs') used tighter tolerances than the propagated-rounding tolerance of `table_checks` here; the rows it flagged reproduce under rounding except the one listed under Table checks.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Grande__1950_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Grande__1950-E001 | Brain_O2.mL_min | Tabla VI p. 6, second Elefante row (3.752 kg / 4.896 g), column 'Consumo de O2 del cerebro c. c. min.' | 182 |  | publication_error | 181 | proposed | Caption rule: 4.896 g x 3,7 c.c./100 g/min = 181.2 c.c./min; the printed 182 is 0.85 above that and outside rounding of the printed cells (tolerance 0.52). The other 14 rows reproduce. The printed % (3,0) is consistent with either 181 or 182 (181.2/5960 = 3.04; 182/5960 = 3.05). Re-read at 300 dpi. | Kept as printed; the first Elefante row (211 for 5.700 g = 210.9) reproduces. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
