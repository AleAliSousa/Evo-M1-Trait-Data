# Johnson et al. 2016 - Table 1 felid cortical-layer thickness

## Source

Johnson, C. B., Schall, M., Tennison, M. E., Garcia, M. E., Shea-Shumsky, N. B., Raghanti,
M. A., Lewandowski, A. H., Bertelsen, M. F., Waller, L. C., Walsh, T., Roberts, J. F., Hof,
P. R., Sherwood, C. C., Manger, P. R., & Jacobs, B. (2016). Neocortical neuronal morphology
in the Siberian tiger (*Panthera tigris altaica*) and the clouded leopard (*Neofelis nebulosa*).
*Journal of Comparative Neurology*, 524, 3641-3665. DOI `10.1002/cne.24022`.

The openly available Colorado College author copy was downloaded from
`https://www.coloradocollege.edu/dotAsset/17493d76-5085-4a01-a757-d992278a9eaf.pdf` after the
EndNote database was checked and found not to contain the record or attachment. SHA-256:
`1bb9ba961eeac7a4f02836b4db6c4fa5ec7fee449e6fa55f798aac5ec84131f8`.

## Build

- Frozen source: `Johnson_etal_2016_Table1_snapshot.csv`, visually checked against Table 1 on PDF page 5.
- Builder: `Johnson_etal_2016_Table1.R`.
- Output: 42 long rows for prefrontal, primary motor and primary visual cortex in both felids.
- Sampling: mean +/- SD across 10 sampling locations in each region.

The Siberian tiger is one 12-year-old female; the clouded-leopard values summarize two females aged
20 and 28 years. This distinction is retained in `observation_level` and `n_specimens`. M1 layer IV
is explicitly absent in both species.

## Checks

All printed values and SDs were checked against the rendered table. Layer sums and printed totals are
reported separately in merge QA because independently rounded means differ by as much as 10 um in
some non-M1 regions.
