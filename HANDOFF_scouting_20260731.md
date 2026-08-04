# Handoff — dataset-expansion scouting & scaffolding (2026-07-31)

Branch: **`claude/evo-m1-trait-data-q50l6x`**. Everything below is committed and pushed there.

## What this session did

Scouted the literature for **new comparative data to extend the existing merges**, checked every
candidate against `__ReadMe.xlsx` (Sheet1) to avoid duplicates, and **scaffolded** the accepted ones
so they are ready to finish locally. Full rationale + citations live in
`SCOUTING_candidate_papers_20260731.md` (read that first).

**Nothing was ingested and no merge script was touched** — the current build is unaffected. Scaffolds
are structure + documentation only, because this environment could not (a) reach publishers / Dryad /
Zenodo (org network policy denied them at the egress proxy) or (b) run R. So the actual data pull,
column confirmation, and merge runs must happen on the OneDrive copy with R.

## Owner decisions locked this session

1. **Heuer MRI is fine** — an earlier turn wrongly dropped it; **reinstated**. The paper the owner
   flagged was **Navarrete**, not Heuer.
2. **Technical innovation** is compiled from **Simon Reader's** data, **not Navarrete**.
3. **Cerebellar folding — OUT OF SCOPE** (owner is a co-author; not in scope now).
4. **Gyrification: keep the two kinds completely separate, never merged.** Zilles-method 2-D GI stays
   in `__merging_gyrification`; Katja Heuer's 3-D MRI folding is useful but housed on its own and never
   combined with Zilles. Method difference verified (3-D convex-hull + folding length/wavelength/depth
   vs 2-D coronal contour). Documented in the GI merge README's exclusion note.

## Status of every candidate

| # | Candidate | Decision | Scaffold | Feeds |
|---|---|---|---|---|
| 1 | Heuer et al. 2018 — MRI brain volumes (39 primates, ~20 new) | IN | `Heuer_etal_2018/` (+ volumes standardized-term template) | `__merging_volumes` as its **own Heuer_MRI team** (never pooled with histological Stephan volumes) |
| 5 | Heuer et al. 2019 — neocortical folding (34 primates, MRI) | IN, **separate** | `Heuer_etal_2019/` | **none** — housed separately, never pooled with Zilles GI |
| — | Reader lineage — technical innovation (2002 classic + 2011 Dryad) | IN | `Reader_etal_2011/` (+ reader `EvoM1_read_innovation_reader.R`) | `__merging_behaviour` (new `Innovation` measure) |
| 2 | Bardo et al. 2016 — hand manipulability (13 anthropoids) | IN | `Bardo_etal_2016/` (+ reader `EvoM1_read_hand_bardo.R`) | `__merging_behaviour` (hand morphology) |
| 4 | Capellini et al. 2008 — mammalian sleep (REM %, daily sleep) | IN | `Capellini_etal_2008/` (+ sleep standardized-term template) | `__merging_sleep` (extends beyond primate-only REM) |
| 7 | Medina-González 2026 — limb excursion, 182 mammals | IN | `MedinaGonzalez_2026/` (+ reader `EvoM1_read_gait_excursion_medina.R`) | `__merging_behaviour` (locomotion) |
| 8 | Corticospinal / CM termination extent | IN | `Corticospinal_terminations/` (compile-from-lit) | behaviour (new `CST_termination_grade`) |
| 9 | Betz cells / L5 corticospinal neurons in M1 | IN | `Betz_cells_M1/` (compile-from-lit) | `__merging_cellcounts` as **regional M1** sub-trait (never pooled with whole-cortex counts) |
| 6 | Cerebellar folding (eLife 2023) | **OUT OF SCOPE** | none | — |
| 3 | Navarrete et al. 2016 — innovation | **EXCLUDED** (owner-flagged) | none | — |

Each scaffold folder has a **README** (source citation + DOI, download/freeze steps, `__ReadMe.xlsx`
registration row, and the exact merge-wiring edits) and a `reference_tables/*_definitions.csv`.

## To finish any source (do on the OneDrive copy, with R)

Per `__HOWTO_build_a_dataset_file.md`, and spelled out in each folder's README:
1. **Download the frozen source** (DOIs/Zenodo/Dryad IDs are in each README).
2. **Confirm exact column headers** — readers/definitions have `TODO(curator)` / `confirm header`
   markers where real names/values go (I could not see the source files).
3. Write the **DOI-coded public TSV** into `__Public/comparative-data/`.
4. **Register** in `__ReadMe.xlsx` (Item name → Item encoded) with the row given in the README.
5. **Wire the merge** (add to the `item_name` vector / add `grab()`+`META`+`TEAM` / add
   standardized-term rows) — only after the source file exists, or the merge errors.
6. Re-run the merge's compile script and check species resolve and no double-counting.

## Known items to verify
- **Heuer 2018 DOI**: `10.1159/000489791` vs `000488136` — confirm on the article page.
- **Heuer 2018 structures**: template maps 9 high-confidence structures onto canonical volume terms;
  complete the remaining ones of the 16 from the SI.
- **Reader** column names, **Bardo** index column, **Medina-González** summary columns,
  **Capellini** sleep-column headers + REM% derivation — all flagged in-file.

## Open thread (not blocking)
- **Which "Navarrete"?** Catalogued #3 is Navarrete et al. 2016, an *innovation* dataset — not MRI.
  "Navarrete MRI data" likely points to a different Navarrete paper (e.g. an Ana Navarrete
  brain-size/volumetric work). Confirm which so the exclusion note is accurate and nothing wrong feeds
  a merge. The Reader technical-innovation compilation is unaffected either way.

## Environment limits during this session (why it's scaffolds, not data)
- Org network policy denied publishers / Dryad / Zenodo at the egress proxy (`connect_rejected 403`).
- No R runtime — merges could not be run or verified here.
- `__ReadMe.xlsx` (binary master) was **not** edited from here on purpose; each README gives the row
  to add so the owner keeps control of that master file.

## Get it onto your machine
```bash
cd ~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data
git fetch origin
git checkout claude/evo-m1-trait-data-q50l6x   # first time; later: git pull
```

## Commit trail (this session)
```
9f1e150 Gyrification README: document Heuer 2019 as kept completely separate from Zilles GI
f9b570d Heuer 2019: lock 'house separately' — method differs from Zilles GI (verified)
495365a Scaffold reinstated Heuer candidates (volumes + neocortical folding)
c9bf7e6 Scouting report: reinstate Heuer (mis-attribution), flag Navarrete
d971285 Scouting report: mark cerebellar folding (#6) out of scope
7378e7f Scouting report: correct cerebellar-folding (#6) entry
89aaeba Scaffold remaining kept candidates: Bardo, Capellini, Medina-Gonzalez, CST, Betz
4bb347e Start Reader technical-innovation compilation
e6d6c88 Add scouting report: candidate papers for dataset expansion
```
