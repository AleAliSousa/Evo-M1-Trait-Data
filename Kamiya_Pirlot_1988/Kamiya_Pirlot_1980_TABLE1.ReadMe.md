# Kamiya_Pirlot_1980_TABLE1

## Status: printed sum row and original headings restored, reader with table checks, 2026-10-15; NOT FINISHED (R run and human visual check pending)

On 2026-10-15 the snapshot was changed back to the **layout of the printed Table 1** (same filename): the caption, the original column headings, the printed sum row and the "Total brain" line are now in it, so the reader can check the table against its own sums (see *Table checks*). The N progression index was set back to the printed **3,903**, which the owner confirmed by eye the same day (see *QA*). The analysis CSV keeps the same schema and 9 rows. R has **not** been run on this version yet, so the analysis CSV and public TSV have not been regenerated.

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

Source format: scanned journal pages (600 ppi, dithered 1-bit), legible as images, with no OCR layer for the article pages. Some digits in Table 1 are hard to tell apart on the scan (9/3 especially).

`Kamiya_Pirlot_1980_TABLE1_snapshot.csv` is laid out like the printed table (13 rows × 4 columns), so it can be read side by side with PDF page 4:

| Rows | Content |
|---|---|
| 1 | the caption |
| 2 | the original headings: `Components`, `Volumes (mm³)`, `Percentages of total brain`, `Progression indices` (two-line headings written on one line) |
| 3–11 | the 9 components in printed order, with thousands commas and trailing zeros as printed |
| 12 | the printed **sum row** (no label in print): `158,164.90`, `100.00`, and `—` in the progression column |
| 13 | the printed line `Total brain` · `170 g with body-weight 17.5 kg` · (blank) · `842` |

Rows 12 and 13 are part of the printed table, not extra observations: the sum row is used only for the checks below, and 842 (the encephalization index, brain-to-body progression) and the 170 g brain weight are not read into the analysis CSV. 170 g is not converted to a volume.

Who and when: an AI assistant restored the caption, headings and rows 12–13 on 2026-10-15 from the scan of PDF page 4 (SHA-256 `4ad44d5d4aab4d80e2cca535507cc8ad7932182beb9a3892a0ee66d0617037a2`) and compared every cell with it. This is not a human visual check: the `Human visual check of snapshot` column in `__ReadMe.xlsx` stays blank until a person has compared it. The original transcriber of the 27 component numbers is not recorded.

View the CSV on GitHub or in a text editor. Do not open and re-save it in Excel: that would drop trailing zeros (`3.90`) and the reader uses the printed decimals for its checks.

## Snapshot → data readable

Run `Kamiya_Pirlot_1980_TABLE1.R` in a clean R session (Rscript, RStudio Source or `build_dataset_item()`). It:
1. reads the snapshot as text and stops if the caption, headings, component labels, sum row or grid size differ from the printed layout;
2. parses the 9 component rows (thousands commas removed) into the existing columns `component`, `volume_mm3`, `percent_total_brain`, `progression_index`, and adds `source`;
3. checks the table against its printed sum row (below), keeps the results in a `table_checks` data frame and warns about mismatches — **it never changes a value**;
4. writes `Kamiya_Pirlot_1980_TABLE1.csv` (9 rows) and `<Item encoded>.tsv` (registry: `SRWRI%3A32%3A105-126_TABLE1`) to `__Public/comparative-data/`.

`table_checks` is not written to a file; `build_dataset_item()` attaches it to its report.

Method ("Material and techniques", p. 105): one *Platanista gangetica* (Indus river dolphin) from the Indus River, Pakistan. It measured 106.5 cm, weighed 17.5 kg and was assumed to be about one year old; its brain weighed 170 g. Preparation:
1. brain fixed in 1/6 formalin;
2. one sagittally cut half embedded in paraffin, sectioned at 10 µm and Nissl-stained;
3. photographs of 108 sections were prepared in Montréal (collection number P285);
4. volumes of nine components were estimated in Tokyo, following Stephan, Bauchot & Andy (1970).

Progression index: the structure's size relative to that expected for a "basal insectivore" of the same body weight (100 = basal).

Units: mm³; percent of total brain; progression index (dimensionless, 100 = basal insectivore).

Observation level: **one individual, a juvenile** (n = 1); one row per brain component.

Data role: **primary** (the authors' own measurements).

## Table checks (printed sum row)

Table 1 prints the sum of the volume and percentage columns (row 12), so the reader checks the table against itself before writing anything. Rules:
- numbers are compared in whole units of their last printed decimal (no floating-point drift);
- tolerance is what rounding of the printed cells can explain: half a unit per summed cell (0.045 for 9 cells at 0.01), and one unit (0.01) for a percentage recomputed as 100 × volume / printed sum;
- progression indices are not checked: they are ratios, not additive, and their sum cell is printed as `—`;
- a mismatch is warned and recorded; the printed values are kept.

Expected results, computed outside R from the snapshot with exact decimal arithmetic (**R execution pending**):

| Check | Calculated | Printed | Difference | Result |
|---|---:|---:|---:|---|
| Sum of the 9 volumes (mm³) | 158,164.81 | 158,164.90 | −0.09 | **mismatch** |
| Sum of the 9 percentages | 100.00 | 100.00 | 0.00 | pass |
| Each percentage vs 100 × volume / printed sum | 9 of 9 within 0.01 | | N −0.01, Rh +0.01, St −0.01; others 0 | pass |

In total: **11 checks — 10 pass, 1 mismatch.** Differences are calculated minus printed.

What the checks show: the volumes add up to 0.09 mm³ less than the printed sum, which is more than rounding of nine two-decimal values can explain (0.045). The table does not show which cell (or the sum itself) is off, so nothing is changed. The three 0.01 percentage differences are rounding: the printed percentages were evidently adjusted to add up to exactly 100.00.

Outside the table: Table 3 on p. 109 (PDF page 6) prints *Platanista gangetica* with Br 842, N 3,903, Rh 123 and C 671, and the text above it gives the neocortex value as "(3,903)". These match Table 1 and settle the N progression index (see *QA*). This cross-table comparison is recorded here, not computed by the reader.

## Known limitations

- **Juvenile, half brain:** a single, approximately one-year-old specimen; volumes come from one hemisphere. [TO CHECK: whether the reported volumes were doubled to whole-brain values; the text says one half was sectioned.]
- **Rh scope:** Rh includes paleocortex, and the paper notes that the olfactory bulb is absent in odontocetes.
- **Volume sum:** 0.09 mm³ short of the printed sum (see *Table checks*).

## QA and online database

On 2026-10-13 an AI assistant (not a human) compared the 27 snapshot values with a rendered 300 dpi image of the printed table and changed 3 cells:

| Component | Field | Before 2026-10-13 | 2026-10-13 | Now (2026-10-15) |
|---|---|---|---|---|
| Rh | volume_mm3 | 3596.59 | 3,599.59 | 3,599.59 (kept) |
| D | volume_mm3 | 9898.12 | 9,893.12 | 9,893.12 (kept) |
| N | progression_index | 3903 | 3,909 | **3,903 (reverted; owner-confirmed)** |

- Rh and D: both read clearly on the scan and are kept. The arithmetic supports them: the 9 volumes now sum to 158,164.81 against the printed 158,164.90 (the old values summed to 158,166.81), and the D percentage (6.25) fits 9,893.12 better than 9,898.12.
- N progression index: the last digit is ambiguous on the Table 1 scan, but the same paper prints the value twice more, clearly as **3,903** (Table 3 and the text on p. 109). The 2026-10-13 change to 3,909 is therefore reverted. **Owner check, 15 Oct 2026 (Alexandra de Sousa): the two clearer prints read 3903.** This confirms that one value by eye; it is not a full visual check of the snapshot. The analysis CSV and public TSV will carry 3903 after the next R run. (The public TSV still holds the pre-2026-10-13 values, so its N value is already 3903.)

On 2026-10-15 all 27 component numbers were checked again against the page while restoring the snapshot. The new reader was checked outside R by reproducing its steps on the snapshot: it gives the current `Kamiya_Pirlot_1980_TABLE1.csv` except for N `progression_index` (3909 → 3903), and the check results above. That is not an R run.

Expected analysis rows: **9**. Definitions: `reference_tables/Kamiya_Pirlot_1980_TABLE1_definitions.csv` (unchanged; its UNCONFIRMED notes are answered by the Abbreviations paragraph, see above). Registry public TSV: `SRWRI%3A32%3A105-126_TABLE1.tsv`.

Pending:
- **run `Kamiya_Pirlot_1980_TABLE1.R`** in R (it rewrites the CSV and the public TSV) and compare its `table_checks` with the table above;
- human visual check of the rest of the snapshot against PDF page 4 (N progression index already confirmed; then fill in the last column of `__ReadMe.xlsx`);
- update the definitions' UNCONFIRMED notes;
- clean R build/validate.
