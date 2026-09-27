# Merging cell type, cell size and cell morphology data — DRAFT

**Status: DRAFT merge, 2026-09-27 — wired into the Shiny app the same day.** `__ShinyApp/app.R`
loads `cell_morphology_long.csv` through `std_cell_morphology()` (dataset label "Cell type, size &
morphology"; 1,700 rows, 270 variables, 115 species after the app's filters), and the legacy
`interlaminar_astrocytes.xlsx` melt was retired from `__ShinyApp/build_data.R` so Falcone 2019
reaches the app once, via this merge. The 270 labels have **no rows yet in
`_keys/variable_domain.csv`**, so the app lists them under "Unclassified" until that key is extended
(`Rscript _keys/build_variable_definitions.R && Rscript __ShinyApp/build_data.R`).
The folder follows the `__merging_gyrification` / `__merging_cortical_layers` pattern
(`standardized_term_by_reference/` → `standardized_term.R` → `<trait>_compiled.R` → long CSV + QA),
and it is the sibling that `__merging_cortical_layers/README__merging.md` anticipates when it says the
layer-thickness merge keeps the Jacobs lineage "separate from soma, dendrite and spine traits".
The compile script has been run once so that the inventory, term maps and crosswalks are proven
against the public TSVs; the outputs are **draft data products for review, not release files**.

## Scope

One long table of **cell-type-resolved morphometry**: for a named cell type in a named region and
layer, how big is the cell body, how large/complex is its dendritic arbor, how many spines does it
carry, and — for the two "special" neuron types with counts (von Economo neurons, fork cells) — how
many are there and what fraction of layer V neurons they make up. Three axes distinguish it from the
existing products:

| axis | this merge | where the neighbouring construct lives |
|---|---|---|
| **cell type** | pyramidal L3 / L5, gigantopyramidal (Betz), Meynert, VEN, fork, fusiform L6, felid Golgi classes, corticospinal, thalamic relay, interlaminar astrocyte | whole-structure neuron/glia totals (no cell type) → `__merging_cellcounts` |
| **cell size** | soma volume / area / length / diameter / depth | structure volume → `__merging_volumes`; layer thickness → `__merging_cortical_layers` |
| **cell morphology** | dendritic volume, length, segments, trees, basal field area, Sholl complexity, spine number and density | gyrification / folding → `__merging_gyrification`, `__merging_cerebellar_folding` |

**Deliberately excluded (kept in their own products, never merged here):**

- **Counts and densities of neurons/glia without a cell type** (Herculano-Houzel, Kaas, Pakkenberg,
  Morgan, Lewitus glia/neuron ratios): `__merging_cellcounts`. Glia *subtype* numbers
  (astrocyte / oligodendrocyte / microglia in Karlsen & Pakkenberg 2011, Morgan 2014, Hanson 2018
  Table 3) are cell-type composition **by count** and belong there too; all three are human-only.
- **Corticospinal soma counts, regional densities and population distribution** (Nudo 1995
  Tables 2–5 except the soma diameter): sensorimotor & motor-pathways scope (not yet wired anywhere;
  see `SOURCE_INVENTORY.csv`).
- **Cortical surface area** printed alongside dendritic data (Elston 2006 `CSA`): `__merging_cortical_areas`.
- **Secondary brain/body/ecology columns** in Sherwood 2003 Table 1: their primaries (Stephan 1981,
  Baron 1996, Harvey 1987…) are already held; the columns are dropped in the term map.
- **Transcriptomic cell-type proportions** (Jorstad et al. 2023 Tables S1–S4): HOLD. The registry
  rows are `FINISHED` but no public TSV is on disk, and `PROJECT_SCOPE_AND_DATASET_ROADMAP.md` assigns
  cell types and their proportions to the transcriptomic project. **Owner decision** whether any
  snRNA-seq / MERFISH subclass proportion ever enters this repository's merges.

## Sources in this draft build

Every source below is built, registered, and has a public TSV on disk (one filename mismatch, see
Known issues). None was wired into any `__merging_*` script before this draft (`grep` 2026-09-27).

| Source | team (provisional) | taxa | long rows | cell types | regions | measures | secondary rows | merge_default = FALSE |
|---|---|---:|---:|---|---|---|---:|---:|
| `Jacobs_etal_2018_Table3` | Jacobs | 20 | 477 | gigantopyramidal, pyramidal_L5 | M1 | soma_area, soma_length, soma_volume | 0 | 0 |
| `Jacobs_etal_2018_Table5` | Jacobs | 19 | 832 | gigantopyramidal, pyramidal_L3, pyramidal_L5 | M1 | dendritic_segment_count, dendritic_volume, mean_segment_length, soma_area, soma_depth, spine_count, spine_density, total_dendritic_length | 0 | 0 |
| `Nguyen_etal_2019_Table2` | Jacobs | 3 | 690 | aspiny, extraverted, gigantopyramidal, horizontal, inverted, meynert, multiapical, neurogliaform, pyramidal_unspecified | M1, V1, frontal | as Jacobs 2018 T5 | 0 | 0 |
| `Bianchi_etal_2012_Table2` | Jacobs | 2 | 120 | pyramidal_L3 | M1, PFC_area10, S1_3b, V2 | as Jacobs 2018 T5 + dendritic_tree_count | 56 (human) | 0 |
| `Jacobs_etal_2015_Table4` | Jacobs | 5 | 20 | pyramidal_unspecified | pooled_multiregion | soma_area, soma_depth | 16 (4 non-giraffe spp) | 0 |
| `Elston__2000_Figure2` | Elston | 1 (*M. fascicularis*, resolved) | 16 | pyramidal_L3 | PFC_area10/11/12, V1, parietal_7a, temporal_TE | basal_dendritic_field_area, branches_at_75um, spine_count | 3 (V1, 7a, TE) | 0 |
| `Elston_etal_2001_Table1` | Elston | 3 | 54 | pyramidal_L3 | PFC, occipital, temporal | basal_dendritic_field_area, max_spine_density, peak_branching_complexity | 0 | 0 |
| `Elston_etal_2006_Table1` | Elston | 7 | 39 | pyramidal_L3 | PFC_granular, V1, V2 | basal_dendritic_field_area, spine_count | 35 | 10 (footnote *t*) |
| `Sherwood_etal_2003_Table1` | Sherwood | 25 | 282 | gigantopyramidal, meynert, pyramidal_L5 | M1, V1 | soma_volume | 0 | 0 |
| `Nimchinsky_etal_1999_Table2` | Hof | 5 | 30 | fusiform_L6, pyramidal_L5, ven | ACC | soma_volume | 0 | 0 |
| `Butti_etal_2009_Table5` | Hof | 4 | 23 | ven | ACC, ACC_subgenual, PFC_area10, anterior_insula | ven_count, ven_pct | 0 | 0 |
| `Butti_etal_2009_Table6` | Hof | 4 | 28 | fusiform_L6, pyramidal_L5, ven | ACC (inferred) | soma_volume, ven_index | 0 | 0 |
| `Hakeem_etal_2009_Table1` | Hof | 1 | 10 | ven, all_neurons | FI | ven_count, ven_pct, reference_neuron_count | 0 | 0 |
| `Raghanti_etal_2015_Table1` | Sherwood | 8 | 64 | ven, fork_cell | ACC, PFC_area10, anterior_insula, occipital_pole | ven_pct, fork_pct | 0 | 0 |
| `Falcone_etal_2019_TABLE1` | Falcone | 47 | 180 | interlaminar_astrocyte | frontal | ila_presence (categorical) | 0 | 0 |
| `Falcone_etal_2019_TABLE2` | Falcone | 47 | 226 | interlaminar_astrocyte | frontal | ila_linear_density, ila_primary_processes, ila_total_processes, ila_total_length, ila_complexity | 0 | 0 |
| `Armstrong__1979_Tables1-9` | Armstrong | 5 (incl. *Hylobates* sp.) | 40 | thalamic_relay | LGN parvo/magno, MGN parvo, VB | soma_volume (perikaryal) | 0 | 0 |
| `Nudo_etal_1995_TABLE2` | Nudo/Masterton | 24 | 24 | corticospinal | cortex_corticospinal_field | soma_diameter | 0 | 0 |

**Total (draft run): 3,155 long rows, 117 taxa, 18 cell types, 27 measures.** Row counts include
every printed statistic (mean, sd/sem, min, max, cv, ce), so they overstate the number of
observations; `cell_morphology_coverage.csv` counts central values only.

Second-tier and out-of-scope items (Jorstad 2023, Jacobs 1997/2001 parents, Hanson 2018,
Karlsen & Pakkenberg 2011, Morgan 2014, Jacob 2021 Figure 4, Nudo Tables 3–5, Kaskan 2005 …) are
listed with a disposition and reason in **`SOURCE_INVENTORY.csv`**.

## Long-table schema (`cell_morphology_long.csv`)

One row per (source × species × specimen × region × layer × cell type × measure × statistic).

| column | meaning |
|---|---|
| `source`, `doi`, `team` | registry item; DOI from `__ReadMe.xlsx`; provisional team label |
| `Species`, `species_printed`, `taxon_level` | accepted binomial as given by the source's harmonised column, or from `species_aliases_draft.csv` when the source prints common names / genera; `genus` only for *Hylobates* sp. (Armstrong 1979) |
| `observation_level`, `specimen_id`, `hemisphere` | `species summary` or `individual` (Armstrong 1979; Hakeem 2009 hemispheres); hemisphere carried, **never doubled** |
| `region`, `region_printed`, `layer` | controlled region code via `region_crosswalk.csv`; layer from the term map, the cell-type crosswalk, or the printed column |
| `cell_type`, `cell_type_printed` | controlled code via `cell_type_definitions.csv` / `cell_type_crosswalk.csv` |
| `method_class`, `variant`, `variable_label` | pooling key for the app: `golgi`, `LYinj`, `stereology`, `fractionator`, `nissl_count`, `nissl_perikaryal`, `HRP`, `GFAP`; `variant` = pial/subpial × dorsal/ventral for Falcone Table 1; `variable_label` = `region_cellType_measure[_variant] [method_class]` — the app appends ` (unit)` and averages only rows sharing this label |
| `measure`, `statistic`, `value`, `value_text`, `unit` | measure code from `cell_morphology_definitions.csv`; statistic ∈ mean, sd, sem, min, max, cv, ce, estimate, value, category; `value_text` keeps categorical values (ILA presence) and the printed string |
| `n`, `n_basis` | sample size and what it counts (neurons, individuals, neurons per layer per case) |
| `method` | source-stated or lineage default (Golgi tracing, Lucifer-Yellow injection, nucleator/rotator stereology, Nissl perikaryal volumetry, optical fractionator, GFAP + Neurolucida) |
| `data_role`, `dependency`, `merge_default`, `ref` | primary/secondary per row; named parent when a value is re-reported; `merge_default = FALSE` only where the same value is already merged from its own table |
| `source_note`, `term_note`, `curation_note` | source flags (e.g. `gigantopyramidal_absent=TRUE`, `underestimate=TRUE`), term-map notes, compile-time notes (unit rescale, inferred region) |

## Merge rules drafted (all subject to owner sign-off)

1. **The product stays long.** No wide table is generated because a species-level "the" soma size
   does not exist: the same species × region × cell type is measured by Golgi 2-D tracing (area)
   and by stereological nucleator/rotator probes (volume) — `Jacobs_etal_2018` Tables 3 and 5 are the
   same specimens by two methods, and `cell_morphology_qa_overlaps.csv` lists all 27 such groups.
   **Values from different methods are never averaged.** Any future wide product must be keyed by
   (region, layer, cell_type, measure, method).
2. **Cell-type naming is unified, not the measurements.** `gigantopyramidal` collects Jacobs'
   "gigantopyramidal", Sherwood 2003 "Betz" and Nguyen's "Gigantopyramidal"; `ven` collects
   Nimchinsky's "spindle" and later "VEN". The printed label is always retained in `cell_type_printed`.
3. **Hemisphere basis is carried and never doubled** (VEN counts are single-hemisphere in Butti 2009
   and Hakeem 2009; Armstrong's nuclei are one hemisphere). Same policy as `__merging_volumes/laterality_known.csv`.
4. **Re-reported values are flagged, not dropped**, except where the identical value is already
   merged from its own table:
   - Elston 2006 footnote `t` (= Elston et al. 2001) → `merge_default = FALSE`, dependency named;
     other footnotes (`a`–`s`) are secondary re-reports of earlier Elston papers not held in the
     repository and stay `merge_default = TRUE`.
   - Bianchi 2012 human rows reuse Jacobs 1997/2001 → `data_role = secondary`, kept as the only
     per-area tabulation of those human data. They are **not** the same numbers as the human M1
     "Superficial" cells in Jacobs 2018 Table 5 (soma area 273 vs 452 µm²; n = 10 new tracings),
     so both are genuine observations and both stay.
   - Jacobs 2015 Table 4 non-giraffe rows (`ref` a/b) → secondary; primaries (Jacobs 2011 elephant,
     Butti 2014 cetaceans) are not in the repository.
   - Elston 2000 spine totals for V1, 7a, TE → secondary comparator values.
   - Elston 2001 *Macaca* / Prefrontal BDFA and branching rows are the Elston 2000 area-10 cells
     re-tabulated (dependency named; kept because 2001 prints the SD that 2000 lacks).
5. **Unit corrections are explicit.** Elston 2001 prints basal dendritic field area in units of
   10⁴ µm²; the compile rescales to µm² and writes `curation_note`. Elston 2001's maximum spine
   density (per 10 µm) is **not** rescaled to spines/µm because it is a maximum, not a mean, and gets
   its own measure code `max_spine_density`.
6. **Absence is not missing.** Jacobs 2018 Table 5 `gigantopyramidal_absent = TRUE` species keep an
   empty gigantopyramidal row flagged in `source_note`; Falcone 2019 `No` / `rudimentary` presence
   classes are categorical values, not blanks.
7. **Team-aware within-team resolution is NOT applied yet.** Unlike `__merging_cellcounts` §8, no
   most-recent-wins pass runs here. Two same-team, same-method (Golgi) overlaps exist and both stay
   as separate rows for now, because the values differ and are therefore distinct measurements:
   - *Homo sapiens* M1 layer III pyramidal, `Bianchi_etal_2012_Table2` (Jacobs 1997/2001 data) vs
     `Jacobs_etal_2018_Table5` (n = 10 new tracings): soma area 273 vs 452 µm², total dendritic
     length 3,563 vs 6,121 µm.
   - *Panthera leo* M1 gigantopyramidal, `Jacobs_etal_2018_Table5` (n = 10) vs
     `Nguyen_etal_2019_Table2` (n = 16; source footnote says the Golgi impregnation was incomplete
     and the dendritic/spine measures are underestimates): soma area 2,824 vs 1,771 µm², total
     dendritic length 8,600 vs 1,872 µm.
   A blind most-recent-wins rule would keep Nguyen's flagged underestimates over Jacobs 2018 for the
   lion, so the resolution rule here needs to weigh the source's own quality flag — **owner decision**.

## Owner decisions needed before wiring

1. **Folder / trait name.** `__merging_cell_morphology` is a placeholder. Alternatives:
   `__merging_neuron_morphology` (but Falcone's interlaminar astrocytes are glia),
   `__merging_cell_types` (but most rows are morphometry, not composition).
2. **Do glial cell types belong here?** Falcone 2019 interlaminar astrocytes are the only glial
   morphology source and give 47 species. Keep (one glial `cell_type`) or spin off.
3. **Transcriptomic cell-type proportions** (Jorstad 2023): in, held, or explicitly out (roadmap
   currently says out).
4. **Species resolution.** Elston 2000 names only "macaque monkey"; it is now resolved to
   *Macaca fascicularis* because its area-10 cells (n = 29; 133.2 × 10³ µm²; 32.35 branches; 8,766
   spines) are re-tabulated, species named, in Elston et al. 2001 Table 1 and Elston et al. 2006
   Table 1 — see `ELSTON_2000_SPECIES_EVIDENCE.md`, which also records two discrepancies exposed by
   the match (animal age/sex differs between the papers; the 2000 "SD" is numerically the SEM).
   *Hylobates* sp. (Armstrong 1979) stays at genus level. `Cercopithecus pygerythrus` (Elston 2006)
   is aliased to *Chlorocebus pygerythrus* in the draft alias table; confirm against
   `_keys/species_reference.csv` / MDD. **88 of 117 names are not in `_keys/species_reference.csv`**
   (`cell_morphology_qa_species_not_in_reference.csv`) — expected, since the reference only lists
   species already merged; they are the input for a `resolve_taxonomy.R` pass.
5. **Team labels** are provisional (`team_of` in the compile script). Bianchi 2012 and Nguyen 2019
   are filed under the Jacobs Golgi lineage because they use its protocol and, for human, its data;
   Raghanti 2015 under Sherwood. Confirm against `_keys/team_grouping_crosswalk.csv` and add rows there.
6. **Region for Butti 2009 Table 6** (ACC) is the folder README's inference from Table 2 coverage,
   not printed in the caption — confirm from the Results before pooling with Nimchinsky 1999.
7. **Wide product, if any.** Suggest an M1-first wide keyed by method, as `__merging_cortical_layers`
   did: `M1_L5pyramidal_soma_volume_um3 (stereology)`, `M1_gigantopyramidal_soma_volume_um3 (stereology)`,
   `M1_L3pyramidal_spine_density (Golgi)`, `M1_gigantopyramidal_spine_count (Golgi)` — the Betz-cell
   traits the roadmap's item 9 asked for.

## Known issues found while drafting

- **`Nimchinsky_etal_1999_Table2` public TSV filename has a stray space**
  (`10.1073%2Fpnas.96.9.5268 _Table2.tsv`; Table 1 likewise) and so does not match the registry's
  `Item encoded`. The compile carries a **temporary, warned** override (`tsv_override`); re-run
  `Nimchinsky_etal_1999/Nimchinsky_etal_1999_Table2.R` (and `_Table1.R`) so the TSV name matches,
  then delete the override.
- **Jorstad 2023 (4 items) and Kaskan 2005 (4 items)** are `FINISHED` in `__ReadMe.xlsx` but have no
  public TSV on disk — registry-vs-folder gaps of the kind `_checks/registry_snapshot.R` tracks.
- `Falcone_etal_2019_TABLE2` prints *Cercocebus kandti* where Table 1 prints *Cercopithecus kandti*
  (already noted in that item's definitions); the draft carries the printed names — resolve in the
  taxonomy pass.
- Nguyen 2019 `Species_scientific_printed` is *Panthera leo leo* (subspecies) against `Species`
  *Panthera leo*; Jacobs 2018 has *Panthera tigris altaica*. Subspecies handling follows whatever
  `__merging_cellcounts` does for the same names.

## Files

| file | role |
|---|---|
| `README__merging.md` | this file |
| `SOURCE_INVENTORY.csv` | every candidate item: tier, disposition (IN / HOLD / OUT), TSV status, rows, taxa, reason |
| `cell_morphology_definitions.csv` | controlled measure vocabulary (27 codes, units, notes) |
| `cell_type_definitions.csv`, `cell_type_crosswalk.csv` | controlled cell-type codes and printed-label → code map per source |
| `region_crosswalk.csv` | printed region label → controlled region code |
| `ELSTON_2000_SPECIES_EVIDENCE.md` | how the unnamed Elston 2000 macaque was resolved to *M. fascicularis*, and the two source discrepancies that surfaced |
| `species_aliases_draft.csv` | common name / genus → binomial for sources without a harmonised species column (verify) |
| `standardized_term_by_reference/<Item>_standardized_terms.csv` | one row per TSV column: measure code or key role (`Species`, `region_printed`, `cell_type_printed`, `n`, `ref`, `note`, `DROP`, `FILTER`) plus cell_type / region / layer / statistic / unit / hemisphere |
| `standardized_term.R` → `standardized_term_cell_morphology.csv` | stacker; fails on duplicate terms |
| `cell_morphology_compiled.R` | draft compile (reads TSVs via the registry, fails loudly on unmapped columns / unknown codes) |
| `cell_morphology_long.csv` | draft long product |
| `cell_morphology_coverage.csv` | species × region × layer × cell type × measure → number of sources |
| `cell_morphology_qa_overlaps.csv` | same species × region × cell type × measure from more than one source (28 groups: cross-method, Bianchi-vs-Jacobs human, Jacobs-vs-Nguyen lion, Elston 2000-vs-2001 macaque area 10) |
| `cell_morphology_qa_unmapped_labels.csv` | printed cell-type / region labels with no crosswalk row (0 after this run) |
| `cell_morphology_qa_species_not_in_reference.csv` | names absent from `_keys/species_reference.csv` |

## Rebuild

```sh
Rscript __merging_cell_morphology/standardized_term.R
Rscript __merging_cell_morphology/cell_morphology_compiled.R
```

Both scripts resolve their own path, so they also run from RStudio (Source). To add a source: build
its public TSV, add `standardized_term_by_reference/<Item>_standardized_terms.csv` (every column must
appear once), add printed labels to the two crosswalks, append the item to `item_name` and `team_of`,
and decide its `data_role` / dependency rows in the compile's `case_when` blocks.

## Registry / roadmap follow-ups (not done here)

- `__ReadMe.xlsx` is untouched. No new registry rows are needed — all 18 sources are already registered.
- `PROJECT_SCOPE_AND_DATASET_ROADMAP.md` item 9 (Jacobs 2018 → "`__merging_cellcounts` as a regional
  M1 sub-trait") should be re-pointed to this folder if the owner accepts the scope above; the same
  applies to the "Jacobs regional M1 morphology" audit note (roadmap do-first step 5).
