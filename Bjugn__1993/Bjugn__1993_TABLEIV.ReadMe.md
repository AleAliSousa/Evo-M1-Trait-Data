# Bjugn__1993_TABLEIV — staged build, public export HOLD

## Source → frozen snapshot

Bjugn, R. (1993). The use of the optical disector to estimate the number of neurons, glial and endothelial cells in the spinal cord of the mouse—with a comparative note on the rat spinal cord. Brain Research, 627(1), 25–33. https://doi.org/10.1016/0006-8993(93)90744-8

PMID **8293301**; one article DOI **10.1016/0006-8993(93)90744-8**. Bibliographic metadata was checked at https://pubmed.ncbi.nlm.nih.gov/8293301/; scientific measurements came from the held PDF, **printed p. 29, TABLE IV**, not a web abstract. Original filename: `Bjugn-1993-The use of the optical disector to.pdf`; held-source SHA-256 `7b11dcd6ba8795284512f4c3b5586b94376fd3642a1ec3394afa8d6f5d1663a2`. The source paper and private checking material are not delivered in this build package.

**Source reader: Microsoft Copilot AI assistant. Read/transcription date: 2026-10-10 (Pacific, America/Los_Angeles). Human visual curation: unconfirmed/blank.** The AI reader rendered the held PDF, checked the full printed table plus methods/discussion and froze a faithful CSV before authoring the R reformat. Source format is a legible printed PDF table with a usable but imperfect text layer. Legibility is source-format metadata, not a measurement-confidence score.

`Bjugn__1993_TABLEIV_snapshot.csv` preserves the printed Roman table label, caption, original units, grouping headers, row/column order and line-wrapped region labels. CSV flattens typography, not meanings. No contextual species, enrollment or uncertainty fields are inserted into the snapshot. Context is separately join-ready by `Reference` in `reference_tables/Bjugn__1993_TABLEIV_context.csv`.

## Frozen snapshot → analysis CSV

`Bjugn__1993_TABLEIV.R` reads the frozen snapshot and item context; it never regenerates a snapshot or hardcodes measurements. It resolves source/sys.source file frames before a wrapper's `--file` argument and accepts only its own basename. Every related path derives from `item_name`.

- Keeps four published regional means and the printed total-cell column.
- Removes presentation line wraps from labels without changing author terminology.
- Converts cell counts **×10⁶ → cells** in code only; keeps original units in source-unit columns and the snapshot.
- Keeps volumes **mm³** unchanged; no morphological percentages occur in this item.
- Keeps printed species common name `mouse`; strain **Bom:NMRI**, adult, male are method context. No unsupported inline `Mus musculus` mapping or species-key write.
- Appends per-row observation level, estimate type, confidence notes, enrollment and dependency context. Meaningful blanks (unknown/unconfirmed) are explained in the dictionary.

## Regional means: contributor-n HOLD

The four rows are Cervical, Thoracic, **Lumbal** (printed spelling) and Sacro-coc-cygeal. The caption calls these means, but does not explicitly give the contributing-animal n. Enrollment is five adult male albino mice, **not** proof that all five contributed to each regional mean. Results p. 28 reports average sampled counts of 201 gray / 80 white cells in animals 1, 3, 4, 5, versus more extensive counting and separate horn/middle reference volumes in animal 2 (Methods p. 27). That sampling statement does not establish TABLE IV's contributor n. `ContributingAnimalsN` is intentionally blank and distinct from `StudyEnrolledN = 5`.

These regional summaries come from the same study cohort as TABLE II, not independent replicates. Printed total-cell values remain as printed, not the sum of rounded categories. No extra total/mean row, per-region SD/CE, or reconstructed animal measurements is invented.

## Source discrepancies retained

- TABLE IV sacro-coccygeal neurons are **0.6 ×10⁶** in the actual table; the held paper's abstract says 0.4 ×10⁶. The table governs this item; neither source is silently repaired.
- Regional volumes total 25.2 mm³, while TABLE I's enrolled-cohort gray-matter mean is 24.48 mm³. The contributor/estimator basis remains uncertain. Values are not rescaled to the cohort mean.
- Rounded components need not exactly equal printed totals. Preserve both rather than force arithmetic equality.

## Cell classification and tissue treatment

Endothelial cells **include pericytes and smooth muscle cells** (p. 26). Unidentified cells stay unidentified; they are never silently redistributed to glia. The author warns that neuron identification has no clear-cut criteria: neurons may be classified as glial/unidentified and glia may enter categories 2/3 (pp. 29–30). Confidence notes are separate from estimate type and row observation level. No volumetric processing/shrinkage correction was applied by the author (p. 31), and none is added here.

## Outputs and truthful QA status

Four core item files: frozen snapshot, `.R`, analysis `.csv`, this `.ReadMe.md`; plus item-scoped definitions/context CSVs under `reference_tables/`. Analysis has **4 rows**. Dictionary uses the exact fixed 10 headers and covers every analysis column plus Method:observation_level and unit/classification/gate rows; `Reference` is exactly `Bjugn__1993_TABLEIV`. Info/note/method fields have blank `Measure`.

**R and Rscript are definitively absent.** Canonical R audit / dry-run / build / validate were **NOT RUN**. The supplied analysis CSV was generated by a separate private Python transformation of the frozen input; independent Python/source/numeric/schema/hash checks are a limited QA substitute, not canonical R execution or validation. Private result/checking files stay under private session audit material and are not needed as public build inputs. No public TSV is produced in this batch.

## Registry and public-export gate

The existing registry item is `Bjugn__1993_TABLEIV`; retain printed `TABLE IV` and its existing uppercase item name. A fresh exact live-row read of `Sheet1!A1:L750` confirms its citation has an incorrect article DOI ending in **90744-11**, while Column C is blank. **Owner must replace Citation A with TABLE I's correct article citation (single DOI 10.1016/0006-8993(93)90744-8), preserve blank Column C/default resolution unless the owner explicitly chooses an override, recalculate formulas/file list, and re-read the row by exact Item name before code authority is trusted.** The same owner citation correction is required for TABLE II–V, including the method-only TABLE III; this task applies none of those changes. The initial 200-row host-model window did not cover these appended rows and is not row authority. No shared workbook or generated E:L fields are edited here. Current 34-field descriptive proposals and the exact live-row evidence are private, named-field records, not applied changes.

After the owner correction and canonical R checks on a machine with R, explicit export requires `EVOM1_R_QA_CONFIRMED=true` and `EVOM1_PUBLISH_PUBLIC_TSV=true`; the script reads current `__ReadMe.xlsx` by Item name, validates the corrected citation/Column C/resolved DOI before trusting `Item encoded`, and writes only to the existing repo-level `__Public/comparative-data/`. No table-specific DOI is guessed. Default execution writes only the analysis CSV. Publication/method/species-key/merge gates remain unresolved; this package is **staged, not published**.

## Bounded scope / source disposition

This item has no whole-source README edit and does not alter TABLE I/II, shared keys, old approvals, previous archives, source-paper provenance or merge code. TABLE III is a worked coefficient-of-error / Q⁻/F/P sampling calculation from animal 1, **not a species-mean primary trait table**. A private proposal recommends retaining it as methods evidence/documented skip for primary ingestion; that disposition is **planned, not applied**. Its original registry candidate is retained unchanged. No TABLE III primary dataset is built.
