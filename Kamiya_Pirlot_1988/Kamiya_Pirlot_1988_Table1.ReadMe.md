# Kamiya_Pirlot_1988_Table1

## Status: README expanded, NOT FINISHED. ⚠ REGISTRY CITATION DOES NOT MATCH THE SOURCE IN THIS FOLDER (see below)

This README replaces a 4-line stub on 2026-10-13. It documents the existing files only. No data, script, snapshot, definitions, registry row or public TSV was changed. No registry invariant is claimed passed.

## Source → snapshot

**Source actually held in this folder and transcribed in the snapshot:**
Kamiya, T., & Pirlot, P. (1988). The brain of the Malayan bear (*Helarctos malayanus*). *Zeitschrift für Zoologische Systematik und Evolutionsforschung*, 26, 225–235. Received 13 January 1988; Copyright Clearance Center code 0044-3808/88/2603-0225, i.e. issue 3. File: `Kamiya-1988-The Brain of the Mal.pdf` (held unchanged).

**Registry citation and identifiers (Sheet1) describe a different paper by the same authors in the same journal and year:** "Kamiya, T., & Pirlot, P. (1988). The brain of the lesser panda *Ailurus fulgens*: A quantitative approach. *Z. Zool. Syst. Evolut.-forsch.*, 26(1), 65–72":
- `DOI (or Alt)` = `10.1111%2Fj.1439-0469.1988.tb00644.x`;
- `Item encoded` = `10.1111%2Fj.1439-0469.1988.tb00644.x_Table1`;
- `Item full original title` = "Table 1. Percentile composition of total brain for the lesser panda".

The Malayan bear paper itself cites "KAMIYA and PIRLOT (1988)" on the lesser panda as a separate article.

**[TO CHECK, BLOCKING: decide which paper this item represents.**
- **If the Malayan-bear paper (matching the data):** correct the registry citation, DOI, item title and `Item encoded` (owner action in `__ReadMe.xlsx`), then regenerate the public TSV under the new code.
- **If the lesser-panda paper:** the snapshot and PDF here are the wrong source.

The public TSV currently named for the lesser-panda DOI contains Malayan-bear-paper data.]

Locus (Malayan bear paper): **Table 1, "Progression indices"**, printed p. 231 (PDF page 7). Layout as printed:
- three columns: *Helarctos*, *Ailuropoda*, *Ursus*;
- ten component rows: BO, N, RH, S, D, ST, H, M, C, O.

Printed footnote: BO = olfactory bulb; N = neocortex; RH = rhinencephalon; S = septum; D = diencephalon; ST = striatum; H = hippocampus; M = mesencephalon; C = cerebellum; O = medulla oblongata.

Source format: publisher PDF with an Acrobat Paper Capture OCR text layer. The running text is readable, but Table 1's numbers are not in the text layer and must be read from the page image.

`Kamiya_Pirlot_1988_Table1_snapshot.csv` has 10 rows and 3 value columns (one per genus). Binomials are in `reference_tables/Kamiya_Pirlot_1988_Table1_taxa.csv`: *Helarctos malayanus*, *Ailuropoda melanoleuca* and *Ursus americanus*.

## Snapshot → data readable

Run `Kamiya_Pirlot_1988_Table1.R` in a clean R session. It:
1. reads the snapshot;
2. stops unless it finds 10 rows;
3. adds `source`;
4. writes `Kamiya_Pirlot_1988_Table1.csv`;
5. writes `<Item encoded>.tsv` to `__Public/comparative-data/` if the registry lookup succeeds. Note the citation issue above.

The R script does not transform any values.

Method (Malayan bear paper, pp. 225–226): one male *Helarctos malayanus* brain from the Tama Zoo, near Tokyo. The body weighed 82 kg at death and the brain 300 g. Progression indices give the brain part's size relative to that expected for a basal insectivore of equal body size (above 100 = progression).

Units: progression index (dimensionless; 100 = basal insectivore). **Not volumes.**

Observation level: **one individual per species** (n = 1); one row per component.

Data role: **mixed**.
- *Helarctos*: **primary** (this paper's own specimen).
- *Ailuropoda* and *Ursus*: **secondary**, reproduced from Pirlot & Jiao (1985). The text (p. 230) cites "PIRLOT and JIAO 1985" for the panda (3018) and black bear (1635) N indices, and these values equal Pirlot & Jiao (1985) Table 3.

Do not merge the *Ailuropoda* and *Ursus* columns as primary or as independent of `Pirlot_Jiao_1985`. [TO CHECK: whether the registry `Data role` should be `both` / mixed.]

## Known limitations

- **Single specimen:** the authors question their specimen's body weight. The literature gives 45 kg or 100 lb for the species against 82 kg for this animal, which affects the progression indices (p. 226).
- **Secondary columns:** two of the three columns are secondary (see Data role).

## QA and online database

On 2026-10-13 an AI assistant (not a human) compared all 30 snapshot values with a rendered 200 dpi image of printed Table 1. **All 30 match.** This is not human visual curation, which is still pending.

Expected analysis rows: **10**. Definitions: `reference_tables/Kamiya_Pirlot_1988_Table1_definitions.csv`. Its notes cite pages 226 and 230–231, which match the Malayan bear paper.

Pending:
- resolve the citation / `Item encoded` mismatch (blocking for public TSV naming);
- set the data role for the secondary columns;
- clean R build/validate;
- human visual curation.
