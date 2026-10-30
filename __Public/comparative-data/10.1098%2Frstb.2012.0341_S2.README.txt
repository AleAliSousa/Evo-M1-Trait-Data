# Kamilar_Cooper_2013_S2

Kamilar, J. M., & Cooper, N. (2013). Phylogenetic signal in primate behaviour, ecology and life history. Philosophical Transactions of the Royal Society B: Biological Sciences, 368(1618), 20120341. https://doi.org/10.1098/rstb.2012.0341

## Source and extraction

Original `rstb20120341supp2.xlsx` copied byte-for-byte to `Kamilar_Cooper_2013_S2_snapshot.xlsx`. SHA-256 `3f4c32fbda9e1661173abea39396dc0b8f783c94106358ef9a3529f4568c80e7`. Reader: Codex, 2026-10-21, using readxl for XLSX and xml2 for DOCX, with independent Python value checks. No transcription or human visual sign-off is claimed for these author-tabulated digital files.

S2 sheet 1: rows 2–214 hold 213 species; bibliography starts at row 218. Empty trailing columns and empty worksheets are not data. Cached Excel formula results are read without recalculating or modifying the source. There are 30 numeric columns in the supplied matrix; the paper’s 31-variable analysis also discusses derived variables not supplied as separate matrix columns. Endocranial volumes are from Isler 2008 and converted from cm3 to mm3. Body masses are already g. Maximum longevity remains months. AdultSexRatio is female/male in the supplied formulas. References are split into joinable keys with the exact original source cells retained. Bibliography ambiguities and year mismatches remain flagged; they are not silent corrections.

## Outputs and wiring

`Kamilar_Cooper_2013_S2.R` produces `Kamilar_Cooper_2013_S2.csv` (213 rows) and `__Public/comparative-data/10.1098%2Frstb.2012.0341_S2.tsv`. All metadata columns are described in `reference_tables/Kamilar_Cooper_2013_S2_definitions.csv`. Printed species names are resolved downstream by `_keys/resolve_species.R`; unresolved and historical labels are retained without inventing identities.

Mapped to source-specific variables in `__merging_supplementary/supplementary_sources.csv`, explicitly marked secondary. These views preserve coverage while avoiding averaging compilation repeats into existing primary measurements. They are not independent source counts. No color-vision or vocal-repertoire measurement occurs in this supplement.

## Registry and rebuild

Live registry insertion is pending. `Kamilar_Cooper_2013_S2_registry_row.xlsx` follows the live 34-column registry layout and contains owner paste instructions. The explicit staging identities used for this build are in `ManyPrimates__2022/ManyPrimates_supplements_build_registry.xlsx`. Before owner insertion, run from the repo root:

```sh
DATASET_REGISTRY=ManyPrimates__2022/ManyPrimates_supplements_build_registry.xlsx Rscript Kamilar_Cooper_2013/Kamilar_Cooper_2013_S2.R
```

After registration, run the same R script without the environment variable. The live registry determines the public TSV name. The supplementary merge reads the explicit local CSV path and therefore does not depend on insertion timing.

## Table checks

Executed in R on 2026-10-21: {'pass': 322, 'not_evaluable': 104}. Ratios compared to male/female mass and female/male adult counts, tolerance 0.005.

Cross-source coverage and verification reports are private under `restricted_checks/_cross_table/ManyPrimates_20261021` in the restricted repository.

## Species identity

The paper-specific General key maps `Cercocebus_torquatus_atys` to `Cercocebus atys`, preserving the distinction from the separate `Cercocebus_torquatus` row. NCBI taxonomy 9531 lists the former as a synonym of C. atys: https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=9531&mode=info .
