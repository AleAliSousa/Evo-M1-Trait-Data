# Registry audit — 2026-10-28

Audit of `__ReadMe.xlsx` against the paper folders and `__Public/comparative-data/`, followed by a
build pass on unbuilt folders (R 4.5.3, `evom1-r` environment).

## Overall health — GOOD (no data loss); registration backlog is large

- **Registry:** 848 Sheet1 rows = **787 data rows + 61 fully empty formatting rows** at the bottom.
  Sheets: Sheet1 / SOURCE_DISPOSITION / PROPOSED_CHANGES / AUTO_Public_TSV_FileList.
- **Lost rows: 0.** `registry_snapshot.csv` (680 keys, 2026-10-26) has 30 keys absent now; all are accounted for:
  - 21 are the `#n` format change (Item names now carry `Table2#2`; the snapshot key used `Table2 #2`).
  - 9 are renames/splits: `CrileG__1940`→`Crile_Quiring_1940`, `DunbarRIM__1998`→`Dunbar_Bever_1998` (×3),
    `HerculanoHouzelS__2007`→`HerculanoHouzel_etal_2007`, `MangerPR__2012`→`Manger_etal_2012`,
    `Reep_O'Shea_1990`→`Reep_OShea_1990` (×3), `Heffner__2004_Table1`→`_TABLE1`,
    `Babushina_etal_1991_` (blank Item number)→`_Text`/`_Figure1-3`, `Myhrvold…AmnioteDatabaseAug2015.csv`→`…Aug2015`,
    `Ricklefs__2010_SIAppendix`→`_Appendix4`/`_Appendix6`.
  - 140 keys are new since the snapshot. Refresh the snapshot (`_checks/registry_snapshot.R`).
- **Malformed keys: 0.** There are 0 blank Item names, 0 trailing `_`, and 0 `xml:`/quote corruption.
- **Duplicate Item names: 19.** All follow the legitimate `#n` multi-row convention.
- **Folder audit:** 454 folders, 358 clean on all three folder-side checks (`_checks/folder_audit.csv` rewritten).

## Progress stage
FINISHED 418 · blank 147 · candidate 29 · ~190 in assorted BUILT/PREPARED/pending states (about 40 distinct free-text
stage strings). Consider normalising the stage vocabulary to a short controlled list.

## Findings by severity

### A. Built folders with no Sheet1 row (registration backlog) — 31 folders
Products are built (frozen source + derived data), but the folders have no registry row. Most come from the
ManyPrimates / sensory-colour-vision / Nick–Fran intakes:
`Bowmaker_etal_1991`, `Campbell_Tobler_1984`, `Devillard_etal_2003`, `GalánAcedo_etal_2019`, `Gamba_etal_2015`, `Grueter_etal_2013`, `Hardus_etal_2009`, `Hiwatashi_etal_2011`, `Hohmann__1991`, `Jacobs_Deegan_1993`, `Jacobs_Deegan_2003`, `Jacobs_Neitz_1987`, `Jacobs__2008`, `Jacobs__2009`, `Jacobs_etal_2002`, `Jaeggi_etal_2020`, `Kamilar_Cooper_2013`, `MacLean_etal_2014`, `McComb_Semple_2005`, `Modlinska_Stryjek_2016`, `MorroghBernard_etal_2008`, `Norbury_etal_1998`, `Norlén_etal_2019`, `Nunn_Samson_2018`, `Pasquaretta_etal_2014`, `Qiu_etal_2022`, `Sherwood_etal_2020`, `Tan_Li_1999`, `Wiafe_2019`, `Ziege_etal_2016`, `Zimmermann__2017`.
Their public TSVs make up most of the **66 orphan TSVs** in `__Public/comparative-data/`. For example,
Gamba_etal_2015 has 8 orphans, Hohmann__1991 10, Galán-Acedo_etal_2019 7, MorroghBernard_etal_2008 + the OUP
chapter 4 (`9780199213276.003.0004`) 10, and Jacobs colour-vision items about 10.
Action: paste each folder's `*_registry_row(s).xlsx` (generate one where missing), then rerun `file_list.R`.

### B. Public-TSV naming mismatches (4) — carried over from 2026-09-30, still open
- Stray space: `10.1002%2Far.20829 _Table1.tsv`, `10.1007%2Fs00429-014-0792-y _Table1.tsv`.
  The registry's `Item encoded` no longer has the space, so the TSVs need renaming.
- `10.1037%2F0735-7036.102.2.99_Table1.tsv` vs registry `_Table1+Table3` (Owren 1988).
- `10.1121%2F1.1903415_Table1.tsv` vs registry `_TableI` (Schusterman 1974).
- `10.1002%2Fajpa.1330380234_ResultsText.tsv` (Gillette 1973) is still keyed by DOI while the registry uses PMID.

### C. Stale `NA.tsv` in `__Public/comparative-data/`
This is a 2026-09-28 output of `Heffner_Heffner_1992_c/Heffner_Heffner_1992_c_TABLEI.R`, written when the
Item-name lookup returned NA (`TableI`/`TABLEI` case). The correctly named
`10.1016%2F0378-5955(92)90188-S_TABLEI.tsv` now exists. Owner action: move `NA.tsv` to Trash.

### D. FINISHED with no public TSV on disk (8)
`Boddy_etal_2012_brainbodydatabasev2.txt`, `Brodmann__1913_Tabelle1`, `Halley_Krubitzer_2019_Figure1`
(documented skip), `Isler_etal_2008_Tree.nex` (tree, not a TSV item), and `Jorstad_etal_2023_TableS1–S4`.
These are the same set as on 2026-09-30, so the issue is the stage label or the TSV convention, not data loss.

### E. Registered rows without a public TSV: 89 rows in 59 folders
- **Folders with no build at all**: these went into this session's build pass (see below).
- **Folders with a script but unbuilt figure/text items** (~30 rows, mostly Heffner/Koay/Masterton
  audiogram figures marked `candidate`): next figure-digitisation queue.
- **PREPARED, awaiting owner paste/TSV**: Crile_Quiring_1940, Dunbar_Bever_1998 ×3, HerculanoHouzel_etal_2007,
  Hofman__1985, Manger_etal_2012, Reep_OShea_1990 ×3, Haug__1987.

### F. Folders without an R build (51), classified
- **Documented skips / reference-only (OK):** Anderson_Gallup_2015, Gallup__1977, Smith_Jungers_1997, Nunn_etal_2001,
  Henry_etal_2006, Krubitzer_1995, Krubitzer_1998, Krubitzer_etal_1995, Luethke_etal_1988, Luethke_etal_1989,
  Lyon_etal_1998, Jacobs_Williams_2001, Weaver__2005, Smaers_Soligo_2013, deMagalhães_Costa_2009.
- **Built by a central or Python script (OK, but not R-per-item):** Devillard_etal_2003, Jaeggi_etal_2020,
  Modlinska_Stryjek_2016, Norbury_etal_1998, Qiu_etal_2022, Wiafe_2019, Ziege_etal_2016
  (`_tools/build_nick_fran_sources.R`), plus MangoldWirz__1966 and Wirz__1950 (`build_tables.py`) and Mackes_etal_2020 (restricted).
- **Blocked:** McGuire_Ratcliffe_2011 and Shultz_Dunbar_2010 each need one manual supplement download (see the NOTE files).
  Stensaas_etal_1974 and Terborgh__1983 have no PDF.
- **Build pass this session:** the remaining ~25 folders (see "Actions taken").

## Actions taken (2026-10-28 build pass)

Five parallel build tracks covered 22 folders. Result: **26 items built** and **9 documented skips**.
I re-ran every new build script with `Rscript --vanilla` in `evom1-r`; all 26 exit 0. Their warnings are by design
(derived `Item encoded` until the registry row lands; table self-check mismatches are kept as printed and filed as errata).
After the builds, `audit_folders.py` reports 457 folders, **369 clean** (358 before). `__ReadMe.xlsx` was not edited by this session.
Someone edited it concurrently at 23:33, and the scripts re-read it on every run.

| Folder | Item | Rows | Data role | refs CSV |
|---|---|---|---|---|
| Filiminoff_1932 | `Filiminoff_1932_Tablep70` | 52 | primary | — |
| Panepinto_etal_1978 | `Panepinto_etal_1978_Table1` | 44 | primary | — |
| Panepinto_etal_1978 | `Panepinto_etal_1978_Table3` | 65 | primary | — |
| Morelli_etal_2025 | `Morelli_etal_2025_Figure5` | 9 | secondary | yes |
| Kay_etal_2026 | `Kay_etal_2026_DataS1` | 1033 | both | yes |
| Johnson_etal_2002 | `Johnson_etal_2002_Table1` | 113 | both (rank coding original; performance data secondary); liv | yes |
| Siegel__2022 | `Siegel__2022_Appendix` | 52 | secondary | yes |
| Bahney_vonBartheld_2018 | `Bahney_vonBartheld_2018_TABLE1` | 8 | primary | — |
| Bahney_vonBartheld_2018 | `Bahney_vonBartheld_2018_TABLE2` | 8 | primary | — |
| Bahney_vonBartheld_2018 | `Bahney_vonBartheld_2018_TABLE3` | 43 | both (41 secondary rows + 2 "This Study" primary rows) | yes |
| Bahney_vonBartheld_2018 | `Bahney_vonBartheld_2018_TABLE4` | 112 | both (110 secondary rows + 2 own-study primary rows) | yes |
| Carlo_Stevens_2013 | `Carlo_Stevens_2013_TableS1` | 7 | primary | — |
| Carlo_Stevens_2013 | `Carlo_Stevens_2013_Figure2` | 24 | primary (digitized values, approximate) | — |
| Iwaniuk_etal_2000 | `Iwaniuk_etal_2000_Table1` | 45 | both (N + dexterity primary; BW, Arb, Diet secondary) | yes |
| Dom_etal_1971 | `Dom_etal_1971_motormapCST` | 42 | primary (41 rows) + 1 secondary statement (Harting & Martin  | yes |
| Heffner_Heffner_1992_b | `Heffner_Heffner_1992_b_TABLE34.1` | 16 | primary | yes |
| Heffner_Heffner_1992_b | `Heffner_Heffner_1992_b_TABLE34.2` | 20 | secondary | yes |
| Heffner_etal_1999 | `Heffner_etal_1999_ResultsText` | 29 | both | yes |
| Heffner_Heffner_2018 | `Heffner_Heffner_2018_Figure3` | 22 | secondary | yes |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table1` | 53 | both | yes |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table2` | 53 | primary | — |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table3` | 53 | primary | — |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table4` | 636 | primary | — |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table5` | 53 | primary | — |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table6` | 53 | primary | — |
| Glendenning_Masterton_1998 | `Glendenning_Masterton_1998_Table7` | 53 | primary | — |

**Documented skips (NOTE.md plus a references roadmap where the source compiles values from other studies):** Elston_Fujita_2014 (whole folder); Feinberg_etal_1990 (whole folder); Deaner_etal_2007 (whole folder); Reader_Laland_2002 (whole folder); Shultz_Dunbar_2007 (whole folder); Baizer_etal_2014 (whole folder); Changizi_He_2005 ((none) documented skip); Ketten__2012 (Ketten__2012_Text(TTSvalues)); Glendenning_Masterton_1998 (Glendenning_Masterton_1998_Table8).

**Caveats carried from the build agents:**
- Carlo & Stevens 2013 Figure 2 is digitised from a raster image (24 points, about ±0.5 thousand cells / ±0.005 mm). Three occluded markers were inferred, so treat the values as approximate.
- Heffner & Heffner 2018 Figure 3: 5 of 22 points are traced to their primaries. The other 17 remain untraced because the paper prints no per-point sources.
- Morelli 2025 Figure 5: only the 9 labelled points were taken. The 14 unlabelled points were not digitised.
- Kay 2026 Data S1: units are not printed. They were inferred from exact value matches to Stephan 1981 and Bush & Allman 2004. Data S2–S5 were not built.
- Filiminoff 1932: `sex_inferred` comes from German grammatical gender. The means table on pp. 93–94 duplicates the p. 70 table and was not built separately. The area values agree with the 22–29 cm² range that Van Essen & Drury 1997 cite.
- Glendenning & Masterton 1998 Table 8 is a sampling-design table and was skipped. Figures 1–11 repeat Tables 1–7 and were not digitised.
- Johnson 2002 Table 1 was transcribed from page images, cell by cell. The text layer was used only for cell coordinates. Its data role (both) differs from the registry (primary): owner decision.
- Siegel 2022: 51 common-name→binomial mappings are curator judgments pending owner sign-off. The in-folder legacy TSV was left in place as an orphan for the owner.
- Data-role changes are proposed only in the registry_row.xlsx files: Heffner 1992b TABLE34.1 secondary→primary, Heffner 1999 primary→both.
- **Registry defect:** in Bahney 2018, Sheet1 col A for TABLE2–4 carries auto-incremented DOIs (`ar.23729/30/31`). The TSVs are written as `10.1002%2Far.23728_TABLE<N>`. Correct col A, then rerun `file_list.R`.
- **Folder content:** `Iwaniuk_etal_2000/1-s2.0-S0079610725000185-main.pdf` is the Morelli 2025 paper, misfiled. It was left in place.
- `_keys/General/species_key.csv` is now 1214 rows. One agent rewrote the file with pandas while others were appending. Verification: all 31 consumer scripts find rows for their folder, with 0 duplicate (variant, source) pairs and 0 blank accepted names. Quoting may have been normalised. 5 accepted names lack a hub taxid: Arctictis binturong, Dasyprocta prymnolopha, Genetta maculata, Rana temporaria, Sorex hoyi.
- **Tool-layer defects (not patched):** `build_dataset_item()` uses `sys.source()`, which breaks the self-locating header and hides attached tidyverse packages. Every agent validated with `validate_dataset_item()` after a clean `Rscript` run instead. `validate_dataset_item()` also gives a false registry_row PASS for unregistered items, because NA Item-name rows make the subset non-empty.
- Not built: the ~30 `candidate` figure items in folders that already have scripts (Heffner, Koay, Masterton, Wenstrup). Blocked: McGuire & Ratcliffe 2011 and Shultz & Dunbar 2010 (manual supplement download), Stensaas 1974 and Terborgh 1983 (no PDF).

The roadmap's `Current order of work` was refreshed for 2026-10-28.


### Review follow-ups (2026-10-28)
- **Kay 2026 Data S1, Mandrillus:** the frontal (9900 mm³) and non-frontal (20630 mm³) gray-matter values are
  identical to the Data S1 *Macaca* row, and that row equals Bush & Allman 2004 *Macaca mulatta*. Bush & Allman
  *M. sphinx* = 19170 / 52160. This is a likely row copy error in the supplement. Filed as `Kay_etal_2026-E001/E002`
  (proposed) in `Kay_etal_2026/reference_tables/Kay_etal_2026_errata.csv`. `render_errata.R` has not been run.
  Do not merge those two cells until resolved. The value_match notes were corrected to give exact ratios (0.52×, 0.40×).
- **Filiminoff registry row:** the "Flags pre-addressed" text now states the 'A kit 1 s.' percent exception (E001/E002).
- **Siegel 2022 page citation** ("p. 940, PDF p. 4") verified against the PDF page headers.
