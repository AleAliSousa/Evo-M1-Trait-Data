# Kruska 1980 — Tabelle 1 (fresh brain weights and shrinkage, 40 specimens)

Kruska D (1980). *Domestikationsbedingte Hirngrößenänderungen bei
Säugetieren.* Zeitschrift für Zoologische Systematik und
Evolutionsforschung 18(3): 161–195.
doi:10.1111/j.1439-0469.1980.tb00738.x

**Tabelle 1** — fresh brain weight (g) and percentage decrease from
formaldehyde fixation and histological processing for **40 individual
brains**: 7 camelids, 17 pigs (wild, domestic, feral) and 16 rats
(wild, domestic).

## Source → Snapshot → Data readable → Online database

- **Source:** the publisher PDF scan of the paper, held in this folder
  (`Kruska-1980-Domestikationsbeding.pdf`, supplied by Michael Proulx
  2026-11-18); the paper is paywalled at Wiley and has no open copy.
- **Snapshot:** `Kruska__1980_Tabelle1_snapshot.csv` — the table
  transcribed exactly as printed (two-block layout flattened in
  printed order, German decimal commas kept), frozen **before** any
  cleaning. Transcribed by Buddy (AI assistant) on 2026-11-18 from the
  whole-paper extraction in `extracted_tables/`, whose values were
  verified cell by cell against rendered page images.
- **Data readable:** `Kruska__1980_Tabelle1.R` reads **only** the
  snapshot, converts decimal commas, and harmonises the printed
  species names through `_keys/Stephan/species_key.csv` (printed names
  kept in `species_as_printed`; the key's rows for this paper record
  Kruska's forms — *Lama guanacoe* f. *pakos* etc. — and their
  accepted names). It writes `Kruska__1980_Tabelle1.csv` (40 rows) and
  the public TSV, and runs clean under Rscript, reproducing the
  committed CSV/TSV exactly.
- **Definitions:** `reference_tables/Kruska__1980_Tabelle1_definitions.csv`.
- **Online database:** public TSV
  `10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle1.tsv` in
  `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `Kruska__1980_Tabelle1`).

## Data role and caveats

- **Primary, per-specimen.** These are Kruska's own weighings of the
  brains he sectioned for Tabelle 2.
- **Shrinkage is large**: fixation + histological processing shrank
  these brains by 32–59%. Tabelle 2's volumes are corrected back to
  the fresh state per brain using these percentages.
- **Taxonomy as printed:** Kruska treats guanaco, alpaca and llama as
  one species (*Lama guanacoe*, f. *pakos*, f. *glama*); pigs and rats
  appear as *Sus scrofa* f. *dom.* (and f. *dom.* verwildert) and
  *Rattus norvegicus* f. *dom.* The accepted names stand in
  `species_sci`, resolved through the Stephan species key.
