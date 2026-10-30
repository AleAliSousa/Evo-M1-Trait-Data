# Iwaniuk_etal_2000_Table1

## Source
Iwaniuk, A. N., Pellis, S. M., & Whishaw, I. Q. (2000). The relative importance of body size,
phylogeny, locomotion, and diet in the evolution of forelimb dexterity in fissiped carnivores
(Carnivora). *Canadian Journal of Zoology*, 78(7), 1110–1125. https://doi.org/10.1139/z00-023

Table 1 (printed pp. 1112–1113, landscape): N, proximal/distal/total forepaw dexterity, body
mass (BW), arboreality (Arb), diet, and references for the arboreality and diet data — 45 species
in 9 families. PDF: `Iwaniuk-2000-The relative importance of body s.PDF`.

## Pipeline
| file | role |
|---|---|
| `Iwaniuk_etal_2000_Table1_snapshot.csv` | frozen source: spanning "Forepaw dexterity" header row, printed headers (with maxima "(8)", "(13)", "(21)"), Family rows, 45 species rows in printed order, `*` marks, table Note and `*` footnote |
| `Iwaniuk_etal_2000_Table1.R` | positional read → CSV + public TSV; `table_checks` |
| `Iwaniuk_etal_2000_Table1.csv` | one row per species (45) |
| `reference_tables/Iwaniuk_etal_2000_Table1_references.csv` | 99 rows: 96 works cited in the References column + 3 body-mass sources named in the Note |
| `reference_tables/Iwaniuk_etal_2000_Table1_definitions.csv` | data dictionary |
| `reference_tables/Iwaniuk_etal_2000_errata.csv` | 1 proposed erratum (Panthera pardus total) |
| `Iwaniuk_etal_2000_Table1_registry_row.xlsx` | registry row for the owner |
| public TSV | `__Public/comparative-data/10.1139%2Fz00-023_Table1.tsv` |

## Reader / provenance
Built 2026-10-28 by an AI assistant from the born-digital PDF text layer by word coordinates
(rotation-corrected, column-binned, wrapped reference cells re-joined; page furniture in the
margins excluded). The plain text stream of p. 1112 is scrambled (e.g. it attaches "42.3 0 2 Mills
and Mills 1978" to the red panda), so it was not used. Every row was compared with 2.5× renders of
both pages; the Proximal + Distal = Total check confirms the column assignment.

## Data role — both
N and the three dexterity scores are the authors' own observations (filmed captive animals) →
primary. BW (Nowak 1991 and others, per Note), Arb and Diet are compiled from the literature in the
References column → secondary. `data_role = both` on every row; the definitions file marks each
column's role.

## References (secondary columns)
`references` keeps the printed cell; `ref_keys` splits on "; " and expands author-elided years
("Rasa 1973, 1977" → "Rasa 1973; Rasa 1977"; "Laborde 1986a, 1986b") so each key joins 1:1 on
`references.csv$ref_key`. Kept verbatim, not corrected:
- **Hornocker 1970** (Puma concolor row) is cited but absent: the bibliography lists only
  Hornocker, M.G. 1972 (and Hornocker & Hash 1980).
- **C. Long, personal communication** (Gulo gulo row) — Acknowledgements thank Clinton Long.
- The Note spells "Prionailuurs rubiginosa" (row prints "Prionailurus rubiginosa").

## Units
BW kg → g (× 1000). Scores are ordinal integers; `diet_estimated` = printed `*`.

## Species
Printed names kept (`species_as_published`); harmonised via `_keys/General/species_key.csv`
(source_publication `Iwaniuk_etal_2000`): e.g. Canis familiaris → Canis lupus familiaris,
Fennecus zerda → Vulpes zerda, Hyaena brunnea → Parahyaena brunnea, Felis silvestris ornatus →
Felis silvestris (subspecies_assign), Aonyx cinerea → Aonyx cinereus.

## Table checks
Rule: Proximal + Distal = Total (integer scores, tolerance 0). Actual R run 2026-10-28: 44 pass,
1 mismatch — **Panthera pardus** prints 3 + 7 but Total **13** (difference −3; confirmed on the
page image). Kept as printed; filed as proposed `publication_error` erratum.

## Errata
<!-- errata:begin -->
## Errata

Generated from `reference_tables/Iwaniuk_etal_2000_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Iwaniuk_etal_2000-E001 | dexterity_total | Table 1, p. 1112, row "Panthera pardus" (Leopard), column "Total (21)" | 13 | 13 | publication_error | 10 | proposed | Printed Proximal (8) = 3 and Distal (13) = 7 on the same row (page image p. 1112); Total is defined as proximal + distal (Fig. 1 taxonomy; all other 44 rows satisfy it). Which cell is wrong (3, 7 or 13) cannot be decided from the paper. | CSV keeps the printed 13; proposed_value assumes the component scores are right. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

## Other file in this folder (not part of this item)
`1-s2.0-S0079610725000185-main.pdf` is **Morelli, A. M., Saada, A., & Scholkmann, F. (2025).
Myelin: A possible proton capacitor for energy storage during sleep and energy supply during
wakefulness. *Progress in Biophysics and Molecular Biology*, 196, 91–101.
https://doi.org/10.1016/j.pbiomolbio.2025.03.001** — unrelated to Iwaniuk et al. (2000) (it does not
cite it). Its Fig. 5 plots white-matter volume vs sleep time for 23 mammals (sleep times from E. H.
Chudler's tabulation and Hozer et al. 2019; white-matter volumes from Zhang & Sejnowski 2000 and
Mota et al. 2019 — figure only, no table). Left in place (not deleted); it looks
misfiled and probably belongs in its own folder (e.g. `Morelli_etal_2025`) — owner decision.
