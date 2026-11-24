# Merging cell-counts data

Pipeline for compiling the comparative brain cell-count dataset.

## Steps

1. **Standardized term list** — `standardized_term.R`
   - Input: one term file per table in `standardized_term_by_reference/`
     (`<Reference>_standardized_terms.csv`, columns `Original_Term, Reference, Standardized_Term`).
   - Output: `standardized_term_cell_counts_isotropic_fractionator.csv` (all per-reference files stacked).

2. **Compile cell counts** — `cell_counts_isotropic_fractionator_compiled.R`
   - Merges, filters, and calculates variables across datasets.
   - Inputs: `__Public/comparative-data/*.tsv`, `__ReadMe.xlsx`, `standardized_term_cell_counts_isotropic_fractionator.csv`.
   - Label definitions (hand-written, read by `_keys/build_variable_definitions.R`, not by the
     merge): `cell_counts_isotropic_fractionator_label_definitions.csv` — one row per label whose
     meaning the label alone does not carry (today the 205 per-area and one-hemisphere labels).
     A label served from several sources has ONE row, which names each source.
   - Hemisphere register (hand-written, read by the merge): `laterality_known.csv` — the columns
     that were measured on one side — and `laterality_known_exceptions.csv` — species of an
     author-doubled column that were measured on both sides. See **Hemispheres** below.
   - Outputs: `cell_counts_isotropic_fractionator_long.csv`, `cell_counts_isotropic_fractionator_wide.csv`,
     `cell_counts_isotropic_fractionator_flags.csv` (which served values are both-hemisphere estimates).
   - Checks: `cell_counts_isotropic_fractionator_unfiltered.csv`; `cell_counts_isotropic_fractionator_conflictcheck.R`.
   - Species names: `cell_counts_isotropic_fractionator_source_species_ids.csv`.
   - Flagged datasets: `*_metadata_flags.csv`.

3. **Imputations** — `cell_counts_isotropic_fractionator_imputations_diagnostic.R` → `imp30x10.RData`.

## Adding a paper

1. Create `standardized_term_by_reference/<Reference>_standardized_terms.csv` (its terms → standardized terms).
2. Register it in `__ReadMe.xlsx` (Item name → Item encoded) and add it to the `item_name` vector in `cell_counts_isotropic_fractionator_compiled.R`.
3. Put its DOI-coded table in `__Public/comparative-data/<Item encoded>.tsv`.
4. Re-run `standardized_term.R`, then `cell_counts_isotropic_fractionator_compiled.R`.

Most recent additions: `HerculanoHouzel_etal_2013_Table1-a` (mouse, 18 cortical areas),
`Young_etal_2013_a_Table1` (M1 of five primates) and `Collins_etal_2016_Table1` (one chimpanzee),
2026-11-24 — see **Queued per-area sources wired**; before them `Seelke_etal_2014_Table3`,
`_Table4`, `_Table5` (*Monodelphis domestica*; 2026-11-23), the first per-area items.

## Hemispheres (the merge's rule, 2026-11-23)

Owner, 2026-11-23: *"serve both hemisphere in the comparison but make it clear it is doubled; and
also offer single. There are many cases where a hemisphere is doubled, we should just always do it
the same way unless there is a specific note that it is a different kind of value."* It is the
convention `__merging_volumes` already uses, with the same file format, flags and wording.

- **A weight, volume or number of cells measured in one hemisphere is served twice.**
  `<Structure>_<code>` is the both-hemisphere estimate, 2 × the printed value, doubled by this
  merge (step 3.5). `<Structure>_unilateral_<code>` is the printed value, one hemisphere, as
  measured (`_left_` / `_right_` where the source states the side: Collins et al. 2016, right;
  Collins et al. 2010, right or left **by case** — see **Step 7b** below).
- **Densities, percentages and ratios are never doubled**: they are the same for one hemisphere as
  for both. They have one plain label; its definition says the measurement was made in one
  hemisphere. Values the merge derives (`_O.p.N`, step 3.7; ratios and densities, step 9.1) are
  computed on the plain labels only, so no `_unilateral_` ratio or density is created, and a
  ratio is the same whichever basis it is computed on.
- **The register** is `laterality_known.csv`, in the format of `__merging_volumes/laterality_known.csv`
  (`Reference, Original_Term, side, doubling, required_suffix, note`), one row per one-side column:
  - `doubling = none` — the table prints one side, undoubled. The column's standardized term must
    carry the suffix immediately before the code; the merge builds the 2× partner and marks it
    `estimated_bilateral_from_unilateral`.
  - `doubling = by_source` — the table prints a value its authors already doubled. The term must
    not carry a suffix; the value is used as published, **never doubled again**, and marked
    `published_bilateral_estimate`.
  The merge **stops** (section 2 guard) if a registered column is unmapped, is not a weight, volume
  or count, is suffixed when it must not be or unsuffixed when it must be, or if any live term
  carries a laterality suffix without being registered. Doubling is fill-only: it never replaces a
  value the same table already has under the plain label.
- **The marks** are in `cell_counts_isotropic_fractionator_flags.csv` (`Species, Variable, flag,
  detail`; written by step 9.3 on every run; `Species` and `Variable` exactly as in
  `cell_counts_isotropic_fractionator_long.csv`). A row is written only where the estimate is the
  value actually served. Step 9.3 stops if a flagged value is not exactly 2 × its `_unilateral_`
  partner. A value *derived from* an estimate (the raccoon's `Hippocampus_O.p.mg`) is not flagged.
- **One cell-level case, not in the register:** Jardim-Messeder et al. 2017 Table 1 prints both-
  hemisphere hippocampus masses for seven species and a one-hemisphere mass for *Procyon lotor*
  (Corrections, 2026-09). That is one cell of a column, so it stays in step 3.4c — which now treats
  it the same way: `Hippocampus_Mass.g` = 0.954 (unchanged, now flagged) and
  `Hippocampus_unilateral_Mass.g` = 0.477 as printed, for the raccoon only.
- **Unless a note says it is a different kind of value.** A value that is not "one hemisphere of a
  bilateral structure" (a sample, a piece, one animal's side chosen for a reason) is not registered
  and not doubled; say so in the item's `source_methods.csv` row and its label definition.
- **Species exceptions to an author-doubled column** are in `laterality_known_exceptions.csv`
  (`Reference, Species, basis, note`; the only basis is `both_sides_measured`). A register row is
  a whole column; a species listed here was measured on both sides and gets no flag. One case:
  Herculano-Houzel et al. 2020 (bats). Methods 2.1: for every species except *Chaerephon pumilus*
  only one hemisphere was available and "data are necessarily expressed as twice the numbers
  obtained for the available hemisphere"; Table 1 marks each species "(1H each)" or "(2H each)".
  The four neuron-number columns of its Tables 1 and 2 and the brain mass of Table 1 (`MBRAIN`)
  are registered `by_source`; step 3.4o stops the merge unless the exception list equals the
  "(2H each)" species of Table 1. No value changed: 60 values are marked
  `published_bilateral_estimate` (12 species × four neuron numbers and the brain mass).
  The paper does not say in words whether `MBRAIN` is a brain weighed whole or the sum of the
  dissected structures. Its own tables decide it
  (`HerculanoHouzel_etal_2020/internal_checks/HerculanoHouzel_etal_2020_TABLE3_internal_check.csv`):
  `MBRAIN` equals the sum of the structure masses implied by Table 2 (neurons ÷ neurons per mg)
  within rounding for 5 species and within 1.41 % for all 13, and the species measured on both
  hemispheres differs from that sum as much (−1.38 %) as the one-hemisphere species do. So
  `MBRAIN` is the sum of the dissected structures, on the same basis as the neuron numbers.
  Limits: for 8 species the agreement is close, not exact (the table prints means over two
  animals); that the structure data are 2 × one hemisphere is the paper's statement, not
  something the tables show. The bats' `CerebralCortex_`, `Cerebellum_` and `RoB_Mass.g` are
  computed by this merge from the doubled neuron numbers and the densities and are not flagged
  (a value derived from an estimate is not flagged).
- Today (2026-11-24, after step 7b): 144 registered columns (139 `none`, 5 `by_source`), 2 exception
  rows, 206 flagged values — 146 `estimated_bilateral_from_unilateral` (54 mouse, 30 owl monkey,
  30 galago, 16 opossum, 9 chimpanzee, 4 baboon, 1 pig-tailed macaque, 1 squirrel monkey, 1 raccoon)
  and 60 `published_bilateral_estimate` (bats).

## Per-area items and the Krubitzer team (2026-11-23)

Seelke, Dooley & Krubitzer 2014 measured one species, *Monodelphis domestica*, by isotropic
fractionation: the neocortex of one hemisphere kept intact, and V1, S1, A1 and the remaining
cortex dissected from the other. The owner's decisions of 2026-11-23 on how these enter the merge
are recorded in `WIRING_into_cell_counts_isotropic_fractionator.md`. What the script does:

- **Structures** (step 1.7). The three public TSVs are long by area; each becomes one row.
  "Whole neocortex" is served as `Neocortex_`, and `V1_`, `S1_`, `A1_` as their own regions.
  The "Σ neocortex" and "Rem Ctx" rows and Table 3's "% of Σ neocortex" are not served: each has a
  registered status and reason in `not_served.csv` (**What is not served, and why**, below); they
  stay in the public TSVs. Guard: the six printed areas, one species, n = 5.
- **Units** (step 3.4n). `_C.n`, `_N.n`, `_O.n` = printed millions × 10⁶. `_C.p.mg`, `_N.p.mg`,
  `_O.p.mg` = printed millions per gram × 10⁶ ÷ 1000. `_Mass.g` and `_p.C.N` are as printed.
  `_C.p.mg` (cells per mg) is a new code; it is not in the step 3.7 derivations, so no other
  species gains a value. Guard: the columns must still be in the printed units.
- **Hemisphere** (register + step 3.5; rule in **Hemispheres** above). Every weight and count in
  these tables is one hemisphere. The 16 of them (4 structures × `Mass.g`, `C.n`, `N.n`, `O.n`)
  are served twice: `Neocortex_Mass.g` = 0.146 g is 2 × the printed 0.073 g, flagged as an
  estimate; `Neocortex_unilateral_Mass.g` = 0.073 g is the printed value. The 20 densities,
  percentages and ratios are served once and never doubled. The paper's own both-hemisphere
  figures (Discussion: 0.15 g, about 6 million cells) are rounded text values and are not served.
- **Derived** (step 3.7, the merge's standing rule). `_O.p.N` = `_O.n` ÷ `_N.n` inside Table 4.
  It is a ratio of the group means (the same from the printed or the doubled numbers) and is not
  printed in the paper; the printed `_p.C.N` is kept as printed, and the two need not agree (whole
  neocortex: 25.6% neurons printed; 0.80 / (0.80 + 2.22) = 26.5% from the two printed counts).
- **Dispersion.** Group means of 5 animals. The printed ± is not labelled in the tables (figure
  captions: SEM); it is carried as `_pm`, converted with its mean, annexed in step 6 with `_SD`
  and `_n`, and kept in the unfiltered table. It belongs to the measured value
  (`<Structure>_unilateral_<code>_pm`); the 2× estimate has none. It is not presented as SD.
- **Team** (steps 7, 8.1–8.3.S, 9.2). The Seelke items are removed from the "not Kverkova" block,
  so the Herculano-Houzel worth order, pins and demotions are untouched, and are resolved as a
  team of their own (`Krubitzer`). Step 9.2 stops the merge if this team and another ever give
  the same species × variable: nothing here can change, or be averaged with, a served value.
- **Not joined to the weights merge.** `Neocortex_Mass.g` is not joined to the `Neocortex_Mass (g)`
  of `__merging_weights` (no `_keys/variable_canonical.csv` row). Open item: it is now a
  both-hemisphere estimate, so the join is possible, but the estimate flag would have to follow
  the value into the joined label first; and the tissue was weighed after perfusion fixation.
- **Effect** (against a run of the previous script on the same inputs, same machine).
  `cell_counts_isotropic_fractionator_long` 3,994 → 4,047 rows, 86 → 87 species, 208 → 261
  variables: 53 new rows — 52 *Monodelphis domestica* (16 estimates, 16 as measured, 20 densities,
  percentages and ratios) and the raccoon's `Hippocampus_unilateral_Mass.g`; every other row
  identical. `_unfiltered` +101 rows (93 from the three items, appended; 8 for the new
  Jardim-Messeder column, 7 of them empty). `_wide` +1 row, +53 columns. `_species_resolution`
  +3 rows. `_flags` is new: 17 rows. No existing value, source or row order changed.
  `__compiled/compiled_long.csv.gz` (the table the apps read): +53 rows under `Cell counts`, each
  classified (`cellular_composition` 44, `structure_mass` 9).

## Queued per-area sources wired (2026-11-24)

The owner's per-area decision of 2026-11-23 also covers the queued Herculano-Houzel 2013 and
Kaas-lab sources. Three were wired on 2026-11-24; the owner's answers of the same day to what
each still needed, and Collins et al. 2010, are in **Step 7b** below. The three entries here
describe the tables as they are served now.

- **Herculano-Houzel, Watson & Paxinos 2013, Table 1-a** (step 1.8; Herculano-Houzel team). Mouse,
  4 animals, 18 cortical areas, grey matter, numbers "per functional area in one cortical
  hemisphere", corrected for sectioning losses. Each area is a structure: `V1`, `S2`, `Insula`
  and `EntorhinalCortex` use labels the database already has; the other 14 use the paper's own
  names (`Infralimbic`, `Cingulate`, `Retrosplenial`, `Parietal`, `Motor`, `Frontal`, `V2M`, `V2L`,
  `S1limb`, `S1face`, `Auditory`, `Orbital`, `Ectorhinal`, `Piriform`). `Motor` is M1 + M2, not
  `M1`; `Auditory` is not `A1`; `Frontal` and `Parietal` are groups of mouse atlas areas, not
  lobes. The paper writes "S1-limb" and "S1-face": the hyphen is dropped because the script turns
  a hyphen in a label into a dot. Served per area: neurons and other cells (`_N.n`, `_O.n`), their
  sum (`_C.n`, not printed), each as the 2 × estimate and as `_unilateral_`; derived `_O.p.N` and
  `_p.C.N` (step 3.7). The printed SEM is kept as `_SEM` (annexed, step 6). Neurons per mm² and per
  mm³ are served as printed (`_N.p.mm2`, `_N.p.mm3`); **their denominators are the surface area and
  the volume of each area in the Franklin & Paxinos (2007) atlas, not measurements of these mice**.
  Not served (`not_served.csv`): thickness and the three % columns. Table 1-b (7 functional groups;
  sums of Table 1-a) and Figure2TopLeft (the Table 1-a means again) are not listed. The owner
  confirmed the area names on 2026-11-24, and that S1-limb and S1-face are samples of S1: no
  whole-S1 value is built for the mouse.
- **Young, Collins & Kaas 2013, Table 1** (step 1.9; units step 3.4p; team Kaas). M1 of one
  hemisphere per brain. Served for six species: `M1_Mass.g` (2 × estimate) and
  `M1_unilateral_Mass.g`, `M1_C.p.mg`, `M1_N.p.mg`, `M1_p.C.N`, and (not printed for *Macaca
  nemestrina*) `M1_C.p.mm2`, `M1_N.p.mm2`; SD and n annexed. **The two baboon cases** (09-27 and
  11-31) are one row, their mean (**Step 7b**). Not served (`not_served.csv`): M1 area (it belongs
  to `__merging_cortical_areas`), the three other % columns, the descriptive columns.
- **Collins et al. 2016** (step 1.10; units step 3.4p; team Kaas). One chimpanzee, right
  hemisphere. Served: the flattened neocortex as `Neocortex`, `V1`, `V2`, `M1`: `_C.n`, `_N.n` (2 ×
  estimate) and `_right_C.n`, `_right_N.n`; `_p.C.N`; `_C.p.mg`, `_N.p.mg`; `_C.p.mm2`, `_N.p.mm2`
  (printed per cm²) for V1, V2, M1. Values are the rounded numbers of the Results text. **M1** is
  the same chimpanzee as Young's M1 row: the measures both tables give are counted once, served
  from Young, and the cell and neuron numbers, which only this table gives, are served (**Step
  7b**). Not served (`not_served.csv`): the somatosensory, premotor and prefrontal dissection
  blocks, the left-hemisphere V1 volume, surface area, brain and body mass.
- **Team Kaas** (steps 7, 8.1–8.3.Y, 9.1, 9.2): Young 2013, Collins 2016 and Collins 2010, on the
  Krubitzer pattern. Animals these tables share are handled by the specimen rule (step 6b). What
  that rule does not explain still stops the merge: two Kaas-lab tables giving the same species ×
  variable (step 8.Y), or this team and any other (step 9.2).
- **Effect** (against the previous script on the same inputs, same machine).
  `cell_counts_isotropic_fractionator_long` 4,047 → 4,235 rows, 87 → 89 species (*Pan
  troglodytes*, *Aotus nancymaae* are new to this merge), 261 → 413 variables: 188 new rows
  (mouse 144, chimpanzee 24, four other primates 5 each); every other row identical.
  `_unfiltered` +265 rows. `_wide` +2 rows, +152 columns. `_species_resolution` +7 rows.
  `_flags` 17 → 130 rows. No existing value, source or row order changed.
  `__compiled/compiled_long.csv.gz`: +188 rows under `Cell counts`, each classified
  (`cellular_composition` 178, `structure_mass` 10).

## Step 7b (2026-11-24): new density codes, the baboons, the same data counted once, Collins et al. 2010

Owner decisions of 2026-11-24 (reviews `RV-2026-017` to `RV-2026-021` in
`_keys/cell_count_methods/expert_reviews.csv`).

### New measure codes

`C.p.mm2`, `N.p.mm2` — cells, neurons under 1 mm² of cortical surface — and `N.p.mm3` — neurons per
mm³ of cortical grey matter (`_keys/glossary.csv`). Densities: never doubled. Served only where a
table prints them:

| Table | Printed as | Served as |
|---|---|---|
| Young et al. 2013 Table 1 | millions per mm² | `M1_C.p.mm2`, `M1_N.p.mm2` (× 10⁶) |
| Collins et al. 2016 | per cm² | `V1_`, `V2_`, `M1_` × `C.p.mm2`, `N.p.mm2` (÷ 100) |
| Collins et al. 2010 Dataset S1 | per mm² | nine areas × `C.p.mm2`, `N.p.mm2` |
| Herculano-Houzel et al. 2013 Table 1-a | N/mm², N/mm³ | 18 areas × `N.p.mm2`, `N.p.mm3` |

For the mouse table the numerator is the measured neuron number and **the denominators are the
surface area and volume of each area reconstructed from the Franklin & Paxinos (2007) atlas, not
measurements of the animals** (the paper: "we made no attempt to measure their individual surface
areas and volumes"). Each mouse definition says so. In the Kaas-lab tables the surface area was
measured on the flattened cortex of the same animal.

### The two baboons of Young et al. 2013 (step 1.9)

Table 1 prints one row per baboon: "Papio cynocephalus anubis" (case 09-27) and "Papio hamadryas
anubis" (case 11-31). Owner: *"if [they] are the same species we can average them for the
merging"*. Both names are NCBI taxon 9555 (*Papio anubis*) in the repository's keys; step 1.9
checks this with the shared resolver and stops if it ever fails. The two rows are served as **one
row: for each M1 measure, the unweighted mean of the two cases**, n = 2 hemispheres, no SD (none
is printed for a single case). The row carries the name printed for case 09-27, the name Collins
et al. 2010 uses for the same animal. SampleInfo and the source details say "mean of two cases
(09-27, 11-31)". Both cases are neurologically normal.

### The same data are counted once (the specimen rule; steps 4.3b and 6b)

Owner: *"We should register, and just indicate they are the same data when it is registered, so
that it never double counts. Like a code for different data points which are actually the same
data."*

- **The code is the repository's specimen identifier**: `canonical_specimen` in
  `_keys/specimen_crosswalk/specimen_crosswalk.csv` (`KAAS-PAN-11_38`, `KAAS-AOTUS-07-78`,
  `KAAS-OTO-08-07`, `KAAS-PAPIO-09-27`, `KAAS-PAPIO-11-31`).
- **`specimen_key.csv`** (this folder) points at those identifiers, one row per table × species row
  × animal: `Reference, Species` (the table's own name), `canonical_specimen`,
  `crosswalk_item_reference` (the crosswalk's name for the table), `relation` (`is` = the row is
  that animal; `mean_includes` = the row is a mean over animals that include it), `serve_rank`,
  `note`. It copies nothing from the crosswalk: the strength of each link (`matched`, `probable`)
  is read from the crosswalk at run time. The merge stops if a key row points at an identifier the
  crosswalk does not have for that table.
- **The rule.** Rows of two tables that share an identifier and give the same measure of the same
  structure are the same data. The value is served once, from the table with the lower
  `serve_rank`; the other table's value is taken out before any team step and written, with both
  values, both tables, the identifier and both link strengths, to
  `cell_counts_isotropic_fractionator_same_data.csv`. The served row names both tables in its
  source details. Labels are compared without their hemisphere suffix (`M1_left_Mass.g` is the same
  measure as `M1_unilateral_Mass.g`). **A measure only one table gives is served.** A `probable`
  link counts as the same animal; its strength stays on record. A mean that includes the animal
  (Young's three galagos) is served whole and never taken apart.
- **Where the code is visible.** Each keyed table has a `Specimen` variable in
  `cell_counts_isotropic_fractionator_unfiltered.csv` ("KAAS-PAN-11_38 (link: matched)", "mean
  includes KAAS-OTO-08-07 (link: probable)").
- **Which table serves.** Young et al. 2013, the M1 paper, serves the M1 measures it prints
  (`serve_rank` 1), as the owner decided for `__merging_cortical_areas` on 2026-08-25; the Collins
  tables serve the M1 cell and neuron numbers, which Young does not print.
- **Today: 19 values are registered as the same data.** Chimpanzee M1 (5: `p.C.N`, `C.p.mg`,
  `N.p.mg`, `C.p.mm2`, `N.p.mm2` of Collins et al. 2016); owl monkey M1 (7) and galago M1 (7) of
  Collins et al. 2010 (the five densities and percentages, the M1 weight and its 2 × estimate).
  Served next to Young's M1 mass and densities: `M1_C.n`, `M1_N.n` and their one-side values from
  Collins et al. 2016 (chimpanzee) and Collins et al. 2010 (owl monkey; galago, case 08-07 alone).
  The two papers' M1 pieces differ in extent, so number ÷ mass does not reproduce the served
  density; the definitions of `M1_C.n` and `M1_N.n` say so.
- **What still stops the merge.** An overlap that no shared identifier explains: two Kaas-lab
  tables giving the same species × variable (step 8.Y), or team Kaas or Krubitzer and another team
  (step 9.2). An animal shared with a table of another team is handled by the rule, which runs
  before the teams and is not limited to one team; a value taken out as the same data is not
  rebuilt by step 9.1 from the table it was taken out of.

### Collins et al. 2010 Dataset S1 (step 1.11; team Kaas)

244 tissue pieces of one flattened cortical hemisphere from five animals; the supplement prints
no totals.

- **Per area**, for the two cases dissected into named areas — galago 08-07 (right) and owl monkey
  07-78 (left): `V1`, `V2`, `S1`, `M1`, `A1`, `MT`, `DL` (labels the database already has) and
  `dV3`, `vV3` (the supplement's names; new). Per area: `Mass.g`, `C.n`, `N.n` (one hemisphere →
  hemisphere rule), `p.C.N`, `C.p.mg`, `N.p.mg`, `C.p.mm2`, `N.p.mm2`.
- **Whole neocortex per case = the sum of the supplement's pieces** (`Neocortex_` × `Mass.g`,
  `C.n`, `N.n`; `N.p.mg` and `p.C.N` derived from the sums by step 3.7). The sum is made by this
  project. It is served only where it agrees within 1 % with every whole-hemisphere figure in the
  paper's text (`Collins_etal_2010_text_totals.csv`): galago 08-07, owl monkey 07-78, baboon 09-27.
  For macaque 08-59 and galago 07-104 the two disagree: both figures are registered
  (`cell_counts_isotropic_fractionator_sums_vs_text.csv`, written on every run) and no total is
  served. The paper calls the structure "cortex" and does not say whether any allocortex was
  removed; the label `Neocortex` follows Collins et al. 2016.
- **One row per species.** Cases of one species that give the same measure are averaged. Today
  galago 07-104 serves nothing, so the *Otolemur garnettii* row is case 08-07 alone. Two cases
  measured on different sides stop the merge (no label for such a mean has been decided).
- **Side per case.** The weight and number columns are built per side by step 1.11 ("V1 total_cells
  (right hemisphere)", "… (left hemisphere)"), so one printed column is a right hemisphere for one
  case and a left for another, and `laterality_known.csv` keeps one row per column with one side.
  The side is the case's own (`hemisphere` in the item's table); for baboon 09-27, which the
  supplement gives no side for, it is in `laterality_case_side.csv` with its evidence (right:
  Fig. 3 legend; Young et al. 2013b Table S1).
- **Shared animals.** Owl monkey 07-78 is Young's owl monkey; galago 08-07 is one of Young's three
  galagos; baboon 09-27 is one of the two baboon cases. The M1 measures both tables give are
  served from Young (for the galago, the three-animal mean, as
  `_keys/specimen_crosswalk/Kaas_Young_Collins_specimen_overlap_note.md` says: keep the pooled
  row, do not subtract or reconstruct). The baboon's M1 (Young) and neocortex (Collins) are
  different measures: both served.

### What is not served, and why (`not_served.csv`)

Nothing is "held". Every row and column of a per-area table wired since 2026-11-23 that does not
reach the merge is registered in `not_served.csv` (`Reference, kind, name, status, same_as,
reason`). Steps 1.7–1.11 check the register against what they actually leave out and stop on any
difference. The statuses:

| Status | Meaning |
|---|---|
| `same_data` | repeats data registered elsewhere; `same_as` names what it repeats. (Values found to be the same data by the specimen rule are not listed by hand: they are in `cell_counts_isotropic_fractionator_same_data.csv`.) |
| `derived_from_registered` | computable from served values: a sum, share or ratio of them |
| `second_measurement` | another measurement of a quantity already served from the same source and animals (Seelke's "Σ neocortex") |
| `no_measure_code` | the merge has no code for the quantity |
| `not_a_database_structure` | a dissection block, remainder or grid piece, not a structure |
| `other_merge` | the quantity belongs to another merge, named in `same_as` |
| `excluded` | excluded by a decision; the reason says whose and why |
| `disagrees_with_text` | two figures for the same quantity disagree; both are registered, none is served until the owner says which to trust |
| `descriptive` | a text or identifier column, not a measurement |

Whole tables that are not in the item list keep their row in
`_keys/cell_count_methods/source_methods.csv`; the reason there starts with the same status word
(`derived_from_registered` for Herculano-Houzel 2013 Table 1-b, `same_data` for its
Figure2TopLeft, `excluded` for Young et al. 2013b, the epileptic-baboon study).

### Source details

`cell_counts_isotropic_fractionator_long.csv` has a new last column, `Source_detail`: empty except
where a note belongs to the served value — "mean of two cases (09-27, 11-31)", "same data also in
…: counted once", "only this table gives this measure; its animal … ", "from the sum of the N
tissue pieces of case …". The compiled table reads it into `Source_details`.

### Files added by this step

Authored: `not_served.csv`, `specimen_key.csv`, `laterality_case_side.csv`,
`Collins_etal_2010_text_totals.csv`,
`standardized_term_by_reference/Collins_etal_2010_DatasetS1_standardized_terms.csv`. Written on
every run: `cell_counts_isotropic_fractionator_same_data.csv`,
`cell_counts_isotropic_fractionator_sums_vs_text.csv`.

### Effect

Against the previous script on the same inputs, same machine.
`cell_counts_isotropic_fractionator_long` 4,235 → 4,502 rows, 89 → 90 species (*Papio
cynocephalus anubis* is new), 413 → 545 variables: 267 new rows (Collins 2010 208, mouse 36,
Young 15, Collins 2016 8). No existing value or source changed and the row order is the same. 13
existing rows gained a source detail (the M1 rows of chimpanzee, owl monkey and galago); the
`species_printed` and `species_basis` columns of the 67 existing *Aotus nancymaae* and *Otolemur
garnettii* rows now also list the spelling Collins et al. 2010 prints. `_unfiltered` +515 rows.
`_wide` +1 row, +132 columns. `_species_resolution` +4 rows. `_flags` 142 → 206.
`__compiled/compiled_long.csv.gz`: +267 rows under `Cell counts`, each classified
(`cellular_composition` 227, `structure_mass` 40).

## Corrections

- **2026-11 — Dos Santos et al. 2020: the published Table 1 is the source again (steps 1, 3.4e, 8.2.H).**
  `DosSantos_etal_2020_Table1` replaces `DosSantos_etal_2020_unpublished` in `item_name`. The
  unpublished item, its standardized-terms file and its public TSV are gone; no output of this merge
  names it any more.
  - **Ten printed cells are corrected, step 3.4e.** Table 1 prints a few wrong values, some
    impossible (*Tragelaphus strepsiceros* whole-brain cells below its own neuron count, *Procavia
    capensis* cerebellar neurons above its total cells). They were found by checking the paper
    against itself — its arithmetic, its Table 5 and its Figure 5 — in
    `DosSantos_etal_2020/internal_checks/` (33 major or impossible failures as printed, 12 with the
    ten values applied, all twelve documented non-errors). Each correction is one row of
    `DosSantos_etal_2020/reference_tables/DosSantos_etal_2020_errata.csv` (E001–E010) and is guarded:
    the merge stops unless the printed value is the expected one and the errata file still proposes
    the value applied. Corrected values follow the curator's order of preference: a published table,
    then calculation from published numbers, then the authors' unpublished table (named as the
    source), then a figure. Eight values come from the first two. Two — cortex total cells of
    *Cebus apella* and *Papio anubis cynocephalus* (E007, E008) — come from the authors' unpublished
    workbook, because no published table carries those samples and the published numbers do not fix
    them exactly; the Figure 5 readings agree within 0.4%. The unpublished data agrees with the
    other eight within 0.7% (private check). The item CSV, snapshot and TSV stay verbatim.
  - **Re-reported measures rank below the primaries, step 8.2.H.** Table 1's footnote says its
    structure mass, C, N and N/mg are values published previously. Under the compilation rule (as
    for the HH2011 pin) those rows — and `_p.C.N` derived from them — are demoted below every other
    Herculano-Houzel-team source. Table 1 fills them only where no primary table has the cell. Its
    microglia measures keep their date priority: `_I.p.mg` and `_I.p.N` (measured), `_I.n` (printed,
    = I/N × N) and `_I.p.C` (derived in 3.7 from Table 1's own I and C).
    Why it matters: of the 433 such cells Table 1 shares with a primary table, 375 agree within
    0.1% but 33 differ by more than 2% (23 by more than 10%), 28 of them cerebral cortex — six
    primates, *Elephantulus myurus*, *Loxodonta africana* — on a different sample basis
    (`checks/DosSantos_2020_rereported_vs_primaries.R` and its CSV).
  - **Effect** (against a re-run of the previous script on the same inputs).
    `cell_counts_isotropic_fractionator_long` 3,259 → 3,842 cells; **no cell lost**. No `_Mass.g`,
    `_C.n`, `_N.n`, `_N.p.mg` or `_p.C.N` value that was in the merge changed (1,900 cells). 583 cells
    are new, all from Table 1: `_I.p.N` (153, a measure the merge did not have), `_I.n` and `_I.p.mg`
    (83 each), and fallback cells for structures the primaries lack (`_C.n` and `_p.C.N` 83 each,
    `_Mass.g`, `_N.n`, `_N.p.mg` 32 each). 231 microglia values changed: `_I.p.C` 102 (87 within 1%,
    none above 4.4%), `_I.n` 59 and `_I.p.mg` 70 (median change 0.01–0.02%). The 12 changes above
    10% are all cerebral-cortex `_I.n` / `_I.p.mg` of the primates and the elephant, where the previous
    values were the unpublished ratio multiplied by another paper's cortex count on a different sample
    basis; they are now the values the paper prints.
  - **Known consequence.** For those cortex cells the merged `_C.n` (primary source) and the merged
    `_I.n` (Dos Santos) describe different samples, so `_I.n / _C.n` from the merged table is not the
    microglia fraction. Use `_I.p.C`, which is built inside Table 1.
  - Minor: the Table 1 standardized-terms file mapped a column `Species` that the TSV names
    `Species name`; corrected, or the item would have lost its species column.

- **2026-09 — Jardim-Messeder et al. 2017 Table 1, *Procyon lotor* hippocampus mass: laterality-basis
  fix, step 3.4c.** `MHP` is doubled, 0.477 g → 0.954 g. The published raccoon row is internally
  inconsistent by exactly a factor of two: printed `DNHP` (16,076 /mg) is half of `NHP`/`MHP`
  (15.34×10⁶ / 477 mg = 32,159 /mg). Printed `O/NHP` (4.564) equals `OHP`/`NHP`, tying the two
  counts to each other, so only two readings are coherent — a halved mass, or both counts doubled.
  **A density is basis-invariant** (N/M is the same for one side as for both), so `DNHP` cannot be
  corrupted by a side error, and the evidence isolates `MHP` as the single printed error — the mass
  of ONE hippocampus printed against bilateral counts:
  - Of the 42 checkable `N.p.mg` cells in this table, 41 agree with `NHP`/`MHP` to within 0.4%.
    This is the only 2× cell, so it is not a table-wide convention.
  - *Felis catus* has almost the same brain mass (34.86 g vs 34.19 g); its hippocampus is 2.51% of
    brain and the dog's 2.32%. The printed raccoon value is 1.40%, and doubled it is 2.79%.
  - `OHP`/`MHP` as printed is 146,751 /mg, the highest in the table by 1.65×; on the doubled mass it
    is 73,375 /mg, between cat (63,870) and ferret (89,088).
  - Printed `NHP` is 0.71% of `NBR`, in line with ferret 0.79% and cat 0.66%; halving the counts
    instead would drop it to 0.36%. So the counts look right.
  - **Direct confirmation — same species, same method (2026-09-06).** Jacob et al. 2021
    (*J Comp Neurol* 529:3375, DOI 10.1002/cne.25197; Herculano-Houzel a co-author of both papers)
    reports raccoon hippocampus mass **and** hippocampal nuclei counts by isotropic fractionation
    for **one hemisphere** (Methods §2.3–2.4), pooled n-weighted over its three problem-solving
    groups: mass 474.01 mg (n = 18), total nuclei 42.60×10⁶ (n = 18), nonneuronal 36.88×10⁶
    (n = 17). Against the Jardim-Messeder row: the printed **mass matches Jacob's one-hemisphere
    mass to 0.6%** (477 vs 474.01), the printed **total cell count is twice Jacob's
    one-hemisphere count to 0.3%** (85.34×10⁶ vs 2 × 42.60×10⁶), and on the doubled mass the
    total-cell density agrees with Jacob to **0.5%** (89,455 vs 89,874 /mg) where on the printed
    mass it is off by exactly 2×. So the printed mass is unilateral and the printed counts are
    bilateral. Check: `restricted_checks/_cross_table/JardimMesseder_2017_vs_Jacob_2021_raccoon/`
    in the restricted repo. **Caveat:** the neuronal/nonneuronal split does *not* agree — 18.0%
    neurons here against 13.4% implied by Jacob — but Jacob's neuronal count is a difference of
    means over non-identical samples (n = 18 vs 17) from different animals, so it is recorded, not
    used as evidence.
  - **Congener cross-check.** Reep et al. 2007 gives the congener *Procyon cancrivorus*
    `Hippocampus_Vol.mm3` = 1,025.76 at a comparable brain size (36,858 mm³ summed, against 34,100
    mm³ for *P. lotor*), and `__merging_volumes/laterality_known.csv` records Reep values as already
    bilateral. Across size-comparable congeneric pairs, this table's mass ÷ Reep volume runs
    0.72–1.14 (*Canis* 0.904, *Panthera leo* 0.788, *P. leo* vs *pardus* 1.135, *Ursus* 0.717). The
    raccoon sits at 0.451; doubled it is 0.902. The *Mustela* pair is excluded — ferret against the
    much smaller weasel is not size-matched.

  **Effect (2 cells).** `Hippocampus_Mass.g` 0.477 → 0.954 and `Hippocampus_O.p.mg` 146,750.52 →
  73,375.26 /mg. The reported `Hippocampus_N.p.mg` (16,076) is correct and untouched, as are `_C.n`
  and `_p.C.N`. The cell now passes the density-basis check: densities imply O/N = 4.5643 against
  the paper's printed 4.564.

  The frozen source snapshot is deliberately **not** edited — it is the record of what the paper
  printed, and 0.477 is confirmed verbatim from the PDF (Table 1, p. 6). Step 3.4c carries a guard
  that stops the run if the printed value is no longer 0.477 or the row is missing.
  *(2026-11-23: under the merge's hemisphere rule the 0.954 is now marked as a both-hemisphere
  estimate in `cell_counts_isotropic_fractionator_flags.csv`, and the printed 0.477 is also served,
  as `Hippocampus_unilateral_Mass.g`. The value 0.954 itself is unchanged. See **Hemispheres**.)*
  **Cross-confirmed against Jacob et al. 2021 (same species, same method), not author-confirmed.**
  The Jardim-Messeder team has not been asked; revise if they supply the underlying mass or confirm
  the hemisphere basis. **Separately unresolved:** this raccoon's `CerebralCortex` fails the same density
  check by 3.4%, which this correction does not explain. Four other cells fail it by 2–7%
  (*Mustela putorius furo* WholeBrain, and SpinalCord for *Macaca radiata*, *M. mulatta*,
  *Aotus trivirgatus*) and look like printed-precision effects rather than basis errors.

- **2026-09 — cellular ratios and densities are now derived, not only harvested (steps 3.6, 3.7, 6, 9.1).**
  `WholeBrain_N.p.mg` had exactly **one** value in `cell_counts_isotropic_fractionator_long` (*Balaenoptera acutorostrata*,
  `AvelinodeSouza_etal_2025_TABLE1`). That was not a peculiarity of how the minke-whale table was
  compiled. Isotropic fractionation measures a density in each **dissected piece**, so the
  Herculano-Houzel-team tables print densities per structure (cortex, cerebellum, rest of brain)
  and print whole-brain **totals** — but never a whole-brain density, because the whole brain is
  not a dissected piece. Avelino de Souza et al. 2025 is the only table that tabulates a
  whole-brain density row. Meanwhile `WholeBrain_N.n` and `WholeBrain_Mass.g` were present in
  **seven** sources: the ratio was never missing from the data, it was simply never computed.
  Four changes:
  1. **Step 3.6 bug (regional `_C.n` never derived).** `prefixes` was computed once, outside the
     loop, from whatever dataframe the variable `df` was left holding by step 3.4b (Burish et al.
     2010 — WholeBrain / SpinalCord / Body only), so those were the only structures the step ever
     tried. **195** species × structure cells of `_C.n` were silently skipped (Cerebellum 50,
     CerebralCortex 49, RoB 49, OlfactoryBulb 31, Hippocampus 9, plus 7 single-species structures:
     Amygdala, CerebralCortexGrey, CerebralCortexWhite, DiencephalonStriatum, Medulla,
     Mesencephalon, Pons). `prefixes` is now rebuilt per dataframe, and the `!any(is.na(...))` test — which
     gated a whole column on one blank species — is now row-wise.
  2. **New step 3.7: within-source derivation.** `_N.p.mg`, `_O.p.mg`, `_I.p.mg`, `_O.p.N`,
     `_I.p.C`, `_p.C.N` and `_I.n` are filled from each source's own `_N.n` / `_O.n` / `_C.n` /
     `_Mass.g`, so a species × structure ratio stays tied to one paper's specimens and competes in
     the section 8 within-team resolution exactly as a reported value would.
  3. **Step 6: the cellular ratios are no longer annexed.** `_p.C.N` joined `_N.p.mg`, `_O.p.mg`
     and `_O.p.N` in the merge. `_p.C.Brain` stays annexed deliberately — it is a structure
     fraction, and `_keys/glossary.csv` defines it as a volume fraction while the masses and counts
     carried here would give a mass or neuron fraction; its basis needs pinning to the source
     table first.
  4. **Step 9.1 implemented (was commented out).** Ratios still empty after filtering are derived
     from primaries that survived for the same species and structure within the same team, across
     tables, with the two contributing sources joined in `Source`. At the time this was the only
     route to microglia numbers: the Dos Santos 2020 item then in the merge reported only the
     microglia/cell ratio `_I.p.C`, while `_C.n` and `_Mass.g` for those species came from other
     HH-team tables, so `_I.n = _I.p.C * _C.n` and `_I.p.mg = _I.n / (_Mass.g * 1000)`.
     *(Since 2026-11 the published Dos Santos Table 1 supplies `_I.n`, `_I.p.mg` and `_I.p.N`
     directly — see the 2026-11 entry above — and 9.1 only fills what is still empty.)*

  **Policy: fill-only.** A ratio a source reports is never overwritten. For isotropic-fractionation
  data the density is the measured quantity and the count is density × mass, so a printed density
  carries the authors' precision while a back-calculation from a rounded printed count does not.
  Where both exist they agree to a median |difference| of 0.02–0.24%; the 85 species-cells above 2%
  (worst *Procyon lotor* `Hippocampus_N.p.mg` at 100%, i.e. a factor of two, plausibly a
  one-versus-both-hemispheres basis) are **source-table inconsistencies to inspect**, not values to
  overwrite.

  **Effect.** `cell_counts_isotropic_fractionator_long` 2,465 → 3,259 cells; no cell lost. `WholeBrain_N.p.mg` 1 → 70
  species, `WholeBrain_O.p.mg` 1 → 48, `WholeBrain_O.p.N` 23 → 57, `WholeBrain_p.C.N` 0 → 48,
  `_I.n` and `_I.p.mg` 0 → 70 cells across 5 structures. Five values changed, all
  `WholeBrain_O.p.N` for the five Kazu artiodactyls and all by ≤0.02%: HH 2015 Table 5 now supplies
  a full-precision derived value and, per the documented date-then-species-count tie-break,
  outranks Kazu's 4-significant-figure printed value. Verified against a pre-patch run that
  reproduced the committed `cell_counts_isotropic_fractionator_long/wide/unfiltered` bit-for-bit.

  **Known, not caused by this change:** 18 rows in `cell_counts_isotropic_fractionator_long` carry `NA` values because
  five Kazu text/metadata columns (`Species_Kazu2015`, `body_mass_approximate`,
  `consistency_flags`, `parse_flags`, `source_printing`) are not annexed in step 6 and are coerced
  by `as.numeric` in 9.2 — the source of the "NAs introduced by coercion" warning. Present
  identically before this change.

- **2026-06 — HH-2020 Table 2 derived masses (unit fix), step 3.4.**
  Regional masses not reported in Herculano-Houzel et al. 2020 Table 2
  (`CerebralCortex_Mass.g`, `Cerebellum_Mass.g`, `RoB_Mass.g`) are back-calculated
  from neuron count ÷ neuronal density. Because `_N.p.mg` is neurons per **mg**,
  `_N.n / _N.p.mg` is a mass in **mg** and must be divided by 1000 to get grams.
  The code previously **multiplied** by 1000, inflating those masses by **10⁶** for
  the ~13 African bats in that table (whole-brain masses, reported directly, were
  unaffected). Corrected to `(_N.n / _N.p.mg) / 1000`. Re-run the pipeline to
  propagate the fix.

- **2026-06 — Burish et al. 2010 (two fixes).**
  (a) *Brain = whole brain*: Burish's "Brain" (`MBR`, `NBR`) is the whole brain, so it is now
  mapped to `WholeBrain_Mass.g` / `WholeBrain_N.n` in its standardized-terms file (rather than a
  separate `Brain_*` measure that duplicated WholeBrain). The `Brain_*` measure no longer exists.
  (b) *Units*: Burish tabulated cell COUNTS in **millions** (e.g. *Macaca mulatta* brain "6380" =
  6.38×10⁹ neurons; spinal-cord neuron/other counts likewise). Step 3.4b in `cell_counts_isotropic_fractionator_compiled.R`
  now multiplies `WholeBrain_N.n`, `SpinalCord_N.n(_SD)`, `SpinalCord_O.n(_SD)` by 1e6. Masses (g),
  densities (per mg) and percentages were already absolute and are unchanged. A density sanity scan
  (neurons / (mass×1000) should be ~50–3,000,000 /mg) flagged only Burish; JardimMesseder et al. 2017
  and the other datasets were within range. Re-run `standardized_term.R` then `cell_counts_isotropic_fractionator_compiled.R`.

## Within-team resolution: most recent wins (worked example, Kazu 2015)

`cell_counts_isotropic_fractionator_compiled.R` §8.2 builds a `worth_dataframe` per team, sorting sources by **date
descending, then number of species descending**, and assigns `priority` = row number. §8.3 then
marks every row `WORSE` whose priority is above the minimum for that **species × variable**, and
drops it. So a newer table from the same team supersedes an older one automatically, per
species × variable — there is no manual column filtering and no per-source exclusion list to
maintain.

`Kazu_etal_2015_TABLE1` (added 2026-08-06) is the worked example, and it is instructive because
the date *ties*:

- Kazu is Herculano-Houzel–team work, so it is resolved in §8.2.H alongside `HerculanoHouzel_etal_2015`
  Tables 1–5. Both are dated **2015**.
- The tie-break on species count hands the shared variables to HH (≈40 species against 5).
- Simulated against the published TSVs before wiring: of the five Kazu species,
  **80 species × variable pairs are held by both → HH wins**; **87 pairs are sub-structure values
  only Kazu has** (hippocampus 20, pons + medulla 20, diencephalon + basal ganglia 16,
  mesencephalon 16, cortical grey matter 15); **21 more are whole-structure values HH happens to
  lack for those species**. Kazu contributes 108 values and duplicates none.
- Of the 80 overlapping pairs, **none differ by more than 2%** — HH 2015's full-precision values
  already are the corrigendum's, so which source wins does not change the data. That is the check
  worth repeating whenever a same-team, same-year source is added: if the overlap *disagreed*, the
  priority rule would be silently choosing between two different measurements rather than two
  printings of one.

The older printing, `Kazu_etal_2014_Table1`, is not in `item_name` and should never be: the
corrigendum changed 71 of the 184 cells present in both, and the 2014 values fail
`N_BR = N_CXT + N_CB + N_RoB` by up to −22%. Even if it were listed, its 2014 date would put it
below both — but leaving it out keeps the intent explicit.


## Renamed 4 Nov 2026

Former names: `__merging_cellcounts` and `__merging_cell_counts` (renamed by `_tools/__rename_cell_counts_20261104.R`, owner decisions RV-2026-004 and RV-2026-011). Inside this folder the term became `cell_counts_isotropic_fractionator` (file names, R object names, notes). It holds isotropic- and flow-fractionator counts only; counts made in tissue sections go to `__merging_cell_counts_histology`. Each source's counting method, treatment and flags: `_keys/cell_count_methods/source_methods.csv`.
