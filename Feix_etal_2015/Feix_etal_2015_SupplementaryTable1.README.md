# Feix et al. 2015, Supplementary Table 1

Feix, T., Kivell, T. L., Pouydebat, E., & Dollar, A. M. (2015). Estimating thumb–index finger precision grip and manipulation potential in extant and fossil primates. *Journal of the Royal Society Interface*, 12, 20150176. [DOI](https://doi.org/10.1098/rsif.2015.0176).

## Source and scope

The open [author PDF](https://www.eng.yale.edu/grablab/pubs/Feix_Interface2015.pdf) is frozen as `Feix-2015-Estimating-thumb-index-precision-grip.pdf`. Supplementary Table 1 is PDF page 17 (printed supplement page 5). Its 45 model rows are captured in order with six printed columns. The final fossil *Au. afarensis* Human model label spans two PDF text lines; those lines are joined in the snapshot. The source leaves the Group cell blank for *D. madagascariensis*, and the snapshot does too.

The table reports peak workspace position, relative object size R, and real object size R (mm), with N as printed. The caption does not give a unit for peak workspace. The seven fossil rows include separate Human and *Pan* model assumptions for *Au. sediba* and *Au. afarensis*. These are alternative configurations, not independent fossils. The 45 rows are model outputs, not the raw specimen-length rows in Supplementary Table 2; their Ns should not be forced to match Table S2. The unusually small printed fossil real-object values (2.1–3 mm) were retained as printed rather than inferred to be a unit error.

Printed names remain in `species_as_published`. Collection-scoped `_keys/General/species_key.csv` supplies a separate taxon anchor; historical *Pongo pygmaeus* remains `Pongo sp.` until its specimens are identified. Apparent printed spellings `Alouatta semiculus`, `Eulemur mangoz`, and `Galago senegalesis` are preserved. Model variants remain separate in analysis output.

## Reproduction and checks

From repository root, run `Rscript --vanilla Feix_etal_2015/Feix_etal_2015_SupplementaryTable1_snapshot.R`, then `Rscript --vanilla Feix_etal_2015/Feix_etal_2015_SupplementaryTable1.R`. The first script captures the printed PDF text table only; the second reads its frozen snapshot and writes a 45-row analysis CSV and registry-coded public TSV. The snapshot was checked against the rendered source page by Codex on 2026-11-23, including the wrapped fossil label and bottom Lorisiformes block. Structural checks require 45 rows, seven fossil rows, four explicit model variants, and positive numerical values. No printed totals permit an independent arithmetic check. Human visual signoff remains pending. The registry row is in `__ReadMeAddON.xlsx` while the main registry is occupied.

This item is a printed table, so no figure replot applies. Do not pool its model outputs with Supplementary Table 2 raw lengths or with later secondary reuses before checking provenance.

## Main-table discrepancy (2026-11-24)

The printed main-text Table 1 is a subset of this supplement and is now frozen separately as `Feix_etal_2015_Table1_snapshot.csv`. For *Hylobates lar*, main Table 1 prints real object size **2.20 mm**, while this supplementary Table 1 prints **22.2 mm**. Both values remain as published in their respective items. Treat them as one modeled result with an unresolved source conflict, not independent observations; clarify the correct value before merging that cell.

## Snapshot layout audit (2026-11-27)

Compared with Supplementary Table 1 on PDF page 17. The Group column is a spanning label; the old CSV repeated it on every species row. The snapshot generator now writes one label per group block and leaves the remaining group cells blank. The R reader fills groups for analysis. Row 37, `D. madagascariensis`, visibly falls within Lemuriformes in the source; its previously missing group and observation level are corrected in the analysis CSV. Regenerating the snapshot with `Rscript --vanilla Feix_etal_2015/Feix_etal_2015_SupplementaryTable1_snapshot.R` and the analysis CSV with `Rscript --vanilla Feix_etal_2015/Feix_etal_2015_SupplementaryTable1.R` succeeded. The only analysis CSV difference is row 37 group/observation level; human visual signoff remains separate.
