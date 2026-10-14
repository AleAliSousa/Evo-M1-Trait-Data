# Pirlot_Nelson_1978_TABLE3

## Status: 4 snapshot cells reset to the printed values 2026-10-13, NOT FINISHED (printed-table errors still to resolve; public TSV pending)

This README replaced a 4-line stub on 2026-10-13. On the same day 4 snapshot cells were reset to the values as printed (see QA) and the analysis CSV was regenerated. The R script, definitions and registry row were not changed. The public TSV has **not** been updated yet. No registry invariant is claimed passed.

## Source → snapshot

Pirlot, P., & Nelson, J. (1978). Volumetric analyses of monotreme brains. In *Monotreme biology* (pp. 171–180). The Royal Zoological Society of New South Wales. OCLC:1340515946 (registry `DOI (or Alt)`: `OCLC%3A1340515946`). The document-supply cover sheet gives the publication as "Monotreme Biology: Symposium, Royal Zoological Society of NSW, Sydney, May 1978 Proceedings", published by the Society in 1979. The folder and registry keep **1978**, the symposium year. [TO CHECK: the registry citation's editor field reads "A. M. L. (Ed.)", which looks incomplete.]

Locus: **TABLE 3, "Absolute volumes of various brain structures and their percentage of total brain volume"**, printed p. 175 (PDF page 6 of `pirlot_nelson_1978.pdf`, held unchanged). PDF page 1 is a British Library document-supply cover sheet.

Source format: library-supplied scan with an Adobe Paper Capture OCR text layer. The table is legible as an image; the OCR layer has character errors and is not a numerical authority.

`Pirlot_Nelson_1978_TABLE3_snapshot.csv` is a long table:
- 36 rows (3 species × 12 components) with 4 columns: species, component, absolute volume (mm³), percent of total brain;
- printed column headings PLATYPUS / ECHIDNA / OPOSSUM are mapped to *Ornithorhynchus anatinus*, *Tachyglossus aculeatus* and *Didelphis marsupialis*;
- the second printed `Mes` row is labelled `Mesocortex` (the caption lists the order "… medulla oblongata and mesocortex");
- printed dashes `—` are blank;
- the printed total row (8571.45 / 26,578.2 / 6487.89 mm³) is not stored.

[TO CHECK: the person who transcribed the snapshot, and the date, are not recorded.]

## Snapshot → data readable

Run `Pirlot_Nelson_1978_TABLE3.R` in a clean R session. It:
1. reads the snapshot;
2. stops unless it finds 36 rows;
3. adds `source`;
4. writes `Pirlot_Nelson_1978_TABLE3.csv`;
5. writes `<Item encoded>.tsv` (registry: `OCLC%3A1340515946_TABLE3`) to `__Public/comparative-data/` if the registry lookup succeeds.

The R script does not transform any values.

Method (Material and methods, p. 171): one *Ornithorhynchus anatinus* (body 1040 g, brain 9.169 g) and one *Tachyglossus aculeatus* (body 4120 g, brain 27.518 g). Preparation:
1. perfused with saline, then 20% formalin, and stored for a week in 10% formalin;
2. brains dissected out and weighed, embedded in paraffin, and cut serially at 10 µm;
3. every *n*th section Nissl-stained, and 100–200 sections per species photographed;
4. areas measured and volumes calculated from the photographs, following Stephan & Pirlot (1970).

One *Didelphis marsupialis* (body 1205 g, brain 6.885 g) was "treated in the same way" for comparison.

Units: mm³ and percent of total brain volume.

Observation level: **one individual per species** (n = 1 each); one row per species × component.

Data role: **primary** for platypus and echidna. The opossum is also the authors' own measurement, but it is the same specimen as `Pirlot__1981_TABLEI` row 1 (P313, 1205 g, 6885 mg) and the *Didelphis marsupialis* column of `Pirlot__1981_TABLEII`. Do not merge it as an independent observation.

## Known limitations

The printed table is itself internally inconsistent in four places:
- **Medulla (Med) rows:** for platypus and echidna the printed Med values are identical to the Mes (mesencephalon) values (163.56 / 1.91 and 686.7 / 2.58). This looks like a printing error. From the column totals, platypus Med should be ≈ 603.12 mm³ and echidna Med ≈ 1118.7 mm³.
- **Echidna striatum and diencephalon:** the printed percentages for Str (6.68) and Di (5.84) don't match their printed volumes. 1553.5 / 26,578.2 = 5.85%; 1768.3 / 26,578.2 = 6.65%.
- **Opossum Med:** the printed value equals Bul (572.13 / 8.82). Here the column total confirms the value, so it is not an error.
- **No schizocortex for the opossum:** it was not reported (—), and mesocortex is reported only for the opossum.

## QA and online database

On 2026-10-13 an AI assistant (not a human) compared all 66 numeric cells with a rendered image of the printed table. 4 cells held values that were neither printed nor implied by the column totals. They were reset to the **printed** values the same day, so the snapshot is again a faithful record of the page:

| Species | Component | Field | Printed = new snapshot | Old snapshot |
|---|---|---|---|---|
| Tachyglossus aculeatus | Str | percent | 6.68 | 5.68 |
| Tachyglossus aculeatus | Di | percent | 5.84 | 6.64 |
| Ornithorhynchus anatinus | Med | volume | 163.56 | 663.56 |
| Ornithorhynchus anatinus | Med | percent | 1.91 | 7.74 |

**Important: the printed values carried over in these cells are themselves suspect** (see Known limitations). The platypus and echidna Med rows duplicate the Mes rows, and the echidna Str/Di percentages don't match their volumes. Values implied by the totals: echidna Str 5.85%, echidna Di 6.65%, platypus Med ≈ 603.12 mm³ / 7.04%, echidna Med ≈ 1118.7 mm³ / 4.21%. **[TO CHECK, owner decision: either (a) keep the printed values and flag these cells as unreliable in downstream merges, or (b) apply documented corrections in the R reader, not the snapshot, with the reason recorded. Until decided, exclude platypus and echidna Med, and echidna Str and Di percentages, from merges.]**

`Pirlot_Nelson_1978_TABLE3.csv` was regenerated with the same transformation as the R script (snapshot + `source`, R `write.csv` formatting). R itself was not run; the formatter reproduces the previous CSV exactly from the previous snapshot.

Expected analysis rows: **36**. Definitions: `reference_tables/Pirlot_Nelson_1978_TABLE3_definitions.csv`. Registry public TSV: `OCLC%3A1340515946_TABLE3.tsv`, which still holds the 4 old values.

Pending:
- the owner decision above;
- **re-run `Pirlot_Nelson_1978_TABLE3.R`** in R to rewrite the public TSV;
- clean R build/validate;
- human visual curation;
- de-duplicate the opossum against Pirlot 1981.
