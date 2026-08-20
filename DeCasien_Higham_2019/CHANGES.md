# deSousa 2010 provenance fix — DeCasien BrainRegion comparison

## Problem

`DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R` matches DeCasien & Higham's
compiled brain-region volumes (MOESM3) against this repo's merged dataset. For deSousa 2010
it did **not** read the paper's snapshot-derived TSVs — it carried a hardcoded
`desousa_specimens <- data.frame(...)` block of 29 brains × 5 columns, raw numbers typed
straight into the script. Its header comment asserted *"no digitized per-brain TSV exists"*,
which was false: `deSousa_etal_2010_Table1.R` already writes
`__Public/comparative-data/10.1016%2Fj.jhevol.2009.11.011_Table1.tsv`.

Worse, the hardcoded block computed **LGN** as per-specimen `left_LGN × 2`. But DeCasien's
reference 60 (= deSousa 2010) draws its LGN from the paper's **Supplementary Table 2**, which
reports a species-mean **bilateral** LGN (Gorilla 309, Pongo 259, Pan paniscus 275,
Pan troglodytes 251, Hylobates 166, Macaca 92 mm³). The `left × 2` reconstruction gives e.g.
Gorilla 400 ≠ 309, so those LGN cells never matched deSousa 2010 — they fell to
`decasien_only` or were mis-attributed to **deSousa 2013**, **Bauernfeind 2013**, or
**Barger 2007** by coincidental value.

## Root cause

deSousa 2010 published two items. Table 1 (per-specimen, left-side V1/LGN) had a converter +
Public TSV + standardized-terms key. Supplementary Table 2 (species means, bilateral V1/LGN)
had a converter (`deSousa_etal_2010_SupTable2.R`) that wrote only a local CSV — **no Public
TSV and no standardized-terms key** — so its species-mean bilateral LGN was invisible to the
matcher. The hardcoded paste-in was a workaround for that gap.

## Changes

1. **`deSousa_etal_2010/deSousa_etal_2010_SupTable2.R`** — appended a Public-TSV writer tail
   identical in pattern to `deSousa_etal_2010_Table1.R`: it looks up the encoded name in
   `__ReadMe.xlsx` (`Item name` → `Item encoded` = `10.1016%2Fj.jhevol.2009.11.011_SupTable2`)
   and writes `__Public/comparative-data/10.1016%2Fj.jhevol.2009.11.011_SupTable2.tsv`
   (44 species rows). No existing value-correction logic changed.

2. **`__merging_volumes/standardized_term_by_reference/deSousa_etal_2010_SupTable2_standardized_terms.csv`**
   (new) — the missing crosswalk key, mirroring the Table 1 key. Maps SupTable 2 columns to
   canonical **bilateral** (`_Vol.mm3`, no `_left` suffix) terms:
   `brain_volume_cm3 → Total_brain_net_volume_Vol.mm3`,
   `neocortex_volume_cm3 → Neocortex_Vol.mm3`,
   `V1_area_striata_volume_cm3 → Area_striata_grey_matter_Vol.mm3`,
   `LGN_volume_cm3 → Corpus_geniculatum_laterale_Vol.mm3`.
   `standardized_term_volumes.csv` regenerated (300 rows) to register it.

3. **`DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R`** — deleted the hardcoded
   `desousa_specimens` data.frame and its four `addspec()` calls; replaced with `rd_cd()` reads
   of the two Public TSVs, applying the repo's standard conversions (cm³→mm³; left→bilateral by
   doubling for Table 1's per-specimen columns; SupTable 2's V1/LGN already bilateral). Corrected
   the false header comments. **No raw numeric literals remain** — every deSousa value flows from
   a TSV via a unit/hemisphere conversion. New source labels:
   `deSousa2010_Table1_specimen`, `deSousa2010_Table1_specimen_bilateral_est`,
   `deSousa2010_SupTable2_speciesmean`.

4. Regenerated **`DeCasien_vs_merge_comparison.csv`**, **`DeCasien_taxonomy_proposed_changes.csv`**,
   **`DeCasien_Higham_2019_FINDINGS.md`**.

## Result

All six deSousa-2010 LGN cells now match `deSousa2010_SupTable2_speciesmean` at **0.0 %**
difference (five `match`, one `match_taxonomy_variant` for Gorilla gorilla vs our "Gorilla sp.").
Overall across 2190 DeCasien cells: `match` +23, `decasien_only` −21,
`value_match_other_structure` −5, no category regressed. In the regenerated comparison, of the
63 deSousa ref-60 cells **61 are sourced to deSousa-2010 TSVs**
(`deSousa_etal_2010_Table1`=33, `deSousa2010_Table1_specimen_bilateral_est`=18,
`deSousa2010_SupTable2_speciesmean`=10). The remaining **two** cells match a non-deSousa source
by coincidental same-structure value — Pan troglodytes BV 330000 → `Bauernfeind_specimen` 329340
(0.2 %), and Pongo pygmaeus V1 8400 → `Zilles_Rehkämper_1988_Table12-2` 8400 (0.0 %) — both
legitimate same-structure matches elsewhere in the merge, not deSousa mis-attributions.
(In the separate step-1 sanity check `deSousa_provenance_check.csv`, which forces each cell
against only the two deSousa TSVs with a 2 % tolerance, 62/63 cells reproduce; the single
non-reproducing cell there is Pan troglodytes BV 330000, ~3.2 % above SupTable 2's species-mean
319700 — its companion LGN 251 matches exactly.) See `desousa_match_diff.md` and
`deSousa_provenance_check.csv`.

## Run order

1. `deSousa_etal_2010/deSousa_etal_2010_SupTable2.R`  → writes the SupTable 2 Public TSV
   (`deSousa_etal_2010_Table1.R` already writes the Table 1 TSV)
2. `__merging_volumes/standardized_term.R`  → regenerates `standardized_term_volumes.csv`
   (only needed if the merge itself is rebuilt; the comparison script reads the TSVs directly)
3. `DeCasien_Higham_2019/DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R`  → comparison outputs

## 5. `__merging_volumes/volumes_compiled_DeCasien.R` — stale comment reconciled (comment only)

Line ~202 carried a stale comment claiming the deSousa Table 1 TSV was *"rebuilt to mm3
both-sides columns … term map updated to match … this cm3->mm3 line is now a no-op"*. That was
false: the TSV on disk still has per-specimen `brain_volume_cm3` / `neocortex_volume_cm3` /
`left_V1_volume_cm3` / `left_LGN_volume_cm3` (cm³, left-side V1/LGN), the Table 1
standardized-terms key still maps V1/LGN to `*_left_Vol.mm3`, and the
`across(ends_with("_cm3"), ~num(.x)*1000)` line converts all four columns — it does real work,
not a no-op. Replaced the comment with an accurate description of the per-specimen cm³→mm³
conversion and the left-hemisphere V1/LGN mapping (Supp. Table 2 carries the bilateral means).
**Code line unchanged; behaviour identical** (verified: the script still parses). This does not
affect the DeCasien comparison, which reads the TSVs directly.

---

# Recovering unpublished-via-DeCasien values + wiring the annotated comparisons

Follow-up to the user's annotations in `DeCasien_vs_merge_comparison_DeCasien_changethis4.csv`
("DO THIS" column, 66 rows). The annotations flag four situations: **A** values Barks/Sherwood
never published (recover them, via DeCasien, as new datasets), **B** DeCasien values that
disagree with their cited source, **C** values that exist in a cited table but need a
conversion/crosswalk to match, and **D** a taxonomy/attribution problem. Scope agreed with the
user: **wire in C, document B and D**, and place the new datasets **in the source-paper folders**.

## 6. New dataset — `Barks_etal_2014_unpublishedviaDeCasien` (class A)

Barks et al. 2014 published per-individual **whole-brain** volume (Table 1) and **species-mean**
regional volumes (Figs 4A/5A) — but never the per-individual **regional** volumes. DeCasien &
Higham (2019) MOESM3 lists them per specimen (reference 65): 33 gorilla brains (16 *G. g.
gorilla*, 14 *G. beringei*, 3 *G. g. graueri*), with cerebellum, striatum, hippocampus, neocortex
GM+WM, neocortex GM, amygdala, insula GM. Added, in `Barks_etal_2014/`:

- `Barks_etal_2014_unpublishedviaDeCasien_snapshot.xlsx` — the 33 individual rows extracted from
  MOESM3 (already mm³), each linked to its Barks 2014 Table 1 specimen number by whole-brain match.
- `Barks_etal_2014_unpublishedviaDeCasien.R` — converter mirroring the deSousa path-detector +
  `__ReadMe.xlsx`-lookup TSV-writer pattern. No unit conversion (MOESM3 is already mm³).
- `__Public/comparative-data/10.1002%2Fajpa.22646_unpublishedviaDeCasien.tsv` (33 rows) — written
  by the converter; encoded name from the pre-registered `__ReadMe.xlsx` row.
- `__merging_volumes/standardized_term_by_reference/Barks_etal_2014_unpublishedviaDeCasien_standardized_terms.csv`
  (9 rows) — crosswalk to canonical `_Vol.mm3` terms.

## 7. New dataset — `Sherwood_etal_2004_unpublishedviaDeCasien` (class A)

Sherwood et al. 2004 Table I published four gorilla individuals; MOESM3 (reference 64) lists six.
Two are **not** in Table I (*G. beringei* BV 460600 / Thalamus 8300; *G. g. gorilla* BV 459400 /
Thalamus 11400) — per the DeCasien methods, some Sherwood values were "provided by the author
(Sherwood 2018, personal communication)." Added, in `Sherwood_etal_2004/`:

- `Sherwood_etal_2004_unpublishedviaDeCasien_snapshot.xlsx` — the two unpublished individuals.
  **Only BV and Thalamus** are carried: in MOESM3 these ref-64 rows are flagged "F" (cerebellum /
  neocortex / striatum / hippocampus replaced with Barks measurements), so only whole-brain and
  thalamus are genuinely Sherwood-sourced.
- `Sherwood_etal_2004_unpublishedviaDeCasien.R` — converter (same pattern).
- `__Public/comparative-data/10.1002%2Fajp.20048_unpublishedviaDeCasien.tsv` (2 rows).
- `..._standardized_terms.csv` (3 rows: species, BV, Thalamus).

`standardized_term_volumes.csv` regenerated to 312 rows (44 per-reference files) to register both
new keys.

**Note on scope:** the two unpublished-via-DeCasien TSVs are deliberately **not** wired as
candidate sources in `DeCasien_vs_merge_comparison.csv`. They contain DeCasien's own MOESM3
numbers, so matching DeCasien against them would be circular (trivial 0% self-matches). Their
purpose is to make the recovered values available **to the merge** for other analyses.

## 8. Class-C conversions wired into `DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R`

Three of the six class-C rows now match at 0.0%; the other three are surfaced as value-differences
(see item 9 / `annotation_findings.md`):

- **Bush & Allman 2004b V1 & LGN.** The matcher already read this table's neocortex; added its
  `V1_grey_cm3` and `LGN_cm3` columns (×1000) as `Bush_Allman_2004_specimen` candidates. → DeCasien
  *Tarsius syrichta* V1(GM) 280 and LGN 20 now match exactly (previously the merge only offered the
  Stephan "Tarsius sp." 349 / 20.8 rows).
- **Bauernfeind insula — DeCasien's actual convention.** DeCasien did **not** sum left+right for the
  Bauernfeind insula subregions; it **doubled a single hemisphere**. Confirmed on *Pongo pygmaeus*
  "Briggs": DeCasien granular 398 / dysgranular 2114 / agranular 376 / insula-GM 3010 all equal
  left×2, not L+R (=1694 for dysgranular). Added a parallel `Bauernfeind_1side_x2_est` candidate
  (double whichever single side exists) alongside the existing L+R `Bauernfeind_T1T2_specimen`. →
  *Pongo* dysgranular insula 2114 now matches at 0.0%.

## 9. New comparison tier + provenance/flag column

- **`description_match_value_mismatch`** (Tier 4). For cells still `decasien_only` where the **same
  structure exists for the same genus** in the merge but no candidate fell within the 2% tolerance,
  the script now records the nearest same-structure source in new columns `mismatch_source /
  mismatch_value / mismatch_pct` and sets this status — the "a comparison **was** possible, the
  value differs" case, flagged for review rather than left blank. 62 cells land here, including the
  class-B rows (*Avahi* BV +2.7%, *Tarsius* MOB +321%, *Saimiri* amygdala +14%) and *Loris* BV
  (+2.4% vs Bauernfeind). Filterable by `mismatch_pct` (29 are ≤5%, mostly gorilla individual-vs-
  species-mean differences; 3 are >20%, likely wrong-cell in DeCasien).
- **`flag` column** — one human-readable label per row (`match`, `match_taxonomy_variant`,
  `species_mean_match`, `value_match_other_structure`, `description_match_value_differs`,
  `matched_unpublished_via_DeCasien`, `decasien_only_no_comparable_source`) so the CSV
  self-documents how each cell resolved.

## 10. Latent `addspec()` bug found and fixed

While wiring the Bush & Allman LGN column (which has NA values for Macaca / Aotus / Saimiri), the
matcher left *Tarsius* LGN 20 unmatched despite an exact 20.0 candidate. Root cause: `addspec()`
built its candidate tibble as `tibble(sp = norm(sp[ok]), genus = genus(sp[ok]), …)`. Inside
`tibble()`, data-masking makes the `sp` in `genus(sp[ok])` resolve to the **just-created `sp`
column** (already length `sum(ok)`), which is then re-indexed by the full-length `ok` — silently
**misaligning `sp`/`genus` and injecting phantom NA rows** whenever a candidate column had NA
values. Invisible until now because every earlier candidate source happened to have complete
columns. Fixed by computing the filtered species vector into a local before the tibble.

Effect of the fix (vs the immediately prior run): `decasien_only` 6→**3**, `match` +12, **0 real
regressions**. It also **unmasked one spurious prior match** — *Gorilla g. graueri* amygdala had
matched a phantom 1246.0; the real Barger 2014 gorilla amygdala values (×2000) are 1290 / 1302 /
1734, none equal to 1246, so that cell correctly moved to `description_match_value_mismatch`
(DeCasien 1246.9 vs nearest 1290, 3.3%). All plan-1 deSousa provenance matches remain intact.

## Result (this phase)

Across 2190 DeCasien cells: `match` 1777, `match_taxonomy_variant` 216, `value_match_other_structure`
102, `description_match_value_mismatch` 62, `species_mean_match` 30, `decasien_only` **3**. Of the 66
user-annotated rows, **65 resolved off `decasien_only`**; the single remainder is *Nomascus concolor*
BV, a class-D misattribution documented in `annotation_findings.md`.

## 11. Class-B and class-D findings (`annotation_findings.md`, new)

Documents the class-B value-disagreements (*Avahi* BV, *Tarsius* MOB, *Loris* BV, *Saimiri*
amygdala) and the class-D taxonomy problem. Key class-D result answering the user's "Did they call
it Gibbon?": **yes** — DeCasien's *Nomascus concolor* BV 115800 equals *Hylobates lar* BV 115800
(de Sousa 2010) and its amygdala 637 equals *Hylobates lar* amygdaloid-complex-total 0.637 cc
(Barger 2007) exactly. Barger 2007 contains no *Nomascus*; DeCasien filed gibbon (*Hylobates lar*)
values under *Nomascus concolor*. A **species misattribution in DeCasien**, not a missing source.
The doc also records the re-sourcing outcome for the two review-flagged rows (*Propithecus* LGN and
*Loris* BV are both in-pool class-C cases, not re-sourcing failures — correcting an earlier
undercount that named only *Propithecus*).

## Run order (this phase)

1. `Barks_etal_2014/Barks_etal_2014_unpublishedviaDeCasien.R`  → writes Barks Public TSV
2. `Sherwood_etal_2004/Sherwood_etal_2004_unpublishedviaDeCasien.R`  → writes Sherwood Public TSV
3. `DeCasien_Higham_2019/DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R`  → comparison outputs

---

# 2026-08-19 — item renamed: `unpublishedviaDeCasien` → `viaDeCasien2019`

The two items carrying the regional volumes that DeCasien & Higham (2019) attribute to Sherwood
et al. 2004 (ref 64) and Barks et al. 2014 (ref 65) were named `<Paper>_unpublishedviaDeCasien`.
That label was misleading: **the values are published** — they appear in DeCasien & Higham's
Supplementary Data 1, which is where this project read them. What DeCasien says is that the *authors*
provided them as unpublished data, i.e. they are absent from Sherwood's and Barks's own tables. The
data is published; only its route is unusual.

Renamed to `viaDeCasien2019`, which records the route without the false claim:

| before | after |
|---|---|
| `Sherwood_etal_2004_unpublishedviaDeCasien` | `Sherwood_etal_2004_viaDeCasien2019` |
| `Barks_etal_2014_unpublishedviaDeCasien` | `Barks_etal_2014_viaDeCasien2019` |
| `10.1002%2Fajp.20048_unpublishedviaDeCasien.tsv` | `10.1002%2Fajp.20048_viaDeCasien2019.tsv` |
| `10.1002%2Fajpa.22646_unpublishedviaDeCasien.tsv` | `10.1002%2Fajpa.22646_viaDeCasien2019.tsv` |

Each item stays keyed to the **measuring** paper's DOI, per the convention that credits whoever made
the measurement; the item number carries the route. `Data role` was blank on both rows and is now
`primary`, with the provenance recorded in the registry `Note`.

Renamed: the `.R`, `_snapshot.xlsx` and `.csv` in `Sherwood_etal_2004/` and `Barks_etal_2014/`; both
`standardized_term_by_reference/*_standardized_terms.csv` (filename *and* `Reference` column); both
public TSVs; `__ReadMe.xlsx` col D plus the cached `Item name` / `Item encoded`. The flag classifier in
`DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R` now matches `viaDeCasien`, so it still
recognises the pre-rename label in older outputs.

**Needs a re-run to catch up** (all generated, none hand-maintained): `__merging_volumes/standardized_term.R`
→ `standardized_term_volumes.csv`, `_audit_missing_structures.R`, the DeCasien comparison itself,
`_tools/__file_list.R` → the registry's `AUTO_Public_TSV_FileList`, and `update_shinyapp.R` →
`__ShinyApp/data/source_manifest.csv`. Neither item is in a `volumes_compiled` item list, and neither
appears in `volumes_long.csv`, so no merged value changes.
