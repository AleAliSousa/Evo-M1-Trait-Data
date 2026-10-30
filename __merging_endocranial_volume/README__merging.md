# Merging endocranial volume (cranial capacity)

Species-level **endocranial volume** in millilitres — a sibling of `__merging_brain_mass/`
and structured like `__merging_cerebral_metabolic_rate/`.

## Why this is not part of the brain-mass merge

**Cranial capacity is not brain weight.** Endocranial volume is the capacity of the
braincase, so it contains the brain *plus* the meninges, cerebrospinal fluid and the
vessels, and therefore exceeds brain volume. Nothing here is converted to a mass, and the
app never pools an endocranial volume with a brain mass — the two labels carry different
`poolable_group` values in `_keys/variable_domain.csv`, and the Plot tab warns if you put
one on each axis.

This split is the same decision recorded in `__merging_fossil_brain_glucose/README__merging.md`,
which keeps endocranial capacity and brain-tissue quantities apart for the fossil specimens.

## Sources

| Folder | Table | Role | Rows | Species | Column |
|---|---|---|---|---|---|
| `Isler_etal_2008` | TableS2 | primary | 274 | 223 | `ECV species mean` |
| `Powell_etal_2017` | Dataset1 | secondary | 249 | 249 | `ECV` |
| `Seymour_etal_2015` | TableS1 | secondary | 60 | 60 | `Brain_volume_ml` |
| `Caspar_etal_2022` | Supplementary file 3 | primary | 38 | 38 | `female_endocranial_volume_ml` |
| `Heldstab_etal_2016` | TableS1 | secondary | 37 | 37 | `ECV_ml` (female) |

Isler et al. (2008) is the reference primate ECV compilation and measured 264 of its own
species (`Source of ECV` = "This study"), so it is treated as primary.

### Deliberately not used

- `10.6084/m9.figshare.c.3899422.v1_Dataset1.tsv` is the **figshare export of the same
  Powell et al. 2017 dataset** — identical 289 rows and identical columns. Including both
  would double-count every species.
- `Seymour_etal_2017` (rsos.170846) is **specimen-level fossil hominin** material. Per-specimen
  fossil endocranial data belongs to `__merging_fossil_brain_glucose/`, which is keyed by
  specimen rather than by species.
### Heldstab et al. 2016, and why it adds two species rather than 37

The public TSV export was simply missing: the paper's own reformat script
(`Heldstab_etal_2016/Heldstab_etal_2016_TableS1.R`) writes it and had not been run. Running it
produced `10.1038%2Fsrep24528_TableS1.tsv`, and the source is now harvested.

It is almost entirely a **reprint**. Its definitions file attributes its ECV to "Lonsdorf & Ross
and van Woerden et al."; Powell et al. 2017 labels 219 of its own rows "van Woerden compilation".
36 of Heldstab's 37 species are already in Powell — 33 of them from that same van Woerden
compilation, agreeing to within 2% for 28 of them — so harvesting both would double-count van
Woerden. The merge therefore carries a declared `reprint_of` rule: a Heldstab row is dropped for
any species Isler or Powell already has. What survives is *Homo sapiens* and *Pongo* sp. female
ECV, which no other source in this merge supplies.

One disagreement is worth knowing about: *Cercopithecus hamlyni* is 51.2 mL in Heldstab against
61.9 mL in Powell, both nominally from van Woerden.

## Pipeline

1. **Harvest** each source's ECV column, resolve the species name through
   `_keys/species_reference.csv` + every `*species_key.csv` (blank `accepted_name` entries,
   written as the literal `"NA"`, are skipped so the printed name survives), and drop
   genus-level rows (`… sp.`).
2. **Drop reprints.** Powell's own `Source ECV` column names *Isler et al. 2008* for 29 of
   its rows, and several Caspar rows cite Isler in `endocranial_volume_ref`. Those are the
   same datum reprinted, not independent measurements, and are dropped —
   63 rows in `endocranial_volume_dedupe_report.csv`. This is the same
   compilation-overlap problem the cerebral-metabolic-rate merge solves by resolving
   compilations down to primary-study level.
3. **Split by sex scope, do not pool.** Caspar reports female-only means and Powell labels
   each row `fem` or `all individuals`. A female mean and a both-sexes species mean are
   different quantities in a dimorphic clade, so two variables are emitted:
   `Endocranial_volume` (both sexes or unspecified) and `Endocranial_volume_female`.
4. **Pool** within variable: collapse to one value per team, prefer `primary` teams when any
   are present, then average. Same rule as `__merging_brain_mass/`.

## Outputs

| File | What it is |
|---|---|
| `endocranial_volume_long.csv` | the merged table the app reads — 281 species both-sexes, 106 female-only |
| `endocranial_volume_wide.csv` | species × variable |
| `endocranial_volume_unfiltered.csv` | every harvested row with its team, role, `source_of_value` and sex scope |
| `endocranial_volume_dedupe_report.csv` | the 100 rows dropped as reprints — 64 whose own source column names another team here, 36 by the Heldstab `reprint_of` rule |
| `endocranial_volume_team_comparison.csv` | the 108 species measured by more than one team, with the max/min ratio; 3 disagree by >1.5× |

## Caveats

- **Genus-level buckets are kept.** `Macaca sp.` and `Pongo sp.` are accepted names in
  `_keys/species_reference.csv` and are ordinary rows in the sibling merges, so this merge does
  not filter them. An earlier version did, which silently dropped Heldstab's validly-printed
  *Pongo abelii* — a species key maps it onto the `Pongo sp.` bucket.
- **`Isler` is both a team here and a team in `__merging_body_ecology`** (Isler et al. 2008
  also supplies BMR). Same paper, different measure — not a double count.
- Powell's ECV values are means over the individuals that paper used, and its `N ECV` column
  is carried in the unfiltered table but not used to weight the pooled value.
- Three species disagree by more than 1.5× across teams; see the team-comparison report before
  using them.

## Run

```bash
python3 __merging_endocranial_volume/build_endocranial_volume_merge.py
```
