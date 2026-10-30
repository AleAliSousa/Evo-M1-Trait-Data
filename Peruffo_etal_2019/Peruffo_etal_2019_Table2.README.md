# Peruffo et al. 2019 - Table 2 sheep M1 layer thickness

## Source

Peruffo, A., Corain, L., Bombardi, C., Centelleghe, C., Grisan, E., Graic, J.-M., Bontempi,
P., Grandis, A., & Cozzi, B. (2019). The motor cortex of the sheep: laminar organization,
projections and diffusion tensor imaging of the intracranial pyramidal and extrapyramidal tracts.
*Brain Structure and Function*, 224, 1933-1946. DOI `10.1007/s00429-019-01885-x`.

The open publisher PDF was downloaded from
`https://link.springer.com/content/pdf/10.1007/s00429-019-01885-x.pdf` after the EndNote database was
checked and found not to contain the record or attachment. SHA-256:
`91f302cb96c5c8898fccc378b50dfe5dd9d6070ac7e4c9c4413ded05e7110b12`.

## Build

- Frozen source: `Peruffo_etal_2019_Table2_snapshot.csv`, retaining the six sheep and printed Average row.
- Builder: `Peruffo_etal_2019_Table2.R`.
- Output: absolute thickness in um and printed percentages standardized to proportions.
- Granularity: six individual adult sheep plus the paper's six-animal mean.

The sampled region is the motor cortex controlling distal forelimb movements. Four observers
identified five layers; layer IV is virtually absent. The build adds an explicit nonnumeric layer-IV
absence row for every individual and the mean. It does not turn absence into zero thickness.

## Checks

The rendered Table 2 was visually checked. All six individuals, the Average row, absolute values and
percentages are retained. The printed Average is not a simple arithmetic mean of all six displayed
subject rows, and several percentages are not exactly the corresponding displayed thickness divided
by displayed total. These quantities were probably averaged at a lower measurement level. The merge
therefore preserves them independently and writes two reconciliation files. `merge_default` selects
the published Average row while keeping individual rows available, preventing double counting.
