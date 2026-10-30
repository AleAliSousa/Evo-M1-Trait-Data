# Kamiya_Pirlot_1980_TABLE1

## Status: 3 snapshot cells corrected 2026-10-13, NOT FINISHED (human check and public TSV pending)

This README replaced a 4-line stub on 2026-10-13. On the same day 3 snapshot cells were corrected to the printed values (see QA) and the analysis CSV was regenerated. The R script, definitions and registry row were not changed. The public TSV has **not** been updated yet. No registry invariant is claimed passed.

## Source → snapshot

Kamiya, T., & Pirlot, P. (1980). Brain organization in *Platanista gangetica*. *Scientific Reports of the Whales Research Institute*, 32, 105–126. Registry alternative identifier `SRWRI:32:105-126` (`DOI (or Alt)`: `SRWRI%3A32%3A105-126`).

Locus: **TABLE 1, "Volumes and progression in the brain of P. gangetica"**, printed p. 107 (PDF page 4 of the folder PDF).

The folder PDF has an unusual name, `kamiya_pirlot_1980_114NeverExisted.pdf`. [TO CHECK: what "114NeverExisted" refers to; possibly an earlier page or volume reference that turned out to be wrong.] The file holds:
- a British Library document-supply cover sheet (PDF page 1);
- the full article as **image-only scans with no usable text layer** (PDF pages 2–13; printed pp. 105–116, including Tables 1–3 and the Abbreviations);
- section and plate figures (later pages), where OCR picked up only scattered diagram labels.

The existing definitions file says the PDF is "a poor/garbled scan of brain-section diagram labels, not the article text". **That is not accurate.** The article text, the Abbreviations paragraph (p. 106) and Table 1 are present and legible as images; only the OCR text layer is missing. The component definitions marked `UNCONFIRMED` there are confirmed by the paper's Abbreviations paragraph:
- N = neocortex;
- Rh = rhinencephalon or paleocortex (P);
- S = septum;
- D = diencephalon;
- St = striatum, including the area of the capsula interna;
- H = hippocampus;
- M = mesencephalon;
- C = cerebellum, including pontine fibres;
- O = medulla oblongata.

[TO CHECK: update the definitions file accordingly. Not done here because that file was out of scope.]

Source format: scanned journal pages, legible as images, with no OCR layer for the article pages.

`Kamiya_Pirlot_1980_TABLE1_snapshot.csv` has 9 component rows and 3 value columns: volume (mm³), percent of total brain, progression index. The printed sum row (158,164.90 mm³ / 100.00) and the printed "Total brain 170 g with body-weight 17.5 kg … 842" line are not stored as rows; they are recorded here. [TO CHECK: the person who transcribed the snapshot, and the date, are not recorded.]

## Snapshot → data readable

Run `Kamiya_Pirlot_1980_TABLE1.R` in a clean R session. It:
1. reads the snapshot;
2. stops unless it finds 9 rows;
3. adds `source`;
4. writes `Kamiya_Pirlot_1980_TABLE1.csv`;
5. writes `<Item encoded>.tsv` (registry: `SRWRI%3A32%3A105-126_TABLE1`) to `__Public/comparative-data/` if the registry lookup succeeds.

The R script does not transform any values.

Method ("Material and techniques", p. 105): one *Platanista gangetica* (Indus river dolphin) from the Indus River, Pakistan. It measured 106.5 cm, weighed 17.5 kg and was assumed to be about one year old; its brain weighed 170 g. Preparation:
1. brain fixed in 1/6 formalin;
2. one sagittally cut half embedded in paraffin, sectioned at 10 µm and Nissl-stained;
3. photographs of 108 sections were prepared in Montréal (collection number P285);
4. volumes of nine components were estimated in Tokyo, following Stephan, Bauchot & Andy (1970).

Progression index: the structure's size relative to that expected for a "basal insectivore" of the same body weight (100 = basal).

Units: mm³; percent of total brain; progression index (dimensionless, 100 = basal insectivore).

Observation level: **one individual, a juvenile** (n = 1); one row per brain component.

Data role: **primary** (the authors' own measurements).

## Known limitations

- **Juvenile, half brain:** a single, approximately one-year-old specimen; volumes come from one hemisphere. [TO CHECK: whether the reported volumes were doubled to whole-brain values; the text says one half was sectioned.]
- **Rh scope:** Rh includes paleocortex, and the paper notes that the olfactory bulb is absent in odontocetes.

## QA and online database

On 2026-10-13 an AI assistant (not a human) compared the 27 snapshot values with a rendered 300 dpi image of the printed table. 3 cells differed, and they were corrected in the snapshot the same day:

| Component | Field | Printed (as read from the image) | Old snapshot | New snapshot |
|---|---|---|---|---|
| Rh | volume_mm3 | 3,599.59 | 3596.59 | 3599.59 |
| D | volume_mm3 | 9,893.12 | 9898.12 | 9893.12 |
| N | progression_index | 3,909 | 3903 | 3909 |

The arithmetic supports the two volume corrections. The corrected volumes sum to 158,164.81, against the printed total of 158,164.90; the old values summed to 158,166.81. The D percentage (6.25) also fits 9,893.12 (6.255%) better than 9,898.12 (6.258%). No arithmetic check is possible for the progression index: 3,909 vs 3,903 rests on the image reading alone, and the 9/3 digits are close on this scan. **[TO CHECK: a human should confirm all three digits against p. 107.]**

`Kamiya_Pirlot_1980_TABLE1.csv` was regenerated with the same transformation as the R script (snapshot + `source`, R `write.csv` formatting). R itself was not run; the formatter reproduces the previous CSV exactly from the previous snapshot.

Expected analysis rows: **9**. Definitions: `reference_tables/Kamiya_Pirlot_1980_TABLE1_definitions.csv` (its UNCONFIRMED notes are now answered by the Abbreviations paragraph; see above). Registry public TSV: `SRWRI%3A32%3A105-126_TABLE1.tsv`, which still holds the 3 old values.

Pending:
- human confirmation of the 3 digits;
- **re-run `Kamiya_Pirlot_1980_TABLE1.R`** in R to rewrite the public TSV;
- update the definitions' UNCONFIRMED notes;
- clean R build/validate.
