# Nimchinsky et al. 1999 — Table 1 (spindle cells in ACC area 24, 28 primates)
Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999). *A neuronal morphologic type unique to humans and great apes.* Proc Natl Acad Sci USA 96(9):5268-5273. doi:10.1073/pnas.96.9.5268. PMID 10220455. PMC21853.
Full title (`__ReadMe.xlsx`): **"Table 1. Summary of the primate species investigated"**

## Source->Snapshot
Open-access HTML, `https://pmc.ncbi.nlm.nih.gov/articles/PMC21853/`, `section#T1` (snapshot HOWTO method 2). -> `..._Table1_snapshot.xlsx` (sheet `Table1`): 48 rows as printed — 28 species and the 20 clade rows they nest under, row order kept.

Extraction and build are one script, `..._Table1.R`, in two sections. Section 1 reads `section#T1` from the source page and compares it with the frozen copy: writes it if absent, reports a verification if identical, writes `..._REBUILD.xlsx` and stops if it differs, and warns and carries on if the page cannot be read. Section 2 always reads the frozen `.xlsx` from disk — never the object parsed in section 1 — so what is published is always what is committed. (Until 21 September 2026 extraction for both tables lived in `Nimchinsky_etal_1999_extract_snapshot.R`; once the frozen copies existed that script took its "already matches" branch on every run and produced no output, so it has been removed and each table now owns its own extraction.)

`.xlsx`, not `.csv`, because the caption defines a value by typography: *"Spindle cells in layer Vb of anterior cingulate cortex area 24 are observed with certainty only among hominoids, in all extant pongid and hominid species (shown in bold)"*. The bold falls on Hominoidea, Pongidae, Hominidae and the five species under them; it is preserved in the snapshot. Italics on the binomials are typesetting, not data, and are not carried.

Transcription: the values were read from the PMC HTML by the script (no table values are typed into it) on 10 September 2026; the script was written by Claude (AI assistant) and its output was checked cell by cell against page images of the printed table supplied by M. Windley, including the bold. Re-running the script re-reads the page and stops rather than overwrite if the frozen copy has drifted.

## Data readable
`..._Table1.R` -> `..._Table1.csv`/`.tsv` (use this): 28 rows, one per species. The clade rows are unnested into `suborder`/`superfamily`/`family`; `spindle_cells` keeps the printed level and `spindle_cells_present` is derived from it (the extract script checks it agrees with the bold before freezing). Species harmonized via `_keys/Hof/species_key.csv`; printed name kept as `species_as_published`.

Checks in the script: 48 snapshot rows, 28 species, every species under a family, `sum(n_specimens) == 74`, five species with spindle cells present.

## Species notes
- New collection group. `_keys/Hof/` rather than an existing key: the specimens are Mount Sinai, the Great Ape Aging Project, Caltech, Oregon RPRC and zoo material (Methods, *Specimens*), which is not the Wisconsin/Welker material behind `_keys/Allman/`. Hof is the constant author across this lineage — Nimchinsky 1999, Hof 2001, Butti 2009, Hakeem 2009, Raghanti 2015 — and Allman is not on Raghanti.
- `Papio hamadryas cynocephalus` -> `Papio cynocephalus`. The printed trinomial names the yellow baboon under the 1990s single-species treatment of *Papio*; `species_reference.csv` carries `Papio cynocephalus` and `Papio hamadryas` as separate accepted names, so the yellow baboon resolves to the former. `Bush_Allman_2003/2004` print plain "Papio hamadryas", a different animal, and are unaffected.
- `Gorilla gorilla gorilla` -> `Gorilla gorilla`.
- `Galagoides demidoff` kept as printed.
- Pongidae is the paper's 1999 family usage and is retained in `family` because the table prints it.
- Three accepted names are not yet in `species_reference.csv`: *Cebus apella*, *Macaca fuscata*, *Macaca nigra*. Proposed rows are in `_keys_patch/species_reference_ADDITIONS.csv` with `ncbi_taxid` left blank and `needs_taxonomy_review = TRUE`, for `resolve_taxonomy.R` to fill.

## Comparisons
None. Founder item — no `__Public` value for spindle-cell presence to audit against.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
