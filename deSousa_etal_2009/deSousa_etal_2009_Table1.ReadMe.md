# deSousa_etal_2009_Table1

## Source
de Sousa, A. A., Sherwood, C. C., Schleicher, A., Amunts, K., MacLeod, C. E., Hof, P. R., & Zilles, K. (2009/2010). Comparative cytoarchitectural analyses of striate and extrastriate areas in hominoids. *Cereb Cortex* 20(4), 966-981. Registry Item **Table 1**; DOI-coded TSV `10.1093%2Fcercor%2Fbhp158_Table1.tsv`. Held as the Advance Access PDF (`desousa_etal_2009_AdvanceAccess.pdf`, published 23 September 2009), which is why the folder is dated 2009.

**Samples used in analyses of V1, V2, and VP** — nine specimens of seven catarrhine species from the **Zilles comparative neuroanatomy collection** (C&O Vogt Institute, Düsseldorf), with the brain, body and visual-system variables the paper scaled its GLI data against. Volumes in mm³ (body g, brain mg), areas in mm².

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `deSousa_etal_2009_Table1_extract_snapshot.py` → `deSousa_etal_2009_Table1_snapshot.xlsx` (sheet `Table1`), `deSousa_etal_2009_Table1.R` → `deSousa_etal_2009_Table1.csv` (+ TSV), `reference_tables/deSousa_etal_2009_Table1_definitions.csv`, `comparison/deSousa_etal_2009_Table1_compare_to_deSousa_2010_Table1_csv.R`.

Structures: Neocortex, Area striata grey matter (left), Corpus geniculatum laterale (left), whole-brain mass, body mass, optic nerve, eye.

## Preparation → `deSousa_etal_2009_Table1.csv`
One row per **specimen** (9 rows; the sample is not aggregated to species means here). The source is a printed table, so the frozen copy is a snapshot: `..._extract_snapshot.py` holds the transcription and writes the sheet, and `--verify` re-reads the PDF with pdfplumber and asserts every transcribed token is on the page in its own printed row — **9/9 rows matched**. The snapshot keeps the printed caption, the three header tiers, the footnote markers attached to the strings that carry them (`Homo sapiensa,b`, `EQe`, `area (mm2)f`), the printed blanks and the printed row order, in the original units.

The reformat types the values, converts to project units (body kg→g, brain g→mg, neocortex cm³→mm³; V1/LGN are printed in mm³ and pass through), and splits the printed species cell in two: the name goes to `species_as_published` and its superscript footnote marker to `footnote_ref`. The marker is typography, not part of the name, so `species_as_published` is `Homo sapiens`, never `Homo sapiensa,b` — the snapshot flattens the superscript onto the epithet, and the tribble in the build script is what pulls it back off. The marker then drives the `body_mass_substituted` / `brain_mass_substituted` / `neocortex_substituted` flags plus `substitution_note`. Species harmonisation is left to `_keys/Stephan/species_key.csv` (token `deSousa2009`, which follows `deSousa2010`/`deSousa2013` for the same specimens: *Gorilla gorilla* → `Gorilla sp.`, *Pongo pygmaeus* → `Pongo sp.`).

## Data role — SECONDARY. Every macroanatomical column here is re-used data
This is the sample-description table of a **cytoarchitectural** study, and the paper says plainly where its size variables come from:

> "In most cases, these data were available for the individual specimens (de Sousa et al., unpublished data), but where not available, species means were used from the literature (Stephan et al. 1981)."

That "unpublished data" is what became **de Sousa et al. 2010 Table 1**. Column by column:

| column | primary source |
|---|---|
| left V1, left LGN, brain mass | `deSousa_etal_2010_Table1` (the same nine specimens) |
| **neocortex (whole column)** | **Carol MacLeod's own measurements**, `MacLeod_data.xls` Table II — the workbook she emailed in September 2002. Its brain/cerebellum/vermis/hemisphere columns are the published MacLeod et al. 2003 *J Hum Evol* table, but the **neocortex column was never published**. Held in the private repo `Evo-M1-Trait-Data-restricted` as `unpublished_data/____Unpublished__MacLeod_neocortex/` and subject to her conditions of use |
| optic nerve cross-sectional area, eye half surface area | Stephan & Frahm 1981 species means (footnote f — the value repeats within a species) |
| human neocortex (both rows) | the same MacLeod workbook: 974 cm³ is the mean of her eight humans (973.9987 — reproduced exactly), which is what footnote b's "combined sex mean human neocortex value (n = 8) … unpublished data provided by Carol MacLeod" refers to |
| *Homo* body mass | Zilles 1972 same-sex species mean (footnote a) |
| *Pan paniscus* body mass | Jungers & Susman 1984 same-sex species mean (footnote c) |
| ptd brain + body mass | Herndon et al. 1999 combined-sex species means (footnote d) |
| EQ | derived — Martin 1981 / Ruff et al. 1997 |

The paper's **own** primary measurements — species mean GLI values, layerwise GLI, relative laminar widths — are published only in Figures 5–7 and are never tabulated, and Tables 2–4 are derived statistics (RMA regressions, Euclidean distances, PCA loadings), which this project does not transcribe. So the item is built for provenance and **excluded from `__merging_volumes`** (`Data role = secondary`); nothing here is merged and nothing is double-counted.

## Why it is still worth having: it is the precise copy of the left V1/LGN volumes
2009 prints these volumes in **whole mm³**; 2010 prints the same measurements in **cm³ to one decimal place**. For LGN that is a coarse grid (0.1 cm³ = 100 mm³), and this table resolves it:

| specimen | left LGN, 2009 (mm³) | left LGN, 2010 (cm³) |
|---|---|---|
| ggy *Gorilla gorilla* | 150 | 0.2 |
| hs5 *Homo sapiens* | 186 | 0.2 |
| hs6 *Homo sapiens* | 156 | 0.2 |
| ppz *Pan paniscus* | 130 | 0.1 |
| **mf2 *Macaca fascicularis*** | **46** | **0.0 as printed → 0.046 reconstructed in `deSousa_etal_2010_Table1.csv`** |

The macaque row is the useful one. 2010 Table 1 printed its left LGN as `0` (it rounds to zero at one decimal place), and this project reconstructed it as `0.046 cm³` from Supplementary Table 2's bilateral 0.092 ÷ 2. **This table prints 46 mm³ directly, confirming that reconstruction exactly.**

## Laterality — LEFT, and printed undoubled
> "Included were sections from the left hemispheres of adult specimens."

The printed V1 and LGN volumes are the measured left side, **not** doubled: they reproduce `deSousa_etal_2010_Table1`, which the project already records as `doubling = none`. The author-doubled (2 × left) figures for these species are in `deSousa_etal_2010_SupTable2` (`doubling = by_source`), not here. Registered in `../__merging_volumes/laterality_known.csv` as `side = left, doubling = none, required_suffix = _left`, so that if this item is ever wired into a merge it can never be averaged against a both-sides volume, nor doubled a second time.

## Comparison / QA → `comparison/`
`deSousa_etal_2009_Table1_compare_to_deSousa_2010_Table1_csv.R` audits three things and writes `..._comparison_report_from_R.csv` (+ `..._mismatches_from_R.csv`). Specimens are matched by archive number after normalising the en dash and the accession fraction (`YN82-140` ↔ `YN82–140`, `Disco` ↔ `Disco 3/97`). Because the two prints have different precision, a value counts as matching when it agrees to **half the last printed digit of the coarser print** (0.05 cm³ against 2010's one decimal place; 0.5 against a whole number).

- **A. values vs de Sousa 2010 Table 1 — 31 match, 1 mismatch, 3 `2009 only` + 1 `both missing`.** All 9 left V1 and all 9 left LGN values agree; brain mass agrees for 8 (the 9th, ptd, has no 2010 value because 2009 prints the Herndon species mean); neocortex agrees for 5, is 2009-only for the two *Homo* rows (MacLeod mean), missing in both for mf2, and mismatches for ppz — see the flag below. The `2009 only` / `both missing` rows are provenance, not errors (`__HOWTO_build_a_dataset_file.md` §7).
- **B. specimen identity vs the restricted master catalog** — the private audit confirms that the
  paper's `code` field corresponds to the catalog's working-code field and checks the printed sex and
  age. Exact catalog identifiers and row-level matches are retained in
  `Evo-M1-Traits-Data-restricted/restricted_checks/deSousa_etal_2009/`, not in this public note.
- **C. internal consistency of EQ** — recomputing EQ = brain(g) / (11.22 × body(kg)^0.75) reproduces every printed EQ to within **0.055** (worst case *Hylobates lar*, 2.54 printed vs 2.485), the expected effect of the masses being printed rounded.

## FLAG — the ppz (*Pan paniscus*, Zahlia) neocortex is another bonobo's value
Table 1 prints **279 cm³** of neocortex for `ppz` / Zahlia. Zahlia's own neocortex is **214.4 cm³**; **279.0** belongs to a *different* bonobo of the same collection, **YN86–137**. Every other Zahlia value in the 2009 row (brain mass 324 g, left V1 5687 mm³ ≈ 5.7 cm³, left LGN 130 mm³ ≈ 0.1 cm³) matches Zahlia, so the error is confined to this one cell.

**How it happened is now known.** The neocortex column comes from Carol MacLeod's `MacLeod_data.xls` Table II, and that sheet labels its specimens **anonymously** — `PAN PANISCUS H1`, `PAN PANISCUS H2`, and so on, with no archive numbers. `H1` is YN86-137 (278.968) and `H2` is Zahlia (214.405). The 2009 table took the wrong H-row for the bonobo. This is exactly the risk Carol warned about when she asked that "the specimens [be kept] in the same format as the published JHE volumes (i.e., Homo sapiens(139/95)" — the crosswalk that resolves her H-numbers to named specimens is now `unpublished_data/____Unpublished__MacLeod_neocortex/MacLeod_specimen_crosswalk.csv` in the private repo.

The value is **kept as printed** in both the snapshot and the CSV, and flagged here, in `reference_tables/…_definitions.csv`, and in `__ReadMe.xlsx` (`Flags pre-addressed`). Unlike the de Sousa 2010 Supplementary Table 2 neocortex error — 13 of 17 values physically impossible, so corrected in the data — this is a real measurement of a real specimen, printed against the wrong animal. Since the column is secondary and not merged, no value in the project depends on it; the bonobo neocortex the merge uses comes via `deSousa_etal_2010_Table1`, where Zahlia carries her own 214.4.

## Note
Two further differences from 2010 Table 1 are rounding, not disagreement, and are carried as printed: brain mass 58 g vs 57.6 g (mf2) and 360 g vs 359.5 g (ptb). Tables 2–4 of this paper are derived statistics and are deliberately not built. If the merge is ever changed to prefer this table's mm³ precision over 2010's rounded cm³ for the nine shared specimens, that is a `__merging_volumes` decision (conflict-resolution rule 1, "revised value") and needs the usual regression re-check — it is **not** done by this build.
