# Glendenning & Masterton (1998) — Table 2

Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. *Brain, Behavior and Evolution*, 51(2), 59–89. https://doi.org/10.1159/000006530

**Item:** `Glendenning_Masterton_1998_Table2` · **Item encoded (derived):** `10.1159%2F000006530_Table2` · **Public TSV:** `__Public/comparative-data/10.1159%2F000006530_Table2.tsv`

**Table 2.** Percentage size of each nucleus relative to the size of the total subcortical auditory system for each animal (p. 70): 53 animals × 10 nuclei, plus printed Average / Standard deviation / % variation rows.

## Data role — primary, derived within the paper

Each cell is 100 × nucleus / Total from Table 1 (verified: every one of the 530 cells is within 3% of 100 × Table 1 nucleus / Table 1 Total). Not reused from another paper, but derived — prefer recomputing from Table 1. The three summary rows remain in the snapshot only; the note describes them as antilogs of log means/SDs, and the printed Average is not reproducible from the printed rows as a geometric mean, so they are not checked.

## Table checks (actual R run)

The note states "each row sums to 100%". Tolerance = half a unit of each cell plus the rounding propagated from Table 1's printed Total and nuclei. **49 pass, 4 mismatch** — exactly the four Table 1 rows above: Chinchilla 80.87%, Mouse 100.87%, Mouse, spiny 111.80%, Opossum, didelphis 84.28% (inherited; errata rows reference the Table 1 errata).

## Registry status

No `__ReadMe.xlsx` row existed for this paper. **Item encoded is derived by the house convention** — url-encoded DOI + `_` + compacted Item number: `10.1159/000006530` → `10.1159%2F000006530`, Item number "Table 2" → `10.1159%2F000006530_Table2`. The build script uses that derived name and, once the owner pastes `Glendenning_Masterton_1998_Table2_registry_row.xlsx` into Sheet1, stops if the registry's Item encoded differs (the registry is the authority). `__ReadMe.xlsx` was not edited.

## Pipeline (reader named)

1. **Source:** `Glendenning-1998-Comparative Morphometry of Ma.pdf` (born-digital Karger PDF).
2. **Snapshot:** `Glendenning_Masterton_1998_Table2_snapshot.csv`, written by `Glendenning_Masterton_1998_extract_snapshot.py` (conda env `python`) from the text layer by word coordinates — no value typed by hand; caption and footnotes captured verbatim to `reference_tables/Glendenning_Masterton_1998_Table2_footnotes.csv`. The script asserts the table's structure before writing and refuses to overwrite a differing frozen copy; a second run reports "unchanged". Extraction by an AI assistant on 2026-10-28, checked against page renders (p. 70).
3. **Data readable:** `Glendenning_Masterton_1998_Table2.R` — run 2026-10-28 with `Rscript --vanilla` in env `evom1-r` (R 4.5.3): completed, 53 rows × 16 columns.
4. **Online database:** public TSV `__Public/comparative-data/10.1159%2F000006530_Table2.tsv` from the same script.

Species: printed names kept; harmonised through `_keys/General/species_key.csv` (`source_publication = Glendenning_Masterton_1998`; the script stops if the filter returns zero rows). Key notes record the printed-name fixes (*Hydrochaeris* → *Hydrochoerus*, *Petterus fulvus* → *Eulemur fulvus*, *Llama peruana* → *Lama glama*, *Aplodotia* [sic] → *Aplodontia*, *Sciurius* [sic] → *Sciurus*, *Perodorcas* → *Petrogale*, *Dromiciops australis* → *D. gliroides*, *Mustela vison* → *Neogale vison*, *Cercopithecus aethiops* → *Chlorocebus aethiops*, *Marmosa elegans* → *Thylamys elegans*). **Flag:** "Rat, albino" is printed as *Rattus rattus*; kept verbatim (laboratory albino rats are normally *R. norvegicus*) — curator to decide before pooling.

## Files

| file | what it is |
|---|---|
| `Glendenning_Masterton_1998_Table2_snapshot.csv` | frozen snapshot (printed layout) |
| `Glendenning_Masterton_1998_extract_snapshot.py` | text-layer extraction of all seven table snapshots |
| `Glendenning_Masterton_1998_Table2.R` | snapshot → analysis CSV + public TSV |
| `Glendenning_Masterton_1998_Table2.csv` | analysis data |
| `reference_tables/Glendenning_Masterton_1998_Table2_definitions.csv` | data dictionary |
| `reference_tables/Glendenning_Masterton_1998_Table2_footnotes.csv` | caption and footnotes, verbatim |
| `Glendenning_Masterton_1998_Table2_registry_row.xlsx` | paste-ready new Sheet1 row |

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Glendenning_Masterton_1998_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Glendenning_Masterton_1998-E005 | * | Table 2 p.70, row 9 Chinchilla | row sums to 80.87% |  | publication_error |  | proposed | Table 2 note: "each row sums to 100%". This row sums to 80.87% (beyond the rounding propagated from Table 1). Each cell equals 100 x Table 1 nucleus / Table 1 Total, so the discrepancy is inherited from the Table 1 row (see the Table 1 erratum for the same animal). | CSV keeps the printed percentages (rowsum100_check = mismatch). |
| Glendenning_Masterton_1998-E006 | * | Table 2 p.70, row 33 Mouse | row sums to 100.87% |  | publication_ambiguity |  | proposed | Table 2 note: "each row sums to 100%". This row sums to 100.87% (beyond the rounding propagated from Table 1). Each cell equals 100 x Table 1 nucleus / Table 1 Total, so the discrepancy is inherited from the Table 1 row (see the Table 1 erratum for the same animal). | CSV keeps the printed percentages (rowsum100_check = mismatch). |
| Glendenning_Masterton_1998-E007 | * | Table 2 p.70, row 34 Mouse, spiny | row sums to 111.80% |  | publication_error |  | proposed | Table 2 note: "each row sums to 100%". This row sums to 111.80% (beyond the rounding propagated from Table 1). Each cell equals 100 x Table 1 nucleus / Table 1 Total, so the discrepancy is inherited from the Table 1 row (see the Table 1 erratum for the same animal). | CSV keeps the printed percentages (rowsum100_check = mismatch). |
| Glendenning_Masterton_1998-E008 | * | Table 2 p.70, row 35 Opossum, didelphis | row sums to 84.28% |  | publication_error |  | proposed | Table 2 note: "each row sums to 100%". This row sums to 84.28% (beyond the rounding propagated from Table 1). Each cell equals 100 x Table 1 nucleus / Table 1 Total, so the discrepancy is inherited from the Table 1 row (see the Table 1 erratum for the same animal). | CSV keeps the printed percentages (rowsum100_check = mismatch). |

4 recorded, 4 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
