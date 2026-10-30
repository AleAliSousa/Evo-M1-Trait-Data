# Hofman 1985 - Table I (brain volume, cortex volume, cortical surface, thickness, folding; 44 mammals)

Hofman MA (1985). *Size and shape of the cerebral cortex in mammals. I. The cortical surface.* Brain Behav Evol 27(1):28-40. doi:10.1159/000118718

Role: **secondary**. Hofman compiled Table I from refs 1-12 (Elias & Schwartz 1969/1971, Frahm et al. 1982, Haug 1970, Pirlot 1981, Pirlot & Kamiya 1982, Ridgway & Brownson 1979, Schlenska 1969/1974, Stephan 1954/1961, Stephan et al. 1981); Stephan 1981 and Frahm 1982 are already in the repo, so prefer those originals for overlapping volumes. Hofman's own contribution: cortical surface compilation, thickness and folding index.

## Source -> snapshot
`Hofman__1985.pdf` is a scan without text layer. Table I runs over facing pages: PDF p3 (journal p30) + p4 (p31) = 28 rows; p5 (p32) + p6 (p33) = 16 rows; total 44, row counts equal on both halves. `Hofman__1985_TableI_snapshot.csv` is a constructed (transcribed) snapshot: row order, group headers (added as a column), numbers (thousands commas kept) and reference strings as printed. Printed `-` kept as `-`; cells that are simply unprinted are left blank; `>` kept verbatim in the Index column (">1.00"). The R build turns both into NA and adds `index_of_folding_is_lower_bound`.

## Fidelity checks
- Index of folding = St/So recomputed on 25 rows with both surfaces and no `>`: 0 disagree at 2 dp.
- Mean thickness d = Vg/St (gray volume / total surface) recomputed on 27 rows: 0 differ by more than 3%.
- Those checks cover columns Vg, St, So, d, index only; brain / prosencephalon / Vg+w volumes and reference numbers need the RA side-by-side read.

## Caveats
- Outer surface is unprinted (blank) for 12 rows (Marmosa mitis, all 6 Basal insectivora, Neomys..Potamogale, Rattus); all have index 1.00 so So = St by definition, but it is not filled in. Printed `-` (no data) for Rhynchocyon, Tupaia, Galagoides, Perodicticus, Aotus, Stenella.
- Row-1 Marmosa mitis: only 3 values in the outer-surface column for 4 marsupial rows (11.8, 35.2, 53.0 sit against rows 2-4).
- Reference numbers are printed once per brace block and repeated on each row here (block-level, not per value). Printed "3, 11 12" (Prosimii, no comma) kept verbatim. Index/reference braces cover Marsupialia, Basal insectivora, Progressive insectivora, Prosimii, Ungulata.
- Species spellings as printed (Wallabia rufogrisea, Crocidura russala, Canis latrans, Stenella styx, Pseudorca crassidiens, Dolichotus/Callithrix "spec."); Aotus, Macaca mulatta, Homo sapiens etc. single means.
- Table II (p34) is an allometric regression summary (slopes +/- SD, n species), not species data; not built.
- Cortex here = iso-, schizo-, palaeocortex (hippocampus and primary olfactory cortex excluded), i.e. not the same as total pallium.

## Build
`Hofman__1985_TableI.R` -> `Hofman__1985_TableI.csv` (44 rows). Public TSV is written once the registry row is pasted into `__ReadMe.xlsx`.
