# Baron_etal_1983_Table1

## Source

PDF: `baron_etal_1983.pdf`

Paper: Baron, G., Frahm, H. D., Bhatnagar, K. P., and Stephan, H. (1983). *Comparison of Brain Structure Volumes in Insectivora and Primates. III. Main olfactory bulb (MOB).* Journal fuer Hirnforschung 24:551-568.

Table: **Table 1. Data on total MOB (layers 1-6 + periventricular zone).** 76 species.

## Three separate concerns

1. **Preparation** (`Baron_etal_1983_Table1.R`) — turn the snapshot into a lean per-species CSV. Values come from the snapshot; current names come from the species reference table. Column meanings/units live in the definitions table, not in the data.
2. **Checking** (`Baron_etal_1983_Table1_compare_to_Baron_1983_csv.R`) — a separate QA process that audits `Baron_1983.csv` against the snapshot (and, optionally, against the reference table).
3. **Reference tables** (`reference_tables/`) — the species crosswalk and the definitions/data dictionary. Per-paper for now; to be folded into shared, cross-paper tables in the compilation step.

| File | Role |
|---|---|
| `Baron_etal_1983_Table1_snapshot.xlsx` | Faithful capture of the PDF table (sheet `Table1_snapshot`). Source of truth for values. |
| `Baron_etal_1983_Table1.R` | Preparation -> `Baron_etal_1983_Table1.csv`. |
| `Baron_etal_1983_Table1_compare_to_Baron_1983_csv.R` | Checking (QA) against `Baron_1983.csv`. |
| `Baron_1983.csv` | Earlier formatted/draft table. Audited only. |
| `reference_tables/Baron_etal_1983_species_crosswalk.csv` | Species reference: Baron code -> current name + order/family (MDD v2.4). |
| `reference_tables/Baron_etal_1983_definitions.csv` | Data dictionary: anatomy code, value columns + units, and the legend symbols. |

## 1. Preparation — `Baron_etal_1983_Table1.R` -> `Baron_etal_1983_Table1.csv`

One row per species (76), 13 lean columns:

`code_Baron1983`, `Anatomy_code` (MOB), `Species_Baron1983` (old name), `Species` (current name), `Species_former_synonym`, `n`, `n_note`, `volume_mm3`, `volume_note`, `SEM_pct`, `size_index`, `permille_net_brain`, `permille_telencephalon`.

What it does:

- **Names.** `Species_Baron1983` is the 1983 name with footnote digits dropped and Baron's three abbreviations completed (`semispin.` -> semispinosus, `madagascar.` -> madagascariensis, `Avahi l.` -> Avahi laniger). `Species` is the current accepted name pulled from the species crosswalk by code. Genus-level entries (`Tarsius spp.` etc.) are left as-is.
- **Footnotes translated.** Instead of keeping the bare superscript, `Species_former_synonym` gives the name that superscript points to in the legend — the name used in former papers / Stephan et al. (1981a). Populated for the 12 footnoted species (e.g. *Otolemur crassicaudatus* -> former *Galago crassicaudatus*).
- **Values + markers.** `n` and the value columns are numeric (dashes/blanks -> `NA`). The `*` on `n` is kept in `n_note`; the `+` on volume is kept in `volume_note`. Their meanings are defined in the definitions table.

What it deliberately omits (now in the definitions table or dropped as redundant): units, the full anatomy term, `Structure_original`, the reference/table-number columns, the verbatim superscripted label, and the taxonomic grouping (the grouping lives in the species crosswalk).

On save it writes two files (matching the convention in your other `_Table1.R` scripts): `Baron_etal_1983_Table1.csv` next to the script, and a tab-separated copy named by the item's encoded DOI — looked up in the master `__ReadMe.xlsx` — into the shared `__Public/comparative-data/` folder. If the DOI isn't found or the shared folder is missing, the TSV is skipped with a warning and the local CSV is still written.

## 2. Checking — `Baron_etal_1983_Table1_compare_to_Baron_1983_csv.R`

Matches `Baron_1983.csv` to the snapshot by code and reports three checks separately:

1. **Values** — `n` and MOB volume. Result: 0 mismatches across all 76.
2. **Faithful name** — snapshot vs the CSV's `Species_Baron1983`. Result: **2** transcription typos (0589 `Oryzoricles`; 3244 `Avahi I.`).
3. **Taxonomy currency** *(optional)* — the CSV's updated `Species` vs the crosswalk's current name; skipped if the reference table is absent. Result: **4** out-of-date names.

> **Encoding fix (retained).** `Baron_1983.csv` has a non-UTF-8 byte (`0xCA`) in "Scutisorex somereni" that silently truncated a UTF-8 read; the script reads it with `readr::locale(encoding = "latin1")`.

## 3. Reference tables — `reference_tables/`

- **`Baron_etal_1983_species_crosswalk.csv`** — each Baron code -> current accepted name + order/family under one authority, the **Mammal Diversity Database (MDD) v2.4**, with `name_change`, `needs_review`, and corroborating sources. Verified against MDD and corroborated by published reuses of the Stephan/Baron dataset (per PubMed): Boddy et al. 2012 [DOI](https://doi.org/10.1111/j.1420-9101.2012.02491.x); DeCasien et al. 2017 [DOI](https://doi.org/10.1038/s41559-017-0112); Smaers et al. 2021 [DOI](https://doi.org/10.1126/sciadv.abe2101).
- **`Baron_etal_1983_definitions.csv`** — data dictionary in the same format as your other `_definitions.csv` files (`Code, Definition, Structure, Measure, Stat, Reference, Note`). Defines `MOB`, every value column with its unit (volume mm3, SEM %, size index, per-mille of net brain / telencephalon, n), and the legend symbols (`*`, `+`, superscript 1-12, N).

Open items for the compilation step: decide where the **shared** species and anatomy reference tables should live (likely above the per-paper folders); review the 4 `needs_review` species; and to switch taxonomy authority (MSW3, GBIF, …) edit only the crosswalk.
