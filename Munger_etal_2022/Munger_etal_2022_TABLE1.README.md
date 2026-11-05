# Munger et al. 2022 — TABLE 1 (individuals: species, age, sex, brain weight)
Munger EL, Edler MK, Hopkins WD, Hof PR, Sherwood CC, Raghanti MA (2022). *Comparative analysis of astrocytes in the prefrontal cortex of primates: Insights into the evolution of human brain energetics.* J Comp Neurol. doi:10.1002/cne.25387.
Full title (`__ReadMe.xlsx`): **"TABLE 1 Individuals included in the present study with age (years), sex, and brain weight (grams) listed."**

## Source -> Snapshot -> Data readable
- **Snapshot: `Munger_etal_2022_TABLE1_snapshot.csv`**, written by step 1 of `Munger_etal_2022_TABLE1.R` from the text layer of the publisher PDF in this folder (born-digital; `pdftools::pdf_text`, p. 3) **before any cleaning**. Owner decision, 04 Nov 2026, revising the same day's "snapshot not needed": the conversion to a snapshot lives in the build script and the snapshot is saved in this folder.
- Laid out as printed: the caption row, the header row (`Genus, species`, `Age (years)`, `Sex`, `Brain weight (g)`), then the 25 printed rows in printed order. The species name appears only on the first row of its block (blank below, as on the page). Each brain weight is exactly as printed, with its footnote mark (`118.0`, `124.2*`, `384**`).
- No table value is typed into the script. The caption and the four header cells are printed literals, each checked against the page before anything is written: the caption shares its lines with the page's second text column, so it cannot be cut out of the text layer cleanly. Text-layer quirks: `TABLE 1` is letter-spaced (`TA B L E 1`). An empty text-layer line between the 41- and 43-year chimpanzees is paragraph spacing from the right-hand column, not a printed row, so it is not in the snapshot.
- Rows are read only for their four leading cells, and only where the age cell starts under the printed `Age (years)` header, because Table 1 sits in the left column of p. 3 and shares lines with the right-hand column.
- **Frozen-file guard** (model: `Jacob_etal_2021/Jacob_etal_2021_extract_snapshot.R`): when the snapshot already exists, a re-run compares its new extraction with it byte for byte. Identical: nothing is written. Different: the extraction goes to `Munger_etal_2022_TABLE1_snapshot_NEW.csv` and the run stops, so the frozen copy never changes silently. `keep_frozen_snapshot <- TRUE` (top of the script) builds from a deliberately hand-corrected frozen copy instead; record any such correction in this README. Without the PDF in the folder, step 1 is skipped and the build runs from the snapshot.
- **Step 2 reads the snapshot by position, never the PDF:** it carries each species down its block, splits each brain-weight cell into grams and footnote mark, maps species through the key, and writes the CSV and TSV.

## Output
`Munger_etal_2022_TABLE1.csv` / `__Public/comparative-data/10.1002%2Fcne.25387_TABLE1.tsv`: 25 rows, one per individual (*Macaca nemestrina* 6, *Papio anubis* 6, *Pan troglodytes* 7, *Homo sapiens* 6). Columns: `specimen_row` (printed row order; a local locator, not an accession), `species`, `species_as_published`, `age_years`, `sex`, `brain_weight_printed`, `brain_weight_mg` (printed g x 1000, project unit), `brain_weight_marker`, `brain_weight_basis`, `source`. Data dictionary: `reference_tables/Munger_etal_2022_TABLE1_definitions.csv`.

## Brain weight basis (caption footnotes, kept, never changed)
- Row 8, *Papio anubis*, M, 6 y: `124.2*` = extrapolated from one hemisphere.
- Row 17, *Pan troglodytes*, M, 41 y: `384**` = the species average from Robson & Wood (2008), **not this animal's weight** (secondary). Filter on `brain_weight_basis` before any individual-level use.
- The other 23 values are `measured`.

## Checks
- Two PDF readers agree: the build (poppler text layer, as `pdftools`) and an independent word-position read (pdfplumber) give the same 25 rows; 0 mismatches in 100 cells. The rendered page was also compared by eye by the AI assistant.
- Snapshot vs page (4 Nov 2026, AI assistant; **not** a human check): the rendered Table 1 was read across, row by row, against the snapshot. The caption, header and all 25 rows agree, including the blank species cells under each block and both footnote marks.
- **Human visual check of snapshot: pending** (`__ReadMe.xlsx` column AJ; the person signs `DDMMYYYY_initials`).
- Table 1 vs Table 4: Table 4's `n` never exceeds the Table 1 count for its species (6, 6, 7, 6; the chimpanzee EAAT2 rows have n = 4).
- Table 1 vs text: the text says sexes were balanced; Table 1 prints 3 M / 3 F (*Macaca*, *Homo*), 4 M / 2 F (*Papio*) and 3 M / 4 F (*Pan*). Kept as printed.
- Table checks (build HOWTO sec. 7a): none possible; Table 1 prints no totals.

## Species
Binomials printed as such; mapped through `_keys/Hof/species_key.csv` (four `verbatim` rows, `source_publication = Munger_etal_2022`). All four are in `species_reference.csv`.

## Specimens (why this table matters)
Brain sources (Materials and methods 2.1): macaques from the Washington National Primate Research Center, baboons from the Southwest National Primate Research Center, chimpanzees from the National Chimpanzee Brain Resource, humans from the NIH NeuroBioBank (`reference_tables/Munger_etal_2022_specimen_sources_from_text.csv`). No accession is printed, so every individual is registered in `_keys/specimen_crosswalk/specimen_crosswalk.csv` (`MUNGER2022-T1-01` ... `-25`). A scan of the repository's public specimen tables found **five chimpanzees that are probably the same animals as individuals in other papers** (species, sex, age and brain weight to 0.1 g agree):
- row 16 (M, 40 y, 341.2 g) = Bauernfeind et al. 2013 **YN01-92a** (GAAP) = Stimpson et al. 2015 Table S1 subject 1; joined to `BAUERNFEIND-PANTRO-YN01-92`;
- row 13 = Stimpson 2015 subject 5; rows 14, 15, 19 = Hrvoj-Mihic et al. 2026 codes PTF93, PTF125, PTF173.
Row 18 has two equally good Hrvoj-Mihic candidates (PTF141, PTF143) and is not linked. Details: `_keys/specimen_crosswalk/Munger2022_specimen_note.md` and `munger_2022_provenance_audit.csv`. The comparison with the Allen Institute M1 cross-species transcriptomic study uses unpublished specimen metadata and lives in the restricted repository (`restricted_checks/_cross_table/Munger_etal_2022_vs_M1_cross_species_study/`).

## Comparisons
None in the public repository (founder item; no earlier `__Public` value to audit against).

## Reader and provenance
Values read from the PDF text layer by the build script; no values typed by a person or an AI. Script written on 4 Nov 2026 by an AI assistant (Microsoft Copilot).
- **First version (no snapshot step):** the owner's R run on 4 Nov 2026 reproduced the Python mirror: the CSV byte for byte, the TSV at the same size.
- **Snapshot step: confirmed by R.** The owner ran this script on 4 Nov 2026 (08:43). It left the frozen snapshot unchanged, so R's extraction matched the Python mirror's (no `_snapshot_NEW.csv`). It rebuilt the CSV byte for byte and the TSV at the same size.

## Registry
- `Item encoded` is `10.1002%2Fcne.25387_TABLE1`. The citation in column A of `__ReadMe.xlsx` ended with a space after the DOI; this was fixed on 4 Nov 2026. The script still stops, rather than write a misnamed TSV, if a space ever returns.
- Snapshot columns: `Snapshot (if filename is not Item name)` stays empty, because the snapshot carries the standard name. `Snapshot filetype` is `csv`. `Human visual check of snapshot` is pending.

Pipeline: Source (born-digital PDF) -> Snapshot (R step 1; confirmed by R run 04 Nov 2026) -> Data readable OK (R run 04 Nov 2026) -> Species harmonized -> Specimens registered -> Online database
