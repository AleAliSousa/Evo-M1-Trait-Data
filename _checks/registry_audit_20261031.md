# Registry audit — 2026-10-31

Audit of `__ReadMe.xlsx` against the paper folders and `__Public/comparative-data/`, followed by a
build pass on the remaining unbuilt registry items (R 4.5.3, `evom1-r` environment; R now runs in the
sandbox, so builds were executed and validated rather than queued for RStudio).

## Overall health — GOOD; no data loss. The binding constraint is TSV/registry name reconciliation

- **Registry:** 890 Sheet1 data rows, 0 fully empty formatting rows. The workbook was edited
  concurrently by the owner throughout (it grew during the pass), so every script re-read it before
  writing a TSV, and the counts here are a point-in-time read.
- **Lost rows: 0.** `registry_snapshot.csv` (680 keys, 2026-10-26) has 33 keys absent now. 20 are the
  `#n` spacing change (`Table2 #2` → `Table2#2`), 12 are the renames documented on 2026-10-28, and the
  last — `Winkler_Bryant_2021_Figure1 #2` — was an exact duplicate pair (same Item number, same Item
  encoded) of which one copy has been removed. That is a deduplication, not a loss: the folder holds
  one item and one TSV. 233 keys are new since the snapshot; refresh it (`_checks/registry_snapshot.R`).
- **Malformed keys:** 0 blank Item names, 0 `xml:`/quote corruption, **3 trailing `_`**
  (`Anderson_Gallup_2015_`, `Gallup__1977_`, `Nunn_etal_2001_`). These are the three whole-paper
  REFERENCE-ONLY / HOLD rows, where a blank Item number is semantically intended but still breaks the
  `read_item()` contract. The 2026-10-28 audit reported 0; they are back.
- **Duplicate Item names:** 17, all the legitimate `#n` multi-row convention.
- **Folder audit:** 472 folders, **407 clean** on all three checks (405 before this pass;
  `_checks/folder_audit.csv` rewritten).
- **Public TSVs:** 842 files, **27 orphans** (unchanged in count from the start of the pass, because
  every TSV written this pass matched its registry `Item encoded`).

## Findings by severity

### A. All 27 orphan TSVs are name mismatches, not missing registrations

The 2026-10-28 audit framed the orphans as a registration backlog. They are not: every one of them
belongs to an item that **already has a Sheet1 row**. The registry `Item encoded` and the filename on
disk simply disagree, in four families:

| Family | n | Registry `Item encoded` | File on disk | Fix |
|---|---:|---|---|---|
| OUP book chapters (Hardus 2009 ×4, Morrogh-Bernard 2008 ×6) | 10 | `…acprof%3Aoso%2F9780199213276…` (colon percent-encoded) | `…acprof:oso%2F9780199213276…` (literal colon) | Morrogh-Bernard already has correct `%3A` copies, so its 6 literal-colon files are **stale duplicates to Trash**; Hardus's 4 need renaming to `%3A`. |
| Galán-Acedo 2019 | 7 | `…_BodyMass.csv` etc. (Item number carries the source `.csv`) | `…_BodyMass.tsv` | Double-extension case, same as de Sousa 2022: expected name is `…_BodyMass.csv.tsv`. Owner decides whether to strip `.csv` from Item number (col D) or rename the files. |
| Colour-vision text items (Jacobs & Deegan 1993/2001, Deegan & Jacobs 2001, Hiwatashi 2011) | 4 | `…_Text:Discussion,LemurPhotopigments` etc. | `…_TextResults` | Item number and filename describe the locus differently. Reconcile one way. |
| Carried over from 2026-09-30 | 5 | stray space (`ar.20829 `, `s00429-014-0792-y `), Owren 1988 `_Table1+Table3`, Schusterman 1974 `_TableI`, Gillette 1973 DOI-vs-PMID | — | Rename the TSVs; the registry is the authority. |

Plus the stale `NA.tsv` (a 2026-09-28 output of `Heffner_Heffner_1992_c_TABLEI.R`, written when the
Item-name lookup returned NA). Move it to Trash.

### B. `audit_folders.py` under-reports registration because `norm()` drops non-ASCII

`norm()` strips every non-`[a-z0-9]` character, so `é` vanishes rather than folding to `e`:
`Norlén_etal_2019` → `norlnetal2019`, which does not prefix-match the registry's
`Norlén_etal_2019_Table1` → `norlenetal2019table1`. Norlén is fully registered (4 items) yet appeared
in the "no Sheet1 row" list; only the author/year fallback rescued it. Affected folders include
Norlén, Ballesteros-Yáñez, Kowiański, Gómez, Galán-Acedo, de Magalhães, Zilles-Rehkämper,
Braitenberg-Schüz, Lethmate-Dücker and Medina-González. **Fix:** fold with
`unicodedata.normalize('NFKD', s).encode('ascii','ignore')` before stripping.

### C. Folder name ≠ registry Item-name stem: `Hardus_etal_2009`

The folder is `Hardus_etal_2009/`; the four registry items are `HardusME__2009_Table4.1`–`4.4`. Neither
the prefix match nor the author/year fallback connects them, so the folder reads as unregistered and
the items read as having no folder. Rename one side.

### D. Snapshot fidelity in the social-variables intake (7 folders) — FOUND, then REPAIRED 2026-10-31

Devillard 2003, Jaeggi 2020, Modlinska & Stryjek 2016, Norbury 1998, Qiu 2022, Wiafe 2019 and
Ziege 2016 had built products but no Sheet1 row, and their frozen sources did not meet the snapshot
rule. Files named `*_snapshot.csv` in Devillard (`ColonySize`), Modlinska (`Colony`), Norbury
(`DenCensus`), Ziege (`Population`) and Wiafe (`GroupSizes`) were cleaned analysis tables carrying
project columns (`role`, `quality_flag`, `source_doi`, `age_scope`) — not the published table or
text as printed. In Devillard and Modlinska the "snapshot" was a byte-identical copy of the analysis
CSV, which is the hardcoding failure mode the snapshot HOWTO names explicitly. Norbury's carried
**39** single-occupant dens, a number the paper never prints (it is 41 - 2).

**All seven were repaired on 2026-10-31**, with no change to any derived value (Ziege mean 4.14,
Norbury 1.048780487804878, Modlinska 50, Wiafe 10.8 all unchanged):

| Folder | Frozen source now | How |
|---|---|---|
| Devillard 2003 | constructed snapshot: printed wording + 3 verbatim Methods sentences, p. 204 | new `build_colony_size.py`, reading the folder's PDF and asserting each passage verbatim |
| Modlinska 2016 | constructed snapshot: `approx. 50 individuals` + verbatim Methods sentence | sentences extracted from `source/PMC4890768.xml` |
| Norbury 1998 | constructed snapshot: printed `41`, `Two`, `adult males`, `May and August` + 2 verbatim sentences, p. 154 | asserted verbatim against `source/Norbury_etal_1998.pdf`; the derived 39 moved to `Norbury_etal_1998_DenCensus.csv` |
| Ziege 2016 | `Ziege_etal_2016_Table1_snapshot.csv` - Table 1 as printed, spanning `Coordinates` header, section rows, caption | regenerated from the XML with colspan honoured; reproduces the previous hand-made file on all 114 cells |
| Wiafe 2019 | `Table3_snapshot.csv` in the printed grid (sector band over Mean/SE/Range) + abstract constructed snapshot keeping the printed word `six` | `build_group_sizes.py` |
| Jaeggi 2020 | `Populations_snapshot.xlsx` byte-identical to the author workbook (177,036 B) | extracted from `source/author_workbook_original.zip`; the old file was an Office re-save (183,616 B) |
| Qiu 2022 | `Populations_snapshot.xlsx` byte-identical to the author S5 workbook (23,014 B) | extracted from `source/Model_S5_author_archive.zip`; old file 30,241 B |

Both builders are idempotent (re-running changes no snapshot byte), and `audit_folders.py` no longer
flags any of the seven for invariant 1. Jaeggi's and Qiu's CSV sheet transcriptions were renamed to
`*_sheet_rows.csv` - readable twins of the frozen workbook, not second snapshots. Superseded files
were moved to Trash, and each folder's README records what changed and why.

Wiafe's duplicate snapshot pair under a `Wiafe__2019_` (double-underscore) prefix is resolved: that
content was verified correct against the PDF and is now produced under the folder-consistent names.
**Still open for the owner:** the house convention gives single-author papers a double underscore
(`Gallup__1977`, `Karbowski__2007`), and Wiafe 2019 is single-author, so the folder arguably should
be `Wiafe__2019`. It is unregistered with no public TSV, so renaming is cheapest now, but it also
touches `source_publication` in the species key.

These seven are now registrable. They were not registered in this pass.

### E. Registered items with no public TSV: 56 (was 74 at the start of the pass)

The 18 closed this pass are listed under "Actions taken". What remains is: documented skips and policy
holds (Anderson & Gallup, Gallup 1977, Nunn 2001, Smith & Jungers, Westergaard & Hyatt ×2, Norlén
Figure 1, Ketten 2012, de Magalhães & Costa, Halley & Krubitzer, Elston 2005a Tables 4–6 and 2005b
Table 4 behind the owner publication gate); non-TSV items (Isler 2008 `Tree.nex`, Upham 2019
`Completed100`); items built but awaiting owner review (Van Essen & Drury cited V1 ranges, Mayer 2019
Fig 6, Young 2013 surface text, Nudo 1990-IV Figure 2A); the 27 orphan-TSV items from finding A, whose
files exist under the wrong name; and `Frost_Masterton_1994_Figure3`, now blocked on method (below).

### F. FINISHED with no public TSV on disk (8) — unchanged since 2026-09-30

`Boddy_etal_2012_brainbodydatabasev2.txt`, `Brodmann__1913_Tabelle1`, `Halley_Krubitzer_2019_Figure1`,
`Isler_etal_2008_Tree.nex`, `Jorstad_etal_2023_TableS1`–`S4`. Same set for the third audit running, so
the issue is the stage label or the TSV convention, not data loss. Decide once and relabel.

### G. Merge wiring: none of the 2026-10-28 or 2026-10-31 builds is wired in

`grep -l <ItemToken> __merging_*/*.R` returns zero for Filiminoff, Panepinto, Morelli 2025, Kay 2026,
Johnson 2002, Siegel 2022, Bahney 2018, Carlo & Stevens, Iwaniuk 2000, Dom 1971, Heffner 1992b,
Heffner 1999, Heffner & Heffner 2018, Glendenning & Masterton, MacLean 2014, Sherwood 2020,
Ferrell 2026 and Kaskan 2005. Karbowski is the only token with a merge hit, and that predates this
pass. A source folder's existence is still not evidence of wiring.

### H. Jones et al. 2009 shares one definitions file across two items

`validate_dataset_item()` fails the `definitions` check for both PanTHERIA items: the folder has a
single paper-level `reference_tables/Jones_etal_2009_definitions.csv` (built by
`Jones_etal_2009_definitions.R`) rather than `<Item>_definitions.csv` per item. This predates the
pass and is defensible — WR05 and WR93 are the same variable dictionary under two taxonomies — but it
is a standing invariant failure. Either split it or record the exemption.

## Actions taken (2026-10-31 build pass)

Four parallel build tracks. **26 items built and validated** across 17 paper folders, 1 blocked on
method, 2 resolved as deliberate non-TSV or held items, and 10 registry rows staged for unregistered
folders.

### Items built

| Folder | Item | Rows | Data role | refs CSV | validate |
|---|---|---:|---|---|---|
| Karbowski__2007 | `Karbowski__2007_Table1` | 23 | secondary | 48 rows | 7P/0F/2S |
| Branstetter_etal_2017 | `Branstetter_etal_2017_TableI` | 96 | both (proposed) | 2 rows | 7P/0F/2S |
| Stephan_etal_1991 | `Stephan_etal_1991_Table71` | 43 | primary (provisional) | — | 7P/0F/2S |
| Heffner_etal_2008 | `Heffner_etal_2008_ResultsText` | 11 | primary | — | 7P/0F/2S |
| Rivara_etal_2003 | `Rivara_etal_2003_TABLE1` | 6 | primary | pre-existing | 7P/0F/2S |
| Kaskan_etal_2005 | `Kaskan_etal_2005_Figure2` | 8 | secondary | — | 7P/0F/2S |
| Kaskan_etal_2005 | `Kaskan_etal_2005_Figure3` | 46 | secondary (digitised) | — | 7P/0F/2S |
| Heffner_etal_1994_c | `Heffner_etal_1994_c_Figure7` | 29 | secondary | 29 keys, 5 unresolved | 8P/0F/1S |
| Heffner_etal_2003 | `Heffner_etal_2003_Figure4` | 49 | both | 3 curves | 7P/0F/2S |
| Heffner_etal_2003 | `Heffner_etal_2003_Figure5` | 62 | secondary | 21 keys, 10 unresolved | 7P/0F/2S |
| Heffner_etal_2007 | `Heffner_etal_2007_Figure4` | 2 | primary | — | 7P/0F/2S |
| Heffner_etal_2014 | `Heffner_etal_2014_Figure3` | 42 | primary | — | 8P/0F/1S |
| Heffner_etal_2014 | `Heffner_etal_2014_Figure9` | 38 | secondary | 2 collective | 8P/0F/1S |
| Heffner_etal_2014 | `Heffner_etal_2014_Figures10-11` | 25 | secondary | 3 | 8P/0F/1S |
| Koay_etal_1998 | `Koay_etal_1998_Figure7` | 58 | both | 49 keys | 7P/0F/2S |
| Koay_etal_1998_b | `Koay_etal_1998_b_Figure8` | 30 | both (reg. secondary) | 2 keys | 7P/0F/2S |
| Koay_etal_1998_b | `Koay_etal_1998_b_Figure9` | 24 | both (reg. secondary) | 2 keys | 7P/0F/2S |
| Koay_etal_2002 | `Koay_etal_2002_Figure3` | 26 | both (reg. primary) | 2 keys | 7P/0F/2S |
| Wenstrup__1984 | `Wenstrup__1984_Figure8` | 64 | both (reg. secondary) | 4 keys | 8P/0F/1S |
| Jung_etal_2022 | `Jung_etal_2022_TableS1` | 11 | both | per-item crosswalk | 7P/0F/2S |
| Jung_etal_2022 | `Jung_etal_2022_TableS2` | 9 | both | per-item crosswalk | 7P/0F/2S |
| Jones_etal_2009 | `…_PanTHERIA1-0WR05Aug2008.txt` | 5416 | secondary | yes | 5P/1F/3S (finding H) |
| Jones_etal_2009 | `…_PanTHERIA1-0WR93Aug2008.txt` | 4629 | secondary | yes | 5P/1F/3S (finding H) |
| Myhrvold_etal_2015 | `…_AmnioteDatabaseReferencesAug2015.csv` | 113101 | secondary | is the reference layer | 7P/0F/2S |
| Myhrvold_etal_2015 | `…_AmnioteRangeCountAug2015.csv` | 107605 | secondary | yes | 7P/0F/2S |
| Myhrvold_etal_2015 | `…_AmnioteSparseTableAug2015.csv` | 279459 | secondary | yes | 7P/0F/2S |

Row counts and validation results above were re-run independently against the repo's own
`validate_dataset_item()` after the tracks reported, not copied from their reports. The Wenstrup row
was re-run last, after that item landed in a follow-up round: its analysis CSV has 64 rows and it
validates **8P/0F/1S** (`registry_row` SKIP), not the 9P/0F/0S the track reported.

### Not built, with reasons

- **`Frost_Masterton_1994_Figure3` — blocked on method.** The four series use the letters `d`, `e`,
  `v`, `r` as plotting markers and the joining lines run through the glyphs. Five extraction methods
  were tried (tight-template NCC, margin-padded templates, thick-stroke core detection, recall-only
  specificity ranking, montage read-by-eye); the best recall reached d≈8, e≈10, v≈6, r≈11 against an
  expected ~10–12 per series, so the *Didelphis* series would ship a third to a half short. The folder
  was left untouched. Needs a glyph classifier that separates letters from attached strokes.
- **`Nudo_Masterton_1990_IV_Figure2A`** — analysis CSV built (22 rows); the public TSV remains under
  the folder's documented release hold. `validate` fails only on `tsv`, as intended.
- **`Upham_etal_2019_Completed100`** — resolved as a non-TSV item. It is a nexus tree, so it follows
  the `Isler_etal_2008_Tree.nex` precedent; the decision is written into `Upham_etal_2019.README.md`.

### Registry rows staged for owner paste (10 new workbooks)

`Ferrell_etal_2026_Table1`, `MacLean_etal_2014_TableS1`–`S7`, `Sherwood_etal_2020_SuppTable1`–`2`.
Built against the live A–AH Sheet1 header, filling only A, D and N→AH, with B and E–M left grey, plus
a HOW_TO_PASTE sheet. Each build track also emitted a `<Item>_registry_row.xlsx` in its paper folder
for the items it built (Progress stage off blank/`candidate`, plus the proposed data-role changes
noted in the table above). `__ReadMe.xlsx` was **not** modified by this session.

## Reviewer findings worked

Seven findings were raised against the build tracks. Three were real and are fixed; two were false
positives and are rebutted here; two were fixed by the track that raised them.

- **Fixed — Kaskan Figure 3 definitions placement.** The file sat in the folder root while the repo
  convention (and the sibling Figure 2) puts it under `reference_tables/`. Copied, verified
  byte-identical (md5 `7b9ab1cb870adcb08b2968b5202dea7c`), the root copy moved to Trash, the README
  file table updated, and the item re-validated 8P/0F/1S.
- **Fixed — Koay Figure 7 header comment.** It summarised the comparison against the 2021 Bath
  digitisation as "1-23% low", where the README's own numbers are: low for 57 of 58 points, by up to
  24%, median +8.5%, one point reading 2.9% high, with the high-frequency axis agreeing to 2.8%. The
  comment now matches the README.
- **Fixed by the Database track — Jung definitions reference-join Note.** One global constant listing
  all seven crosswalk works was reused for every `*_ref` column in both items. Table S1 cites five of
  them, Table S2 three. Both definitions files now carry per-item crosswalks; verified on disk.
- **Rebutted — "Heffner 1994c Figure 7 cites a grasshopper-mouse paper for the wood rat."** The paper
  itself prints `Heffner and Heffner, 1988a` for both the wood rat and the grasshopper mouse in the
  Table 1 Source column (confirmed against the PDF text layer; the gerbil row's `1988b` anchors the
  column alignment). The build kept the key verbatim, flagged it `CITED-BUT-MISMATCHED` in the row's
  `note`, and raised errata `Heffner_etal_1994_c-E001`/`E002` as `publication_ambiguity`. That is the
  house convention working, not an error.
- **Rebutted — "inconsistent Heffner & Heffner 1982 elephant title."** The two papers genuinely print
  different titles for the same work (same journal, volume 96, pages 926–944): Heffner et al. 1994c
  prints "Hearing the elephant (Elephas maximus): Absolute sensitivity, frequency discrimination, and
  sound localization"; Heffner et al. 2014 prints "Hearing in the elephant: Absolute thresholds,
  frequency discrimination, and sound localization". Both reference CSVs are verbatim-as-printed, which
  is the convention. Worth knowing before joining on citation text.
- **Noted, not fixed — Kaskan Figure 2 transcription guard.** The literal text-layer substring check
  was replaced by a weaker semantic check because the PDF's font encoding made the literal check fail
  on correct rows. The track declared this; it is recorded here so the reduced rigour is visible.

## Caveats carried from the build tracks

- **Rivara public TSV was released by setting `EVOM1_RIVARA_R_GATE`** on an in-session instruction.
  The scientific review the folder README demands has **not** happened. To undo: delete that one TSV
  and re-run `_tools/file_list.R`. Its build also **requires a UTF-8 locale** — under a C locale the
  `fileEncoding = "UTF-8"` reads of the µm³ characters truncate silently and the build fails its own
  assertion. Two Table-vs-Results discrepancies stay open as errata candidates (case E pyramidal count
  1,873,740 vs prose 1,673,740; case E Betz soma 113,125.2 µm³ vs prose 113,146).
- **Rivara was not built as a separate `Betzcells` item.** The registered row and the folder's Table 1
  build are the same locus; the item is now `Rivara_etal_2003_TABLE1`, encoded
  `10.1002%2Far.a.10015_TABLE1`.
- **Kaskan Figure 3 was not re-digitised.** The original working files were not kept, so the frozen
  snapshot reconstructs the capture layer from the published CSV plus a fresh reading of the figure for
  marker shapes, legend wording and arrow labels. It records what was captured; it cannot corroborate
  the coordinates. Two new checks contradict the existing README: panel b resolves **6 of 8** diurnal
  points, not 8 (the README cited 8/8 as the main basis for confidence in the method — that holds for
  panel a only), and the *Saimiri sciureus* panel-a point sits **0.20 log units** from its panel-b twin
  on a shared axis against a ±0.10 tolerance, so that identification is unresolved rather than merely
  uncertain. The data were left alone.
- **Branstetter Table I** — the registry Taxon says 8 individuals; the printed table carries ten. The
  two extra (Vigga, Yakka) come from Szymanski et al. 1999, hence the proposed `Data role = both`.
- **Heffner 1994c Figure 7 is the weakest digitisation in the set, and is quantified rather than
  glossed:** abscissa calibration spread −10.9% to +10.5%; 29 species, of which 13 sit on 8 printed
  dots (8 inferred from a shared dot) and 16 are located only by their printed code. Against the
  paper's own Table 1, dot-anchored species agree to 2.7% but code-anchored ones scatter −40.9% to
  +11.6% (spiny mouse 11.2° vs 19.0°). The README directs readers to
  `Heffner_etal_1994_c_Table1` instead.
- **Heffner 2003 Figure 5** — 62 of 70 plotted points resolved; 8 could not be separated from an
  overlapping neighbour and are absent. The CSV undercounts the figure by that much, and says so.
- **Heffner 1994c Figure 7 right panel** (residuals after partialling out the field of best vision) was
  not digitised: it plots a derived quantity, not a trait.
- **Koay 1998b Figure 9** — only 6 of 24 points are markers; the other 18 are the caption's key numeral
  set at the data position, so crowded numerals (2019, 1411, 23/5) are approximate. Label 20 (ferret)
  is flagged unresolved.
- **Koay 2002 Figure 3** — 12 printed markers resolved; the 14 behavioural points are inferred polyline
  vertices because the curve carries no markers.
- **Wenstrup Figure 8** — 7 printed open circles resolved (one bisected by the y-axis, flagged) plus 57
  inferred polyline vertices, of which 25 are confirmed by a separately resolvable printed dot. Errata
  E001 (CF band 56–59 kHz) is neither contradicted nor resolved by Figure 8 at ±1 dB; no erratum row
  added, no printed value altered.
- **Stephan folder latent defect:** the shared reader degrades a literal `mm³` to the text `<U+00B3>`
  under a C locale, affecting Table61, Table68 and siblings. Table 71 sidesteps it by storing its unit
  as ASCII. Not fixed.
- **Branstetter printed SD is `not_evaluable` on all 23 rows** — it was computed on unrounded
  thresholds and cannot be recovered from printed integers. Reported as not done rather than estimated.
- **`_keys/General/species_key.csv` gained 103 rows** this pass (6 from the printed-tables track, 97
  from the Heffner track), all keyed by `source_publication` = folder name. No existing row was
  touched. The Stephan key already held all 43 Table 71 taxa.
- **No human visual sign-off is claimed on any item built this pass.** All ten staged registry rows
  leave the `Human visual check of snapshot` column blank.

## Run in RStudio next session

1. `_tools/file_list.R` — after pasting the staged registry rows, then verify K/L for each.
2. `_checks/registry_snapshot.R` — refresh the snapshot (233 keys are new since 2026-10-26).

---

# Second pass — 2026-10-31 (owner's new rows)

The owner pasted the 10 staged registry rows and added 19 further rows at the bottom of Sheet1.
Registry is now **910 data rows**; folder audit **476 folders, 416 clean** (407 earlier today);
**862 public TSVs**.

## Registry edits applied by the assistant

**153 descriptive cells** across 33 already-registered items, every one shaded light blue
(`FFD9E8FB`) in Sheet1. Only two kinds of change: a blank cell in columns N-AH was filled, or
`Progress stage` was rewritten because the item is now built. **97 further changes were NOT applied**
and are listed with an `apply?` column in `_checks/registry_edits_applied_20261031.xlsx` - the 7 data
role changes, 2 Taxon corrections, 13 `Human visual check of snapshot` entries (that column is the
owner's sign-off; the proposed text is honest but an AI note does not belong there) and anything that
would overwrite existing curator prose.

Backup before any edit: `_checks/__ReadMe_backup_20261031_pre_edit.xlsx`. Verification: the edited
workbook was compared cell by cell against the backup across all three sheets; exactly the intended
cells differ, and `SOURCE_DISPOSITION` / `AUTO_Public_TSV_FileList` are unchanged. Only
`xl/worksheets/sheet1.xml` and `xl/styles.xml` were rewritten, so formulas, shared strings, theme and
customXml parts are byte-identical.

### Two column-A fixes (whitespace and one character)

- **11 rows carried trailing whitespace at the end of the citation** - a non-breaking space on the
  six Harlow rows, a plain space on Maslow x2, Riddell and Martin x2. It propagated through the
  formula into `Item encoded` as `10.1037%2Fh0073864 _TABLE1`. Trimmed. The two Martin TSVs have been
  orphans since September and need renaming once `file_list.R` reruns.
- **MacLean x7**: the `Item name` formula detects "et al." by testing for the ellipsis character
  `UNICHAR(8230)`. The citation pasted from the staged workbook used three ASCII dots, so a 20-author
  paper resolved to `MacLean__2014_TableS1`. Replaced with the real ellipsis; after recalculation the
  stem becomes `MacLean_etal_2014_TableS*`, matching the folder. This was an assistant error in the
  generated row, not an owner error.

## Builds — 19 new items, all validated

All nineteen have the four-file convention plus a public TSV, and were re-validated independently by
the lead with `validate_dataset_item()` after the tracks reported.

| Folder | Item | Rows | Role | refs CSV | validate |
|---|---|---:|---|---|---|
| Harlow_etal_1932 | `_TABLE1` … `_TABLE6` | 24, 124, 30, 36, 74, 60 | proposed per item | — | 8P/0F/1S each |
| Maslow_Harlow_1932 | `_TABLE1`, `_TABLE2` | 18, 77 | proposed | — | 8P/0F/1S |
| Riddell_Corl_1977 | `_TableII` | 30 | proposed | yes | 8P/0F/1S |
| Chugani_etal_1987 | `_Table1`, `_Table2` | 29, 70 | primary | — | 8P/0F/1S |
| Chugani_etal_1987 | `_Figure2A`, `_Figure2B-D` | 101, 226 | primary | — | 8P/0F/1S |
| Huttenlocher__1979 | `_Figure3` … `_Figure6` | 22, 14, 10, 10 | primary / both | Fig 4 yes | 8P/0F/1S |
| Feinberg_etal_1990 | `_Figure1(a)`, `_Figure1(c)` | 12, 28 | secondary | yes | 7P/0F/2S |

Snapshots use `.xlsx` where the printed table has multi-row headers and `.csv` where it is flat, per
the revised snapshot HOWTO. Two folders were created: `Harlow_etal_1932/` (PDF copied from the stray
`Harlow_Maslow_1932/`) and `Maslow_Harlow_1932/` (PDF copied out of
`Martin_etal_2017/Maslow_Harlow_1932/`, where it was misfiled). Neither original was deleted.

### Findings from these builds

- **Feinberg Figure 1 is fully traced to its primaries**, which was the point of building it.
  Panel (a) replots Huttenlocher's synapse densities: pairing the 12 points by sorted value against
  Huttenlocher's 12 brains aged <=32 y gives mean |difference| 0.084 and max 0.159 x10^8/mm^3, inside
  the summed digitisation error. Ages disagree by up to 1.44 y, and the two worst are exactly the two
  Huttenlocher points inside an axis-break gap where an age cannot be read; Feinberg's single linear
  axis is the better age there. Panel (c) replots Chugani's metabolic rates: bin means reproduce his
  frontal-cortex means to +0.85, +0.24, +0.05 and +0.77 umol/min/100 g. A point-by-point pairing is
  not possible and was not invented. Neither side was adjusted.
- **Huttenlocher Figure 5 is derived, not independent** — it is Figure 3 / Figure 4, confirmed from
  the caption, p. 202 and the arithmetic. Recorded in the definitions Note and README so it is not
  counted as separate evidence.
- **Huttenlocher Figure 4 erratum E001**: adult neuronal density digitises to 1.11 x10^4 against the
  text's 1.32 x10^4. The figure is self-consistent with the paper's own "55 % above" statement; the
  printed adult value is not. Kept as printed.
- **Chugani Table 2**: 55 of 56 printed ratios reproduce from their own row at printed precision.
  The exception (transverse temporal cortex, birth-1 year: 0.853 vs printed 0.86) is erratum E001;
  E002 records the brainstem prose (82 %, 170 %) against Table 2 (0.89, 1.46).
- **Chugani Table 1 row alignment was checked, not assumed**: 10 of 10 table checks pass, including
  16 M / 13 F, 18 on anticonvulsants and age-bin sizes 7/4/12/6 — the bin sizes are what confirm every
  age was keyed into the right patient row.
- Resolved-point counts are reported honestly rather than as figure content: Chugani Figure 2A
  101 of 120, Figure 2B-D 226 of 270, Feinberg 1(c) 28 of 29, Huttenlocher Figures 3-6 all resolved.
- **Feinberg's folder-wide documented skip now has two exceptions**, recorded in a dated box at the
  top of `Feinberg_etal_1990_NOTE.md`. The rest of the folder remains skipped.

### Locale defect is repo-wide, not folder-specific

Four of the seven MacLean scripts fail under a C locale with "invalid input found on input
connection" and run correctly under `LANG=en_US.UTF-8` (42, 567, 6 and 45 rows). With Rivara and the
Stephan shared reader, that is three folders. `Rscript --vanilla` defaults to `LC_CTYPE=C` in this
environment, so **the house instruction should be to run builds under a UTF-8 locale.**

## Still pending the owner

1. **Reopen `__ReadMe.xlsx` (or run `_tools/file_list.R`) so the formula columns recalculate**, then
   the 9 MacLean/Sherwood public TSVs can be written — their scripts now look `Item encoded` up by
   `Item name` and warn rather than guessing. Ferrell's TSV is already written and validates 8 PASS.
2. The 97 held registry edits in `_checks/registry_edits_applied_20261031.xlsx`.
3. `Sherwood_etal_2020_SuppTable1/2`: the registry resolves the item to `SupplementaryTable1` from the
   printed label in column D, while the built files say `SuppTable1`. Rename the files or change D.
4. `Harlow_Maslow_1932/` is now a stray folder duplicating `Harlow_etal_1932/`; decide whether to
   retire it. `Martin_etal_2017/Maslow_Harlow_1932/` held a misfiled PDF for a different paper.
5. Data roles for the nine Harlow / Maslow / Riddell items are proposed in their
   `*_registry_row.xlsx` files; the registry leaves them blank.

---

# Third pass — 2026-10-31 (tooling, after the workbook repair)

The owner repaired `__ReadMe.xlsx` after a scripted XML edit by the assistant corrupted it. All 153
cells that edit had applied survived the repair, verified against
`_checks/registry_edits_applied_20261031.xlsx`. **No further scripted edits to the workbook were
made**; registry changes are now routed through a tool the owner runs.

## `file_list.R` "Non-canonical Sheet1 naming formula(s)" — fixed, and it was never a workbook fault

The error named H2, H66, H130 … H936 — 21 cells. Those are exactly the **shared-formula masters**:
19 spanning a range (`<f t="shared" ref="H2:H65" si="2">…`) plus two single-cell groups (H732, H883).
Every other H cell is a continuation, `<f t="shared" si="n"/>`, which `formula_text()` reduces to ""
and the audit skips. So the masters are the only H cells the audit ever actually tests.

Their formula wraps the expected text in `SUBSTITUTE(SUBSTITUTE(…,"'",""),"’","")` — the
apostrophe-stripping change that produces the `Reep_OShea_1990` Item name matching the renamed
folder. `formula_family()` still carried the pre-apostrophe H expectation, so it rejected all 21.
This is the same drift the script's own comment records for column F on 2026-09-27: the workbook was
updated in Excel and the tool was not.

Fixed in `_tools/file_list.R` (H entry of `formula_family()`, with a comment). Verified on a copy:
867 TSVs indexed, 3 missing formulas filled, existing validated, 910 rows refreshed, 857 matched,
and the refreshed E:L cache resolves `MacLean_etal_2014_TableS*`, `Harlow_etal_1932_TABLE1` and the
other repaired names correctly.

## New: `_tools/registry_apply.R` — CSV in, registry out

Pasting rows by hand does not scale and a generic XML writer corrupts the workbook. This tool uses
the **same openxlsx path `file_list.R` has always used safely** (`openxlsx_compatible_copy` →
`loadWorkbook` → `writeData` → `saveWorkbook`), run from RStudio with Excel closed.

    Rscript --vanilla _tools/registry_apply.R            # dry run
    Rscript --vanilla _tools/registry_apply.R --apply    # write

Reads `_checks/registry_pending.csv` (`action,item_name,column,value,note`). `action=edit` sets one
cell on a row located **by Item name**; `action=new` appends a whole row. It refuses any write to
the generated band B and E–M, backs up first, shades every written cell light blue, re-reads from
disk to verify each one, and is idempotent. Proven end to end on a copy: 213 cells applied and
verified, rerun reported 213 no-ops, `file_list.R` clean afterwards.

`registry_pending.csv` is queued with 329 changes ordered as a work queue — 164 fills, 49
overwrites, 116 held for the owner (data roles, Taxon corrections, and the `Human visual check of
snapshot` column).

## Three more items built

| Item | Rows | Note |
|---|---:|---|
| `Kaskan_etal_2005_References` | 20 | keyed a–t reference lookup for Table S1 |
| `Kaskan_etal_2005_TableS2` | 19 | individual specimens, 5 New World primates |
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1` | 64 | snapshot 66 printed rows; 8P/0F/1S |

Both Kaskan scripts carried a comment deferring their public TSV to "the house file_list.R
pipeline". **`file_list.R` only indexes existing TSVs; it never writes one**, so those two items
could never have received a public copy. Both now write their own TSV from the registry
`Item encoded`, looked up by Item name.

McGuire & Ratcliffe is `secondary` and its traceability is complete: all 29 distinct reference keys
printed in the ESM References column resolve to a verbatim citation, 0 unresolved, plus a 30th row
for `Baron_etal_1996`, the measurement source named in the ESM caption. Reference 14 is listed by
the ESM but cited by no row, recorded in the definitions Note rather than given a row. Erratum E001
(`publication_error`, confirmed): the ESM prints the family label `Rhinolophuidae`; kept as printed.

## Remaining backlog is now small

`Frost_Masterton_1994_Figure3` stays blocked on method (letter markers overlapping the joining
lines). `Heffner_etal_2015_TABLEI` is a duplicate registry row of `Heffner_etal_2015_TableI`, which
has a TSV — registry hygiene, not a build. `Smaers_Soligo_2013_Supplement` is a documented skip. The
rest of the no-TSV list is the 15 name mismatches and the items waiting on `file_list.R`.
