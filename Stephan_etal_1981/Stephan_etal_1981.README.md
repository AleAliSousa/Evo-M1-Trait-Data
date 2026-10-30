# Stephan, Frahm & Baron (1981) — per-table data

Stephan, H., Frahm, H., & Baron, G. (1981). *New and revised data on volumes of brain
structures in insectivores and primates.* **Folia Primatologica**, 35(1), 1-29.
DOI 10.1159/000155963.

## Layout — one snapshot per printed table (project convention)

The 1981 volume data span **16 printed tables (I-XVI)**, not 6. The former snapshot named
`TablesI-VI` actually held all 44 structure codes = the data of all 16 tables (the registry's
"the file name should be changed!" note). The paper uses **three taxon granularities** depending
on the structure-group:

| Table | Structure-group | Taxon scope | species |
|---|---|---|---|
| I / II / III | Body/brain weight + total brain & fundamental parts (codes 1-10) | Insectivore / Prosimian / Simian | 28 / 21 / 27 |
| IV / V / VI | Telencephalon and its components (11-18) | Insectivore / Prosimian / Simian | 28 / 21 / 27 |
| VII | Components of the diencephalon (19-26) | Insectivore | 10 |
| VIII | Components of the diencephalon (19-26) | **primates** (prosimian+simian) | 27 |
| IX | Visual cortex (area striata) + lateral geniculate body (27-28) | **primates only** | 40 |
| X | Palaeocortex, amygdala and components (29-34) | Insectivore | 10 |
| XI | Palaeocortex, amygdala and components (29-34) | **primates** | 18 |
| XII | Vestibular complex and components (35-39) | Insectivore | 10 |
| XIII | Vestibular complex and components (35-39) | **primates** | 27 |
| XIV / XV / XVI | Various periventricular structures (40-44) | Insectivore / Prosimian / Simian | 26 / 20 / 21 |

Fundamental / telencephalon / periventricular groups split into all three taxa; diencephalon,
palaeocortex and vestibular split insectivore-vs-pooled-primates; the visual table is
primates-only. The taxon each table was captioned by is carried in each file's `group` column.

Each printed table is its own item under ``: `Stephan_etal_1981_Table{I..XVI}` with a
matching `_snapshot.xlsx`, `.R`, `.csv`, and public TSV
(`10.1159%2F000155963_Table{I..XVI}.tsv`).

> **History.** Replaced the single bundled `TablesI-VI` item (which dropped the per-table taxon
> label). The split is merge-invariant: `volumes_long.csv` / `volumes_wide.csv` are byte-identical
> before and after; only provenance labels in `volumes_unfiltered.csv` / `volumes_flags.csv`
> refine to the per-table item names. See the split invariance report.

## Laterality
Vestibular structures (Tables XII & XIII, codes 35-39) were measured from **one side only**
(Baron et al. 1988). Their five columns carry a `_unilateral` suffix so a one-side value is
never silently averaged against a both-sides value. Registered in
`__merging_volumes/laterality_known.csv` for both TableXII and TableXIII.

## Excluded column
Code 4 `Meninges_hypophysis_nerves_etc.` (Tables I-III) is intentionally **not** in the term map
— it is not a brain-structure volume for the comparative merge (same as the bundled version).

## Cross-table QA
`Stephan_etal_1981_crosstable_QA.R` checks the 8 telencephalon components (Tables IV-VI)
sum to the fundamental Telencephalon total (Tables I-III), per species. n=76, median |diff|
0.007 %. **One species flagged**: *Solenodon paradoxus* at 4.09 % — this deviation is present
identically in the original source data (not a split artifact; 1981 reports palaeocortex/amygdala
as a separate structure-group).

## Registry / encoding note
The `__ReadMe.xlsx` rows for Tables VIII / IX / X carry drifted DOI encodings
(000155964/5/6). All 16 items are pinned to the correct single paper DOI 10.1159/000155963 via
`enc_override` in `volumes_compiled.R`, so resolution is correct regardless of those cells.
