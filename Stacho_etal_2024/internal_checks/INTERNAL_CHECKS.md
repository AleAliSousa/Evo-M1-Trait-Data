# Internal checks — Stacho et al. 2024, Table 3 transposition

**Paper:** Stacho, M. et al. (2024). Phylogenetic reduction of the
magnocellular red nucleus in primates and inter-subject variability in
humans. *Frontiers in Neuroanatomy* 18:1331305.
**Check script:** `check_table3_transposition.R` · **Results:**
`check_results.csv` (15 tests) · **Figure evidence:** `inputs/`
(Figure 4, 8, 9, 10 as published). No build values were changed.

**Status update (2026-11-23):** the correction specified at the end of
this document has since been **applied** to the build — on the strength
of the cross-paper demonstration (the specimens' documented volumes:
YN82-140 = 362.9 cm³; YN81-146 and Disco = 88.8 and 115.8 cm³; committed
in the restricted repo as `__stacho2024_cross_paper_check`) and with
Michael's approval. The within-paper verdict below stands exactly as
written: this paper alone still does not demonstrate the swap. The build
script (`Stacho_etal_2024_Table3.R`) now performs the exchange in a
guarded block; the snapshot remains verbatim.

## The suspicion

Table 3 (species-mean brain volume BV and red-nucleus volumes) prints:

| Row | BV (cm³) | RNp R/L (mm³) | RNm R/L (mm³) | n |
|---|---|---|---|---|
| Gorilla gorilla | 98.8 | 33.7 / 34.3 | 2.6 / 2.0 | 1 |
| Hylobates lar | 396.8 | 131.1 / 129.3 | 6.8 / 7.4 | 2 |

A 98.8 cm³ gorilla brain and a 396.8 cm³ gibbon brain are both
anatomically impossible; each row's measurements are plausible for the
*other* species (the build README already records that the two gibbon
specimens are 92 g and 120 g brains). **Hypothesis:** the five measurement
columns of the two rows were transposed. The build carried the values as
printed because the swap was not provable from the table's own numbers
(the RNp/BV ratios are in-band either way). This package tests the
hypothesis against everything else *inside the paper*: Table 2, the
Results/Discussion text, and Figures 4, 8, 9 and 10.

## Verdict

**Still unproven on within-paper evidence — the transposition is NOT
demonstrated.** No text statement, figure, or count inside the paper
directly contradicts the printed measurement arrangement and agrees with
the swapped one. The paper is internally consistent because every
quantitative statement and display in it descends from the same
species-mean table, so an error made at that level propagates everywhere
and no internal check can catch it. The suspicion continues to rest on
anatomy external to the paper, where it remains overwhelming.

The checks do produce two hard results that narrow the question:

1. **The specimen counts refute the whole-row form of the swap and fix
   the exact correction spec** (Test 1). Whatever was transposed, it was
   *not* the species names together with their sample sizes.
2. **The one figure that could have contradicted the table leans, weakly,
   the other way** (Test 3, Figure 8A) — with the caveat that the figure
   is captioned as displaying Table 3's own values, so it cannot be
   treated as independent.

## Evidence lines

### 1. Specimen counts (Table 2 vs Table 3 "Number") — supports the printed name/n columns

Table 2 lists the specimens: **one** gorilla (YN82-140) and **two**
gibbons (YN81-146, 3_97). Table 3 prints n = 1 on the Gorilla row and
n = 2 on the Hylobates row. The control check passes for **all 20
species**: Table 3's "Number" equals the Table 2 specimen count
everywhere, so "Number" is a true specimen count, and for these two rows
it travels with the printed species name.

Consequence: if the species *names* had been swapped wholesale (each
whole row, sample size included, belonging to the other species), the
Gorilla row would carry n = 2 and the Hylobates row n = 1. They carry 1
and 2. So the transposition, if it happened, exchanged **only the five
measurement columns** (BV, RNp right, RNp left, RNm right, RNm left) and
left Taxon, Species and Number correct as printed. This test is silent
on whether the measurements themselves are swapped — but it determines
exactly which cells a correction would have to exchange (§Correction
spec).

### 2. Text — neutral (the paper never speaks at species level)

A full-text search of the Results and Discussion finds **no sentence**
that gives Gorilla or the gibbon a brain size, a red-nucleus size, or a
size ranking. "Gorilla" occurs only in Tables 1–3 and the Figure 1 tree;
the gibbon appears only cytoarchitecturally ("In some specimens such as
in Hylobates lar, there was a tendency for a much higher cell density
toward the medial pole of RNp (Figure 4E)"). There is therefore no
species-level text claim for the printed table to contradict.

The one brain-volume ranking sentence is group-level:

> "In our dataset human specimens had the largest fresh brain volume
> followed by apes and old world monkeys (Figure 8A)."

As printed, the five ape species' mean BV is 316.7 cm³ vs 73.2 cm³ for
old world monkeys — the ranking holds, and it holds identically under
the swap, because both rows sit inside the same group.

### 3. Figures — one weak lean toward printed, the rest structurally blind

**Figure 8A** (log₁₀ brain volume per specimen) is the only display that
could, in principle, separate the arrangements. Its per-specimen reading
was validated on the other groups (humans ≈ 10 points, prosimians 7,
old world monkeys 4, new world monkeys 3 — all matching the sample
sizes). In the non-human-ape column there is **exactly one** marker at
log₁₀ BV ≈ 2.0 (≈ 100 cm³), confirmed as a single clean ring in a
native-resolution crop (overlapping marker pairs elsewhere in the same
panel are visibly double). As printed, exactly one ape specimen has
BV ≈ 100 cm³ — the single gorilla (n = 1, BV 98.8). Under the swap,
**two** specimens — both gibbons, species mean 98.8 — should appear
there. They do not. This leans toward the printed arrangement, but only
weakly: the caption states the figure "shows values for brain volume and
left and right RNm and RNp **summarized in the Table 3**", so figure and
table share a source and the figure is not independent evidence.

**Figures 8B–D and 9** plot ratios computed *within* each row's
measurement bundle (relative RN/RNm/RNp volumes; the RNm/RNp ratio).
The printed Gorilla bundle gives rel. RN 0.0735 % and rel. RNm
0.0047 %; the printed Hylobates bundle gives 0.0692 % and 0.0036 % —
both inside the ape cloud, and the point *positions* are identical under
the swap, which only re-labels two bundles within one group. Neutral by
construction.

**Figure 10A/D/G/J** (bivariate log–log scaling plots) show the two
bundles as unlabelled purple points — one at log₁₀ BV = 4.99 with
log₁₀ left RNm = 0.30, one at log₁₀ BV = 5.60 with log₁₀ left RNm =
0.87 — exactly where the printed table puts them, and exactly where the
swapped table would put them too. The points carry no species labels.
Neutral. The **phenograms (10C/F)** do label the tips (Hl, Gg), and both
labels sit in the extreme-negative hominoid cluster, but at the
published resolution their order cannot be matched uniquely to either
arrangement — the residuals are pGLS/ASE model outputs, not table
values, and the labels are fanned. Examined; not decisive.

**Figure 4** photographs the Hylobates brain itself: an ordinary
gibbon-sized coronal section with its own scale bar. A single section
yields no brain volume, so it neither supports 396.8 cm³ nor refutes it
quantitatively. Neutral.

### 4. Internal arithmetic — neutral, provably invariant

The text's group statistics for non-human apes were recomputed from
Table 3 under both arrangements. First the reconstruction convention was
validated on groups the swap cannot touch — per-species relative value =
bilateral (R+L) volume ÷ BV, group statistic = mean ± SEM across
species:

- Prosimians, relative RN: printed **0.078 % ± 0.012 %**; recomputed
  0.0770 % ± 0.0117 %. ✓
- Old world monkeys, relative RN: printed **0.073 % ± 0.015 %**;
  recomputed 0.0730 % ± 0.0146 %. ✓
- Humans, relative RNm: printed **0.0005 %**; recomputed 0.000494 %. ✓
- Humans, RNp−RNm relative difference: printed **0.047 %**; recomputed
  0.0467 %. ✓

Applied to the apes, every printed statistic is reproduced (to the
precision the species means allow) **identically under both
arrangements**:

> "The highest RN volume relative to the brain volume was observed in
> prosimians (0.078%± 0.012% of brain volume), old world monkeys
> (0.073% ± 0.015%) and non-human apes (0.069% ± 0.006%; see
> Figure 8B)."

Recomputed ape value: 0.0698 % — printed arrangement and swapped alike.

> "More importantly, the relative volume of RNm in non-human apes and
> humans was one and two orders of magnitude smaller than in the rest,
> respectively (non-human apes: 0.003% ± 0.0004%, humans:
> 0.0005% ± 0.00005%)."

Recomputed ape value: 0.0032 % — both arrangements.

> "However, while in old world monkeys the RNp was about twice as large
> as the RNm … in humans and non-human apes the difference was 95-fold
> and twentyfold, respectively."

Humans reproduce exactly (95.6-fold). Apes: 22.5-fold (ratio of group
means) or 26.0-fold (mean of species ratios) — both arrangements,
because the swap pools the same five bundles.

> "The volume difference between RNm and RNp in humans and non-human
> apes was also higher compared to the rest, when considered relatively
> to the brain volume (0.047 and 0.061% of brain volume in humans and
> non-human apes, respectively)."

Recomputed ape value: 0.0635 % under both arrangements. (The small
offset from the printed 0.061 % under *both* arrangements indicates the
printed statistics were computed from the 11 individual specimens —
compare the text's own group size, "non-human apes (i.e., lesser and
great apes excluding humans) (n = 11)" — rather than from the five
species means; the offset does not favour either arrangement.)

This invariance is not a coincidence of these particular numbers: any
statistic that pools the five ape species' values is mathematically
identical under the swap, because the swap exchanges two complete
measurement bundles *within* the group.

### 5. The central claim — consistent under both arrangements

The paper's thesis is that Hominoidea — gibbons included — have a
miniaturised magnocellular red nucleus:

> "We show that humans and non-human apes have miniaturized RNm and
> significantly deviate from the scaling of the RNm with the total brain
> volume."

> "On the other hand, the RNp is well developed in these species but its
> volume in humans and non-human apes is within the expected range
> relative to the brain volume."

Under the printed arrangement, rel. RNm is 0.0047 % (Gorilla row) and
0.0036 % (Hylobates row); under the swap, 0.0036 % and 0.0047 %. Both
values sit inside the reduced hominoid band (~0.003 %, vs 0.025–0.047 %
in monkeys and prosimians) under either assignment, so the claim is
consistent with both and discriminates neither.

## What is missing

A demonstration from within the paper would need a within-paper source
generated **independently of the Table 3 species-mean pipeline**. None
exists:

- Table 2 names all three specimens (YN82-140; YN81-146, 3_97) but
  prints **no measurements** for them — there is no per-specimen BV or
  RN value anywhere in the paper to set against Table 3.
- No figure labels a species-level BV/RN point for either animal
  (Figure 10's points are unlabelled; Figure 8's caption ties it to
  Table 3).
- The article has no supplementary data tables, and the data
  availability statement offers no per-specimen deposit for the
  non-human material ("The original contributions presented in the study
  are included in the article/supplementary material, further inquiries
  can be directed to the corresponding author").

## Correction spec (NOT applied)

If the transposition is corrected on the external anatomical evidence,
the counts test (§1) fixes its exact form: exchange, between the
Gorilla gorilla and Hylobates lar rows of Table 3, **only** the five
measurement cells —

| Cell | Gorilla gorilla | Hylobates lar |
|---|---|---|
| Brain Volume, cm³ | 98.8 → **396.8** | 396.8 → **98.8** |
| RNp Volume Right, mm³ | 33.7 → **131.1** | 131.1 → **33.7** |
| RNp Volume Left, mm³ | 34.3 → **129.3** | 129.3 → **34.3** |
| RNm Volume Right, mm³ | 2.6 → **6.8** | 6.8 → **2.6** |
| RNm Volume Left, mm³ | 2.0 → **7.4** | 7.4 → **2.0** |

Taxon, Species and Number (1 for Gorilla, 2 for Hylobates) stay exactly
as printed. This package does not apply the correction; the build values
remain as printed, with the existing flag.
