# Frahm et al. (1984), Table 1

Frahm, H. D., Stephan, H., and Baron, G. (1984). Area striata in Insectivora
and Primates. Source PDF: `frahm_etal_1984.pdf`, PDF p. 3 / printed p. 539.
This item supplies area striata volumes in mm³ to the Stephan-collection tier
of `__merging_volumes`.

## Snapshot

`Frahm_etal_1984_Table1_snapshot.xlsx` now follows the printed seven-column
table: species, n, ASV (total volume), ASW (white matter), ASG (grey matter),
ASG 1, and ASG 2–6. It retains source order, the Scandentia/Primates,
Prosimians/Simians group rows, three header tiers, dashes in unmeasured lamina
cells, printed superscript footnote keys, and the two table notes. The former
snapshot sorted species and put ASW after the grey-matter columns.

Codex reconstructed the layout from the PDF page render on 2026-11-27,
retaining the existing transcription's measurements and checking their
placement against the visible source table. This is an assistant check, not
human visual signoff or a new claim that every numeral has received human
review. Printed names that differ from established analysis labels are mapped
in `reference_tables/Frahm_etal_1984_Table1_species_lookup.csv`; the original
footnote names remain in the existing item footnote lookup.

## Build

Run `Rscript --vanilla Frahm_etal_1984/Frahm_etal_1984_Table1.R` from the
repository root. The reader moves ASW to the existing analysis column position,
removes grouping/header/footnote rows, joins name annotations, and applies the
established analysis order. The rebuilt 44-row CSV and public TSV have the same
cell contents as before this snapshot correction.
