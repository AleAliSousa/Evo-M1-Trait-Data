# Stephan, Frahm & Baron 1987 — amygdala & amygdaloid components (Insectivora → Primates)

Stephan H, Frahm HD, Baron G (1987). *Comparison of Brain Structure Volumes in Insectivora and
Primates. VII. Amygdaloid Components.* Journal für Hirnforschung 28(5):571–584. (Received Sept 4, 1986.)
Part **VII** of the Stephan/Frahm/Baron series; same brain collection and methods as Stephan et al.
1981, 1982, 1984; Frahm et al. 1982, 1984; Baron et al. 1983, 1987.

Full table titles (for `__ReadMe.xlsx`):

- **Table 1** — "Volumes and indices of the amygdala (AMY) and amygdaloid components (LAM, MCB, MAM,
  NTO) in Macroscelidea, Insectivora and Scandentia"
- **Table 2** — "Volumes and indices of the amygdala (AMY) and amygdaloid components (LAM, MAM, MCB,
  NTO) in Primates. (0 = not determinable with certainty)"
- *(Table 3 — group-mean indices/percentages/ratios — is a derived summary and is **not** snapshotted.)*

## Source → Snapshot
Source is a **scanned PDF with a noisy OCR text layer** (`stephan_etal_1987_VII_scan.PDF`). Values were
triangulated three ways and agree: (1) independent OCR of the table pages, (2) visual read of the
rendered primate page, (3) the pre-existing extraction in `comparison/Stephan_1987.csv`. Internal
check **AMY = LAM + MAM** holds for all rows except one (see below).

- `Stephan_etal_1987_Table1_snapshot.xlsx` — printed Table 1 on PDF page 3 (44 non-primates:
  2 Macroscelidea, 39 Insectivora, 3 Scandentia).
- `Stephan_etal_1987_Table2_snapshot.xlsx` — printed Table 2 on PDF page 4 (45 primates:
  18 prosimians, 26 simians plus human).

The two XLSX sheets preserve printed group heading rows, source species order, and the five volume
columns followed by their five index columns. The earlier flat CSV snapshots omitted the indices
and encoded group headings as a data column; they were retired. The earlier Table 1 XLSX combined
both printed tables and sorted the species; that was also replaced. A separate species lookup holds
expanded labels and the prior analysis order.

89 species total — matches the paper's Methods exactly. The 89 indices rows were transcribed from
the rendered PDF pages; they remain in the snapshots, while the readers select volumes for the
existing analysis outputs. Human visual signoff is still open.

## Data readable
Run `Rscript --vanilla Stephan_etal_1987/Stephan_etal_1987_Table1.R` and
`Rscript --vanilla Stephan_etal_1987/Stephan_etal_1987_Table2.R` from the repository root.
Both generated analysis CSVs were checked cell for cell against their previous versions (89 and
45 rows respectively) and are unchanged. `Stephan_etal_1987_Table1.R` reads both printed-table
snapshots to retain its established 89-species output; `_Table2.R` reads the Table 2 snapshot.
These produce `Stephan_etal_1987_Table1.csv` / `_Table2.csv`
(**use these**). Species harmonized to `_keys/Stephan/species_key.csv` (all 89 matched via
`source_publication == "Stephan1987"`); `species_printed` retained for traceability.

## Amygdaloid anatomy (how the columns nest)
- **AMY** = whole amygdaloid complex. **AMY = LAM + MAM.**
- **LAM** = cortico-basolateral group ("lateral amygdala") = lateral + basal + cortical nuclei.
- **MCB** = magnocellular part of the basal nucleus — a **subset of LAM** (not added on top).
- **MAM** = centromedial group ("medial amygdala") = central + medial nuclei + anterior amygdaloid area.
- **NTO** = nucleus of the lateral olfactory tract — sits **within MAM**. In simians/man it is printed
  as **0 = "not determinable with certainty"** (≈ below resolution), *not* a true zero.

## Amygdala equivalency — the column that carries across datasets
`amygdala_total_mm3` (**AMY**) is the variable that is **compatible across the Stephan-lineage and
Barger datasets**:

| dataset | column | notes |
|---|---|---|
| Stephan et al. 1987 (this) | AMY | amygdaloid complex, mm³ |
| Stephan et al. 1981 | "Amygdala" | same collection/definition (part of the same series) |
| Zilles & Rehkämper 1988 | "amygdala" | hominoid chapter; same structure definition |
| Barger et al. 2007 | `amygdaloid_complex_total` | amygdaloid complex, both hemispheres (cm³ → ×1000 = mm³) |

See `comparison/Stephan1987_AMY_vs_Barger2007_AC.csv` for the head-to-head test on the shared
hominoids. **Agreed merge rule for the future Study-3 amygdala variable: average Stephan 1987 and
Barger where they overlap** (Homo, *Pan troglodytes*, *Gorilla gorilla*, *Hylobates lar*).

## Provenance / caveats
- Single Stephan/Frahm/Baron collection; values are species means (typically 1 specimen), fresh-volume
  corrected, mm³. Whether AMY is unilateral or bilateral is a known open question for the Stephan
  series — flagged in the comparison file (it bears on the Barger reconciliation).
- The faithful 1987 hominoids are only **Hylobates lar, Pan troglodytes, Gorilla gorilla, Homo sapiens**.
  *Pongo*, *Pan paniscus*, *Hylobates muelleri* in `comparison/Stephan_1987.csv` come from **other
  sources** (that file is a merged master list, not faithful 1987).
- *Setifer setosus* is printed AMY 68.7 though LAM+MAM = 71.1 — a rounding/measurement artifact in the
  original; kept as printed.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species harmonized ✅ → Barger cross-check ✅ → Online database ☐
