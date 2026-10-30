# Nudo et al. 1995 — TABLE 4 (maximum surface density of corticospinal somata, by region)

**Built 2026-08-06.**

| File | |
|---|---|
| `Nudo_etal_1995_TABLE4_snapshot.xlsx` | frozen source (sheet `TABLE4`) |
| `Nudo_etal_1995_TABLE4.R` | reformat: snapshot → CSV (+ TSV) |
| `Nudo_etal_1995_TABLE4.csv` | analysis table — **24 rows = 24 species** |
| `reference_tables/Nudo_etal_1995_TABLE4_definitions.csv` | data dictionary (12 codes) |

Registry: `Item name = Nudo_etal_1995_TABLE4`, `Item encoded = 10.1002%2Fcne.903580203_TABLE4`.

## Source

Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). J Comp Neurol 358(2):181–205.
DOI 10.1002/cne.903580203. TABLE 4 is printed on **journal p. 187 = PDF p. 7**, right column,
directly below TABLE 3.

**Printed/scanned source → snapshot required** (invariant 1). Read off a 300-dpi render, then
cross-checked against the PDF text layer by coordinate-matched word extraction: **24/24 rows agree
exactly, 0 differences.**

## The unit in the caption — printed form vs corrected form

The brief flagged the caption as printing a broken `cells/mm'`. **It does not.** Rendered at
900 dpi, the printed caption is

> `TABLE 4. Maximum Surface Density of Corticospinal Somata (cells/mm²)`

with a **true superscript two**. The string `cells/mm'` comes from the PDF's OCR **text layer**,
which loses the superscript — a text-layer artefact, not a print error. Both forms are recorded:

| | |
|---|---|
| **printed form** (kept verbatim in the snapshot caption) | `(cells/mm²)` |
| **PDF text-layer rendering** (do not propagate) | `(cells/mm')` |
| **corrected/analysis unit** | cells per mm² → column suffix `.cells_per_mm2`, `Measure = Density.N_mm2` |

No numeric conversion: an areal cell density is not one of the mass/volume classes of §6.
The same note is carried in the `Source Note` column of every density row of the definitions file.

## What TABLE 4 gives

Per species, the **maximum** surface density of CS somata in each of the four regions
(A, B, C, C′). Method (p. 184): the maximum number of labelled somata subjacent to a
**250 µm × 50 µm** patch of neocortical surface. Region definitions are in the TABLE 2 README.

### Blank vs zero

A printed `0` in column **C** or **C′** is a **true zero** — the region does not exist in that
species. Verified: `C > 0` only in the 7 primates; `C' > 0` only in rat, gray squirrel, ground
squirrel, rabbit and vole — exactly the same species as in TABLE 2. No blanks, no `n.a.`.

## Printed values distrusted / flagged — 1 of 24 rows

| species | flag | verdict |
|---|---|---|
| Rabbit | order printed **`Lagamorpha`** | Print typo (also TABLES 2 and 5; TABLE 3 prints `Lagomorpha`). Printed string kept in `Order_Nudo1995`; `Order_resolved = Lagomorpha`; correction named in `parse_flags`. |

Unlike TABLE 2, the cat row here prints **`Carnivora`** correctly (verified at 900 dpi) — the
`Camivora` typo is confined to TABLE 2.

## Verification — every check and its result

The paper states several of these means in its own text (p. 187), so recomputation is a real
transcription check.

| # | check | from the snapshot | paper |
|---|---|---|---|
| 1 | rows | **24** | 24 species |
| 2 | mean max density, region A | **1,366.8 → 1,367** | 1,367 cells/mm² |
| 3 | mean max density, region B | **420.7 → 421** | 421 cells/mm² |
| 4 | B as a share of A | **30.8 %** | "about 31 %" |
| 5 | primate mean, region C (n = 7) | **522.3 → 522** | 522 |
| 6 | region C vs the primates' own region A | **42.6 %** | "about 43 %" |
| 7 | region C vs the primates' own region B | **33 % higher** | "about 33 % higher" |
| 8 | mean region C′ over the 5 C′-bearing species | **994.0** | 994 |
| 9 | region C′ vs those species' region A | **49.2 %** | "about 49 %" |
| 10 | region C′ vs those species' region B | **79 % higher** | "about 78 %" |
| 11 | highest / lowest region A | bushbaby 4,030 / crab-eating macaque 300, rhesus 408 | same |
| 12 | highest / lowest region B | mole 1,335 / rhesus 99 | same |
| 13 | highest / lowest region C | bushbaby 1,504 / crab-eating macaque 128 | same |
| 14 | highest / lowest region C′ | rat 1,606 / rabbit 170 | same |
| 15 | region A is the densest region in every species (A ≥ B, C, C′) | **24/24 hold** | region A is by definition the maximum-density zone |
| 16 | region-presence pattern identical to TABLE 2 | ✔ (C = primates only; C′ = the same 5 species) | — |
| 17 | TABLE 5 average surface density ≤ this table's region-A maximum | **24/24 hold** | an average over the labelled zone cannot exceed the peak |

Checks 4, 6, 7, 9 and 10 also pin down *which* denominator the paper used: the region-C and
region-C′ ratios only reproduce against the **subgroup's own** mean region-A/B density (primates
only, or the five C′-bearing species only), not against the all-24 mean.

## Species names

As in TABLE 2, the species is printed only as genus/species initials in the
`Animal/G.s./Order` cell. The printed cell survives whole and split; `species_sci` is resolved
**through the species key** (`Nudo1995` variant rows in `PROPOSED_species_key_rows.csv`), never
hand-coded. All 24 resolve; see the TABLE 1 README for the six remapped names and the one
ambiguous case.

## Data role

**`primary`** — the paper's own measurement, and a *different* measure class from TABLE 2 (areal
density, not a count), so both can be merged without double-counting.

## Still to do (locally, with R)

1. **Re-run `Nudo_etal_1995_TABLE4.R` in RStudio** — the committed CSV was produced by an offline
   Python mirror. The `.R` is canonical.
2. Merge `PROPOSED_species_key_rows.csv` into `_keys/`, then delete the staged file.
3. Public TSV not written in this session; the `.R` writes it.
