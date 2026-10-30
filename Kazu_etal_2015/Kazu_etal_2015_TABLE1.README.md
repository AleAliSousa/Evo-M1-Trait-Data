# Kazu et al. 2015 — CORRIGENDUM, TABLE 1 (Artiodactyla cell counts)

**Built 2026-08-06.** This table **supersedes `Kazu_etal_2014_Table1`**. Use this one.

## Source

Kazu, R. S., Maldonado, J., Mota, B., Manger, P. R., & Herculano-Houzel, S. (2015).
*Corrigendum: Cellular scaling rules for the brain of Artiodactyla include a highly folded cortex
with few neurons.* **Front. Neuroanat. 9:39.** DOI **10.3389/fnana.2015.00039**.
Corrigendum to Front. Neuroanat. 8:128 (DOI 10.3389/fnana.2014.00128).

**Printed source → snapshot required.** `Kazu_etal_2015_TABLE1_snapshot.xlsx` (sheet `TABLE1`),
built by `Kazu_etal_2015_extract_snapshot.py` from p. 2 of the corrigendum PDF.

| File | |
|---|---|
| `Kazu-2015-Corrigendum_ Cellular scaling rules.pdf` | the printed source (3 pp.; TABLE 1 on p. 2) |
| `Kazu_etal_2015_extract_snapshot.py` | capture script |
| `Kazu_etal_2015_TABLE1_snapshot.xlsx` | **frozen source** — caption, species header, 39 printed rows, legend |
| `Kazu_etal_2015_TABLE1.R` | reformat: snapshot → CSV + TSV |
| `Kazu_etal_2015_TABLE1.csv` | analysis table — **5 species × 46 columns** |
| `comparison/Kazu_etal_2015_TABLE1_compare_to_Kazu_2014.R` (+ report) | the cell-by-cell diff against the 2014 printing |
| `__Public/comparative-data/10.3389%2Ffnana.2015.00039_TABLE1.tsv` | public TSV |

## Why it supersedes 2014, in the corrigendum's own words

> "values for the hippocampus had in four cases been included in the rest of brain, not cerebral
> cortex, in Table 1, and had failed to be included for *Damaliscus*. There were a few other minor
> mistakes in the table that are now also corrected."

`Kazu_etal_2015_TABLE1.R` is a deliberate **line-for-line parallel** of the 2014 reformat — same
parser, same label map, same column schema, same consistency checks — which is what makes the two
directly diffable.

### The diff (comparison/…_vs_Kazu_2014_report.csv)

**71 of the 184 cells present in both printings changed — 39%.** Per species: *Damaliscus* 20,
giraffe 17, kudu 16, springbok 12, pig 6. Six terms changed for **every** species —
`CerebralCortex_Mass.g`, `CerebralCortex_N.n`, `CerebralCortex_N.p.mg`, `CerebralCortex_O.p.N`,
`WholeBrain_Mass.g`, `WholeBrain_O.p.N` — exactly the footprint of moving the hippocampus out of
rest-of-brain and into cortex. Largest single changes: giraffe `DiencephalonStriatum_N.n` +100%,
kudu `Mesencephalon_N.p.mg` +58%, *Damaliscus* `WholeBrain_N.n` −22%.

### The check the 2014 printing failed

Whole-brain neurons should equal cortex + cerebellum + rest of brain. In the 2014 build this was
out by **−0.4% to −22.0%** across four of five species. Here:

| Species | discrepancy |
|---|---|
| *Sus scrofa domesticus* | +0.26% |
| *Antidorcas marsupialis* | +0.27% |
| *Damaliscus pygargus phillipsi* | −0.09% |
| *Tragelaphus strepsiceros* | −0.02% |
| *Giraffa camelopardalis* | +0.03% |

All within the rounding of the printed three-significant-figure values. This is the strongest
single confirmation both that the corrigendum fixed the misallocation and that the extraction is
right.

## Verification against the corrigendum's own stated numbers

| Stated | Recomputed | |
|---|---|---|
| brain mass varies **8.4-fold** | 8.37 | ✅ |
| brain neurons vary **4.8-fold** | 4.84 | ✅ |
| cortex = **15.7 ± 0.8%** of brain neurons | 15.7 ± 0.8 | ✅ |
| cortex = **69.5 ± 1.8%** of brain mass | **69.3 ± 1.8** | ⚠️ see below |
| O/N minimum **0.184**, blesbok cerebellum | 0.184, *Damaliscus* cerebellum | ✅ |
| O/N maximum **34.190**, giraffe rest of brain | 34.190 — but see below | ⚠️ |
| O/N in cortical grey **7.2–8.8** | 7.239–8.754 | ✅ |
| rest-of-brain density max **4238**, pig | 4238, *Sus* | ✅ |
| rest-of-brain density min, greater kudu | 1727, *Tragelaphus* | ✅ |

Two places where the corrigendum's **text disagrees with its own table** — both recorded, neither
corrected:

1. **Cortex % of brain mass.** Every sensible computation from the table gives **69.3 ± 1.8**, not
   69.5 ± 1.8. The SEM matches exactly, so only the mean differs.
2. **O/N maximum.** 34.190 (giraffe rest of brain) is the maximum across the *major* structures
   (BR, CXT, GM, HP, CB, RoB), and that is what the sentence covers. The table's overall maximum is
   **41.017**, the giraffe mesencephalon — an RoB subdivision the sentence does not mention.

## Remaining internal inconsistencies (flagged, not repaired)

`consistency_flags` carries three, down from the 2014 printing's much longer list:

- giraffe `DN_Hippocampus` printed 8435 but `N/M` = 7827 (7.8%)
- kudu `DN_Mesencephalon` printed 2594 but `N/M` = 2021 (28.4%)
- kudu `M_CXT + M_CB + M_RoB` = 306.862 vs `M_BR` = 306.860 (0.002 g, rounding)

`parse_flags` records the pig's body mass as printed `~100` — approximate, as the paper marks it.

## Merged — the team rule does the de-duplication, no manual column filtering

**LIVE in `__merging_cellcounts/cellcounts_compiled.R` since 2026-08-06.** Kazu is
Herculano-Houzel–team work, so it goes through §8.2.H's existing resolution: within a team each
source gets a priority by **date, then number of species**, and for every species × variable only
the best-priority source survives. Nothing here is special-cased.

All five species are also in `HerculanoHouzel_etal_2015` Tables 1–5. Both sources are dated
**2015**, so the date ties and the tie-break on species count hands the shared variables to HH
(40-ish species against 5). Kazu then contributes only what HH does not carry. Simulated against
the actual published TSVs:

| | |
|---|---|
| species × variable pairs where **both** have a value → **HH wins** | **80** |
| of those 80, values differing by more than 2% | **0** |
| pairs only Kazu has → fills a **sub-structure** gap | **87** |
| pairs only Kazu has → fills a whole-structure gap | **21** |

**Zero double-counting, and zero disagreement where they overlap** — which independently confirms
that HH 2015's full-precision values already are the corrigendum's (e.g. *Sus*
`CerebralCortex_N.n` 307,082,404 against the printed 307.08 × 10⁶), so which source wins does not
change the data.

The 87 sub-structure values Kazu uniquely adds: **hippocampus 20, pons + medulla 20,
diencephalon + basal ganglia 16, mesencephalon 16, cortical grey matter 15**.

`standardized_term_by_reference/Kazu_etal_2015_TABLE1_standardized_terms.csv` is an identity map —
the build already emits canonical `<Structure>_<Measure>` names — with `n → WholeBrain_n`. Every
column is listed, because the compile renames by `match()` and any unlisted column would become an
`NA` column name.

## Other notes

- **Species names.** Five `Kazu2015` rows added to `_keys/Stephan/species_key.csv`, mirroring the
  `Kazu2014` set — the corrigendum reprints the same five printed names, including the misprint
  *Tragelaphus stripceros* (→ *T. strepsiceros*, spelled correctly in the 2014 Methods) and
  *Damaliscus dorcas phillipsi* (→ *D. pygargus phillipsi*).
- **Subscript casing.** The corrigendum prints `M_CxT` / `N_CxT` / `DN_CxT` with a lowercase x but
  `O/N_CXT` with uppercase, for the same structure. Labels stay verbatim in the snapshot; the
  structure lookup matches case-insensitively.
- **Units.** Masses in g as printed; body mass kg → **g** (×1000); densities neurons/mg; O/N
  dimensionless. All values are both hemispheres. Whole brain excludes the olfactory bulb.
- **Blank vs zero.** No zeros anywhere. 21 `n.a.` cells — all in the *Damaliscus* column, whose
  cortex was processed as grey/white only.
- The corrigendum also reprints corrected power-function exponents in its text. Those are
  regression statistics, not species trait values — not registered, not built.
- **Re-run `Kazu_etal_2015_TABLE1.R` and the comparison script in RStudio** to confirm they
  reproduce the committed files; they were written by an offline mirror (no R in the authoring
  environment).
