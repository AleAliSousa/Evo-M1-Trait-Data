# Kazu, Maldonado, Mota, Manger & Herculano-Houzel 2014 — Table 1 (Artiodactyla cell counts)

> ## ⛔ SUPERSEDED — built 2026-08-06: use `../Kazu_etal_2015/Kazu_etal_2015_TABLE1`
>
> The 2015 corrigendum (DOI 10.3389/fnana.2015.00039) reprints this table with corrections and is
> now built. **71 of the 184 cells present in both printings changed — 39%.** `CerebralCortex`
> mass / N / density / O-N and `WholeBrain` mass and O/N changed for *every* species: the
> hippocampus had been counted into rest-of-brain rather than cortex in four species and omitted
> entirely for *Damaliscus*.
>
> The consistency failure documented below — `N_BR` ≠ `N_CXT + N_CB + N_RoB`, out by −0.4% to
> −22.0% — is fixed there, closing to ±0.27% (printed rounding).
>
> Cell-by-cell diff: `../Kazu_etal_2015/comparison/Kazu_etal_2015_TABLE1_vs_Kazu_2014_report.csv`.
> This folder is kept as the historical printing. **Do not merge it** (`Flags active (skips)` is
> set in `__ReadMe.xlsx`).


Kazu RS, Maldonado J, Mota B, Manger PR, Herculano-Houzel S (2014). *Cellular scaling
rules for the brain of Artiodactyla include a highly folded cortex with few neurons.*
Front. Neuroanat. 8:128. doi:**10.3389/fnana.2014.00128**
Table 1, "Cellular composition of Artiodactyla brains", article/PDF **p. 5**.

Status: **BUILT** (snapshot → CSV → definitions). **NOT merged, and it should not be**
— see "The corrigendum problem" below.

## What was built

| file | what it is |
|---|---|
| `Kazu_etal_2014_extract_snapshot.py` | reproducible capture of Table 1 from the PDF |
| `Kazu_etal_2014_Table1_snapshot.xlsx` (sheet `Table1`) | the **frozen** printed table: caption, printed species header, all 39 printed rows in printed order, `n.a.` cells, thousands commas, `∼100`, legend |
| `Kazu_etal_2014_Table1.R` | the canonical reformat: frozen snapshot → analysis CSV (+ public TSV) |
| `Kazu_etal_2014_Table1.csv` | **5 rows × 46 columns** — one row per species |
| `reference_tables/Kazu_etal_2014_Table1_definitions.csv` | data dictionary, 50 rows (46 Codes = the 46 CSV columns, + 4 `Method:*` rows) |
| `PROPOSED_species_key_rows.csv` | the five `Kazu2014` rows for `_keys/Stephan/species_key.csv` (not merged by this build) |

The printed table is transposed (structures down, species across); the `.R` pivots it so
the CSV is species-as-rows, which is what the cell-count merge consumes.

### Transcription rules in the snapshot

The Frontiers text layer has **no space glyphs**, and subscripts / power-of-ten exponents
are separate small-font characters on their own baselines — read as lines of text, "2.22 ×
10⁹" and "292.96 × 10⁶" both collapse to "…10 9" / "…10 6" and become indistinguishable.
The extractor therefore works from character coordinates + font size. Two documented,
reversible deviations, and nothing else:

* printed subscript → written inline after `_` — `M_BD`, `N_D+BG`, `O/N_CXT`
* printed superscript → written inline after `^` — `2.22 × 10^9`

Every exponent was read from its own small-font glyph, so no `10^6`/`10^9` is guessed.

## Species (5, one specimen each)

| printed in Table 1 | resolved `Species` | note |
|---|---|---|
| Sus scrofa domesticus | *Sus scrofa domesticus* | domestic pig |
| Antidorcas marsupialis | *Antidorcas marsupialis* | springbok |
| Damaliscus dorcas phillipsi | *Damaliscus pygargus phillipsi* | blesbok; **name changed** since 2014, and this is the form already used in `cellcounts_source_species_ids.csv` |
| Tragelaphus stripceros | *Tragelaphus strepsiceros* | greater kudu; **"stripceros" is a misprint** — the Methods spell it correctly. The 2015 corrigendum reprints the same misprint |
| Giraffa camelopardalis | *Giraffa camelopardalis* | giraffe, a **juvenile** (Methods) |

Resolution goes only through the species key (token `Kazu2014`); no mapping is hand-coded
in the script. Until `PROPOSED_species_key_rows.csv` is merged into
`_keys/Stephan/species_key.csv`, the `.R` reads that staging file and **warns**.

⚠️ **The scaffold's species claim was wrong.** The old README (and
`__merging_cellcounts/HH_coverage_gaps_scaffold.md`) said this paper adds collared peccary,
gemsbok, blue wildebeest, lesser kudu and warthog. **None of those animals is in this
paper.** Kazu 2014 has exactly five artiodactyls, and all five are **already in the merge**
from Herculano-Houzel et al. 2015 Tables 1–5. What this paper actually adds is *finer
structures* for those same five species: hippocampus, cortical grey matter, diencephalon +
basal ganglia, mesencephalon, pons + medulla.

## Units and conventions

* structure masses printed in **g**, kept in **g** (`*_Mass.g`, the cell-count lineage unit)
* body mass printed in **kg** → multiplied by 1000 to project unit **g** (HOWTO §6)
* neuronal densities are **neurons/mg** as printed; `O/N` is dimensionless
* all values are **both hemispheres**: one hemisphere was counted and ×2 (Methods)
* whole brain (`WholeBrain_*`) **excludes the olfactory bulb**
* **structures are nested, not disjoint**: `Hippocampus` and `CerebralCortexGrey` sit
  inside `CerebralCortex`; `DiencephalonStriatum`, `Mesencephalon` and `PonsMedulla` sit
  inside `RoB`. Only cortex + cerebellum + RoB sum to whole brain.

### Blank vs zero

There are **no zeros** in this table. Every empty measurement is printed `n.a.` and is
parsed to `NA` — **19 cells, all in the *Damaliscus* (blesbok) column**, whose cerebral
cortex was "processed separately as gray and white matter only" (Methods), so it has no
hippocampus and no brainstem subdivisions. `NA` here means "not reported", never "none".
No cell was left blank in the print.

## Verification (recomputed from the built CSV)

| # | claim in the paper | recomputed | verdict |
|---|---|---|---|
| A | body mass varies **18.8-fold** (25 kg springbok → 470 kg giraffe) | 18.80 | **pass** |
| B | brain mass varies **9.1-fold** | 9.14 | **pass** |
| C | brain neurons vary **5.0-fold** | 5.05 (from the printed `N_BR` row) | **pass** |
| D | cortex **67.2 ± 2.4 %**, cerebellum **11.4 ± 0.9 %**, RoB **21.3 ± 2.3 %** of brain mass | 67.3 ± 2.4, 11.4 ± 0.9, 21.3 ± 2.3 (mean ± SEM, n = 5) | **pass** |
| E | cerebellum **82.3 ± 0.9 %**, cortex **15.4 ± 0.8 %**, RoB **2.4 ± 0.3 %** of brain neurons | **72.9 ± 4.1 / 13.5 ± 0.5 / 2.1 ± 0.2** using the printed `N_BR`; **82.3 ± 0.9 / 15.4 ± 0.8 / 2.4 ± 0.3** using `N_CXT + N_CB + N_RoB` | **fail against the printed `N_BR` row; exact against the sum of parts** |
| F | hippocampus is 1.9 % (giraffe) to 5.5 % (springbok) of cortical mass | 1.9 / 5.5 | **pass** |
| G | hippocampus holds 3.5 % (giraffe) to 5.4 % (springbok) of cortical neurons | 3.5 / 5.46 (printed as 5.4, i.e. truncated) | **pass** |
| H | grey-matter `O/N` varies between 7.2 and 8.5 | 7.239 – 8.544 | **pass** |
| I | `O/N` ranges 0.184 (blesbok cerebellum) → 32.333 (giraffe RoB) | identical, over cortex/cerebellum/RoB | **pass** |
| J | other-cell density 33,123 (blesbok cerebellum) → 81,505/mg (giraffe cerebellum) | 32,974 and 81,532 from `DN × O/N` (3-decimal rounding); but the **pig cortex** gives 84,111, above the stated maximum | **pass for the quoted pair, fail as a range** — the pig cortex value is a knock-on of the `DN_CXT` error below |
| K | p. 8: `DN_CXT` 3,741 (kudu) → 8,118 (pig); `DN_CB` 127,218 → 228,632; `DN_RoB` 1,642 → 4,238 | identical | **pass** |

### Internal arithmetic (run by the `.R`, stored in `consistency_flags`)

* `M_BR = M_CXT + M_CB + M_RoB` — **exact for all five species**.
* `M_RoB = M_D+BG + M_MES + M_P+M` — exact for pig, kudu, giraffe; **fails for the
  springbok** (13.814 + 5.304 + 8.312 = 27.430 vs printed 27.830, off by 0.400 g).
* `N_BR = N_CXT + N_CB + N_RoB` (0.5 % tolerance for printed rounding) — passes for the pig
  only; **springbok −11.6 %, blesbok −22.0 %, kudu −18.9 %, giraffe −4.5 %**.
* `DN_x = N_x / M_x` for all eight structures with both printed — passes everywhere except
  **`DN_CXT` for the pig** (printed 8,118, computed 8,188, −0.9 %).

Other things worth distrusting in the 2014 print, recorded but not changed:

* `N_OB` for *Damaliscus* is printed **58.71 × 10⁶ — byte-identical to `N_RoB` for
  *Sus*** — while `M_OB` and `DN_OB` for *Damaliscus* are `n.a.`. The corrigendum removes
  this value (`n.a.`). Treat it as a copy error.
* `M_MES` is printed as **15.928 g for both kudu and giraffe**. The corrigendum changes the
  kudu to 12.902.
* The Results text on p. 7 says "our specimen had a **cortical** mass of only 528 g" —
  528.026 is `M_BR` (whole brain), not `M_CXT` (389.616).

## The corrigendum problem — read before merging anything

**Kazu et al. (2015), Corrigendum, Front. Neuroanat. 9:39, doi:10.3389/fnana.2015.00039**
reprints Table 1 in full because "values for the hippocampus had in four cases been
included in the rest of brain, not cerebral cortex … and had failed to be included for
*Damaliscus*", plus "a few other minor mistakes". **That corrigendum PDF is still not in
this folder.**

Comparing the built 2014 snapshot against the corrigendum's reprinted Table 1 (read from
the Frontiers HTML for documentation only — no corrigendum value has been ingested):
**71 of the 195 cells changed (36 %)** — pig 6, springbok 12, blesbok 20, kudu 16,
giraffe 17. `M_BR`, `M_CXT`, `N_CXT`, `DN_CXT`, `O/N_BR` and `O/N_CXT` change for **every**
species; `N_BR` changes for four of five, in exactly the direction that makes check E
above come out right (e.g. springbok 3.06 → 2.72 ×10⁹, kudu 6.09 → 4.91 ×10⁹). The
corrigendum also restates the text: brain mass varies **8.4**-fold (not 9.1) and brain
neurons **4.8**-fold (not 5.0).

**And the corrected values are already in the merge.** All five species carry
`WholeBrain`, `CerebralCortex`, `Cerebellum`, `RoB` and (except the blesbok)
`OlfactoryBulb` counts in `__merging_cellcounts/cellcounts_wide.csv`, sourced from
`HerculanoHouzel_etal_2015_Table1..5`, at **full precision** and matching the corrigendum
(e.g. *Sus* `CerebralCortex_N.n` = 307,082,404 ↔ corrigendum 307.08 × 10⁶; `DN_CXT` 7,276 ↔
7,276; giraffe `Cerebellum_O.p.mg` 81,505 ↔ the paper's quoted maximum).

### Recommendation

1. **Do not add `Kazu_etal_2014_Table1` to `cellcounts_compiled.R` `item_name`.** Its
   whole-structure values are superseded and its species are already present.
2. In `__ReadMe.xlsx` Sheet 1, keep `Data role = primary` (this is the primary study) and
   set **`Flags active (skips)`** to something like *"EXCLUDED from merged cellcounts:
   2014 printing superseded by the 2015 corrigendum (10.3389/fnana.2015.00039); corrected
   values already enter via HerculanoHouzel_etal_2015 Tables 1–5"* — the same pattern
   already used for `DosSantos_etal_2020_Table1`.
3. If the sub-structure coverage is wanted (**hippocampus, cortical grey matter,
   diencephalon + basal ganglia, mesencephalon, pons + medulla** — genuinely absent from
   the merge for these five species), build **`Kazu_etal_2015_`** (the corrigendum, already
   registered in `__ReadMe.xlsx` with no `Item number`) from the corrigendum PDF and merge
   *that*, not this table. Nine of those sub-structure cells changed in the corrigendum.

## Not done here (deliberately)

* `__merging_cellcounts/standardized_term_by_reference/Kazu_etal_2014_Table1_standardized_terms.csv`
  is **left as the old stub** and still names columns this build does not produce
  (`Body mass, g`, `Cortex neurons`, …). It is not updated because the table should not be
  merged; when a corrigendum build replaces it, the mapping is a one-liner —
  `Original_Term` = the CSV column, `Standardized_Term` = the same string (the CSV columns
  are already canonical `<Structure>_<Measure>` names, and `reference_tables/…_definitions.csv`
  carries the `Structure`/`Measure` split for every one).
* No `.tsv` was written to `__Public/comparative-data/`. The `.R` writes it when sourced;
  publishing is handled separately.
* No comparison script (HOWTO §7): there is no independent curated copy of this table.
  The nearest thing is the HH 2015 cross-check described above, done by hand in this README.
