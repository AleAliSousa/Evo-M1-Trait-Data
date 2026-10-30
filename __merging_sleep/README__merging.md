# Merging sleep (& torpor) data

Compiles a comparative dataset of **sleep and torpor traits** across papers, following the same
`standardized_term` + compile pattern as `__merging_volumes`, `__merging_gyrification`, and
`__merging_cerebral_metabolic_rate`. Built as a standing home for sleep data because **more sources
keep arriving** — the structure is designed to grow (see *Adding a source* below).

## Scope: focal sleep/torpor traits

Like the other trait readers (cf. `EvoM1_read_gait` / `EvoM1_read_locomotion`), each source contributes
its **focal** traits; finer per-source columns stay in the source table and can be promoted later.

| Standardized_Term | meaning | unit | source |
|---|---|---|---|
| `Species` | accepted binomial (join key) | — | — |
| `REM_sleep_pct` | per cent of total sleep in REM | percent | Eagleman & Vaughn 2021 |
| `Sleep_h_day` | total daily sleep | hours/day | Herculano-Houzel 2015 |
| `SWS_total_pct` | total slow-wave sleep | percent of sleep | Lyamin et al. 2008 |
| `USWS_pctTST` | unihemispheric SWS (= low- + high-amplitude USWS) | percent of TST | Lyamin et al. 2008 |
| `Torpor_type` | daily torpor vs hibernation | `DT` / `HIB` | Ruf & Geiser 2015 |
| `Torpor_Tb_min_C` | minimum torpor body temperature | °C | Ruf & Geiser 2015 |
| `Torpor_bout_max_h` | maximum torpor bout duration | hours | Ruf & Geiser 2015 |

**Torpor/hibernation** (Ruf & Geiser) is a thermoregulatory domain, sleep-*adjacent* rather than sleep
proper; it is included here as a distinct `dependency_group = "torpor"` family, kept clearly separate
from the sleep-architecture traits.

**Deliberately left in the source tables (not promoted to terms):** Eagleman's developmental milestones;
Herculano-Houzel's neuron-density/brain-mass columns; Lyamin Table 2's hemispheric SWS breakdown
(`sws_left/right_hemisphere_pct`, the low/high-amp bilateral components); Ruf & Geiser's `tmr_min`,
`tmr_rel_pct`, `tbd_mean_h`, `ibe_h`, `latitude_deg`, `body_mass_kg`.

**Not a source:** `Lyamin_etal_2008_Table1`. In the paper Table 1 is muscle-jerk counts, and the
sleep-columned stub in that folder is currently **empty** (header only). Cetacean sleep numbers here
come from **Table 2**. If Table 1 is ever populated with its `total_sleep_time_h_day` / `rem_sleep_pct`
columns, it becomes a **second** source of `Sleep_h_day` and `REM_sleep_pct` → apply the combine rules.

## Sources (this build)

| Reference | team | traits | species | role |
|---|---|---|---|---|
| `Eagleman_Vaughn_2021_TABLE1` | Eagleman_2021 | `REM_sleep_pct` | 25 primates | primary (REM) |
| `HerculanoHouzel__2015_Table1` | HerculanoHouzel_2015 | `Sleep_h_day` | 24 mammals | primary (daily sleep) |
| `Lyamin_etal_2008_Table2` | Lyamin_2008 | `SWS_total_pct`, `USWS_pctTST` | 4 cetaceans | primary (SWS/USWS) |
| `Ruf_Geiser_2015_Table1` | RufGeiser_2015 | `Torpor_*` | 213 birds & mammals | primary (torpor) |

Result: **622 long rows across 256 species.** Ten species carry more than one trait *family*, i.e. link
sleep architecture to torpor — e.g. *Erinaceus europaeus* (daily sleep + torpor), *Mus musculus*,
*Mesocricetus auratus*.

## Team-aware, citation-dependency-aware combine

Same rules as the volume / gyrification merges. **They do not bite in this build** because the four
sources contribute *different* traits, so no two values ever compete. State them when adding a source:

- **Within a team (same paper), newest/authoritative wins.**
- **Across teams, average — UNLESS the sources are citation-dependent** (one compiled from the other, or
  both from a shared upstream compilation), in which case never average: prefer the primary and keep the
  other value alongside, flagged.

## Species key & resolution

- **Eagleman** lists common names → resolved to binomials in **`species_resolution_Eagleman.csv`** with a
  `species_confidence` flag (`high` / `medium` / `review`; *Ateles geoffroyi* and *Eulemur fulvus* are
  `review` — verify).
- **Herculano-Houzel** binomials; only `Loxodonta Africana` → `Loxodonta africana` normalised. Genus-level
  `<Genus> sp.` kept as-is.
- **Lyamin** Table 2: four cetacean binomials, used directly.
- **Ruf & Geiser**: `taxon` used directly; a subspecies parenthetical (`Caprimulgus guttatus (argus)`) is
  trimmed to the binomial and flagged `review`.

## Outputs

- **`sleep_long.csv`** — one row per (Species, source, trait): `Species, Species_printed,
  Standardized_Term, Value, Units, source, team, ref, species_confidence, dependency_group` (622 rows).
- **`sleep_wide.csv`** — one row per species (256): `Species` + the seven trait columns + `n_traits`.
- **`sleep_source_species_ids.csv`** — provenance per (source, species, trait).
- **`species_resolution_Eagleman.csv`** — editable common→binomial map with confidence flags.
- **`standardized_term_sleep.csv`** (+ `standardized_term.R`, `standardized_term_by_reference/`) — the
  original→standardized column map, stacked per source.

## Rebuild

Canonical: run **`sleep_compiled.R`** (reads each source's public TSV from `__Public/comparative-data/`;
it warns and skips a source whose TSV isn't published yet). `standardized_term.R` restacks the term map.

> The CSV outputs here were generated by **`build_sleep_merge.py`** (a verified port), which reads each
> source's TSV if present, else the source folder's `<Item>.csv` (identical content). This let the merge
> be built before the Lyamin/Ruf-Geiser TSVs were generated. Re-running `sleep_compiled.R` in R after the
> TSVs exist reproduces the outputs identically.

## Adding a source (the "more is coming" path)

1. Build the source table to house convention in its own folder (snapshot → `.R` → `.csv`), then **add a
   row to `__ReadMe.xlsx`** (`Item name` + the derived `Item encoded`) and run the source `.R` to write
   `__Public/comparative-data/<Item encoded>.tsv`.
2. Drop `<Reference>_standardized_terms.csv` in `standardized_term_by_reference/` mapping its columns to
   existing terms or a **new** term (add it to the Scope table with a unit).
3. Add a source block to `sleep_compiled.R` (and `build_sleep_merge.py`): set `team`, select focal columns,
   and — **if it shares a trait with an existing source** — decide the combine rule (average vs
   citation-dependent → prefer primary).
4. If species are common names or non-standard, extend `species_resolution_Eagleman.csv` (or add a parallel
   resolution file) with confidence flags.
5. Re-run `standardized_term.R`, then `sleep_compiled.R`.

## Feeding the Shiny app  ✅ wired

1. **`____EvoM1_TraitTable/EvoM1_read_sleep.R`** reads `sleep_wide.csv` and writes
   `____EvoM1_TraitTable/sleep.xlsx` (each trait + a per-cell `*_Source` column; trait→source is 1:1 in
   this build).
2. **`__ShinyApp/build_data.R`** has `sleep.xlsx` in `trait_files`, so it melts into
   `__ShinyApp/data/evom1_traits_long.csv` as the seven variables (Dataset = "EvoM1 traits"). New variables
   appear in the app automatically.

Rebuild after changing the merge: `EvoM1_read_sleep.R` → `Rscript __ShinyApp/build_data.R` → commit + push
(the live app fetches `evom1_traits_long.csv` from GitHub; a local run uses the committed fallback). The
622 sleep/torpor rows are already in the committed fallback.
