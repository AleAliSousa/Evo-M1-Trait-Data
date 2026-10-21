# Myhrvold et al. 2015 — Amniote Life-History Database (Aug 2015 release)

## What this item is
Myhrvold, Baldridge, Chan, Sivam, Freeman, & Ernest (2015, *Ecology* 96:3109,
doi:10.1890/15-0846R.1) compiled a cross-taxon **life-history trait database** spanning
21,322 bird, mammal, and reptile species/subspecies across 29 numeric traits (body mass,
maturity age, litter/clutch size, gestation, longevity, egg/svl measurements, etc.) —
itself a *compilation* of ~900+ underlying literature sources, not new measurements by
these authors. No brain-related trait is in this database; it is built here as
body-size/life-history covariate data (e.g. for brain-body allometry).

## The two files combined
- **`Amniote_Database_Aug_2015.csv`** (Data_Files/) — one row per species/subspecies,
  one column per trait, value or `-999` (the source's own missing-value sentinel).
- **`Amniote_Database_References_Aug_2015.csv`** (Data_Files/) — row-for-row,
  column-for-column aligned with the above (verified identical taxon identity per row
  before merging); each cell is the free-text citation the paired value was taken or
  derived from (a single reference, a mean across named references, or
  `"X from median of N(ref1, ref2, ...)"`).

Both are frozen byte-identical as `Myhrvold_etal_2015_AmnioteDatabaseAug2015_snapshot.csv`
and `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv`.

## Build
`Myhrvold_etal_2015_AmnioteDatabaseAug2015.py` melts both wide tables to long (one row
per species x trait), attaches the matching reference string, drops rows whose value is
the `-999` sentinel (113,105 of 618,338 species x trait combinations have a value), and
adds `unit` from `Supplemental_Table_9_Dataset_Field_Information.csv`
(the paper's own field-definition table — not re-derived from training knowledge).
`data_role = secondary` throughout, since the value's own reference column names the
actual contributing source.

Note on filename: the registry row for this item was already present in `__ReadMe.xlsx`
with `Item name = "Myhrvold_etal_2015_AmnioteDatabaseAug2015.csv"` (the registered name
itself carries the `.csv` extension) — the build script and analysis CSV are named to
match that exactly, rather than following the usual `<item_name>.csv` pattern.

## Species identity
`genus`/`species`/`subspecies` are the paper's own printed binomial/trinomial names —
already a scientific identity, not a common name needing curator interpretation — so no
`interpreted_taxon` column or `_keys/*/species_key.csv` entry was added for this item
(unlike common-name-only sources). Species-identity resolution against this repo's
`accepted_name` authority still happens at merge time, per `_keys/SPECIES_NAMING.md`.

## Deferred — not built this pass
Three further registry rows already exist for this paper and remain unfulfilled as
standalone items, plus several un-registered supplemental tables
(`Supplemental_Table_2_Reference_Counts.csv`, `..._3/4/5_*_Name_Transformations.csv`,
`..._6/7/8_*_Synonyms.csv`). None were requested for this build (the ask was the main
database plus the references needed to make sense of it) and none are built here:

- **`Amniote_Database_References_Aug_2015.csv`** — has its own registry row
  (Item name `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv`, "Public TSV
  match": notfound) distinct from this item's. Its content is fully *consumed* here (every
  value's reference string is in the `reference` column above), but no standalone CSV/TSV
  matching that row's own Item name/encoded was produced — that row's own TSV is still
  outstanding if a reference-indexed artifact of its own is wanted later.
- `Amniote_Range_Count_Aug_2015.csv` — min/max/count of the *underlying individual
  records* behind each pooled trait value (data-provenance metadata, not new trait
  values).
- `Amniote_Sparse_Table_Aug_2015.csv` — an alternate long-format export of the same
  Database values with a `dataset` origin-flag column; redundant with the long table
  built here once reshaped (not independently re-verified).
- The Reference-Counts / Name-Transformation / Synonym supplemental tables are
  bookkeeping for the compilers' own synonym-matching pipeline, not trait data.

## Reference tables (added 2026-10-20) — per-cell citations parsed, Table 2 reconciled, PanTHERIA crosswalks

Three Rscript-runnable scripts build `reference_tables/`; run them in this order from any cwd
(`Rscript <script>.R`; each self-locates, forces a UTF-8 locale, and `stop()`s on any input
problem rather than messaging). Every CSV has a sibling `*_definitions.csv` (house template
columns). Nothing in `Data_Files/`, `Supplemental_Materials/` or the snapshots is modified.

| script | writes |
|---|---|
| `Myhrvold_etal_2015_cell_references.R` | `Myhrvold_etal_2015_cell_references.csv` (322,572 rows), `…_cell_references_unparsed.csv` (0 rows), `…_mammal_independence_by_trait.csv` |
| `Myhrvold_etal_2015_references.R` | `Myhrvold_etal_2015_references.csv` (1,003 rows), `…_references_table2_mismatches.csv` (349), `…_references_citation_candidates.csv` |
| `Myhrvold_etal_2015_pantheria_crosswalk.R` | `Myhrvold_etal_2015_PanTHERIA_variable_crosswalk.csv` (30), `…_PanTHERIA_species_crosswalk.csv` (4,953), `…_PanTHERIA_species_unresolved.csv` (3) |

### 1. The citation-string grammar (`cell_references`)
Each cell of `Amniote_Database_References_Aug_2015.csv` is one of four constructs. Reference
keys themselves contain commas, `" and "` and parentheses (`Burghardt and Rand (Eds.), 1982`),
so the pool cannot be split on `", "`; the parser is a lexicon-driven, longest-first,
backtracking tokenizer constrained by the pool count `N`. A string is a parse failure unless a
derivation consumes it entirely.

```
cell             ::= "-999" | "" | expr
expr             ::= single | mean2 | median_sel | mean_median_sel
single           ::= key
mean2            ::= "mean of " key " and " key
median_sel       ::= key " from median of " N "(" pool ")"
mean_median_sel  ::= "mean of " key " & " key " from median of " N "(" pool ")"
pool             ::= key { ", " key }                 -- exactly N keys
N                ::= [0-9]+
key              ::= [ bc_prefix ] ( lexkey | empty )
bc_prefix        ::= "BC " ( "Birds" | "mammals" | "Reptiles" ) " - "
lexkey           ::= a lexicon string: Supplemental Table 2 "Reference Name" values (1,002) ∪
                     strings occurring as an entire single-key cell (425) = 1,005 keys
empty            ::= ""                               -- the compilers' blank record → "(blank)"
```
`derivation_role`: `direct` (single), `mean_of_member` (the two keys of `mean2`),
`selected_from_median_pool` (the key(s) before `from median of` — the record(s) whose value
was taken, or averaged in `mean_median_sel`), `median_of_member` (each of the N pool entries,
`member_position` 1..N, duplicates kept in the compilers' order). `cell_form` records the
construct (`single | mean | median_select | mean_median_select | blank`). The `BC <class> - `
prefix is kept in `ref_key` and removed in `ref_key_norm` (the Table 2 form).

Run result (all three classes, all 29 traits, all 21,322 rows): 618,338 cells, 113,105 with a
value, 113,101 with a citation string; 13,355 unique strings; **0 unparsed**. Four value cells
have an *empty* citation cell (not `-999`) — Table 2 itself declares a `(blank)` reference —
carried as `ref_key = "(blank)"`, `cell_form = blank`; 29 further empty key tokens occur inside
constructs (`(, …`, `, ,`, `mean of  and`, `BC Reptiles - ,`) in 19 cells (all Reptilia) and
are emitted as `(blank)` members. Assertions: every value cell has ≥1 reference row (113,105 =
113,105); no reference row for a `-999` cell; every median pool has exactly N member rows.
Rows: Aves 153,459 · Mammalia 105,396 · Reptilia 63,717. Roles: direct 50,604 (+4 blank),
mean members 53,368, selected 25,657 + 20,312, pool members 116,359 + 56,268.
Mammalia: 33,662 value cells, 105,396 rows, 418 distinct keys. Threshold `## CONVENTION-OK`:
the run aborts if >0.5 % of cells fail the grammar (0 did).

### 2. Reference keys and the Table 2 reconciliation (`references`)
One row per `ref_key_norm` (1,003; printed variants 1,030 incl. BC-prefixed forms). All 1,003
keys are found in Supplemental Table 2 — 1,000 exactly and 3 via declared spelling aliases
(`de Magalhaes and Costa, 2009` ↔ Table 2's mojibaked `de MagalhÜes…`; `Fradlova P., Frynta,
D., 2010` ↔ `Fr_dlovà, P., …`; `Greer_Greer, A.E., 1997` ↔ `Greer, A.E., 1997`; the Sparse
Table spells the last `Greer, A.E, 1997`). Table 2 is latin1-encoded.

**Counting rule.** Five rules were tested against Table 2's "Number of records from each
reference" (exact matches of 1,003): every cell_references row 342; cell-level records
(direct + mean members + pool members, selected not re-counted) 546; distinct cells 255;
distinct taxa 176; **rows of `Data_Files/Amniote_Sparse_Table_Aug_2015.csv` whose `dataset`
is the key (BC prefix stripped) 654 (65.2 %)**. The Sparse-Table rule is therefore reported as
`table2_match_rule`; the 349 non-reproducing keys are in the mismatch sidecar. It does *not*
reproduce the large references — Dunning 1992: declared 18,812 vs 23,175 sparse rows;
PanTHERIA: 4,686 vs 6,746; `(blank)`: 26 vs 27 — sums 99,311 declared vs 139,827 sparse rows.
Table 2 evidently counts at a record level the released files do not expose (ratios 1.2–1.4
for the large sources); agreement was not forced.

**Full citations** come from `Supplemental_Table_1_Database_Literature_Cited.pdf` via
`pdftools` (949 entries; unindented line = new entry; Chicago 3-em-dash "same author" carried
forward for 34 entries; one trailing in-text citation block dropped). Matching: first-author
surname (ASCII-folded) + year, further surnames to disambiguate. **924 / 1,003 keys (92.1 %)
matched a unique entry**; 9 ambiguous (candidates in the sidecar); 62 have no entry — notably
`Bennett, 1986` (3,053 declared records; 24,156 bird cells) and `Kratochvil and Frynta, 2006b`
(234) are absent from the bibliography; 8 keys have no year (`Reptile Incubation book`, 3,210
records; `IUCN`-style and "Personal Communication" keys).

### 3. Circularity flag — which Mammalia cells are independent of PanTHERIA
`cell_references.pantheria_derived` = key is `Jones, K., Bielby, J., Cardillo, M. et al.,
2009` (the only spelling found; every lexicon key containing "Jones" is printed and the script
stops on an undeclared variant). `jones2003_derived` = `Jones et al., 2003` / `Jones, et al.
2003`. **Identity finding:** Supplemental Table 1's only Jones-2003 entry is *Jones, Menna,
Chris R. Dickman, and Michael Mike Archer. 2003. Predators with Pouches: The Biology of
Carnivorous Marsupials. CSIRO Publishing*, and of the 628 cells citing the key 623 are
marsupials (Dasyuromorphia 367, Didelphimorphia 240, Paucituberculata 12, Microbiotheria 2,
Notoryctemorphia 2) and 5 are Carnivora — no bats. It is **not**
K. E. Jones et al. 2003 (bat life history) and is not a PanTHERIA derivative, so the
independence table treats PanTHERIA alone as circular and carries the Jones-2003-inclusive
counts in `*_incl_jones2003` columns for comparison.

`Myhrvold_etal_2015_mammal_independence_by_trait.csv` (24 traits — the five egg/fledging
traits have no Mammalia values). Totals: 33,662 cells; **5,902 fully circular** (every
contributing reference is PanTHERIA), **17,730 partly circular**, **10,030 fully independent**
(29.8 %). With Jones 2003 also counted: 6,203 / 17,646 / 9,813.

| trait | cells | fully circular | partly | fully independent | % indep. |
|---|---:|---:|---:|---:|---:|
| female_maturity_d | 2000 | 215 | 1506 | 279 | 13.9 |
| litter_or_clutch_size_n | 3511 | 787 | 2539 | 185 | 5.3 |
| litters_or_clutches_per_y | 2146 | 588 | 1337 | 221 | 10.3 |
| adult_body_mass_g | 4651 | 1858 | 2724 | 69 | 1.5 |
| maximum_longevity_y | 2614 | 187 | 0 | 2427 | 92.8 |
| gestation_d | 2220 | 230 | 1766 | 224 | 10.1 |
| weaning_d | 2043 | 292 | 1481 | 270 | 13.2 |
| birth_or_hatching_weight_g | 1883 | 233 | 1483 | 167 | 8.9 |
| weaning_weight_g | 1064 | 204 | 698 | 162 | 15.2 |
| incubation_d | 2 | 0 | 0 | 2 | 100 |
| longevity_y | 2614 | 54 | 1466 | 1094 | 41.9 |
| male_maturity_d | 967 | 0 | 0 | 967 | 100 |
| inter_litter_or_interbirth_interval_y | 1248 | 338 | 730 | 180 | 14.4 |
| female_body_mass_g | 438 | 0 | 0 | 438 | 100 |
| male_body_mass_g | 620 | 0 | 0 | 620 | 100 |
| no_sex_body_mass_g | 990 | 0 | 0 | 990 | 100 |
| adult_svl_cm | 3921 | 509 | 1998 | 1414 | 36.1 |
| male_svl_cm | 54 | 0 | 0 | 54 | 100 |
| female_svl_cm | 27 | 0 | 0 | 27 | 100 |
| birth_or_hatching_svl_cm | 412 | 407 | 2 | 3 | 0.7 |
| female_svl_at_maturity_cm | 2 | 0 | 0 | 2 | 100 |
| female_body_mass_at_maturity_g | 4 | 0 | 0 | 4 | 100 |
| no_sex_svl_cm | 130 | 0 | 0 | 130 | 100 |
| no_sex_maturity_d | 101 | 0 | 0 | 101 | 100 |

"Partly circular" dominates the core life-history traits because most Mammalia cells are
`median_select` constructs whose pool mixes PanTHERIA records with Ernest 2003, de Magalhães &
Costa 2009, etc.; only `n_fully_independent` cells can corroborate PanTHERIA without
circularity, and `n_partly_circular` cells can do so only after removing the PanTHERIA pool
members (the per-member rows make that possible).

### 4. PanTHERIA crosswalks
**Variables** (`…_PanTHERIA_variable_crosswalk.csv`, 30 rows = 29 Amniote traits + one
alternate counterpart `female_maturity_d ↔ 3-1_AgeatFirstBirth_d`). `amniote_definition` /
`amniote_unit` are verbatim from Supplemental Table 9; `pantheria_definition` / `pantheria_unit`
are parsed from `Jones_etal_2009/metadata.htm` (the `(n) <variable>: …` table cells and the
following unit cell; joined on the numeric code because metadata prints `5-3_NeonatalBodyMass_g`
and `14-1_InterBirthInterval_d` where the data columns are `5-3_NeonateBodyMass_g` and
`14-1_InterbirthInterval_d`). `unit_scale` multiplies an Amniote value into PanTHERIA units —
convention 1 y = 365.25 d = 12 mo, 1 cm = 10 mm — and is asserted against the two unit strings.
`definition_match`: same 7 (litter size, litters/yr, adult body mass, max longevity ×12,
weaning weight, interbirth interval ×365.25, adult SVL ×10), narrower 13 (sex-specific mass /
SVL / maturity subsets; first conception vs PanTHERIA's pooled maturity definitions; conception-
to-birth vs PanTHERIA's pooled gestation start/end points; birth weight/SVL vs neonate ≤7 d;
weaning age vs pooled weaning definitions), different_statistic 2 (`longevity_y` "Age at death"
vs maximum; age at first birth), no_counterpart 8 (egg traits, fledging, SVL/mass at maturity).

**Species** (`…_PanTHERIA_species_crosswalk.csv`, one row per Mammalia Database row, 4,953;
no subspecies rows exist). Tiers in order: `exact_binomial` **4,947**;
`supp_table_4_transformation` **3** (Hydrochoeris hydrochaeris → Hydrochoerus hydrochaeris,
Hydrochoeris isthmius → Hydrochoerus isthmius, Erethizon dorsata → Erethizon dorsatum; reverse
lookup of Table 4's Original → Transformed names, 31,450 species-level + 32 genus-level);
`supp_table_7_synonym` 0 (direction verified: Table 7 `genus/species` = the name in the
cited source — 100 % of the PanTHERIA-cited rows are PanTHERIA binomials — and
`synonymous_*` = the Amniote name); `species_key` 0 (`_keys/resolve_species.R`, both names
resolving to one `accepted_name`); **`unresolved` 3** — Drymoreomys albimaculatus, Cryptotis
lacertosus, Cryptotis mam, all described after MSW05 and absent from PanTHERIA. No row has more
than one PanTHERIA candidate; 4,950 of 5,416 PanTHERIA binomials are reached.

## Source
`Amniote_Database_Aug_2015.csv` and `Amniote_Database_References_Aug_2015.csv`
(Data_Files/), Myhrvold et al. (2015), Ecological Archives E096-269-D1.
