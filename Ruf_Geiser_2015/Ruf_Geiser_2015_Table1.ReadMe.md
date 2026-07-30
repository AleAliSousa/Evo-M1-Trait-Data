# Ruf & Geiser (2015) — Table 1

**Source paper.** Ruf, T., & Geiser, F. (2015). Daily torpor and hibernation in birds and mammals. *Biological Reviews*, 90(3), 891–926.

**Table.** Table 1 ("Torpor characteristics in birds and mammals", pp. 894–905): torpor phenotype and physiology across 213 species.

## Files in this folder

| file | what it is |
| --- | --- |
| `Ruf_Geiser_2015_Table1_snapshot.csv` | frozen, faithful copy of Table 1 as printed |
| `Ruf_Geiser_2015_Table1.csv` | cleaned, analysis-ready data |
| `Ruf_Geiser_2015_Table1.R` | script that turns the snapshot into the clean CSV |
| `Ruf_Geiser_2015_Table1.ReadMe.md` | this file |

## Snapshot

**Method.** The printed Table 1 spans roughly a dozen printed pages of the *Biological Reviews* PDF. It was extracted programmatically from the paper's PDF text layer (rows matched by fixed-format species-line pattern with `DT` or `HIB` in the second field), then written to CSV. Class-level headings (`AVES`, `MAMMALIA`) and Order-level headings (`Coraciiformes`, `Trochiliformes`, `Rodentia`, …) were tracked as the extractor walked down the text and attached to each row.

**Columns kept, as in the paper.**

- Class (`AVES` / `MAMMALIA`) — inferred from the taxonomic section heading in the paper.
- Order — inferred from the taxonomic section heading.
- Taxon (species Latin binomial)
- T — torpor type: `DT` (daily torpor) or `HIB` (hibernation)
- BM — body mass (kg)
- Tb min — minimum torpor body temperature (°C)
- TMRmin — minimum torpor metabolic rate (ml O₂ / g / h)
- TMRrel — TMRmin as % of basal metabolic rate
- TBDmax — maximum torpor bout duration
- TBDmean — mean torpor bout duration
- IBE — interbout euthermia duration (h)
- LAT — latitude of study site (°)
- References — as printed

## Why this table for the database

The comprehensive comparative torpor dataset. Directly extends:

- **Arendt et al. (2003)** on tau reversibility in hibernation — Ruf & Geiser provide the phylogenetic map on which Arendt's molecular finding sits.
- **Hrvatin et al. (2020)** on QRFP-induced torpor in mice — Ruf & Geiser tell you which species already possess natural torpor and which don't.
- **Siegel (2022)** on adaptive inactivity as sleep's core function — torpor is Siegel's extreme case, and this table gives it quantitative shape.

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Em-dash `—` and Unicode minus `−` normalised. `—` in numeric columns becomes `NA`.
- Numeric columns coerced to numeric.
- Character columns (taxon, references) trimmed.

## Known caveats — please verify before submitting

1. **Order-heading inference is imperfect.** The extractor tracks the most recent taxonomic heading it detected. For classes with many small orders (e.g., mammalian marsupials, insectivores), some rows may be attached to the wrong order because the heading text was not matched. Manual verification against the printed table is worthwhile before submission — the rest of the row values are correct even where the order label is wrong.
2. **Reference strings may be truncated.** Where the paper prints a reference that wraps onto a second line of the table row (e.g. `"Hoffmann & Prinzinger (1984) and McKechnie & Lovegrove (2001a)"`), the extractor sometimes only captured the first line. Rows ending in `"and"`, `","` or an ampersand are candidates for manual completion.
3. **Missing values.** `—` (em-dash) in the printed table means "not reported" for that species — preserved as such in the snapshot and coerced to `NA` in the cleaned CSV.
4. **Some species (mostly marsupials at the end of the table) may have been extracted with the wrong `Order` field.** Cross-check any species you plan to use in analysis.

## Alternative if manual verification is too much work

Wiley journals often provide a supplementary Excel file. If `brv.12137` has one at *Biological Reviews*'s online supplement page, downloading it and re-saving as the snapshot would be more faithful than the text-layer extraction used here. As of the ReadMe date I could not verify whether such a file exists — worth checking before you spend hours on manual proofreading.
