# Capellini et al. 2008 — mammalian sleep (`sleep-data_Female` / `_Male` / `_Mixed`)

**Built 2026-08-05.** Three registry items, one build script, three analysis CSVs, three public TSVs.

## Source

Capellini, I., Barton, R. A., McNamara, P., Preston, B. T., & Nunn, C. L. (2008). *Phylogenetic
analysis of the ecology and evolution of mammalian sleep: a reappraisal.* **Evolution 62(7):1764–1776.**
DOI **10.1111/j.1558-5646.2008.00392.x** · open copy PMC2674385.

**Frozen source — digital-native, no derived snapshot** (`__HOWTO_build_a_dataset_file.md` §0a
invariant 1). The three files below are untouched exports from the mammalian-sleep database cited by
the paper, pulled with the search term `Sex = Female / Male / Mixed` (recorded in the registry's
*Note about item*). They are the frozen copies — never edit them.

| Frozen source | Records | Registry item | Public TSV |
|---|---|---|---|
| `sleep-data_Female.csv` | 40 | `Capellini_etal_2008_sleep-dataFemale` | `10.1111%2Fj.1558-5646.2008.00392.x_sleep-dataFemale.tsv` |
| `sleep-data_Male.csv` | 89 | `Capellini_etal_2008_sleep-dataMale` | `10.1111%2Fj.1558-5646.2008.00392.x_sleep-dataMale.tsv` |
| `sleep-data_Mixed.csv` | 54 | `Capellini_etal_2008_sleep-dataMixed` | `10.1111%2Fj.1558-5646.2008.00392.x_sleep-dataMixed.tsv` |

**183 records, 93 resolved species** (35 already in `_keys/species_reference.csv`).

## Granularity — one row per STUDY RECORD, not per species

Each row is one primary sleep study × species × sex class. Several references report the same
species, and a species can appear in more than one of the three files. **Aggregate to species means
at the merge, not here** (§3, "granularity"). `Reference` / `Full_Reference` name the study that
actually measured each row — Capellini is the compiler, not the measurer.

## Build

`Capellini_etal_2008_sleep-data.R` — reads the three frozen CSVs, resolves species, derives the two
standardized terms, writes the analysis CSV and the DOI-coded public TSV for each.

No unit conversion is needed: sleep times are printed in **hours per day** and kept that way; the
sleep cycle is printed in **minutes**. The one derivation is

```
REM_sleep_pct = 100 * REM_h / Sleep_h_day        # = 100 * Daily_PS_time / Total_daily_sleep
```

Missing tokens in this source are `""` and `N/A`.

Source columns are renamed once, in the script: `Total_daily_sleep → Sleep_h_day`,
`Daily_PS_time → REM_h` (PS = paradoxical sleep = REM), `Quiet_sleep_time → NREM_h`,
`Sleep_cycle_length → Sleep_cycle_min`, and `Diet → Diet_condition` (the source's `Diet` is the
feeding condition during recording, **not** the ecological diet trait — renamed so it cannot be
mistaken for one). Every rename is listed in `reference_tables/Capellini_etal_2008_definitions.csv`
under *Source Note*.

## Species names

Printed names are preserved verbatim in `SpeciesName_Reported` (invariant 3). Resolution is entirely
through the key — **108 rows added to `_keys/Stephan/species_key.csv` with
`source_publication = Capellini2008`** — with nothing hand-coded in the script (§5). The export
prints Title Case (`Arctocephalus Pusillus`), inbred strains (`BALB/c`, `C57BL/6J`,
`Sprague-Dawley Rat`), breeds (`Beagle Dog`, `New Zealand White Rabbit`, `Pottock Pony`) and bare
common names (`Cat`, `Goat`, `Pig`, `Jaguar`), all mapped in the key.

### Three labels left unresolved — for the curator

Deliberately **not** given a key row, so no guess enters the data. `species_sci` keeps the cleaned
printed label (or `NA`):

| Printed | Record | Why unresolved |
|---|---|---|
| `Fur Seal` | Mixed | Genus not stated; both *Arctocephalus pusillus* and *Callorhinus ursinus* appear elsewhere in the same export |
| `Tapir` | Mixed, Zepelin 1970 | Four living *Tapirus* species; the record names none |
| `N/A` | Mixed, Hänninen et al. 2008 | Species column is `N/A`; `CommonName_Reported = "Calves"`, so almost certainly *Bos taurus* — needs the primary to confirm. `species_sci` is `NA` |

## Data-quality columns — read before using a row

The export carries the compilation's own screening columns, all retained: `Lab_condition_score`
(composite quality index), `EEG`, `Telemetry`, `Twenty_four_hour`, `Light`, `Adaptation`,
`Diet_condition`, `Temperature`, `Restraint`, `Behavioural`. **11 of 183 records carry an `Error`
flag**, and `Notes_Misc` records provenance warnings (e.g. "Data Match Elgar Et Al. (1988)").
`Data_came_from` marks which earlier compilation a row descends from.

## Not done here (scope: through public TSV + registry)

Merge wiring into `__merging_sleep` is **not** done — no merge script was touched. When it is:

- `Sleep_h_day` currently comes from Herculano-Houzel 2015, whose daily-sleep column descends from
  the **same** older compilations (Zepelin; Campbell & Tobler). Capellini vs HH is therefore
  **citation-dependent → resolve, never average**.
- `REM_sleep_pct` currently comes only from Eagleman & Vaughn 2021 (25 primates). Capellini adds
  non-primate REM; new species do not conflict, shared species resolve by the same rule.
- Lesku et al. 2006 (Am Nat 168:441, DOI 10.1086/506973) is the antecedent compilation — same
  lineage, resolve rather than average if it is ever ingested.
- The `USWS` / `BSWS` / `ASWS` columns are **free text**, not the numeric `USWS_pctTST` that
  Lyamin et al. 2008 supplies. Do not pool them.

## Verification

- 40 + 89 + 54 = 183 records out, matching the three frozen files row-for-row.
- Every `REM_sleep_pct` recomputed from the written TSV reproduces `100 × REM_h / Sleep_h_day`.
- No species name resolved outside `species_key.csv`.
- **Re-run `Capellini_etal_2008_sleep-data.R` in RStudio** to confirm it reproduces these files —
  the committed CSV/TSV were written by an offline mirror of the script (no R in the authoring
  environment).
