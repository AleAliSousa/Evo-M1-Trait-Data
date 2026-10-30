# Glendenning & Masterton (1998) — Table 3

Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. *Brain, Behavior and Evolution*, 51(2), 59–89. https://doi.org/10.1159/000006530

**Item:** `Glendenning_Masterton_1998_Table3` · **Item encoded (derived):** `10.1159%2F000006530_Table3` · **Public TSV:** `__Public/comparative-data/10.1159%2F000006530_Table3.tsv`

**Table 3.** Normalized logarithmic values of entries in table 2 (p. 71): 53 animals × 10 nuclei and the clusters CN (AVCN + PVCN + DCN) and SO (MTB + LSO + MSO).

## Data role — primary, derived within the paper

Methods: log-transform, then V′ = (V − µ)/σ. Minus signs are printed as en dashes (kept in the snapshot; parsed in R). A plain z-score of log Table 2 percentages does **not** reproduce the printed values (maximum deviation 1.7 SD units, in MSO), so the exact normalisation is not stated well enough to re-derive; values are kept as printed and not cross-checked against Table 2.

## Table checks (actual R run)

Footnote: "In each column, mean is 0, standard deviation is 1". **24 / 24 pass** (column means −0.019 to +0.019; SDs 0.997–1.002; tolerance 0.03).

## Registry status

No `__ReadMe.xlsx` row existed for this paper. **Item encoded is derived by the house convention** — url-encoded DOI + `_` + compacted Item number: `10.1159/000006530` → `10.1159%2F000006530`, Item number "Table 3" → `10.1159%2F000006530_Table3`. The build script uses that derived name and, once the owner pastes `Glendenning_Masterton_1998_Table3_registry_row.xlsx` into Sheet1, stops if the registry's Item encoded differs (the registry is the authority). `__ReadMe.xlsx` was not edited.

## Pipeline (reader named)

1. **Source:** `Glendenning-1998-Comparative Morphometry of Ma.pdf` (born-digital Karger PDF).
2. **Snapshot:** `Glendenning_Masterton_1998_Table3_snapshot.csv`, written by `Glendenning_Masterton_1998_extract_snapshot.py` (conda env `python`) from the text layer by word coordinates — no value typed by hand; caption and footnotes captured verbatim to `reference_tables/Glendenning_Masterton_1998_Table3_footnotes.csv`. The script asserts the table's structure before writing and refuses to overwrite a differing frozen copy; a second run reports "unchanged". Extraction by an AI assistant on 2026-10-28, checked against page renders (p. 71).
3. **Data readable:** `Glendenning_Masterton_1998_Table3.R` — run 2026-10-28 with `Rscript --vanilla` in env `evom1-r` (R 4.5.3): completed, 53 rows × 17 columns.
4. **Online database:** public TSV `__Public/comparative-data/10.1159%2F000006530_Table3.tsv` from the same script.

Species: printed names kept; harmonised through `_keys/General/species_key.csv` (`source_publication = Glendenning_Masterton_1998`; the script stops if the filter returns zero rows). Key notes record the printed-name fixes (*Hydrochaeris* → *Hydrochoerus*, *Petterus fulvus* → *Eulemur fulvus*, *Llama peruana* → *Lama glama*, *Aplodotia* [sic] → *Aplodontia*, *Sciurius* [sic] → *Sciurus*, *Perodorcas* → *Petrogale*, *Dromiciops australis* → *D. gliroides*, *Mustela vison* → *Neogale vison*, *Cercopithecus aethiops* → *Chlorocebus aethiops*, *Marmosa elegans* → *Thylamys elegans*). **Flag:** "Rat, albino" is printed as *Rattus rattus*; kept verbatim (laboratory albino rats are normally *R. norvegicus*) — curator to decide before pooling.

## Files

| file | what it is |
|---|---|
| `Glendenning_Masterton_1998_Table3_snapshot.csv` | frozen snapshot (printed layout) |
| `Glendenning_Masterton_1998_extract_snapshot.py` | text-layer extraction of all seven table snapshots |
| `Glendenning_Masterton_1998_Table3.R` | snapshot → analysis CSV + public TSV |
| `Glendenning_Masterton_1998_Table3.csv` | analysis data |
| `reference_tables/Glendenning_Masterton_1998_Table3_definitions.csv` | data dictionary |
| `reference_tables/Glendenning_Masterton_1998_Table3_footnotes.csv` | caption and footnotes, verbatim |
| `Glendenning_Masterton_1998_Table3_registry_row.xlsx` | paste-ready new Sheet1 row |

<!-- errata:begin -->
<!-- errata:end -->
