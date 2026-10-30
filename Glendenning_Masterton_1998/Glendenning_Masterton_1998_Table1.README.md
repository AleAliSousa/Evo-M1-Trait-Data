# Glendenning & Masterton (1998) — Table 1

Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. *Brain, Behavior and Evolution*, 51(2), 59–89. https://doi.org/10.1159/000006530

**Item:** `Glendenning_Masterton_1998_Table1` · **Item encoded (derived):** `10.1159%2F000006530_Table1` · **Public TSV:** `__Public/comparative-data/10.1159%2F000006530_Table1.tsv`

**Table 1.** In vitro volumes (mm³) of the 10 largest nuclei of the ascending auditory system (AVCN, PVCN, DCN, MTB, LSO, MSO, VLL, DLL, IC, MG) in 53 mammals, with body and brain weights (g) and the total of the 10 volumes (p. 62, printed rotated).

## Data role — both (volumes primary; two body weights secondary)

The volumes are this paper's own planimetric measurements, one Nissl-stained specimen per species, from five collections (Methods p. 61; `specimen_source`). **The printed volumes are unilateral** — "The left and right volumes for each nucleus were then averaged" — so the CSV keeps them as `*_unilateral_mm3` and adds `*_bilateral_mm3` = 2 × printed (combined-sides merge unit, HOWTO §6). Units: body g (as printed), brain g × 1000 → mg, volumes mm³. Shrinkage was not corrected and differs between celloidin (31 brains), paraffin (6) and frozen (16) material (pp. 61, 63).

**Secondary values:** body weights printed in parentheses (Chinchilla 580 g, Quoll 550 g) are "estimates from Nowak [1991]" (flag `body_mass_estimated_Nowak1991`); the little brown bat's body and brain weights are "courtesy of Dr. Donald Wong" (personal communication). Both are bound in `reference_tables/Glendenning_Masterton_1998_Table1_references.csv`. Brain weight is printed blank for Chinchilla and Mink.

## Table checks (actual R run)

The printed Total should equal the sum of the 10 nuclei within rounding (half a unit of each summed cell). **49 pass, 4 mismatch:**

| row | summed nuclei | printed Total | difference | tolerance |
|---|---|---|---|---|
| 9 Chinchilla | 19.510 | 24.11 | −4.600 | 0.055 |
| 33 Mouse | 2.302 | 2.28 | +0.022 | 0.010 |
| 34 Mouse, spiny | 4.460 | 3.99 | +0.470 | 0.055 |
| 35 Opossum, didelphis | 9.950 | 11.80 | −1.850 | 0.078 |

The **Chinchilla** row's ten volumes are identical, cell for cell, to row 18 Guinea pig (which sums to its own Total 19.51) — almost certainly a duplicated row. Values are kept as printed and recorded as proposed errata (`reference_tables/Glendenning_Masterton_1998_errata.csv`); do not use the Chinchilla nuclear volumes.

## Registry status

No `__ReadMe.xlsx` row existed for this paper. **Item encoded is derived by the house convention** — url-encoded DOI + `_` + compacted Item number: `10.1159/000006530` → `10.1159%2F000006530`, Item number "Table 1" → `10.1159%2F000006530_Table1`. The build script uses that derived name and, once the owner pastes `Glendenning_Masterton_1998_Table1_registry_row.xlsx` into Sheet1, stops if the registry's Item encoded differs (the registry is the authority). `__ReadMe.xlsx` was not edited.

## Pipeline (reader named)

1. **Source:** `Glendenning-1998-Comparative Morphometry of Ma.pdf` (born-digital Karger PDF).
2. **Snapshot:** `Glendenning_Masterton_1998_Table1_snapshot.csv`, written by `Glendenning_Masterton_1998_extract_snapshot.py` (conda env `python`) from the text layer by word coordinates — no value typed by hand; caption and footnotes captured verbatim to `reference_tables/Glendenning_Masterton_1998_Table1_footnotes.csv`. The script asserts the table's structure before writing and refuses to overwrite a differing frozen copy; a second run reports "unchanged". Extraction by an AI assistant on 2026-10-28, checked against page renders (p. 62).
3. **Data readable:** `Glendenning_Masterton_1998_Table1.R` — run 2026-10-28 with `Rscript --vanilla` in env `evom1-r` (R 4.5.3): completed, 53 rows × 32 columns.
4. **Online database:** public TSV `__Public/comparative-data/10.1159%2F000006530_Table1.tsv` from the same script.

Species: printed names kept; harmonised through `_keys/General/species_key.csv` (`source_publication = Glendenning_Masterton_1998`; the script stops if the filter returns zero rows). Key notes record the printed-name fixes (*Hydrochaeris* → *Hydrochoerus*, *Petterus fulvus* → *Eulemur fulvus*, *Llama peruana* → *Lama glama*, *Aplodotia* [sic] → *Aplodontia*, *Sciurius* [sic] → *Sciurus*, *Perodorcas* → *Petrogale*, *Dromiciops australis* → *D. gliroides*, *Mustela vison* → *Neogale vison*, *Cercopithecus aethiops* → *Chlorocebus aethiops*, *Marmosa elegans* → *Thylamys elegans*). **Flag:** "Rat, albino" is printed as *Rattus rattus*; kept verbatim (laboratory albino rats are normally *R. norvegicus*) — curator to decide before pooling.

## Files

| file | what it is |
|---|---|
| `Glendenning_Masterton_1998_Table1_snapshot.csv` | frozen snapshot (printed layout) |
| `Glendenning_Masterton_1998_extract_snapshot.py` | text-layer extraction of all seven table snapshots |
| `Glendenning_Masterton_1998_Table1.R` | snapshot → analysis CSV + public TSV |
| `Glendenning_Masterton_1998_Table1.csv` | analysis data |
| `reference_tables/Glendenning_Masterton_1998_Table1_definitions.csv` | data dictionary |
| `reference_tables/Glendenning_Masterton_1998_Table1_footnotes.csv` | caption and footnotes, verbatim |
| `reference_tables/Glendenning_Masterton_1998_Table1_references.csv` | Nowak [1991] and D. Wong (body/brain weight sources) |
| `Glendenning_Masterton_1998_Table1_registry_row.xlsx` | paste-ready new Sheet1 row |

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Glendenning_Masterton_1998_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Glendenning_Masterton_1998-E001 | * | Table 1 p.62, row 9 Chinchilla (nuclear volumes AVCN-MG and Total) | 0.63, 1.83, 3.06, 0.28, 0.33, 0.22, 1.10, 0.16, 7.17, 4.73; Total 24.11 |  | publication_error |  | proposed | All ten printed Chinchilla nuclear volumes are identical, cell for cell, to row 18 Guinea pig (0.63 ... 4.73), whose ten volumes sum to its printed Total 19.51; the Chinchilla Total is 24.11. The Chinchilla Brain cell is blank. Likely a duplicated Guinea-pig row with the true Chinchilla volumes lost; only the Total 24.11 may be Chinchilla-specific. | CSV keeps the printed values (flag total10_check = mismatch). Do not use Chinchilla nuclear volumes; Table 2 percentages for Chinchilla (= 100 x Guinea-pig volumes / 24.11) inherit the error. |
| Glendenning_Masterton_1998-E002 | * | Table 1 p.62, row 34 Mouse, spiny (Total) | 3.99 |  | publication_error |  | proposed | The ten printed nuclear volumes sum to 4.46 mm3 vs printed Total 3.99 (difference 0.47; rounding tolerance 0.055). Which cell is wrong cannot be determined from the paper. | CSV keeps printed values; Table 2 row inherits it (sums to 111.8%). |
| Glendenning_Masterton_1998-E003 | * | Table 1 p.62, row 35 Opossum, didelphis (Total) | 11.8 |  | publication_error |  | proposed | The ten printed nuclear volumes sum to 9.95 mm3 vs printed Total 11.8 (difference -1.85; tolerance 0.078). Which cell is wrong cannot be determined from the paper. | CSV keeps printed values; Table 2 row inherits it (sums to 84.3%). |
| Glendenning_Masterton_1998-E004 | * | Table 1 p.62, row 33 Mouse (Total) | 2.28 |  | publication_ambiguity |  | proposed | The ten printed nuclear volumes sum to 2.302 mm3 vs printed Total 2.28 (difference 0.022; rounding tolerance 0.010). Small but beyond the printed precision. | CSV keeps printed values. |

4 recorded, 4 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
