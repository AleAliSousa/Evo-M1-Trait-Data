# Collins et al. 2010 — Dataset S1

Collins CE, Airey DC, Young NA, Leitch DB, Kaas JH (2010). *Neuron densities vary across and within
cortical areas in primates.* PNAS 107(36):15927–15932. doi:10.1073/pnas.1010356107 · Team **Kaas**.

Registry (`__ReadMe.xlsx`): Item name **`Collins_etal_2010_DatasetS1`**, encoded
`10.1073%2Fpnas.1010356107_DatasetS1`; primary; method = isotropic fractionator.

**Status: wired 2026-11-24** into `__merging_cell_counts_isotropic_fractionator` (team Kaas; dataset `Cell counts`; owner decisions of that day). Served: the named areas of galago 08-07 and owl monkey 07-78 (V1, V2, dV3, vV3, S1, M1, A1, MT, DL), and the whole neocortex of all five cases as the sum of this table's pieces (a sum made by the project; whether a case's sum is served is a recorded decision per case, `__merging_cell_counts_isotropic_fractionator/Collins_etal_2010_case_decisions.csv`). The galago's whole-neocortex cells and neurons are the mean of cases 08-07 and 07-104. One-hemisphere weights and numbers are served as the 2 × estimate (marked) and as measured (`_right_` / `_left_` by case; `_unilateral_` for the two-case galago mean, a right and a left hemisphere). Animals shared with Young et al. 2013 are counted once. Not served: the weight of galago 07-104 and any density from it (see **Internal check**); the whole-hemisphere figures of the paper's text for galago 07-104 and macaque 08-59, which disagree with this table (registered). The merge takes the side of baboon 09-27 (right) from the paper's Fig. 3 legend and Young et al. 2013b Table S1; this table's `hemisphere` column still has none for it. Details: `__merging_cell_counts_isotropic_fractionator/README__merging.md`, **Step 7b** and **Step 7c**.

## What the data are
Raw **per-tissue-piece** cortical cell/neuron counts from **one cortical hemisphere** of each of
**five specimens / four primate species** (SI p.1):

For Charvet et al. (2013) Figure 7, the seven V1 pieces of macaque 08-59 are
**6, 7, 9, 10, 11, 12, and 13**. This mapping uses the V1 outline and density
labels in Collins Figure 2 (printed p. 15929), aligned to the numbered macaque
sample map in SI Figure S3 (SI p. 3). Their Dataset S1 values sum to
**220,430,950 neurons** and **1.557 g** of tissue in the right hemisphere.
Piece 8 (153 million neurons/g) lies outside the V1 outline despite its high
density. The source did not measure surface area for this macaque, and tissue
mass is not itself V1 volume: a mass-to-volume assumption is needed before
placing this result on Charvet's volume axis. The piece mapping is a visual
interpretation pending human signoff. Charvet's plotted black triangle also
appears somewhat higher than this seven-piece neuron sum; the plotted point
cannot yet be reconstructed exactly from Dataset S1 and the published caption.
No new Figure 7 dataset was created.

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
Supplement **`sd01.xls`** (= Dataset S1) copied **verbatim** to
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
- *Papio cynocephalus anubis* is the SI's trinomial (olive baboon); kept as published. (Written
  before the table was wired; it is part of the cell-count merge since 2026-11-24, see **Status**.)

## Per-hemisphere totals reported in the paper (context; not in the per-piece CSV)
galago #1: 2,261 mm², ≈326M cells, 127M neurons (39%) · galago #2: 1,849 mm², 243M cells, 107M
neurons (44%) · owl monkey: >553M cells, 212M neurons (38%) · macaque: ≈3.5B cells, 1.4B neurons (40%)
· baboon: 18,577 mm², 4.67B cells, 2.36B neurons (51%).
These are compared with the sums of this table's pieces in the internal check below.

## Internal check
`internal_checks/Collins_etal_2010_DatasetS1_internal_check.R` → `.csv` (64 rows: 36 pass, 9
mismatch, 19 recorded without a printed figure to compare). It reads only
`Collins_etal_2010_DatasetS1.csv`; the figures of the paper's text, the contour levels of Fig. 1
C and D and the galago values of Young et al. 2013 are constants in the script, each with their
source. Re-run it after any change to the item table.

**What agrees.**
- The number of samples: 36 (galago 07-104: "46 tissue pieces … processed as 36 samples") and 142
  (baboon: "268 tissue pieces … processed as 142 samples").
- Inside the table, for every sample of every case: cells = cells per g × weight and neurons =
  cells × the printed neuron share (no sample differs by more than 2 %).
- The sums of the pieces against the text for galago 08-07 (cells, neurons, 1,849 mm²), owl monkey
  07-78 (cells, neurons) and baboon 09-27 (cells, neurons, 18,577 mm²), each within 1 %.
- The neuron share from the sums against the text: 39.3 % (39 %; range 27.2–60.2 against 27–60) for
  galago 07-104, 44.0 % (44 %; range 29.8–68.7 against 30–69) for galago 08-07, 38.4 % (38 %) for
  the owl monkey, 39.9 % (40 %) for the macaque.
- Macaque 08-59, neurons: the sum (1,361,451,374) is the Discussion's "1.36 billion neurons".
- Galago 07-104, per-piece densities per mm² against the labelled contours of Fig. 1 C and D: cells
  130–344 thousand (contours 100–340), neurons 39–207 thousand (contours 40–200). The figure
  prints no unit.
- Galago 07-104, weight per mm²: 0.00155 g, the same as galago 08-07.
- Galago 08-07 is galago 2 of Young et al. 2013 (1,849.5 mm² here, 1,850 mm² there; 2.8721 g
  here, 2.87 g there).

**What does not agree.**
- Galago 07-104, sums against the text: 239,468,760 cells against "≈326 million", 94,095,164
  neurons against 127 million, 1,137.6 mm² against 2,261 mm². Text ÷ sum = 1.36, 1.35 and 1.99: no
  single factor. The text's total over the text's area is 144 thousand cells per mm², below the
  median piece of the supplement (199 thousand).
- Macaque 08-59, sums against the Results text: 3,412,640,628 cells against "nearly 3.5 billion"
  (2.5 % below) and 1,361,451,374 neurons against "40% (1.4 billion)" (2.8 % below).
- Baboon 09-27, neuron share: 50.4 % from the sums against the printed 51 % (the text's own two
  totals, 2.36 of 4.67 billion, give 50.5 %). A rounding difference; nothing follows from it.
- Galago 07-104 is smaller than the other galago hemispheres: its area and weight are 0.61 of
  those of 08-07; against galagos 1 and 3 of Young et al. 2013 its area is 0.64 and 0.63 and its
  weight 0.62 and 0.74. Its cells are 0.99 and its neurons 0.88 of those of 08-07.

**What was decided, and by whom.** Alexandra de Sousa (owner), 2026-11-24, "I agree" (review
`RV-2026-022`; one row per case in
`__merging_cell_counts_isotropic_fractionator/Collins_etal_2010_case_decisions.csv`):
- Macaque 08-59: the whole-neocortex weight, cells and neurons are served from the sums of this
  table. The Results figures are registered as disagreeing and not served.
- Galago 07-104: cells and neurons are served from the sums of this table, inside the species
  mean with case 08-07. Its weight is not served and no density is derived from it: the
  hemisphere has the cells of a whole one but 0.61 of the area and weight of the other case, so
  its weight is not comparable. The text figures are registered as disagreeing and not served.

**An inference, not a finding.** That the tissue of 07-104 shrank more in preparation would fit
these numbers (equal weight per mm², nearly equal cells, smaller area and weight). The paper does
not say so, and this check cannot show it.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
