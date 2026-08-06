# Build status — 2026-08-05

Registry items **without** a public TSV: **57 → 36** across two batches today.

`__ReadMe.xlsx` backups from today: `__ReadMe.pre_20260805.bak.xlsx` (before any edit) and
`__ReadMe.pre_relfix_20260805.bak.xlsx` (before the relationship repair, below).

> **All `.R` scripts below are canonical but were NOT executed** — there is no R in the authoring
> environment. Their CSV/TSV were written by an offline mirror that reproduces R's writing
> conventions. **Re-run each script in RStudio** to confirm it reproduces the committed files.

---

## Batch 1 — the scouting scaffolds (9 items)

Capellini 2008 ×3, Reader 2011, Liu 2016 Table S1, Jacobs 2018 Tables 3 + 5, Heuer 2019 Table 1 + S1.
Full account in `../HANDOFF_scouting_20260731.md`.

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

---

## What is left (36 items)

### Needs a table extracted from the paper PDF — explicit scaffolds that stop before extracting

`Gabi_etal_2016_Table1`, `Kazu_etal_2014_Table1`, `Ribeiro_etal_2013_Table1`,
`Olkowicz_etal_2016_TableS1`. Each `.R` sets up paths and documents an `extract_tables()` plan;
the folder holds only the paper PDF. `Olkowicz_etal_2016_` also still has a **blank `Item number`**.

### Raw-only folders (paper PDF, nothing built)

`Changizi_Shimojo_2005` Tables 1–5, `Nudo_etal_1995` Tables 1–5, `Sherwood_etal_2003_Table1`,
`Nguyen_etal_2019`, `Jacobs_etal_2015`, `Kazu_etal_2015`, `Baron_etal_1996`,
`Smaers_Soligo_2013_Supplement`, `Fu_etal_2013_Table1`, `Haarlem_etal_2026_CFFdataset`.

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
