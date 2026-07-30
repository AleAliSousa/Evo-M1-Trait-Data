# Merging fossil-hominin brain glucose metabolism

Pipeline for compiling **whole-brain glucose utilization (BGU) of fossil hominins**
from three independent estimators into one merged dataset, mirroring the other
`__merging_*/` pipelines. Unlike `__merging_cerebral_metabolic_rate/` (extant,
per-100 g regional *rates*) this merge is **per fossil specimen** and holds
**absolute whole-brain glucose use** plus a modern-human-relative ratio.

**Scope: fossil hominin whole brain.** One `Measure`, `BGU`, in µmol glucose min⁻¹.
Estimates are absolute whole-brain glucose use (or, for the s4 team, a 6-region
cortical+cerebellar budget — see *Scope* below).

## Measure

| Measure | Meaning | Unit |
|---|---|---|
| `BGU` | whole-brain glucose utilization | µmol / min |

Modern-human anchor = **428.55 µmol min⁻¹** (Clarke & Sokoloff 1994 whole-brain
CMRglc, = the *Homo* value in Boyer & Harrington 2018 Table 2). Every estimate is
also expressed as `Ratio_MH` (estimate ÷ that method's own modern-human value),
which is the **only scope/convention-invariant quantity** and the basis for the
merged consensus.

## Estimators ("teams") and their data role

| Team | Rationale | Volume basis | Scope | Role |
|---|---|---|---|---|
| `Seymour_flow` | carotid blood-flow ∝ metabolism; scaled from modern-human reference (Seymour et al. 2016/2017) | endocranial capacity | whole brain | filtered |
| `Boyer_ACA_scaled` | Boyer & Harrington (2018) BGU~ACA+ECV; fossil ACA = carotid-ratio-scaled to modern human | endocranial capacity | whole brain | **filtered (primary arterial)** |
| `Boyer_ACA_ecvpred` | same regression, fossil ACA predicted from ECV via catarrhine allometry | endocranial capacity | whole brain | **unfiltered only (upper bound)** |
| `s4_volume` | Kochiyama (2018) regional volumes × Heiss (2004) rCMRGlc | brain tissue (GM+WM) | cortical+cerebellar (~77% of whole brain) | filtered |

## Why ratio-based resolution (not absolute team-averaging)

The three rationales are **not independent measurements of one quantity on one
scale**. They differ on two axes that would otherwise contaminate any average:

- **Volume convention.** Seymour "brain volume" and Boyer ECV are cranial /
  endocranial *capacity* (whole cavity incl. CSF, ventricles, meninges; verified
  — Seymour La Chapelle 1625 ≈ Hawks & Wolpoff cranial capacity 1626). s4 uses
  Kochiyama's MRI-based *brain-tissue* (GM+WM) volume, ~15–20 % smaller.
- **Metabolic scope.** Boyer/Seymour BGU is whole-brain (~429 µmol min⁻¹ in the
  modern human); s4's budget covers only the 6 Heiss cortical+cerebellar regions
  = 328.5 µmol min⁻¹ = 76.7 % of whole brain.

So absolute µmol min⁻¹ are comparable **only within a scope**, and the merge
resolves on `Ratio_MH`, which cancels both offsets:

1. Each team's estimate is divided by its own modern-human value.
2. Per specimen, the **consensus** `Ratio_MH` is the mean across the *filtered*
   teams (`Seymour_flow`, `Boyer_ACA_scaled`, `s4_volume`); `consensus_ratio_sd`
   is their spread (flags disagreement, e.g. Skhul 5 = 0.17).
3. `consensus_BGU_umol_min` = consensus `Ratio_MH` × 428.55 (whole-brain scale).

The `Boyer_ACA_ecvpred` variant is an **upper bound** (hominins fall below the
general euarchontan ACA–ECV line), so — like the anesthesia filter in the CMR
merge — it is retained in `*_unfiltered.csv` only and excluded from the consensus.

## Specimen key

The union of the Seymour (30) and s4 (8) specimen sets = **35** individuals.
Three appear in both and are the strict cross-team checks; the crosswalk maps
`Gibraltar (Forbes Quarry)`→`Forbes' Quarry 1`, `La Chapelle-aux-Saints`→
`La Chapelle-aux-Saints 1`, `Skhul 5`→`Skhul 5`. Seymour-only specimens carry the
two arterial teams; s4-only specimens (Amud 1, La Ferrassie 1, Qafzeh 9, Mladeč 1,
Cro-Magnon 1) carry only `s4_volume`.

## Steps

**Compile** — `build_fossil_brain_glucose_merge.py` (tested builder that generated
the shipped CSVs) **or** `fossil_brain_glucose_compiled.R` (house-style
equivalent; R was unavailable in the build environment, same arrangement as the
Karbowski / cerebral-metabolic-rate builds — both implement the same pipeline).
Refits the Boyer calibration (ln BGU = −0.139 + 0.440·ln ACA + 0.541·ln ECV;
R² = 0.9997; Duan 1983 smearing) and the catarrhine ACA–ECV allometry from the
staged inputs, then estimates, ratios, and resolves.

## Inputs (`inputs/`; staged copies for a self-contained build)

- `Boyer_Harrington_2018_Table2.csv` — 7-taxon BGU calibration
- `Boyer_Harrington_2018_Table1.csv` — extant euarchontans (catarrhine ACA–ECV)
- `Seymour_etal_2017_TableS1.csv` — 30 fossil hominin specimens
- `s4_specimen_budgets.csv` — s4 per-specimen volume budgets (from
  `analyses_metabol_rate_structure/data_intermediate/`)

## Outputs

- **`fossil_brain_glucose_long.csv`** — one row per Specimen × filtered Team:
  `Specimen, Species, Group, sapiens_grade, Measure, Units, Value, Ratio_MH,
  Scope, Volume_basis, Team, Source`.
- **`fossil_brain_glucose_wide.csv`** — one row per Specimen: `Species, Group,
  sapiens_grade`, each team's `__BGU` and `__ratio_MH`, plus `n_teams, teams,
  consensus_ratio_MH, consensus_ratio_sd, consensus_BGU_umol_min`.

### `sapiens_grade` — intra-species temporal grade

A generic column giving the within-species temporal level of a specimen, for
taxa that have such levels (only *H. sapiens* is graded in this dataset; extend
`GRADE_BY_SPECIMEN` in the builder for other taxa). It exists because the source
labels conflate fossils with living humans — see
`../____Collections and Specimen notes/EarlyHomoSapiens_fossil_vs_extant_specimen_note.md`.

| value | meaning |
|---|---|
| `early` | early/fossil *H. sapiens*: the 4 Kochiyama EH fossils (Qafzeh 9, Skhul 5, Mladeč 1, Cro-Magnon 1) **plus** two other early *H. sapiens* carried by Seymour/Boyer but not by Kochiyama — BC1 (Border Cave, ~80 ka) and LH 18 (Ngaloba, ~120 ka) |
| `recent` | recent modern-human specimens (M3-A343, M4-A344 Bushmen) |
| `modern_reference` | the mean-modern-human anchor (AS8078; `ratio_MH` == 1.0) |
| `NA` | no intra-species grade applies (Neanderthal, early *Homo*, *Australopithecus*) |

Note that `Group` still lumps `H. sapiens (early/recent)`; use `sapiens_grade`
to split early from recent/modern without tracing back to the inputs.
- **`fossil_brain_glucose_unfiltered.csv`** — all rows incl. the `Boyer_ACA_ecvpred`
  upper bound, with a `note` column.

## Cross-check (overlap specimens, `Ratio_MH`)

| Specimen | Seymour_flow | Boyer_ACA_scaled | s4_volume | consensus |
|---|---|---|---|---|
| La Chapelle-aux-Saints 1 | 0.94 | 1.06 | 1.04 | 1.02 |
| Forbes' Quarry 1 | 0.83 | 0.87 | 0.82 | 0.84 |
| Skhul 5 | 0.65 | 0.91 | 0.96 | 0.84 (sd 0.17) |

`Boyer_ACA_scaled` and `s4_volume` agree closely; `Seymour_flow` is low for
Skhul 5 (small carotid foramen for its brain size — noted by Seymour), which the
consensus SD flags.

## Caveats

- Neanderthal arterial sample is small (Seymour n = 2: Gibraltar, La Chapelle).
- Consensus averages *rationales*, not replicate measurements; `consensus_ratio_sd`
  is a method-spread, not a sampling error.
- s4-only specimens have `n_teams = 1` (no arterial data); their consensus is just
  the volumetric ratio.

## References

Boyer & Harrington 2018 *J. Hum. Evol.* 114:85–101 · Seymour et al. 2016/2017
*R. Soc. Open Sci.* 3:160305 / 4:170846 · Kochiyama et al. 2018 *Sci. Rep.* 8:6296 ·
Heiss et al. 2004 · Karbowski 2007 *BMC Biol.* 5:18 · Clarke & Sokoloff 1994 ·
Duan 1983 *JASA* 78:605–610.
