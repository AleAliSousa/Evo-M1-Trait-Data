# Kruska 1980 — Tabelle 2 (camelid brain-part volumes, 7 specimens)

Kruska D (1980). *Domestikationsbedingte Hirngrößenänderungen bei
Säugetieren.* Zeitschrift für Zoologische Systematik und
Evolutionsforschung 18(3): 161–195.
doi:10.1111/j.1439-0469.1980.tb00738.x

**Tabelle 2** — per-specimen brain weight, whole-brain volume and
volumes (mm³) of 11 compartments for the **7 camelid brains** of
Tabelle 1 (3 guanaco, 2 alpaca, 2 llama), from complete serial
sections, corrected back to the fresh state.

This is the source of the alpaca row in Castillo-Morales et al. (2016)
Table 1 (their ref 99) — verified exactly: the paper prints no alpaca
mean, and Castillo's values are the arithmetic means of Kruska's two
alpaca specimens (brain volume (180502 + 182432)/2 = 181467 mm³ =
181.467 cm³; neocortex (99985 + 103635)/2 = 101810 mm³ = 101.81 cm³).

## Source → Snapshot → Data readable → Online database

- **Source:** the publisher PDF scan of the paper, held in this folder
  (`Kruska-1980-Domestikationsbeding.pdf`, supplied by Michael Proulx
  2026-11-18); the paper is paywalled at Wiley and has no open copy.
- **Snapshot:** `Kruska__1980_Tabelle2_snapshot.csv` — the table
  transcribed exactly as printed (structure-by-specimen matrix, German
  row labels, space thousands separators and decimal commas kept),
  frozen **before** any cleaning. Transcribed by Buddy (AI assistant)
  on 2026-11-18 from the whole-paper extraction in `extracted_tables/`,
  whose values were verified cell by cell against rendered page
  images. `extracted_tables/` remains the extraction record for all 14
  of the paper's tables; this snapshot is the item's canonical frozen
  copy.
- **Data readable:** `Kruska__1980_Tabelle2.R` reads **only** the
  snapshot, transposes it to one row per specimen, and harmonises
  species through `_keys/Stephan/species_key.csv`. The specimen-to-form
  mapping is read from `reference_tables/Kruska__1980_Tabelle2_specimens.csv`,
  an item-scoped register kept with this item (build HOWTO §7b), so the
  script never reads Tabelle 1's files. It writes
  `Kruska__1980_Tabelle2.csv` (7 rows) and the public TSV, and runs
  clean under Rscript, reproducing the committed CSV/TSV exactly.
- **Definitions:** `reference_tables/Kruska__1980_Tabelle2_definitions.csv`.
- **Online database:** public TSV
  `10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle2.tsv` in
  `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `Kruska__1980_Tabelle2`).

## Table checks

The reader checks two relations the table implies (build HOWTO §7a):
neocortex = its grey + white parts, and the five main parts sum to the
printed pure brain substance. **Result (R run, 2026-11-18): all 14
checks pass** within the tolerance for independently rounded integer
mm³ values — three specimens' grey + white parts differ from the
printed neocortex total by exactly 1 mm³, and one specimen's parts
sum differs by 1 mm³; both are rounding, reported in the check table.
Nothing was adjusted to make a check pass.

## Data role and caveats

- **Primary, per-specimen.** The volumes are Kruska's own measurements
  (complete serial sections, planimetric paper-weighing after Stephan
  1960), each brain corrected to fresh volume by its own factor, with
  fresh volume = fresh weight ÷ **1.035** (specific gravity of brain
  substance — a fifth density convention alongside those in
  `_COMMON_CALCULATIONS.md`). The corrections assume equal shrinkage
  of all parts within a brain.
- **Erratum (proposed):** Tabelle 2 prints specimen A 7's allocortex
  as 14 386 mm³, but Tabellen 6 and 11 print 14 368 and Tabelle 3's
  share (8.22%) confirms 14 368 — recorded as
  `Kruska__1980-E001` in `reference_tables/Kruska__1980_errata.csv`;
  the value is kept as printed in Tabelle 2 and flagged in the CSV.
- **No per-form means are printed** anywhere in the paper: its summary
  tables pool llama + alpaca (n = 4) against guanaco (n = 3). Any
  species mean (like Castillo's alpaca values) is a downstream
  computation from this table.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Kruska__1980_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Kruska__1980-E001 | Allocortex_mm3 | Tabelle 2, column "A 7" (alpaca), row "Allocortex" | 14 386 | 14386 | publication_error | 14368 | proposed | Tabellen 6 and 11 print the same value as 14 368, and Tabelle 3's printed share for A 7's allocortex (8.22% of the pure brain substance 174 751) gives 14 364-14 368, confirming 14 368; the Tabelle 2 printing of 14 386 is a digit transposition. | Value kept as printed in the Tabelle 2 snapshot and analysis CSV (14386); the analysis CSV's note column for specimen A 7 carries the same warning. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
