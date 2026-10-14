# Pirlot__1981_TABLEII

## Status: README expanded, NOT FINISHED

This README replaces a 4-line stub on 2026-10-13. It documents the existing files only. No data, script, snapshot, definitions, registry row or public TSV was changed. No registry invariant is claimed passed.

## Source → snapshot

Pirlot, P. (1981). A quantitative approach to the marsupial brain in an eco-ethological perspective. *Revue Canadienne de Biologie*, 40(2), 229–250. PMID:7280305 (registry `DOI (or Alt)`: `PMID%3A7280305`).

Locus: **TABLE II**, printed pp. 234–236 (PDF pages 6–8 of `pirlot_1981.pdf`, held unchanged). The printed caption reads: "This table presents the actual volumes in cubic mm for 12 brain components and their sum making up total brain for each species. The last line is the sum of RH and PY …".

Source format: library-supplied scan with an Adobe Paper Capture OCR text layer. The table pages are legible as images, but the OCR text layer is unreliable for numbers.

`Pirlot__1981_TABLEII_snapshot.csv` holds 28 taxon rows and 12 component columns, transposed from the printed layout (where species are columns and components are rows). Two printed summary rows are left out because they can be derived: total brain, and RH + PY. The printed higher-taxon headings (Polyprotodonta / Didelphidae / … ) are also not carried over. [TO CHECK: the person who transcribed the snapshot, and the date, are not recorded.]

## Snapshot → data readable

Run `Pirlot__1981_TABLEII.R` in a clean R session. It:
1. reads the snapshot;
2. stops unless it finds the expected row count;
3. adds `source`;
4. writes `Pirlot__1981_TABLEII.csv`;
5. writes `<Item encoded>.tsv` (registry: `PMID%3A7280305_TABLEII`) to `__Public/comparative-data/` if the registry lookup succeeds.

The R script does not transform any values.

Method (pp. 232–233): component volumes come from Nissl-stained serial sections (10–40 µm). Neuronal fields were photographed, cut out of the prints and weighed; the author preferred this to an electronic area analyser. Between 115 and 130 sections were used per brain, following Stephan, Bauchot & Andy (1970). Appendix B of the paper discusses problems in delimiting some components.

Component codes (author's list, p. 233): BO bulbus olfactorius; N neocortex; RH rhinencephalon; PY pyriform cortex; S septum; Di diencephalon; STR striatum; Hi hippocampus; M mesencephalon; C cerebellum; O medulla oblongata; Sz schizocortex.

Units: mm³ (absolute volumes).

Observation level: **one row per taxon**. The printed column labels are genus-level or collapsed versions of the Table I specimen names (e.g. `Philander`, `Didelphis aurita`), and each column corresponds to the sectioned (`S`) specimen(s) in `Pirlot__1981_TABLEI`. [TO CHECK: whether any column pools more than one sectioned specimen. Table I lists one `S` specimen per taxon in most cases.] Species keys need resolving: see the note in `reference_tables/Pirlot__1981_TABLEII_definitions.csv`.

Data role: **primary** (the author's own volumetric measurements).

## Known limitations

- **Totals that don't add up in the original:** for 25 of the 28 taxa, the 12 components sum exactly to the printed total. Three printed totals don't match their components: *Caluromys* (printed 4295.1, components sum to 4294.1), *Schoinobates* (printed 4604.3 vs 4604.7) and *Vombatus* (printed 52645.7 vs 52615.7). Spot checks found these rows' component values match the page, so the mismatches look like arithmetic errors in the original. The snapshot keeps the printed component values.
- **One cell that differs from the scan:** *Didelphis marsupialis* O (medulla) appears as `66.0` on the scan, but the snapshot holds `566.0`. With 566.0 the column sums exactly to the printed total (6485.0), which suggests a lost leading digit in the scan rather than a transcription error.
- **RH vs PY:** the paper treats RH and PY separately but sums them for comparison with bat studies, where PY is not separated (caption).
- **Duplicate specimen:** the *Didelphis marsupialis* specimen (P313) is the same animal used as the opossum comparison in `Pirlot_Nelson_1978_TABLE3`. Its values are not independent observations.

## QA and online database

On 2026-10-13 an AI assistant (not a human) checked all 28 rows:
- **Totals check:** each row's components were summed and compared with the printed total and RH + PY lines. All 28 RH + PY sums match. 25 of the 28 totals match exactly; the other 3 are the printed-total mismatches listed above.
- **Image check:** the visible cells were compared with rendered page images.

This is not human visual curation, which is still pending.

Expected analysis rows: **28**. Definitions: `reference_tables/Pirlot__1981_TABLEII_definitions.csv`. Registry public TSV: `PMID%3A7280305_TABLEII.tsv`.

Pending: clean R build/validate; human visual curation; species-key resolution.
