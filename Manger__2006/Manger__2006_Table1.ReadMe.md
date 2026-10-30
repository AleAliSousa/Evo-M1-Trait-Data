# Manger (2006) — Table 1 (extant cetaceans)

**Source paper.** Manger, P. R. (2006). An examination of cetacean brain structure with a novel
hypothesis correlating thermogenesis to the evolution of a big brain. *Biological Reviews*, 81(2),
293–338.

**Table.** Table 1: *"Brain mass, body mass, encephalisation quotients, and water temperatures used in
the analyses included in the present study"*, pp. 296–297.

## Files in this folder

| file | what it is |
| --- | --- |
| `Manger__2006_Table1_snapshot.csv` | the extant-cetacean rows of Table 1 as printed |
| `Manger__2006_Table1.csv` | cleaned, analysis-ready data ("use this") |
| `Manger__2006_Table1.R` | script that turns the snapshot into the clean CSV |
| `Manger__2006_Table1.ReadMe.md` | this file |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Scope

The printed table has four sections: Eocene Archaeoceti, Oligocene cetaceans, Miocene cetaceans, and
Extant cetaceans, the last subdivided into Suborder Odontocete and Suborder Mysticete. This snapshot
covers the extant cetaceans, 34 species. The three fossil sections can be added as
`Manger__2006_Table1_fossils_snapshot.csv`.

## Snapshot

**Method.** Text-layer extraction from the PDF, checked row by row against page images of
pp. 296–297 by an AI assistant on 10 September 2026.

**Columns kept, exactly as in the paper.**

- `Species`
- `Brain mass (g)`
- `Body mass (g)`
- `Encephalisation quotient`
- `Water temp. (°C)` — range string as printed
- `Source` — numeric key to the reference list in the caption

**Row order.** As published, within suborder and family.

**`Suborder` and `Family` are not printed columns.** The printed table separates its groups with
indented headings — Extant cetaceans → Suborder Odontocete → Platanistidae → species — and both
fields carry the nearest preceding heading.

Water-temperature ranges are preserved as printed (`−1–9`, `13–29`), with `−` as the Unicode minus
(U+2212), per Manger's typography. Blank temperature cells are preserved as such: no habitat range
was reported for that species in the cited source.

## Source key (from the caption)

The `Source` numbers refer to brain and body masses:

(1) Gingerich (1998) · (2) Schwerdtfeger *et al.* (1984) · (3) Ridgway & Brownson (1984) ·
(4) Ridgway (1990) · (5) Marino (1998) · (6) Pilleri & Gihr (1970) · (7) von Bonin (1936) ·
(8) Jacobs & Jensen (1964) · (9) Jerison (1978) · (10) Marino *et al.* (2004)

The caption states that encephalisation quotients were calculated from the general mammalian
regression (Fig. 2) and that water temperatures were derived from the data compiled in Fig. 16, so
`Source` does not cover either.

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Brain mass, body mass and EQ coerced to numeric.
- Water-temperature range parsed into `water_temp_min_c` and `water_temp_max_c`; the printed string
  is kept in `water_temp_range_c`.
- `Data_role = derived` on the encephalisation quotient.

## Notes for the database

- `Physeter catadon` is Manger's spelling; now usually *Physeter macrocephalus*. Species-name
  standardisation is deferred to the repo-level step.
- The *Megaptera novaeangliae* row sits under a printed heading reading `Megaptera`; the family
  assignment is left to the taxonomy step.
- The Unicode minus (U+2212) will need `gsub("−","-",…)` for any tool expecting ASCII.
- Manger's thermogenesis hypothesis is argued from these data; the table is usable independently of
  it.

## Public export

Add the row to `__ReadMe.xlsx` (`Item name = Manger__2006_Table1` plus the derived `Item encoded`)
and run the `.R`, which writes `__Public/comparative-data/<Item encoded>.tsv`.
