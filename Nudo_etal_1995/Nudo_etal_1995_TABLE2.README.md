# Nudo et al. 1995 — TABLE 2 (number and percentage of corticospinal somata per region)

**Built 2026-08-06.**

| File | |
|---|---|
| `Nudo_etal_1995_TABLE2_snapshot.xlsx` | frozen source (sheet `TABLE2`) |
| `Nudo_etal_1995_TABLE2.R` | reformat: snapshot → CSV (+ TSV) |
| `Nudo_etal_1995_TABLE2.csv` | analysis table — **24 rows = 24 species**, 26 columns |
| `reference_tables/Nudo_etal_1995_TABLE2_definitions.csv` | data dictionary (26 codes) |

Registry: `Item name = Nudo_etal_1995_TABLE2`, `Item encoded = 10.1002%2Fcne.903580203_TABLE2`.
**This is the primary data table of the paper** — the corticospinal (CS) soma counts everything
else in the paper is derived from.

## Source

Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). J Comp Neurol 358(2):181–205.
DOI 10.1002/cne.903580203. TABLE 2 is printed full-width on **journal p. 185 = PDF p. 5**.

**Printed/scanned source → snapshot required** (invariant 1). Every cell was read off 300-dpi
renders and then cross-checked against the PDF text layer by coordinate-matched word extraction:
**20 of 24 rows agree exactly**; the 4 that differ are all demonstrable OCR faults, each re-read at
300 or 900 dpi and, in four cases, additionally confirmed by internal arithmetic:

| row | snapshot | OCR text layer | how settled |
|---|---|---|---|
| Gray squirrel `% Other` | `0.3` | `03` | decimal point dropped by OCR; also 48/16,150 = 0.30 % |
| Hedgehog `H.a.` profile cell | `615 [1,415]` | `615 [1,4151` | OCR read the closing `]` as a `1`; also 1,415 × 0.856 = 1,211 = the printed corrected total |
| Hedgehog `H.a.` `% Other` | `0.0` | `00` | decimal point dropped |
| Slow loris soma diameter | `23.14` | `23 14` | decimal point dropped; also 100/123.14 → 0.812 = the printed correction term |
| Vole max profile # | `7,120` | `7.120` | comma read as a period; also 7,120 × 0.872 = 6,209 = the printed corrected total |

## What TABLE 2 gives

Per species: the raw **maximum labelled-profile count**, the mean **soma diameter (µm)**, the
**stereological correction term**, the **corrected total number of CS somata**, and the count **and
percentage** of CS somata in each of five cortical regions.

**Regions** (Methods, p. 184):

| region | what it is |
|---|---|
| **A** | frontal + parietal cortex — roughly M1 + premotor + SMA + S1 + posterior parietal |
| **B** | roughly the second somatosensory area (SII) |
| **C** | arcuate (lateral) premotor area — **primates only** |
| **C′** | rostral forelimb area — **the four rodents and the rabbit only** |
| Other | the remainder |

### Blank vs zero — decided explicitly

- **A printed `0` in `#C` / `#C'` is a TRUE ZERO**, not a missing value: it means the region does
  not exist in that species. Verified: `#C > 0` occurs in Primates and nowhere else (7/7 primates);
  `#C' > 0` occurs in exactly rat, gray squirrel, ground squirrel, rabbit and vole. Carried as `0`.
- **`CS_profiles_ipsilateral` is `NA` in 19 of 24 rows** — that parenthetical is only *printed*
  where the ipsilateral total exceeded the contralateral one (footnote 2). `NA` here means "not
  printed", not "zero".
- TABLE 2 prints no `n.a.`, no dashes and no blank data cells.

### The parenthetical in "Maximum profile #"

Footnote 2: where the ipsilateral total exceeded the contralateral total, the cell prints
`contralateral (ipsilateral)` — and it is the **ipsilateral** number the paper carries forward
(Methods, p. 184: the three hedgehogs, mole and hyrax have a predominantly uncrossed CST). The cell
is split into `CS_profiles_contralateral` / `CS_profiles_ipsilateral`, and `CS_profiles_used` +
`hemisphere_used` record which one the correction was applied to. **That reading is confirmed
arithmetically for all five species** (see check F below).

## Printed values distrusted / flagged — 5 of 24 rows

Nothing is corrected in the snapshot; every deviation is named in `parse_flags`.

| species | flag | verdict |
|---|---|---|
| Cat | order printed **`Camivora`** | **Print typo.** Verified at 900 dpi: the glyph is a clean `m`, whereas `Carnivora` in the raccoon row on the same page shows a distinct `r`+`n`. TABLES 4 and 5 print `Carnivora` for the same animal. The PDF's own OCR text layer "reads" `Carnivora` — i.e. the OCR silently corrected it. Printed string kept in `Order_Nudo1995`; `Order_resolved = Carnivora`. |
| Rabbit | order printed **`Lagamorpha`** | Print typo, also in TABLES 4 and 5; TABLE 3 prints `Lagomorpha`. `Order_resolved = Lagomorpha`. |
| Hedgehog `H.a.` | ipsilateral total printed in **square** brackets `615 [1,415]` although footnote 2 says "parentheses" | Typesetting inconsistency only. Recorded in `CS_profiles_bracket_printed`; the value is used exactly as the other four parentheticals are. |
| Green monkey (`C.a.`) | regions sum to **59,268** but the printed corrected total is **59,269** | **Benign rounding residue.** 75,310 × 0.787 = 59,268.97; the total rounds up to 59,269 while the five separately-rounded regional counts sum to 59,268. No transcription error — both printed numbers are kept. |
| Gray short-tailed opossum (`M.d.`) | `%A` printed 81.1 but 397/490 = 81.0; `%B` printed 18.9 but 93/490 = 19.0 | **Benign rounding residue.** The unrounded total is 550 × 0.890 = **489.5**. Against 489.5 the printed percentages are exact: 397/489.5 = 81.10 → 81.1 ✓ and 92.5/489.5 = 18.90 → 18.9 ✓ (the region-B count 93 is itself the rounding of ≈92.5). The authors computed the percentages before rounding the counts. Printed values kept. |

## Verification — every check and its result

Recomputed from the snapshot; the "paper" column is a figure the paper states **independently in
its own text**, so agreement is a genuine transcription check.

| # | check | from the snapshot | paper |
|---|---|---|---|
| 1 | rows | **24** | 24 species |
| 2 | mean corrected `#CSN` over 24 species | **24,071** | 24,071 (p. 186) |
| 3 | highest / lowest `#CSN` | raccoon 104,434 / least shrew 423 | same |
| 4 | mean `#B` | **1,241** | 1,241 |
| 5 | mean `%B` | 9.15 | "on average … 9.0 %" (≈) |
| 6 | highest / lowest `#B` | bushbaby 3,294 / least shrew 75 | same |
| 7 | primate mean `#C` (n = 7) | **888** | 888 |
| 8 | primate mean `%C` | **2.19 → 2.2** | 2.2 |
| 9 | highest / lowest `#C` | green monkey 1,600 / slow loris 342 | same |
| 10 | mean `#C'` over the 5 C′-bearing species | **1,319** | 1,319 |
| 11 | mean `%C'` over those 5 | **11.58 → 11.6** | 11.6 |
| 12 | highest / lowest `#C'` | rat 2,119 / rabbit 636 | same |
| 13 | highest / lowest `%A` | rhesus 98.0 / pine vole 72.2 | same |
| 14 | highest / lowest `%B` | mole 24.0 / rhesus 1.3 | same |
| **E** | `correction_term == round(100/(100 + soma_diameter), 3)` | **24/24 hold** | — |
| **F** | `corrected #CSN == round(profiles_used × correction_term)` | **24/24 hold** | — |
| **G** | five regional counts sum to the corrected total | **23/24** (green monkey off by 1 — rounding, see above) | — |
| **H** | all five printed percentages recompute from the printed counts (1 dp, half-up) | **23/24** (`M.d.` opossum — rounding, see above) | — |
| **I** | ipsilateral parenthetical used exactly where printed | 5/5: hedgehogs `E.a.`, `E.e.`, `H.a.`, mole, hyrax | Methods p. 184 |

Checks **E** and **F** are the strongest evidence the transcription is right: the correction term
turns out to be exactly `100/(100 + soma diameter)` rounded to 3 dp, and multiplying it back by the
profile count reproduces the printed corrected total, in **all 24 rows**. That ties the profile
count, the soma diameter, the correction term and the total together — four independent columns.

Cross-table (see the TABLE 1 / TABLE 3 READMEs): TABLE 3 is exactly the order-wise mean of this
table (**72/72 cells reproduce**), and `#CSN` ÷ TABLE 5 avg surface density gives a CS-labelled
cortical area that is 4.3 %–27.6 % of the TABLE 1 neocortical area in every species.

## Species names

TABLE 2 prints the species **only as genus/species initials** (`R.n.`, `G.s.`, … — footnote 1
"G.s., Genus specie; see Table 1"). The printed cell survives whole in `Animal_Nudo1995` and split
into `animal_common_Nudo1995` / `gs_initials_Nudo1995` / `Order_Nudo1995`. The initials are
resolved to `species_sci` **through the species key** as `Nudo1995` variant rows — the expansion is
*not* hand-coded in the script. All 24 resolve; see `PROPOSED_species_key_rows.csv` and the TABLE 1
README for the six remapped names and the one ambiguous case (`Cercopithecus aethiops`).

## Data role

**`primary`** — this is the paper's own HRP tract-tracing measurement (one animal per species: the
individual with the most labelled somata among the several examined for that species). The
percentage columns are author-derived from the counts in the same row; the definitions mark them
`secondary`.

## Still to do (locally, with R)

1. **Re-run `Nudo_etal_1995_TABLE2.R` in RStudio** — the committed CSV was produced by an offline
   Python mirror of the script. The `.R` is canonical.
2. Merge `PROPOSED_species_key_rows.csv` into `_keys/`, then delete the staged file.
3. Public TSV not written in this session; the `.R` writes it.
