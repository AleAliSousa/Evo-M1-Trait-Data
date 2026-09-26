# deSousa__2008_Table5.1

## Source
de Sousa, A. A. (2008). *Hominoid brain organization: Histometric and morphometric
comparisons of visual brain structures* [Ph.D., The George Washington University].
UMI:3311323. Registry Item **Table 5.1**, printed p. 190 (PDF page 209, landscape).
Public copy: `deSousa__2008/desousa_2008.pdf`; also at
<https://paleoanthro.org/media/dissertations/Alexandra%20de%20Sousa.pdf>.

**Specimens and volumes** — 29 catarrhine specimens. Part of the
**Stephan/Düsseldorf histological-volume collection** (Zilles, Stephan, Welker,
Yakovlev-Haleem and Sherwood-Hof material).

## Why this item exists
The 29 dissertation specimen codes (`hs14` … `mf2`) are used throughout
`_keys/specimen_crosswalk/` as `item_reference = deSousa_dissertation_2008_Table5.1`;
until now that reference pointed at a workbook in `Evo-M1-Trait-Data-restricted`
(`_deSousaDissertation_staging/`). The codes and their measurements are printed in
the public dissertation, so the reference now resolves to a public, citable item and
the restricted staging area is no longer load-bearing for it.

## Pipeline
PDF text layer → snapshot → R → usable csv/tsv.

| file | role |
|---|---|
| `deSousa__2008_Table5.1_extract_snapshot.R` | reads the PDF text layer, writes the frozen snapshot |
| `deSousa__2008_Table5.1_snapshot.xlsx` (sheet `Table5.1`) | frozen source, printed layout and units |
| `deSousa__2008_Table5.1.R` | reads the snapshot, cleans, converts units, writes CSV + public TSV |
| `deSousa__2008_Table5.1.csv` | one row per specimen (29) |
| `reference_tables/deSousa__2008_Table5.1_definitions.csv` | data dictionary |

Structures: Total brain net volume, Area striata grey matter (left V1),
Corpus geniculatum laterale (left LGN), Neocortex.

## Who read the values, when, and how it was checked
The values were **not transcribed by hand**. `deSousa__2008_Table5.1_extract_snapshot.R`
reads them from the dissertation PDF's own text layer at run time
(`pdftools::pdf_data()`, page 209) and places each token in its printed column by
x-position; only the caption, the two header tiers and the footnote are printed
literals in the script. Extracted and checked by an AI assistant (Claude Science
session), 2026-09-25, three ways:

1. **Independent second extraction.** The same page was re-read with a different
   library and a different geometry model (`pypdfium2` character bounding boxes,
   rotated-page reconstruction). 29/29 rows, and all seven numeric columns,
   agree with the `pdftools` extraction — 0 differences.
2. **Printed fidelity.** The literal `NA` cells (ptd, ptw1) and the printed blanks
   survive verbatim in the snapshot; printed row order (hs14 → mf2) is preserved;
   the build script asserts 29 unique codes, the first/last printed row and the
   first brain volume.
3. **Against the published version of the same data** — see below.

## Comparison (restricted repo)
`Evo-M1-Trait-Data-restricted/restricted_checks/deSousa__2008/comparison/deSousa__2008_Table5.1_compare_to_deSousa_etal_2010_Table1.R`
(comparisons do not live in the public repo — `REPO_BOUNDARY.md` §3).

It joins the two tables **through `_keys/specimen_crosswalk/specimen_crosswalk.csv`**
(dissertation code ↔ 2010 archive label) rather than by name, so it also tests the
crosswalk. Result at the journal table's printed precision:

**0 value mismatches**, all 29 specimens matched — brain volume 29/29, correction
factor 29/29, left V1 29/29, brain mass 25/25, left LGN 27/27, neocortex 15/15
(the remaining cells are blank in *both* tables).

Two things the comparison establishes:

- **`mf2` / `ma22` left LGN.** The dissertation prints **0.05 cm³**. The 2010 paper
  printed `0` (a rounding-to-zero artefact at 1 d.p.) and the repo had reconstructed
  0.046 cm³ from Supp. Table 2. The dissertation confirms the repair independently.
- **Identifier defect found.** Five Yerkes codes are printed with an **en dash**
  (U+2013) in `deSousa_etal_2010_Table1.csv` (`YN81–146`, `YN82–140`, `YN85–38`,
  `YN86–137`, `YN89–278`) but with an ASCII hyphen in `specimen_crosswalk.csv`, so a
  literal join silently drops ouy, ggy, hly, pty and ppy. The comparison normalises
  dashes, but **the inconsistency should be fixed at source** in one of the two files.

## Data role — SECONDARY, not merged
These are the same 29 specimens and the same measurements later published as
`deSousa_etal_2010_Table1`, which is the item already carried in `__merging_volumes`
(Tier 2, averaged). This item is built for **provenance** and is deliberately **not**
added to any merge; ingesting it would double-count. Per §9 of the build HOWTO it is
still fully built (snapshot → comparison → TSV).

Provenance is split by measure and is **not** uniform:

| measure | whose data |
|---|---|
| left V1, left LGN | de Sousa's own measurements |
| neocortex (15 specimens) | supplied by **Carol MacLeod** (unpublished) |
| brain mass, correction factor, brain volume | Zilles-collection convention |

See `_keys/specimen_crosswalk/via_data_source_registry.csv`
(`PUB_DESOUSA_DISSERTATION_2008`): *"Do not label every dissertation value as a
de Sousa measurement merely because it appears in her table."*

## Laterality — LEFT and undoubled
`left_V1_volume_mm3` and `left_LGN_volume_mm3` are left-hemisphere volumes **as
measured**. The `left_` prefix is load-bearing: these must never be averaged against
a bilateral volume. The doubled version of the same measurements is
`deSousa_etal_2010_SupTable2`; both are registered in
`__merging_volumes/laterality_known.csv`.

## Printed oddities carried as-is
- The siamang is printed **"Syndactylus symphalangus"** — genus and species
  reversed. The snapshot keeps the printed string; the accepted binomial
  *Symphalangus syndactylus* is resolved through
  `_keys/Stephan/species_key.csv` (token `deSousa2008`), and the build script
  asserts that the resolution happened.
- `ptd`, `ptc1`, `ptc3`, `ptw1` have no printed brain mass and carry the pooled
  correction factor 2.05.
- Ages are a mix of years, `A` (adult), `JUV` and `6 or 7`; the printed string is
  kept in `age_as_published` and only bare numbers populate `age_yrs`.

## Units
Volumes printed in cm³ → **mm³** (×1000); body mass kg → **g**; brain mass g → **mg**.
The snapshot keeps the printed units. Values are rounded back to printed precision
after conversion (the ×1000 otherwise leaves binary floating-point noise).

## Observation level
**One row per specimen**, not per species. Pool to species means before any
species-level use.
