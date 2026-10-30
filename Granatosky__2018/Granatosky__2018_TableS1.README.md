# Granatosky 2018 — Supplementary Table S1 (locomotor diversity)

Granatosky MC (2018). *A review of locomotor diversity in mammals: How and why animals move
the way they do.* Journal of Zoology. doi:10.1111/jzo.12608

Full table: **"Supplementary Table S1"** — locomotor repertoire and morphology for 174 mammal
species. Each species is scored for presence of ~45 locomotor modes (quadrupedal walking, leaping,
climbing, suspension, bounding, gliding, …), with a summary **Locomotor diversity index**, plus
**intermembral index**, **arboreal vs terrestrial** substrate use, body mass, and the original
citation for each species' locomotor data.

## What we built (summary indices)
For the EvoM1 trait table we keep the **summary indices** (the wide gait-by-gait repertoire stays in
the snapshot / public TSV for anyone who wants it):

- `Locomotor_diversity_index` — focal locomotion trait
- `Intermembral_index` — limb-proportion / locomotor morphology
- `Arboreal_terrestrial` — substrate-use category
- `Body_Mass.g` — kept for reference (already compiled elsewhere; **secondary**, not merged)

## Source → snapshot → CSV
- **Source:** the journal supplement `jzo12608-sup-0001-tables1.xlsx` (kept in this folder).
- **Snapshot:** `Granatosky__2018_TableS1_snapshot.xlsx` (sheet `TableS1_snapshot`) — a frozen,
  faithful copy of the supplement (golden rule: freeze before cleaning).
- **Reformat:** `Granatosky__2018_TableS1.R` reads the snapshot, selects the summary columns,
  harmonises species names against `_keys/Stephan/species_key.csv` (printed name preserved as
  `Species`, accepted binomial in `species_sci`), and writes:
  - `Granatosky__2018_TableS1.csv` (analysis-ready)
  - `__Public/comparative-data/10.1111%2Fjzo.12608_TableS1.tsv` (public, DOI-encoded)

## Species names
Printed names preserved verbatim in `Species`; accepted binomials added in `species_sci` via the
project key (rows added with `source_publication = Granatosky2018`). 81 of 174 species resolve to a
canonical binomial already in `_keys/species_reference.csv`; the rest are new to the project (kept as
their cleaned printed binomial).

## Data role
**Primary** for the locomotor traits (locomotor diversity index, intermembral index, substrate use).
`Body_Mass.g` is **secondary** (body mass is compiled in the volume/cell-count merges) and is not
merged from here.

## Registry (action needed)
Add one row to `__ReadMe.xlsx` → `Sheet1` (fill only the descriptive columns; the `Item name` /
`Item encoded` formulas fill themselves):

| column | value |
|---|---|
| Publication name | `Granatosky__2018` |
| 1st Author | `Granatosky` |
| year | `2018` |
| DOI (or Alt) | `10.1111/jzo.12608` |
| Item number | `Supplementary Table S1` |
| Source type | `table` |
| Team | `Granatosky` |
| Main Trait(s) | `locomotion` |
| Data role (primary/secondary/both) | `both` |

`Item encoded` will resolve to `10.1111%2Fjzo.12608_TableS1`, which matches the public TSV already
written.

## Checks
- Analysis CSV = 174 rows (one per species). No comparison script: this is a first-party
  compilation with no independent curated copy to audit against.
