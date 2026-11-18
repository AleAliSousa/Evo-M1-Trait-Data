# Röhrs 1986 — Table 1 (mustelid body and brain weights, 20 species)

Röhrs M (1986). *Cephalisation, Telencephalisation und
Neocorticalisation bei Mustelidae.* Zeitschrift für Zoologische
Systematik und Evolutionsforschung 24: 157–166.
doi:10.1111/j.1439-0469.1986.tb00624.x

**Table 1** — gross body weight (BKG, g), brain weight (HG, g),
cephalisation index and n for **20 mustelid species** (species means
over 196 individuals in total).

## Source → Snapshot → Data readable → Online database

- **Source:** the publisher PDF scan of the paper, held in this folder
  (`Ro_hrs-1986-Cephalisation__Telen.pdf`, supplied by Michael Proulx
  2026-11-18); Table 1 is printed on journal p. 161.
- **Snapshot:** `Röhrs__1986_Table1_snapshot.csv` — the table
  transcribed exactly as printed (German decimal commas, printed
  header abbreviations, the footnote mark on the three species
  determined after Drescher 1977), frozen **before** any cleaning.
  Transcribed by Buddy (AI assistant) on 2026-11-18 and verified value
  by value against the rendered page image of journal p. 161.
- **Data readable:** `Röhrs__1986_Table1.R` reads **only** the
  snapshot (decimal commas converted to points; the footnote mark
  becomes the `note` column) and writes `Röhrs__1986_Table1.csv`
  (20 rows) and the public TSV. The script runs clean under Rscript
  and reproduces the committed CSV/TSV exactly.
- **Definitions:** `reference_tables/Röhrs__1986_Table1_definitions.csv`.
- **Online database:** public TSV
  `10.1111%2Fj.1439-0469.1986.tb00624.x_Table1.tsv` in
  `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `Röhrs__1986_Table1`).

## Data role and caveats

- **Primary.** The brain weights are species means from the Hannover
  group's material; three species (*Martes pennanti*, *Taxidea taxus*,
  *Lutra canadensis*) were determined after Drescher (1977) and are
  flagged in the CSV, as the table's footnote 1 states.
- The Cephalisation column is an **index** (deviation from the Mustela
  reference line = 100), not a measurement; it is flagged as an index
  in the definitions.
- Names as printed: *Mustela vison* (now often *Neogale vison*) and
  *Lutra canadensis* (now *Lontra canadensis*) are kept verbatim.
