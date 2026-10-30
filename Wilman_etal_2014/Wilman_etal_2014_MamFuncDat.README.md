# Wilman et al. 2014 — EltonTraits 1.0 (mammal functional data)

Wilman H, Belmaker J, Simpson J, de la Rosa C, Rivadeneira MM, Jetz W (2014).
*EltonTraits 1.0: Species-level foraging attributes of the world's birds and mammals.*
Ecology 95(7):2027. doi:10.1890/13-1917.1 (Ecological Archives E095-178)

Source table: **`MamFuncDat.txt`** — species-level foraging attributes for **5,403 mammal
species**: diet composition (10 categories, as percentages summing to ~100), foraging stratum,
diel activity, and body mass, each with a certainty/source code. `MamFuncDatSources.txt` holds the
full reference list keyed by the `Ref_*` source codes. (The companion bird table `BirdFuncDat` is
not used in this mammal-focused project.)

## What we built
Full mammal table (all 5,403 species), with the raw EltonTraits columns retained and a few
**derived summaries** added for convenience:

- `Diet_Inv … Diet_PlantO` — the 10 raw diet percentages (invertebrates, endotherm/ectotherm/fish/
  unknown vertebrates, carrion, fruit, nectar, seed, other plant)
- `Diet_dominant` — the single diet category with the highest percentage (derived, argmax)
- `Diet_breadth` — number of diet categories used (>0%), 1–10 (derived)
- `Trophic_guild` — coarse guild (derived): **Faunivore** (≥70% animal), **Herbivore** (≥70% plant),
  else **Omnivore**
- `ForStrat_stratum` — foraging stratum (derived label): Marine / Ground / Arboreal / Scansorial /
  Aerial (from the raw `ForStrat_Value` code M/G/Ar/S/A)
- `Activity_pattern` — diel pattern (derived): Nocturnal / Diurnal / Crepuscular / **Cathemeral**
  (nocturnal + diurnal), from the three raw activity flags
- `BodyMass.g` — body mass, kept **for reference only** (secondary; body mass is compiled in the
  volume/cell-count merges and is **not** merged from here)

Rows with all-zero diet (6 species, no diet data) get `NA` for the derived diet fields.

## Source → snapshot → CSV
- **Source:** `MamFuncDat.txt` and `MamFuncDatSources.txt` (kept in this folder), plus the paper PDF.
- **Snapshot:** `Wilman_etal_2014_MamFuncDat_snapshot.xlsx` (sheet `MamFuncDat_snapshot`) — a frozen,
  faithful copy of `MamFuncDat.txt` with the original 26 columns and header names (golden rule:
  freeze before cleaning).
- **Reformat:** `Wilman_etal_2014_MamFuncDat.R` reads the snapshot, harmonises species against
  `_keys/Stephan/species_key.csv` (printed name preserved as `Species`, accepted binomial in
  `species_sci`), derives the summary fields above, and writes:
  - `Wilman_etal_2014_MamFuncDat.csv` (analysis-ready, all 5,403 species)
  - `__Public/comparative-data/10.1890%2F13-1917.1_MamFuncDat.tsv` (public, DOI-encoded)
- **Definitions:** `reference_tables/Wilman_etal_2014_MamFuncDat_definitions.csv`.

## Species names
Printed names preserved verbatim in `Species`; accepted binomials in `species_sci` via the project
key. 13 verified junior/senior synonyms were bridged to lift overlap with the brain dataset
(rows added to `species_key.csv` with `source_publication = Wilman2014`):

| project accepted | Wilman printed |
|---|---|
| Equus burchelli | Equus quagga / Equus burchellii |
| Mustela vison | Neovison vison |
| Myoxus glis | Glis glis |
| Galagoides demidoff | Galago demidoff |
| Notamacropus parma | Macropus parma |
| Notamacropus rufogriseus | Macropus rufogriseus |
| Mops pumilus | Chaerephon pumilus |
| Macronycteris commersoni | Hipposideros commersoni |
| Fukomys anselli / damarensis / darlingi / mechowii | Cryptomys anselli / damarensis / darlingi / mechowi |
| Galictis vittatus | Galictis vittata |

Not bridged: subspecies-level project names (e.g. *Canis lupus familiaris*, *Mustela putorius furo*,
*Cryptomys hottentotus* subspecies), `sp.` placeholders, and the ambiguous *Marmosa mitis* /
*Marmosa robinsoni* pair — left unmatched on purpose to avoid pooling distinct taxon concepts.

## How it's used (EvoM1 trait table)
`____EvoM1_TraitTable/EvoM1_read_diet.R` reads the public TSV, **subsets to the project's accepted
species** (196 of the 215 in `_keys/species_reference.csv` have EltonTraits data), keeps the focal
diet / foraging-stratum / activity traits (body mass dropped), and writes `diet_foraging.xlsx`.
`__ShinyApp/build_data.R` melts that file into `evom1_traits_long.csv` under the source label
**"Wilman et al. 2014 (EltonTraits diet & foraging)"**, so the traits are searchable and correlatable
in the app.

## Data role
**Primary** for diet, foraging stratum, and activity pattern. `BodyMass.g` is **secondary**
(compiled elsewhere) and is retained in the full CSV/TSV but not carried into the trait table.

## Registry (action needed)
Add one row to `__ReadMe.xlsx` → `Sheet1` (fill only the descriptive columns; the `Item name` /
`Item encoded` formulas fill themselves). `__ReadMe.xlsx` can't be edited programmatically here
(embedded drawings break openpyxl, and a resave would strip cached formula values), so edit it in Excel:

| column | value |
|---|---|
| Publication name | `Wilman_etal_2014` |
| 1st Author | `Wilman` |
| year | `2014` |
| DOI (or Alt) | `10.1890/13-1917.1` |
| Item number | `MamFuncDat` |
| Source type | `table` |
| Team | `Wilman` |
| Main Trait(s) | `diet; foraging stratum; activity` |
| Data role (primary/secondary/both) | `both` |

`Item encoded` will resolve to `10.1890%2F13-1917.1_MamFuncDat`, which matches the public TSV already
written (the scripts use this as a fallback until the row exists).

## Checks
- Analysis CSV = 5,403 rows (one per mammal species). Diet percentages sum to 100 for all but the
  6 all-zero (no-data) rows. No comparison script: first-party published database, no independent
  curated copy to audit against.
