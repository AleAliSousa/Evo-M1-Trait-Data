# Reader, Hager & Laland 2011 — primate behavioural flexibility (`Data`)

**Built 2026-08-05.** One registry item: `Reader_etal_2011_Data` →
`__Public/comparative-data/10.1098%2Frstb.2010.0342_Data.tsv`.

## Source

Reader, S. M., Hager, Y., & Laland, K. N. (2011). *The evolution of primate general and cultural
intelligence.* **Phil Trans R Soc B 366(1567):1017–1027.** DOI **10.1098/rstb.2010.0342**.

Antecedent: Reader, S. M., & Laland, K. N. (2002). *Social intelligence, innovation, and enhanced
brain size in primates.* PNAS 99(7):4436–4441. DOI 10.1073/pnas.062041299.

**Frozen source — digital-native, no derived snapshot** (§0a invariant 1):
`Data_ReaderHagerLalandPhilTrans2011.csv`, the Dryad download (**doi:10.5061/dryad.t0q94**), kept
verbatim with its own `README_for_Data_...txt` and the ESM PDF. Two quirks are handled on read and
**not** repaired in the frozen file: classic-Mac **CR-only line endings**, and one trailing unnamed
empty column.

**238 species rows**; 64 carry at least one 2011 report.

## Curator note — the scaffold's column list was wrong on two points

Corrected against the actual Dryad file and its README:

1. **There is no tactical-deception column.** The paper discusses tactical deception, but the
   archived data file does not carry it. The definitions row for it has been removed.
2. **Both raw and "reduced" counts ship**, plus the whole superseded 2002 block. The scaffold
   described only "raw counts and effort-corrected values". There are no pre-corrected values in
   the file at all — effort is supplied as its own column (`Zoological Record Article Count`) so
   the correction stays reproducible downstream. All three groups are carried and labelled.

Measures of record (raw 2011 counts): `Innovation`, `Tool_use`, `Extractive_foraging`,
`Social_learning`. The `*_reduced` variants removed cases that qualified for more than one category;
the paper used the reduced data for all but one analysis. **Never sum or average a raw count with
its reduced counterpart** — pick one.

## Species names

Printed names preserved in `Species_Reader2011` (and the paper's second name system in
`SpeciesPurvis`). Resolution is **paper-scoped** — only `_keys/Stephan/species_key.csv` rows with
`source_publication = Reader2011` apply, then an exact match against `_keys/species_reference.csv`
(`_keys/SPECIES_NAMING.md` §3). Four key rows added:

| Printed | Accepted | Why |
|---|---|---|
| `Lagothrix lagotricha` | `Lagothrix lagothricha` | spelling |
| `Procolobus badius` | `Piliocolobus badius` | genus update |
| `Cebus apella` | `Sapajus apella` | genus update |
| `Hylobates syndactylus` | `Symphalangus syndactylus` | genus update |

**Why the scoping matters.** An unscoped lookup across the whole key silently rewrote
`Gorilla gorilla → Gorilla sp.` and `Pongo pygmaeus → Pongo sp.` — those rows belong to the
Stephan/Düsseldorf lineage, where the specimen is only identified to genus. Reader's records are
ordinary species-level entries and must not inherit that. **Consequence for the merge:** Reader's
`Gorilla gorilla` / `Pongo pygmaeus` will not join to the volumes merge's `Gorilla sp.` /
`Pongo sp.` rows. That is a curator decision, not something this build should have made silently.

## Not done here (scope: through public TSV + registry)

`__merging_behaviour` was **not** touched. When it is:

- Reader's counts are a **different construct** from Heldstab 2016's categorical
  `Extractive_foraging` / `Tool_use` (presence / complexity). Keep them as distinct measures
  (`ExtractiveForaging_freq`, `ToolUse_freq`), never as extra sources on Heldstab's categorical rows.
- `Innovation` has no existing source — a genuinely new measure.
- Navarrete et al. 2016 descends from this same lineage; if it is ever added it is
  **citation-dependent → never averaged**. Excluded here per curator direction.
- The 2002 block is the **same lineage superseded** — resolve to the 2011 columns, never average.
- `____EvoM1_TraitTable/EvoM1_read_innovation_reader.R` still carries `TODO(curator)` markers; the
  confirmed headers are in `reference_tables/Reader_etal_2011_definitions.csv` under *Source Note*.

## Verification

- 238 rows out = 238 data rows in the frozen CSV.
- Every count column round-trips from the frozen file unchanged; blanks stay `NA` (the source
  README states "cells with no data are left blank").
- **Re-run `Reader_etal_2011_Data.R` in RStudio** to confirm it reproduces the committed CSV/TSV —
  they were written by an offline mirror of the script (no R in the authoring environment).
