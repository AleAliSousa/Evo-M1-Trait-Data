# Kaufman (2004) — dissertation appendix tables A1–A15

Kaufman, J. A. (2004). *Pattern and scaling of regional cerebral glucose metabolism in
mammals* (Publication No. 3147447) [Doctoral dissertation, Washington University in St.
Louis]. ProQuest Dissertations & Theses Global. Identifier: **UMI:3147447**.

Item names follow `__ReadMe.xlsx`: **`Kaufman__2004_TableA1` … `Kaufman__2004_TableA15`**.

The dissertation's Appendix reports, per brain region, the regional cerebral **metabolic
rate** for glucose (CMRgl) and oxygen (CMRO2) and the regional cerebral **blood flow**
(CBF), compiled from the PET / Sokoloff / Kety-Schmidt / microsphere / NMR literature plus
Kaufman's own PET data ("Present Study"). Tables **A1–A14** are the per-study raw data;
**A15** is the computed species-means summary ("Species Means in Conscious Subjects").

## Pipeline (same golden rule as the other papers)

The snapshots transcribe the dissertation tables, but their original PDF text-layer
extraction contains OCR errors and is not a verbatim representation of the printed pages.
Page-verified transcription corrections are made in the snapshots; further cleaning
happens in the `.R` scripts, including the checked shared overlay in
`Kaufman__2004_source_corrections.R`. Checks live in the restricted companion repository.

```
<dissertation PDF / xlsx>
      │  transcription (OCR and page checks)
      ▼
Kaufman__2004_TableAxx_snapshot.csv      ← source-table transcription
      │  Kaufman__2004_TableAxx.R  (parse numbers, add Region/units, trim)
      ▼
Kaufman__2004_TableAxx.csv               ← use this
      │  (same script)
      ▼
__Public/comparative-data/UMI%3A3147447_TableAxx.tsv   ← DOI/UMI-named public copy
```

Each table's `.R` derives its own name from the filename and matches `__ReadMe.xlsx`.
The A1–A14 scripts read their snapshots plus the shared correction overlay and citation
map. Column meanings and units are in
`reference_tables/Kaufman__2004_definitions.csv`.

## Files

| Path | Role |
|---|---|
| `Kaufman__2004_dissertation.pdf` | Source dissertation. |
| `Kaufman__2004_dissertation.xlsx` | Digitized capture of every dissertation table (104 sheets), used to cross-check the PDF extraction. |
| `Kaufman__2004_TableA1..A15_snapshot.csv` | Source-table transcriptions used by the build; unchecked OCR errors may remain. |
| `Kaufman__2004_TableA1..A15.R` | Preparation: snapshot → clean CSV (+ UMI-named TSV). |
| `Kaufman__2004_source_corrections.R` | Checked overlay for confirmed OCR/column-shift defects in A1-A14; never edits snapshots. |
| `reference_tables/Kaufman__2004_citation_corrections.csv` | Explicit observed-to-corrected citation map with source IDs and evidence locators. |
| `Kaufman__2004_TableA1..A15.csv` | Clean, analysis-ready tables. **Use these.** |
| `reference_tables/Kaufman__2004_bibliography.csv` | Source-local transcription of all 504 Literature Cited entries, with PDF page spans and transcription review status. |
| `reference_tables/Kaufman__2004_bibliography_ocr_audit.csv` | Page-checked corrections to the initial bibliography OCR, retaining the original text for each changed entry. |
| `reference_tables/Kaufman__2004_TablesA1-A14_references.csv` | Exact cleaned table citation → full cited-source bibliography entry, source level/type, stable source ID, and primary ID where applicable. |
| `Kaufman__2004_build_source_matches.R` and `reference_tables/Kaufman__2004_TableA*_reference_columns.csv` | Build per-table reference lists and source matches using curated measurement-column scopes. |
| `old/Kaufman__2004_TableA*_ocr_capture.csv` | Earlier OCR captures, preserved before page-verified snapshot corrections. |
| `reference_tables/Kaufman__2004_snapshot_reference_repairs_A1-A7.csv` and `Kaufman__2004_snapshot_citation_audit_A8_A10-A14.csv` | Citation corrections checked against the printed PDF pages, with row and page locators. |
| `reference_tables/Kaufman__2004_snapshot_cell_audit_A10.csv` | Page-checked sample-size and anesthesia repairs. |
| `old/Kaufman__2004_TableA9_snapshot_audit.md` | Full Table A9 snapshot check against both printed pages. |
| `reference_tables/Kaufman__2004_definitions.csv` | Data dictionary (documentation only; not read by the scripts). |
| `old/` | Superseded Python build/compare scripts and earlier comparison outputs. |

## The 15 tables

| Item | Region (dissertation title) | Kind | Rows |
|---|---|---|---:|
| `TableA1`  | Basal Ganglia rCMR & rCBF | per-study | 121 |
| `TableA2`  | Hippocampus rCMR & rCBF | per-study | 86 |
| `TableA3`  | Thalamus rCMR & rCBF | per-study | 126 |
| `TableA4`  | Cerebellum rCMR & rCBF | per-study | 87 |
| `TableA5`  | White Matter rCMR & rCBF | per-study | 82 |
| `TableA6`  | Neocortex rCMR & rCBF | per-study | 151 |
| `TableA7`  | Frontal Cortex rCMR & rCBF | per-study | 119 |
| `TableA8`  | Parietal Cortex rCMR & rCBF | per-study | 103 |
| `TableA9`  | Temporal Cortex rCMR & rCBF | per-study | 65 |
| `TableA10` | Auditory Cortex rCMR & rCBF | per-study | 51 |
| `TableA11` | Occipital Cortex rCMR & rCBF | per-study | 111 |
| `TableA12` | **Sensorimotor Cortex** rCMR & rCBF | per-study | 76 |
| `TableA13` | **Cingulate Cortex** rCMR & rCBF | per-study | 62 |
| `TableA14` | Whole Brain CMR & CBF (direct measurement) | per-study | 195 |
| `TableA15` | Species Means in Conscious Subjects | species means | 284 |

### ⚠ A12 / A13 numbering — please confirm

The **dissertation itself prints A12 = _Sensorimotor Cortex_ and A13 = _Cingulate
Cortex_**, and the tables are built and named accordingly here. In the current
`__ReadMe.xlsx` the *Item full original title* cells for these two items are **swapped**
(`TableA12` is labelled "A13. Cingulate", `TableA13` is labelled "A12. Sensorimotor").
I have aligned the titles to the dissertation (see "ReadMe.xlsx updates" below); if you
deliberately intended the opposite item→region mapping, flip the two `_snapshot.csv` /
`.csv` / titles and tell me.

(A13's first-page header was lost in the PDF OCR — its region continues from the
"Table A13, cont." pages; the data restart at *Homo* confirms the table boundary.)

## Per-study tables A1–A14 (the missing tables, now built)

One row per published study entry. Columns: `Species`, `Reference`, `n`, `Anesthesia`,
`Mode`, `Region`, `CMRgl_umol_100g_min`, `CMRgl_SD`, `CMRO2_umol_100g_min`, `CMRO2_SD`,
`CBF_ml_100g_min`, `CBF_SD`, `source`. Units: CMRgl & CMRO2 in µmol/100 g/min; CBF in
mL/100 g/min.

**Extraction.** Snapshots were built from the dissertation PDF text layer
(`pdftotext -layout`), parsed by column position: each row is split at its measurement
`Mode` token, the numeric tail (Glucose/Oxygen/Blood-Flow ± SD) is assigned by column
position (so blank measures stay blank), and Species/Reference/n/Anesthesia are recovered
by nearest-column anchor. The snapshots retain extracted tokens unless a transcription
has been checked and corrected against the page image. An earlier positional audit
against all 1,435 logical PDF rows found and repaired collapsed or
misaligned values/method fields in A1, A3, A6, A11, A13, and A14 (including the shifted
A13 oxygen columns, the A14 Boarini `.20` SD, and two lost Capra rows). The current
snapshots include these page-checked repairs, including eleven shifted Sokoloff rows and
three n/anesthesia shifts; the shared overlay asserts the corrected rows. The A14
McPherson citation wraps in print and is represented as one logical snapshot row. The
104-sheet dissertation `.xlsx` was used as an independent cross-check on completeness
(snapshot row totals ≥ xlsx). Earlier OCR captures are archived when page-checked
transcription corrections are applied to snapshots.

**References.** The overlay applies the explicit citation map to the prepared `Reference`
column, repairing spacing, punctuation and OCR variants matched to the same source in
the dissertation bibliography and existing source-local catalog. Burns and Tyrrell (1992)
and De Volder et al. (1997), whose names were also misread in the bibliography OCR, were
checked against [PubMed 1414666](https://pubmed.ncbi.nlm.nih.gov/1414666/) and
[PubMed 9098549](https://pubmed.ncbi.nlm.nih.gov/9098549/). After rebuilding A1–A14,
regenerate the catalog with `python3 __merging_cerebral_metabolic_rate/build_primary_reference_catalogs.py`
from the repository root; its exact keys and occurrence counts refer to the prepared
tables. Then run `Rscript Kaufman__2004/Kaufman__2004_build_source_matches.R` from the
repository root to rebuild the per-table lists and measurement source matches. The
scope declarations cover the six measurement and SD columns; the unmatched Zimmer
citation stays flagged. `Present Study` and nonprimary sources retain their catalog
classifications. Archived OCR captures preserve the earlier extraction where snapshots
have been corrected against page images.

The paper-wide `Kaufman__2004_bibliography.csv` is the maintained source-local
list of all 504 entries in the dissertation's Literature Cited, including entries
not used in Tables A1–A14. Entry IDs identify dissertation-list positions, and PDF
page numbers are physical, one-based page numbers. The initial citation text comes
from the PDF OCR text layer; the 2026-11-17 page-image review corrected obvious
errors in 305 entries and retained the prior text in the OCR audit. This was a targeted
review, not an independent verification of every character; all rows are marked
`ocr_partially_reviewed`. Entry 203 has a specifically ambiguous character. PDF
line breaks and superscript/subscript styling are normalized in plain text. The catalog
builder reads this file without overwriting it. The shared citation-key catalog and
per-table reference/source-match files are derived views; correct the bibliography
here and rebuild the catalog and source matches, rather than editing those copies.
`bibliography_entry_id` links each resolved catalog citation to its entry in the
bibliography, without treating that source-local ID as a globally unique work ID.
`Present Study` is a self-reference rather than a bibliography entry; Zimmer has no
matched bibliography entry and remains an unresolved table citation.

The bibliography is registered as paper-wide supporting metadata in `pipeline_files.csv`,
not as a separate public measurement item in `__ReadMe.xlsx`.

The 2026-11-17 snapshot review checked the mapped citation corrections in A1–A14
against the page images and restored the printed spelling and spacing in the snapshots.
Printed abbreviations such as `Hovda` and `Yamaki 96` are retained there and expanded
only in the prepared tables. Tables A1–A14 have also been visually checked across
the fields. This review recovered an omitted A3 blood-flow mean and SD, as well as
21 other missing blood-flow SDs in A2–A6. Table A15's 284 rows and 1,420 numerical
strings were compared with the PDF text layer; only selected cells were independently
verified by eye. The archived OCR files and audit notes preserve the extraction history.

## Species means A15

`Kaufman__2004_TableA15.csv`: one row per genus × weighting × region × measure, with
`N, Mean, SD, CV, CVstar`. `unweighted` = each study equal; `weighted` = each individual
equal. The snapshot now follows the eight printed pages (PDF pp. 169–176): repeated
captions where printed, section headers, blank species cells on weighted rows, page
breaks, and the source's row order. The R reader propagates section and species
labels, then applies the existing analysis species order. All 284 numeric rows were
matched uniquely to the PDF text layer; the first and last pages were also inspected
as rendered images. `Rscript --vanilla Kaufman__2004_TableA15.R` reproduced the prior
284-row analysis CSV exactly. See `old/Kaufman__2004_TableA15_snapshot_audit.md` for the
earlier comparison and its limits. Two cells were OCR-reconstructed in the original build (Parietal Cortex · CMRgl ·
Homo · weighted CV*; Cerebellum · CBF · Rattus · weighted) and carried in `note`; both
agree with the manual tables.

## Checking — `comparison/`

Analogous to the other papers' `comparison/` folders. Manual comparisons only; nothing is
merged across papers here.

- `Kaufman__2004_TableA15_compare_to_manual.R` — audits the built **A15** against the
  manually compiled tables Alexandra added (`Kaufman_energetics_weights.csv` and
  `wholebrain_/partsbrain_Kaufman2004.csv`). The wide manual tables are reshaped to long
  **for comparison only**. Result: **1,420 / 1,420 cells match, 0 mismatches** —
  `Kaufman__2004_TableA15_comparison_mismatches.csv` is empty (header only).
- `Kaufman__2004_energetics_compare_to_Kaufman_csv.R` — pre-existing manual-vs-manual
  consistency check (source wide tables vs the flattened compilation).

**A1–A14 validation.** Because A15 is A1–A14 restricted to conscious subjects, the A15
species means can be recomputed from the built per-study tables. Recomputing unweighted
`N` and `Mean` reproduces the verified A15 exactly for the cleanly-mapped regions (~90% of
cells to the cent). Residual differences are expected and are **not** extraction errors:
(a) A15's aggregate regions *Cortex* and *Whole Brain* are not sourced 1:1 from a single
appendix table; (b) a few ±1 study-count differences reflect Kaufman's own study-inclusion
choices; (c) a small number of small-N species rows sit on garbled continuation pages.

## Known limitations

The dissertation is a scanned document; snapshots that have not been completely
page-audited can contain OCR artefacts (such as misread names or dropped parentheses).
Confirmed structural and citation errors can also be corrected by the explicit overlay.
The bibliography entries in the reference catalog are OCR-derived and can themselves
contain errors. `(Zimmer, 1975)` has no matching entry anywhere in the supplied dissertation
folder and remains explicitly unresolved. Dastur (1985) is a review/reappraisal, not a
row-level primary experiment; its three A14 measurements retain cited-source provenance
but are excluded from the primary-only merge until their experimental lineage can be
recovered. Madsen (1993) is an author-led pooled methodological reanalysis rather than an
independent cohort; its A14 row combines subgroup-corrected CBF with pooled measured
CMRO2, so both measurement records are retained in provenance but held out until their
component-study lineage and compatible estimands can be reconstructed. Taxonomy is left
genus-level as printed and is reconciled only in the
cross-paper merge.

The `Anesthesia` value `none` is evidence of no reported anesthesia, not proof of a
baseline/control arm. The canonical merge therefore labels such records
`nonanesthetized_unspecified_arm` and quarantines every otherwise-eligible
within-primary source/cell/condition/unit group containing multiple rows until control,
treatment, disease, task, age, or temperature arms can be reconstructed.

## ReadMe.xlsx updates (this pass)

Filled the previously-blank *Item full original title* cells for `TableA3`–`TableA11`, and
set `TableA12`/`TableA13` titles to the dissertation's printed titles (Sensorimotor /
Cingulate). No item names were changed.
