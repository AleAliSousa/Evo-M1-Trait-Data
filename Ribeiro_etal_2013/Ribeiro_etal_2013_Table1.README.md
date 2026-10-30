# Ribeiro, Ventura-Antunes, Gabi, Mota, Grinberg, Farfel, Ferretti-Rebustini, Leite, Jacob Filho & Herculano-Houzel 2013 — Table 1 (human cortical cell densities by region)

Ribeiro PFM, Ventura-Antunes L, Gabi M, Mota B, Grinberg LT, Farfel JM,
Ferretti-Rebustini REL, Leite REP, Jacob Filho W, Herculano-Houzel S (2013). *The human
cerebral cortex is neither one nor many: neuronal distribution reveals two quantitatively
different zones in the gray matter, three in the white matter, and explains local
variations in cortical folding.* Front. Neuroanat. 7:28. doi:**10.3389/fnana.2013.00028**
Table 1, "Mean neuronal density, other cell density and other cell/neuron ratio across
cortical regions", article/PDF **p. 7**.

Status: **BUILT** (snapshot → CSV → definitions). Whether it enters the cell-count merge is
still the curator's open decision — see "Merge-include decision" below.

## What was built

| file | what it is |
|---|---|
| `Ribeiro_etal_2013_extract_snapshot.py` | reproducible capture of Table 1 from the PDF |
| `Ribeiro_etal_2013_Table1_snapshot.xlsx` (sheet `Table1`) | the **frozen** printed table: caption, printed header (`Neuronal density ± SE` …), the 7 printed region rows in printed order, the significance asterisks, the full legend |
| `Ribeiro_etal_2013_Table1.R` | the canonical reformat: frozen snapshot → analysis CSV (+ public TSV) |
| `Ribeiro_etal_2013_Table1.csv` | **7 rows × 17 columns** — one row per printed cortical region |
| `reference_tables/Ribeiro_etal_2013_Table1_definitions.csv` | data dictionary, 20 rows (17 Codes = the 17 CSV columns, + 3 `Method:*` rows) |
| `PROPOSED_species_key_rows.csv` | one `Ribeiro2013` row (`human` → *Homo sapiens*) for `_keys/Stephan/species_key.csv` |

### Why coordinate extraction

The Frontiers text layer stores no space glyphs, and inside a cell the digits, the decimal
point, the thousands comma, the `±` and the significance asterisks all sit on **different
baselines** — `17,742 ± 4,240` arrives as three interleaved text lines. Read line by line
the numbers scramble (`4, 240`, `2291`). The extractor groups characters into printed rows
by baseline and then orders every character by x, so `2 . 2 9 1` recomposes as `2.291` and
`4 , 240` as `4,240`. All 21 measured cells parsed; `parse_flags` is empty for every row.

## Granularity: one row per printed region, one individual

The paper analysed a **single hemisphere of a single brain** — the right cerebral cortex of
a 65-year-old human female, cut into **101 coronal sections of 2 mm** (Methods, "Subject"
and "Morphometry"). `n = 1` on every row. Each printed value is a **mean across the coronal
sections of that region**, unweighted by section mass, so the seven region means **cannot
be recombined into a cortex-wide mean**.

Region section ranges, from the Methods (recorded here, not in the CSV): prefrontal 1–17,
"dorsal" 18–57, temporal 26–57, insula 32–51, "parietal" 58–72, "occipital" 73–101; V1 was
counted separately where the stria of Gennari was visible and its values are *also* inside
the occipital data points.

⚠️ **The printed row labels do not match the Methods' region names.** Table 1 lists
*Prefrontal, Frontal, Temporal, Insula, Parietal, Posterior, V1*, while the Methods and all
figure legends use *prefrontal, dorsal, temporal, insular, parietal, occipital, V1*. The
text points at Table 1 when discussing "dorsal" and "occipital" cortex, so **Table 1's
"Frontal" is the Methods' "dorsal" and its "Posterior" is the Methods' "occipital"**. That
is an inference from the cross-references, not something the paper states; both label sets
are recorded in `Region` / the definitions rather than silently harmonised.

## *** REGIONAL — never pooled ***

These are **within-cortex regional densities**. *Homo sapiens* already carries whole-cortex
`CerebralCortex_*` values in `__merging_cellcounts` (from Herculano-Houzel et al. 2015).
The seven values here must **never** be averaged into, summed with, or substituted for
those — exactly the rule `Jacobs_etal_2018/README.md` states for M1. They also must not be
pooled with each other (see the unweighted-mean point above), and V1 must not be added to
"Posterior" (V1 is already inside it).

`region_term` in the CSV offers the never-pooled naming
(`PrefrontalCortexGrey`, `FrontalCortexGrey`, …, `V1CortexGrey`). It is **mechanically
derived** from the printed label in the `.R` rather than hand-listed, because the regional
vocabulary decision is still open in
`__merging_cellcounts/HH_coverage_gaps_scaffold.md` ("Design note"). Rename it there when
that decision is made; nothing downstream depends on the current spelling.

## Units

The printed header carries **no units**. They come from the Results text ("neuronal density
varies 5× (between approximately 10,000 and 50,000 **N/mg**), and other cell density varies
3× (approximately 30,000–90,000 **O/mg**)"), and the Methods define `DN`/`DO` as densities
**in the gray matter**. So:

* `CorticalGrey_N.p.mg` — neurons per **mg of cortical grey matter**
* `CorticalGrey_O.p.mg` — other (non-neuronal) cells per **mg of cortical grey matter**
* `CorticalGrey_O.p.N` — dimensionless ratio

**No unit conversion is applied.** The printed range (17,742–58,162 N/mg) sits inside the
10,000–50,000 the text quotes except for V1, which the text separately calls out as
reaching "an average 58,162 ± 13,640 N/mg" — see the discrepancy note below.

### Blank vs zero, and SE vs SD

* No blanks, no `n.a.`, no zeros: all 7 × 3 printed cells carry a mean and a dispersion.
* The asterisks are kept, split into `sig_N.p.mg` / `sig_O.p.mg` / `sig_O.p.N`, and are
  `NA` where the print has none (Prefrontal/Frontal/Temporal/Insula, plus the
  other-cell and O/N columns of Parietal). `NA` here means "no marker printed", i.e. not
  significant, not "missing".
* ⚠️ **The paper contradicts itself about the dispersion.** The printed column header says
  `± SE` for all three columns; the printed legend says "mean neuronal density ± standard
  error (second column), mean other cell density ± **standard deviation** (third column),
  other cell/neuron ratio ± **standard deviation** (fourth column)". The columns are named
  `_SE` after the header and the contradiction is recorded in the definitions. Unresolved
  in the source — treat columns 3 and 4's dispersion as ambiguous.

## Verification (recomputed from the built CSV)

**The O/N check the parent asked for.** Printed `O/N ratio` vs
`Other cell density ÷ Neuronal density`, row by row:

| Region | printed O/N | O-density ÷ N-density | difference |
|---|---|---|---|
| Prefrontal | 2.291 | 2.2576 | **+1.48 %** |
| Frontal | 2.713 | 2.6460 | **+2.53 %** |
| Temporal | 2.638 | 2.5673 | **+2.75 %** |
| Insula | 2.102 | 2.0606 | **+2.01 %** |
| Parietal | 2.208 | 2.1881 | **+0.91 %** |
| Posterior | 1.712 | 1.6773 | **+2.07 %** |
| V1 | 1.306 | 1.2760 | **+2.35 %** |

**Verdict: consistent, but it is not an identity — do not treat a mismatch here as an
error.** All seven printed ratios are *larger* than the ratio of the printed means, by
0.9–2.8 %. That is exactly what is expected: each printed value is a mean over the sections
of the region, and mean(Oᵢ/Nᵢ) ≥ mean(Oᵢ)/mean(Nᵢ) by Jensen's inequality. The systematic
positive sign and the small, uniform size are the pass condition; a *negative* difference
or one over ~5 % would indicate a transcription error. The `.R` prints this table on every
run, stores it as `ONratio_check_from_densities` / `ONratio_check_pct_diff` (role `note`,
not measurements), and warns above 5 %.

Other paper statements checked against the built table:

| claim | recomputed | verdict |
|---|---|---|
| V1 reaches "an average **58,162 ± 13,640** N/mg" (Results, p. 6) | Table 1 prints **58,162 ± 13,641** | **mean passes; the SE differs by 1 between text and table** — off-by-one rounding, recorded not fixed |
| neuronal density "varies 5×" along the AP axis | 58,162 / 17,742 = **3.28×** across the seven *region means* | **not comparable** — the 5× claim is across the 101 individual sections (≈10,000–50,000 N/mg), not across region means; the region means are averages and compress the range |
| other cell density "varies 3×" | 74,214 / 40,055 = **1.85×** across region means | same reason — **not comparable** |
| O/N "varies by approximately 4×" along the AP axis | 2.713 / 1.306 = **2.08×** across region means | same reason — **not comparable** |
| "the O/N ratio is larger than 1.0 in all sections" | all 7 region means are 1.31–2.71 | **pass** |
| densities are highest in the occipital cortex and higher still in V1 | Posterior 38,960 < V1 58,162, both above every anterior region | **pass** |
| hemisphere totals: 4.63 bn neurons, 24.33 bn other cells, 15.49 bn of the latter in white matter (Results, p. 4) | **not checkable from Table 1** — the table has densities only, no masses and no totals | not checked |

## Merge-include decision (still open)

Unchanged from the scaffold, and this build does not settle it. Two live options:

1. **Reference only** (what `HerculanoHouzel_etal_2013` mouse areas does today): keep the
   built table for provenance and leave `Ribeiro_etal_2013_Table1` commented out in
   `cellcounts_compiled.R` `item_name`.
2. **Merge as regional terms**: requires the regional-vocabulary decision in
   `HH_coverage_gaps_scaffold.md`, and a reshape — the merge expects **species-as-rows**,
   and this table is one species × seven regions. The standardized-terms file would have to
   map region × measure into 21 wide columns (`PrefrontalCortexGrey_N.p.mg`, …), i.e. the
   `.R` would need a pivot step added after section 5.

Nothing in `__merging_cellcounts/` was touched by this build (no standardized-terms file
was written; there was no stub for this paper). No `.tsv` was written to
`__Public/comparative-data/` — the `.R` writes it when sourced; publishing is separate.

No comparison script (HOWTO §7): there is no independent curated copy of this table.
