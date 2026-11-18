# Baker et al. 2025 — Supplementary Data 1 (species brain & body mass)

Baker J, Barton RA, Venditti C (2025). *Macroevolutionary brain scaling is a
microevolutionary metaphenomenon.* Nature Communications 17.
doi:10.1038/s41467-025-66843-0

Supplementary Data **1** — species-level body mass and whole-brain mass for
**4,679 species** across seven animal classes, collated from the literature,
with the source of every value recorded per row (37 sources; full citations on
the file's "Reference List" sheet). The mammal subset is **1,684 species**.


> **Folder name:** this is the second Baker, Barton & Venditti paper from 2025
> added to this repo, so it sits in `Baker_etal_2025_b` (the `Smaers_etal_2011_b`
> precedent). `Baker_etal_2025` (no suffix) is the same authors' *Communications
> Biology* paper, "Human dexterity and brains evolved hand in hand"
> (doi:10.1038/s42003-025-08686-5) — a different paper and dataset.

## What we built

- **Frozen source (digital-native, no snapshot):** the journal download
  `41467_2025_66843_MOESM3_ESM.xlsx` is machine-readable and is kept
  verbatim in this folder under its original name; it is listed in the
  registry under that name (the item's "Snapshot filename" field) and
  the build script reads it directly — no snapshot was made and
  nothing was re-saved or converted.
- **Reformat:** `Baker_etal_2025_b_SupplementaryData1.R` reads only the
  frozen source file (sheet "Data S1"), keeps the mammal rows, adds `species_sci` (printed name
  with underscores replaced by spaces; printed name preserved verbatim as
  `Species_Baker2025`), and writes:
  - `Baker_etal_2025_b_SupplementaryData1.csv` (analysis-ready, 1,684 rows)
  - `__Public/comparative-data/10.1038%2Fs41467-025-66843-0_SupplementaryData1.tsv`
    (public, DOI-encoded — name is the expected Item encoded; see Registry)
- **Definitions:** `reference_tables/Baker_etal_2025_b_SupplementaryData1_definitions.csv`.
- **Reader:** the publisher XLSX was downloaded from nature.com on 2026-11-16
  by Muse (Buddy), Michael Proulx's AI assistant; every value was
  cross-checked against the frozen source programmatically (row counts, no
  duplicates, spot values). The item was rebuilt to the _skills form
  on 2026-11-18: the .R script reads only the frozen source file, runs clean
  under Rscript, and reproduces the committed CSV/TSV exactly.

## Data role

**Secondary (compilation).** Every value is compiled from an earlier
publication named in the row's `Source` column; the underlying primaries are
the merge-worthy sources. The paper's own methods: only whole-brain masses
were used (masses reported excluding the olfactory bulb were excluded);
juvenile values were excluded; where only endocranial volumes were available
they were converted to mass at **1 g = 1 cm³**. The per-row basis (weighed
mass vs volume-converted) is **not** flagged in the source; for the
brain-mass merge the column is classified in `_keys/brain_size_basis.csv`
as `mass_or_volume_mixed` (the Burger 2019 pattern) and individual rows
enter the pooled traits only through the row-basis decisions described
under Downstream use, so these values never displace a primary
measurement.

## Quality caveats

- Brain-mass values are a **mixture of weighed masses and volume-derived
  estimates** with no per-row flag (see Data role). Do not treat the column
  as uniformly measured.
- Values were rounded to 4 decimal places in the analysis CSV/TSV to strip
  binary float noise present in the publisher file (e.g. a body mass of
  58560.0000000006 g). The frozen source is unrounded.
- The paper's mammal taxonomy is as printed in 2025; a small number of
  printed names are older synonyms of the project's accepted names. No
  synonym bridges were added: add rows to `_keys/Stephan/species_key.csv`
  (source_publication = Baker2025bb) if a specific project species needs
  recovering.

## Species names

Printed `Species` (underscore binomial) preserved as `Species_Baker2025`;
`species_sci` is the same name with spaces. 1,684 mammal rows, no duplicate
species, every row carries both masses.

## Registry

Registered in `__ReadMe.xlsx` Sheet1 on 2026-11-17 (Item name
`Baker_etal_2025_b_SupplementaryData1`, Item encoded
`10.1038%2Fs41467-025-66843-0_SupplementaryData1`); the .R build looks the
code up by Item name. The frozen-source fields (the publisher filename
in "Snapshot filename", frozen date 2026-11-16 — the download date —
filetype xlsx) and the descriptive columns were completed on
2026-11-18 via `_tools/registry_apply.R`. Human visual check of
snapshot: Not applicable: tabulated and digital already.

## Downstream use

Ingested into `__merging_brain_mass` on 2026-11-17: the item's
`Brain_mass_g` column is classified in `_keys/brain_size_basis.csv` as
`mass_or_volume_mixed` (review-only as a whole), and 1,337 of its rows
were split into measured vs endocranial-volume-estimated by row-basis
decisions in `__metadata/curation/brain_mass_row_basis.csv`, keyed on
each row's named source; the merge outputs were regenerated the same
day. Also a candidate for `__merging_body_ecology` (body mass,
secondary). Worked example of the gap it fills: of the 298
`compiled_genome_data` cohort species (added 2026-11-16), 150 lacked
the combined brain-mass trait in the merge output of that date; this
dataset carries a published brain mass for **67** of them, including 7
of the 8 cohort species that have a neocortex volume but no brain mass
(*Eumetopias jubatus* 575 g; *Puma concolor* 128 g; *Mustela erminea*
4.11 g; *Mustela nivalis* 1.67 g; *Neogale vison* 7.2 g;
*Rhinopoma microphyllum* 0.387 g; *Fukomys damarensis* 1.3353 g, compiled
from Kverková et al. 2018 — itself a primary source in this repo).

## Checks

- Analysis CSV = 1,684 rows (one per mammal species; no duplicates; no
  missing body or brain mass). Counts verified against the frozen source:
  4,679 total rows (mammals 1,684; birds 1,327; bony fish 1,097; non-avian
  reptiles 278; amphibians 172; cartilaginous fish 64; insects 57).
- No independent curated copy of this table exists to audit against, so no
  comparison/ step (per HOWTO §7, its absence is not a defect here).

## Table checks

The published table prints no totals or other checkable arithmetic, so there
is no §7a relation to check. The .R build instead records two structural
checks in `table_checks` (one row per species; no missing masses) — both pass
on the frozen source as downloaded.
