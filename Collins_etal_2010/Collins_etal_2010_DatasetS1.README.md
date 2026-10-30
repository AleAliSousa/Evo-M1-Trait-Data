# Collins et al. 2010 — Dataset S1

Collins CE, Airey DC, Young NA, Leitch DB, Kaas JH (2010). *Neuron densities vary across and within
cortical areas in primates.* PNAS 107(36):15927–15932. doi:10.1073/pnas.1010356107 · Team **Kaas**.

Registry (`__ReadMe.xlsx`): Item name **`Collins_etal_2010_DatasetS1`**, encoded
`10.1073%2Fpnas.1010356107_DatasetS1`; primary; method = isotropic fractionator.

## What the data are
Raw **per-tissue-piece** cortical cell/neuron counts from **one cortical hemisphere** of each of
**five specimens / four primate species** (SI p.1):

| specimen (case) | sheet | Species | common name | hemisphere | pieces | surface area? |
|---|---|---|---|---|---|---|
| galago #1 (07‑104) | 07104Galago | *Otolemur garnetti* | galago | left | 36 | yes |
| galago #2 (08‑07) | 0807Galago | *Otolemur garnetti* | galago | right | 12 | yes |
| owl monkey (07‑78) | 0778OwlMonkey | *Aotus nancymae* | owl monkey | left | 12 | yes |
| macaque (08‑59) | 0859Macaque | *Macaca mulatta* | macaque monkey | right | 42 | **no** (not flattened) |
| baboon (09‑27) | 0927Baboon | *Papio cynocephalus anubis* | baboon | (not stated) | 142 | yes |

244 tissue pieces total. Galago #1, macaque and baboon were cut as a numbered **grid**; galago #2 and
the owl monkey were dissected into identified cortical **areas** (piece_id = `V1`, `MT`, `DL`, …).

## Source → Snapshot
Supplement **`sd01 (1).xls`** (= Dataset S1) copied **verbatim** to
`Collins_etal_2010_DatasetS1_snapshot.xlsx` (all 5 specimen sheets, original headers/values, blank
cells kept). Frozen — all cleaning happens in the `.R`. (`Collins_etal_2010_text_snapshot.xlsx` is a
separate, earlier snapshot of density values quoted in the running text; not used for this per‑piece
build.)

## Data readable
`Collins_etal_2010_DatasetS1.R` → `Collins_etal_2010_DatasetS1.csv` (**use this**), one tidy row per
tissue piece. The five sheets use different column spellings and orders (and the owl‑monkey sheet has
its last two density columns swapped), so the script maps every column **by name, never by position**,
then adds `Species` / `common_name` / `specimen` / `hemisphere` from the SI. Columns are defined in
`reference_tables/Collins_etal_2010_DatasetS1_definitions.csv`.

## Data-quality notes (read before analysis)
- **NeuN percent unit clash.** In the **baboon** sheet `NeuN_Percent` is a **percentage** (e.g. 37.69),
  while every other sheet stores a **fraction** (e.g. 0.377). The original value is preserved verbatim
  in `neun_percent_printed`; a computed, unit-safe `neun_ratio = total_neurons/total_cells` is added —
  **use `neun_ratio`**.
- **Macaque has no surface area** — hemisphere 08‑59 was dissected but not flattened, so
  `surface_area_mm2`, `cell_density_per_mm2`, `neuron_density_per_mm2` are NA for that specimen.
- **piece_id kept verbatim** (includes `29a` and area codes) → stored as text.
- *Papio cynocephalus anubis* is the SI's trinomial (olive baboon); kept as published. This table is
  not part of a merge, so `_keys` was not modified.

## Per-hemisphere totals reported in the paper (context; not in the per-piece CSV)
galago #1: 2,261 mm², ≈326M cells, 127M neurons (39%) · galago #2: 1,849 mm², 243M cells, 107M
neurons (44%) · owl monkey: >553M cells, 212M neurons (38%) · macaque: ≈3.5B cells, 1.4B neurons (40%)
· baboon: 18,577 mm², 4.67B cells.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
