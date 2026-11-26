# WongRiley_etal_1993_Text

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla WongRiley_etal_1993/WongRiley_etal_1993_Text.R` wrote `__Public/comparative-data/10.1017%2FS0952523800003217_Text.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `WongRiley_etal_1993_Text` · **Item number** `Text` (mirroring Kennedy_etal_1978_Text) · **Item encoded** `10.1017%2FS0952523800003217_Text` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `WongRiley_etal_1993_Text_registry_row.xlsx`.

Wong-Riley, M. T. T., Hevner, R. F., Cutlan, R., Earnest, M., Egan, R., Frost, J., & Nguyen, T. (1993). Cytochrome oxidase in the human visual cortex: Distribution in the developing and the adult brain. *Visual Neuroscience*, 10(1), 41-58. <https://doi.org/10.1017/S0952523800003217>

**Item full original title:** Values printed in running text: MATERIALS AND METHODS (p. 42), RESULTS (pp. 42, 44, 45, 47, 49) and DISCUSSION "Supragranular puffs" (p. 56). The paper prints no table.

## Source

PDF in this folder: `Wong-Riley-1993-Cytochrome oxidase in the huma.pdf` (Cambridge University Press scan with OCR text layer, 18 pages = journal pp. 41-58). DOI verified against the page-foot stamp and CrossRef on 2026-11-18 (Visual Neuroscience 10: 41-58, 1993; 7 authors).

## What quantitative content the paper has

All 18 PDF pages were inspected as page images:

- **Tables:** none (no numbered table anywhere).
- **Figures:** Figs. 1-6, 8, 9, 11 are photomicrographs (Nissl, CO histochemistry, CO immunohistochemistry); Figs. 7 and 10 are stippled schematic diagrams of laminar CO staining across V1, V2 and four extrastriate loci with **no axis and no numeric scale** — nothing digitisable. No bar chart, no densitometric profile. Hence no `_Figure<N>` item.
- **Text:** 84 printed numeric lexemes — specimen demographics and methods (p. 42), laminar thicknesses at 26 weeks gestation, birth, 4 months and adult (pp. 42-45), puff dimensions / spacing / density (pp. 44-45, 56), V2 globular-zone and stripe dimensions (pp. 47, 49), and **the only quantitative CO values: percent optical-density differences between IVcα and IVcβ** (newborn 7 %, P < 0.01, p. 44; 4-month 10 %, P < 0.01, p. 44; adult 5-14 % across cases, P < 0.01 in every case, p. 45). Absolute optical densities are not printed.

## Pipeline

```
Source (PDF)
  -> WongRiley_etal_1993_Text_snapshot.R   writes the frozen snapshot (hand-typed printed-text block)
  -> WongRiley_etal_1993_Text_snapshot.csv   FROZEN: 85 rows x 14 cols (header + 84 printed values)
  -> WongRiley_etal_1993_Text.R   parse + harmonise units + table checks
  -> WongRiley_etal_1993_Text.csv   84 rows x 37 cols  ("use this")
  -> internal_checks/WongRiley_etal_1993_Text_table_checks.csv   13 checks
  -> __Public/comparative-data/10.1017%2FS0952523800003217_Text.tsv   (written by the build once registered)
  -> reference_tables/WongRiley_etal_1993_Text_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from 220-dpi renders of PDF pages 2, 4, 5, 7, 9 and 16 (`pdfplumber`), typed as a verbatim printed-text block into `WongRiley_etal_1993_Text_snapshot.R` (freezes, refuses to overwrite a differing copy). The OCR text layer was used to cross-read words only: it drops or garbles the Greek sublayer subscripts (IVcα → "IVc a", IVcβ → "IVc^" / "IVc0" / "IVcg"), the micro sign ("/xm", "fim", "pm", "/tm") and at least one digit group ("1.'4-1.7"). Every number was read from the page image.

The build script `WongRiley_etal_1993_Text.R` reads the frozen file and contains no printed value. It was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) from a clean session on 2026-11-18; it stops, as expected, at `Expected one registered item row for WongRiley_etal_1993_Text` because the item is not yet registered (the analysis CSV and the checks file are written before that point).

### Constructed snapshot

There is no printed table: the snapshot is **constructed**, one row per printed value lexeme, with page, section, location and the sentence it comes from (quoted). Fidelity decisions: a printed range (`2.1-2.5 mm`) is ONE row (`value_printed` keeps the range; the build parses `value_low`/`value_high`); a range plus a printed mean gives two rows; `~`, "approximately", "at least", "up to", "or more" are kept in `stat_as_printed`; P values in `significance_as_printed`; author-year citations in `cited_ref`. Legibility: p. 44 "approximately 1.'4-1.7 mm thick" has a stray mark between "1." and "4" in the scan; read as 1.4-1.7 (text row 21, flagged in `note`).

## Table checks

13 checks in `WongRiley_etal_1993_Text.R`, result in `internal_checks/WongRiley_etal_1993_Text_table_checks.csv`: **13 pass, 0 mismatch, 0 not evaluable** (run of 2026-11-18).

| check | basis | observed | printed | tol | status |
|---|---|---|---|---|---|
| adult_laminar_sum_low | I + II/III + IVb + IVcα + IVcβ + V + VI (range lows) vs total 2.1 mm | 2.03 | 2.1 | 0.1 | pass |
| adult_laminar_sum_high | same, range highs vs total 2.5 mm | 2.47 | 2.5 | 0.1 | pass |
| fourmonth_IVc_sublayers | IVcα 0.21 + IVcβ 0.29 vs IVc 0.51 | 0.50 | 0.51 | 0.01 | pass |
| restatement_320 / 450 / 650 / 800 / 2to3 | Discussion p. 56 vs Results p. 45 | equal | equal | 0 | pass (5) |
| mean_*_in_range | printed means 340 µm, 2.35 puffs/mm2, 0.65 mm, 0.8 mm inside their printed ranges | 1 | 1 | 0 | pass (4) |

## Data role

**primary** for this paper's own measurements, methods and demographics (75 rows). **secondary** (`data_role`), row by row, for the 9 values the paper quotes from other work for comparison on pp. 44 and 56 (squirrel-monkey and macaque puff dimensions, spacing and density: Carroll & Wong-Riley 1984; Wong-Riley & Carroll 1984b; Horton 1984; Purves & LaMantia 1990; Schein & de Monasterio 1987; Horton & Hedley-Whyte 1984 human density 1.25-1.67 puffs/mm2; two macaque spacings stated without a printed citation). The authors' own unpublished macaque datum (6.08 puffs/mm2) is `value_status = unpublished_own`, primary. Do not merge the secondary rows as Wong-Riley 1993 data; they are a roadmap for primary ingestion of the cited papers.

## Species names

The text prints "human" / "man" for its own specimens and common names for the cited comparisons. Six variant rows (`human`, `man` → Homo sapiens 9606; `macaque monkey`, `macaque`, `monkey` → Macaca sp. 9539, genus-level because the cited macaque species is not printed; `squirrel monkey` → Saimiri sciureus 9521, following the existing key rows) with `source_publication = WongRiley_etal_1993` were appended to `_keys/General/species_key.csv` on 2026-11-18; the build resolves `Species` through them and stops if the key filter returns no rows.

## Use for the laminar-metabolism question (adult human V1, `adult_flag = TRUE`)

- **Quantified:** IVcα has 5-14 % lower CO optical density than IVcβ in every adult case (P < 0.01), i.e. IVcα/IVcβ ≈ 0.86-0.95 (`OD_ratio_lower_over_reference_low/high`, text row 61; n = 24 adult brains analysed, per-case range, no mean ± SD). Reversed in the newborn (IVcβ proper 7 % lower than IVcα, row 27) and already adult-like at 4 months (IVcα 10 % lower, row 37). Adult laminar thicknesses (rows 45-46, 58-60, 62-63) give the depth frame for pairing with BigBrain layers and receptor strata.
- **Ordinal only — NOT built, no numbers invented.** The full laminar CO profile of adult V1 is described in words (pp. 44-45): IVc most darkly reactive, with the lower half to three-fourths of IVcβ the darkest > IVcα; VI moderate-to-darkly reactive (upper half especially); II/III puffs reactive against less-reactive interpuffs; V light-to-moderately reactive; IVb lightly reactive (upper boundary blends with interpuffs); I rather lightly reactive (inner third least reactive in the neonate); IVa not demarcable by CO. V2 (pp. 47, 49): CO-rich globular zones from lower II to mid IV superimposed on a moderately reactive layer III, organised in stripes orthogonal to the V1/V2 border; areas beyond V2: layers III and IV high (continuous rather than globular), VI moderate, V less reactive, anteriormost occipital cortex lightest. A constructed **ordinal** laminar table (rank per layer per area: V1, V2, extrastriate) is a possible future item (`WongRiley_etal_1993_OrdinalLaminar`); it was not built here because the paper gives no numeric scale and the house rule forbids inventing one.
- **Not in the paper:** absolute optical densities; any V1-vs-V2 numeric comparison; blob/interblob ratios (puff vs interpuff is described only as "less-reactive").

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to lay the snapshot beside pages 42, 44, 45, 47, 49 and 56, read a sample of rows (including the three CO percent rows 27, 37, 61 and the adult thickness rows 44-46, 58-63), and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.
