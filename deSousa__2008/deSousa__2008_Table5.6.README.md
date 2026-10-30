# deSousa__2008_Table5.6

## Source
de Sousa, A. A. (2008). *Hominoid brain organization: Histometric and morphometric
comparisons of visual brain structures* [Ph.D., The George Washington University].
UMI:3311323. Registry Item **Table 5.6**, printed p. 195 (PDF page 214, landscape).

**Species mean volumes of cortical areas and brain nuclei** — 6 hominoid species ×
11 structures, all in mm³ (printed footnote b).

## Why this item exists
This is the public, citable home of the de Sousa hominoid means for the brainstem
motor nuclei (Vmo, VII, XII), Brodmann areas 13, 10, 44 and 45, and the three
basolateral amygdala nuclei. The restricted staging note
(`_deSousaDissertation_staging/README_staging.md`) listed these as data to be added
from `multisystem.xlsx` — but **the `Medulla vol`, `Vmo`, `VII` and `XII` columns of
that workbook are empty headers**: the values exist only in this printed table.
Registering it here removes the need to cite the restricted staging area for them.

## Pipeline
PDF text layer → snapshot → R → usable csv/tsv.

| file | role |
|---|---|
| `deSousa__2008_Table5.6_extract_snapshot.R` | reads the PDF text layer, writes the frozen snapshot |
| `deSousa__2008_Table5.6_snapshot.xlsx` (sheet `Table5.6`) | frozen source, printed layout and units |
| `deSousa__2008_Table5.6.R` | reads the snapshot, cleans, writes CSV + public TSV |
| `deSousa__2008_Table5.6.csv` | one row per species (6) |
| `reference_tables/deSousa__2008_Table5.6_definitions.csv` | data dictionary |

## Who read the values, when, and how it was checked
Read from the dissertation PDF's own text layer at run time
(`pdftools::pdf_data()`, page 214), placed by printed x-position; only the caption,
the header row and the two footnotes are printed literals. Extracted and checked by
an AI assistant (Claude Science session), 2026-09-25. The printed grid is complete
(6 × 11 with no blanks), so the build script asserts **no NA anywhere** — a dropped
cell cannot pass silently — plus row count, printed row order (Homo sapiens →
Hylobates lar) and the first brain volume (1264586.01 mm³).

No independent copy of this table exists in the project to audit against
(`multisystem.xlsx` does not carry these values), so there is no comparison script;
per §7 of the build HOWTO that absence is not a defect.

## Data role — SECONDARY (compilation), not merged
Printed footnote a: *"The data are derived from previous studies which have included
hominoid brain specimens from the Zilles collection."* The table is a compilation,
not new measurement, and is **not** added to any merge — the underlying values are
(or will be) ingested from their own primary tables. Attribution by structure, as
stated in the dissertation's chapter 5 text and source list:

| columns | compiled from |
|---|---|
| Vmo, VII, XII | Sherwood et al. 2005 |
| area 13 | Semendeferi et al. 1998 |
| area 10 | Semendeferi et al. 2001 |
| lateral, basal, accessory basal (amygdala) | Barger et al. 2007 |
| area 44, area 45 | Schenker et al. 2005 / Sherwood et al. 2003 lineage |
| brain | Zilles-collection convention, as in Table 5.1 |

Treat the attribution column as the dissertation's own statement of source, not as a
verified value-match: the per-structure primaries have not been value-matched against
this table. `__merging_volumes/crosspub_value_match.R` is the tool to do that when
each primary is built.

## Canonical structure names
`Vmo`, `VII`, `XII`, areas 13/10/44/45 and the amygdala subnuclei have **no entry in
`_keys/anatomy_reference.csv` yet**. The definitions file uses descriptive
canonical-style names and flags this; add the entries when the first primary table
for each structure is built.

## Units
None applied — printed footnote b states all volumes are already in mm³. Values are
rounded to the printed two decimals to remove parsing noise.

## Observation level
**One row per species** (printed species means).
