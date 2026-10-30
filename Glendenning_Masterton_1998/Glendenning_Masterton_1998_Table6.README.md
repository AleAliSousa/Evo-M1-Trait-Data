# Glendenning & Masterton (1998) — Table 6

Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. *Brain, Behavior and Evolution*, 51(2), 59–89. https://doi.org/10.1159/000006530

**Item:** `Glendenning_Masterton_1998_Table6` · **Item encoded (derived):** `10.1159%2F000006530_Table6` · **Public TSV:** `__Public/comparative-data/10.1159%2F000006530_Table6.tsv`

**Table 6.** Animal rankings based on similarity in form of each animal's cochlear nuclei with average form of cochlear nuclei (p. 81): r for each of 53 animals, printed in alphabetical and in descending order; ranks less than 12 apart are not reliably different.

## Data role — primary, derived (from Table 3)

The snapshot keeps both printed lists side by side with the printed headers ("Alphabetical order", "r", "Descending order", "r", and the unlabelled annotation column with "least deviant" / "most deviant"); 54 rows (the descending list carries the "Average similarity" row, r = 0.356). The analysis CSV has one row per animal: r, descending rank (1 = least deviant), annotation, and position relative to the average similarity.

## Table checks (actual R run)

**3 / 3 pass:** the r printed in the alphabetical list equals the r printed in the descending list for all 53 animals; the descending list is non-increasing in r; the Average similarity row sits at the position its r implies (after 31 animals).

## Registry status

No `__ReadMe.xlsx` row existed for this paper. **Item encoded is derived by the house convention** — url-encoded DOI + `_` + compacted Item number: `10.1159/000006530` → `10.1159%2F000006530`, Item number "Table 6" → `10.1159%2F000006530_Table6`. The build script uses that derived name and, once the owner pastes `Glendenning_Masterton_1998_Table6_registry_row.xlsx` into Sheet1, stops if the registry's Item encoded differs (the registry is the authority). `__ReadMe.xlsx` was not edited.

## Pipeline (reader named)

1. **Source:** `Glendenning-1998-Comparative Morphometry of Ma.pdf` (born-digital Karger PDF).
2. **Snapshot:** `Glendenning_Masterton_1998_Table6_snapshot.csv`, written by `Glendenning_Masterton_1998_extract_snapshot.py` (conda env `python`) from the text layer by word coordinates — no value typed by hand; caption and footnotes captured verbatim to `reference_tables/Glendenning_Masterton_1998_Table6_footnotes.csv`. The script asserts the table's structure before writing and refuses to overwrite a differing frozen copy; a second run reports "unchanged". Extraction by an AI assistant on 2026-10-28, checked against page renders (p. 81).
3. **Data readable:** `Glendenning_Masterton_1998_Table6.R` — run 2026-10-28 with `Rscript --vanilla` in env `evom1-r` (R 4.5.3): completed, 53 rows × 9 columns.
4. **Online database:** public TSV `__Public/comparative-data/10.1159%2F000006530_Table6.tsv` from the same script.

Species: printed names kept; harmonised through `_keys/General/species_key.csv` (`source_publication = Glendenning_Masterton_1998`; the script stops if the filter returns zero rows). Key notes record the printed-name fixes (*Hydrochaeris* → *Hydrochoerus*, *Petterus fulvus* → *Eulemur fulvus*, *Llama peruana* → *Lama glama*, *Aplodotia* [sic] → *Aplodontia*, *Sciurius* [sic] → *Sciurus*, *Perodorcas* → *Petrogale*, *Dromiciops australis* → *D. gliroides*, *Mustela vison* → *Neogale vison*, *Cercopithecus aethiops* → *Chlorocebus aethiops*, *Marmosa elegans* → *Thylamys elegans*). **Flag:** "Rat, albino" is printed as *Rattus rattus*; kept verbatim (laboratory albino rats are normally *R. norvegicus*) — curator to decide before pooling.

## Files

| file | what it is |
|---|---|
| `Glendenning_Masterton_1998_Table6_snapshot.csv` | frozen snapshot (printed layout) |
| `Glendenning_Masterton_1998_extract_snapshot.py` | text-layer extraction of all seven table snapshots |
| `Glendenning_Masterton_1998_Table6.R` | snapshot → analysis CSV + public TSV |
| `Glendenning_Masterton_1998_Table6.csv` | analysis data |
| `reference_tables/Glendenning_Masterton_1998_Table6_definitions.csv` | data dictionary |
| `reference_tables/Glendenning_Masterton_1998_Table6_footnotes.csv` | caption and footnotes, verbatim |
| `Glendenning_Masterton_1998_Table6_registry_row.xlsx` | paste-ready new Sheet1 row |

<!-- errata:begin -->
<!-- errata:end -->
