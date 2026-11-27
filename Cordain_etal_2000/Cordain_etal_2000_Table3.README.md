# Cordain et al. 2000 Table 3

Source: `Cordain-2000-Plant-animal subsistence ratios a.pdf`, Relative contribution of plant-food type to the wild-plant-food database,
printed p. 686 (PDF p. 5). The manual snapshot preserves the printed
row order and all source cells. Run `Rscript Cordain_etal_2000/Cordain_etal_2000_Table3.R`
from the repo root to rebuild the analysis CSV. The PDF page and snapshot
were compared on 2026-11-26; no human visual signoff is claimed.

The 12 printed percentages sum to 100.0%, but printed counts sum to 754
while the table footnote says n = 768. The Roots row prints n = 51 and 8.5%,
which is inconsistent with 51/768 (6.64%). Those cells are retained as
printed and a check flag marks the mismatch; no count or percentage was
corrected. The food-type categories are not species observations. This is a
secondary wild-food database summary, not direct dietary intake data.

Main-registry registration and public TSV remain pending; see
`Cordain_etal_2000_Table3_registry_row.xlsx`.
