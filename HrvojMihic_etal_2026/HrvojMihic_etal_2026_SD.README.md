# HrvojMihic et al. 2026 — brain weight across the adult lifespan in great apes

## What this item is
Hrvoj-Mihic, Stimpson, Cree, Hillegas, Wicinski, Preuss, Hof, Raghanti, Edler, Guevara, Hopkins, &
Sherwood (2026, PNAS, doi:10.1073/pnas.2609260123) compile **individual-level brain weight**
(postmortem necropsy) for adult gorillas, orangutans, bonobos, and chimpanzees, with sex and age at
death, to characterize brain-weight change across the adult lifespan. Built from the paper's two
digital-native supplementary Excel files, copy-renamed byte-identical as the frozen snapshots
(`HrvojMihic_etal_2026_SD1_snapshot.xlsx`, `..._SD2_snapshot.xlsx`) — no transcription.

## Dataset S1 and S2
- **Dataset S1** (`pnas.2609260123.sd01.xlsx`): 601 individuals across 8 sheets (one per
  species x sex): Code, Brain weight (g), Sex, Age (years). This is the base table.
- **Dataset S2** (`pnas.2609260123.sd02.xlsx`): a **verified full subset** of Dataset S1's
  chimpanzee codes (146/146 female, 130/130 male matched) restricted to chimpanzees aged 15+,
  adding **Body weight (kg)**. Joined onto Dataset S1 as an extra column
  (`body_weight_g`) rather than appended as new rows — Dataset S2 contributes no individuals
  beyond what Dataset S1 already has.

## Duplicate-code anomaly in Dataset S2 (source data, not a transcription artifact)
Dataset S2 prints **two distinct records** under the same code for two chimpanzees (`PTM153`,
`PTF31`) — different brain weight and age under the same code. For these two codes only, the row
whose `brain_weight_g` (rounded to 1 decimal, to avoid float-precision mismatches) is closest to
Dataset S1's single authoritative value for that code is kept; the other Dataset S2 row is dropped
from the join. All other codes (a clean 1:1 match) join directly on `code`. The result: 276 of 601
individuals (all 146 female + all 130 male Dataset-S2 codes, verified as a full subset of Dataset
S1's chimpanzee codes) carry a `body_weight_g` value. See
`reference_tables/HrvojMihic_etal_2026_SD_definitions.csv` (`QA:duplicate_code` row).

## Species
Species is not a printed column — it is implicit in the sheet name (one sheet per species x sex).
`species_as_published` carries the common name as printed in the sheet label (Gorilla / Orangutan
/ Bonobo / Chimpanzee); `interpreted_taxon` is the curator's binomial for that common name,
informational only. Per `_keys/SPECIES_NAMING.md` v1, species identity is **resolved at the merge
step**, not here — four rows were added to `_keys/General/species_key.csv`
(`source_publication = HrvojMihic_etal_2026`) for `resolve_species()` to pick up.

## Units
Brain weight converted g -> mg; body weight converted kg -> g (project units).

## Data role
`data_role = primary` throughout — this is the paper's own measured necropsy data.

## Source
`pnas.2609260123.sd01.xlsx` (Dataset S1) and `pnas.2609260123.sd02.xlsx` (Dataset S2), supplementary
to Hrvoj-Mihic et al. (2026), PNAS 123(41):e2609260123.
