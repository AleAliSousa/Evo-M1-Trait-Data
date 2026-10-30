# Ruf & Geiser (2015) — Table 1

**Source paper.** Ruf, T., & Geiser, F. (2015). Daily torpor and hibernation in birds and mammals.
*Biological Reviews*, 90(3), 891–926.

**Table.** Table 1: *"Torpor characteristics in birds and mammals"*, pp. 894–901. 214 species — 43
birds and 171 mammals, per the paper's abstract.

## Files in this folder

| file | what it is |
| --- | --- |
| `Ruf_Geiser_2015_Table1_snapshot.csv` | Table 1 as printed |
| `Ruf_Geiser_2015_Table1.csv` | cleaned, analysis-ready data ("use this") |
| `Ruf_Geiser_2015_Table1.R` | script that turns the snapshot into the clean CSV |
| `Ruf_Geiser_2015_Table1.ReadMe.md` | this file |
| `reference_tables/Ruf_Geiser_2015_Table1_definitions.csv` | measurement basis per column |
| `reference_tables/Ruf_Geiser_2015_Table1_references.csv` | the 265 works cited in the `References` column |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Snapshot

**Method.** Extracted from the PDF text layer, matching rows on a fixed-format species line, then
checked cell by cell against page images of pp. 894–901 by an AI assistant on 10 September 2026;
section headings re-derived from the printed page, reference strings completed where the printed cell
wraps to a second line, and the row count reconciled with the printed table. Five reference cells
(*Cricetus cricetus*, *Marmota marmota*, *Spermophilus parryii*, *Tenrec ecaudatus*, *Dromiciops
gliroides*) were re-checked against the PDF by M. Windley.

**Columns kept, exactly as in the paper.**

- `Taxon` — species binomial
- `T` — torpor type, `DT` or `HIB`
- `BM` — body mass
- `Tb min` — minimum body temperature in torpor
- `TMRmin` — minimum torpor metabolic rate
- `TMRrel` — TMRmin as a percentage of basal metabolic rate
- `TBDmax` — maximum torpor bout duration
- `TBDmean` — mean torpor bout duration
- `IBE` — duration of interbout euthermia
- `LAT` — latitude of the mid-point of the species range
- `References` — as printed

Units are given in the footnote to the printed table, p. 901: BM in kg, `Tb min` in °C, `TMRmin` in
ml O₂ g⁻¹ h⁻¹, `TBDmax` / `TBDmean` / `IBE` in hours, `LAT` in degrees (>0 °N, <0 °S).

**Row order.** As published.

**`Class` and `Order` are not printed columns.** The printed table separates its groups with in-table
section headings — `AVES` → `Coraciiformes`, `Coliiformes`, … and `MAMMALIA` → `Monotremata`,
`Placentalia` → `Rodentia`, `Primates`, … — and both fields carry the nearest preceding heading. The
infraclass headings `Placentalia` and `Marsupialia` are not carried into a column.

**What was NOT included in the snapshot.**

- The paper's own analyses of these data (cluster analysis, PGLS models, Figs 2–8).

## References table

`reference_tables/Ruf_Geiser_2015_Table1_references.csv` carries the 265 works cited in the
`References` column, one row per work, with the full entry transcribed from the paper's reference
list, pp. 918–926. Columns: `ref_key` (the citation string exactly as printed in the data column),
`cited_in_column`, `citation`, `note`.

Where a single printed key covers more than one work — `Hiebert (1990, 1993)`, `Lasiewski (1963,
1964)`, `Dausmann et al. (2004, 2005, 2009)` — both entries are given in `citation`, separated by
` | `, and the `note` records it. Four keys are not published works and are marked as such:
`T. Ruf (unpublished data)`, `T. Ruf & W. Arnold (unpublished data)`, `C. Bieber & T. Ruf
(unpublished data)` and `C. Siutz (personal communication)`. Two carry the printed indirection
verbatim: `F. Lachiver cited in Kayser (1961)` and `Moyle in Reardon (1999)`.

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Em-dash `—` and Unicode minus `−` normalised; `—` in numeric columns becomes `NA`.
- Numeric columns coerced to numeric; `Taxon` and `References` trimmed.
- `References` split on `"; "` so multi-citation cells resolve to one work each.

## Notes for the database

- `LAT` is the latitude of the **mid-point of the species range**, not of the study site. Mammal
  values come from PanTHERIA (Jones et al., 2009) for 159 species; 12 further mammals and all birds
  were estimated by the authors from IUCN range maps (p. 902).
- `T` is the authors' classification, cut at a maximum torpor bout duration of 24 h.
- `TMRrel` is a ratio as printed and is not recomputed here.
- The paper excludes `IBE` from its own cluster analyses, on the grounds that it may be affected by
  prior torpor episodes (p. 902).
- Ruf & Geiser (2015) is a review; the measurer of each row is the work cited in `References`. Those
  works are a roadmap for primary ingestion and should not be re-ingested as primary.
- *Spermophilus* is now split across several genera and *Fukomys damarensis* appears in older sources
  as *Cryptomys*. Species-name standardisation is deferred to the repo-level step.
- *Dasycercus cristicauda/blythi* (p. 900) carries a solidus in the printed binomial; kept as printed.

## Public export

Add the row to `__ReadMe.xlsx` (`Item name = Ruf_Geiser_2015_Table1` plus the derived `Item
encoded`) and run the `.R`, which writes `__Public/comparative-data/<Item encoded>.tsv`.
