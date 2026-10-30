# Krubitzer & Kaas 1990 — Table 1

Krubitzer LA, Kaas JH (1990). *Cortical connections of MT in four species of primates: areal, modular,
and retinotopic patterns.* Vis Neurosci 5(2):165–204. doi:10.1017/s0952523800000213 · Team **Kaas**.

Registry (`__ReadMe.xlsx`): Item **`Krubitzer_Kaas_1990_Table1`**, encoded
`10.1017%2Fs0952523800000213_Table1`. Full title: *"Surface areas of cortical fields as a percentage
of the total surface of neocortex (See Fig. 1 for visual areas)."*

## What the data are
Per-hemisphere (per-case) size of **eight visual cortical fields** — 17, 18, DL, DM, DI, FST, MT, MST —
each expressed as a **percentage of total neocortex surface**, plus a `Total` (sum of the eight),
for four primate groups:

| common name | Species | cases |
|---|---|---|
| squirrel monkey | *Saimiri sciureus* | 6 |
| owl monkey | *Aotus trivirgatus* | 4 |
| marmoset | *Callithrix jacchus* | 6 |
| galago | *Galago senegalensis* (provisional curator inference) | 4 |

20 cases. **These are proportions, not absolute areas** — absolute field areas appear only as text
ranges (e.g. area 17 = 378–653 mm² across six squirrel monkeys), not in the table.

## Source → Snapshot → Data readable
PDF p.174–175 Table 1 → transcribed to `Krubitzer_Kaas_1990_Table1_snapshot.csv` (per-case rows +
the printed `Mean %` / `Std Dev` rows, verbatim). `Krubitzer_Kaas_1990_Table1.R` →
`Krubitzer_Kaas_1990_Table1.csv` (**use this**): one row per case, `Species` binomial added, the
derived Mean/Std Dev rows dropped. Columns in `reference_tables/Krubitzer_Kaas_1990_Table1_definitions.csv`.
All four normalized binomials are already in `_keys/species_reference.csv`, but the inspected paper
labels the last group only as `Galago`. `Galago senegalensis` is therefore retained for compatibility
and explicitly marked `species_inference_unverified` pending verification from a primary specimen or
methods source.

## Overlap with other data in the repo (asked)
- **Measure overlap: none.** The "% of neocortex per visual field" measure is **unique to this table**
  in the repo — no other built TSV reports these columns, so there is **no value duplication** with
  Changizi 2001, Finlay 2006, or Collins 2010 (which report, respectively, log #areas, absolute
  cortical area / area counts, and neuron densities).
- **Species overlap: high but expected.** All four species are common lab primates that recur across
  ~10+ tables. Finlay 2006 carries all four (*Saimiri sciureus*, *Aotus trivirgatus*, *Callithrix
  jacchus*, *Galago sp.*); Changizi 2001 shares owl monkey, marmoset and squirrel monkey. Shared
  species ≠ double-counting when the measured quantity differs.
- **Provenance link (double-count flag): Finlay 2006 cites THIS paper.** Finlay's methods list
  "Krubitzer and Kaas 1990a" and its reference list is exactly this article, so Finlay's cortical-area
  / visual-area values for marmoset, squirrel monkey, owl monkey and galago are partly **derived from
  this mapping lineage**. If both ever feed one cortical-area merge, treat Finlay as **secondary** for
  those species. (No literal collision now, because K&K report proportions and Finlay reports counts +
  absolute mm².)
- **Collins 2010 (same Kaas lab): no confirmed species overlap.** Collins used *Aotus nancymae* (not *A.
  trivirgatus*) and *Otolemur garnetti* (not the provisionally identified K&K galago); it did not measure squirrel
  monkey or marmoset. Different specimens, species and measure — independent.

Bottom line: building this adds a **new, non-overlapping measure**; the only thing to watch is the
Finlay→K&K provenance link if a cortical-area merge is built.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species inference flagged ✅ → Online database ✅
