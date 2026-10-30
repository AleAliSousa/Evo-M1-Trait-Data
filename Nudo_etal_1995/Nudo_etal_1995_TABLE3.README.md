# Nudo et al. 1995 — TABLE 3 (corticospinal somata by taxonomic order)

**Built 2026-08-06.**

| File | |
|---|---|
| `Nudo_etal_1995_TABLE3_snapshot.xlsx` | frozen source (sheet `TABLE3`) |
| `Nudo_etal_1995_TABLE3.R` | reformat: snapshot → CSV (+ TSV) |
| `Nudo_etal_1995_TABLE3.csv` | analysis table — **9 rows = 9 taxonomic orders** |
| `reference_tables/Nudo_etal_1995_TABLE3_definitions.csv` | data dictionary (10 codes) |

Registry: `Item name = Nudo_etal_1995_TABLE3`, `Item encoded = 10.1002%2Fcne.903580203_TABLE3`.

## Where TABLE 3 is

**Journal p. 187 = PDF p. 7, right-hand column, immediately above TABLE 4** — i.e. on the same page
as TABLE 4, not on a page of its own. A caption scan of the PDF text layer can miss it because the
caption line is merged with body text from the left column ("*the average percentage number of
somata in regions A and* **TABLE 3. Number of Corticospinal Somata by Taxonomic Order**"). It is
typeset normally; it is only the two-column text extraction that hides it.

## Source

Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). J Comp Neurol 358(2):181–205.
DOI 10.1002/cne.903580203.

**Printed/scanned source → snapshot required** (invariant 1). Read off a 300-dpi render, then
cross-checked against the PDF text layer by coordinate-matched word extraction: **9/9 rows agree
exactly, 0 differences.**

## Shape — orders, not species

The unit of observation is the **taxonomic order**, so this table has **no species column and
nothing to resolve through the species key**. `Order_Nudo1995` is the row key; `n_species` is the
number of TABLE 2 species pooled into it, and sums to **24**.

| order | n |
|---|---|
| Carnivora 2 · Edentata 1 · Hyracoidea 1 · Insectivora 5 · Lagomorpha 1 · Marsupialia 2 · Primates 7 · Rodentia 4 · Scandentia 1 | **24** |

Columns: `Mean # CSN`, `Mean #A`, `Mean #B`, `Mean #C`, `Mean #C'`, `Mean %A`, `Mean %B`. There is
**no** `%C`, `%C'` or "Other" column, and no footnote other than
"¹Numbers of CS somata are stereologically corrected values."

## Units

Counts (dimensionless) and percentages. Nothing to convert (§6).

## Blank vs zero

No blanks and no `n.a.` are printed. Every printed `0` in `Mean #C` / `Mean #C'` is a **true zero**
— those regions do not exist in the species of that order (region C is primate-only, C′ is
rodent + rabbit only). Carried as `0`.

## Verification — TABLE 3 is exactly the order-wise mean of TABLE 2

Recomputed **every one of the 8 numeric cells × 9 orders = 72 cells** as the *unweighted* mean over
that order's TABLE 2 species, rounded half-up to the printed number of decimals (exact decimal
arithmetic — binary floats mis-round the Marsupialia `%B` case, 11.65 → 11.7):

> **72/72 cells reproduce. 0 mismatches.**

Worked examples:

| order | recomputation | printed |
|---|---|---|
| Carnivora `Mean #CSN` | (33,038 + 104,434)/2 = 68,736 | 68,736 |
| Insectivora `Mean #A` | (1,644+3,550+957+348+9,730)/5 = 3,245.8 | 3,246 |
| Primates `Mean #C` | 6,218/7 = 888.29 | 888 |
| Rodentia `Mean #C'` | 5,961/4 = 1,490.25 | 1,490 |
| Marsupialia `Mean %B` | (4.4 + 18.9)/2 = 11.65 | 11.7 |
| Primates `Mean %A` | 648.7/7 = 92.67 | 92.7 |

Note the percentage columns are **means of the per-species percentages**, not pooled percentages —
confirmed by the recomputation. And `Mean #A + #B + #C + #C'` falls short of `Mean #CSN` by exactly
the mean "Other" count, which TABLE 3 does not print; the `.R` therefore only flags an *excess*
(none occurs).

Cross-checks against figures the paper states in its own text (p. 186–187), all matching: highest
mean `#CSN` Carnivora 68,736 / lowest Insectivora 4,195; highest mean `#A` Carnivora 65,897 /
lowest Insectivora 3,246; highest mean `#B` Carnivora 2,407 / lowest Marsupialia 236; highest
`%A` Edentata 96.5 / lowest Lagomorpha 76.5; highest `%B` Insectivora 19.9 / lowest Edentata 3.5.

## Printed values distrusted

**None.** 0 of 9 rows flagged.

One typographic note (not a data problem): TABLE 3 prints **`Lagomorpha`** where the same rabbit
appears as **`Lagamorpha`** in TABLES 2, 4 and 5. TABLE 3 has the correct spelling, so no
correction is applied here; the other three tables carry a `parse_flags` entry.

## Data role — do not merge

**`secondary`, and excluded from every merge.** TABLE 3 is arithmetically derived from TABLE 2
(proved above, 72/72). Merging it would double-count the same 24 animals. It is built for
provenance and because it is a registered item, not because it adds data.

## Still to do (locally, with R)

1. **Re-run `Nudo_etal_1995_TABLE3.R` in RStudio** — the committed CSV was produced by an offline
   Python mirror. The `.R` is canonical.
2. Public TSV not written in this session; the `.R` writes it.
