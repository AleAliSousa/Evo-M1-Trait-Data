# Sensory (audio-visual) dataset — intake note

**Written 2026-08-14.** Status: **scouted and copied in, not curated, not built, not merged.**
Nothing here is wired to any `__merging_*` script or to the Shiny app.

---

## 1. What arrived and where it came from

Source (an **archive — do not edit it**, by owner instruction):

```
OneDrive-UniversityofBath/Projects Kaskan Cortical Areas & Other Shared/
  Project Audio Visual evolution/
```

Copied verbatim to:

```
____Sensory_audiovisual/_incoming_Bath_archive_20260814/
```

The copy is byte-faithful. Excluded from the copy: `.DS_Store`, an empty `.Rhistory`, and a macOS
alias file (`Visual_Auditory_Heffner alias`, 960 B) pointing at a Dropbox folder
`~/Dropbox/COLLABORATIVE/Orlin/Visual_Auditory_Heffner` that is **not** in the copied tree — the
analysis project this database fed is somewhere else and was not captured here. 49 files, ~32 MB,
verified identical to source by checksum-of-checksums.

Provenance in one line: the original goal, per `read me databasing.txt`, was *"the biggest sensory
database for mammals"*, feeding a project called **Visual_Auditory_Heffner**. Databasing rules were
written 2020-07-06 (A. de Sousa); the last data edits are 2022-10-13. Nothing has moved since.

---

## 2. What the data actually is

Three generations of the same material, in this lineage:

| generation | file | shape | date |
|---|---|---|---|
| raw per-source extractions | `Part 2 Hearing data/hearing data.xlsx` | 10 sheets, one per source (Koay 1998, Heffner & Heffner 1992/1992a, Heffner 1998/2004/2018, Mooney 2012, Ketten 2012) | 2021-07-27 |
| per-trait working table | `Part 1 Visual Acuity/Visual Acuity database in progress.xlsx` (`max VA`) | 123 rows, 118 spp, 12 cols | 2022-10-13 |
| **integrated table** | `Sensory Data.xlsx` / `Sensory Data (1).xlsx`, sheet `Data` | **167 rows, 157 species, 44 variable+reference columns** | 2022-04-26 / 2022-10-13 |

`Sensory Data.xlsx` and `Sensory Data (1).xlsx` are **identical in content** — all six sheets, zero
differing cells; only the file mtime differs. Keep one, drop the other at curation time.

`Sensory Data` is the furthest-along artefact and is the one to build from. It already has the
structure this repo wants: a `Data` sheet, a `Metadata` sheet (variable → definition → source), a
`Reference` sheet (53 short-code → full citation), a `Rules` sheet (4 stated curation rules), a
`Notesissues` sheet (4 open issues, flagged by the original curator), and a `Primary refs` sheet
(180 rows, **almost entirely empty** — the primary-reference back-fill was started and abandoned).

**Traits present** (fill counts out of 167 rows):

| trait | n | trait | n |
|---|---|---|---|
| Maximum visual acuity (c/deg) | 127 | Best frequency (kHz) | 83 |
| Highest audible freq @60 dB SPL (kHz) | 90 | Functional interaural distance (µs) | 78 |
| Lowest audible freq @60 dB SPL (kHz) | 84 | Sound localization threshold (deg) | 45 |
| Best sensitivity (dB) | 83 | Binaural phase cue | 36 |
| Binaural intensity-difference cue | 36 | Trophic level | 26 |
| Width of field of best vision (deg) | 24 | Hearing range (octaves) | 22 |
| Binocular field (deg) | 20 | Highest freq using binaural phase cue (kHz) | 8 |
| Monaural pinna cues | 1 | | |

Every trait column is followed by its own `Reference` (and often `Comment`) column — the
one-reference-per-value discipline is already there, which is unusually good for an unfinished table
and is most of the reason this is worth ingesting rather than re-collecting.

---

## 3. Defects found — read before using any value

### 3.1 ⚠️ The visual-acuity column in `Sensory Data` is off by one row for 24 species

This is the serious one. Auditing `Sensory Data` sheet `Data` against its own upstream table
(`Visual Acuity database in progress`, sheet `max VA`) species-by-species:

- 102 of 127 VA values agree with the value the upstream table assigns to that species
- **24 are displaced** — the value sitting on species *i* is the upstream value of species *i−1*
- 1 species (*Macaca fuscata*, 46.8 c/deg) carries a VA value with no upstream counterpart

The displacement is a contiguous run in the alphabetical head of the table, **Excel rows 4–33**
(*Alouatta caraya* … *Cuniculus paca*), plus three isolated cases further down (rows 75, 120, 134).
Worked example: *Aonyx cinerea* carries 59.61 c/deg, which upstream belongs to *Alouatta caraya*;
*Aonyx cinerea*'s own values are 2.0 / 2.2. The signature is a **sort or paste that moved the value
block relative to the species block** — the classic Excel "sorted the selection, not the sheet"
error. The three later rows (*Macaca fuscata*, *Phocoena phocoena* 2.1 vs 2.7, *Rattus norvegicus*
1.5 vs 1.6) do not fit that pattern and are probably separate edits.

Full per-row audit: **`sensory_VA_offset_audit.csv`** in this folder (127 rows; `status` ∈
`agree` / `MISMATCH` / `species_absent_from_Part1`, with the upstream value and the species the
displaced value actually belongs to).

**Do not merge the VA column until this is resolved against Veilleux & Kirk 2014 / Kirk & Kay 2004
directly.** Resolving it upstream-of-both is better than reconciling the two spreadsheets against
each other — the upstream table also carries `PRIMARY SOURCE 1/2` and `SPECIES IN PRIMARY REFERENCE`
columns that `Sensory Data` dropped, so the fix and the primary-reference back-fill are the same job.

### 3.2 Reverse-engineered figure values are mixed in with published values

`read me databasing.txt` and the `NOTES ABOUT REFERENCES` sheet both record it: values with 4+
decimal places were **digitised off figures**, chiefly Koay et al. 1998 Fig. 6 and Heffner 2018.
They are visible in the raw sheets (e.g. `6.11869813214261` kHz) and some propagated into
`Sensory Data`. These need a `value_origin` flag (`published` / `digitised_from_figure`) rather than
silent inclusion; in the repo's terms, a digitised value is a **snapshot-from-a-picture** and its
`.R` must be reproducible from the figure extraction, not hand-typed.

### 3.3 The `Notesissues` sheet holds 4 unresolved curator flags

Carried over verbatim, all with an empty `Resolved/not` cell: sound-localization data for one
species in Heffner & Heffner 1992a; a highest-frequency conflict between Koay et al. 1998 and its
primary references; visual acuity for "House mouse" in Veilleux & Kirk 2014; and unclear values in
the Mooney 2012 block. These are the original curator's own open questions — treat them as the
first work items, not as new findings.

### 3.4 Species-level structure is not yet decided

167 rows / 157 species: 10 species appear more than once. Per the stated rules that is intentional
(one row per value, and separate rows for air vs water substrate) — but `Substrate` is filled for
only 20 of 167 rows, so the multi-row species are not consistently distinguishable. The repo's own
convention (analysis CSV = one tidy row per species, or per individual, declared) forces a decision
here: long-format with a `value_id`, or wide with a documented aggregation rule.

### 3.5 Duplicates and non-data

- `Sensory Data.xlsx` ≡ `Sensory Data (1).xlsx` (§2) — one is redundant.
- `EXAMPLE ORGANIZATION/` holds DeCasien & Higham 2019, DeCasien et al. 2017, DeCasien et al. 2018
  — kept in the archive only as a *formatting exemplar*, not as sensory data. DeCasien & Higham 2019
  MOESM3 is **already in the repo** at `DeCasien_Higham_2019/` (same 9 sheets, same dimensions; the
  1-byte file-size difference is zip metadata, not content). Do not create a second registry item.
- `old work/PanTHERIA_1-0_WR05_Aug2008.{csv,txt}` — the public PanTHERIA release, plus
  `Databasing.Rmd`, a 2019 teaching-style `merge()` demo joining VA/hearing to PanTHERIA on
  `Species` with no name harmonisation. Historical only; the repo has a real resolver.
- `Meeting 23 July/` (2020) duplicates the two working files at an earlier state.

---

## 4. How it relates to Evo-M1-Trait-Data

**Taxonomic overlap is the headline: 48 of 157 species (31%) are already in
`_keys/species_reference.csv`** (215 spp). A further 17 match at genus level only. 92 species are new
to the repo — dominated by taxa the M1 dataset has little of: cetaceans and pinnipeds
(*Tursiops*, *Delphinapterus*, *Inia*, *Phocoena*, *Eschrichtius*, *Callorhinus*, *Enhydra*,
*Eumetopias*), bats (*Eptesicus*, *Desmodus*, *Carollia*, *Artibeus*, *Macroderma*, *Eidolon*),
rodents (*Cynomys*, *Dipodomys*, *Geomys*, *Ellobius*, *Lemmus*), and ungulates.

Three consequences:

1. **This is a coverage expansion, not just a trait expansion.** Ingesting it roughly doubles the
   non-primate mammal breadth of the species backbone. That is a taxonomy-resolver job before it is
   a merge job.
2. **It contains non-mammals** — at least *Anas platyrhynchos*, *Columba livia domestica*,
   budgerigar in the hearing sheets. The non-mammal policy (`SCOUTING_AND_SCOPING.md`, owner
   decision 2026-08-12) applies unchanged: **register, don't compile.** Note the standing violation
   documented there (43 Ruf & Geiser birds already in the compilations) — a sensory merge should be
   built with the class gate from the start rather than inheriting the same problem.
3. **It plugs directly into what the repo already holds on the sensory side, which is thin and
   scattered.** Existing touch points:
   - `Caves_etal_2018` — visual acuity, 40 species, but **26 of them non-mammal** (built, not
     merged). Same trait, largely complementary taxa; the two will need one canonical
     `visual_acuity_cdeg` term and an explicit precedence rule.
   - `Heffner_Masterton_1975` / `_1983` — same author lineage, but these are **pyramidal-tract and
     corticospinal** papers, i.e. already core M1 material. The Heffner corpus straddles both halves
     of the project; the sensory intake makes that a strength, not a coincidence.
   - `Fritsches_etal_2005` (fish visual temporal resolution), `Haarlem_etal_2026` (CFF dataset, raw
     only), `Chen_Wiens_2020` (acoustic communication origins, raw supplement only) — all
     sensory-adjacent, all currently unbuilt or unmerged. **A sensory merge would give these four
     orphans a home.**
   - `_keys/variable_catalog.csv` has **no** behavioural/psychophysical sensory terms at all — every
     "visual"/"auditory" hit is a *structure* (V1, A1, area striata, MT, LGN). This dataset would
     open a genuinely new `measure_class`: **performance/psychophysics**, as distinct from
     volumetrics and cell counts.
   - `deSousa_etal_2010` already carries a `V1LGN` table — a natural structure↔performance pairing
     with the visual-acuity column.

---

## 5. What ingestion would take (not started)

Under `__HOWTO_build_a_dataset_file.md`, this is **not one source folder — it is a compilation**.
`Sensory Data` is a *secondary* table aggregating ~15 primary sources, which is the situation the
repo handles by building each source and letting a `__merging_*` script combine them. Two routes:

**Route A — build per source (repo-conventional, slower).** One folder per primary source
(`Koay_etal_1998`, `HeffnerHeffner_1992`, `Heffner_1998`, `Heffner_2004`, `Heffner_2018`,
`Mooney_etal_2012`, `Ketten_2012`, `VeilleuxKirk_2014`, `Kirk_Kay_2004`, `Dooley_etal_2012`,
`Pettigrew_1998`) → snapshot → `.R` → CSV → public TSV → definitions → README → `__ReadMe.xlsx` row,
then `__merging_sensory/` compiles them. **None of these folders exists in the repo yet** (checked:
no Veilleux, Kirk, Kay, Koay, Ketten, Mooney, Dooley or Pettigrew folder). The PDFs for most are in
the copied archive and in `~/Documents/References.Data`. Highest cost, but it is the only route that
makes the primary/secondary distinction real — which is precisely what the abandoned `Primary refs`
sheet was trying to do.

**Route B — build `Sensory Data` as one secondary item (fast, honest about its status).** Treat the
integrated table as a single registry item with `Data role = secondary`, frozen as a snapshot,
`.R`-cleaned to long format, definitions from the existing `Metadata` sheet, references from the
existing `Reference` sheet. Registered and public but **not merged**, exactly as
`Caves_etal_2018` and `Fritsches_etal_2005` sit now. Fixes §3.1 as a documented correction in the
`.R`, not silently.

**Recommended: B first, then A for the sources that matter.** B is a few days and makes the data
findable, citable and auditable; A can then proceed source-by-source without blocking anything, and
the B item becomes the `comparison/` fixture that each A folder is audited against — which is how
the repo already handles curated-vs-primary elsewhere.

Either route needs first: **(i)** fix or quarantine the VA offset (§3.1); **(ii)** decide long vs
wide (§3.4); **(iii)** run the 157 species through `_keys/resolve_taxonomy.R` and extend
`species_reference.csv`; **(iv)** add a `Class` gate so birds register but do not compile;
**(v)** add sensory/psychophysical terms to `variable_canonical.csv`.

Naming, when it moves: `__merging_sensory/` alongside `__merging_cortical_areas/`, or
`____Sensory_audiovisual/` kept as a holding area with per-source folders at repo top level like
every other source. The second fits the existing layout better — the `____`-prefixed folders here
are *thematic collections* (`____Brain_structure_volumes`, `____Spinal_cord_etc`,
`____Collections and Specimen notes`), not source folders.

---

## 6. Open questions for the owner

1. **Is the Visual_Auditory_Heffner analysis project recoverable?** The alias points at a Dropbox
   path not included in this copy. If that project has already published or corrected any of these
   values, it supersedes the spreadsheets and should be found before curation starts.
2. **Who owns the VA offset fix** — is there a corrected copy elsewhere, or does it get re-derived
   from Veilleux & Kirk 2014 here?
3. **Route A or B**, and does the sensory data get its own merge or fold into an existing one?
4. **Scope**: does the repo's mammal-only compilation rule hold for sensory data, given how much of
   the comparative hearing literature (Heffner's own framing) is explicitly cross-class?
