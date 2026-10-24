# Merging reproductive life history: Asdell's root compendium + the compilations that cite it

`life_history_compiled.R` merges **Hayssen, van Tienhoven & van Tienhoven (1993), Asdell's Patterns of Mammalian
Reproduction** (transcribed per value in `Hayssen_etal_1993/`, 20 per-order items) with the four life-history
compilations in this repo that cite it: **PanTHERIA WR05** (Jones et al. 2009; Hayssen = reference 1297),
**AnAge build 15** (de Magalhães et al. 2024; BIBLIOID 00455), **Ernest 2003** (reference 1) and the
**Amniote database** (Myhrvold et al. 2015; named in the per-cell derivation string). Everything is harvested
from `__Public/comparative-data/`; the public/private boundary is not crossed.

Why a separate merge: `__merging_body_ecology` pools life-history columns of the brain papers (Lewitus 2014, Isler
2008, …) team/role-aware. Here the question is different — a **root source that cites every value** is placed
beside the compilations that re-export it, so that a compilation value can be told apart from an independent
measurement. The two merges should be reconciled once this one has been reviewed (open item below).

## Files

| file | contents |
|---|---|
| `life_history_source_columns.csv` | the crosswalk used: dataset, source column / Hayssen topic → canonical `Measure`, unit scale, admission rule, Hayssen's key in each compilation's reference system |
| `life_history_unfiltered.csv` | **one row per source record, nothing dropped** (83,923 rows): every Hayssen data line of a mapped topic (27,211; 17,282 admitted) and every published compilation cell of a mapped column; `value_canonical` in the canonical unit (admitted lines only), `value_canonical_any` the same number for every numeric Hayssen line whether admitted or not (used by the restricted `__life_history_root_comparison`), `derivation` where a unit scale or a range midpoint was applied (ranges, and `mode 3-4`-type lines, enter as midpoints), `admitted` + `admission_reason`, `role`, `cites_hayssen`, `cited_work` (Hayssen Literature Cited numbers / PanTHERIA reference list / AnAge BIBLIOIDs / Ernest numbers / Amniote derivation string), species resolution (`Species` = `_keys` accepted name or the cleaned printed name, `species_basis`) |
| `life_history_long.csv` | one row per `Species × Measure` (27,801 rows, 5,192 species): `Value` = median over **independent parties**, `n_independent`, `n_derived`, `Teams`, `roles`, `value_min/max`, `disagreement`; the root summarised beside it (`hayssen_median`, `hayssen_n_lines`, `hayssen_min/max`, `hayssen_refs`); `derived_values` and `derived_outside_root_range` for compilation values that cite Hayssen |
| `life_history_wide.csv` | Species × Measure matrix of `Value` |
| `life_history_species_alignment_candidates.csv` | Hayssen names matching no compilation species (406), each with the glyph-aware nearest name in the genus when one exists — a roadmap for `_keys` rows, **not applied** |

## Measures

Canonical names and units follow the restricted comparison's trait crosswalk so the two sides join:
`neonate_body_mass_g`, `weaning_body_mass_g`, `litter_size_n`, `litters_per_year_n`, `gestation_d`, `weaning_age_d`,
`interbirth_interval_d`, `female_maturity_age_d`, `male_maturity_age_d`, `neonate_head_body_length_mm`,
`weaning_head_body_length_mm`; Hayssen-only `estrous_cycle_length_d`; compilation-only `maximum_longevity_y`,
`adult_body_mass_g`, `age_at_first_reproduction_d` (Ernest AFR = age at first conception, kept apart from maturity).
Month = 365.25/12 d; Ernest months → days, PanTHERIA/Ernest longevity months → years, Amniote interbirth years → days
and SVL cm → mm.

## Admission (Hayssen lines)

A line is admitted when it is a central numeric value of the measure as the compilations define it: a point, mean,
mode or median, or a range (→ midpoint, derivation recorded); unit of the right kind; no measure label other than the
one the topic→measure map names (LACTATION → `weaning_age_d` only for `wean:` lines; SEXUAL MATURITY → female measure
for `f:`/unspecified, male measure for `m:`; NEONATAL/WEANING SIZE for unlabelled, `HB:` or `CR:` lines); for
LITTER SIZE the count word must be born young (`yg`, `ea`, none) — embryos, corpora lutea, placental scars,
implantations, blastocysts, ova are proxies and stay unadmitted. Bounds (`<`, `>`, max, min) and labelled
sub-measures (`1st mate:`, `implant:`, `solid food:` …) are kept in the unfiltered table with the reason.

## Pooling (compilation-aware)

Parties for a Species × Measure: the root (Hayssen, median of admitted lines) and each compilation whose record does
**not** cite Hayssen for that species. `Value` = median over parties. A compilation record that cites Hayssen is
`derived_from_root`: counted in `n_derived`, listed in `derived_values`, excluded from `Value`. Share of records
citing Hayssen: PanTHERIA 80%, AnAge 86%, Ernest 92%, Amniote database 2%
(the Amniote database string names Hayssen only when it is the median's source; the per-record sparse table is used
in the restricted comparison). No value is changed; `disagreement` (independent parties differ by > 25 %, or by > 1 for
counts) and `derived_outside_root_range` (a value citing Hayssen that lies outside the root's own range for the
species) are flags, not resolutions. Counts at the last run: 6,811 Species × Measure with a Hayssen value,
876 disagreements among independent parties, 2,202 derived values outside the root's range.

The record-level judgement of these flags — which are copying errors, unit slips, taxonomic mismatches or genuine
independent data — is in `Evo-M1-Trait-Data-restricted/__life_history_root_comparison/`.

## Open items

- **Species alignment.** 1,850 of 2,256 Hayssen species match a compilation species; the 406 others are OCR residue
  the within-family canonicalisation could not absorb, `spp` rows, and pre-MSW05 synonyms (the book follows Honacki
  et al. 1982). The candidate list is the roadmap; the fix belongs in `_keys`.
- **Reconcile with `__merging_body_ecology`'s life_history class** (Lewitus/Isler sources, ~100 species) — same
  measures, different sources; one home for the app.
- Printed p. 634 of the book (Muridae LACTATION) is not transcribed (see the Hayssen README); weaning ages of
  ~30 murid species are missing from the root for that reason.

## How to run

`Rscript __merging_life_history/life_history_compiled.R` (conda env `evom1-r`; ~1 min). Input problems stop; every
count is printed; outputs are UTF-8 BOM CSVs read back after writing (the read-back also refuses parse problems and
embedded NULs — a UTF-8 LC_CTYPE is set first because the C locale mangles the non-ASCII folder name).
