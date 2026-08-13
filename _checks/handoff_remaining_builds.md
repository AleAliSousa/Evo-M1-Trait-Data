# Handoff — finish processing Evo-M1-Trait-Data

> **This file answers "how do I finish this folder?"** — the build workflow, what each folder still
> needs, and the QA pass. It assumes the source is already wanted.
>
> **`SCOUTING_AND_SCOPING.md` answers "should this source be here at all?"** — candidate papers,
> curator/owner inclusion decisions (several are ❌ EXCLUDED or 🚫 OUT OF SCOPE), tier ranking, and the
> taxonomy/backbone design note that gates non-mammals.
>
> Deliberately separate: inclusion is a **decision record** that should stay stable and citable; this
> is a **working plan** that churns as batches land. **Check the inclusion decision there before
> building anything here** — a folder with a PDF in it is not evidence that it was wanted.

Master plan for completing the dataset. Work in
`~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data`.
This is large (~45 folders to build/finish + ~41 to QA), so run it in **batches across
fresh sessions** — do a handful of folders, verify, report, repeat. Phase 1 first, then 2→3→4.
Re-run the variable catalog after each batch.

## The workflow every folder must end up with

Mirror these finished examples before building: `Stephan_etal_1982/` (single `species`
column with grade/family/Mean label rows, superscripts), `Frahm_etal_1982/` (single
`species` column, n in parentheses, blank rows between groups), `Stephan_etal_1981/` (wide
master table from the curated CSV), `Baron_etal_1988/` (simple volumes).

Each paper folder needs: the **paper PDF**; a **journal-faithful snapshot**
`<Folder>_Table<N>_snapshot.xlsx`; a **reformat R** `<Folder>_Table<N>.R` (reads ONLY the
snapshot → analysis CSV + a DOI/PMID-named TSV in `../__Public/comparative-data/`, looked up
from `__ReadMe.xlsx` `Item encoded` by `Item name`); a **comparison** R in `comparison/`
(snapshot ↔ the formatted CSV, matched by species on EITHER the paper name OR canonical name,
each CSV row resolved once so no phantom duplicates); `reference_tables/<...>_definitions.csv`
(schema `Code, Definition, Structure, Measure, Stat, role, taxon, Reference, Note, Source Note`);
and a short README.

**Snapshot principle (important):** look at the *specific* printed table and reproduce ITS
layout — do not impose one template. Per-table choices: single `species` column vs hierarchy;
`n` as a column vs in parentheses; group/family/Mean rows only where the journal prints them;
keep superscripts (Unicode) where present, translate to `former_name` in the R step. Find the
table inside the Adobe PDF→Excel export (`*.xlsx` in the folder; it's split across
generically-named "Table N" sheets — search for known values). Take cell **values from the
formatted `comparison/*.csv`** (laid out journal-style); the snapshot's job is the faithful
layout for eyeballing against the PDF. Snapshot the volumes; recompute size indices downstream.

**Verify** each build with a Python mirror of the R logic (R isn't in the sandbox): correct
species count out of the reformat, and 0 value mismatches in the comparison.

**Gotchas:** read CSVs with a latin1 fallback (Mac-Roman bytes); strip thousands-separator
commas; never write the formula columns of `__ReadMe.xlsx` (cols 5–13 — the user maintains
them); set `Item number` exactly as printed; keep the PDF in the folder.

---

## Phase 1 — the 4 primate-compilation source papers (do first)

These feed `Stephan_primates.csv` and each already has its comparison CSV / Adobe export:

1. `Zilles__Rehkamper_1988/` — great-ape (Pan, Gorilla, Pongo) telencephalon/brain-structure volumes. `comparison/Zilles_1988.csv`.
2. `Bauernfeind_etal_2013/` — insular-cortex volumes (primates). `comparison/Bauernfeind_2013.csv`. Units were converted (orig kg/g/cm³ → g/mg/mm³).
3. `Matano_etal_1985_a/` & `_b/` — the "Pons"/brainstem source (raw `Matano_1985a/b.csv` + Adobe exports). Check which part has the pons data; process that one (both if both carry measured volumes).
4. `Frahm_Zilles_1994/` — hippocampal-region volumes (Insectivora + Primates). `comparison/Frahm_1994.csv`.

(Registry rows already exist for all four; Bauernfeind appears twice — rows 9 and 109 — consolidate.)

## Phase 2 — finish the PARTIAL folders (27)

**Ready to build (comparison CSV present; just need snapshot + R + definitions + README)** —
same pattern as Phase 1: `Baron_etal_1990`, `Frahm_etal_1984`, `Frahm_etal_1997`,
`Frahm_etal_1998`, `Sherwood_etal_2005`, `Stephan_etal_1984`, `Karbowski__2007`,
`Kaufman__2004` (+ the Phase-1 four). These are mostly Stephan/Frahm/Baron-series single-structure
volume tables — reuse the Stephan_etal_1982 / Frahm_etal_1982 template.

**Has a snapshot, needs R + comparison + definitions:** `Collins_etal_2010`,
`Collins_etal_2016`, `Young_etal_2013`.

**Has data CSV only, needs snapshot + R + comparison + definitions:** `Burger_etal_2019`,
`Chen_Wiens_2020`, `Haarlem_etal_2026`, `Mota_etal_2015`, `Sherwood_etal_2004_I`,
`Turner_etal_2016`.

**Has an R script but no snapshot (investigate / regularize):** `DeCasien_Higham_2019`,
`Mota_etal_2019`.

**Has definitions only:** `Lewitus_etal_2013`, `Lewitus_etal_2014`.

**Effectively done — just run its R to emit the CSV/TSV:** `Stephan_etal_1981` (snapshot +
reformat R + comparison + definitions already built this session).

## Phase 3 — build the RAW-ONLY folders (18, PDF/data only)

`BarbeitoAndres_etal_2019`, `Brodmann__1913`, `Fu_etal_2013`, `Genoud_etal_2018`,
`Granatosky__2018`, `Heffner_Masterton_1983`, `Heldstab_etal_2016`, `HerculanoHouzel_etal_2013`,
`Isler_etal_2008` (multi-table — endocranial volumes database), `Johansen_etal_2024`,
`ManyPrimates__2022`, `Smaers_Soligo_2013`, `Smaers_etal_2018`, `Wilman_etal_2014`,
`Wimberly_etal_2021`, `Winkler_Bryant_2021`, `Young_etal_2013_b`, `Zilles_etal_2013`.
Several are behavioural/ecological (Granatosky, Heldstab, ManyPrimates, Wilman, Wimberly,
Winkler) — same workflow, the "table" is just behavioural/ecological traits. Some have no
registry row yet (Smaers_Soligo_2013, Smaers_etal_2018) — add one (don't touch formula cols).

## Phase 3b — registry rows with **no `Item number`** (8)

Surfaced 2026-08-12 while debugging a `volumes_compiled_select.R` failure. These rows exist in
`__ReadMe.xlsx` with a citation and a DOI but **col D (`Item number`) is empty**, so the K/L formulas
render `Item name` / `Item encoded` with a **bare trailing underscore** (`Ebinger__1974_`,
`10.1007%2FBF00522811_`). Nothing looks broken — A, F, J and the K/L formulas are all intact and the
workbook opens fine — but the row can never resolve to a TSV, and any script that asks for it dies
with *"no encoding (not in `__ReadMe.xlsx` 'Item name' and no `enc_override`)"*.

**Diagnostic (cheap, run it before any merge):** sweep the cached `Item name` / `Item encoded` for a
trailing `_`. On 2026-08-12 that returned **9** rows. One — `Matano__1986` — was a real breakage
(its `10.1159%2F000156277_TableI.tsv` was already exported and the merge had previously cited it);
D185 has been restored to `Table I` and verified by `soffice` recalc. The other 8 are below: the row
was registered from the citation and the item never got built.

The tell that separates "broken" from "not built yet" is an **orphaned TSV in
`__Public/comparative-data/` matching the DOI prefix** — that filename hands you the item number that
went missing. None of the 8 has one (and no TSV in the folder ends in a bare `_`, so nothing was ever
built against a blank D).

| Row | Folder | What's there now | Pattern | What it needs |
|---|---|---|---|---|
| 65 | `Ebinger__1974` | PDF + `comparison/*.xlsx` (Adobe export, sheet `Table 1`) | **Phase 2 ready-to-build** | snapshot + R + definitions + README, then set D |
| 207 | `Schleifenbaum__1973` | PDF + `comparison/Schleifenbaum Canis brain region volumes.xlsx` | **Phase 2 ready-to-build** | same (export was cloud-only at time of writing — materialise it first) |
| 24 | `Baron_etal_1996` | PDF only | **Phase 3 raw-only** | Chiroptera *book* (Birkhäuser), macromorphology + brain-structure tables + atlases. Multi-table, so it needs **one registry row per table**, not one for the book. `DOI (or Alt)` is `#N/A` — assign an ISBN-based identifier before exporting |
| 193 | `Navarrete_etal_2016` | PDF only | **EXCLUDED — leave alone** | candidate #3 in `SCOUTING_AND_SCOPING.md`: ❌ excluded, technical innovation is sourced from **Reader** instead (curator decision 3). Empty D is **correct**. Do not build. (Distinct from Navarrete **2018**, also excluded, owner-flagged, scaffold deleted — don't conflate them) |
| 194 | `Nguyen_etal_2019` | PDF only | **Phase 3 raw-only** | comparative neocortical neuromorphology (Sherwood/Manger/Hof) → cell-count / morphology side. Not scouted, no inclusion decision on record — get one before building |
| 190 | `MedinaGonzalez_2026` | README + `reference_tables/*_definitions.csv` | **blocked, not stalled** | scaffold done; needs the **Zenodo download** (`10.5281/zenodo.15425733`) — egress proxy blocked it in the scaffolding session. Pull locally, check the licence, then write `10.1002%2Fjez.70069_Data.tsv` and set D |
| 200 | `Olkowicz_etal_2016` | README + `TableS1.R` + definitions | **blocked, deliberately** | birds — the dataset behind the "Premature — non-mammal" hold in `SCOUTING_AND_SCOPING.md` Part 1. Hard-blocked on the de-MDD resolver (Part 2, do-first step 4). Leave D empty until `Class` gating exists — setting it early would publish a row the resolver silently drops |
| 288 | `Weaver_2005` | PDF + `Weaver_2005_NOTE.md` | **documented skip — leave alone** | no extractable table (Table 1 is qualitative; CQ is a derived index, not transcribed). Its data is `Weaver_2001`, already built. The empty D is **correct here** — do not "fix" it |

So: **2 ready to build**, **2 raw-only**, **2 blocked on prerequisites**, **2 correctly empty** (leave
them alone). Half of these are cheap to get wrong the same way — an empty `Item number` *looks* like a
to-do, and for four of the eight it is the recorded answer. **Check `SCOUTING_AND_SCOPING.md` for an
inclusion decision before building any of them**: that file, not this one, is where "should this source
be in the dataset" is settled.

When you do set D, follow the Gotchas above — `Item number` exactly as printed, and never write the
formula columns (E–M) by hand. If you have to repair col D at the XML level rather than in Excel, the
method and its traps are in the project memory note *"__ReadMe.xlsx col D empties itself"*: check
`sharedStrings.xml` first (the item string usually already exists, making it a one-cell edit), hand-
update the cached `<v>` of K and L, leave `<f>` alone, and verify with
`soffice --headless --convert-to csv` — that recalc is what proves the cached values equal what Excel
would compute.

**Watch it recur.** Col D on this workbook has emptied itself at least once with no edit from us; the
OneDrive/Excel rewriter is the suspect (same rewriter documented under "never write
`<t xml:space="preserve">`"). Re-run the trailing-`_` sweep at the close of each batch alongside the
variable catalog.

## Phase 4 — QA the 41 already-built folders

Check each for: (a) the snapshot actually **looks like the source table** (the Smaers 2017
problem below is the prototype — don't assume "built" means "right"); (b) definitions use the
standard 10-column schema with `role` + `taxon` filled; (c) the comparison runs and matches;
(d) the registry row is correct (table number as printed, taxon, role, main trait). Several
built folders use older **`.csv` snapshots** rather than the journal-faithful `.xlsx` style
(`deSousa_etal_2010`, `deSousa_etal_2013`, `MacLeod_etal_2003`, `Smaers_etal_2017`,
`Smaers_etal_2011`, others) — flag/regularize these to the current convention.

Built (41): Andelin 2019, Avelino-de-Souza 2025, Barger 2007, Baron 1983/1987/1988, Burish 2010,
Bush & Allman 2003 / 2004 a&b, Caspar 2022, Changizi 2001, Dos Santos 2017/2020, Eagleman & Vaughn
2021, Falcone 2019, Finlay 2006, Frahm & Stephan 1982, Garwicz 2009, Heffner & Masterton 1975,
Heiss 2004, Herculano-Houzel 2015 (×2 folders) & 2020, Iwaniuk 1999/2001, Jardim-Messeder 2017,
Karl 2024, Kverková 2018, MacLarnon 1996, MacLeod 2003, Powell 2017, Semendeferi 1998/2001/2002,
Smaers 2011/2017, Stephan 1982/1987, de Sousa 2010/2013.

---

## Special: rebuild Smaers et al. 2017 (split one mixed table into two)

The current `Smaers_etal_2017` snapshot is wrong — it kept only the cortical **volume**
columns; the source supplemental table also carries cortical **surface areas**, and the two
shouldn't share one sheet. Rebuild as **two parts**, same 4 cortical regions throughout
(Primary visual, Prefrontal, Other cortical association, Frontal motor):

- **Part 1 — volumes:** the 8 gray/white columns (4 regions × {gray, white}). Source values in
  `Smaers_mmc1.xlsx` (sheet "Table 1") / the current data.
- **Part 2 — surface areas:** the 4 region surface areas. Source values in
  `cortical surfaces Brodmann 1909 in Smears et al 2017.xlsx` (cols: Primary visual, Prefrontal,
  Other cortical association areas, Frontal motor).

Produce `Smaers_etal_2017_TableS1part1_snapshot.xlsx` +
`Smaers_etal_2017_TableS1part2_snapshot.xlsx`, each with its own reformat R →
its own csv/tsv, its own definitions block (Measure = `Volume` for part 1, `surface area` for
part 2), and its own comparison. Add **two rows to `__ReadMe.xlsx`** (Part 1 and Part 2), each
with the correct `Item number`, `Measure type`, and `Main Trait(s)`; keep the existing Smaers
2017 row's identifiers consistent. Make each snapshot look like its half of the printed
supplement.

## Closing each batch

Re-run `_keys/build_variable_catalog.R` so `_keys/variable_catalog.csv` and
`_keys/variable_catalog_compatibility.csv` absorb the new/standardized `definitions.csv` files;
report the updated variable count and poolable-group counts. Also keep
`__ReadMe.xlsx` current (Taxon group / Data role / Measure type / Main Trait(s) / table number
for every new row), and add the paper PDF to any folder missing it.

## State at handoff

- **2026-08-12:** `Smaers_etal_2011_SupplementaryTable1` wired into `volumes_compiled_select.R` —
  total frontal lobe **grey** matter, 19 species incl. *Homo*, grey-only/whole-lobe scope. Everything
  it needed already existed except the tribble row. Note the finding that prompted it: Smaers 2017
  `prefrontal_gray` + `frontal_motor_gray` are **not** a partition of the frontal lobe (they sum to
  ~36% of it), so total frontal grey cannot be rebuilt from the subregions — see
  `__merging_volumes/Smaers_frontal_grey_FINDINGS.md`. Same session: `__ReadMe.xlsx` D185 repaired
  (Phase 3b above), and the Smaers 2011 orangutan identified as **YN85-38 = *Pongo abelii*** (a
  specimen swap out of Smaers 2010's "Harry", not a re-measurement) — `Pongo_specimen_note.md` §4.
- Done this session: Stephan 1981 (master table), plus prior: Frahm & Stephan 1982, Stephan 1982
  (AOB), Baron 1983/1987/1988, de Sousa 2010/2013, MacLeod 2003, Smaers 2017 (volumes only — to be
  re-done per above).
- Size indices (Stephan/Frahm/Baron) = 100 × observed/expected, expected from a fixed-slope
  log–log reference line through the basal-Insectivora centroid (per-structure slope from each
  paper's Methods; AOB = 0.57). Recompute downstream with Stephan-1981 body weights; don't OCR
  faint index columns.
- `_checks/check_Zilles_Rehkamper_1988_provenance.R` flags Pongo data that leaked
  anachronistically into pre-1988 datasets — relevant when auditing Zilles & Rehkämper 1988 and
  the pre-1988 volume papers.
- Catalog: `_keys/variable_catalog.csv` (one row per measured variable) +
  `_keys/variable_catalog_compatibility.csv` (poolable groups by structure × measure-class),
  built from per-folder `definitions.csv` + `_keys/anatomy_reference.csv`.
