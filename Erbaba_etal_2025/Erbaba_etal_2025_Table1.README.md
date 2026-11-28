# Erbaba et al. (2025) - Table 1

## Source
Erbaba, B., Sinha, M., Guevara, E. E., Hecht, E. E., Hopkins, W. D., & Sherwood, C. C. (2025). Insights From Language-Trained Apes: Brain Network Plasticity and Communication. Evolutionary Anthropology, 34, e70018. https://doi.org/10.1002/evan.70018

## Item
Table 1. List of language-trained apes.

## Provenance and build
- `Erbaba_etal_2025.pdf` is the source paper.
- `Erbaba_etal_2025_Table1_snapshot.csv` is a faithful transcription of the printed table, preserving row order, wording, citation keys, and reported ages/statuses.
- `Erbaba_etal_2025_Table1.R` reads only that snapshot and writes the analysis CSV and registry-coded public TSV in `__Public/comparative-data/`.
- Common-name species labels are preserved in `species_printed`. `species_unresolved` supplies conservative scientific labels; orangutan remains `Pongo sp.` because Table 1 does not identify the species.
- `first_exposure_age_years` is derived only for explicit numeric weeks, months, or years. Infant, Early Age, and Adult descriptions remain missing in the numeric field rather than being inferred.
- The reported current ages are retained verbatim and are time-stamped claims in the 2025 paper, not dynamically updated.

## Scope and data role
Secondary compilation/review table. Each row represents a named individual ape and summarizes language-training modality, first exposure, sex, and reported death/current-age status. The paper reports no new primary measurements.

## Checks
- Expected rows: 26.
- Snapshot checked against the page 3 table image for headings, row order, sex, exposure wording, modality, ages/statuses, and reference numbers.
- No arithmetic table check applies.

## Source correction, 2026-11-26
The Nyota status was truncated to “Born in April 4th” in the previous analysis
CSV and provisional TSV. The printed Table 1 continues “1998; currently 27”
on the next line. The frozen snapshot contained the full text but needed CSV
quoting around its comma to parse cleanly; that quoting was corrected without
changing the printed wording. The reader was rerun, restoring the full source
text in both outputs. Seven numeric ages changed only in serialization
(`1.0` to `1`, etc.). The obsolete provisional TSV inside the paper folder was
removed after the registry-coded public TSV was verified against the CSV.

## Registration note
The reader requires one live registry row with a valid `Item encoded` value
before writing either output.

Layout audit (2026-11-27): compared with printed Table 1. The former snapshot split bracketed citations out of the printed Ape name cells into an added Reference column. The six-column snapshot now keeps the printed cells; the R reader extracts the name and reference key. Build: `Rscript --vanilla Erbaba_etal_2025_Table1.R`.
