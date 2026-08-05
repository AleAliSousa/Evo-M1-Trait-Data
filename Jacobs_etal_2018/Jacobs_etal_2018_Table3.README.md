# Jacobs et al. 2018 — Table 3 (stereology: layer V pyramidal vs gigantopyramidal somata)

**Snapshot built 2026-08-04. Analysis CSV / public TSV / `.R` still to do locally (needs R).**

## Source

Jacobs, B., Garcia, M. E., Shea-Shumsky, N. B., Tennison, M. E., Schall, M., Saviano, M. S.,
Tummino, T. A., Bull, A. J., Driscoll, L. L., Raghanti, M. A., Lewandowski, A. H., Wicinski, B.,
Ki Chui, H., Bertelsen, M. F., Walsh, T., Bhagwandin, A., Spocter, M. A., Hof, P. R.,
Sherwood, C. C., & Manger, P. R. (2018). *Comparative morphology of gigantopyramidal neurons in
primary motor cortex across mammals.* **Journal of Comparative Neurology 526(3):496–536.**
DOI **10.1002/cne.24349** · PMID **29088505** · EndNote `[4950]`.

PDF in this folder (`Jacobs-2018-Comparative morphology of gigantop.pdf`, from the EndNote library).

**Printed source → snapshot required** (invariant 1). Table 3 is printed **rotated 90°** across
pp. 504–505; there is no journal-supplied data file. Captured from the PDF text layer and then
**verified cell-by-cell against rendered page images** of both halves.

## What Table 3 gives

Unbiased-stereology soma dimensions for **two neuron classes** — layer V pyramidal and
gigantopyramidal (= **Betz cells in primates**) — in **20 species: 11 carnivores + 9 primates**,
one animal per species. Six measure blocks, each with `n` / `Mean ± SD` / `Range`:

| Block | Unit |
|---|---|
| Pyramidal neuron lengths | µm |
| Gigantopyramidal neuron lengths | µm |
| Pyramidal neuron areas | µm² |
| Gigantopyramidal neuron areas | µm² |
| Pyramidal neuron volumes | µm³ |
| Gigantopyramidal neuron volumes | µm³ |

Plus per-species **body mass (kg)** and **brain mass (g)**. Areas were computed with the
*nucleator* probe in StereoInvestigator (paper's footnote a).

## Fidelity notes

- Values are carried **exactly as printed**, including `Mean ± SD` in one cell and ranges with the
  printed en dash. Nothing was recomputed or corrected.
- **Documented deviation:** the printed Species cell holds the common name on line 1 and the italic
  binomial on line 2. That one cell is split into `Species` / `Species_binomial` so the file is
  machine-readable; both printed strings survive verbatim (invariant 3). Printed clade rows
  (`Carnivores`, `Primates`) and printed row order are kept.
- **Print typos in the published table — carried verbatim, do NOT silently fix in the snapshot.**
  Fix them in the `.R` with a comment, so the correction is visible:

  | Species | Cell | As printed | Almost certainly meant |
  |---|---|---|---|
  | African wild dog | Pyr areas Range (low) | `20.11` | `120.1` (all other species 113–128) |
  | African wild dog | Pyr volumes Range (high) | `8,996.72` | `8,996.7` |
  | African wild dog | Gig volumes Range (high) | `55,734,1` | `55,734.1` |
  | Banded mongoose | Gig volumes Range (low) | `40,16.1` | `4,016.1` |
  | Siberian tiger | Pyr volumes SD | `14,71.9` | `1,471.9` |
  | Amur leopard | Gig areas Mean | `1,316` | `1,316.0` (no decimal printed) |
  | Lar gibbon | Gig lengths SD | `0.04` | possibly `0.4` — unresolved, flag on ingest |
  | Harp seal | Pyr volumes SD | `1233.7` | `1,233.7` (thousands separator missing) |
  | Red-tailed monkey | Gig volumes Range (high) | `4901.5` | `4,901.5` |
  | Vervet monkey | Pyr volumes Range (high) | `2929.2` | `2,929.2` |
  | Black-capped squirrel monkey | Gig lengths Range (high) | `11` | `11.0` |

## Verification done (2026-08-04)

Recomputed from the snapshot and matched against statistics the paper states independently in text:

| Check | From snapshot | Paper |
|---|---|---|
| Primate gigantopyramidal ÷ pyramidal **soma area** | **1.64** | 1.64 |
| Primate gigantopyramidal ÷ pyramidal **soma volume** | **2.30** | 2.3 |
| Vervet monkey gigantopyramidal area | 352.6 µm² | 352.6 |
| African lion gigantopyramidal area | 1,416.2 µm² | 1,416.2 |
| Vervet monkey gigantopyramidal volume | 5,636.5 µm³ | 5,636.5 |
| Asian small-clawed otter gigantopyramidal volume | 20,560.2 µm³ | 20,560.2 |
| Species count | 20 (11 carnivore + 9 primate) | 11 + 9 |

## Still to do (locally, with R)

1. `Jacobs_etal_2018_Table3.R`: snapshot → analysis CSV. Split `Mean ± SD` into `mean` / `sd`
   columns and `Range` into `range_min` / `range_max`; fix the print typos above **in the script**,
   each with an inline comment naming the printed value.
2. **Project units** (invariant 4): body mass kg → g (×1000), brain mass g → mg (×1000). Soma
   lengths/areas/volumes are µm/µm²/µm³ — regional cell morphology, **not** the mm³ structure-volume
   lineage; do not convert them to mm³.
3. Resolve `species_sci` via `_keys`; keep `Species` and `Species_binomial` printed.
4. Register in `__ReadMe.xlsx` (`Data role = primary` — this is original stereology),
   then write the DOI-coded public TSV (invariant 2).
5. Wire into `__merging_cellcounts` as a **regional (M1) sub-trait**, its own team — **never** pooled
   with whole-cortex neuron counts. See `README.md` (this folder).

## Relation to the rest of the repo

- This is the **primary** source that the former `Betz_cells_M1/` compile-from-literature scaffold was
  built to compile from — that scaffold is dissolved and this folder replaces it (see `README.md`).
  Nolan et al. 2024 is only the review entry point and must never be a row's `Source`.
- `neuron_class` (pyramidal vs gigantopyramidal) must stay an explicit column. The two classes are
  measured in the same cortex on the same animal — collapsing them would average a Betz cell with an
  ordinary layer V pyramidal neuron.
- Stereology here is **not interchangeable** with the Golgi 2-D measures in Table 5; flag `method`
  per datum, as the cellcount lineage does.
- Sits beside `Young_etal_2013` (M1 cell count / surface area / mass) as a regional-M1 sub-trait.
  Checked 2026-08-04: **no species collision and no measure collision** — see the overlap section in
  `Jacobs_etal_2018_Table5.README.md`.
