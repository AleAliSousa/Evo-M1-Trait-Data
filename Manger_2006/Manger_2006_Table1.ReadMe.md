# Manger (2006) — Table 1 (extant cetaceans)

**Source paper.** Manger, P. R. (2006). An examination of cetacean brain structure with a novel hypothesis correlating thermogenesis to the evolution of a big brain. *Biological Reviews*, 81(2), 293–338.

**Table.** Table 1 ("Brain mass, body mass, encephalisation quotients, and water temperatures", pp. 4–5): comparative brain and body masses, encephalisation quotients, and habitat water-temperature ranges across cetaceans.

## Files in this folder

| file | what it is |
| --- | --- |
| `Manger_2006_Table1_snapshot.csv` | frozen, faithful copy of the extant-cetacean rows of Table 1 |
| `Manger_2006_Table1.csv` | cleaned, analysis-ready data |
| `Manger_2006_Table1.R` | script that turns the snapshot into the clean CSV |
| `Manger_2006_Table1.ReadMe.md` | this file |

## Scope

The printed Table 1 has three sections: Eocene Archaeoceti, Oligocene cetaceans, Miocene cetaceans, and Extant cetaceans (subdivided into odontocetes and mysticetes). This snapshot covers the **extant cetaceans only** (34 species). The fossil sections are of narrower interest for a comparative sleep/thermoregulation database and can be added later as a separate snapshot (`Manger_2006_Table1_fossils_snapshot.csv`) if wanted.

## Snapshot

**Method.** Text-layer extraction from the PDF followed by manual proofreading. Values, units, family assignments and reference source numbers preserved exactly as printed. Water-temperature ranges preserved as printed (e.g. `−1–9`, `13–29`), with `−` rendered as the Unicode minus sign per Manger's typography.

**Columns kept, as in the paper.**

- Species (Latin binomial)
- Suborder (`Odontocete` / `Mysticete`)
- Family
- Brain mass (g)
- Body mass (g)
- Encephalisation quotient
- Water temp. (°C) — range string as printed
- Source (numeric key to the reference list in the paper's Table 1 caption)

## Why this table for the database

Cetacean brain-body-EQ dataset across most extant species, plus **habitat water temperature** — a rare inclusion that makes this specifically relevant to Siegel (2022)'s thermoregulation framework. Manger's own thesis in this paper (that cetacean big brains function partly as heat generators against cold water) is contentious, but the underlying comparative data are among the cleanest cetacean brain/body datasets available.

Directly connects to:
- **Siegel (2022)** — temperature-driven sleep/REM argument.
- **Lyamin et al. (2008)** — species-level sleep data for the same taxa.
- **de Sousa & Proulx (2014)** — anatomy as active in shaping cognition.

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Brain mass, body mass and EQ coerced to numeric.
- Water-temperature range parsed into two derived columns (`water_temp_min_c`, `water_temp_max_c`); the original range string is preserved in `water_temp_range_c`.

## Notes

- The `−` character in temperature values is the Unicode minus (U+2212), matching Manger's typography. If any downstream tool expects ASCII `-`, run `iconv` or `gsub("−","-",…)`.
- Some rows have blank water temperature (no habitat-range data reported in the source references) — preserved as `NA`.
- `Physeter catadon` in Manger's Table 1 is now more commonly written as `Physeter macrocephalus`. Species-name standardisation is deferred to the repo-level step.
- The `Megaptera novaeangliae` row appears in the paper under the family label "Megaptera" but the species belongs to Megapteridae/Balaenopteridae depending on the taxonomy used; the snapshot preserves Manger's assignment (`Megapteridae`).
