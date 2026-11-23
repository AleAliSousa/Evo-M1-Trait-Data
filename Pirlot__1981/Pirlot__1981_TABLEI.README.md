# Pirlot__1981_TABLEI

## Status: XLSX reader repair, NOT FINISHED

The bounded reader repair of 2026-10-14 switches the input to the faithful XLSX snapshot and documents its in-R parsing and checks. Analysis CSV, public TSV, registry, keys and merges are unchanged by this preparation. Clean-R audit/build/validate and human visual curation remain pending; no registry invariant is claimed passed.

## Source → snapshot

Pirlot, P. (1981). A quantitative approach to the marsupial brain in an eco-ethological perspective. *Revue Canadienne de Biologie*, 40(2), 229–250. PMID:7280305 (registry `DOI (or Alt)`: `PMID%3A7280305`).

Locus: **TABLE I, "List of material"**, printed pp. 230–231 (PDF pages 2–3 of `pirlot_1981.pdf`, held unchanged in this folder).

Source format: library-supplied scan (Canon iR3225) with an Adobe Paper Capture OCR text layer. The printed table is legible on the page image, but the OCR layer has character errors (e.g. `Bioi.` for `Biol.`, `11` for `II`), so the text layer is not a numerical authority.

The reader uses `Pirlot__1981_TABLEI_snapshot.xlsx`, Sheet1, rather than the older normalized CSV snapshot. The XLSX retains the two printed parts, repeated headers and units, group headings, numbered specimens (1)–(50), literal species/`idem` labels, qualifiers and footnotes. A separate AI-assistant snapshot task transcribed it from printed pp. 230–231 on 2026-10-14 and records checks against the scan page images; this is not human curation or R validation. The reader never writes or reconstructs it.

Specimen 11's brain weight remains `(2200)` as printed. Results, Basal Didelphinae, section 2 (Basal BrW/BoW regression; printed p. 233 / PDF p. 5) explicitly states that specimen 11's BrW was interpolated: this is not an unqualified original measured brain weight. That provenance comes from the prose, not from assigning a meaning to the parentheses; the punctuation itself remains unexplained.

## Snapshot → data readable

Run `Pirlot__1981_TABLEI.R` in a clean R session (Rscript, or Source in RStudio). It:
1. reads Sheet1 `A1:G87` positionally as text and verifies both printed headers and the `gr`/`mgr` units;
2. keeps only rows anchored by literal specimen numbers, requires (1)–(50) once each in order, and checks the two parts, unique collection codes, sex/use codes and all 50 body/brain weights;
3. retains the literal label in `species_as_printed` and expands only `idem` or `idem` with the printed `(x)` qualifier (with or without the intervening space) into the legacy `species` column, carrying the preceding species and qualifier; no taxonomy normalization is applied;
4. parses body weights numerically in g; keeps `brain_weight_mg` as printed text, parses it separately for numeric checks, and flags `(2200)` with `brain_weight_parenthetical` without assigning a meaning to the parentheses;
5. appends `specimen_number` and derives `source` and filenames from its own saved script filename;
6. writes `Pirlot__1981_TABLEI.csv` and looks up `Item encoded` by exact `Item name` in `__ReadMe.xlsx` Sheet1. Registry value: `PMID%3A7280305_TABLEI`. If found, it writes `<Item encoded>.tsv` to `__Public/comparative-data/`; otherwise it only warns.

All parsing and validation are in the R reader. Table I has no printed total/sum line: no total is invented and no Table II medulla correction is applied here. The added provenance/flag columns have blank `Measure` fields in the definitions and are not independent primary measurements.

Method (pp. 230–233):
- **Specimens:** 5 come from Pirlot's own collection at the Université de Montréal (prefix `P`); the other 45 come from Prof. J. I. Johnson's collection at Michigan State University (prefix `J`).
- **Preparation:** brains were fixed in formalin, embedded in paraffin or celloidin, cut at 10–40 µm and stained for Nissl substance.
- **Weights:** body and brain weights were generally supplied by the collectors, with specimen 11's explicitly interpolated BrW as the exception noted above (p. 233 / PDF p. 5). A brain density of 1.036 was assumed when converting weights to volumes.

Units: body weight in grams (`gr`); brain weight in milligrams (`mgr`).

Observation level: **one row per individual specimen** (50 rows; 29 species). Repeated species rows are separate animals, so species means need aggregating downstream.

Use codes (table footnote): **S** = sectioned and used for component analysis as well as the encephalization estimate; **W** = weighed and used for the encephalization estimate only. Only the S specimens underlie the component volumes in `Pirlot__1981_TABLEII`.

Data role: **primary**. These are specimen data reported by the author. Collector-supplied weights are provenance metadata, not a secondary compilation; specimen 11's BrW is the explicitly author-interpolated exception (p. 233 / PDF p. 5), not an original measured weight. This exception does not reclassify the whole item. [TO CHECK: confirm the role against the registry `Data role` column once it is filled.]

## Known limitations

- **Specimen 8 (*Metachirops* (?) sp.):** the author says the specimen's identity is uncertain and differs from the usual *Philander* type (table footnote).
- ***Antechinus* (x):** the collector could not say whether these animals were adult or young.
- **Specimen 11 (*Marmosa (Thylamys)* sp.):** `(2200)` is retained literally. Results (p. 233 / PDF p. 5) identifies this BrW as interpolated; do not treat it as an unqualified directly measured weight. No meaning is assigned to the punctuation itself and no original measured BrW is invented.
- **Specimen 39 (*Vombatus mitchelli* (ursinus ?)):** the author was unsure of the species.
- **Overlap with another item:** specimen 1, *Didelphis m. marsupialis* P313 (body 1205 g, brain 6885 mg), is the same opossum used as the comparison animal in `Pirlot_Nelson_1978_TABLE3` (body 1205 g, brain 6.885 g). Do not count it twice.

## QA and online database

The earlier CSV comparison of 2026-10-13 does not certify this new XLSX reader. R/Rscript is unavailable in the preparation environment, so the reader has not been parsed or executed in R and no clean-build success is claimed. The separate snapshot review and human visual curation remain distinct from the reader's executable checks.

Expected analysis rows: **50**. Definitions: `reference_tables/Pirlot__1981_TABLEI_definitions.csv` (fixed 10-column schema). Registry public TSV: `PMID%3A7280305_TABLEI.tsv`.

Pending:
- clean R audit → build → validate;
- human visual curation of the snapshot against the page;
- collection-scoped species mapping (printed names include subspecies and uncertain identifications).
