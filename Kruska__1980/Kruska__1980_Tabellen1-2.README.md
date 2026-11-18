# Kruska 1980 — fresh brain weights & shrinkage (Tabelle 1) and camelid brain-part volumes (Tabelle 2)

Kruska D (1980). *Domestikationsbedingte Hirngrößenänderungen bei
Säugetieren.* Zeitschrift für Zoologische Systematik und
Evolutionsforschung 18(3): 161–195.
doi:10.1111/j.1439-0469.1980.tb00738.x

**Tabelle 1** — fresh brain weight and fixation/processing shrinkage
(%) for **40 individual brains**: 7 camelids, 17 pigs (wild, domestic,
feral) and 16 rats (wild, domestic). **Tabelle 2** — per-specimen
volumes (mm³) of the whole brain and 11 compartments for the **7
camelid brains** (3 guanaco, 2 alpaca, 2 llama), from complete serial
sections, corrected back to the fresh state.

This is the source of the alpaca row in Castillo-Morales et al. (2016)
Table 1 (their ref 99) — verified exactly: the paper prints no alpaca
mean, and Castillo's values are the arithmetic means of Kruska's two
alpaca specimens (brain volume (180502 + 182432)/2 = 181467 mm³ =
181.467 cm³; neocortex (99985 + 103635)/2 = 101810 mm³ = 101.81 cm³).

## What we built

- **Frozen source:** the publisher PDF scan in this folder, supplied by
  Michael Proulx (2026-11-18); the paper is paywalled at Wiley and has
  no open copy.
- **Extraction archive:** `extracted_tables/` holds verbatim CSVs of
  all 14 numbered tables plus the in-text cerebralisation-index list,
  with `REPORT.md` documenting the extraction and verification.
- **Reformat:** `Kruska__1980_Tabellen1-2.R` transcribes Tabellen 1–2
  (German decimal commas and space thousands separators normalised)
  and writes:
  - `Kruska__1980_Tabelle1.csv` (40 rows), `Kruska__1980_Tabelle2.csv` (7 rows)
  - `../__Public/comparative-data/10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle1.tsv` and
    `_Tabelle2.tsv` (public, DOI-encoded — names are the expected
    Items encoded; see Registry)
- **Definitions:** `reference_tables/Kruska__1980_Tabelle1_definitions.csv`
  and `..._Tabelle2_definitions.csv`.
- **Reader:** the CSVs/TSVs were produced by Muse (Buddy), Michael
  Proulx's AI assistant, from the verified extraction in
  `extracted_tables/`. The R script was run in an isolated copy on 2026-11-18; both CSVs and TSVs matched the committed files by cell, and the alpaca checks passed.

## Data role and caveats

- **Primary, per-specimen.** Tabelle 2's volumes are Kruska's own
  measurements (complete serial sections, planimetric paper-weighing
  after Stephan 1960), each brain corrected to fresh volume by its own
  factor (fresh volume ÷ total section volume), with fresh volume =
  fresh weight ÷ **1.035** (specific gravity of brain substance — a
  fifth density convention for `_COMMON_CALCULATIONS.md`).
- **Shrinkage is large**: fixation + histological processing shrank
  these brains by 32–59% (Tabelle 1). The corrections assume equal
  shrinkage of all parts within a brain.
- **Taxonomy as printed:** Kruska treats guanaco, alpaca and llama as
  one species (*Lama guanacoe*, f. *pakos*, f. *glama*); the CSVs keep
  his names in `species_as_printed` and carry the accepted names
  (*Lama guanicoe*, *Vicugna pacos*, *Lama glama*) in `species_sci`.
- **No per-form means are printed** anywhere in the paper: its summary
  tables pool llama + alpaca (n = 4) against guanaco (n = 3). Any
  species mean (like Castillo's alpaca values) is a downstream
  computation from Tabelle 2.
- The paper's interspecific compilation (brain/body weights across five
  orders) appears only as figures and cerebralisation indices, not as
  a printed data table; the index list is in `extracted_tables/`.
- Misprint: Tabelle 2's A 7 allocortex (14 386) vs 14 368 in Tabellen
  6/11 — transcribed as printed, flagged in the CSV.

## Registry

The public TSV names above are the expected Items encoded
(10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle1 / _Tabelle2). The two registry rows were added on 2026-11-18; descriptive metadata remain incomplete. Merge ingestion is pending.
