# Paper folders added on 2026-11-18: naming and item audit

Scope: the six paper folders added in the morning commits (Beatty &
Laughlin 2006; Castillo-Morales et al. 2016; González-Lagos et al. 2010;
Gonzalez-Voyer et al. 2016; Kruska 1980; Röhrs 1986), plus the source-only
Balcarcel et al. 2022 folder added in the morning backup. The Hevner
folders were built on 2026-11-17 and are outside this audit.

The check used the live `__ReadMe.xlsx` Sheet1, the repository's
`_tools/dataset_builder/audit_dataset_item.R`, the item conventions in
`_skills/build-dataset-item/SKILL.md`, CSV/TSV cell comparisons, R builds
in isolated temporary copies, and PDF page-count/integrity checks with
`pdfinfo`. It did **not** repeat a visual comparison of every transcribed
table cell against the page images.

## Findings by folder

| Folder | State after this audit | Remaining action |
| --- | --- | --- |
| `Beatty_Laughlin_2006` | One registered item; CSV, public TSV, definitions and source files present. R output matches committed data. | Freeze Table 1 from the article XML as `Beatty_Laughlin_2006_Table1_snapshot.*`; make the reader consume that snapshot. |
| `CastilloMorales_etal_2016` | One registered item; CSV, public TSV, definitions and source files present. R output matches committed data. | Freeze printed Table 1 as an item snapshot and make the reader consume it. Build the join-ready `Source_ref_no` citation lookup for refs 84–99. |
| `GonzalezVoyer_etal_2016` | One registered item; CSV, public TSV, definitions, original Dryad source and byte-identical item snapshot present. R reader consumes the snapshot and reproduces the committed data. | Complete the descriptive registry metadata. |
| `Kruska__1980` | Two registered items; CSVs, public TSVs, definitions, PDF and an extraction archive present. R outputs match committed data. | Copy the verified `extracted_tables/` source views into separate item snapshots and make each item reader consume its own snapshot. Split the shared two-item R script into one reader per item. |
| `Röhrs__1986` | Two registered items; filenames now use the current folder spelling; CSVs, public TSVs, definitions and PDF present. Both R outputs match the committed files by cell. | Freeze both printed tables as separate item snapshots; make the readers consume them and split the shared script. |
| `GonzalezLagos_etal_2010` | Source-only paper record; the cited 493-species dataset is absent, as its README states. No item CSV or TSV was invented. | Locate the underlying dataset or retain the folder as a methods/source record. Remove the case-only duplicate tracked README (`.README.md` and `.ReadMe.md`), which cannot coexist on this case-insensitive filesystem. |
| `Balcarcel_etal_2022` | Source-only folder with article PDF and three publisher supplements; folder README added. | Inspect the supplementary workbook and choose the item(s) to build. Its current registry citation is a placeholder with blank Item number, generated Item name ending `_`, and no public TSV; do not treat it as a registered item. |

## Shared item issues

- All seven registered items have one matching public TSV and a registry row.
  The CSV and TSV agree cell by cell for each item. Every CSV column now
  has a definition, and every definitions file parses to the ten-column
  schema. Seventeen malformed definitions rows were repaired, and `note`
  definitions were added for Kruska Tabelle 2 and Röhrs Table 1.
- Four dataset folders still lack item-specific snapshots, covering six
  registered items. The existing R scripts for those items embed
  transcriptions in code rather than reading a frozen snapshot. Kruska
  and Röhrs each have one R script producing two item outputs, contrary
  to the one-reader-per-item convention.
- Each of the seven new item registry rows has only 6 of 29 descriptive
  columns populated. The original title, data role, source provenance,
  snapshot details, and visual-check field are blank. The workbook had
  pre-existing uncommitted edits when this audit began and was not
  changed here.
- The item scripts now write to repo-level
  `__Public/comparative-data/`; their previous `public_tsv/` destination
  did not exist. README references to that path and to pending registry
  rows were corrected.

The remaining steps require source-facing curation. A derived analysis
CSV should not be relabelled as a snapshot of a printed table, and a
missing González-Lagos dataset should not be reconstructed from its
later descendant without marking it as a new derivation.
