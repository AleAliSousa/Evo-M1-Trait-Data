# Stephan_etal_1984_Table1

## Source
Stephan, H., Baron, G., & Frahm, H. D. (1984). Comparative size of brains and brain components. (J. Hirnforsch.) Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A6481154_Table1.tsv`.

**Visual pathway measurements, including revised lateral geniculate nucleus (CGL) volumes.** Table 1 also prints eye surface area, optic nerve area, chiasma area, and optic tract volume. Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Stephan_etal_1984_Table1_snapshot.xlsx` (sheets `Page386` and `Page387`), `Stephan_etal_1984_Table1.R` → `Stephan_etal_1984_Table1.csv` (+ TSV), `reference_tables/Stephan_etal_1984_Table1_species_lookup.csv`, `reference_tables/Stephan_etal_1984_Table1_definitions.csv`.

Structures: Corpus geniculatum laterale.

## Preparation → `Stephan_etal_1984_Table1.csv`
The snapshot sketches printed Table 1 across PDF pages 2–3 (printed pages 386–387). It has the 89 printed species rows in source order, group headings, repeated header tiers, and all eleven columns in printed order: HSE and its origin and sample size, NOA and its origin and sample size, CH II and its sample size, TRO, CGL, and its sample size. It retains the printed `+` and `*` marks. The context columns were extracted from the PDF text layer, checked against the rendered pages, and obvious OCR errors corrected. Every CGL value and sample size used by the analysis was checked against the prior audited snapshot.

The printed table has 55 filled CGL cells. The existing analysis selects 53; codes 3289 (*Cebuella pygmaea*) and 3306 (*Saguinus midas tamarin*) are present in the corrected snapshot but remain outside the established analysis output. The R reader selects those 53 codes through the item lookup and applies established analysis names and order.

Run `Rscript --vanilla Stephan_etal_1984/Stephan_etal_1984_Table1.R` from the repository root. Its 53-row analysis CSV was compared cell for cell with the previous version and is unchanged; the public TSV is unchanged.

## Note
The previous snapshot had only four curated columns and omitted 36 printed species rows. The corrected layout was checked against both rendered source pages. Context cells from the OCR layer still need a human visual review; human signoff was not set. Used in `__merging_volumes` (Tier 1, Stephan collection).
