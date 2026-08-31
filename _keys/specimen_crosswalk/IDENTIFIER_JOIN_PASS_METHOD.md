# Systematic identifier-join pass — method and column audit

*Public half. Every paper table in `Evo-M1-Trait-Data` joined against the specimen identifier space.
Per-paper specimen determinations depend on the private catalog and live in the restricted
companion note `specimen_registry/derived/RESTRICTED_identifier_join_results.md`.
Outputs: `identifier_join_pass_columns.csv`, `identifier_join_pass_matches.csv`,
`identifier_join_pass_by_paper.csv`. Nothing written into either repository.*

## Method

347 tables across the 168 paper folders were read (4 skipped as >8 MB; infrastructure
folders excluded). Every column whose name suggests an identifier was extracted and each
value looked up — raw and with Bauernfeind-style trailing footnote letters stripped —
against the 1,328 specimen handles in `lookup_index.csv`.

**Match count alone is useless as evidence**, which the first run demonstrated: a row-index
column (`Wilman_etal_2014.MSW3_ID`, 5,400 values) produced 154 "hits" purely because Stephan
`Tier Nr.` values are 2–4 digit integers. The discriminator is **match rate** — matched
distinct values divided by total distinct values in the column — plus two structural
rejections:

- **row-index-like**: ≥10 values, ≥90% integers, starting near 1, near-contiguous range.
- **species-code column**: values overlap `species_reference.code_Stephan1981` at >50%.

That second test earned its place. `Stephan_etal_1981.code` matched 13 catalog Art numbers
and looked like a hit; it is 76/76 a *species* code and 0/76 an Art number. Conversely
`Matano_etal_1985_b.code`, `Stephan_etal_1984.code` and `Baron_etal_1983.code_Baron1983`
overlap species codes at 0–2% and Art numbers at 36–43 values each. They are accession
numbers.

## Result: 47 columns assessed, 21 credible

| tier | columns | rule |
|---|---|---|
| A — register now | 12 | match rate ≥ 0.75 |
| B — review then register | 8 | 0.35 ≤ rate < 0.75 |
| C — rejected on review, series-code collision | 1 | `Ebinger__1974.individual` |
| C — rejected, non-identifier column | 14 | `ref_number`, `search_id`, `%animal prey`, `dendritic_spine_number` … |
| C — rejected, species-code column | 5 | >50% species-code overlap |
| C — rejected, low match rate | 4 | rate < 0.35 |
| C — rejected, row-index-like | 3 | contiguous integer sequence |

605 row-level matches were retained from 1,032 raw hits, reaching 185 distinct specimen
entities. Tier review then rejected the 4 `Ebinger__1974` rows, leaving **601** matches —
the set carried into the collection-scoped re-join (`IDENTIFIER_MATCHING_RULES.md`).

## What this does not do

- **It cannot find specimens that are never named.** `Barger_etal_2014` prints no specimen
  handle at all (its only candidate column is a row index), so Disco remains invisible there
  despite being present — identifiable only because its values reproduce Barger 2007's rows.
  That case needs the measurement bridge, not a better join.
- **It says nothing about species-mean publications**, which carry no identifiers by
  construction. The `via_data_source_registry.csv` mechanism remains the right treatment.
- **It does not verify that a matched value means the same animal.** A 4-digit number
  appearing in both a paper and the catalog is strong evidence in a Stephan-lineage paper and
  weak evidence elsewhere; tier B exists precisely because that judgement is not mechanical.

## Suggested next actions

1. Fix the `MacLeod_2000` / `MacLeod__2000` key mismatch — largest gain, one string.
2. Register the three individual-resolving papers (`deSousa_etal_2009`, `Kochiyama_etal_2018`,
   the individual part of `Bauernfeind_etal_2013`) as `match = matched`.
3. Register the four Stephan-lineage papers in two parts: the 49 single-animal accessions at
   `match = matched`, and the 114 multi-animal ones at the accession level with `n` used and
   N held recorded, never by picking an animal. Resolve the 20 species-label disagreements
   as `taxon_conflict` rows.
4. Review the remaining tier-B columns by eye before registering. `Ebinger__1974` was
   already rejected this way; the series-code collision it hit is the pattern to watch for.
5. Re-run this pass after any registration round — it is cheap, and its counts should be
   generated into whatever note reports them rather than transcribed.