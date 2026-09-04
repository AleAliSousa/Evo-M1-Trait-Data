# Jorstad et al. 2023 dataset build

Publication key: `10.1126%2Fscience.adf6812`  
DOI: 10.1126/science.adf6812

## Dataset-item decision
Four separate items were created because Table S1 is a subclass-definition table and the three Table S5 worksheets represent distinct result structures and measurement roles:

1. Table S1 subclass metadata
2. Table S5 MERFISH metrics
3. Table S5 snRNA-seq counts and subclass proportions
4. Table S5 snRNA-seq E:I ratios

Combining these would mix metadata, counts, proportions, percentages, and ratios with different denominators and keys.

## Data classification
- Table S1: primary publication metadata/definitions.
- Table S5 `MERFISH`: reported derived metrics from primary spatial-transcriptomic measurements.
- Table S5 `snRNA_prop`: primary subclass counts and derived within-area subclass proportions.
- Table S5 `snRNA_EI`: reported derived ratios from primary layer-dissected snRNA-seq counts.
- Secondary data: none identified in the supplied digital tables. The article cites prior work for context, but these rows do not carry secondary-source citations.

## Review flags
- The article states Table S5 contains subclass proportions and E:I ratios, and the supplied workbook provides the values.
- The exact denominator semantics for each MERFISH metric should be retained from the publication/supplement legend when the complete supplementary legend becomes available.
- One MERFISH donor-area combination is blank in the supplied worksheet and remains missing.
- No values were transcribed from plots or estimated.
- `__ReadMe.xlsx` was not modified. Use `Jorstad_etal_2023_registry_rows_for_review.csv`.
