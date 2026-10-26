# Merging brain-mass data

## Update: HrvojMihic et al. 2026 added
Added `HrvojMihic_etal_2026_SD` (601 adult great apes — gorilla, orangutan, bonobo, chimpanzee —
individual necropsy brain weight, with body weight for a 276-animal chimpanzee 15+ subset) to the
harvested source pool; it now shows as a contributor for all four species in `brain_mass_long.csv`
(`Teams` column). Classified `mass_measured` with basis `unstated` (fixation state not given in
the source) in `_keys/brain_size_basis.csv`, added via `_keys/build_brain_size_basis.py`.

While re-running the classification pipeline for this addition, two **pre-existing, unrelated**
gaps were found blocking it (both predate this session): `Ridgway__1990_Table1` (`brain_weight_kg`)
and `Jacobs_etal_2015_Table4` (`Mean Brain mass (g)`) had no basis entry in
`_keys/build_brain_size_basis.py`. Both were classified from their own definitions files/table
structure (Ridgway: a plain weighed mass, no fixation stated -> `mass_unspecified`/`unstated`;
Jacobs: a cross-species compilation table with a `Source Ref` column -> `mass_compilation_unspecified`,
same pattern as the existing Sherwood/de Sousa entries) and added so the Python builder
(`build_brain_mass_merge.py`, the tested artifact) runs clean again. The R house-twin
(`brain_mass_compiled.R`) still aborts, separately, on `Zilles_Rehkämper_1988_Table12-1` /
`Brain_weight_g` — that entry IS already present and classified (`mass_compilation_unspecified`)
in `_keys/brain_size_basis.csv`, so this looks like an R-side lookup bug (possibly a Unicode
normalization mismatch on "ä" between the harvested TSV filename and the basis-key join) rather
than a missing classification; not investigated further here, flagged for whoever maintains the R
script. **The outputs below are from the Python builder**, which completed without error.

Pipeline for compiling **whole-brain mass** across species — a sibling of the body-mass merge
(`__merging_body_ecology/`) and structured like `__merging_cerebral_metabolic_rate/`. Brain mass
is a brain measure (not organism/ecology), so it lives in its own merge rather than in
`body_ecology`.

Harvested from the **27 source tables** that record a whole-brain mass (of 29 with a brain-mass
column; 2 — MacLeod's `brainweight_known` — are non-numeric text). **Burger et al. 2019 SD1
(1,552 species)** is by far the largest contributor.

## Preventing duplication
Same three mechanisms as the body-mass merge:

1. **Same-specimen re-reporting** → collapse within a team first (team from
   `_keys/team_grouping_crosswalk.csv`; e.g. the Stephan collection's brain weights, reported
   across Stephan 1970/1981 and the Karger tables, count once).
2. **Compilation double-counting** → `role` from `_keys/variable_catalog.csv` (primary = measured
   the brain, secondary = compilation such as Burger/Lewitus); pooling is primary-preferred.
3. **Unit double-entry** → all converted to grams. Units come from the column name where present
   (`_mg`, `(g)`, `kg`, `cm3`); for **unit-less** columns the unit is inferred by magnitude —
   mammal brains are < ~10,000 g, so a column whose max exceeds 20,000 is milligrams. Crucially
   the magnitude is pooled **per (author, column) across all of an author's tables**, not per
   file: Stephan's unit-less `Brain_weight` is mg, and this is decided from the whole Stephan set
   (max ≈ 1.33 M) so a small-taxa subtable (e.g. Table I, all insectivores, max < 20,000) is not
   mislabelled grams. `1 cm³ = 1 g` is assumed where a source reported volume (Burger's convention).

No double-counting against `__merging_volumes`: this harvest reads the **source TSVs**, which are
the same primaries the volumes merge derives its `Brain_Mass.mg` from — so brain mass is compiled
once, here, with much wider coverage (1,616 vs 97 species).

## Pooling is SPLIT BY MEASUREMENT BASIS

The sources are not all reporting the same quantity, so values are only ever pooled with
values of the same **measurement basis**. The basis of every source column is recorded in
`_keys/brain_size_basis.csv` from that source's own definitions file, and the builder
**aborts** if a harvested row has no basis there. Four parallel variables are emitted; none
is pooled with another:

| `Measure` | Species | Basis |
|---|---|---|
| `Brain_Mass_measured` | 289 | a weighed brain mass. Fresh, fixed, mixed and literature-compiled masses all pool here — they are all a brain on a balance — and the `state` column in the basis key records which |
| `Brain_Mass_excl_olfactory_bulb` | 40 | weighed mass the source states **excludes the olfactory bulbs** (Herculano-Houzel 2015, Kazu 2014/2015, Avelino-de-Souza 2025) — runs ~7% below the measured stream on the 25 shared species |
| `Brain_Mass_mass_or_volume` | 1,553 | compilations that report a mass for some species and a volume converted at 1 cm³ = 1 g for others, with **no per-row flag** saying which (Burger 2019; Herculano-Houzel 2015 `brain.mass..g.or.cm3.`) |
| `Brain_size_sum_of_structures` | 11 | a whole-brain figure summed from 14 measured sub-structures **including** the olfactory bulbs (Kverková 2018) |
| `Brain_Mass_from_volume_or_ecv` | 29 | **not a weighed mass**: Weaver 2001 computes it from a measured brain volume (extant) or from an endocranial volume via Ruff et al. 1997 (fossils) |

Endocranial volume is **not** here — cranial capacity is not brain weight — and lives in
`__merging_endocranial_volume/`. The full rationale, with the quoted source definitions and
the disagreement numbers, is in `../_keys/AUDIT_brain_size_compatibility.md`.

Within a basis: `Value` = mean of primary team-values (or all team-values if no primary),
after within-team collapse; `Value_median` is the robust alternative for flagged species.

## Outputs
- **`brain_mass_long.csv`** — one row per Species × Measure: `Species, measure_class, Measure,
  Units, Value, Value_median, n_sources, n_teams, n_teams_primary, primary_used, Teams, roles,
  basis, value_min, value_max`. **1,922 cells across 1,671 species.**
- **`brain_mass_wide.csv`** — Species × one column per basis.
- **`brain_mass_unfiltered.csv`** — every harvested row with provenance plus its resolved
  `paper`, `column`, `poolable_group`, `basis` and `measure_emitted` (2,660 rows).
- **`brain_size_basis_comparison.csv`** — the review list the split makes necessary: one row per
  species with more than one basis (**224**), with the max/min ratio and a `DISAGREEMENT>2x`
  flag (**5**). Reading this is how the cross-basis comparison stays visible now that nothing
  is pooled across bases.
- **`brain_mass_dedupe_report.csv`** — within-basis cross-source disagreements (review list).
- **`brain_mass_source_columns.csv`** — chosen column + resolved unit per source (audit).

## Build
`build_brain_mass_merge.py` is the tested builder; `brain_mass_compiled.R` is the house twin.
Both were run and their five outputs compared cell by cell: **identical**. Keeping them that way
needs two things that are commented in both files — `round_n()` (base R rounds the shortest
printed decimal, Python rounds the stored double, so neither native rule can be used) and a
10-significant-digit normalisation of the mg-to-g conversion (3550 × 0.001 = 3.5500000000000003).
Re-run after any source TSV changes, and re-run `_keys/build_brain_size_basis.py` first if a
source column was added — the merge aborts on a row whose basis is not on record.

## Verified
Homo 1,333 g, Gorilla 446 g, Macaca mulatta 94 g, Microcebus murinus 1.78 g, Sorex minutus
0.11 g, Loxodonta africana ~4,900 g — all correct. Burger contributes 1,551 rows (secondary).

## Known limitations
- **8 of the 56 whole-brain-size columns have no stated basis** (`basis_evidence = unstated` in
  `_keys/brain_size_basis.csv`): Bauernfeind 2013, Brodmann 1913, Lewitus 2013/2014, Nudo 1995,
  Stimpson 2015, Young 2013, deSousa 2013. Each paper was read and each is genuinely silent
  about the tabulated mass; several describe a fixation protocol for their *histology*, which
  says nothing about a mass column compiled from the literature. They sit in `mass_measured`
  with every inclusion field `unknown`. To resolve one, update `ASSIGN` and `SOURCE_STATEMENTS`
  in `_keys/build_brain_size_basis.py` (not the CSV), then run
  `_keys/verify_source_statements.py`, which fails if a statement attributed to a paper is not
  verbatim in its PDF.
- **Lewitus et al. 2013 `Brain_weight_g` carries two rows that are ×100 the gram value**
  (*Panthera leo* 24,721; *Sus scrofa* 13,765 — both exactly 100× that group's own 2014 values).
  Primary-preferred pooling keeps them out of the shipped values for both species, so the defect
  is contained, but the column name asserts a unit its values do not honour.
- MacLeod 2000/2003 (`brainweight_known`, s0047-2484) is non-numeric text and contributes nothing
  yet; would need parsing.
- A few source rows use trinomials/subspecies (e.g. `Homo sapiens sapiens`, `Papio cynocephalus
  anubis`) that don't collapse to the binomial — add key rows if a specific species needs merging.


## Value vetoes (added 2026-10-26)

`brain_mass_value_flags.csv` drops named harvested rows before pooling. Schema as `__merging_volumes/volumes_select_value_flags.csv`
plus `n_expected`: a veto must match exactly that many rows or the build stops (a veto can neither silently do nothing nor silently drop
more). Only `action = skip` is implemented. Vetoed rows are removed from the pool and from `brain_mass_unfiltered.csv` and listed in
`brain_mass_vetoed_rows.csv`. Current vetoes (flags `fsu_unvalidated_weights`, and `extraction_error_zero` for one row): Nudo et al. 1995 Table 1 brain weight (24 rows) and the
5 DeCasien 2017 rows whose source is Glendenning 1998 (green monkey 36.54 g, rhesus 53.7, slow loris 7.88, galago 3.2, brown lemur 9.5).
Reason: absolute values of this single-animal FSU lineage are not validated and are treated as non-shrinkage-corrected (owner policy);
see `_keys/specimen_crosswalk/Green_monkey_FSU_specimen_note.md`. Implemented in both `build_brain_mass_merge.py` and
`brain_mass_compiled.R`. Note: the R twin currently stops during pooling on the present inputs (an NA `role`), independent of this change.
The `extraction_error_zero` veto drops the DeCasien 2017 *Chlorocebus aethiops* row with brain mass 0 (source Haug 1987; DeCasien marks it IGNORE). Haug 1987 Table 2 (`Haug__1987/`) prints a vervet brain volume of 64 cm3: the 0 is a blank volume carried through Boddy 2012 and DeCasien 2017. Effect: the cell's `n_sources` 7 -> 6 and `value_min` 0 -> 60; the pooled value is unchanged.
