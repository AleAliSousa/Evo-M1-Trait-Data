# Jacobs et al. 2016 - Table 1 newborn cortical-layer thickness

## Source

Jacobs, B., Lee, L., Schall, M., Raghanti, M. A., Lewandowski, A. H., Kottwitz, J. J.,
Roberts, J. F., Hof, P. R., & Sherwood, C. C. (2016). Neocortical neuronal morphology in
the newborn giraffe (*Giraffa camelopardalis tippelskirchi*) and African elephant
(*Loxodonta africana*). *Journal of Comparative Neurology*, 524, 257-287.
DOI `10.1002/cne.23841`.

The openly available Colorado College author copy was downloaded from
`https://www.coloradocollege.edu/dotAsset/f0f0cd15-dac1-4695-9a39-6f7eba5810f5.pdf` after the
EndNote database was checked and found not to contain the record or attachment. SHA-256:
`b675b02029316ff43f393527e04726354925061fc2e04c702ffdb7cb8273bd74`.

## Build

- Frozen source: `Jacobs_etal_2016_Table1_snapshot.csv`, visually checked against Table 1 on PDF page 4.
- Builder: `Jacobs_etal_2016_Table1.R`.
- Output: 35 long rows covering newborn giraffe M1/V1 and newborn elephant frontal/M1/occipital cortex.
- Granularity: one specimen per species, summarized across 10 sampling locations per region.

Age, sex, region and specimen-level status are explicit. Every printed dash is retained as
`layer_status = absent`; it is not converted to a numerical zero. The 1-day-old giraffe and
stillborn elephant must not be pooled with adult values without an age model.

## Checks

All Table 1 values and SDs were checked against the rendered page. Some independently averaged and
rounded layer means differ from the printed total by 1 um; the merge QA file retains those differences.
