# Melchionna et al. 2020 brain-shape DATA

Source: Melchionna et al. (2020), *From Smart Apes to Human Brain Boxes*,
DOI `10.3389/feart.2020.00273`. The untouched public Zenodo source files are
`DATA.rda` (record `10.5281/zenodo.3931032`, MD5
`b1547ff9cce7d6bee22fc6d4f8b389f2`) and the authors' `script.R`, retained
locally as `source_script.R` (MD5 `2f35ae01a6c2ea0b9dbd4ee64034bc91`).

Run `Rscript Melchionna_etal_2020_brain_shape/Melchionna_etal_2020_brain_shape_DATA.R`
from the repo root. It reads the original RData directly and writes the
123-row analysis CSV. The `volumes` vector's order, numeric precision and
19 source codes are retained. The authors' script maps those codes to species;
the mapping is kept in `reference_tables/`. The RData also holds landmark
arrays, a tree and meshes; those are not this ECV item and have not been built.

**Limits before a merge:** the deposited vector has repeated species-code
names but no individual specimen IDs. `source_vector_index` and
`within_source_code_index` record order only; they must not be treated as
specimen identities. Neither the article nor the deposited data labels the
ECV unit explicitly, so `ECV_value_as_deposited` is left in source units and
no mm³ conversion is made. `Species` is the authors' analysis label, not a
taxonomically revised acceptance. A specimen crosswalk, unit confirmation and
overlap audit against existing ECV values are required before wiring.

The archive is born-digital and publicly downloadable; there is no derived
snapshot or human transcription. Source file and MD5 were checked on
2026-11-26. Main-registry registration and public TSV are pending; proposed
row: `Melchionna_etal_2020_brain_shape_DATA_registry_row.xlsx`.

**2026-11-26 completion:** The main registry now distinguishes this brain-shape
paper from Melchionna et al.'s other 2020 paper. Running
`Rscript --vanilla Melchionna_etal_2020_brain_shape/Melchionna_etal_2020_brain_shape_DATA.R`
wrote the public `10.3389%2Ffeart.2020.00273_DATA.tsv`; its 123 parsed rows
match the item CSV. The unit, specimen, and overlap limitations above still
govern merger.
