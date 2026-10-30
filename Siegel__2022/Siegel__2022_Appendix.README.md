# Siegel__2022_Appendix

Siegel, J. M. (2022). Sleep function: an evolutionary perspective. *Lancet Neurology*, 21(10),
937–946. https://doi.org/10.1016/S1474-4422(22)00210-1
Source: `Siegel__2022_Sleep_Supplementary.pdf` (supplementary appendix "as supplied by the
authors"), pp. 1–2 = PDF pp. 2–3: **Appendix: REM, non-REM, and total sleep amounts in homeotherms.**
Registry: existing Sheet1 row, `Item name` Siegel__2022_Appendix, `Item encoded`
`10.1016%2FS1474-4422(22)00210-1_Appendix`.

## Files

| file | role |
|---|---|
| `Siegel__2022_Appendix_snapshot.xlsx` | frozen source (byte-identical copy-rename, SHA-256 35b39645f21b…, of the pre-existing `Siegel__2022_Sleep_Supplementary_Snapshot.xlsx`; hand transcription in printed layout: title, intro sentence, Birds/Mammals headings with superscripts, three blocks with their headers, references) |
| `Siegel__2022_Appendix.R` | reads the snapshot positionally → CSV + public TSV, with table checks |
| `Siegel__2022_Appendix.csv` | analysis data, 52 rows |
| `__Public/comparative-data/10.1016%2FS1474-4422(22)00210-1_Appendix.tsv` | public copy |
| `reference_tables/Siegel__2022_Appendix_definitions.csv` | data dictionary |
| `reference_tables/Siegel__2022_Appendix_references.csv` | the appendix's five references (ref 1 birds; refs 2–5 on the Mammals heading) |
| `reference_tables/Siegel__2022_errata.csv` | E001 duplicated Phalanger row; E002 main-text opossum binomial |
| `Siegel__2022_Appendix_registry_row.xlsx` | proposed descriptive-column update for the existing registry row |

## Snapshot verification and reader

The snapshot existed before this build (transcriber not recorded in the folder). On 2026-10-28 an
AI assistant (Claude Science) compared all 52 data rows with the PDF text layer (names and three
values per row; 0 differences) and viewed both page images. Fidelity limits, kept as found: numeric
cells are stored as numbers, so the printed trailing zeros ("10.0", "4.0", "15.0") display as 10, 4,
15 — the values are equal; superscripts are flattened ("52 species2-5" for printed 52 species²⁻⁵).
The original file name predated the `<Item>_snapshot` convention (and its capital "S" hid it from
`build_dataset_item()`'s case-sensitive frozen-source search), so it was copy-renamed byte-for-byte to
`Siegel__2022_Appendix_snapshot.xlsx` on 2026-10-28. The old-name copy was put to the owner for
removal to Trash (one frozen copy only); if it is still present, it is an identical duplicate.

## Build steps (R)

Positional read; block = nearest heading above (Placentals / Marsupials / Monotremes); data rows =
rows with a numeric Total; printed names kept verbatim (`species_as_published`); harmonised via
`_keys/General/species_key.csv` filtered on `source_publication = Siegel__2022` (stops on zero rows
or any unkeyed name); hours kept as printed (no conversion). Ran clean with `Rscript --vanilla` in
env `evom1-r` (R 4.5.3), 2026-10-28.

## Table checks

56 checks, all **pass** (actual R run, 2026-10-28): Total = REM + non-REM for all 52 rows (tolerance
0.1 h = half a unit on each of two 0.1-h cells; every row is exact); row counts 47 / 3 / 2 equal the
printed "47 species", "3 species", "2 species", and 52 rows equal "Mammals 52 species". The
mammal count passes only because the Phalanger row is printed twice (E001): 51 distinct names.

## Data role: secondary — source tracing

Values are compiled. The appendix prints source keys only at section level (Birds "23 species¹",
Mammals "52 species²⁻⁵"); `section_ref_keys` carries "2; 3; 4; 5" on every mammal row (join
`ref_key`). Refs 3 and 4 (Siegel et al. 1996 echidna; 1999 platypus) are the original sources of the
two monotreme rows; refs 2 (elephant welfare chapter) and 5 (marsupial thermal energetics) do not
evidently report the listed sleep amounts, and no per-species source is given for the 47 placental
rows. These are recorded verbatim in the references `note`, not corrected. The per-species originals
must be traced through earlier sleep compilations before any primary ingestion.

## Species names

`species_key.csv` rows (51) were added for `Siegel__2022` (collection General). Main-text binomials
are adopted for echidna, platypus, thick-tailed opossum and phalanger (`author_judgment`); the main
text's `Lutreolina crassicaudata` for "North American opossum" is not adopted (E002; Figure 1 says
"Virginia opossum" → *Didelphis virginiana*). Generic names (Macaque, Baboon, Galago, Tapir, …) map
to `<Genus> sp.`; "Gray hyrax", "Mole rat", "Tenrec" stay `(species unspecified)`. All other
common-name → binomial mappings are curator judgments pending owner sign-off.

## Legacy files (left untouched — for the owner)

- `Siegel__2022_Homeotherms.csv`: a script-less earlier CSV. Same 52 rows and identical values, but it
  silently changed two printed names ("Lesser short-tailed shew" → "shrew", "cat" → "Cat") and
  hand-coded 16 binomials outside the species key (36 NA). Superseded by `Siegel__2022_Appendix.csv`.
- `Siegel__2022_Homeotherms.tsv`: **orphan TSV inside the paper folder** (the audit flags it). The
  public TSV is now written by the script to `__Public/comparative-data/`; this copy should be removed
  by the owner (not deleted here).
- `.RData`, `.Rhistory`, `Siegel__2022.Rproj`, `.Rproj.user/`: RStudio session files.

## Errata

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Siegel__2022_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Siegel__2022-E001 | * | Supplementary appendix p. 1 (PDF p. 2) Placentals row 'Phalanger' and p. 2 (PDF p. 3) Marsupials row 'Phalanger' | Phalanger 13.7 / 1.8 / 11.9 (printed in both blocks) |  | publication_ambiguity | treat the Placentals 'Phalanger' row as a duplicate of the marsupial row (duplicate_printed_row = TRUE); 51 distinct mammals, not 52 | proposed | Main text p. 940 (PDF p. 4) lists 'the phalanger [Trichosurus vulpecula]' among marsupials; the identical values appear in both blocks; Placentals '47 species' and Mammals '52 species' both count it | CSV keeps both printed rows; analyses should drop duplicate_printed_row == TRUE |
| Siegel__2022-E002 | species_harmonised | Main text p. 940 (PDF p. 4), mammal subgroups paragraph: 'North American opossum [Lutreolina crassicaudata]' | the North American opos­sum [Lutreolina crassicaudata], the thick-tailed opos­sum [Lutreolina crassicaudata] |  | publication_error | Didelphis virginiana for appendix row 'North American opossum' | proposed | Same binomial printed for two different common names; Figure 1 (PDF p. 4) labels the species 'Virginia opossum' (= Didelphis virginiana); Lutreolina crassicaudata is the thick-tailed opossum | Applied only through _keys/General/species_key.csv (basis our_judgment); printed common name retained |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
