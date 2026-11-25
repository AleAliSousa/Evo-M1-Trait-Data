# Internal-consistency checks — Herculano-Houzel et al. (2015), all five tables

**Paper:** Herculano-Houzel, S., et al. (2015). Mammalian brains are made of these:
numbers of neurons and non-neuronal cells in the brains of 39 mammalian species.
*Brain, Behavior and Evolution* 86, 145–163. DOI 10.1159/000437413.

**Run:** `Rscript run_internal_checks.R` from this folder (inside the full repo it
also runs the merge-fidelity check; run as a lone folder that part is skipped with
a warning). Machine-readable output: `internal_checks_results.csv` — one row per
checked cell (table, species, structure, quantity, printed, recomputed, deviation %,
classification, note). All inputs are this folder's own files (built table CSVs and
`_snapshot.xlsx` files) plus, for check 5b, the isotropic-fractionator merge
outputs and standardized-term maps. Inputs verified byte-identical to live `main`
on 2026-11-20.

## Headline result

**4,513 cells checked — 4,381 PASS · 124 EXPECTED_DEVIATION · 8 SUSPECT.**

The 8 SUSPECT rows trace to **four errors in the published paper** (elephant cortex
other-cell count; rabbit cerebellum O/N; kudu olfactory-bulb other-cell count;
giraffe whole-brain % neurons) **plus one unresolved inconsistency** (shrew
whole-brain neuron number). **No SUSPECT cell is a repo extraction error**: the
extraction chain (published table → snapshot → built CSV → merge) is exact at
every one of the 3,916 fidelity cells checked.

| Check | Cells | PASS | EXPECTED | SUSPECT |
|---|---|---|---|---|
| 1–2. Derived quantities recomputed (O/N, N/mg, O/mg, % neurons) | 480 | 359 | 115 | 6 |
| 3. Copy-signature scan | (folded into checks 1–2) | — | — | 1 hit (the rabbit) |
| 4. Table 5 vs sum of Tables 1–3 | 117 | 106 | 9 | 2 |
| 5a. Fidelity: snapshot → built CSV | 1,751 | 1,751 | 0 | 0 |
| 5b. Fidelity: built CSV → merge (+ merge derivations) | 2,165 | 2,165 | 0 | 0 |

## Methods

### The per-specimen caveat, and the bands

HH2015's printed ratios and densities are **means over specimens of per-specimen
ratios/densities**, not ratios of the printed mean counts and masses. They
therefore legitimately deviate from the ratio of the printed means. The observed
distribution over all 480 derived cells:

| Quantity | n | median \|dev\| | 90th pct | 95th pct | max |
|---|---|---|---|---|---|
| O/N | 147 | 0.05% | 2.29% | 4.45% | 289% (rabbit) |
| N/mg | 150 | 0.28% | 3.50% | 6.36% | 11.9% |
| O/mg | 150 | 0.27% | 3.42% | 6.09% | 170% (elephant) |
| % Neurons (Table 5) | 33 | 0.08% | 1.62% | 2.95% | 6.37% (giraffe) |

Classification bands (deviation = (printed − recomputed)/recomputed × 100):

- **PASS** — |dev| ≤ max(1%, print-rounding allowance). Print rounding: O/N is
  printed to 3 decimals (half-unit 0.0005), densities as integers (0.5),
  % neurons to 1 decimal (0.05).
- **EXPECTED_DEVIATION** — 1% < |dev| ≤ 20%, multi-specimen row, no copy
  signature. This band is honest, not generous: it contains the whole observed
  per-specimen tail (95th percentile ≈ 6%; the largest benign cell is +15.6%),
  and it is corroborated by the control below.
- **SUSPECT** — any of: |dev| > 20%; a copy signature (below); a failed hard
  identity — a deviation beyond PASS in a **single-specimen row** (no SDs printed
  in Tables 1–3, or n = 1 printed in Tables 4–5), or a selective Table 5 sum
  deviation (check 4).

**The single-specimen control.** Where n = 1, per-specimen averaging cannot
operate: the printed derived value must equal the ratio of the printed counts
exactly. Empirically, every single-specimen row in Tables 1–4 agrees with its own
counts to ≤ 0.71% — **except precisely the cells classified SUSPECT below**.
That is what licenses treating the 1–20% band as benign for multi-specimen rows
while treating much smaller deviations as errors when n = 1.

### Check 3 — copy-signature scan

For every non-PASS printed derived value, the scan tests whether it equals —
within its own print rounding — the *recomputed* value of a different structure
for the same species, or of a different species in the same table (the rabbit
signature: a value copied across a row or column during table assembly). Eight
raw matches occur; seven are coincidences inside PASS cells (cerebellar O/N
values cluster tightly — 0.110, 0.184, 0.313, 4.618 each match a neighbour within
0.0005 while also matching their own row), and exactly one is a true signature:
the rabbit (below).

### Check 4 — Table 5 vs the structure tables

Table 5's whole brain **excludes the olfactory bulb**: summing Tables 1–3
reproduces Table 5 to ≤ 2% on all three quantities for 33 of 39 species, while
bulb-included sums overshoot systematically by the bulb's share. Sums of printed
means are exact if the same specimens underlie both, so the bands are: PASS
≤ 2%; EXPECTED_DEVIATION ≤ 10% with mixed signs across mass/N/O (the
whole-brain means were computed on a slightly different specimen set — the
pattern in *Otolemur garnettii* +5.5/−5.5/+8.3%, *Tupaia glis*, *Aotus
trivirgatus*, *Dasyprocta prymnolopha*); SUSPECT if one quantity deviates > 2%
while the other two agree to ≤ 0.5% (**selective deviation** — specimen-set
effects move all three quantities together; a single-quantity gap is a
transcription signature), or any quantity > 10%. All 39 Table 5 species are
present in all of Tables 1–3, so no partial sums arise. (*Gorilla gorilla*,
*Pongo pygmaeus* and *Callimico goeldii* appear in Tables 1–4 but have no
Table 5 row — a coverage fact, not an inconsistency. Six Table 5 species print
no % neurons, leaving 33 checkable % neurons cells.)

### Check 5 — extraction fidelity

Three layers, all exact:

- **Snapshot → built CSV** (1,751 mean and SD cells): the per-table
  `_snapshot.xlsx` files are the frozen published tables; the built CSVs match
  them cell for cell.
- **Built CSV → merge** (1,751 carried cells): every HH2015 value in the
  isotropic-fractionator merge's unfiltered output (checked against the long
  output as well) equals the built-CSV value, following the merge's own
  standardized-term maps. 125 of these cells sit under accepted/reidentified
  names rather than the printed ones (*Proechimys cayennensis* →
  *P. guyannensis*, *Cebus apella* → *Sapajus apella*, *Papio anubis
  cynocephalus* → *P. cynocephalus*, *Damaliscus dorcas phillipsi* →
  *D. pygargus phillipsi*); the values match exactly under those names.
- **Merge derivations** (414 cells): the merge's derived variables (per-structure
  C.n and p.C.N; whole-brain C.n, O.p.N, N.p.mg, O.p.mg) recompute exactly from
  the built tables.

Spot-verification against the published PDF itself (held in this folder) for
the three new suspect counts below — elephant cortex O, kudu bulb O, shrew
whole-brain N — confirms the PDF prints the same values as the snapshots and
CSVs (and the authors' workbook in this folder carries the elephant count
identically). **Every error below is in the published paper; Evo-M1 extracted
and carried all of them faithfully.**

## The SUSPECT cells, one by one

### 1. African elephant, cerebral cortex — the other-cell count is misprinted (Table 1; also Table 5 sum)

Printed row (n = 1, no SDs): mass 2,847.594 g, N = 5,593,241,033,
**O = 55,698,998,687**, N/mg 1,964, O/mg 52,721, O/N 26.844.

- N/mg recomputes exactly (1,964.2). O/mg and O/N do not: the counts give
  O/mg = 19,560 and O/N = 9.958 — both printed values are **+170%** off, by the
  *same* factor, while N/mg is exact. That pattern localises the error to the
  one input the two failing quantities share and N/mg does not: **the O count**.
- Both printed derived values were computed from an O of ≈ 1.501 × 10¹¹
  (150,128,003,274 implied by O/mg; the printed O/N implies the same to 0.01%).
- Independent corroboration inside the same paper: Table 5 prints whole-brain
  O = 216,057,982,337. The structure sum with the printed cortex count is
  121,610,534,807 (+77.7% gap — the second SUSPECT row for this error); with
  the density-implied cortex count it is 216,039,539,394 — agreement to
  **0.009%**.
- With n = 1, no averaging explanation is available. **Diagnosis: the cortex
  other-cell count in Table 1 is a misprint in the published paper; the value
  consistent with the paper's own densities, ratio and whole-brain total is
  ≈ 150,128,000,000.** The primary source (Herculano-Houzel et al., 2014) is
  not a dataset in this repo, but the internal evidence is three-against-one
  and decisive. Downstream note: the merge currently carries the inconsistent
  trio as printed (O.n = 55,698,998,687 alongside O/mg 52,721 and O.p.N
  26.844); a curator correction or flag should target the count.

### 2. Rabbit, cerebellum — O/N copied from the olfactory bulb (Table 2)

Printed O/N = **1.222**; the row's own counts (O 124,578,750 / N 396,671,250)
and densities (88,229 / 280,929) both give **0.314**. 1.222 is exactly the
rabbit's olfactory-bulb O/N in Table 4 (22,935,000 / 18,765,000 = 1.2222, where
it is internally consistent) — the copy signature this suite was built to hunt.
n = 1, so no averaging explanation. **Diagnosis: cross-structure copy error in
the published paper** (full investigation:
`~/workspace/evom1-cellproportions/hh2015_rabbit/FINDINGS.md`). **Resolved** by
the Herculano-Houzel et al. (2011) build — see check 6 below: the merged value
is now 0.31406, derived from the 2011 counts under the precedence pin.

### 3. Greater kudu, olfactory bulb — the other-cell count's leading digits are transposed (Table 4)

Printed row (n = 1, printed in the table): mass 5.546 g, N = 38,331,562,
**O = 362,731,438**, N/mg 6,912, O/mg 58,913, O/N 8.523.

- N/mg recomputes exactly (6,912). O/mg and O/N are both **−9.9%** off, by the
  same factor: both were computed from an O of ≈ 326.7 million (326,731,498
  implied by O/mg; 326,699,903 by O/N — the two agree to 0.01%, the residual
  being print rounding of mass and ratio).
- The printed count, 362,731,438, differs from the implied ≈326,731,4xx in the
  leading digit group: **362 for 326 — a digit transposition** introduced when
  the compilation's count was produced.
- **Adjudicated by a primary source in this repo:** Kazu et al. (2014)
  (`Kazu_etal_2014/`, the artiodactyl source for this row) prints for the same
  single specimen O.p.N = 8.523 and N/mg = 6,912 — agreeing with HH2015's
  derived values, not with its count. Kazu prints no O count, so the transposed
  count first appears in the 2015 compilation. **Diagnosis: paper error in
  HH2015 Table 4; the count should be ≈ 326.7 million.** The merge carries the
  printed (transposed) count alongside the correct ratio and density.

### 4. Giraffe, whole brain — % neurons carried from a different whole-brain row than the counts (Table 5)

Printed % neurons = **23.5**, but the row's own counts (N = 10,751,287,650,
O = 37,912,932,350) give **22.09** (+6.37% deviation), and n = 1 rules out
averaging. The counts themselves are coherent — they equal the sum of the
giraffe's structure tables exactly (check 4: 0.00% on all three quantities).
The printed 23.5 is, however, exactly what the primary source's whole-brain
ratio implies: Kazu et al. (2014) prints whole-brain O.p.N = 3.252 → % neurons
= 23.52. But Kazu's own whole-brain neuron count (11.21 × 10⁹) does not match
Kazu's own structure sum (10.7 × 10⁹; the repo's Kazu extraction flags −4.5%
on that row). **Diagnosis: HH2015's giraffe row mixes two provenances — counts
compiled as structure sums, % neurons carried from the primary's whole-brain
row, which is itself inconsistent with the primary's structures. The value
consistent with HH2015's printed counts is 22.1%.** A small error, but a real
one, and it propagates: the merge's WholeBrain_p.C.N for the giraffe is
derived from the counts (22.09), so the merged dataset and the paper's Table 5
disagree on this cell — the merge is the consistent one.

### 5. Short-tailed shrew (*Blarina brevicauda*), whole brain — neuron number disagrees with the structure sum (Table 5) — RESOLVED (Sarko et al. 2009 build, Nov 2026)

Table 5 prints whole-brain neurons = **55,190,000**; Tables 1–3 sum to
**51,646,000** (+6.86%). Brain mass and other cells agree with their sums to
**0.00%** — the selective-deviation signature: specimen-set differences move
all three quantities together (cf. the EXPECTED sum rows), so a single-quantity
gap with the other two exact points to a transcription error in one of the
four printed neuron numbers (Table 5's, or one structure's). Table 5's own
% neurons (64.8 vs 62.19 recomputed, +4.2%, EXPECTED band for n = 5) leans the
same way but cannot adjudicate. The primary source settles it: Sarko et al.
(2009), Table 1, corroborates the structure sum (51,646,400 against HH2015's
own 51,646,000), so the misprint is Table 5's printed whole-brain number.
**Diagnosis: HH2015 Table 5's whole-brain neuron count (55,190,000) is a
misprint; the structure sum stands.** (Context, not an excuse: the gap of 3,544,000 is within
Table 5's printed SD of 6,126,000 — but means over the same specimens must sum
exactly regardless of spread, and the exact mass/other-cell agreement says
the specimen sets are the same.)

## EXPECTED_DEVIATION — what the benign tail looks like

115 derived cells (1–20%) and 9 sum cells. The largest derived cells are the
known per-specimen cases, several independently documented during the
HH2011 build: grey squirrel RoB O/N +15.6%; marmoset olfactory-bulb O/mg
−15.4% and N/mg −11.8%; human RoB N/mg +11.9%; agouti olfactory-bulb N/mg
+11.6%; squirrel bulb O/N +9.3%; mole cortex N/mg +7.9%; guinea-pig RoB O/N
+7.6%; mouse RoB densities −7.5%. The 9 sum cells are the four
different-specimen-set species named in check 4. None of these cells shows a
copy signature, a single-specimen identity failure, or a selective pattern.

## Check 6 — the Glires species against Herculano-Houzel et al. (2011)

The 2011 Glires paper (11 species) is now built into Evo-M1 as the primary
source, with precedence over HH2015's re-carriage in the fractionator merge
(`~/workspace/evom1-glires2011/BUILD_REPORT.md`). Of the cells this suite
flags in HH2015's Glires rows — **59 in total: 1 SUSPECT + 58
EXPECTED_DEVIATION** — the position is:

- **The rabbit SUSPECT is resolved.** The precedence pin makes the merge take
  the 2011 item for every shared cell, and since the 2011 paper prints no
  ratios, the merged cerebellum O.p.N is *derived* from the 2011 counts:
  1.222 → **0.31406**. (HH2015's printed 1.222 remains in the unfiltered
  output at source level, as it should — the correction lands at priority
  resolution, not by editing the compilation's record.)
- **Every flagged EXPECTED Glires cell is likewise superseded in the merged
  output**: the merge now derives ratios/densities from the 2011 counts, so
  the merged values land on the ratio-of-means values (each within 0.1% of
  what HH2015's own counts derive). These are exactly the > 5% changed cells
  itemised in the build report §7 — squirrel RoB O/N, guinea-pig RoB O/N,
  mouse RoB and bulb densities, agouti cortex and bulb densities, squirrel
  bulb O/N. No surprises in either direction: the build's diff and this
  suite's flags are two views of the same cells.
- **Not flagged here, but changed by the build — a curator decision, not an
  error.** HH2015's olfactory-bulb *primary* values for rat and grey squirrel
  are internally consistent in both papers, but they rest on different
  samples than the 2011 paper published (bulb n: rat 5 in HH2015 vs 4 in
  2011; squirrel 9 vs 3; spiny rat 1 vs 2, values agreeing ≤ 0.5%). Internal
  checks cannot flag either side; precedence gives the merged output the
  2011 values (squirrel bulb N −13.0%, bulb mass +6.6%; rat bulb mass +4.1%,
  O +3.9% relative to HH2015). If the larger-n 2015 bulb samples should win
  for those two species, that needs an explicit carve-out — see the build
  report §8.
- **One cell where the compilation is right and the primary misprints:**
  prairie dog (*Cynomys* sp.) whole-brain neurons — 2011 prints 473.94 × 10⁶
  (a digit transposition; its own structure parts sum to 437.94 × 10⁶),
  HH2015 Table 5 prints the correct 437,943,767, and this suite does not flag
  it. The 2011 build guards the misprint on its side (§3.4d of its compiled
  script). Do not "correct" HH2015 from 2011 here.
- **Agouti whole-brain counts** deviate from the structure sums in *both*
  papers by the same amount (this suite: Table 5 neurons −3.89%, EXPECTED;
  the 2011 build's own table checks fail identically) — the authors' reported
  values, left as printed on both sides.

## Bottom line for curators

Four printed values in HH2015 are wrong and worth a value flag (or correction)
in the dataset: elephant cortex O (Table 1), rabbit cerebellum O/N (Table 2 —
already resolved via HH2011), kudu bulb O (Table 4), giraffe % neurons
(Table 5). One more (shrew whole-brain N, Table 5) is certainly wrong in one
of four cells but cannot be adjudicated without Sarko et al. (2009). Nothing
in HH2015's Evo-M1 extraction or merge wiring needs repair: fidelity is exact
at all 3,916 checked cells.
