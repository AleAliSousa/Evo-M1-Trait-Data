# Plan — hierarchical curation workflow for the `__merging_*` compiled scripts

Status: **proposed, not implemented.** Written 2026-08-19.
Target: `volumes_compiled.R` edited **in place**, with the reusable parts extracted to a sourced
helper so the other 12 domains can adopt them later.

Protocol adopted: *remove duplicated information → reconcile overlapping measurements → average
genuinely independent estimates*, after DeCasien & Higham (2019). The 8-step protocol below is the
one supplied; this document maps it onto what the repo already does, what it does not, and in what
order to close the gap.

---

## 0. Decisions taken before drafting

| Decision | Choice |
|---|---|
| Where the workflow lands | `volumes_compiled.R` **in place** (not a 4th variant). `_prerun_backup_curation_2026-08-19/` snapshot first; canonical outputs and the Shiny app move together. |
| Weighting policy | Weighted mean **only where every contributor to that cell has a known N**; unweighted otherwise, with the rule that fired recorded per cell. No `N = 1` fictions. |
| Scope of pass 1 | Volumes only, but every reusable piece written into `_tools/curation.R` so the other 12 scripts plug in without redesign. |

---

## 1. How much of the dataset this actually touches

Measured on the current `volumes_long.csv` (8,091 cells = species × variable):

| | cells | share |
|---|---|---|
| single team, single source (nothing is combined) | 7,724 | 95.5% |
| single team, >1 source averaged inside the team | ~103 | 1.3% |
| **>1 team averaged together** | **264** | **3.3%** |

So the curation ladder changes *numbers* on roughly 4% of the dataset. On the other 96% it changes
only *provenance* — which is still the point, but it means the regression review after
implementation is a 300-row job, not an 8,000-row job. Plan the effort accordingly.

Team pairs that actually meet (multi-team cells): `Stephan_collection; Zilles` 87 ·
`Bush; Stephan_collection` 58 · `Ashwell; Bush` 47 · `Ashwell; Stephan_collection` 23 ·
`Ashwell; Reep` 14 · `Bush; Reep` 12 · plus 23 cells across 5 three- and four-team combinations.

---

## 2. Step-by-step: what exists, what is missing

| Protocol step | Current state | Verdict |
|---|---|---|
| **1** Provenance table | `volumes_unfiltered.csv` (Species, Variable, Value, Source, Team, Year) → `volumes_source_contributions.csv` (adds `source_Value`, `merged_Value`, `pct_diff_from_merged`, `role`, `Cited_as`, `DOI_or_ISBN`) | **Done.** Add two columns: `N_specimens`, `Specimen_IDs`. |
| **2** Identify duplicate publications + `Relationship` column | One-off `crosspub_value_match.R` covers **Smaers 2017 only**; everything else is free-text `flag` on a (Source, Species, Variable) triple in `volumes_select_value_flags.csv` with the primary named only in prose | **Missing as a registry.** Build `_keys/source_relations.csv`. |
| **3** Prioritize | Tier-1 recency implemented (`volumes_compiled.R:442-454`); >50% deviation flagged (`:456-459`) | **Partial.** Recency is keyed on the literal string `"Stephan_collection"`, not on the fact that those papers share specimens. Generalize. |
| **4** Remove duplicate specimens | `_keys/specimen_crosswalk/` exists — 35 specimen records, 8 taxon concepts, 181 parsed collection specimens, a full `SCHEMA.md` — and **no merge script reads it** | **Missing.** Highest ratio of value to effort in this plan. |
| **5** Which value to keep | Recency only | **Partial.** Cannot distinguish "remeasured, so supersede" from "republished, so ignore" without step 2's relation type. |
| **6** Standardize anatomical definitions | Enforced only by *term-name collision avoidance* (definition-specific standardized terms, `_left`/`_right`/`_unilateral` suffixes). `_keys/variable_catalog_compatibility.csv` has a `poolable` column that is literally `n_papers >= 2` — it encodes "≥2 papers use this label", not "these are the same region" — and nothing reads it | **Narrated, not enforced.** See §4; this is the most consequential gap. |
| **7** Species-level values | Unweighted `mean(Value)` within team (`:467`) and across teams (`:487`) | **Partial.** Needs N. See §3. |
| **8** Record every exclusion | Three partial logs: `volumes_flagged_not_used_select.csv` (good schema, currently **0 rows**, no canonical equivalent at all), `volumes_taxon_excluded_select.csv` (taxon filter only), `SOURCE_DISPOSITION_REGISTER.md` (prose, not joinable) | **Missing as one ledger.** Several drop paths log nothing: values with no term-map row, values lost when a per-specimen table is collapsed to a mean, values displaced by the step-7 anti-join, items removed by `EXCLUDE_ITEMS`. |

---

## 3. The N question, answered

You asked which papers have unknown N so you can check whether it sits in another table. Full audit
in **`volumes_N_availability.csv`** (57 rows, one per citable source table). Four states:

| State | Items | Meaning |
|---|---|---|
| **A** printed in the TSV the merge reads | 13 | Stephan 1982, 1984 · Frahm 1982, 1984, 1998 · Baron 1983 · Matano 1985a, 1985b, 1986, 1992 · Semendeferi 1998, 2001 · Sherwood 2005 |
| **B** printed elsewhere in the same paper | 19 | **Stephan 1981 Tables I–XVI** (all 16 items — see below) · deSousa 2013 (`n_leaflets`, `n_brain`, `n_LGN` in `deSousa_etal_2013_Table1_snapshot.csv`) · Bauernfeind 2013 T1 + T2 (`n` in `Bauernfeind_etal_2013_Table3.csv`) |
| **C** derivable by counting specimen rows | 7 | MacLeod 2003 T1 (47 rows/11 spp) and T2 (50/16) · deSousa 2010 T1 (29/8) · Smaers 2011 SuppT1 and SuppT2 (26/19) · Barger 2007 T1 (12/6) · Reep 2007 T1 (29/29 → N=1) |
| **D** not located | 18 | see the blocker list |

### B, the one that matters most

`Stephan_etal_1981/Stephan_etal_1981_TablesI-VI.csv` carries **six per-structure-block sample sizes**
— `n_1_18`, `n_19_26`, `n_27_28`, `n_29_34`, `n_35_39`, `n_40_44` (e.g. *Tenrec ecaudatus* = 3, 2, NA,
1, 2, 1). They survive into the bundled public TSV `10.1159%2F000155963_TablesI-VI.tsv`. But the merge
consumes the **per-table split** items, and `per_table/Stephan_etal_1981_TableI.csv` +
`10.1159%2F000155963_TableI.tsv` both drop them. So the Tier-1 backbone's N is already extracted and
the split the merge reads throws it away. Recovering it is a source-TSV fix (add the right `n_*`
column to each per-table item, per `README__after_changing_a_source_TSV.md`), not a merge fix — and it
must be done **before** any weighting, because Stephan 1981 Tables I/II/III/V/VI contribute 103 of the
264 multi-team cells.

### D, the blockers — these are the papers to check

Only 9 of the 18 D items ever appear in a cell where averaging happens. Ranked by how many
multi-team cells they block:

| Item | Team | multi-team cells blocked | where to look |
|---|---|---|---|
| **`Ashwell__2020_SupplementaryTable`** | Ashwell | **97** | `Ashwell-2020-Quantitative analysis of cerebell.pdf` methods; `1-s2.0-S094420062030012X-mmc1.docx` has no N text (scanned, 18k chars). The extracted table is 150 rows / 150 species with no specimen numbering, so N is not recoverable from what we hold. |
| **`Bush_Allman_2004_a_Table2`** | Bush | **87** | `bush_allman_2004a.pdf` / `05760table2.html`. 55 species × 1 row. |
| **`Bush_Allman_2004_b_TABLE1`** | Bush | **49** | `bush_allman_2004b.pdf` p.3. 21 species × 1 row. |
| **`Bush_Allman_2003_Table1`** | Bush | **36** | `bush_allman_2003.pdf` p.2. 45 species × 1 row. |
| `Stephan_etal_1987_Table1` | Stephan_collection | 4 | Tier-1 — N inheritable from the collection (same C&O Vogt specimens); see note below |
| `Zilles_Rehkämper_1988_Table12-2` | Stephan_collection | 4 | as above |
| `Stephan_etal_1970_Table3` / `Table2` | Stephan_collection | 2 / 1 | as above |
| `Frahm_etal_1997_Table1` | Stephan_collection | 1 | as above |

**Ashwell 2020 + the three Bush & Allman tables account for 269 of the 281 blocked contributions.**
Four papers. If N turns up in those four, weighted pooling becomes available on essentially the whole
multi-team surface. If it does not, the honest outcome is: weight the 77 multi-team cells where every
contributor already has N, leave the remaining 187 unweighted, and record which rule fired.

**Tier-1 D items are a special case.** Within `Stephan_collection` a duplicate is resolved by
*recency*, not averaging, so N never enters the arithmetic for those cells — it is documentation only.
And because those papers re-measured the *same* Vogt specimens, their N is a property of the specimen
set, not of the paper: it should be inherited from the collection record via
`_keys/specimen_crosswalk/`, not hunted paper by paper. Do not spend PDF time on Stephan 1970/1987,
Frahm 1997 or Zilles & Rehkämper 1988 for this purpose.

**Naming warning.** `n_obs` (`volumes_compiled_select.R:666`) and `n_rows_in_source` already exist and
are **row counts of collapsed duplicate table rows**, not animals — 2,753 of 2,777 audit rows are `1`.
Call the new column `N_specimens` and never reuse `n`, `n_obs` or `n_sources`.

---

## 3a. Resolved 2026-08-19 — the four blockers are no longer blockers

All four were checked. **252 of the 264 multi-team cells (95%) now have a known N for every
contributor**, up from 77. Full evidence, including specimen identifiers and unpublished per-brain
values, is restricted:
`Evo-M1-Traits-Data-restricted/unpublished_data/____Unpublished__Bush_Allman_specimens/Bush_Allman_N_FINDINGS.md`.
Publishable conclusions:

**Bush & Allman 2003, 2004a, 2004b are one sample of 55 Wisconsin brains.** The specimen workbook
supplied by Bush holds 59 specimen rows across 55 species — exactly the PNAS 2004a sample, with 2004b
(21 spp.) and 2003 (45 spp.) as subsets. Only three species have more than one brain: *Aotus
trivirgatus* (2), *Ateles* sp. (2), *Galago senegalensis* (3). **N = 1 for the other 52.** Verified
cell-by-cell: 102/102 cells of 2004b Table 1 and 200/200 of 2004a Table 2 reproduce a specimen value —
or, for those three species, the specimen mean — at the printed precision, with zero mismatches. 2003
Table 1 prints to 3 significant figures and matches on 157/168; 11 cells differ, two materially
(*Papio hamadryas* neocortex grey −9.7%, white −6.5%), so **prefer the 2004 tables for `Neocortex_*`** —
the workbook is the later revision.

**Bush & Allman 2004b Table 1 contains no Frahm 1984 data, and needs no de-averaging.** The methods'
"combined with those of Frahm et al. (1984), averaging in cases of overlap" describes the 37-species
*regression sample*, which was never tabulated. Table 1 is the raw own-measurement table: every cell
traces to a Wisconsin brain; 30 of Frahm's 41 primates are absent from it; its haplorhine count (14) is
the stated own-measurement count, not the combined 22; and for the 11 species sharing an exact name,
Bush V1 grey ÷ Frahm area striata grey runs 0.61–1.09 (median 0.81) — an average would have to lie
*between* the sources. Where Frahm fits: Frahm 1984 Table 1's 41 primates collapse to exactly 22
haplorhine + 15 strepsirrhine genera, which is precisely the paper's stated combined composition — so
the analysis dataset was built on Frahm's taxon list with Bush's species folded in as overlaps. Two
loose ends recorded in the findings file: *Semnopithecus entellus* has no Frahm counterpart (a
one-taxon discrepancy), and Table 1 prints 21 species where the methods claim 22.

**Ashwell 2020 was averaged too early — fixed 2026-08-19.** The snapshot xlsx is per-specimen for
*Ornithorhynchus anatinus* (rows 1–3) and *Tachyglossus aculeatus* (rows 1–3), each followed by
explicit `mean` and `SD` label rows; the remaining 148 species are one unnumbered row each. The `.csv`
collapsed those 6 specimen rows into 2 species means and dropped the label rows.
`Ashwell__2020/Ashwell__2020_SupplementaryTable.R` has been rewritten to stop averaging at extraction:

- data table is now **154 rows / 150 species**, with `species_as_published`, `specimen_number`,
  `row_type` and `n_specimen_rows` alongside the existing columns; the public TSV is regenerated
- Ashwell's printed mean/SD rows are no longer discarded — they moved to
  `Ashwell__2020_published_mean_reconciliation.csv` as a QA anchor. All 26 printed means reproduce from
  the specimen rows (3 differ in the last printed digit by ≤0.3%, Ashwell's own rounding); 2 printed
  **SD**s do not (*Tachyglossus* `total_cb_volume` 385 vs 311.6, `total_cb_cx_volume` 259 vs 187.7), so
  the printed SDs should not be trusted — the means and the specimen values reconcile, which is what
  matters here
- **zero numerical change to `volumes_long.csv`**: the old script's species mean and the merge's
  step-6 within-team mean are the same arithmetic, verified identical on all 26 monotreme values. The
  148 single-row species are byte-identical. The change buys N and provenance, nothing else
- `n_specimen_rows` counts **printed rows, not animals** — for the 148 unnumbered species Ashwell does
  not say whether one row is one brain, so N stays `as_published_single_row` for them and becomes a
  real counted N only for the two monotremes
- offline mirror `Ashwell__2020_SupplementaryTable.py` added (no R in the sandbox); the `.R` is
  canonical, and previous outputs are in `Ashwell__2020/_prerun_backup_2026-08-19/`

Also settled by the same check: `raw <- long %>% distinct(Source, Species)` at
`volumes_compiled.R:365` means the step-4 species join cannot fan out on repeated species labels, so
multi-row-per-species sources flow through to the step-6 team mean safely. That is what makes "stop
averaging at extraction" a general policy rather than a special case — the same move is available for
every per-specimen table currently collapsed in the step-3 reshape (Bauernfeind, MacLeod, deSousa,
Smaers, Barger).

**The 12 still-unresolved contributions are all Tier 1 and all documentation-only** — Stephan 1987 (4),
Zilles & Rehkämper 1988 (4), Stephan 1970 Table 3 (2) and Table 2 (1), Frahm 1997 (1). Within Tier 1
duplicates resolve by recency, never by averaging, so N never enters their arithmetic. Their N should
be inherited from the collection: `____Unpublished__Frahm_Stephan_individuals/` holds 96 specimen rows
naming the individual Stephan-collection animals. One caveat carried in that workbook's own notes — its
"Arttypus" values do not reproduce the published Stephan means, so the specimen data may be used to
**count and name** the animals behind a published value but never to recompute it.

---

## 4. The finding that outranks weighting

The merge currently averages Bush & Allman with `Stephan_collection` on 58 cells (plus 47 with
Ashwell, plus 14 in three- and four-team combinations). The repo's own per-paper ReadMes already say
not to:

> "Bush and Frahm neocortex are **NOT interchangeable** — use one consistently."
> — `Bush_Allman_2004_a/Bush_Allman_2004_a_Table2.ReadMe.md`, recording Bush running 3–12% smaller
> than Frahm for shared primates (*Homo* −5.0%, *Pan* −5.5%, *Aotus* −33%)

> "Confirms V1 measurements differ substantially by source; **pick one consistently** for Study 3."
> — `Bush_Allman_2004_b/Bush_Allman_2004_b_TABLE1.ReadMe.md`, recording *Pan* +33%, *Macaca* −39%,
> *Aotus* −37% against de Sousa V1

This is protocol step 6, the evidence is already written down, and the merge cannot see it because
compatibility lives in prose ReadMes while the merge joins on standardized term names. Two sources
whose regional boundaries differ but whose canonical term matches are averaged silently; the only
backstop is the >50% deviation flag, which fires **only within Tier 1** and only against the
next-most-recent value. A −39% V1 disagreement across teams is invisible to it. As of §3a the Bush
divergence is quantified against Frahm directly as well: Bush V1 grey ÷ Frahm area striata grey =
0.61–1.09 over 11 shared species, median 0.81. Systematic, one-directional, not noise.

A weighted mean of two incompatible definitions is a more precisely-computed wrong number. Fix the
compatibility gate first.

### 4a. And a second live defect: the same brains averaged against themselves

The three Bush & Allman tables are the same 55 Wisconsin brains (§3a), but the merge assigns them to
one team and takes the **mean within the team**. In the current `volumes_long.csv`, **70 cells have two
Bush tables contributing and 38 have all three.** *Alouatta palliata* `Neocortex_grey_matter_Vol.mm3` =
17,233.33 mm³ — the mean of 2003's 17.4, 2004a's 17.153 and 2004b's 17.153 cm³. That number exists in
no publication and in no brain; it is an average of three print precisions of one measurement, reported
with `n_sources = 3`.

It compounds across teams. *Aotus trivirgatus* `Neocortex_grey_matter_Vol.mm3` = 6,351.33 is the mean
of the three Bush roundings **and** Frahm 1982 — two Wisconsin brains casting three votes against
Frahm's one. This is what `shares_specimens_with` (§5.1) exists to prevent, and it is a defect in the
canonical output today rather than a hypothetical.

---

## 5. New control files (hand-curated, four of them)

Every one keys on `item_name` — the join key that already ties `__ReadMe.xlsx` "Item name",
`standardized_term_volumes.csv$Reference`, `volumes_long.csv$Sources`, `laterality_known.csv$Reference`
and `volumes_source_citations.csv$Source` together. Match it case- and space-insensitively, the way
`read_item()` does at `volumes_compiled.R:152` — the registry has known case drift (`Table2` vs `TABLE2`).

### 5.1 `_keys/source_relations.csv` — protocol step 2
The typed edge between two items. Replaces "the primary is named in a prose `reason` field".

```
item_from, item_to, relation, scope_variable, scope_species, evidence, n_cells_matched,
max_pct_diff, decided_by, decided_date, note
```

`relation` is a **closed vocabulary**, and each value carries a merge consequence:

| `relation` | merge consequence |
|---|---|
| `republishes` | `item_from` is dropped wherever `item_to` is present. Never averaged, never allowed to win on recency. |
| `remeasures_same_specimens` | recency applies — `item_from` supersedes `item_to`. (Stephan 1987 amygdala over 1981.) |
| `derived_from` | `item_from` is a residual/derived quantity; drop unless it is the only source. |
| `reanalyses` | same numbers, new statistics — treat as `republishes` for value purposes. |
| `independent_series` | eligible for cross-team averaging, **subject to §5.3**. |
| `shares_specimens_with` | not a duplicate publication, but the two items are not independent samples: they collapse into one specimen-sharing group and resolve by recency rather than averaging. |

`shares_specimens_with` is what generalizes Tier 1. Today the recency rule is triggered by the literal
string `"Stephan_collection"` (`volumes_compiled.R:442`). After this change, Tier 1 is *derived* — the
transitive closure of `shares_specimens_with` — so a new paper on the Vogt collection is handled by
adding one row here instead of editing the `papers` tribble's team column. It also retires the
smuggled fact at `volumes_compiled_DeCasien.R:98`, where Barger 2007 vs 2014 specimen overlap is
currently encoded by *renaming the team* to `Zilles`.

Seed rows available immediately: the Smaers 2017 → de Sousa 2010 → Frahm 1984 chain (already
value-matched EXACT, 14 spp, 0.0% difference, in `crosspub_Smaers2017_FINDINGS.md`), the 4
`secondary_compilation` and 2 `derived_residual` skips in `volumes_select_value_flags.csv`, and the
27 *Matano 1986 = Stephan 1981 TableXIII* species already identified as identical to the digit.

### 5.2 `_keys/source_sample_sizes.csv` — protocol step 7
Where N comes from, per item, when it is not in the merged TSV.

```
item, N_mode, N_column, N_source_file, N_value_fixed, N_per_species_file, checked_by,
checked_date, note
```

`N_mode` ∈ `in_tsv` (read `N_column`) · `from_sibling_table` (join `N_source_file`) ·
`count_specimen_rows` (count rows per species on `N_column`) · `fixed` (one N for all species, e.g.
single-specimen studies) · `unknown` (explicitly recorded as unknown — this is what makes "weight only
where N is known" auditable rather than accidental).

`volumes_N_availability.csv` is the pre-filled draft: 39 of 57 items already have a mode, 18 need
`unknown` or a PDF check.

### 5.3 `_keys/definition_compatibility.csv` — protocol step 6
The gate. One row per (canonical variable × item), assigning a **compatibility class**.

```
Variable, item, definition_id, definition_text, compat_class, poolable_with,
evidence, decided_by, decided_date
```

Two items may be cross-team averaged **only if their `compat_class` matches**. Mismatched classes on
the same variable produce, instead of a mean, either (a) a preferred-class value with the others
logged to the exclusion ledger, or (b) two separate variables (`Neocortex_grey_Vol.mm3__Stephan` vs
`__Bush`), whichever you prefer per variable. Recommend (a) with an explicit `preferred_class` column,
because (b) proliferates columns in `volumes_wide.csv`.

`definition_text` is not new writing: `_keys/variable_catalog.csv` (1,561 rows) already carries a
per-item `Definition` column, and each source folder has a `*_definitions.csv`. This file is the
curated *class assignment* over material that already exists. Retire the fake `poolable` column in
`_keys/variable_catalog_compatibility.csv` (or redefine it to read from here) so there is one answer
to "may these be pooled".

Seed rows: the Bush/Frahm neocortex and Bush/de Sousa V1 cases in §4, and Reep's diencephalon
(excludes globus pallidus) vs its striatum (includes it), already documented in `README__merging.md`.

### 5.4 `_keys/specimen_crosswalk/` — protocol step 4, **already built**
35 specimen records + 8 taxon concepts + 181 parsed collection specimens, with `SCHEMA.md` stating the
consumer contract (reassign via `resolved_taxon`, surface `taxon_conflict`, never auto-rewrite a
pooled `decomposable = FALSE` s.l. mean). Nothing reads it. Wiring it in is the work; the curation is
done. It also supplies the Tier-1 N inheritance in §3 and the specimen-overlap evidence behind
`shares_specimens_with` in §5.1.

Note the free gift: `MacLeod_etal_2003_Table2` carries its own `stephan_collection` TRUE/FALSE column,
which the reshape currently drops. That column is a per-specimen statement of whether MacLeod's animal
is one of the Vogt animals — i.e. exactly the independence test that licenses averaging MacLeod with
Stephan_collection. It is being thrown away at `volumes_compiled.R:272-333`.

---

## 6. Three output tables

Your proposal, mapped onto the existing file names so nothing downstream breaks:

| Your table | File | Change |
|---|---|---|
| Raw | `volumes_unfiltered.csv` (written `:437`) | add `N_specimens`, `Specimen_IDs`, `definition_id`, `compat_class` |
| **Curation** | **`volumes_curation.csv` (new)** | one row per candidate value: the relation applied, the specimen-overlap verdict, the compatibility class, the decision (`used` / `superseded` / `dropped`), the rule that fired, and the pointer to the control-file row that decided it. This is the layer that does not exist today. |
| Final species table | `volumes_long.csv` (written `:503`) | add `N_final`, `N_rule` (`weighted` / `unweighted_N_incomplete` / `single_source` / `recency`), `n_specimen_sources` |

Plus one ledger, replacing three partial ones: **`volumes_exclusions.csv`** — every value that did not
make it, with `reason`, `rule`, `control_file_row`, `replaced_by`. Route *all* drop paths through it,
including the currently-silent ones (no term-map row; per-specimen collapse; step-7 anti-join;
`EXCLUDE_ITEMS`; taxon filter).

---

## 7. Implementation order

Phased so that each phase is separately reviewable and only phase 4 changes numbers.

**Phase 0 — safety.** `_prerun_backup_curation_2026-08-19/` copy of the 9 outputs `volumes_compiled.R`
writes (`volumes_source_species_ids`, `volumes_species_ids_cache`, `volumes_unfiltered`,
`volumes_flags`, `volumes_long`, `volumes_wide`, `volumes_species_sources`,
`volumes_source_citations`, `volumes_source_contributions`). Note that
git is unreliable on the OneDrive mount (checkout/status can SIGBUS silently), so the backup folder is
the real safety net, not a commit. Snapshot `volumes_long.csv` as the regression baseline.

**Phase 1 — carry N and specimens without using them.** Extend the term map to admit `N.count` and
`Specimen_ID` as standardized terms; add `_keys/source_sample_sizes.csv`; teach `paper_long()`
(`:252`) to attach `N_specimens` and `Specimen_IDs` alongside `Value`; recover the Stephan 1981
per-table `n_*` columns at source. Preserve them through `long` (`:353`), `teamvals` (`:470`) and into
`volumes_long.csv`. **Zero numerical change** — assert byte-identical `Value` against the phase-0
baseline. This phase alone answers "how many brains is this number".

**Phase 2 — wire the specimen crosswalk.** Join `_keys/specimen_crosswalk/` on `Specimen_IDs`; emit
`volumes_curation.csv` with a specimen-overlap verdict per candidate; report which cross-team averages
are currently pooling the same animal twice. **Report only, no drops yet** — expect surprises, and
review them before acting. Recover `MacLeod_etal_2003_Table2$stephan_collection`.

**Phase 3 — relations and definitions.** Build `_keys/source_relations.csv` and
`_keys/definition_compatibility.csv`; derive Tier-1 membership from `shares_specimens_with` instead of
the hardcoded team string; apply `republishes` / `derived_from` drops; gate cross-team averaging on
`compat_class`. Stand up `volumes_exclusions.csv`. **This phase changes numbers** — chiefly by
*removing* incompatible contributors from means. Every changed cell needs a line in the exclusion
ledger naming the control-file row responsible.

**Phase 4 — weighted means.** Only after phase 3 settles. Weighted where `N_specimens` is present for
every contributor to that cell; unweighted otherwise; `N_rule` records which. Expected reach after §3a:
**252 of the 264 multi-team cells (95%)**. The residual 12 are Tier-1 recency cells where N never
enters the arithmetic anyway. Note that most of the weighting will be mild — the Bush team is n=1 for 52
of 55 species and Ashwell is n=1 for 148 of 150 — so the visible effect of weighting will fall on cells
where a Stephan/Frahm multi-brain mean meets a single-brain Bush or Ashwell value, which is the case
where weighting is most obviously right.

**Phase 5 — regenerate and re-check.** Recompute the DeCasien comparison
(`volumes_compiled_DeCasien.R`) and `compare_to_reference.R`. Prior history is instructive here: an
earlier source-matched "expansion" was reverted because cross-team averaging pulled great-ape values
away from DeCasien's single-source figures — **44 regressions**. That is the failure mode this whole
plan is designed to prevent, so treat any movement *away* from DeCasien on great apes as a signal that
a compatibility class or a relation row is wrong, not as noise.

---

## 8. Shared helper — `_tools/curation.R`

`source_citations.R` (sourced at `volumes_compiled.R:629`) is the only existing precedent for a shared
sourced helper in this repo, and it is a good one — documented contract, `pseudo_source_items`
extension point. Mirror its shape. Pure functions, no side effects, no `setwd`, every argument
explicit:

```r
read_curation_keys(base)                        # -> list(relations, sample_sizes, compat, specimens)
apply_relations(long, relations)                # -> long + $relation_action, $relation_row
specimen_overlap(long, specimens)               # -> long + $specimen_group, $overlap_with
derive_sharing_groups(relations)                # transitive closure -> replaces the Tier-1 team string
attach_N(long, sample_sizes, sources)           # -> long + $N_specimens, $N_mode
compat_gate(long, compat)                       # -> long + $compat_class, $poolable_here
pool_values(long, weighted = "if_complete")     # -> value + $N_rule + exclusion rows
curation_ledger(...)                            # -> the volumes_curation.csv / volumes_exclusions.csv pair
```

Why these generalize to the other 12 domains:

- Every compiled script already builds a data frame literally named `long` and one named `wide`
  (`behaviour:172/179`, `body_ecology:356/390`, `brain_mass:126/141`, `cerebellar_folding:27/49`,
  `cortical_areas:79/98`, `gyrification:68/81`, `sleep:104/112`, `volumes:353/585`).
- Every one resolves duplicates with some ad-hoc version of the same three moves: prefer-newest,
  prefer-primary, or mean. `pool_values()` subsumes all three.
- Team identity is currently encoded **three incompatible ways** —
  `_keys/team_grouping_crosswalk.csv` keyed on `paste(tolower(first_author), year)`
  (`body_ecology:63`, `brain_mass:41`), in-script named vectors (`behaviour:44`, `gyrification:51`,
  `cerebral_metabolic_rate:139`), and the per-item `tribble` in `volumes_compiled.R:44`. Only the
  volumes form can say "two tables in the same paper belong to different teams".
  `derive_sharing_groups()` replaces all three with one derived answer.
- Two scripts **actively delete** sample size at intake — `body_ecology:116` and `brain_mass:67`
  both run `cand[!grepl("^n[ _]", norm(cand)) & !grepl("sample_size", norm(cand))]`. Two others
  already carry it unused: `cortical_layers` (`n_specimens`, `uncertainty_value`, plus `specimen_id`
  and a real observation-level key at `:95`) and `cerebral_metabolic_rate` (`n`, `SD`). Those two are
  the natural second and third adopters.
- `cerebral_metabolic_rate_compiled.R:139-145` already dedupes on the **cited primary study** rather
  than a team label (`comp_priority`), which is conceptually `republishes` by another name. It should
  be re-expressed as `source_relations.csv` rows, and is a good test that the vocabulary is sufficient.
- `sleep_compiled.R:23-25` explicitly defers duplicate handling to "the team-aware /
  citation-dependency rules in the README" and already carries `team` and `dependency_group` columns.
  It is pre-wired for this.

Keep `.R` canonical. There is no R in the sandbox, so verification uses an offline Python mirror
writing with R's quoting and `"%.15g"` float format so the outputs diff cleanly. The pattern already
exists in the repo — `__merging_trees/build_mammal_tree.py` mirrors `build_mammal_tree.R`, and
`_tools/mirror_new_comparisons.py` uses the same float format — but **no mirror exists for
`volumes_compiled.R` yet**, so writing one is part of phase 1 rather than something to inherit.

---

## 9. Honest caveats

1. **Steps 3 and 5 of the protocol are already implemented, and re-deriving them risks regression.**
   The `keep_i` idiom (`:446-454`, `:485-499`) — stamping `Source`/`Year` from the same row as `Value`
   rather than re-deriving them — is the reason the `Sources` column is trustworthy. Preserve it
   exactly; every new decision layer must return an *index*, not a recomputed value.
2. **`flags` is assigned, not appended, at `:459`** (`... -> flags` overwrites the tibble initialised at
   `:441`). It is harmless today because nothing populates `flags` before line 459, but a curation
   layer that adds flags earlier will lose them silently. Change to `bind_rows` in phase 1.
3. **"Weight only where N is known" is a defensible rule that will look inconsistent in print.**
   Two cells in the same column, same species, will have been computed by different arithmetic. The
   `N_rule` column makes that auditable, but the methods section has to state it plainly.
4. **Averaging is not always the right end state even for independent samples.** The repo already
   contains two domains that refuse to average on principle — `behaviour_compiled.R:9-14`
   (VocalRepertoire and Dexterity are citation-dependent) and `gyrification_compiled.R:14` (both GI
   teams trace to the Zilles method, so `citation_dependency` is recorded and the newer team is
   preferred outright). For volumes, the §4 finding suggests some variables should follow that pattern:
   a `preferred_class` rather than a mean.
5. **18 of 57 items have no located N and 9 of those never matter.** Do not let N completeness become
   the gate on the rest of the plan. Phases 1–3 deliver most of the value and none of them require N.

---

## Appendix — files this plan creates or changes

New: `_keys/source_relations.csv` · `_keys/source_sample_sizes.csv` ·
`_keys/definition_compatibility.csv` · `_tools/curation.R` · `__merging_volumes/volumes_curation.csv`
· `__merging_volumes/volumes_exclusions.csv` · `__merging_volumes/volumes_N_availability.csv` (already
written, draft of the audit)

Changed: `__merging_volumes/volumes_compiled.R` (steps 2/3 reshape, 5, 6, 6b, 8b) ·
`__merging_volumes/standardized_term_volumes.csv` (+`N.count`, +`Specimen_ID`) ·
`Stephan_etal_1981/per_table/*.csv` and their public TSVs (recover `n_*`) ·
`_keys/variable_catalog_compatibility.csv` (retire or redefine `poolable`) ·
`__merging_volumes/README__merging.md` (document the ladder)

Wired in, unchanged: `_keys/specimen_crosswalk/*` · `_keys/variable_catalog.csv` (`Definition`) ·
`__ReadMe.xlsx` cols AC–AE (`Flags pre-addressed` / `possible` / `active`), AF (`Sample type`),
AG (`Method`), AL (`Data role`) — all present, none currently read by the merge.
