# deSousa__2008_Table4.1

## Source
de Sousa, A. A. (2008). *Hominoid brain organization: Histometric and morphometric
comparisons of visual brain structures* [Ph.D., The George Washington University].
UMI:3311323. Registry Item **Table 4.1**, printed p. 120 (PDF page 139, landscape).

**Samples used in analyses of V1, V2, VP and V5** — 9 catarrhine specimens ×
13 printed columns. The dissertation chapter analysed **V5 as well** as V1, V2 and
VP; the published title drops V5.

## Why this item exists
Two reasons, both about provenance rather than new data.

1. **It closes the registry's Table 4.1 claim.** `specimen_source_registry.csv`
   long described `PUB_DESOUSA_DISSERTATION_2008` as "Tables 4.1 and 5.1" while no
   row anywhere carried a Table 4.1 reference. The table is now built, so the claim
   resolves to something real.
2. **It is the unrounded version of `deSousa_etal_2009_Table1`.** The journal
   rounded; the dissertation did not. **35 cells carry more precision** than the
   published table — body mass 84.70 vs 85 kg, 6.80 vs 7, 62.53 vs 63, 2.90 vs 3;
   neocortex 254.31 vs 254 cm³; left V1 4043.62 vs 4044 mm³; left LGN 150.06 vs
   150 mm³; optic nerve CSA 8.36 vs 8.4 mm².

Its nine specimens are a subset of dissertation Table 5.1, so the item also ties the
2009 paper's archive numbers to the dissertation specimen codes.

## Pipeline
PDF text layer → snapshot → R → usable csv/tsv.

| file | role |
|---|---|
| `deSousa__2008_Table4.1_extract_snapshot.R` | reads the PDF text layer, writes the frozen snapshot |
| `deSousa__2008_Table4.1_snapshot.xlsx` (sheet `Table4.1`) | frozen source, printed layout and units |
| `deSousa__2008_Table4.1.R` | reads the snapshot, cleans, converts units, writes CSV + public TSV |
| `deSousa__2008_Table4.1.csv` | one row per specimen (9) |
| `reference_tables/deSousa__2008_Table4.1_definitions.csv` | data dictionary |

Column names match the sibling item `deSousa_etal_2009_Table1.csv` so the two join
directly on `code`.

## Who read the values, when, and how it was checked
Read from the dissertation PDF's own text layer at run time
(`pdftools::pdf_data()`, page 139), placed by printed x-position; only the caption,
the three header tiers and the six footnotes are printed literals. Extracted and
checked by an AI assistant (Claude Science session), 2026-09-25.

**Footnote superscripts.** The markers `a`, `b`, `c`, `d` are set above the baseline,
so the text layer returns them on their own short line a couple of points above the
species row, in the gutter between the species name and the code column. The extract
collects them from that gutter and glues them to the species string
(`Homo sapiensa,b`) — how the page reads, and how the sibling snapshot
`deSousa_etal_2009_Table1_snapshot.xlsx` stores them. The build splits them back into
`footnote_ref`, stripping a suffix **only when the remainder is a name the species
key already knows**, so the final `a` of *Gorilla gorilla* is never eaten. The build
asserts the recovered markers are exactly `a,b` ×2 plus `c` and `d`.

## Comparison (restricted repo)
`Evo-M1-Trait-Data-restricted/restricted_checks/deSousa__2008/comparison/deSousa__2008_Table4.1_compare_to_deSousa_etal_2009_Table1.R`
(comparisons do not live in the public repo — `REPO_BOUNDARY.md` §3).

**0 value mismatches** at the journal table's printed precision: EQ 9/9, body mass
9/9, brain mass 9/9, left V1 9/9, left LGN 9/9, age 8/8, neocortex 8/8, optic nerve
8/8, eye surface 8/8 — every remaining cell blank in *both* tables (mf2 neocortex,
ppz optic nerve and eye area, ptd age).

The tolerance is computed in the **printed** unit, not the project unit: body mass
printed as `85` kg becomes 85000 g after the ×1000 conversion, and half a printed
unit is 500 g, not 0.5 g. `..._precision_gained_from_R.csv` lists the 35 cells where
the dissertation is finer.

## Data role — SECONDARY, not merged
`deSousa_etal_2009_Table1` is itself registered secondary: every macroanatomical
column in it is re-used data. The same holds here, and the dissertation chapter's own
primary measurements (GLI values, relative laminar widths) are published only in
figures, not tabulated. Built for provenance; **not** added to any merge.

Provenance by column, from the printed footnotes:

| column | whose data |
|---|---|
| left V1, left LGN | de Sousa's own measurements |
| neocortex (hs5, hs6) | combined-sex human mean, n = 8, supplied by **Carol MacLeod** (unpublished) — footnote b |
| body mass (*Homo*) | Zilles 1972 — footnote a |
| body mass (*Pan paniscus*) | Jungers and Susman 1984 — footnote c |
| brain + body mass (ptd) | Herndon et al. 1999 — footnote d |
| EQ | derived, after Martin 1981 / Ruff et al. 1997 — footnote e |
| optic nerve CSA, eye half surface area | Stephan and Frahm 1981 species means — footnote f |

## Laterality — LEFT and undoubled
`left_V1_volume_mm3` and `left_LGN_volume_mm3` are left-hemisphere volumes as
measured; the `left_` prefix is load-bearing.

## Units
Neocortex cm³ → **mm³** (×1000); body mass kg → **g**; brain mass g → **mg**. Left V1
and left LGN are printed in mm³ and left unconverted; the two areas stay in mm².
Values are rounded back to printed precision after conversion.

## Observation level
**One row per specimen.** Note that several columns are species means substituted for
a missing individual value (footnotes a, c, d, f) — see `footnote_ref`.
