# Pirlot_Nelson_1978_TABLE3

## Status: snapshot in printed layout, reader with table checks, values flagged and compared with other data, 2026-10-15; NOT FINISHED (R run and human visual check pending)

On 2026-10-15 the snapshot was changed from a long 36-row list to the **layout of the printed Table 3** (same filename), and the R reader was changed to read that layout and to check the table against its own printed totals (see *Table checks*). The analysis CSV keeps the same schema, rows and all 66 reported numbers. R has **not** been run on this version yet, so the analysis CSV and public TSV have not been regenerated.

Later the same day, at the owner's request, the printed unit and the inconsistent cells were **flagged** in `reference_tables/Pirlot_Nelson_1978_errata.csv` (values kept as printed) and the values were **compared with other data for the same and similar species** (see *Flags* and *Comparison with other data*).

## Source → snapshot

Pirlot, P., & Nelson, J. (1978). Volumetric analyses of monotreme brains. In *Monotreme biology* (pp. 171–180). The Royal Zoological Society of New South Wales. OCLC:1340515946 (registry `DOI (or Alt)`: `OCLC%3A1340515946`). The document-supply cover sheet gives the publication as "Monotreme Biology: Symposium, Royal Zoological Society of NSW, Sydney, May 1978 Proceedings", published by the Society in 1979. The folder and registry keep **1978**, the symposium year. [TO CHECK: the registry citation's editor field reads "A. M. L. (Ed.)", which looks incomplete.]

Locus: **TABLE 3, "Absolute volumes of various brain structures and their percentage of total brain volume"**, printed p. 175 (PDF page 6 of `pirlot_nelson_1978.pdf`, held unchanged). PDF page 1 is a British Library document-supply cover sheet.

Source format: library-supplied scan (600 ppi, 1-bit) with an Adobe Paper Capture OCR text layer. The table is legible as an image; the OCR layer has character errors and is not a numerical authority.

`Pirlot_Nelson_1978_TABLE3_snapshot.csv` is laid out like the printed table (24 rows × 7 columns), so it can be read side by side with PDF page 6:

| Rows | Content |
|---|---|
| 1–3 | `TABLE 3` and the two caption lines |
| 4 | blank (printed rule) |
| 5–7 | `PLATYPUS` / `ECHIDNA` / `OPOSSUM`, each over an `Abs. vol.` and a `% of total brain` column, with the printed unit line |
| 8–19 | the 12 components in printed order with their printed labels (`Mes` twice; `Cbl`), dashes `—`, thousands commas and trailing zeros |
| 20 | the printed **total row** (it has no label in print) |
| 21 | blank (printed rule) |
| 22–24 | the footnote that expands the codes, with its printed line breaks and hyphens |

Unit line: the table prints the absolute volumes as `mm²`. The superscripts are hard to read on this scan: the PLATYPUS and OPOSSUM ones read `mm²`, the ECHIDNA one looks like `mm³`, and the snapshot keeps them as read. These are volumes (caption, Methods), so the owner decided on 15 Oct 2026 that the unit must be mm³: the values are read as mm³ with no conversion, and the printed unit is flagged as erratum **E001** (see *Flags*). The comparison with other data confirms mm³.

Who and when: an AI assistant re-laid the snapshot out on 2026-10-15. The 66 numbers are those of the previous snapshot (unchanged); the caption, headings, unit line, total row and footnote were added from the page, and every cell was compared with the scan of PDF page 6 (SHA-256 `a64f1685be99f13843c975a12a923231e8dbd1479142b57ce87b66afff8b8f34`). This is not a human visual check: the `Human visual check of snapshot` column in `__ReadMe.xlsx` stays blank until a person has compared it. The original transcriber of the 66 numbers is not recorded.

View the CSV on GitHub or in a text editor. Do not open and re-save it in Excel: that would drop trailing zeros (`5.90`) and the reader uses the printed decimals for its checks.

## Snapshot → data readable

Run `Pirlot_Nelson_1978_TABLE3.R` in a clean R session. It:
1. reads the snapshot as text and stops if the caption, headings, unit line, row labels or grid size differ from the printed layout;
2. parses the 12 component rows: thousands commas removed, a printed `—` becomes `NA` (never zero);
3. maps the column headings to the binomials printed in Material and methods (p. 171) — *Ornithorhynchus anatinus*, *Tachyglossus aculeatus*, *Didelphis marsupialis* — and the row labels to the existing analysis codes (the second `Mes` is `Mesocortex`, by the footnote's order "… medulla oblongata and mesocortex"; printed `Cbl` keeps the existing code `CbI`), giving the same 36-row long table as before;
4. checks the table against its printed totals (below), keeps the results in a `table_checks` data frame and warns about mismatches — **it never changes a value**;
5. writes `Pirlot_Nelson_1978_TABLE3.csv` and `<Item encoded>.tsv` (registry: `OCLC%3A1340515946_TABLE3`) to `__Public/comparative-data/`.

`table_checks` is not written to a file; `build_dataset_item()` attaches it to its report.

Method (Material and methods, p. 171): one *Ornithorhynchus anatinus* (body 1040 g, brain 9.169 g) and one *Tachyglossus aculeatus* (body 4120 g, brain 27.518 g). Preparation:
1. perfused with saline, then 20% formalin, and stored for a week in 10% formalin;
2. brains dissected out and weighed, embedded in paraffin, and cut serially at 10 µm;
3. every *n*th section Nissl-stained, and 100–200 sections per species photographed;
4. areas measured and volumes calculated from the photographs, following Stephan & Pirlot (1970).

One *Didelphis marsupialis* (body 1205 g, brain 6.885 g) was "treated in the same way" for comparison.

Units: mm³ and percent of total brain volume.

Observation level: **one individual per species** (n = 1 each); one row per species × component.

Data role: **primary** for platypus and echidna. The opossum is also the authors' own measurement, but it is the same specimen as `Pirlot__1981_TABLEI` row 1 (P313, 1205 g, 6885 mg) and the *Didelphis marsupialis* column of `Pirlot__1981_TABLEII`. Do not merge it as an independent observation.

## Table checks (printed totals)

Table 3 prints a total for each column, so the reader checks the table against itself before writing anything. Rules:
- numbers are compared in whole units of their last printed decimal (no floating-point drift);
- a sum leaves out the dash cells (not reported — they are not zeros);
- tolerance is what rounding of the printed cells can explain: half a unit per summed cell (0.055 for 11 cells at 0.01), and one unit (0.01) for a percentage recomputed as 100 × volume / printed total;
- a mismatch is warned and recorded; the printed values are kept.

Expected results, computed outside R from the snapshot with exact decimal arithmetic (**R execution pending**):

| Check | PLATYPUS | ECHIDNA | OPOSSUM |
|---|---|---|---|
| Sum of the 11 printed volumes vs printed total | 8131.89 vs 8571.45 (−439.56) **mismatch** | 26,146.2 vs 26,578.2 (−432.0) **mismatch** | 6487.89 vs 6487.89 (0) pass |
| Sum of the 11 printed percentages vs 100.00 | 94.88 (−5.12) **mismatch** | 98.47 (−1.53) **mismatch** | 100.00 (0) pass |
| Each percentage vs 100 × volume / printed total | 11 pass (6 of them differ by 0.01) | 7 pass; **4 mismatch**: Hip +0.02, Pal −0.11, Str −0.83, Di +0.81 | 11 pass |
| Not checkable (dash) | second `Mes` | second `Mes` | `Scz` |

In total: **42 checks — 31 pass, 8 mismatch, 3 not evaluable.** Differences are calculated minus printed.

What the checks show:
- The **opossum** column is internally consistent: its 11 volumes and percentages add up exactly to the printed totals.
- The **platypus and echidna** volumes fall short of their printed totals by 439.56 and 432.0. Their printed `Med` rows repeat the first `Mes` row exactly (163.56 / 1.91 and 686.7 / 2.58), so a misprinted `Med` row is the likely cause: if the totals are right, `Med` would be ≈ 603.12 (7.04%) and ≈ 1118.7 (4.21%). The `Med` percentages pass their own check only because they repeat the `Mes` pair consistently.
- The **echidna** `Str` and `Di` percentages do not fit their volumes and look swapped (1553.5 → 5.85%, 1768.3 → 6.65%; printed 6.68 and 5.84). `Pal` (20.22 vs 20.33) and `Hip` (6.67 vs 6.65) are also beyond rounding.
- The six 0.01 differences for the platypus are within the authors' rounding.

None of these values is changed. Owner, 15 Oct 2026: flag these values and compare them with other data from the same or similar species. They are kept as printed and flagged below.

## Flags (errata)

`reference_tables/Pirlot_Nelson_1978_errata.csv` (`_tools/dataset_builder/ERRATA_CONVENTION.md`) is the authoritative record; merges read it and carry `errata_id` / `errata_status` beside the values. No value in the snapshot, CSV or TSV is changed.

| id | cells | printed | issue | proposed | status |
|---|---|---|---|---|---|
| E001 | all absolute volumes (unit line) | mm² | printed unit wrong: volumes are mm³ | mm³, values unchanged | confirmed (owner, 15 Oct 2026) |
| E002 | PLATYPUS Med | 163.56; 1.91% | repeats Mes; column 439.56 short of its total | 603.12; 7.04% (total-inferred) | proposed |
| E003 | ECHIDNA Med | 686.7; 2.58% | repeats Mes; column 432.0 short of its total | 1118.7; 4.21% (total-inferred) | proposed |
| E004 | ECHIDNA Str % | 6.68 | does not fit its volume; Str/Di look transposed | 5.85 | proposed |
| E005 | ECHIDNA Di % | 5.84 | does not fit its volume; Str/Di look transposed | 6.65 | proposed |
| E006 | ECHIDNA Pal % | 20.33 | does not fit its volume | 20.22 | proposed |
| E007 | ECHIDNA Hip % | 6.65 | does not fit its volume (by 0.02) | 6.67 | proposed |
| E008 | OPOSSUM Med | 572.13; 8.82% | repeats Bul; same brain gives 566.0 in Pirlot 1981 | — | proposed |

Proposed values are for rule-based substitution or exclusion in merges, never edits of the data; the total-inferred medulla values are not independent measurements. Running `render_errata("Pirlot_Nelson_1978")` adds the matching notes to the definitions file. (It looks for `<Item>.README.md` or `<Item>.md`, so it will not find this `.ReadMe.md` file; this table is a hand-written summary, not its generated block.)

## Comparison with other data (same and similar species)

On 15 Oct 2026 the Table 3 values were compared with all other measurements of these species in the repository: the same opossum specimen (P313) in `Pirlot__1981_TABLEII`, `Ashwell__2020_SupplementaryTable` (brain and cerebellum volumes), `Bush_Allman_2003_Table1` and `Bush_Allman_2004_a_Table2` (opossum), and brain masses from `__merging_brain_mass`; congeners give the scale for component shares. The check (script and reports) lives in the restricted repository, `restricted_checks/Pirlot_Nelson_1978/comparison/`; it has been computed outside R and is **R execution pending**. Results:

- **The values are volumes in mm³.** The printed totals match the same brains' fresh weights (Methods) converted to volume at 1.036 g/cm³: ratios 0.968 (platypus), 1.001 (echidna), 0.976 (opossum). The opossum total matches its re-publication in Pirlot 1981 TABLE II, in "cubic mm", to 0.04% (6487.89 vs 6485.0), and its hippocampus, septum, olfactory bulb, mesencephalon and cerebellum are all 0.984 × the 1981 values. Areas in mm² could not match brain weights and cubic-mm volumes like this.
- **Same species, other specimens: within normal spread.** Totals and cerebella are 0.76–1.32 × the values of Ashwell 2020 and Bush & Allman 2003/2004, and the totals are within the range of published brain masses. The echidna brain is 1.32 × Ashwell's three echidnas for both the whole brain and the cerebellum (cerebellum 5.98% vs 5.99%): a larger animal, not a unit problem.
- **Medulla.** All three `Med` cells repeat another row. The platypus and echidna medulla shares (1.91%, 2.58%) are far below the opossum's 8.82% and 8.73–11.31% in *Didelphis* (Pirlot 1981); no other monotreme medulla data exist in the repo to confirm E002 or E003. For the opossum, the 1978 medulla (572.13) is close to the 1981 value for the same brain (566.0), which also supports the 1981 correction from the printed 66.0 (`Pirlot__1981-E001`).
- **Echidna percentages** (E004–E007) cannot be tested against other data: no other echidna component volumes exist in the repo.

## Known limitations

- **Medulla (Med) rows** for platypus and echidna duplicate the mesencephalon (`Mes`) rows (E002, E003).
- **Echidna percentages** for `Str`, `Di`, `Pal` and `Hip` do not match their volumes (E004–E007).
- **Opossum Med** equals `Bul` (572.13 / 8.82). The column adds up exactly to the printed total; the same brain's medulla is 566.0 in Pirlot 1981 (E008).
- **Unreported cells:** the opossum has no schizocortex value, and mesocortex is reported only for the opossum (dashes).
- **Unit:** printed mm²; the values are mm³ (E001).

## QA and online database

On 2026-10-13 an AI assistant (not a human) compared all 66 numeric cells with a rendered image of the printed table. 4 cells held values that were neither printed nor implied by the column totals. They were reset to the **printed** values the same day:

| Species | Component | Field | Printed = snapshot | Old snapshot |
|---|---|---|---|---|
| Tachyglossus aculeatus | Str | percent | 6.68 | 5.68 |
| Tachyglossus aculeatus | Di | percent | 5.84 | 6.64 |
| Ornithorhynchus anatinus | Med | volume | 163.56 | 663.56 |
| Ornithorhynchus anatinus | Med | percent | 1.91 | 7.74 |

On 2026-10-15 the 66 numbers were checked again against the page while laying out the new snapshot; all match the print. The new reader was checked outside R by reproducing its steps on the snapshot: it gives exactly the current `Pirlot_Nelson_1978_TABLE3.csv` (36 rows, same columns, same 66 numbers and 6 `NA` cells) and the check results above. That is not an R run.

Expected analysis rows: **36**. Definitions: `reference_tables/Pirlot_Nelson_1978_TABLE3_definitions.csv` (unchanged). Registry public TSV: `OCLC%3A1340515946_TABLE3.tsv`, which still holds the 4 old values until the reader is run.

Pending:
- **run `Pirlot_Nelson_1978_TABLE3.R`** in R (it rewrites the CSV and the public TSV) and compare its `table_checks` with the table above;
- run `render_errata("Pirlot_Nelson_1978")`, and the cross-publication check in the restricted repository;
- human visual check of the snapshot against PDF page 6, including the ECHIDNA unit superscript (then fill in the last column of `__ReadMe.xlsx`);
- confirm or withdraw E002–E008;
- de-duplicate the opossum against Pirlot 1981.
