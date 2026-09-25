# Frahm_etal_1984_Table2

## Source
Frahm, H. D., Stephan, H., & Baron, G. (1984). Comparison of brain structure volumes in
Insectivora and Primates. V. Area striata (AS). *J Hirnforsch*, 25(5), 537-557.
Registry Item **Table 2**; DOI/PMID-coded TSV `PMID%3A6501869_Table2.tsv`.

**Area striata (primary visual cortex, V1) relative-size and laminar ratios.** Table 2 reports
area striata volume/mass **relative to** brain weight, telencephalon volume, neocortex volume,
and neocortex laminar subdivisions (all as percentages), plus two derived within-structure ratios
and a ratio to the dorsal lateral geniculate nucleus (CGL) — for the same 44-species sample as
Table 1. Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
Frozen snapshot → R → analysis CSV/TSV. Files: `Frahm_etal_1984_Table2_snapshot.xlsx` (sheet
`Table2`), `Frahm_etal_1984_Table2.R` → `Frahm_etal_1984_Table2.csv` (+ public TSV),
`reference_tables/Frahm_etal_1984_Table2_definitions.csv` (already present).

## Preparation → `Frahm_etal_1984_Table2.csv`
One row per species (44, hard-checked in the build script). The reformat reads the frozen
snapshot positionally, skips the 2 header rows, parses each percentage/ratio column, and tags
every row `source = "Frahm_etal_1984"`. `ASG_percent_ASV` is additionally range-checked
(0, 100] on every build run.

## Table 1-3 footnote — species-name synonymy vs Stephan et al. (1981)
Table 2 shares Table 1's printed footnote (species names follow Corbet & Hill 1980; six species
were named differently in Stephan et al. 1981 and earlier papers). The build script joins the
same shared lookup, `reference_tables/Frahm_etal_1984_Table1_footnotes.csv`, onto Table 2's rows
by species name, carried into the output as `former_name_stephan1981` (NA where the footnote does
not apply to a given species) — see `Frahm_etal_1984_Table1.README.md` for the full six-species
mapping table.

## Note
Snapshot-driven build (not the curated-comparison pattern used for Table 1); no independent
curated copy exists to audit Table 2 against, so no `comparison/` step applies here. Values are
the printed relative-size/ratio figures — not independently re-derived from Table 1's absolute
volumes.

## Extraction / build record
Snapshot, reformat script, CSV, definitions, and public TSV were already in place and working.
This README was added by Microsoft Copilot (AI assistant) on 2026-09-25, reading the existing
`.R` script, definitions file, and the sibling Table 1 README to document the pipeline. No values
were re-transcribed or changed.
