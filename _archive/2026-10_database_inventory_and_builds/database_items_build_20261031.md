# Database items — build and TSV-export pass, 2026-10-31

Scope: the large born-digital database items plus the built-but-not-exported items.
Nine registry items. `__ReadMe.xlsx` was **not edited**; every registry change is proposed in a
`<Item>_registry_row.xlsx` in the paper folder.

## 1. Diagnosis — five items with an analysis CSV but no public TSV

| Item | Diagnosis | Detail |
|---|---|---|
| `Jung_etal_2022_TableS1` | **(a) never writes a TSV** | script ended at `write.csv`; no `__ReadMe.xlsx` read, no `item_encoded`, no `__Public/` path |
| `Jung_etal_2022_TableS2` | **(a) never writes a TSV** | same |
| `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt` | **writes a public file under a non-conforming name** | not (a) or (b): the `Item encoded` lookup *succeeded*; the script wrote a byte-identical copy named with the bare `item_encoded` and **no `.tsv` suffix**, so `tsv_name_match` failed |
| `Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt` | same | same |
| `Nudo_Masterton_1990_IV_Figure2A` | **(c) deliberate documented hold — not forced** | README §"Build status" names the gate `EVOM1_SPINAL_NUDO_RELEASE=OWNER_VERIFIED_R_SOURCE_SCHEMA_AND_SCIENTIFIC_GATES`; siblings `Nudo_Masterton_1990_III` and `Nudo_Masterton_1988` implement it, and `Nudo_Masterton_1988_TABLE1.R` line 1 carries the owner decision of 2026-10-16 that flips it on *for that item*. Figure2A has not been through the gate; registry stage is `candidate`. Reported, not exported. |

## 2. Validation — `validate_dataset_item()`

| Item | Result |
|---|---|
| `Jung_etal_2022_TableS1` | ALL PASS (8/8) |
| `Jung_etal_2022_TableS2` | ALL PASS (8/8) |
| `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt` | ALL PASS (8/8) |
| `Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt` | ALL PASS (8/8) |
| `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv` | ALL PASS (9/9) |
| `Myhrvold_etal_2015_AmnioteRangeCountAug2015.csv` | ALL PASS (9/9) |
| `Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv` | ALL PASS (9/9) |
| `Nudo_Masterton_1990_IV_Figure2A` | FAIL: `tsv` — **expected**, the documented hold |
| `Upham_etal_2019_Completed100` | FAIL: `tsv`, `definitions` — **expected**, matches the `Isler_etal_2008_Tree.nex` precedent exactly (Isler has no `reference_tables/` and no public TSV) |

## 3. Public TSVs written

| file | data rows | bytes |
|---|---|---|
| `10.1126%2Fsciadv.abn0954_TableS1.tsv` | 11 | 1,259 |
| `10.1126%2Fsciadv.abn0954_TableS2.tsv` | 9 | 730 |
| `10.1890%2F08-1494.1_PanTHERIA1-0WR05Aug2008.txt.tsv` | 5,416 | 2,353,679 |
| `10.1890%2F08-1494.1_PanTHERIA1-0WR93Aug2008.txt.tsv` | 4,629 | 1,544,945 |
| `10.1890%2F15-0846r.1_AmnioteDatabaseReferencesAug2015.csv.tsv` | 113,101 | 34,735,298 |
| `10.1890%2F15-0846r.1_AmnioteRangeCountAug2015.csv.tsv` | 107,605 | 20,302,177 |
| `10.1890%2F15-0846r.1_AmnioteSparseTableAug2015.csv.tsv` | 279,459 | 76,476,827 |

Both PanTHERIA TSVs re-verified byte-identical to their publication files
(md5 `22280dd4db1e7aeb3325199dce4c2130` and `0a7041fed8c203f04bf455312c717b95`).

## 4. Source-tracking confirmation (compilations)

**PanTHERIA** — `Jones_etal_2009_references.R` re-run: 3,143 numbered references parsed from
`metadata.htm` section F; 3,114 distinct numbers cited across WR05+WR93 and **all 3,114 resolve**
(0 unresolved, asserted); 29 listed references never cited; 49,144 species × reference rows with
`n_reference_numbers == n_citations_resolved` asserted per species; 38 fused tokens (missing `;`)
decoded and recorded. Join written into the `References` Note of
`Jones_etal_2009_definitions.csv`, **including the limitation**: PanTHERIA cites per *species*,
not per *variable*, so one value traces to the candidate set for that species, not to one study.

**Myhrvold** — chain verified and written into each definitions Note: value → aligned
References cell → `cell_references_part001..007.csv` (322,572 rows, 0 parse failures) →
`Myhrvold_etal_2015_references.csv` (1,003 keys; 924 `matched_unique` to a full citation from
Supplemental Table 1, 62 `no_entry_found`, 8 `no_year_in_key`, 9 ambiguous). Record level:
1,026 of 1,028 Sparse-Table `dataset` strings resolve after stripping the `BC <class> - ` prefix,
covering **98.0%** of records; **85.4%** of records reach a full citation.

## 5. New errata — `Myhrvold_etal_2015-E003` … `-E023`

21 cells of `Amniote_Range_Count_Aug_2015.csv`, all trait `female_svl`, print `count > 0` and a
real `max` but `min = -999`. Mechanism established and reproduced for **all 21**: the publication
computed `min()` and `count()` over the record pool with the −999 sentinel counted as an
observation (`count` = n_records + 1; `max` reproduces the true maximum exactly). `issue_type
publication_error`, status `proposed`, recoverable true minimum given as `proposed_value`; the
printed value stands. `render_errata("Myhrvold_etal_2015")` run — README block and the `min`
definitions Note both rendered.

## 6. Open actions for the owner

1. **Two orphan files in `__Public/comparative-data/`** — the pre-fix PanTHERIA exports, named
   without a `.tsv` suffix: `10.1890%2F08-1494.1_PanTHERIA1-0WR05Aug2008.txt` (2,353,679 B) and
   `…WR93Aug2008.txt` (1,544,945 B). Superseded by the `.tsv` files above. Not deleted by this
   pass — nothing here deletes pre-existing repo files.
2. **Eight `<Item>_registry_row.xlsx` UPDATE proposals** to paste (Progress stage, and N.B.;
   Data role where a finding applies). Built against the live 34-column Sheet1 header.
3. **`Jung_etal_2022_TableS1` data role** — registry says `both`; every measured cell in the
   printed table carries a numbered citation to another study, including the wallaby column. The
   only uncited cells are the two derived ratio rows. Reads as secondary throughout. Flagged, not
   changed. (TableS2's `both` *is* correct — its Wallaby row prints `(own data)`.)
4. **`.csv` in three Myhrvold Item names** — `…RangeCountAug2015.csv` etc. carry the source file
   extension, so the analysis CSV is `….csv.csv` and the TSV `….csv.tsv`, while the sibling
   `Myhrvold_etal_2015_AmnioteDatabaseAug2015` is registered without it. The registry was followed
   as the authority; normalise if wanted (it would change `Item encoded` and the TSV names).
5. **`Upham_etal_2019_Completed100`** — decided a tree item, no TSV (decision written into
   `Upham_etal_2019.README.md`). Open: whether to publish the 27 MB nexus as
   `…_Completed100.nex` the way Isler publishes its tree. Not written here.
   **Security note:** `Completed100_topoCons_NDexp/config.yaml` contains a personal email address
   and must not be copied into `__Public/`. Nothing in this pass copied it.
6. **`Jung_etal_2022_TableS1_snapshot.xlsx` is transposed** relative to the publication (table S1
   prints species across columns). Not re-saved, per instruction; recorded as a known departure
   from the "same spatial format as printed" snapshot rule.
