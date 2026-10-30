# Baker_etal_2025_SupplementaryData1

## Source

Supplement: `42003_2025_8686_MOESM3_ESM.xlsx` (Supplementary Data 1)
PDF: `Baker-2025-Human-dexterity-and-brains-evolved-.pdf`

Paper: Baker, J., Barton, R. A., & Venditti, C. (2025). *Human dexterity and brains evolved hand in hand.* Communications Biology 8(1). https://doi.org/10.1038/s42003-025-08686-5

Data: **Supplementary Data 1**, two sheets — `Data` (178 taxa × hand-bone, brain/body, and behavioural columns) and `References` (51 numbered primary sources plus three global behavioural sources).

## This paper is **secondary**

Baker et al. did not measure the specimens; they compiled hand-bone lengths, brain/body sizes and behaviour from many **primary** sources. Each data cell carries a numeric reference token in `Bone References` or `Brain References` that keys into the supplement's second sheet. The build resolves those tokens to their primary citations, so the output stands on its own.

## Layout

The **final outputs (csv, tsv) come only from the paper, via the snapshot** — the References sheet is transcribed once into `reference_tables/` and used to resolve tokens.

| Path | Role |
|---|---|
| `Baker_etal_2025_SupplementaryData1_snapshot.xlsx` | Faithful copy of the published supplement (sheets `Data`, `References`). Source of truth. |
| `Baker_etal_2025_SupplementaryData1.R` | **Preparation** → `Baker_etal_2025_SupplementaryData1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `Baker_etal_2025_SupplementaryData1.csv` | Lean, analysis-ready table, 178 rows. |
| `reference_tables/Baker_etal_2025_references.csv` | **Primary references off sheet 2**, number → short + full citation, with category (bone / brain / behavior) and notes. |
| `reference_tables/Baker_etal_2025_definitions.csv` | Data dictionary (columns, units; documentation only). |
| `comparison/` | Reserved for QA outputs. |

## 1. Preparation — `Baker_etal_2025_SupplementaryData1.R` → `...csv`

Reads **only** the snapshot `Data` sheet. One row per taxon (178), 45 columns. Only obvious in-place fixes:

- Values parsed to numbers; blanks → `NA`.
- The restricted-data placeholder `*` (Lemelin 1996 strepsirrhine hand data, withheld from the supplement) → `NA`, and the row flagged `bone_data_restricted = TRUE` (26 rows).
- `Tree Name` (e.g. `Adapis_parisiensis`) → canonical binomial `Species` (`Adapis parisiensis`); the original label is kept as `Tree_Name`.
- **Reference resolution:** `Bone References` / `Brain References` tokens are split on `;`/`,`, the trailing `*` on `40*` is stripped, and each number is mapped to a short primary citation in new `*_References_resolved` columns. The raw numeric tokens are retained (`Bone_References`, `Brain_References`) so the mapping to `references.csv` stays explicit.

Measurements are left in the paper's published units — **log10** of length (mm), mass (g) or volume (cm³) — not back-transformed. See the definitions table.

On save it writes the CSV next to the script and a tab-separated copy named by the item's encoded DOI (`10.1038%2Fs42003-025-08686-5_SupplementaryData1`, from `__ReadMe.xlsx`) into the shared `__Public/comparative-data/` folder.

## 2. Primary references — `reference_tables/Baker_etal_2025_references.csv`

Transcribed from the `References` sheet. Numbers **1–25 + 40** are hand-bone sources, **26–39** are brain/body sources, and three whole-column behavioural sources are appended: tool use = Bentley-Condit 2010, binocularity = Ross 1995, workspace = Feix et al. 2015. Grouped entries are preserved with notes: **6** = Rolian personal communication (sub-sources Rolian 2009, Nelson et al. 2011); **32** = the Stephan/Frahm brain-volume series (Frahm 1982, Stephan 1981, Stephan 1984); **40** = Lemelin 1996 dissertation, **restricted** — values withheld from the supplement and shown as `*`.

## 3. Definitions — `reference_tables/Baker_etal_2025_definitions.csv`

One row per output column with its unit. Documents the output; the preparation script does not read it. Taxonomy harmonisation (matching `Species` across papers) is a later, cross-paper step.
