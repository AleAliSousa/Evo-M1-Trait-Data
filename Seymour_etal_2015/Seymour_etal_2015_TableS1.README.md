# Seymour et al. (2015) — Table S1

Seymour RS, Angove SE, Snelling EP, Cassey P (2015). *Scaling of cerebral blood
perfusion in primates and marsupials.* J Exp Biol 218(16):2631–2640.
DOI 10.1242/jeb.124826. Item name `Seymour_etal_2015_TableS1`.

## Source → snapshot → CSV → TSV → comparison

- **Source:** `TableS1.xlsx` — the journal's supplementary spreadsheet (one table,
  "Relationship between total internal carotid blood flow rate, brain volume and
  body mass for primates and diprotodont marsupials").
- **Snapshot:** `Seymour_etal_2015_TableS1_snapshot.xlsx` (sheet `TableS1`) — a
  frozen, journal-faithful copy: caption, the section markers (Primates /
  Haplorrhini / Strepsirrhini / Diprotodontia), the per-block header + unit rows,
  all 60 species rows in printed order, and the 12 body-mass reference footnotes.
  No cleaning is done in the snapshot.
- **Reformat:** `Seymour_etal_2015_TableS1.R` reads the snapshot by position,
  carries the section markers down into `Clade`/`Suborder`, keeps the species
  rows (Family present + integer Number), strips float-representation noise from
  body mass and brain volume (`signif(x, 6)`), keeps the morphometric/flow columns
  at full precision, and writes:
  - `Seymour_etal_2015_TableS1.csv` — one row per species (60).
  - `Seymour_etal_2015_TableS1_references.csv` — body-mass reference key (1–12).
  - `10.1242%2Fjeb.124826_TableS1.tsv` in `__Public/comparative-data/` (name looked
    up from `__ReadMe.xlsx`).
- **Units:** body mass g (source already g); brain volume ml (as printed); radii cm;
  shear stress dyne cm⁻²; flow cm³ s⁻¹. Brain mass g = Vbr × 1.036 is a documented
  derivation (see definitions), not a snapshot column.

## Species names

The journal's printed binomial is the canonical `Species`. All 60 printed names were
added to `_keys/Stephan/species_key.csv` under the token **`Seymour2015`**. Three
resolve to the project's existing accepted names rather than the printed form:
`Gorilla gorilla → Gorilla sp.`, `Pongo pygmaeus → Pongo sp.`,
`Lagothrix lagotricha → Lagothrix lagothricha` (spelling). **Flag:** the genus-level
lumping of *Gorilla* and *Pongo* follows the project's prior convention — confirm it's
intended for this table.

## Comparison / QA

`comparison/Seymour_etal_2015_TableS1_compare_to_Seymour_brainbody_csv.R` audits the
snapshot against the curated `Seymour_2015_TableS1_brainbody.csv` by species, on the
shared columns (body mass g, brain/endocranial volume ml, the derived brain mass
g = Vbr × 1.036, and the body-mass reference number).

**Result: 60 matched, 0 value mismatches, no snapshot-only or csv-only rows.**

`Seymour_corticalflow.csv` (in the comparison folder) is a separate, mostly *modelled*
QICA dataset (linked to Seymour 2019) — not a copy of Table S1 — and is **not** used to
validate this table.

## Data role

`secondary`/blood-flow morphometrics (metabolic lineage) — built fully for provenance;
see `__ReadMe.xlsx` for the merge flag.
