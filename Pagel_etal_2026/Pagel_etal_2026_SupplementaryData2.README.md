# Pagel_etal_2026_SupplementaryData2

## Source

Pagel, M., O'Donovan, C., & Meade, A. (2026). *Convergence in the size and frequency of
macroevolutionary peak-shifts on the adaptive landscape in vertebrates.* Nat Commun 17, 11208.
https://doi.org/10.1038/s41467-026-78289-z. Supplementary Data 2 ("Ecology and Thermoregulation"),
journal file `41467_2026_78289_MOESM6_ESM.xlsx` (sheets `Data`, `References`). Expected `__ReadMe.xlsx`
Item name `Pagel_etal_2026_SupplementaryData2`, Item encoded `10.1038%2Fs41467-026-78289-z_SupplementaryData2`.

21,374 vertebrate species (Mammals 3,399; Birds 6,404; Reptiles 3,917; Fish 5,219; Amphibians 2,435), each with
dominant ecology (Terrestrial 8,772; Volant 7,033; Aquatic 5,536; Semi-aquatic 33), metabolism
(Ectothermic / Endothermic) and the reference for the ecology call.

## Files

| Path | Role |
|---|---|
| `41467_2026_78289_MOESM6_ESM.xlsx` | Untouched journal download (provenance). |
| `Pagel_etal_2026_SupplementaryData2_snapshot.xlsx` | **Snapshot**: byte-identical copy (verified with cmp) of the download; digital-native, so not transcribed. |
| `Pagel-2026-Convergence in the size and frequen.pdf` | The paper. |
| `Pagel_etal_2026_SupplementaryData2.R` | Snapshot -> CSV, references lookup, public TSV. |
| `Pagel_etal_2026_SupplementaryData2.csv` | Analysis CSV, one row per species. |
| `reference_tables/Pagel_etal_2026_SupplementaryData2_definitions.csv` | Data dictionary. |
| `reference_tables/Pagel_etal_2026_SupplementaryData2_references.csv` | The 35 cited works (`ref_key`, `cited_in_column`, `citation`, `note`). |
| `Pagel_etal_2026_SupplementaryData2_registry_row.xlsx` | Registry row to paste into `__ReadMe.xlsx`. |

## Interpretation notes

- **Ecology is mostly a Class default.** 20,294 of 21,374 rows (95%) read "Base ecology for Class" in
  Reference (`ecology_basis = class_default`): e.g. all Fish = Aquatic, almost all Birds = Volant. Only 1,080 rows
  carry a species-specific citation. Treat class_default calls as lower confidence when filtering by ecology.
- **Cached formulas.** `Ecology` is a VLOOKUP into an external workbook; the script reads the cached values.
- **Whitespace.** 47 amphibian cells are "Aquatic " (trailing space) and the header is "Species "; squished.
- **Categories.** Terrestrial / Volant / Aquatic / Semi-aquatic (Semi-aquatic only in Mammals). These can
  overlap with other ecology sources in `__merging_body_ecology`; map them before wiring to the app.
- **Species names** are as printed; not reconciled to any species key.
- The live registry now supplies `10.1038%2Fs41467-026-78289-z_SupplementaryData2`. The R script was rerun on 2026-11-12 and wrote the 21,374-row public TSV. CSV/TSV cells match and the dataset-item validator returned eight passes and one optional errata skip. Human visual review remains pending; the registry progress text has not been updated here.
