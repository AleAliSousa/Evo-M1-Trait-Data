# Ferrell_etal_2026_Table1

Ferrell, A., Busch, S. E., Hillegas, M., Sherwood, C. C., & Hansel, C. (2026). Cerebellar Purkinje cells change dendritic architecture during primate evolution. *bioRxiv* (preprint, not peer reviewed; posted 8 June 2026; CC-BY-NC-ND 4.0). https://doi.org/10.64898/2026.06.07.728033

## What this item is
PDF p. 15, "Table 1: Attributes of the specimens used in this study". The main text (p. 4) and Methods (p. 20) call the same table "Table S1". It has 25 rows, one per primate specimen: Species, Common Name, Sex, Age (yrs), Rearing. **Data role: primary.** These are the authors' own specimens, the tissue behind every Purkinje-cell (PC) morphology value in the paper.

## Snapshot
`Ferrell_etal_2026_Table1_snapshot.csv` is a hand transcription of the printed table, in the same column order, row order and headings. It was checked cell by cell against the 130-dpi page render. The sequence of non-blank cells is identical to the PDF text layer. Blanks are kept as printed: Rearing is blank in 16 rows; Sex and Age are blank for the second *Callithrix jacchus*; Age is blank for the third *Macaca mulatta*. Wrapped cells are joined with one space (e.g. `Other - Captive Birth`).

## Build
`Ferrell_etal_2026_Table1.R` (run: `LANG=en_US.UTF-8 Rscript --vanilla Ferrell_etal_2026/Ferrell_etal_2026_Table1.R`) does four things:
- reads the snapshot;
- harmonises species with `_keys/General/species_key.csv` rows for `Ferrell_etal_2026` (13 rows; it stops if there are none or any printed name is unkeyed);
- converts Age to numeric years (blank → NA, never 0) and writes `Ferrell_etal_2026_Table1.csv`;
- writes the public TSV `__Public/comparative-data/<Item encoded>.tsv` **only once the registry row exists**. The item is not yet in Sheet1. Paste `Ferrell_etal_2026_Table1_registry_row.xlsx` and rerun. The expected Item encoded is `10.64898%2F2026.06.07.728033_Table1`; the owner should confirm it after `file_list.R`.

Definitions: `reference_tables/Ferrell_etal_2026_Table1_definitions.csv`.

## Printed-count discrepancies (reported, not corrected)
- Text p. 4 says tissue came "from 26 individuals across 11 species". Table 1 prints 25 primate rows and 13 binomials (12 non-human + *Homo sapiens*, with *Pongo pygmaeus* and *P. abelii* separate).
- Results give clade sample sizes "n=3,3,5,4,9,3 specimens/clade" for Mus, Plat, Cerco, Hylo, NH-Hom, Hsap. Table 1 gives platyrrhines 4 (*C. jacchus* ×2, *C. geoffroyi*, *Ateles geoffroyi*); the other primate clades agree (5, 4, 9, 3). The 3 mice are not in Table 1.
- `Nomascus leurogenys` is printed for *N. leucogenys*. It is keyed as a spelling variant and the printed form is kept.

## Not built (documented)
- The PC morphology results (Figures 1–6, S1–S10: subtype proportions, dendrite angles and distances, morphospace, SHAP, allometry) are plotted at cell or clade level. No numeric table or deposited dataset is cited in the preprint, which has no data-availability statement in the PDF. No supplementary data file was found with the PDF; the bioRxiv supplement page was not checked (no network access requested). Digitising cell-level violin and scatter plots would not give reliable per-species values, so no figure item was made. Clade percentages stated in the text (e.g. Poly PCs "~5%" in monkeys, "~30%" in non-human apes, "~55%" in humans) are approximate prose, not a table.
- Species brain and body masses used for allometry were "compiled from numerous sources" (refs 104–110). They are not tabulated in the preprint.

Assistant transcription; no human visual sign-off claimed.
