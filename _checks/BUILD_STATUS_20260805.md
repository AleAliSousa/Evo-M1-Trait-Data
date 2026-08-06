# Build status — 2026-08-05 / 06

Registry items **without** a public TSV: **57 → 50 → 36 → 24** across three batches.

`__ReadMe.xlsx` backups: `__ReadMe.pre_20260805.bak.xlsx` (before any edit),
`__ReadMe.pre_relfix_20260805.bak.xlsx` (before the relationship repair, below) and
`__ReadMe.pre_20260806.bak.xlsx` (before batch 3).

> **All `.R` scripts below are canonical but were NOT executed** — there is no R in the authoring
> environment. Their CSV/TSV were written by an offline mirror that reproduces R's writing
> conventions. **Re-run each script in RStudio** to confirm it reproduces the committed files.

---

## Batch 1 — the scouting scaffolds (9 items)

Capellini 2008 ×3, Reader 2011, Liu 2016 Table S1, Jacobs 2018 Tables 3 + 5, Heuer 2019 Table 1 + S1.
Full account in `../SCOUTING_AND_SCOPING.md`.

## Batch 2 — built-but-unpublished tables (14 items)

These had a `.R` and an analysis CSV but no DOI-coded TSV, so they were built and then invisible to
the merges and the Shiny app.

| Item | Rows | What was missing |
|---|---|---|
| `Stephan_etal_1981_Table{VIII,IX,X}` | 27 / 40 / 10 | registry DOI was wrong (see below) |
| `Heffner_Masterton_1983_TableI` | 21 | CSV predated the current `.R`; **rebuilt from the snapshot**, then published |
| `Bauernfeind_etal_2013_Table3` | 60 | `.R` had no public-TSV block — added |
| `Semendeferi_etal_2002_Table1` | 8 | `.R` had no public-TSV block — added |
| `Iwaniuk_etal_1999_References` | 69 | `.R` had no public-TSV block — added |
| `Sherwood_etal_2004_I_Table{4,5}` | 6 / 6 | no TSV block **and** unparsed numbers (see below) |
| `BarbeitoAndres_etal_2019_{volumes,cellnumber,celldensity}` | 299 / 211 / 214 | wrote local `.tsv` copies, never the DOI-coded one |
| `deJager_etal_2022_Table1` | 28 | `.R` had no public-TSV block — added |
| `Matano__1992_Tables1to4` | 45 | registry `Item number` was blank, so the lookup found nothing |

### Data corrections made

- **Stephan et al. 1981 Tables VIII, IX and X carried the wrong DOI.** Rows 247–249 of `Sheet1`
  cited `10.1159/000155964`, `…965` and `…966` — sequential numbers incremented along with the
  table number — while the same citation text and the other 14 rows of the same paper (Folia
  Primatol 35(1):1–29) use `10.1159/000155963`. All 16 per-table `.R` scripts hardcode `…963`, and
  `__merging_volumes/volumes_compiled.R` carries an `enc_override` written specifically to route
  around the bad rows ("(000155964/5/6) can't send those tables to a missing TSV"). The three
  citations are corrected; **the `enc_override` in the merge is now redundant and can be removed.**

- **Sherwood et al. 2004 (I) Tables 4 and 5 were carrying text where numbers belong.** The Adobe
  export encodes Table 5's minus signs as **en dashes** (`–0.9664`) and prefixes Table 4's *Pongo*
  cells with a **newline** (`\n10.34`), which silently made whole columns character. Both are
  export artefacts, not anything the journal printed, so the reformat now coerces them (§6
  "encoding & parsing gotchas"); the frozen snapshots are untouched. Both CSVs were regenerated.

- **`write.table` escapes quotes with backslashes, `write.csv` doubles them.** R's `write.csv`
  forces `qmethod="double"` while `write.table` defaults to `qmethod="escape"`. The batch-1 TSVs
  were written with the wrong one; fixed, and the offline mirror now distinguishes them. Worth
  knowing for any future hand-written TSV.

- **`__ReadMe.xlsx` relationship repair.** The workbook came back from a save with
  `xl/worksheets/_rels/*.rels` pointing at `drawing1.xml`, `vmlDrawing1.vml` and their sheet-2
  equivalents, none of which are in the archive, plus `<dimension>` collapsed to `A1`. That is the
  state in which openpyxl refuses to open it. The four dead relationships were removed and the
  dimension restored. The same save had also turned the two appended rows' `<t xml:space="preserve">`
  attributes into literal cell text; rows 265–266 were rewritten with plain `<t>` elements.

## Batch 3 (2026-08-06) — tables extracted from paper PDFs (12 items)

Every one was a printed source with nothing built, so each got a frozen snapshot, a reproducible
extract script, a `.R`, a CSV, a definitions file and a README. **97 species-key rows** added under
tokens `Changizi2005` (43), `Nudo1995` (48), `Kazu2014` (5), `Ribeiro2013` (1).

| Item | Rows | Notes |
|---|---|---|
| `Changizi_Shimojo_2005_Table1` | 19 animals | mean relative area size, brain mass, EQ |
| `Changizi_Shimojo_2005_Table2` | 16 animals | **relative size of V1/V2/A1/S1/M1 as % of neocortex** |
| `Changizi_Shimojo_2005_Table3` | 10 subnetworks | areas and area-area connections |
| `Changizi_Shimojo_2005_Table4` | 38 rows / 11 animals | connections per cortical area |
| `Changizi_Shimojo_2005_Table5` | 11 animals | mean connections per area |
| `Nudo_etal_1995_TABLE1` | 24 species | body / brain mass, neocortical surface area |
| `Nudo_etal_1995_TABLE2` | 24 species | **corticospinal soma counts by region** |
| `Nudo_etal_1995_TABLE3` | 9 orders | order means — derived, do not merge |
| `Nudo_etal_1995_TABLE4` | 24 species | peak corticospinal soma density |
| `Nudo_etal_1995_TABLE5` | 24 species | nine soma morphology characteristics |
| `Kazu_etal_2014_Table1` | 5 artiodactyls × 46 cols | cellular composition by sub-structure |
| `Ribeiro_etal_2013_Table1` | 7 human cortical regions | regional neuron / other-cell density |

Both 1995/2005-vintage PDFs needed **word-coordinate extraction**, not line text — the two-column
layout interleaves table rows with body prose (Changizi), and the Nudo text layer is OCR that
renders *Rattus norvegicus* as "Raltus noruegicus". Every Nudo cell was read off 300-dpi renders and
then cross-checked against the text layer; ten disagreements were all OCR faults. Frontiers PDFs
(Kazu, Ribeiro) strip space glyphs and put digits, decimal points, `±` and asterisks on different
baselines, so those too were read by coordinate.

### Cross-checks that passed (re-verified independently after the builds)

- **Changizi Table 4 → Table 5.** Recomputing the paper's own recipe, `10^mean(log10 x)` and the
  *sample* SD of `log10 x`, reproduces Table 5's mean **and** SD to 2 dp for all 9 recomputable
  animals. This validates the per-row values and the animal grouping at once.
- **Changizi Table 1.** The four rows printed without an SD satisfy `avg = 100/(2 × areas shown)`
  exactly — they were counted from unflattened maps, not measured.
- **Nudo Table 3 = Table 2.** All 63 recomputable cells reproduce as the unweighted order-wise mean
  of Table 2 (52 exactly, 11 within the printed rounding). Table 3 is therefore **derived and must
  not be merged**.
- **Nudo Table 2 internals.** `correction term = 100/(100 + soma diameter)` in 24/24;
  `corrected count = profiles × correction term` in 24/24; regions sum to the total in 23/24.
  Nudo's own stated means (24,071 CS somata; primate C = 888) all reproduce.
- **Ribeiro O/N.** All seven printed ratios exceed `other-cell density ÷ neuronal density` by
  0.9–2.8%, all positive — the expected Jensen gap for a mean of per-section ratios. **Not an
  identity**; do not treat it as one.

### Findings that change what should be merged

1. **`Kazu_etal_2014_Table1` must not be merged as built.** All five species are already in
   `cellcounts_wide.csv` from HH 2015 at full precision, and this is the **2014 printing** — the
   2015 corrigendum changes **71 of 195 cells (36%)**. Confirmed here: printed `WholeBrain_N.n`
   disagrees with `cortex + cerebellum + RoB` by −0.4% to −22.0%, and the corrigendum's values are
   what make it hold. What the table genuinely adds is the **sub-structures** (hippocampus, cortical
   grey, diencephalon+basal ganglia, mesencephalon, pons+medulla) — 9 of those cells also changed,
   so they belong to a `Kazu_etal_2015_` build.
2. **`Gabi_etal_2016_Table1` does not exist.** The article has Figures 1–6 and no main-text table;
   both data tables are in the SI Appendix, which is not in the folder. `Item number` corrected to
   **`Table S1`**. Before promising cell counts, check S1 — every in-text citation of it is to
   *cumulative percentages*, and percentages are not transcribed (§7).
3. **Gabi's human hemisphere is the same specimen as Ribeiro 2013** (Gabi Methods says so
   outright): one 65-y-o female right hemisphere. A `_keys/specimen_crosswalk` case before both are
   allowed to contribute a human value.
4. **Ribeiro is regional and cannot be recombined.** The region means are unweighted, so they do not
   average into a cortex-wide value, and V1 is already inside "Posterior". Never pool with the
   whole-cortex *Homo sapiens* row from HH 2015.
5. **Nudo Table 1 is secondary** — the paper states (p.184) that the body/brain/surface values are
   "retabulated here" from Nudo & Masterton 1989 / 1990b, neither of which is in the repo.

### Printed errors recorded, never corrected

Nudo Table 5's `Thickness (µm)` header is wrong (the values are **mm**, as the paper's own text
confirms); Nudo prints `Camivora` and `Lagamorpha` in some rows; Nudo's text gives a mean surface
density of 260 where Table 5 gives 326 (stale paragraph — the table is carried and the `.R` prints
the discrepancy on every run); Changizi Table 4 prints `TD` twice in the tree-shrew block where the
second is almost certainly `TI`; Kazu misprints *Tragelaphus stripceros*. All are flagged in
`parse_flags` / the definitions, and none was silently changed.

---

## What is left (24 items)

### Needs a table extracted from the paper PDF

`Olkowicz_etal_2016_TableS1` (scaffolded `.R`, still a **blank `Item number`**),
`Sherwood_etal_2003_Table1`, `Nguyen_etal_2019`, `Jacobs_etal_2015`, `Kazu_etal_2015`,
`Baron_etal_1996`, `Smaers_Soligo_2013_Supplement`, `Fu_etal_2013_Table1`,
`Haarlem_etal_2026_CFFdataset`.

`Kazu_etal_2015_` is now the **priority** of that list: it is the corrigendum that supersedes
`Kazu_etal_2014_Table1`, and until it exists the artiodactyl sub-structure data cannot be used.

---

## Batch 4 (2026-08-06) — Gabi et al. 2016 Table S1

Built once the SI Appendix (`pnas.201610178si.pdf`) was added to the folder. **8 primates including
human**, from p. 2 of the SI. `Item number` corrected from `Table 1` to `Table S1` (the article has
no main-text table); the stale `Gabi_etal_2016_Table1.*` scaffold files were removed.

**Every value is a percentage** — the prefrontal region's share of a whole-cortex total:
`% V_GM`, `% V_WM`, `% O_WM` and `% neurons`. §7 normally forbids transcribing percentages because
they are recomputed from the absolutes, but the absolute prefrontal values are **not published**
anywhere in this paper's tables (Fig. 6 plots them; no table gives them), so the share is the only
published form of the datum. Tagged `Measure = pct.cortex` throughout. To get an absolute
prefrontal neuron count, multiply `pct.neurons / 100` by that species' whole-cortex count — a
derivation for the merge to make explicitly, naming both sources.

Verified: mean `% neurons` = **8.17%** against the paper's "~8%", and **human = 7.8%, rank 3 of 8**,
which is the paper's own finding of no relative prefrontal expansion. Every share in (0, 100].

**The human row is the same hemisphere as `Ribeiro_etal_2013_Table1`** — Gabi's Methods say the
hemisphere was "previously analyzed by Ribeiro et al.", one 65-y-o female right hemisphere. Needs a
`_keys/specimen_crosswalk` entry before both contribute a human value.

`Table S2` (allometric slopes) is regression statistics, not species data — not registered, not built.

### Registry repair, again

Between batches the workbook came back from a save with the `xml:space="preserve"` attribute of the
inline-string cells written on 2026-08-05 **folded into the cell values**, so four Item numbers read
`xml:space="preserve">Table1` and the formulas propagated that into Item name and Item encoded —
silently unpublishing Heuer Table 1, Jacobs Table 3, Liu Table S1 and Reader Data. Repaired by
stripping the prefix from the 52 affected shared strings and refreshing the four cached Item
name/encoded pairs. **Never write `<t xml:space="preserve">` into this workbook** — use a bare
`<t>`. Backups: `__ReadMe.pre_20260806.bak.xlsx`, `__ReadMe.pre_xmlspacefix.bak.xlsx`.

---

## Batch 5 (2026-08-06) — Kazu et al. 2015 corrigendum, TABLE 1

The table that supersedes `Kazu_etal_2014_Table1`. **5 artiodactyls × 46 columns**, from p. 2 of
the corrigendum PDF by character-coordinate extraction (the Frontiers layer strips spaces and draws
the power-of-ten exponents as separate small-font glyphs).

`Kazu_etal_2015_TABLE1.R` is a deliberate **line-for-line parallel** of the 2014 reformat — same
parser, same label map, same column schema, same consistency checks — so the two are directly
diffable. That diff is the §7 comparison step, and unusually its expected result is *not* zero
mismatches but a complete list of what the corrigendum changed:

**71 of the 184 cells present in both printings changed — 39%** (*Damaliscus* 20, giraffe 17,
kudu 16, springbok 12, pig 6). `CerebralCortex` mass / N / density / O-N and `WholeBrain` mass and
O/N changed for **every** species — the footprint of moving the hippocampus out of rest-of-brain
and into cortex. Report: `Kazu_etal_2015/comparison/Kazu_etal_2015_TABLE1_vs_Kazu_2014_report.csv`.

**The check the 2014 printing failed is fixed.** `N_BR` vs `N_CXT + N_CB + N_RoB` was out by −0.4%
to −22.0% in 2014; here it closes to **+0.27% / −0.09% / +0.03% / +0.26% / −0.02%**, i.e. the
rounding of the printed three-significant-figure values. Strongest confirmation both that the
corrigendum fixed the misallocation and that the extraction is right.

Verified against the corrigendum's own text: brain mass **8.37**-fold (stated 8.4), brain neurons
**4.84**-fold (4.8), cortex **15.7 ± 0.8%** of brain neurons (exact), O/N min **0.184** blesbok
cerebellum, cortical-grey O/N **7.24–8.75** (stated 7.2–8.8), rest-of-brain density max **4238**
in the pig and min in the greater kudu. Two places where the corrigendum's text disagrees with its
own table are recorded, not corrected: it says cortex is 69.5 ± 1.8% of brain mass where the table
gives **69.3 ± 1.8** (the SEM matches exactly), and its O/N maximum of 34.190 holds only across the
*major* structures — the table's true maximum is **41.017**, the giraffe mesencephalon.

`Kazu_etal_2014_Table1` is now `Progress stage = FINISHED - SUPERSEDED` with
`Flags active (skips) = superseded by Kazu_etal_2015_TABLE1 - do not merge`, and its README carries
a banner.

### Wired into `__merging_cellcounts` — by the existing team rule, not by hand

Added to `cellcounts_compiled.R`'s `item_name` on 2026-08-06. Kazu is Herculano-Houzel–team work,
so §8.2.H's existing resolution handles it: within a team, priority is **date, then number of
species**, and only the best-priority source survives per **species × variable**. My earlier
suggestion to hand-pick the sub-structure columns was unnecessary — the rule already does it.

The case is instructive because the date *ties*. Kazu 2015 and HH 2015 are both 2015, so the
species-count tie-break gives HH the shared variables. Simulated against the published TSVs before
wiring:

| | |
|---|---|
| species × variable pairs held by **both** → HH wins | **80** |
| of those 80, differing by more than 2% | **0** |
| pairs only Kazu has → **sub-structure** gap filled | **87** |
| pairs only Kazu has → whole-structure gap filled | **21** |

Kazu contributes 108 values and duplicates none. The zero disagreement on the overlap independently
confirms HH 2015's full-precision values already *are* the corrigendum's, so which source wins
doesn't change the data — and that is the check worth repeating whenever a same-team, same-year
source is added: a *disagreeing* overlap would mean the priority rule was silently choosing between
two different measurements rather than two printings of one.

Also added: `standardized_term_by_reference/Kazu_etal_2015_TABLE1_standardized_terms.csv` (identity
map — the build already emits canonical `<Structure>_<Measure>` names — with `n → WholeBrain_n`;
every column listed, because the compile renames by `match()` and an unlisted column becomes an
`NA` column name), `standardized_term_cellcounts.csv` regenerated (498 → 544 rows, nothing lost),
and the rule written up in `__merging_cellcounts/README__merging.md`.

**Still to run in R:** `standardized_term.R`, then `cellcounts_compiled.R`.

---

## What is left (22 items)

### Needs a table extracted from the paper PDF

`Olkowicz_etal_2016_` (scaffolded `.R`, still a **blank `Item number`**), `Sherwood_etal_2003_Table1`,
`Nguyen_etal_2019_`, `Jacobs_etal_2015_`, `Baron_etal_1996_`, `Smaers_Soligo_2013_Supplement`,
`Fu_etal_2013_Table1`, `Haarlem_etal_2026_CFFdataset`.

### Genuine builds with sources already in hand

`Frahm_Zilles_1994_Table2`, `Karbowski__2007_Table1`,
`DeCasien_Higham_2019_SupplementaryData1-{ActivityPeriod,BrainRegion,Diet,SocialSystem}`.

### Not table builds

`Brodmann__1913_Tabelle1` (placeholder DOI — see above), `Garwicz_etal_2009_TableS2` (published
inside TableS1 — see above), `Isler_etal_2008_Tree.nex` (a phylogeny), and `Navarrete_etal_2016_`,
`Manger__2006_Table1`, `Matano__1986_`, `MedinaGonzalez__2026_`, `Weaver__2005_` (no matching folder).

### Registry hygiene, not builds — for the owner

1. **`Brodmann__1913_Tabelle1` (row 31) is a second, different paper**, not a duplicate of row 30.
   Row 30 is *Neue Ergebnisse über die vergleichende histologische Lokalisation…* (`OCLC:8777719`,
   built and published). Row 31 is *Neue Forschungsergebnisse der Großhirnrindenanatomie…*
   (Verhandlungen der Gesellschaft Deutscher Naturforscher und Ärzte), whose PDF is in the folder as
   `Brodmann_1913_Verhandlungen.pdf` — and its DOI is the literal placeholder
   **`10.0000/placeholder`**. It needs a real identifier before anything can be named after it.
2. **`Garwicz_etal_2009_TableS2` has no output of its own by design.** `Garwicz_etal_2009_TableS1.R`
   extracts both printed tables and writes **one** merged CSV (S1 taxonomy + S2 measures) under the
   `TableS1` item. Publishing a separate S2 TSV would double-count. Either record that in the S2
   row's Note, or retire the row.
3. **`BarbeitoAndres_etal_2019` is flagged `Data role = review`** but its own README describes an
   experimental single-species (*Mus musculus*) nutrition study with per-specimen measurements —
   a primary dataset kept as its own comparison set. The three TSVs were published on that reading;
   the role field looks like a mislabel.
4. **`Isler_etal_2008_Tree.nex`** is a phylogeny, and **`Navarrete_etal_2016_`**,
   **`Manger__2006_Table1`**, **`Matano__1986_`**, **`MedinaGonzalez__2026_`**, **`Weaver__2005_`**
   have no matching folder. None of these is a table build.

### Genuine remaining builds with sources in hand

`Frahm_Zilles_1994_Table2` (Table 1 is built; the xlsx and comparison CSV are present),
`Karbowski__2007_Table1`, `DeCasien_Higham_2019_SupplementaryData1-{ActivityPeriod,BrainRegion,Diet,SocialSystem}`
(MOESM3 xlsx present, one partial `.R`).
