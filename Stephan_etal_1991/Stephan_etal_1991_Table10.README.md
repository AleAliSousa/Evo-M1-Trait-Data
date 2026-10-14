# Stephan_etal_1991_Table10 — prepared source-faithful package

## Source and scope

Stephan, H., Baron, G., & Frahm, H. D. (1991). *Insectivora* (Vol. 1).
Springer. Book DOI: https://doi.org/10.1007/978-1-4613-9124-1 .
Year 1991 and the exact existing registered Item name are retained.
Source: `Stephan_etal_1991.pdf`, a 178-page scan/table-and-atlas extract;
the second supplied tables PDF is byte-identical, not independent evidence.
Source locus: Table 10 pp.416–417 (PDF22–23); units Table 1 p.396.
This extract starts Chapter 10 at printed p.395: **complete Methods pp.12–24 are absent**.
Later atlas methods do not establish these tables' measurement convention.

## Source → frozen snapshot → analysis

- `Stephan_etal_1991_Table10_snapshot.csv`: the **published grid**, not a cleaned-data duplicate.
  Caption, cross-table headings, family rows, page continuation, column order,
  historical/abbreviated names, units, all printed values/native precision, blanks
  and abbreviation notes are preserved. CSV carries multi-tier headings as separate
  rows; semantically meaningful grouping is not flattened into analysis metadata.
- `Stephan_etal_1991_Table10.R`: reads that frozen file and item-scoped context; no measurement
  literals are embedded in R. Row filtering, family-heading propagation, numeric
  parsing, context joining and CSV writing are explicit in code. No unit conversion
  is needed. No taxonomic harmonization, laterality scaling, imputation, recalculation
  or correction of printed rounding is performed.
- `Stephan_etal_1991_Table10.csv`: **actual Python-generated analysis preview** (50 rows), not proof
  of a successful R build. R writes the same analysis schema on later local execution.
- `reference_tables/Stephan_etal_1991_Table10_context.csv`: exact printed-row joins with row-level
  provenance, age/weight scope, method holds and FALSE eligibility gates.
- `reference_tables/Stephan_etal_1991_Table10_abbreviations.csv`: source definitions/notes, joinable
  by the measurement column's author abbreviation.
- `reference_tables/Stephan_etal_1991_Table10_definitions.csv`: exact ten-column dictionary covering
  every analysis column plus method and observation notes. Metadata Measure is blank.
  Volume role `info` explicitly denotes unresolved provenance; it does not assert
  that all reported volumes are secondary or certify them as primary raw histology.

## Author parts and dependencies

Keep `OBL, MES, CER, DIE, TEL` as the five author-reported parts, in printed order.
The abbreviation file retains the source definitions and component-table notes.
Do **not** map CER into an extra VPO-containing canonical concept without method evidence.
OBL in Table 16 repeats Table 10 for 30 taxa: do not ingest these again as independent
observations. Table 8 NET approximately equals the sum of Table 10 parts as expected
part–whole/rounding context; neither table is used to repair the other.

## Critical provenance and scientific holds

Table 5 p.409 footnote b reports **Geogale aurita weight data only as secondary inferred**
from Rehkämper et al. (1986); the basis of every volume is not established by that
weight footnote. Keep its author-reported volumes and the weight-level scope.

Footnote c says **Hylomys suillus composition was measured from one juvenile brain**
(actual BoW 31.4 g / BrW 957 mg). Adult BoW about 57 g and expected BrW 1200 mg are
inferred using literature body weights and cranial capacities (n=7). That n=7 is not
the volume sample size. Author volume values remain untouched, but adult-scaled-volume
status, normalization and provenance are held; n=1 does not make them original adult volumes.
Do not blanket-label all measures secondary when their basis is unknown.

All rows have `Primary_ingestion_eligible=FALSE` and
`Method_compatible_merge_eligible=FALSE`. Full Methods, calibration/fixation/shrinkage,
normalization, specimen identity/overlap, age, taxon concepts and laterality need review
before primary ingestion or a method-compatible merge. There is no certification of
independent raw histology, fresh whole-brain volume or combined left+right convention.
Table 3 standards, Table 5 masses and brain parts are dependent context, not additional
independent records. 53 weight taxa do not equal 50 volume taxa or biological n.

## Reader, source glyphs and checks

Transcription and checks by **GitHub Copilot AI**, 2026-10-10, from the supplied scan,
using installed pdftotext/pdftoppm; all four table pages were read as rendered source
images, with the text layer only an aid. Native numerical strings were checked against
the published grid. The text layer omits three printed n=1 glyphs in each table:
Scalopus aquaticus, Ruwenzorisorex suncoides, Myosorex babaulti.
Each is visible in **this own table's scan** and transcribed from it, not imputed or
borrowed. No source n blanks are visible on these four pages; future genuine blank
cells remain missing under the reader. Source names/punctuation are scan-checked,
not modernized from OCR. **AI checking is not human visual curation**; that field is blank.

Python source/static checks cover frozen-vs-preview numerical value parity,
full dictionary/schema/context joins, roles/holds, shape and preservation of source
strings. Numeric analysis serialization may differ (e.g. 250 and 250.0 are equal);
frozen-source native precision is strict. Private QA evidence is not part of this package.
R/Rscript is absent: R parse, source/sys.source, clean-session execution and canonical
audit/dry-run/build/validation are all **NOT RUN**. No FINISHED or human-review claim.

## Local exact-item R execution (future owner step)

Place only these scientific files into the existing publication folder in a complete
local repository. Do not overwrite differing files without reconciliation. Install
`readxl` in that local R environment if needed, then source this exact reader:

```r
source("Stephan_etal_1991/Stephan_etal_1991_Table10.R", local = new.env(parent = baseenv()))
```

The reader searches `ofile` and `file` source frames before wrapper `--file`, derives
`folder`, `base` and `item_name` from its saved filename, and freshly resolves
`item_encoded` by **exact Item name** from the current `__ReadMe.xlsx`.
No stale registry row number or guessed encoded stem is used. All utils IO is explicit
for the canonical baseenv-parent environment. Public TSV export is withheld by default;
only an explicit owner `EVOM1_WRITE_PUBLIC_TSV=YES` opt-in enables a shelf TSV, never
primary ingestion or merge eligibility. Nothing was exported/uploaded in preparation.
Run each exact item separately: a folder-wrapper run may select only its first reader.

## Handoff status

Prepared scientific files only; R NOT RUN, public TSV WITHHELD, shared upload NOT
ATTEMPTED. Original PDFs, shared registry, collection keys, merge files, prior handoffs
and the old portable workflow are unchanged. Owner registry proposals are separate;
blank proposal cells mean NO CHANGE, especially DOI override, Progress stage and
Human visual curation. Do not delete or re-register these already registered items.
