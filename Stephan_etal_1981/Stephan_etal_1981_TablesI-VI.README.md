# Stephan_etal_1981_TablesI-VI

## Source

PDF: `Stephan-1981-New and revised data.pdf`. Paper: Stephan, H., Frahm, H. D., & Baron, G. (1981), *New and revised data on volumes of brain structures in insectivores and primates*, Folia Primatologica 35, 1-29.

This is the **master volume table** of the Stephan/Frahm/Baron collection and the dominant source feeding the `Stephan_primates` compilation (approximately 43 of its traits). It reports volumes of approximately 44 brain structures for 76 species (Insectivora, Macroscelidea, Scandentia, and Primates).

## Pipeline

raw -> snapshot -> R script -> usable csv/tsv.

| Path | Role |
|---|---|
| `Stephan-1981-New and revised data.pdf` | The publication. |
| `Stephan_etal_1981_TablesI-VI_snapshot.xlsx` | **Snapshot** (sheet `Table1`): 76 species in Stephan code (taxonomic) order x the 44 structures, in the journal's code order, with the 6 per-range `n` columns, and a `group` column (taxon each source table was captioned by). Values from the curated `Stephan_1981` dataset. |
| `Stephan_etal_1981_TablesI-VI.R` | Preparation -> `Stephan_etal_1981_TablesI-VI.csv` (+ DOI/PMID-named TSV). Reads only the snapshot. Adds explicit laterality suffixes to the unilateral vestibular columns. |
| `reference_tables/Stephan_etal_1981_TablesI-VI_definitions.csv` | Data dictionary: each structure -> code, anatomy, measure, role, taxon. |
| `comparison/Stephan_1981.csv` | The formatted dataset, audited only. |
| `comparison/Stephan_etal_1981_TablesI-VI_compare_to_Stephan_1981_csv.R` | Checking (QA): snapshot vs `Stephan_1981.csv`. |

## Snapshot layout

A wide table: `code`, `group`, `species`, then the 44 structure-volume columns interleaved with the 6 sample-size columns `n (1-18)`, `n (19-26)`, `n (27-28)`, `n (29-34)`, `n (35-39)`, `n (40-44)`, exactly the structure-code groups the journal uses. Each structure header carries its Stephan code in parentheses. **Units:** body weight in g, brain weight in mg, all structure volumes in mm3. Species run in Stephan code order (Solenodon = 1 ... Homo sapiens = 280), which is the journal's taxonomic sequence.

**The `group` column preserves the taxon each source table was captioned by.** In the printed paper the volume data are split across six tables *by taxon*, not by structure alone: Tables I/II/III give body/brain mass and fundamental parts for **insectivores / prosimians / simians** respectively, and Tables IV/V/VI give the telencephalon components for the same three taxa. The consolidated snapshot merges all six into one sheet, so without an explicit column that per-table taxon label would be lost (this parallels the `group` column in `Stephan_etal_1970`). `group` is assigned by Stephan code directly from those table captions:

| `group` | Source tables | Stephan codes | n |
|---|---|---|---:|
| `Insectivore` | I, IV | 1-84 (incl. Macroscelidea) | 28 |
| `Prosimian` | II, V | 102-147 (incl. Scandentia: *Tupaia*, *Urogale*) | 21 |
| `Simian` | III, VI | 151-280 | 27 |

These are the paper's own coarse taxonomic groupings (the terms are dated — "insectivore" here is polyphyletic and "prosimian"/"simian" are grades, not clades — but they are the labels the source tables carry, so they are retained verbatim). Finer, current taxonomy (Order/Family, accepted names) is applied downstream via `../_keys/Stephan/` and `../_keys/species_reference.csv` (`Order_Stephan1981`, `Suborder_Stephan1981`, `Family_Stephan1981`).

## Anatomical definitions used by downstream keys

The names in the 44-column table are not always bare modern structure labels.
The printed footnotes define their inclusions, and those definitions control
crosswalks even when another table has a similar value:

- code 5 **net brain volume** is the sum of codes 6-10. It is not a generic
  whole-brain-volume synonym;
- code 6 medulla receives the substantia reticularis that could not be
  separated from mesencephalon, while code 8 mesencephalon excludes it;
- code 7 cerebellum includes brachium and nuclei pontis;
- code 9 diencephalon includes pallidum and excludes hypophysis;
- code 13 piriform lobe includes palaeocortex and amygdala and excludes
  schizocortex;
- code 15 striatum includes caudate, putamen, nucleus accumbens, and the parts
  of internal capsule running through the striatum, but excludes pallidum;
- code 16 schizocortex contains entorhinal, perirhinal, presubicular and
  parasubicular cortex plus their underlying white matter;
- code 18 neocortex includes underlying white matter, corpus callosum, and the
  insular, subgenual, cingular and retrosplenial transitional cortices;
- code 27 area striata includes underlying white matter, so it must not be keyed
  to a grey-matter-only V1 term; and
- codes 29, 31 and 33 have the detailed olfactory/amygdaloid component lists
  transcribed in `reference_tables/Stephan_etal_1981_TablesI-VI_definitions.csv`.

These statements were checked against the complete footnotes on printed pages
11, 15, 20 and 21 of the PDF. The definitions CSV is the compact machine-readable
record; this section records how those definitions affect keying decisions.

## Laterality note: Stephan 1981 vestibular structures are unilateral

The 1981 paper lists the vestibular complex and four component nuclei as codes 35-39 in Tables XII and XIII. The paper itself does not label those table values as unilateral. However, Baron, Frahm & Stephan (1988), *Comparison of Brain Structure Volumes in Insectivora and Primates. VIII. Vestibular Complex*, later states that the vestibular nucleus volumes in Stephan et al. (1981) were measured in 39 species **from one side only**, whereas the 1988 vestibular data were new measurements **from both sides**. Therefore the Stephan 1981 values below should be treated as measured unilateral volumes, not bilateral volumes.

The script leaves the numeric values unchanged and makes the laterality explicit by appending `_unilateral` to only these five output columns:

| Stephan code | Journal structure | Output column |
|---:|---|---|
| 35 | Complexus vestibularis | `Complexus_vestibularis_unilateral` |
| 36 | Nucleus vestibularis superior | `Nucleus_vestibularis_superior_unilateral` |
| 37 | Nucleus vestibularis lateralis | `Nucleus_vestibularis_lateralis_unilateral` |
| 38 | Nucleus vestibularis medialis | `Nucleus_vestibularis_medialis_unilateral` |
| 39 | Nucleus vestibularis descendens | `Nucleus_vestibularis_descendens_unilateral` |

Use `_unilateral` rather than `_hemisphere`: these are brainstem vestibular nuclei, so "hemisphere" could be misread as cerebral hemisphere. The source does not specify left versus right side. For a bilateral approximation, compute `2 * value` downstream and flag it, e.g. `estimated_bilateral_from_unilateral = TRUE`; do not overwrite the original unilateral measurements.

## Preparation -> `Stephan_etal_1981_TablesI-VI.csv`

One row per species (76 rows x 53 cols); identifier columns `code`, `group`, `Species` are carried through untyped, and journal headers cleaned to R-friendly names (`Body_weight`, `Total_brain_net_volume`, `Neocortex`, ..., plus `n_1_18` etc.), all measurements typed numeric. Current accepted names + finer taxonomy are applied downstream via `../_keys/Stephan/`. Also writes a DOI/PMID-named TSV to `../__Public/comparative-data/`.

Schema note: the five vestibular output columns now carry the `_unilateral` suffix listed above. Other structure-volume columns are not relabeled as unilateral.

## Checking -> `comparison/`

Matches the snapshot to `Stephan_1981.csv` by species and compares every shared structure column. Verified: **76 species, 44 structure columns, 0 cell mismatches** (the snapshot is assembled from this CSV, so this confirms faithful assembly; the `n` columns are carried from the CSV but named differently, so they are not part of the value audit).
