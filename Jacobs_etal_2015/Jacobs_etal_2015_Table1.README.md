# Jacobs et al. 2015 - Table 1 cortical-layer thickness

## Source

Jacobs, B., Harland, T., Kennedy, D., Schall, M., Wicinski, B., Butti, C., Hof, P. R.,
Sherwood, C. C., & Manger, P. R. (2015). The neocortex of cetartiodactyls. II. Neuronal
morphology of the visual and motor cortices in the giraffe (*Giraffa camelopardalis*).
*Brain Structure and Function*, 220, 2851-2872. DOI `10.1007/s00429-014-0830-9`.

The PDF came from the user's EndNote library and was already present in this folder. SHA-256:
`0c2fd8152532159af9bfb5afa04ac2633fbfcfa0f599a29cb9f19f93c579983f`.

## Build

- Frozen source: `Jacobs_etal_2015_Table1_snapshot.csv`, transcribed and visually checked against
  Table 1 on PDF page 6.
- Builder: `Jacobs_etal_2015_Table1.R`.
- Analysis output: `Jacobs_etal_2015_Table1.csv` plus the DOI-named public TSV.
- Granularity: species-region summary; three subadult males, 2-4 years old.
- Sampling: layer measurements were averaged across 10 Nissl-stained sections per region.

The analysis table is long: one row per region x layer/total. Layer IV in M1 is an explicit
`layer_status = absent` row with no numerical thickness. M1 and V1 remain separate.

## Checks

The six M1 rows plus total reproduce Table 1 exactly; the five present M1 layers sum to the printed
total of 1,591 um. The existing `__ReadMe.xlsx` row for `Jacobs_etal_2015_Table1` supplies the public
TSV identifier.
