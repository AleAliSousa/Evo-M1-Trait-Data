# Seymour et al. (2017) — Table S1

Seymour RS, Bosiocic V, Snelling EP (2017). *Correction to 'Fossil skulls reveal that
blood flow rate to the brain increased faster than brain volume during human evolution'.*
R Soc Open Sci 4(8):170846. DOI 10.1098/rsos.170846. Item name `Seymour_etal_2017_TableS1`.

This is the **revised** fossil-hominin data table (the Correction supersedes the 2016
original in `erred/Seymour_etal_2016/`).

## Source → snapshot → CSV → TSV

- **Source:** `rsos170846supp1.docx` — the Word supplement (one table, "Revised data",
  30 fossil-hominin specimens + footnotes + a 22-entry reference list).
- **Extract → snapshot:** `Seymour_etal_2017_TableS1_snapshot_extract.R` (pure R:
  `officer` to read the .docx paragraphs + table cells, `openxlsx` to write the sheet)
  builds the frozen `Seymour_etal_2017_TableS1_snapshot.xlsx` (sheet `TableS1`): caption,
  the 11 headers, the 30 specimen rows **with footnote superscripts kept verbatim** (e.g.
  body mass `70.0a`, age `0.05A`), then the footnote notes and the reference list. The
  snapshot is written before any cleaning, so all cleaning is reproducible from it in the
  reformat `.R`.
- **Reformat:** `Seymour_etal_2017_TableS1.R` reads the snapshot, keeps the specimen rows
  (Original/Cast = O or C), splits the footnote superscripts (`Body_mass_note` a–i,
  `Age_note` A–I), converts body mass **kg → g** (`Body_mass_g`), keeps the radii (cm),
  total ICA flow (cm³ s⁻¹) and brain volume (cm³ = ml) as printed, and writes:
  - `Seymour_etal_2017_TableS1.csv` — one row per specimen (30).
  - `10.1098%2Frsos.170846_TableS1.tsv` in `__Public/comparative-data/`.

Granularity is **per specimen** (fossil individuals), not per species.

## Species names

The abbreviated printed labels ("H. floresiensis", "A. africanus", "H. sapiens
(Bushman)", "H. erectus (soloensis)", …) are preserved verbatim in `Species`. All 13
distinct labels were added to `_keys/Stephan/species_key.csv` under token
**`Seymour2017`**, mapping each to its accepted binomial (parentheticals resolve to the
binomial, e.g. `H. sapiens (Bushman) → Homo sapiens`).

## Comparison / QA

No independent curated copy of this table exists in the project, so there is **no
comparison script** (per the guide, its absence is not a defect). The natural cross-check
is against the retracted 2016 version in `erred/` — available if a correction-vs-original
audit is wanted later.

## Data role

Fossil-hominin blood-flow morphometrics (metabolic lineage). Set the `Data role` flag in
`__ReadMe.xlsx`; fossil single-specimen estimates are typically not merged into the
comparative species means.
