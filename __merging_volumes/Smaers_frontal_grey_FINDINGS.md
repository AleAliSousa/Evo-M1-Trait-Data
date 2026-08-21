# Total frontal lobe grey matter from Smaers — which table, and why

Question (2026-08-12): get **total frontal lobe grey matter** from Smaers' own primary data (not his
Brodmann-derived secondary data) into `volumes_compiled_select.R`, maximising species coverage and
compatibility. Three candidate publication folders: Smaers 2010, Smaers 2011, Smaers 2017.

Scope as finally set: **grey matter only, whole lobe only** — no frontal white, no frontal subregions.

---

## 1. The headline correction: prefrontal + frontal_motor is NOT total frontal

The working assumption was that Smaers 2017's `prefrontal_gray` + `frontal_motor_gray` add up to total
frontal grey. **They do not.** Their sum is 53–68% *short* of the published total, in every one of the
19 species — it is roughly a third of the lobe, not all of it.

| species | Smaers 2011 total frontal grey | prefrontal_gray | frontal_motor_gray | sum | shortfall |
|---|---|---|---|---|---|
| *Homo sapiens* | 204.17 | 46.32 | 29.01 | 75.34 | −63.1% |
| *Pan troglodytes* | 68.22 | 14.21 | 13.41 | 27.62 | −59.5% |
| *Pan paniscus* | 50.66 | 7.96 | 8.36 | 16.31 | −67.8% |
| *Gorilla* | 71.11 | 11.64 | 14.85 | 26.50 | −62.7% |
| *Pongo* | 42.96 | 8.60 | 6.35 | 14.95 | −65.2% |
| *Papio anubis* | 24.28 | 3.92 | 4.69 | 8.61 | −64.6% |
| *Cercopithecus ascanius* | 7.94 | 1.15 | 1.35 | 2.50 | −68.4% |

(cm³. Full 19-species table reproducible from the three source CSVs.)

Why: both columns are **cumulative section blocks**, not a two-way partition of the lobe.
`prefrontal_gray` is an exact republication of **Smaers 2011 Supplementary Table 2** `sec5_grey_total`
— the *anterior* frontal block cumulated to section 5 — verified here at 19/19 species, max |diff|
**0.85%**, most exactly 0.00%. `frontal_motor_gray` is the corresponding *posterior* block. Between
them lies the bulk of the lobe, which neither column reports.

So total frontal grey **cannot be reconstructed** from the 2017 subregions. It has to come from a table
that publishes it directly.

## 2. It is published directly, in two places

| source | column | units | species | Homo? |
|---|---|---|---|---|
| `Smaers_etal_2010_Table1` | `frontal_grey_matter_volume_mm3` | mm³ | 18 anthropoids | no |
| `Smaers_etal_2011_SupplementaryTable1` | `frontal_grey_total_cm3` (L+R) | cm³ | **19** | yes, n = 8 |

2011's species set is a **strict superset** of 2010's. 2010 contributes no species that 2011 lacks, so
**Smaers 2011 Supplementary Table 1 maximises coverage at 19 species** and 2010 is not needed for it.

Both are Smaers' own primary volumetry on the C. & O. Vogt / Stephan-Collection brains — Tier 1, not
compilation. (Smaers 2017 *is* a compilation; see `crosspub_Smaers2017_FINDINGS.md`.)

### Value drift 2010 → 2011

17 of 18 species agree within ±6% (median +0.3%); the same brains were re-used and lightly
re-measured. Every total brain volume agrees to **0.01%** — with one exception.

**Pongo is −33% (64.44 → 42.96 cm³), and the printed specimen identifier changes between tables.**

| source | printed catalogue | public specimen resolution | brain vol | MacLeod brain g | density |
|---|---|---|---|---|---|
| 2010 Table 1 | `297` | unresolved in the public layer | 424.7 cm³ | NA | NA |
| 2011 Suppl. T1 | `yn85 38` | **YN85-38** (same printed identifier in MacLeod 2000) | 356.2 cm³ | 369 | 1.036 g/cm³ |

The different printed identifiers are sufficient to show that the 2010 and 2011 rows are not a
simple re-measurement of one labeled specimen. YN85-38 is the repo's public pygmaeus→abelii case:
MacLeod 2000 Appendix I prints it as `PONGO PYGMAEUS / ABELII`, and it is resolved to
***Pongo abelii*** (Sumatran) in the public `specimen_crosswalk.csv`. The identity of catalogue `297`
and its private-catalog links are retained only in the restricted overlay.

**Consequence: the orangutan value now in the merge is a Sumatran animal**, carried under the lumped
label `Pongo sp.` It is n = 1, a *specimen* measurement — not a pooled *sensu lato* mean — so the
do-not-split rule does not apply and `resolved_taxon = Pongo abelii` does. Smaers 2017 carries the same
individual forward (its Pongo `prefrontal_gray` 8.596 = the 2011 `sec5_grey_total` 8.60), so the
`FrontalMotor_*` values already in `volumes_wide_select.csv` under `Pongo sp.` are this same brain.

The public YN85-38 chain is recorded in `_keys/specimen_crosswalk/specimen_crosswalk.csv`,
`_keys/specimen_crosswalk/pongo_provenance_audit.csv`, and
`____Collections and Specimen notes/Pongo_specimen_note.md`. The 2010 catalog match and full finding
are in `Evo-M1-Trait-Data-restricted/specimen_registry/cases/`.

## 3. Compatibility: it was already built, just not switched on

`Smaers_etal_2011_SupplementaryTable1` needed **one line**. Everything else already existed:

| piece | status before |
|---|---|
| DOI-coded TSV in `__Public/comparative-data/` | present |
| `__ReadMe.xlsx` registry row | present |
| `enc_override` entry in the script | present (line 209) |
| term-map rows in `standardized_term_volumes.csv` | present |
| cm³→mm³ + L+R species-mean reshape block | present (line 362) |
| species overrides in `_keys/` | present, all 6 |
| **row in the `select_datasets` tribble** | **missing** ← the only gap |

Compatibility is as clean as it gets:

- `FrontalCortex_grey_matter_Vol.mm3` is claimed by **no other source** in the term map, so nothing is
  superseded and no recency contest happens.
- All 19 species **already exist** in `volumes_wide_select.csv` — zero new species rows, a pure column
  fill of an otherwise-empty variable.
- The 2011 (year 2011) and 2017 (year 2017) Smaers items map to *different* standardized terms, so
  adding 2011 does not disturb the existing 2017 `FrontalMotor_*` values.

### What was changed

1. `volumes_compiled_select.R` — added the tribble row (year 2011) with a provenance comment;
   restricted its reshape to grey only (the `frontal_white_total_cm3` line is retained, commented, one
   edit away). The term-map row for white is untouched, so `volumes_compiled.R` still carries it.
2. `volumes_select_value_flags.csv` — corrected the prefrontal skip notes, which pointed at
   Supplementary **Table 1**; prefrontal is in Supplementary **Table 2** (`sec5_*`, not term-mapped).
   Added the subregion-arithmetic finding to the `FrontalMotor_grey` note.
3. Specimen/provenance records for the Pongo swap (above).
4. Outputs regenerated: `volumes_long/wide/unfiltered/resolution_audit_select`,
   `volumes_source_contributions/citations/species_ids_select`, `volumes_species_sources_select`.

### Verification

Pre-run backup in `_prerun_backup_smaers2011_2026-08-12/`. Checks run against it:

- wide: exactly one new column, pre-existing column **order** preserved, **no pre-existing cell
  changed**, 19 values present, 108 species unchanged.
- long / unfiltered / audit / contributions: exactly +19 rows each, no backup row lost or altered, all
  new rows carry only `FrontalCortex_grey_matter_Vol.mm3`.
- Smaers 2017 rows identical apart from the intended `Pick` renumber 31 → 32 (2011 inserted ahead of it).
- values round-trip against the published table (Homo 204165, Pan troglodytes 68220, Gorilla 71110,
  Pongo 42960, Pithecia 3680 mm³).
- no `PrefrontalCortex_*` and no `FrontalCortex_white_*` column entered; `FrontalMotor_*` byte-identical.
- plausibility: total frontal grey > frontal motor grey in all 18 species that have both; total frontal
  grey < neocortex grey in all 10 species that have both.

> **The `.R` is canonical.** These outputs were regenerated by an offline Python mirror (no R in the
> working sandbox) honouring each file's `arrange()`, R's `write_csv` quoting and `%.15g` float format.
> Re-run `volumes_compiled_select.R` to confirm; the mirror was validated by reproducing the backup's
> `pivot_wider` column order exactly (85/85) before writing.

## 4. Left on the table

- **Smaers 2010 Table 1** is not wired: registry row and TSV exist, but it has **no rows in
  `standardized_term_volumes.csv` and no species overrides**. It adds no frontal-grey species, but it
  does hold Smaers' own `neopallium` grey/white and `basal_ganglia` — checked here and *distinct* from
  the merge's `Neocortex_*` (Frahm 1982) and `Striatum_*` (Stephan 1981) by 5–30%, so genuinely new
  content rather than a republication. Its internal derived columns (`frontal_lobe`, `nonfrontal_*`)
  are exact arithmetic of the grey/white pair and should not be ingested separately.
- **Smaers 2011 Supplementary Table 2** (prefrontal, `sec5_*`) is not term-mapped. Wiring it would let
  prefrontal enter at its true 2011 date instead of being skipped as a 2017 republication.
- If Smaers 2010 is ever wired on the same team as 2011, recency silently picks 2011 and specimen
  `297` disappears without the specimen change surfacing. Flag it before that happens.

---

Sources: `Smaers_etal_2010/Smaers_etal_2010_Table1.csv`;
`Smaers_etal_2011/Smaers_etal_2011_SupplementaryTable{1,2}.csv`;
`Smaers_etal_2017/Smaers_etal_2017_TableS1part1.csv`;
`__merging_volumes/crosspub_Smaers2017_FINDINGS.md`; MacLeod (2000) Appendix I.
