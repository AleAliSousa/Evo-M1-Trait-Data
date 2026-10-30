# Registry + folder audit — 2026-09-28

Scope: the standing periodic audit, run with the question "are there brain-substructure **volume**
datasets to add or fix?" in front. Audit only — `__ReadMe.xlsx` was not edited.

## Overall health: good

| | |
|---|---|
| folders scanned | 286 (262 clean on all three folder checks) |
| registry data rows | 564 (563 named + 1 with an empty Item name) |
| **lost rows vs `registry_snapshot.csv`** | **0** — 563 keys then, 563 now, snapshot is current |
| trailing-`_` keys (blank Item number) | **0** |
| `xml:` / quote-corrupted keys | **0** |
| orphaned public TSVs | **8** (was 43 at the 09-02 audit — `file_list.R` has been run since) |
| Progress stage | 416 FINISHED · 102 blank · 20 BUILT (TSV upload pending) · 17 candidate |

The registry hygiene problems that dominated the August and early-September audits are gone. What is
left is a **wiring** backlog, not a registry backlog.

---

## 1. The headline: a large built-but-unwired volume backlog

`_checks/volumes_unwired_candidates.csv` (written by this audit) lists every registry item whose
public TSV carries volume columns and whose Item name is **not** quoted anywhere in
`__merging_volumes/*.R` (matched case-insensitively, so the `TABLE1` vs `Table1` casing drift does not
produce false hits).

**73 items, of which 60 are not used by any other merge either.** For comparison, the volumes merge
itself currently carries **60 items** (`volumes_compiled.R` tribble: Stephan_collection 42, Zilles 12,
Bush 3, Ashwell 1, Reep 1, Kverkova 1). So the unwired volumetric material is roughly the size of the
merge.

The only change to the merge since 2026-08-19 is that `Matano__1992_Tables1to4` was split into four
per-table items (57 → 60). No new source has been wired into volumes in that window; the intake
program in flight is **sensory/hearing** (`_checks/ReadMe_candidate_rows_20260926.csv` is 32 Heffner /
Koay / Wenstrup / Branstetter / Frost & Masterton rows).

### 1a. Baron et al. 1996 — the register describes 2 tables, the registry holds 19

This is the most consequential discrepancy found. `SOURCE_DISPOSITION_REGISTER.md:80` and
`PROJECT_SCOPE_AND_DATASET_ROADMAP.md` both scope the Baron 1996 `HOLD` to **Tables 10 and 32**, and
`Baron_etal_1996/Baron_etal_1996_overlap_taxonomy_audit.md` still opens *"Tables 10 and 32 contain 272
source rows"*. The registry now carries **19 Baron 1996 items**, all `FINISHED`:

| role | tables | content |
|---|---|---|
| primary, **volumetric** | 8, 10, 13, 16, 19, 22, 25, 28, 30, 32, 35 | net brain / ventricles; five fundamental parts; trigeminal + somatosensory brainstem nuclei; medullary motor and relay nuclei incl. inferior olive; vestibular complex + 4 subnuclei; auditory nuclei (cochlear dorsal/ventral, superior olive); mesencephalon incl. inferior + superior colliculi; cerebellar nuclei (medialis, interpositus, lateralis); lateral lemniscus + medial and lateral geniculate (with CGL dorsal/ventral); accessory olfactory bulb; 8 telencephalic components |
| primary, other | 2, 5 | linear measures; body and brain mass |
| secondary | 36, 39, 42, 45, 48 | cortical / semicortex / bicortex **surface areas (mm²)** → these belong in `__merging_cortical_areas`, not volumes |
| secondary | 51 | brain structure volumes + body/brain weight |

**Eleven volumetric primary tables, nucleus-level, ~272 Chiroptera rows each**, and the completed
overlap audit covers two of them. The two HOLD gates (7 historical taxon concepts listed in the audit;
within-source averaging where subspecies rows collapse to one species) are still open and still
correct — but they now need to be applied to 11 tables, and the overlap/taxonomy audit needs
re-running across the full set before any of it is wired.

This is also the single biggest new-species yield available to the merge: the current core has exactly
one bat (*Pteropus giganteus*, via Ashwell 2020), and the audit found **zero** species × structure
overlap with the core.

### 1b. Stephan-school tables that are simply not wired

These use the same printed structure vocabulary as the tables already in Tier 1, so they are the
cheapest additions after the taxonomy work:

| item | volume cols | note |
|---|---|---|
| ~~`Frahm_Zilles_1994_Table2`~~ | 6 | **RETRACTED same day — it is a duplicate, not an addition.** Value-matched on 2026-09-28: **288 of 288 cells identical** to `Frahm_Zilles_1994_Table1` across all 48 species. The paper prints the six subfields twice; Table 1 adds body weight, HP+HS fibres and the retrocommissural total (which is the stated *sum* of the six Table-2 regions), and Table 1 is already wired as Tier 1 with all six subfield terms mapped. Wiring Table 2 would double-count Tier 1 against itself. Now `EXCLUDED FROM MERGE` in `SOURCE_DISPOSITION_REGISTER.md`. The lesson is the crosspub doctrine's: *the value-identity check has to run before the recommendation, not after.* |
| `Schleifenbaum__1973_Tables1-2` | 16 | medulla / cerebellum / mesencephalon / diencephalon / telencephalon / neocortex — the Stephan fundamental-parts schema |
| `Stephan_Pirlot_1970_Table1` | 13 | same schema plus bulbus olfactorius, palaeocortex+amygdala |
| `Ebinger__1974_Tables3-4` | 25 | total/pure brain volume, ventricle, and the fundamental parts |
| `Pirlot__1981_TABLEII` | 12 | Stephan-style abbreviations (BO, N, RH, PY, S, Di) |
| `Pirlot_Jiao_1985_Table1`, `Kamiya_Pirlot_1980_TABLE1`, `Pirlot_Nelson_1978_TABLE3` | 1–3 | the rest of the Pirlot series |

The Pirlot/Schleifenbaum/Ebinger group needs the same treatment as Baron 1996 — they are largely bats
and insectivores, so expect the same historical-taxon-concept work, and they may share specimens with
the Stephan collection (a Tier-1 question, not a Tier-2 one). **Do not wire any of them before that
is checked.**

### 1c. Primate tables, no taxonomy blocker

| item | volume cols | note |
|---|---|---|
| `Semendeferi_Damasio_2000_Table2` | 8 | whole brain, cerebellum, hemispheres, frontal, temporal, insula. The TSV already carries `Specimen` **and** `taxon_concept` — modern schema, ready for the per-specimen workflow |
| `Smaers_etal_2010_Table1` | 11 | neopallium + frontal lobe, grey and white separately. Check against the wired Smaers 2011 Supplementary Tables for republication before adding |
| `Schenker_etal_2005_Table1` + `Appendix1` | 20 + 11 | frontal cortex by sector (dorsal / mesial / orbital), mean + SE |
| `Smaers_etal_2018_Figure2-data1` | 4 | brain, cerebellum, medial vs lateral cerebellum |
| `deSousa_etal_2009_Table1` | 3 | neocortex, left V1, left LGN — de Sousa 2010 and 2013 are wired, 2009 is not |
| `deSousa__2008_Table4.1 / 5.1 / 5.6 / Suppl.Table5.2` | 3–11 | thesis tables: V1, LGN, area 10, area 13, Vmo, VII, XII. Suppl.5.2 explicitly compares Semendeferi's values to "current" — likely a **secondary** row, check before ingesting |
| `Barks_etal_2014_Fig5A` | 34 | lobe-level GM and WM, left and right separately. Note `Barks_etal_2014_TABLE1` and `_Fig4A` are in `expanded_only_items` (DeCasien-only) but **Fig5A is not**, so it has never been dispositioned either way |
| `Sherwood_etal_2004_unpublishedviaDeCasien` | 2 | thalamus. Distinct item from `Sherwood_etal_2004_TABLEI`, which *is* in `expanded_only_items` |
| `Tschudin__1998_Table2.5`, `MacLeod__2000_APPENDIXI`, `Hakeem_etal_2005_Table2` | 1–5 | single-paper additions |

### 1d. Two long-format items my column scan missed, and they are the best-shaped of all

`Armstrong__1979_Tables1-9` and `Campos_Welker_1976_Table1` are **long** TSVs
(`structure / measure / unit / value`), so a wide-column regex does not see them. Both are built, both
are unwired, and both already carry the specimen-aware schema this project has been moving toward:

- Armstrong 1979: `specimen_code`, `individual_id`, `species_as_published`, `interpreted_taxon`, `sex`,
  `age_years`, `collection`, `section_plane` — thalamic relay-nucleus volumes, with a specimen
  crosswalk that already links `Hylo.-h` / `Hylo.-s` as two hemispheres of one gibbon.
- Campos & Welker 1976: `species_as_published`, `specimen_number`, plus printed-vs-recomputed
  multiplication-factor checks.

Both were built 2026-08-24 and the roadmap records them as **BUILT**, but neither appears in any
`__merging_*/*.R`. They are the natural first customers for the per-specimen + weighted-mean workflow
in `PLAN__weighted_averages_rollout.md`, because they need no de-averaging work at all.

**Followed up the same day, and only one of the two is actually cheap:**

- **`Campos_Welker_1976_Table1` — WIRED.** New Tier-2 team `Campos_Welker`; a long→wide reshape branch
  added to `paper_long()` (the merge's first long-format source); 9 definition-specific standardized
  terms on the Reep precedent. Verified against data before committing: 9 of 9 reshaped columns map,
  18 long rows, **zero collisions** with existing merge cells, 7 new Variables, 1 new species
  (*Hydrochoerus hydrochoerus*). The mm³ unit is confirmed by the source's own internal identity —
  volume × neuronal density = printed total neuron count, ratio **1.0000** for both species — which
  matters because the capybara and guinea-pig forebrain figures look small against Ashwell 2020's
  whole-brain value for *Cavia porcellus* (443.1 mm³ prosencephalon vs 5,415 mm³ net brain). Nothing
  averages across that gap today, since Ashwell contributes only cerebellar terms for this species,
  but it is recorded here as an open cross-source scale question.
- **`Armstrong__1979_Tables1-9` — HOLD, three gates.** Its *shape* is ideal; its *content* is not.
  Armstrong's LGB runs 5–6× below the `Corpus_geniculatum_laterale_Vol.mm3` already in the merge for
  every shared species; two of its five specimen collections are Max Planck Frankfurt (Stephan/Zilles)
  and the University of Wisconsin collection (Bush & Allman), so it is not an independent series; and
  `LGB` = `LGBp` + `LGBm` with two rows per structure under one *Hylobates* `individual_id`. Full
  evidence and clearing conditions: `Armstrong__1979/Armstrong__1979_volume_merge_GATES.md`.

### 1e. Out of scope for the comparative volume merge (recorded so they stop resurfacing)

Human clinical / normative: `Mackes_etal_2020_ERABIS(cortical)` and `_subcortical`,
`Karlsen_Pakkenberg_2011_*`, `Walhovd_etal_2011_normativevolumes`, `Morgan_etal_2014_DataS1`.
Fossil endocasts: `Kochiyama_etal_2018_*` (a separate group if one is ever wanted).
Not volumes despite a volume-looking column: `Seymour_etal_2015/2017` (blood flow),
`Baker_etal_2025_SupplementaryData1` (log10, secondary), `Demirci_etal_2023_Fig.1` (surface),
`Lewitus_etal_2013_TableA1` (ventricle only), `Dunbar__1992_Table1` (secondary compilation),
`HerculanoHouzel_etal_2013_*`, `DeCasien_etal_2017_BrainData`.
`Bauernfeind_etal_2013_Table3` is the paper's own species means — now the reconciliation anchor for
Tables 1–2, deliberately not a data source.

---

## 2. Defects found

### 2a. `NA.tsv` is being written right now — and it is *sensory*, not volumes

`__Public/comparative-data/NA.tsv` exists, is **2,053 bytes, modified 2026-09-27 14:34**, and contains
rodent audiogram data (`low_frequency_limit_kHz`, `high_frequency_limit_kHz`, "R. Heffner and Contos
1989"). This is the known failure fingerprint: a build script's `enc()` lookup returned `NA` because
its Item name has no `Item encoded` in Sheet1, and `write.table(..., paste0(enc, ".tsv"))` silently
wrote to `NA.tsv` instead of failing. It is the same mechanism that made the August row loss silent.

**Severity: high, and it belongs to the active hearing intake, not to volumes.** Find the script that
produced it (a Heffner/Koay rodent-audiogram item from the 09-26 candidate-row batch), register its
row, and add the `stop()` guard so a missing encoding fails loudly. Until then every build of that
item overwrites one shared `NA.tsv`.

### 2b. Seven other orphaned public TSVs

```
10.1002%2Fajpa.1330380234_ResultsText
10.1002%2Far.20829 _Table1            <- stray space before "_Table1"
10.1007%2Fs00429-014-0792-y _Table1   <- stray space before "_Table1"
10.1016%2FB978-012370880-9.00004-9_ResultsText
10.1037%2F0735-7036.102.2.99_Table1
10.1121%2F1.1903415_Table1
10.1121%2F1.3284546_ResultsText
```

The two with an embedded space are a col-C / Item-number formatting slip and will never match an
`Item encoded`; the other five are probably just `file_list.R` lag on recent builds. Five of the seven
are audition DOIs (`10.1121` is JASA), consistent with the same intake.

### 2c. One registry row with an empty Item name

564 non-empty rows, 563 named. One row has content but no Item name, so it can never be resolved by
`read_item()` and is invisible to every merge.

### 2d. Carried forward from the 2026-08-19 session, still open

- **Bush & Allman triple-counting.** 2003 / 2004a / 2004b are the same 55 Wisconsin brains, but the
  merge averages them within the `Bush` team: 70 cells average two Bush tables, **38 average all
  three**. *Alouatta palliata* neocortex grey is 17,233.33 mm³ — the mean of three print precisions of
  one measurement, reported as `n_sources = 3`.
- **Bauernfeind merge-side work** (source side is done): stop collapsing the 43 individuals at
  `volumes_compiled.R:272`; drop the *Pongo pygmaeus* + *P. abelii* lump (Table 3 separates them, so no
  lump is needed); fix the `Brain_Mass.mg` unit defect where the reshape divides by 1000 and stores
  grams under an mg label.
- **Five per-specimen tables still collapsed at extraction**: MacLeod T1/T2, de Sousa 2010 T1,
  Smaers 2011 SuppT1/T2, Barger 2007. All have specimen identifiers.

---

## 3. Actions taken

- Ran `_tools/audit_folders.py`; `_checks/folder_audit.csv` rewritten (286 folders, 262 clean).
- Registry-side sweep run; no workbook edits.
- Wrote `_checks/volumes_unwired_candidates.csv` (73 rows: item, encoded, stage, role, other merge,
  volume-column count and names).
- Refreshed `## Current order of work` in `PROJECT_SCOPE_AND_DATASET_ROADMAP.md`.

## 4. For the next RStudio session

- `_tools/file_list.R` — 8 orphaned TSVs (down from 43; mostly the 09-26/27 hearing builds).
- `_checks/registry_snapshot.R` — snapshot is current (0 drift), rerun after the next registry edit.
- Re-run `Baron_etal_1996`'s overlap/taxonomy audit across **all 11 volumetric tables**, not just 10
  and 32.
