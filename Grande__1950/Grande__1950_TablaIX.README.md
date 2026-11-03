# Grande__1950_TablaIX

**Item name** `Grande__1950_TablaIX` · **Item number** `Tabla IX` · **Item encoded** `RevClinEsp%3A39%3A1-17_TablaIX` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx` — checked by Item name on 2026-11-03; code derived as the registry formula builds it from column C: no DOI exists, so the alternate code `RevClinEsp:39:1-17` is percent-encoded + `_` + locus, the `Babushina_etal_1991` / `Brodmann__1913` convention. Paste `Grande__1950_TablaIX_registry_row.xlsx` (sets column C to the alternate code), run `_tools/file_list.R`, rename the TSV if the registry differs.)

Grande, F. (1950). El consumo de oxígeno del cerebro. *Revista Clínica Española*, 39(1), 1-17 (15 octubre 1950). No DOI.

**Item full original title:** TABLA IX. Metabolismo de distintos órganos humanos (expresado en consumo de oxígeno). Metabolismo basal estimado en 2?0 c. c. de oxígeno por minuto. p. 12.

## Source

PDF in this folder: `Grande-1950-[Cerebral consumption of oxygen].pdf` (17 pages = printed pp. 1-17; copied here from `/Users/crossmodal/Documents/References.Data/PDF/3829176228/`). Tabla IX is on PDF page 12 (printed p. 12); the three footnote paragraphs under the table are part of the snapshot.

## Pipeline

```
Source (PDF)
  -> Grande__1950_extract_snapshot.R   writes the frozen snapshot(s) (verbatim printed-layout blocks; refuses to overwrite)
  -> Grande__1950_TablaIX_snapshot.csv   FROZEN: 12 rows x 8 cols (2 caption rows, 2 header rows, 5 organ rows, 3 footnote rows)
  -> Grande__1950_TablaIX.R   clean + parse + convert units + table checks
  -> Grande__1950_TablaIX.csv   5 rows x 23 cols  ("use this")
  -> __Public/comparative-data/RevClinEsp%3A39%3A1-17_TablaIX.tsv
  -> reference_tables/Grande__1950_TablaIX_definitions.csv, _references.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 170-450-dpi renders and crops of PDF page 12 (pymupdf; read as page images and zoomed crops), typed as a verbatim printed-layout block into the folder's `*_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The PDF text layer is OCR of a 1950 scan and is not a usable second reading; as a weak presence check only, all 34 numeric cells occur as tokens on the page text. Every value was **re-read cell by cell from the page image at high zoom** and, checked against the earlier transcription in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` where it covers this table (see 'Compilation comparison'); that file was used only as a starting point. The build `*.R` reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row: title, caption (with the smudged BMR digit recorded as `2?0`), the two-tier header (the spanner 'Consumo de oxigeno' over its two sub-columns), five organ rows, three footnote paragraphs. Musculatura (reposo) is printed on two lines with values on the second; one row. The Corazón A-V difference prints an em dash (kept `—`, NA in the CSV). Spanish number format kept (`1.400` = 1400 g, `30.000` = 30000 g; `54,0`).
* **The BMR in the caption is smudged.** The middle digit of `2?0 C. C.` is unreadable on the page (it looks like a colon-like mark). The cell is recorded as printed in `BMR_in_heading_as_printed` and is **not** replaced by 250; 250 c.c./min (Tabla VI, running text p. 12 'unos 250') is used only inside the table checks and labelled as an assumption there.
* The analysis CSV has one row per organ (observation level: organs of an average 70 kg adult human assembled from different studies; the heart row is calculated from dog data per the printed footnote). The body weight is not printed in this table (Tabla VI prints Hombre 70 kg; 1.400 g = 2,00 % implies 70.000 g).

## Table checks

Result of an actual R run (2026-11-03): **16 pass, 3 mismatch, 1 not evaluable**, of 20 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `pct_weight_Musculatura (reposo)` | 100 x weight / 70000 g vs printed % del peso total, Musculatura (reposo) | 42.8571 | 43 | -0.142857 | 0.00571429 | mismatch |
| `pct_weight_Corazón` | 100 x weight / 70000 g vs printed % del peso total, Corazón | 0.392857 | 0.4 | -0.00714286 | 0.00571429 | mismatch |
| `fick_Cerebro` | flow x A-V difference / 100 vs printed O2 per 100 g, Cerebro | 3.402 | 3.3 | 0.102 | 0.03515 | mismatch |
| `fick_Corazón` | flow x A-V difference / 100 vs printed O2 per 100 g, Corazón |  | 10 |  |  | not_evaluable |

Mismatches: (1) **Musculatura % del peso total** prints 43,00 but 30.000 g / 70 kg = 42.86 (errata `Grande__1950-E002`); (2) **Corazón % del peso total** prints 0,40 vs 0.393 (marginal, `E003`); (3) **Cerebro Fick**: 54,0 x 6,3 / 100 = 3.40 vs printed rate 3,30 (`E004`, an ambiguity, since 3,30 is a mean of 34 observations). Not evaluable: Corazón (no A-V difference; printed dash).

**Brain share of BMR, a finding that sits inside the tolerance:** printed total 46 c.c./min over the (heading-smudged) 250 c.c./min is 46/250 = **18.4 %**, printed **19** (recomputed value rounds to 18; the text twice says 'del orden del 19 por 100'). The propagated tolerance (0.7) allows it because the printed 46 is itself 46.2 rounded; with the heading digit read as 250. Grande 1980 Table 1 (Ref 15) repeats 19. Not raised as an erratum; flagged here. The five organs' printed percentages of BMR sum to 81 (19+4+27+20+11) and the printed totals to 201 of 250 c.c./min (80.4 %); no total row is printed, so no sum check is made, and 'Grande 1980' states the same 61 % / 81 % subtotals for Ref 15.

## Data role

**secondary** — secondary compilation (Kety & Schmidt 1948 brain; Bradley & Helperin 1948 kidney; Myers 1947 liver; Asmussen, Christensen & Nielsen 1939 muscle; Goodale et al. dog heart). Per-row source citations are in `reference_tables/Grande__1950_TablaIX_references.csv`; use them as a roadmap to the primary measurements, never re-ingest these compiled figures as if primary. Not merged (`__merging_cerebral_metabolic_rate` is untouched).

## Species names

`species_as_published` = 'humanos' (caption 'organos humanos'). Taxon Homo sapiens; the heart row is calculated from dog data (footnote), not human. No `_keys/` file was edited; proposals are in `reference_tables/Grande__1950_species_key_proposed.csv` (collection `General`, `source_publication` = `Grande__1950`).

## Per-row sources

Each organ's source is named in the footnotes under the table (author + year as printed, in `ref_keys_source`; see the references table). Notable: **Goodale y colaboradores (1948)** is printed with 1948 in the footnote but the bibliography entry (Science 109, 117) prints **1949** (kept, not corrected); **Bradley y Helperin (1948)** has two bibliography candidates (J Clin Invest 27 with a smudged page, and a 1947 Federation Proc. entry); **Kety y Schmidt (1948)** has two 1948 entries (27:476 and 27:484).

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with the Grande_1950 Tabla IX row of `classic_energetics_compilations/classic_human_brain_partition.csv` after freezing (brain 1400 g, 3,30, 46, 19; that file recomputes 18.4 % vs printed 19 as here); no printed value changed. The earlier file did not carry the other four organs.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Grande__1950_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Grande__1950-E002 | pct_of_body_weight | Tabla IX p. 12, row Musculatura (reposo), column '% del peso total' | 43,00 |  | publication_error | 42,86 | proposed | 30.000 g / 70 kg = 42.86 % (body weight 70 kg from Tabla VI; brain 1.400 g = 2,00 % implies 70.000 g). Printed 43,00 is 0.14 above, outside rounding (tolerance 0.006). | Kept as printed. Body weight is not printed in Tabla IX; the check assumes 70 kg. |
| Grande__1950-E003 | pct_of_body_weight | Tabla IX p. 12, row Corazón, column '% del peso total' | 0,40 |  | publication_error | 0,39 | proposed | 275 g / 70.000 g = 0.393 %; printed 0,40 is 0.007 above the printed-decimal rounding band (tolerance 0.006). Marginal. | Marginal (0.4 vs 0.39); kept as printed. |
| Grande__1950-E004 | O2_rate.mL_100g_min | Tabla IX p. 12, row Cerebro, columns 'Riego sanguineo' (54,0), 'Diferencia O2 arterio-vena' (6,3) and 'Por 100 g. y minuto' (3,30) | 3,30 |  | publication_ambiguity |  | proposed | Fick relation: flow x A-V difference / 100 = 54,0 x 6,3 / 100 = 3.40 c.c./100 g/min vs printed rate 3,30 (difference 0.10; tolerance 0.035). The 3,30 is the Kety & Schmidt 1948 mean of 34 observations; means of products need not equal the product of means, so this is not necessarily a print error. The other organs reproduce (kidney, liver, muscle). | Kept as printed. Grande 1950 text and Tabla VIII also print 3,3. |

3 recorded, 3 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
