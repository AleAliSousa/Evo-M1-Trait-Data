# Nudo et al. 1995 — TABLE 5 (nine other morphological characteristics of corticospinal somata)

**Built 2026-08-06.**

| File | |
|---|---|
| `Nudo_etal_1995_TABLE5_snapshot.xlsx` | frozen source (sheet `TABLE5`) |
| `Nudo_etal_1995_TABLE5.R` | reformat: snapshot → CSV (+ TSV) |
| `Nudo_etal_1995_TABLE5.csv` | analysis table — **24 rows = 24 species**, 16 columns |
| `reference_tables/Nudo_etal_1995_TABLE5_definitions.csv` | data dictionary (16 codes) |

Registry: `Item name = Nudo_etal_1995_TABLE5`, `Item encoded = 10.1002%2Fcne.903580203_TABLE5`.

## Source

Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). J Comp Neurol 358(2):181–205.
DOI 10.1002/cne.903580203. TABLE 5 is printed full-width on **journal p. 188 = PDF p. 8**.

**Printed/scanned source → snapshot required** (invariant 1). Read off 300-dpi renders, then
cross-checked against the PDF text layer by coordinate-matched word extraction: **18 of 24 rows
agree exactly**; the 6 that differ are all OCR faults, each re-read on a render:

| row / cell | snapshot | OCR text layer | how settled |
|---|---|---|---|
| Armadillo column height | `2.51` | `2 51` | decimal point dropped |
| Cat concentration (large cells) | `69.0` | `69 0` | decimal point dropped |
| Ground squirrel condensation | `93.7` | `93 7` | decimal point dropped |
| Hedgehog `E.e.` % medial-lateral | `32` | *(token missing)* | OCR dropped the cell; read at 300 dpi |
| Monkey `C.a.` thickness | `0.37` | `0 37` | decimal point dropped |
| **Slow loris condensation** | **`94.0`** | `94.1` | **re-rendered at 900 dpi**: the zero is ink-broken but identical in shape to the zero in `91.0` two rows below. The OCR digit is wrong. |

The slow-loris cell is the only place where the transcription **overrides** an OCR digit rather
than just recovering lost punctuation; it is called out here for that reason.

## The nine characteristics

| column | printed header | note |
|---|---|---|
| `avg_surface_density.cells_per_mm2` | Avg surface density (cells/mm²) | total CS somata ÷ the neocortical area containing them |
| `CS_layer_thickness.mm` | Thickness **(µm)** | **printed unit is wrong — see below** |
| `max_volume_density.cells_per_mm3` | Maximum volume density (cells/mm³) | |
| `column_height.cells` | Column height (cells) | max somata stacked in a 30 µm × 50 µm slab; stereologically corrected, hence non-integer |
| `concentration_pct` | Concentration (%) | CS somata ÷ all layer-V somata under a 1 mm × 50 µm sample, in the densest zone |
| `concentration_large_cells_pct` | Concentration (large cells; %) | same, counting only somata ≥ the smallest labelled soma |
| `rostral_caudal_density_ratio` | Rostral/caudal | rostral (motor) density peak ÷ caudal (sensory) peak, within region A |
| `condensation_pct` | Condensation | % of region A below 40 % of peak density |
| `medial_lateral_position_pct` | % Medial-lateral distribution | position of the peak-density zone across region A |

## Units — one printed unit is wrong

**`Thickness (µm)` is a printed-unit error: the values are millimetres.**

- printed header: `Thickness (µm)`; printed values: **0.10 – 0.71**
- the paper's own text, p. 187: *"The highest value was found in slow loris (**0.71 mm**) and the
  lowest was found in short-tailed opossum (**0.10 mm**)"* — the same two numbers, called mm.
- 0.71 µm would be smaller than one soma; 0.71 mm is a plausible layer-V thickness.

**The number is carried unchanged; only the unit is corrected**, in the column name
(`CS_layer_thickness.mm`) and in `Measure = thickness.mm`. The printed header survives in the
snapshot and the printed-vs-corrected pair is recorded in the definitions `Source Note`.

Everything else is carried in its printed unit: cells/mm², cells/mm³, cells, percentages and one
dimensionless ratio. No §6 conversion applies (these are areal/volumetric *cell densities*, not the
mm³ structure-volume lineage).

## Blank vs zero — `n/a` is missing, and there are no zeros

TABLE 5 prints the token **`n/a`** in exactly four cells, and no other blank, dash or zero:

| cell | reading |
|---|---|
| Hyrax — `concentration_pct` | **NA** — not measured |
| Armadillo, Hyrax, Least shrew — `concentration_large_cells_pct` | **NA** — not measured |

These are genuine missing values, **unlike** the printed `0`s in TABLES 2 and 4, which mean "this
cortical region does not exist in this species". No cell in TABLE 5 is printed as `0`.

## Printed values distrusted / flagged — 1 of 24 rows

| species | flag | verdict |
|---|---|---|
| Rabbit | order printed **`Lagamorpha`** | Print typo (also TABLES 2 and 4; TABLE 3 prints `Lagomorpha`). `Order_resolved = Lagomorpha`; correction named in `parse_flags`. |

The cat row prints `Carnivora` correctly here (the `Camivora` typo is confined to TABLE 2).

## ⚠ The paper's text contradicts its own TABLE 5 — average surface density

This is the one substantive problem in the paper, and **the table values are the ones carried**.

Text, p. 187: *"The average surface density for each of the species is listed in Table 5. The mean
average density for the 24 species was **260** cells/mm² with the highest in **mole (587)** and
**bushbaby (583)** and the lowest in **crab-eating macaque (62)**, which is more than a ninefold
difference."*

| | text says | TABLE 5 prints |
|---|---|---|
| mean over 24 species | 260 | **325.9** |
| mole | 587 | **802** |
| bushbaby | 583 | **830** |
| crab-eating macaque (lowest) | 62 | **76** |
| ratio highest : lowest | 9.5× ("ninefold") | 10.9× |

The text does correctly identify *which* species are highest and lowest — mole and bushbaby are the
top two in the printed column (830, 802) and crab-eating macaque is the lowest (76) — so it is the
same ranking with different numbers, most likely a paragraph left over from an earlier version of
the data. **Nothing is corrected.** The printed table is the frozen source and the analysis CSV
carries the printed column; the `.R` prints the discrepancy on every run so it cannot be forgotten.

*(No such conflict exists for the other columns — see the verification table below.)*

## Verification — every check and its result

| # | check | from the snapshot | paper text |
|---|---|---|---|
| 1 | rows | **24** | 24 species |
| 2 | `n/a` cells | exactly 4, as listed above | — |
| 3 | mean column height | **3.80** | 3.85 (close; the paper does not say how it averaged) |
| 4 | highest / lowest column height | bushbaby 7.61 / rhesus 2.23 | same, "threefold" (3.41×) ✔ |
| 5 | mean max volume density | **5,446** | 5,606 (close) |
| 6 | highest / lowest max volume density | mole 17,848 / rhesus 1,196 | same; ratio 14.9× vs "nearly 15-fold" ✔ |
| 7 | mean concentration (23 species, hyrax `n/a`) | **23.45 %** | 22.9 % (close) |
| 8 | highest / lowest concentration | ground squirrel 36.8 / crab-eating macaque 9.1 | same; ratio 4.04× vs "fourfold" ✔ |
| 9 | highest / lowest thickness | slow loris 0.71 / short-tailed opossum 0.10 | same; ratio 7.1× vs "sevenfold" ✔ |
| 10 | highest / lowest condensation | green monkey 99.0, crab-eating macaque 98.9 / short-tailed opossum 78.7 | same ✔ |
| 11 | mean avg surface density | **325.9** | **260 — CONFLICT, see above** |
| 12 | every percentage column within 0–100 | 24/24 hold | — |
| 13 | avg surface density ≤ TABLE 4 region-A maximum, per species | **24/24 hold** | — |
| 14 | CS-labelled area = TABLE 2 `#CSN` ÷ avg surface density ≤ TABLE 1 neocortical area | **24/24 hold** (4.3 %–27.6 % of neocortex) | — |
| 15 | row order and species set identical to TABLES 2 and 4 | ✔ | — |

**Not usable as a check:** the paper defines maximum volume density as *max surface density ÷
layer thickness*, but recomputing it from the printed 2-dp thickness gives only ≈0.83–1.00 (median
0.89) of the printed thickness — the authors evidently divided by an unrounded thickness. The
printed volume density is carried as printed and **not** recomputed.

## Species names

As in TABLES 2 and 4, the species is printed only as genus/species initials. The printed cell
survives whole (`Animal_Nudo1995`) and split; `species_sci` is resolved **through the species key**
(`Nudo1995` rows in `PROPOSED_species_key_rows.csv`), never hand-coded. All 24 resolve; see the
TABLE 1 README for the six remapped names and the one ambiguous case.

## Data role

**`primary`** — the paper's own measurements, and nine measure classes distinct from TABLES 2 and 4
(no double-counting risk). Note the paper's own caveat (p. 199): soma diameter and the derived
densities are sampled in the *densest* labelled zone, so they over-estimate the whole-population
mean.

## Still to do (locally, with R)

1. **Re-run `Nudo_etal_1995_TABLE5.R` in RStudio** — the committed CSV was produced by an offline
   Python mirror. The `.R` is canonical.
2. Merge `PROPOSED_species_key_rows.csv` into `_keys/`, then delete the staged file.
3. Public TSV not written in this session; the `.R` writes it.
