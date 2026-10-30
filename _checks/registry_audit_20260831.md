# Registry + folder audit, 2026-08-31 (build session)

Session goal: build the remaining paper folders, nearest completion first. Audit run first
(`_tools/audit_folders.py` + registry sweep), then two sources built. No edits to `__ReadMe.xlsx`.

## Overall health

- **354 registry rows** (352 non-empty + 2 formatting rows). 168 folders scanned; 145 clean.
- **No lost rows.** The 9 keys "missing" vs `_checks/registry_snapshot.csv` are a suffix-format
  artifact only (snapshot writes `Name #2`, the sweep wrote `Name#2`); sets are identical, 352=352.
  Snapshot is still 14 rows stale → R rerun (`_checks/registry_snapshot.R`).
- **13 orphaned public TSVs** before this session — all are AUTO-column staleness
  (`_tools/file_list.R` not rerun since the 08-24/25 builds), not lost rows. This session adds 2
  more TSVs that will read as orphans until the R rerun.
- No corrupt (`xml:`/quote) keys. 7 duplicate Item names — all the legitimate #n convention.
- Trailing-`_` keys (blank Item number, `read_item()` fails) unchanged from 08-30 audit:
  `Chaplin_etal_2013_`, `Shultz_Dunbar_2010_`, `Stephan_Pirlot_1970_`, `Veilleux_Kirk_2014_`.
- Progress stages: 178 blank, 112 FINISHED, 18 Data readable, 13 NOT STARTED, 9 VERIFIED-ITEM,
  9 candidate, rest as 08-25.

## Built this session (offline Python mirror; R reruns pending)

### 1. `VanEssen_Drury_1997_Table1` — human cortical surfaces (Visible Man)
Folder had only the paper PDF. Built: verbatim `_snapshot.xlsx` (Table 1 sheet + text_V1 sheet),
`.R` (canonical), `.csv` (18 rows: neocortex/5 lobes/sulcal/gyral × L/R + V1 L/R from Results
text), `reference_tables/*_definitions.csv`, public TSV
`10.1523%2FJNEUROSCI.17-18-07079.1997_Table1.tsv`. Checks: sulcal+gyral = totals exactly
(766/803); lobe sums 768/804 = printed rounding. Values are per-hemisphere.
**Citation verified against the PDF: authors are Van Essen & Drury only — "New Collective, A."
in the registry row is confirmed a reference-manager artifact.** Products are named
`VanEssen_Drury_1997_Table1` (the roadmap-intended name); the row still says
`VanEssen_etal_1997_Table1` → rename at next registry sitting (encoded key is DOI-based,
unchanged; `file_list.R` matches by encoded key so the TSV will match even before the rename,
but the .R's own registry lookup warns until renamed).

### 2. `Demirci_etal_2023_Fig.1` — 12-primate MRI surfaces + cerebral volumes
Folder had the paper PDF + publisher's full-res Fig. 1 JPG. SA/V for all 12 species read from the
figure's printed labels (galago 14/3 … human 2115/1053), subject context from Table 1. Built:
`_snapshot.xlsx` (Fig1 + Table1 sheets), `.R`, `.csv` (12 rows), definitions, public TSV
`10.1016%2Fj.neuroimage.2023.120283_Fig.1.tsv`. **SA/V are both-hemispheres totals — halve SA
before wiring into `__merging_cortical_areas`** (recorded in note column, README, definitions).
"Homo Sapiens" as printed → normalized. Colobus common-name mismatch between Fig. 1 and Table 1
handled in the .R join.

### 3. `Chaplin_etal_2013_ResultsText` — BUILT (same day, after owner resolution)
Initially blocked: the registered DOI (10.1002/cne.23215) was the marmoset V1 retinotopy paper.
Identified the intended candidate as **Chaplin, Yu, Soares, Gattass & Rosa 2013, J Neurosci
33(38):15120–15125, doi:10.1523/JNEUROSCI.2909-13.2013** (confirmed from the full text: marmoset
963 / capuchin 6,796 / macaque 11,876 mm²); owner repointed the row's DOI+citation and swapped the
folder PDF the same day. Built: verbatim-quotes + made-a-table `_snapshot.xlsx`, `.R`, `.csv`
(3 rows), definitions, public TSV `10.1523%2FJNEUROSCI.2909-13.2013_ResultsText.tsv`. Transcription
verified against the folder PDF. Caveats recorded per-row: n=1 per species, **mid-thickness (not
pial) surfaces**, single hemisphere (L/R unstated), capuchin retains perfusion shrinkage,
**macaque = reused F99 atlas specimen** (crosswalk before independence claims).
Remaining: Item number (col D) → `ResultsText` (row is still a trailing-`_` key), then R rerun.

### 4. `deSousa_etal_2022_acuityblind.csv` — visual acuity, 120 mammals (BUILT, same day)
Digital-native: `acuityblind.csv` is the paper's own analysis dataset (SI File 1 →
doi:10.17870/bathspa.10275875); no snapshot file, SHA-256
33ca27b69ae20b99950f762c16b37b84e98867d04a9b1659e2d7cb7dd7359baa. MT decoded (A=anatomical 63,
B=behavioral 51, C=blind-coded-0 6) — per-order counts match SI Table 2 (mmc4) exactly; VA range
0–64.28 matches the paper text. Clean product exposes taxonomy + VA + method only; the PanTHERIA
covariate columns stay in the raw file (PanTHERIA's data, never ingest from here). **SECONDARY
compilation** — prefer primaries (V&K 2014 below). TSV
`10.1016%2Fj.neubiorev.2022.104550_acuityblind.csv.tsv`.

### 5. `Veilleux_Kirk_2014_SupplementalTable1` — 91-mammal acuity/eye-size/ecology (BUILT, same day)
Extracted from the Karger supplement PDF (table pp. 1–4) and **verified row-by-row against page
images 1–4**. AD/VA/BM + method (47 anatomical / 42 behavioral / 2 blank as printed) + MRS (12
spp.) + activity pattern + diet + per-column numbered source refs. Footnote markers split to
`footnote_ref` (haplorhine cone-density ², Pettigrew ** on Macropus eugenii, haplorhine * group
exclusion); six as-printed misspellings kept verbatim (Sarcrophilus, dabentonii, fulginosus,
Setonyx, caroliniensis, leoporina) for paper-scoped resolution. TSV
`10.1159%2F000357830_SupplementalTable1.tsv`.
**Dedup:** 78 species shared with the deSousa 2022 item; values identical bar three 2-dp
roundings there — never independent, prefer this primary.

## Queue refresh (evening re-audit, after the day's 5 builds + owner's registry edits)

149/168 folders clean (was 145). **All four trailing-`_` Item numbers are fixed** (owner, today).
Products scan: **no folder has a .R without its product csv.** Stale-stage finding: Genoud 2018,
Granatosky 2018, Heffner & Masterton 1983, Heldstab 2016, Iwaniuk 1999, Matano 1986 + 1992,
Powell 2017, Wimberly 2021 and Mota 2019 TableS1 are all BUILT (R + csv + snapshot) but their
Progress-stage cells still say NOT STARTED — cell updates, not builds. True remaining work:

**Buildable now (source already in repo / web):** Stephan_Pirlot_1970 (paper PDF in folder, 8
registry items, VERIFIED stage — largest nearest-completion block); Shultz_Dunbar_2010 (folder
empty but Source URL now points to the APA .supp file — web-fetchable);
McGuire_Ratcliffe_2011 (Royal Society ESM — web-fetchable); paper-PDF-only folders with blank
stages: Changizi__2003, Changizi_He_2005 (5 rows), Deaner_etal_2006, Johnson_etal_2002,
Sherwood_etal_2003, Weibel_etal_2004 (2 rows), Smaers_Soligo_2013 (supplement PDF also in
folder); Haarlem_etal_2026 (digital-native csv present — needs .R + README + TSV);
Fu_etal_2013 / Rilling_Insel_1998 / deJager_etal_2022 (derived data without frozen source —
invariant-1 repairs); Isler_etal_2008 (folder carries `_NEEDS_PDF_AND_DATA.txt` — data
supplement still missing).

**Needs the EndNote mount:** the 9 VERIFIED rows (Bianchi 2012 ×2, Elston 2000/2001/2006,
Jacobs 1997 ×2, Jacobs 2001 ×2) + 8 candidate rows (Fox & Wilczynski 1986, Hakeem 2005,
Kruska 2014, Kruska & Röhrs 1974, Pirlot & Kamiya 1982 + 1985, Ridgway 1990, Tschudin 1998).

**Blocked/waiting:** Kaskan_etal_2005 Fig 2/3 (+ Changizi 2001, Finlay 2006) on Project Kaskan;
MedinaGonzalez__2026 (owner-blocked); Baron 1996 bat taxon decisions (merge-side).

**Pipeline steps, not builds:** the Data-readable tier (Kaufman 2004 ×18, Bush & Allman ×2,
deSousa 2013); registry stub rows (Hutsler ×4, Deaner 2007, Reader_Laland 2002, Weaver 2005,
Stephan_etal_1987_Table2); VanEssen row rename; stage cells for today's 5 builds; R-side reruns
(5 new .R + `file_list.R` + `registry_snapshot.R`).

## Evening build batch #2 (the "buildable now" list; all offline Python-mirror, R reruns pending)

Built, each with snapshot + .R + csv + definitions + public TSV, all TSVs parse-verified:

6. **`Stephan_Pirlot_1970_Table1`** — 18 bat species × 12 Stephan-school structures + total
   brain + body weight, from the rotated Table 1 (p.205) at 300 dpi, both halves cross-checked;
   **all 36 additivity sums exact**. n=2 for Asellia AND Glossophaga (registry note names only
   Asellia — fix). Baron-1996 specimen-overlap caution in README.
7. **`Haarlem_etal_2026_CFFdataset`** — 280 CFF measurements, 237 species, 16 classes;
   digital-native (SHA-256 recorded); SECONDARY compilation, per-row primary refs kept.
8. **`Weibel_etal_2004_Table1` + `_TableA.1`** — VO2max/body mass (34 species pooled; 58
   study-level rows, internally consistent to 2%). **Published misalignment found in Table 1**
   (chipmunk→guinea-pig block one-row shift, image-verified as printed) — flagged per-row,
   prefer A.1.
9. **`Changizi__2003_Table1`** — ethogram sizes + encephalization + muscle counts (12 orders,
   23 species rows), image-verified; as-printed names kept.
10. **`Sherwood_etal_2003_Table1`** — Betz/Meynert + M1/V1 pyramid soma volumes (25 taxa,
    PRIMARY) + literature covariates (SECONDARY) with per-cell superscript refs disambiguated
    against the page image; Betz_cells_M1-relevant.
11. **`Deaner_etal_2006_Table1`** — 24 genera × 30 procedures cognition ranks (113 cells),
    extracted by word coordinates (`pdftotext -bbox`), grid-verified; **OD=24–26, SO=27** (not
    the caption order). Overlaps Johnson 2002 — never independent.

**Deferred/blocked this batch:** `Shultz_Dunbar_2010_TableS1` + `McGuire_Ratcliffe_2011` — both
supplements blocked to automated fetch (APA binary; RS/PMC reCAPTCHA); one-click URLs left in
folder NOTEs. `Johnson_etal_2002_Table1` — PDF text layer corrupts fractional ranks
("6.5"→"605"); NOTE in folder, build only if it adds over Deaner 2006. `Changizi_Shimojo_2005`
×5 rows — the folder `Changizi_He_2005` holds a *different* Changizi 2005 paper (Complexity,
Changizi & He — no registry row; stub needed); the Shimojo BBE paper's PDF → EndNote list.
`Smaers_Soligo_2013_Supplement` — already a documented skip (folder NOTE: PCA scores only, raw
volumes live in Stephan 1981/Frahm 1982, already built); set its stage cell to the skip.

## Remaining to-build queue (registry rows with no folder), as of the morning audit

- **VERIFIED-ITEM tier (9 rows, pyramidal/dendrite scaffold):** Bianchi 2012 (Tables 1–2),
  Elston 2000 / Elston et al. 2001 / 2006, Jacobs et al. 1997 (Tables 1–2), Jacobs et al. 2001
  (Tables 1–2). Sources are PDF tables — **need the EndNote mount** (`~/Documents/References.Data`)
  to pull the PDFs; none are in the repo.
- **Candidate tier (9 rows):** Fox & Wilczynski 1986, Hakeem et al. 2005, Kruska 2014,
  Kruska & Röhrs 1974, McGuire & Ratcliffe 2011 (ESM — web-fetchable from Royal Society),
  Pirlot & Kamiya 1982 / 1985, Ridgway 1990, Tschudin 1998. All list EndNote PDF filenames in the
  Source URL column — same mount needed (McGuire ESM is the one web-accessible exception).
- **Kaskan_etal_2005 Figure2/Figure3** — waits on Project Kaskan (consistent with the other
  Kaskan-stage rows).
- Folders lacking a registry row (Excel sitting, unchanged from 08-30): Hutsler ×4, Deaner 2007,
  Reader_Laland 2002, Weaver 2005 stubs, Stephan_etal_1987_Table2.

## Actions for Alexandra (next registry / RStudio sitting)

1. Excel: rename `VanEssen_etal_1997_Table1` → `VanEssen_Drury_1997_Table1`, fix its citation
   (drop "New Collective, A."); set Progress stage + Snapshot cells for the two builds; the
   standing item-number fixes (Chaplin/Shultz_Dunbar/Stephan_Pirlot/Veilleux_Kirk) and stub
   registrations from the 08-30 list.
2. RStudio: run `VanEssen_Drury_1997_Table1.R` and `Demirci_etal_2023_Fig.1.R` (expect
   byte-identical CSV/TSV to the Python-mirror outputs), then `_tools/file_list.R` and
   `_checks/registry_snapshot.R`.
3. Mount `~/Documents/References.Data` in a future Cowork session to unblock the 18-row
   EndNote-PDF queue above.
