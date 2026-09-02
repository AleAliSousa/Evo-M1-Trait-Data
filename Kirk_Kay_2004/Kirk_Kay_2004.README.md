# Kirk & Kay (2004) — Tables 1 + 2 (mammalian visual acuity: behavioral + anatomical)

**Source chapter.** Kirk, E. C., & Kay, R. F. (2004). The evolution of high visual acuity in the
Anthropoidea. In C. F. Ross & R. F. Kay (Eds.), *Anthropoid Origins: New Visions* (pp. 539–602).
Kluwer Academic/Plenum. doi:10.1007/978-1-4419-8873-7_20 (Springer chapter DOI, verified).

**Tables.** Table 1: *Behavioral measurements of visual acuity in various mammalian taxa*
(37 species; conditioned grating protocols). Table 2: *Anatomical estimates of visual acuity*
(42 species; highest acuity theoretically attainable from eye/retina morphology). Acuity in
c/deg; ranges and air/water qualifiers as printed; unspecified substrate = air (table notes).
Third Route-A sensory source folder — with Veilleux_Kirk_2014 this covers the remainder of the
check fixture's VA quarantine for KK-cited values.

## Files in this folder

| file | what it is |
| --- | --- |
| `kirk_kay_2004.pdf` | the chapter PDF (frozen source; born-digital) |
| `Kirk_Kay_2004_extract_snapshot.py` | snapshot builder; `--verify` audits every transcribed token against the PDF text layer (clean 2026-08-31) |
| `…_Table1_snapshot.csv`, `…_Table2_snapshot.csv` | frozen snapshots as printed (37 + 42 rows; en-dash ranges, substrate qualifiers, misspellings, typographic apostrophes kept verbatim) |
| `…_Table1.R`, `…_Table2.R` | canonical reformats: snapshot → CSV + public TSV (one row per printed substrate segment) |
| `Kirk_Kay_2004_mirror.py` | offline Python mirror that generated the committed outputs — delete after an RStudio run of the `.R`s reproduces them |
| `…_Table1.csv` (39 rows), `…_Table2.csv` (46 rows) | analysis-ready data ("use these") |
| `reference_tables/…_definitions.csv` ×2 | data dictionaries |
| `reference_tables/Kirk_Kay_2004_footnotes.csv` | both tables' printed notes, verbatim |
| `reference_tables/Kirk_Kay_2004_species_crosswalk.csv` | printed-name deviations → binomials (bactrius, californicus, jubata, caroliniensis, Amblonyx cinerea, rouxi; 3 genus-level "sp." rows; "Gervaif" common-name misprint) |
| `comparison/Kirk_Kay_2004_VA_offset_adjudication.csv` | the check fixture's 25 KK-citing VA rows resolved against these tables |

Public TSVs: `10.1007%2F978-1-4419-8873-7_20_Table1.tsv` / `…_Table2.tsv`.

## ⚠ Registry rows still to add (owner)
No rows existed for this chapter (folder + PDF added 2026-08-31; products built same day). Two
rows needed — suggested values: Item numbers **"Table 1"** / **"Table 2"**, Item names
`Kirk_Kay_2004_Table1` / `Kirk_Kay_2004_Table2`, DOI (col J) `10.1007%2F978-1-4419-8873-7_20`
(Springer chapter DOI — book chapter, so double-check col C isn't wanted instead), citation:
Kirk, E. C., & Kay, R. F. (2004). The evolution of high visual acuity in the Anthropoidea. In
C. F. Ross & R. F. Kay (Eds.), Anthropoid Origins: New Visions (pp. 539–602). Kluwer
Academic/Plenum. The TSV filenames above assume these encoded keys — rename the TSVs if the keys
are decided differently.

## Cleaning applied (in `.R`)
One row per printed substrate segment ("2.5 (air); 3.3 (water)" → two rows); ranges split to
`va_cdeg_min`/`va_cdeg_max` (single values: min = max); full printed string kept in
`va_as_printed`; printed names verbatim in `Species_KK2004` with deviations resolved via the
crosswalk. **Data role: secondary-leaning both** — every value carries its printed citation(s)
(`source_as_printed`, the per-primary audit hook); Table 2 values are the cited authors'
anatomical calculations (methods vary slightly — table notes).

## Comparisons (VA quarantine)
`comparison/…_VA_offset_adjudication.csv`: all **25** fixture VA rows citing "Kirk and Kay 2004"
resolved — **21 CONFIRMED correct** (value within the printed range for that species/method/
substrate) and **4 = the alphabetical offset pattern** (Aotus azarae B-water 2.0 is *Aonyx*'s
water value; Bos taurus A-water 4.2 is *Balaenoptera*'s; Camelus bactrianus A 7.1 is
*Callorhinus*'s; Phoca vitulina 3.6 is Phoca's own **correct value with a displaced water
label** — KK prints it unqualified/air). With VK2014's 92 rows this accounts for 117/127
quarantined VA rows; the rest cite Heffner & Heffner 1992a (see that folder's README).

## Notes for the database
- Overlap: VK2014 compiled many of these same primaries — KK2004 and VK2014 are **not
  independent** for shared species; both cite their primaries per value, so any future acuity
  merge should de-duplicate at the primary-citation level.
- Tables 3 (peak cone densities), 4 (optic foramen indices) and 5 (OFQ) are NOT built —
  candidate future items in this same folder.
- Species-name standardisation deferred; `species_key.csv` token: `KirkKay2004`.
