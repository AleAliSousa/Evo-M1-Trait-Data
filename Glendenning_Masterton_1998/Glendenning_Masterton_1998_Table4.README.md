# Glendenning & Masterton (1998) — Table 4

Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. *Brain, Behavior and Evolution*, 51(2), 59–89. https://doi.org/10.1159/000006530

**Item:** `Glendenning_Masterton_1998_Table4` · **Item encoded (derived):** `10.1159%2F000006530_Table4` · **Public TSV:** `__Public/comparative-data/10.1159%2F000006530_Table4.tsv`

**Table 4. A, B.** Animal rankings of each nucleus and two nuclear clusters (pp. 72–73), based on Table 3 entries: largest at top, smallest at bottom; the printed "Average" row marks the mean; * p<0.05, ** p<0.01; ranks less than 6 apart are not reliably different.

## Data role — primary, derived ranking

Snapshot layout as printed: 12 columns (AVCN, PVCN, DCN, CN (AVCN + PVCN + DCN), MTB, LSO on p. 72; MSO, SO (MTB + LSO + MSO), VLL, DLL, IC, MG on p. 73) × 54 rows, significance marks attached to names as printed. The analysis CSV is long: one row per column × animal (12 × 53 = 636), with `rank_largest_first`, `significance_mark` / `p_value_class`, and position relative to the printed Average row.

**Structural checks** (extract script and R): every column contains each of the 53 animals exactly once plus "Average". One printed misspelling — **"Gropher, pocket"** (LSO column, p. 72) — is kept verbatim in `animal_as_printed` and mapped to Table 1's "Gopher, pocket" for the species join.

## Registry status

No `__ReadMe.xlsx` row existed for this paper. **Item encoded is derived by the house convention** — url-encoded DOI + `_` + compacted Item number: `10.1159/000006530` → `10.1159%2F000006530`, Item number "Table 4" → `10.1159%2F000006530_Table4`. The build script uses that derived name and, once the owner pastes `Glendenning_Masterton_1998_Table4_registry_row.xlsx` into Sheet1, stops if the registry's Item encoded differs (the registry is the authority). `__ReadMe.xlsx` was not edited.

## Pipeline (reader named)

1. **Source:** `Glendenning-1998-Comparative Morphometry of Ma.pdf` (born-digital Karger PDF).
2. **Snapshot:** `Glendenning_Masterton_1998_Table4_snapshot.csv`, written by `Glendenning_Masterton_1998_extract_snapshot.py` (conda env `python`) from the text layer by word coordinates — no value typed by hand; caption and footnotes captured verbatim to `reference_tables/Glendenning_Masterton_1998_Table4_footnotes.csv`. The script asserts the table's structure before writing and refuses to overwrite a differing frozen copy; a second run reports "unchanged". Extraction by an AI assistant on 2026-10-28, checked against page renders (p. 72–73).
3. **Data readable:** `Glendenning_Masterton_1998_Table4.R` — run 2026-10-28 with `Rscript --vanilla` in env `evom1-r` (R 4.5.3): completed, 636 rows × 13 columns.
4. **Online database:** public TSV `__Public/comparative-data/10.1159%2F000006530_Table4.tsv` from the same script.

Species: printed names kept; harmonised through `_keys/General/species_key.csv` (`source_publication = Glendenning_Masterton_1998`; the script stops if the filter returns zero rows). Key notes record the printed-name fixes (*Hydrochaeris* → *Hydrochoerus*, *Petterus fulvus* → *Eulemur fulvus*, *Llama peruana* → *Lama glama*, *Aplodotia* [sic] → *Aplodontia*, *Sciurius* [sic] → *Sciurus*, *Perodorcas* → *Petrogale*, *Dromiciops australis* → *D. gliroides*, *Mustela vison* → *Neogale vison*, *Cercopithecus aethiops* → *Chlorocebus aethiops*, *Marmosa elegans* → *Thylamys elegans*). **Flag:** "Rat, albino" is printed as *Rattus rattus*; kept verbatim (laboratory albino rats are normally *R. norvegicus*) — curator to decide before pooling.

## Files

| file | what it is |
|---|---|
| `Glendenning_Masterton_1998_Table4_snapshot.csv` | frozen snapshot (printed layout) |
| `Glendenning_Masterton_1998_extract_snapshot.py` | text-layer extraction of all seven table snapshots |
| `Glendenning_Masterton_1998_Table4.R` | snapshot → analysis CSV + public TSV |
| `Glendenning_Masterton_1998_Table4.csv` | analysis data |
| `reference_tables/Glendenning_Masterton_1998_Table4_definitions.csv` | data dictionary |
| `reference_tables/Glendenning_Masterton_1998_Table4_footnotes.csv` | caption and footnotes, verbatim |
| `Glendenning_Masterton_1998_Table4_registry_row.xlsx` | paste-ready new Sheet1 row |

<!-- errata:begin -->
<!-- errata:end -->
