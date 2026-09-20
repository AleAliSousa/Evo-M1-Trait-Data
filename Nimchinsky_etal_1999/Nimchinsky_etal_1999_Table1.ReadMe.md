# Nimchinsky et al. 1999 — Table 1 (spindle cells in ACC area 24, 28 primates)
Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999). *A neuronal morphologic type unique to humans and great apes.* Proc Natl Acad Sci USA 96(9):5268-5273. doi:10.1073/pnas.96.9.5268. PMID 10220455. PMC21853.
Full title (`__ReadMe.xlsx`): **"Table 1. Summary of the primate species investigated"**

## Source->Snapshot
Open-access HTML, `https://pmc.ncbi.nlm.nih.gov/articles/PMC21853/`, `section#T1` (snapshot HOWTO method 2). `..._Table1_extract via Nimchinsky_etal_1999_extract_snapshot.R` -> `..._Table1_snapshot.xlsx` (sheet `Table1`): 48 rows as printed — 28 species and the 20 clade rows they nest under, row order kept.

Frozen page: `Nimchinsky_etal_1999_PMC21853.html` (PMC HTML as served 18 September 2026; both tables and the bold verified identical to the snapshots). The script prefers this local copy, so re-runs are offline; it was added after the 2026-09-18 sweep failed on a transient non-article response from PMC.

`.xlsx`, not `.csv`, because the caption defines a value by typography: *"Spindle cells in layer Vb of anterior cingulate cortex area 24 are observed with certainty only among hominoids, in all extant pongid and hominid species (shown in bold)"*. The bold falls on Hominoidea, Pongidae, Hominidae and the five species under them; it is preserved in the snapshot. Italics on the binomials are typesetting, not data, and are not carried.

Transcription: the values were read from the PMC HTML by the script (no table values are typed into it) on 10 September 2026; the script was written by Claude (AI assistant) and its output was checked cell by cell against page images of the printed table supplied by M. Windley, including the bold. Re-running the script re-reads the page and stops rather than overwrite if the frozen copy has drifted.

## Data readable
`..._Table1.R` -> `..._Table1.csv`/`.tsv` (use this): 28 rows, one per species. The clade rows are unnested into `suborder`/`superfamily`/`family`; `spindle_cells` keeps the printed level and `spindle_cells_present` is derived from it (the extract script checks it agrees with the bold before freezing). Species harmonized via `_keys/Allman/species_key.csv`; printed name kept as `species_as_published`.

Checks in the script: 48 snapshot rows, 28 species, every species under a family, `sum(n_specimens) == 74`, five species with spindle cells present.

## Species notes
- `Papio hamadryas cynocephalus` -> `Papio hamadryas`, the paper's own rank treatment and the accepted name already used for `Bush_Allman_2003/2004`.
- `Gorilla gorilla gorilla` -> `Gorilla gorilla`.
- `Galagoides demidoff` kept as printed.
- Pongidae is the paper's 1999 family usage and is retained in `family` because the table prints it.

## Comparisons
None. Founder item — no `__Public` value for spindle-cell presence to audit against.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
