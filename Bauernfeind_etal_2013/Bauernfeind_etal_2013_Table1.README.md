# Bauernfeind_etal_2013_Table1

## Source

PDF: `bauernfeind_etal_2013.pdf` (in this folder). Paper: Bauernfeind, A. L., de Sousa, A. A., Avasthi, T., Dobson, S. D., Raghanti, M. A., Lewandowski, A. H., Zilles, K., Semendeferi, K., Allman, J. M., Craig, A. D., Hof, P. R., & Sherwood, C. C. (2013), *A volumetric comparison of the insular cortex and its subregions in primates*, J Hum Evol 64(4), 263–279. https://doi.org/10.1016/j.jhevol.2012.12.003. Registry Item number **Table 1**.

**Table 1 — per-individual, shrinkage-corrected volumes of the LEFT insula and its subdivisions** (granular, dysgranular, agranular, frontoinsular FI, total) for 43 individuals across 30 primate species, with collection, section thickness, age, sex, body mass, social group size, brain mass and brain volume. (Right-hemisphere volumes are the paper's **Table 2**, not snapshotted here.)

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `bauernfeind_etal_2013.pdf` | The publication (Table 1 transcribed from the PDF; the modern article extracts cleanly). |
| `Bauernfeind_etal_2013_Table1_snapshot.xlsx` | **Snapshot** (sheet `Table1`): Table 1 reproduced to read like the printed page — caption, the unit banner `Volume estimates of left insular subdivisions (cm³)`, the column headers, the 43 individual rows (full species name on the first individual of each species, abbreviated thereafter; en-dash for missing/absent), and the three footnotes (a/b/c). **Original units kept: volumes cm³, body mass kg, brain mass g.** |
| `Bauernfeind_etal_2013_Table1.R` | Preparation → `Bauernfeind_etal_2013_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Bauernfeind_etal_2013_Table1_definitions.csv` | Data dictionary: insula subregions + brain → canonical structure + measure. |
| `comparison/Bauernfeind_2013.csv` | The formatted **species-means** table (the project's working data), audited only. |
| `comparison/Bauernfeind_etal_2013_Table1_compare_to_Bauernfeind_2013_csv.R` | Checking (QA): snapshot (aggregated to species means) ↔ `Bauernfeind_2013.csv`. |

## Preparation → `Bauernfeind_etal_2013_Table1.csv`

One row per **individual** (43): `Species_Bauernfeind2013, Individual, Collection, section_thickness_mm, age, sex, body_mass_g, social_group_size, brain_mass_mg, brain_volume_mm3, granular_L_mm3, dysgranular_L_mm3, agranular_L_mm3, FI_L_mm3, total_insula_L_mm3`. The R script reads past the 3 header rows, drops the footnotes, **carries the genus down to expand the abbreviated species names** (e.g. `H. sapiens` → `Homo sapiens`), and converts to the project units used in `Bauernfeind_2013.csv`: body **kg → g**, brain **g → mg**, all volumes **cm³ → mm³** (×1000). Because Table 1 is left-insula only, the five insula/subdivision output columns are explicitly marked with the Barger-style `_L` side tag. Also writes a DOI-named TSV (`10.1016%2Fj.jhevol.2012.12.003_Table1.tsv`) to `../__Public/comparative-data/`, or locally when the shared folder is unavailable.

## Checking → `comparison/`

`Bauernfeind_2013.csv` is at **species** level, while the snapshot is per **individual**, so the audit aggregates the snapshot to species means and reproduces the CSV's species merge before matching by species. Verified: **29 species labels matched, 0 value mismatches, no snapshot-only or csv-only species.** Columns compared: the five left-insula measures (granular, dysgranular, agranular, FI, total) + brain volume + brain mass.

- The CSV's `Pongo pygmaeus and Pongo abelii` row is reproduced as the **mean of the two Pongo species' means** (n = 4 individuals; *Pongo pygmaeus* "Sabtu" has no left hemisphere, so it contributes brain mass/volume but not insula volumes — matching the CSV exactly).
- **Body mass is not audited** here: the CSV's body weights are a harmonised external value, not the per-individual Smith & Jungers (1997) estimates printed in Table 1.

## Laterality — measured left, **undoubled by the authors**

Bauernfeind did not double anything. *"Volumes of granular, dysgranular, and agranular insular
cortices were estimated in the left hemispheres of all specimens"*; the right hemisphere is measured
separately in Table 2. So both tables are `doubling = none` in
`../__merging_volumes/laterality_known.csv`, and the `_L` / `_R` suffixes carry through to the
standardized terms so a one-side value can never be averaged against a both-sides volume.

Where a species has a left value but no right one, the ×2 is **this project's**, applied in step 7 of
the merge and recorded as `estimated_bilateral_from_unilateral`. That is a **provenance** record in
the generated `volumes_flags.csv`, not an `action = skip` veto in `volumes_select_value_flags.csv` —
the estimate is added as a new both-sides variable and never overwrites or removes the measured side.

Worth keeping distinct from the superficially similar de Sousa case: de Sousa 2010 Supp. Table 2 and
de Sousa 2013 Table 1 publish figures that are *already* 2 × left, doubled by the authors with a
stated symmetry argument (`doubling = by_source` → `published_bilateral_estimate`). Same arithmetic,
different author, and only one of the two happens inside this repo. See README__merging.md
"Hemispheres".

## Data note

The species set is primate-only (5 hominoid + Old/New-World monkeys + strepsirrhines). FI (frontoinsular cortex, defined by von Economo neurons) is present only in great apes and humans; it is en-dash (NA) in monkeys and strepsirrhines, as printed. Footnote c marks the specimen whose left hemisphere was unavailable (*Pongo pygmaeus* "Sabtu"), which contributes brain mass/volume but no insula volumes.
