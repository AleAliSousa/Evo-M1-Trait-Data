# Bjugn__1993_TABLEV — staged build, public export HOLD

## Source → frozen snapshot

Bjugn, R. (1993). The use of the optical disector to estimate the number of neurons, glial and endothelial cells in the spinal cord of the mouse—with a comparative note on the rat spinal cord. Brain Research, 627(1), 25–33. https://doi.org/10.1016/0006-8993(93)90744-8

PMID **8293301**; one article DOI **10.1016/0006-8993(93)90744-8**. Bibliographic metadata was checked at https://pubmed.ncbi.nlm.nih.gov/8293301/; scientific measurements came from the held PDF, **printed p. 29, TABLE V**, not a web abstract. Original filename: `Bjugn-1993-The use of the optical disector to.pdf`; held-source SHA-256 `7b11dcd6ba8795284512f4c3b5586b94376fd3642a1ec3394afa8d6f5d1663a2`. The source paper and private checking material are not delivered in this build package.

**Source reader: Microsoft Copilot AI assistant. Read/transcription date: 2026-10-10 (Pacific, America/Los_Angeles). Human visual curation: unconfirmed/blank.** The AI reader rendered the held PDF, checked the full printed table plus methods/discussion and froze a faithful CSV before authoring the R reformat. Source format is a legible printed PDF table with a usable but imperfect text layer. Legibility is source-format metadata, not a measurement-confidence score.

`Bjugn__1993_TABLEV_snapshot.csv` preserves the printed Roman table label, caption, original units, grouping headers, row/column order and percent signs, superscript a/b/c footnotes and printed zeros. CSV flattens typography, not meanings. No contextual species, enrollment or uncertainty fields are inserted into the snapshot. Context is separately join-ready by `Reference` in `reference_tables/Bjugn__1993_TABLEV_context.csv`.

## Frozen snapshot → analysis CSV

`Bjugn__1993_TABLEV.R` reads the frozen snapshot and item context; it never regenerates a snapshot or hardcodes measurements. It resolves source/sys.source file frames before a wrapper's `--file` argument and accepts only its own basename. Every related path derives from `item_name`.

- Transposes eight printed measure rows into three within-animal portion rows.
- Removes presentation line wraps from labels without changing author terminology.
- Converts cell counts **×10⁶ → cells** in code only; keeps original units in source-unit columns and the snapshot.
- Keeps volumes **mm³** unchanged; retains category percentages as percentages, never inferred neuron numbers.
- Keeps printed species common name `mouse`; strain **Bom:NMRI**, adult, male are method context. No unsupported inline `Mus musculus` mapping or species-key write.
- Appends per-row observation level, estimate type, confidence notes, enrollment and dependency context. Meaningful blanks (unknown/unconfirmed) are explained in the dictionary.

## One-animal partial-cord partition

This is **animal 2 only (n = 1)**, already among TABLE I/II's five enrolled animals. The three analysis rows are printed columns Ventral, Middle and Dorsal, corresponding to ventral horns, middle portion and dorsal horns. These are anatomical portions of one specimen, not three animals, whole-cord observations or population means. The scope is gray matter **down to the upper sacral segments**; the caption says this contains **94%** of the animal's gray matter. That statement is retained separately as `CoverageAsAuthorPrinted_pct`, not used as a scaling factor.

The actual table has volumes 6.6, 6.2, 9.5 mm³ and neuronal counts 0.3, 0.6, 2.3 ×10⁶. Published unidentified-cell zeros and category-3 ventral zero are real printed zeros, not missing data. No total whole-cord row or new biological subject is added.

Category 1 has a prominent nucleolus and clearly defined cytoplasm with distinct Nissl bodies; category 2 lacks distinct Nissl bodies; category 3 has marked nuclear-membrane invaginations and scant/no apparent cytoplasm. Their published percentages are retained on the 0–100 scale, not converted into invented category counts. These morphological categories are **not** motor-neuron subtypes, functional interneuron categories or M1 classes.

## Source coverage discrepancy retained

The actual TABLE V volumes sum to **22.3 mm³**; TABLE I gives **25.2 mm³** gray matter for animal 2. The quotient is approximately **88.49%**, not the caption's **94%**. Scope/estimator basis is uncertain. Both the printed coverage and all printed measurements remain unchanged; no value is rescaled or forced to fit 94%. The quotient is an internal-source check, not an additional primary measurement.

## Cell classification and tissue treatment

Endothelial cells **include pericytes and smooth muscle cells** (p. 26). Unidentified cells stay unidentified; they are never silently redistributed to glia. The author warns that neuron identification has no clear-cut criteria: neurons may be classified as glial/unidentified and glia may enter categories 2/3 (pp. 29–30). Confidence notes are separate from estimate type and row observation level. No volumetric processing/shrinkage correction was applied by the author (p. 31), and none is added here.

## Outputs and truthful QA status

Four core item files: frozen snapshot, `.R`, analysis `.csv`, this `.ReadMe.md`; plus item-scoped definitions/context CSVs under `reference_tables/`. Analysis has **3 rows**. Dictionary uses the exact fixed 10 headers and covers every analysis column plus Method:observation_level and unit/classification/gate rows; `Reference` is exactly `Bjugn__1993_TABLEV`. Info/note/method fields have blank `Measure`.

**R and Rscript are definitively absent.** Canonical R audit / dry-run / build / validate were **NOT RUN**. The supplied analysis CSV was generated by a separate private Python transformation of the frozen input; independent Python/source/numeric/schema/hash checks are a limited QA substitute, not canonical R execution or validation. Private result/checking files stay under private session audit material and are not needed as public build inputs. No public TSV is produced in this batch.

## Registry and public-export gate

The existing registry item is `Bjugn__1993_TABLEV`; retain printed `TABLE V` and its existing uppercase item name. A fresh exact live-row read of `Sheet1!A1:L750` confirms its citation has an incorrect article DOI ending in **90744-12**, while Column C is blank. **Owner must replace Citation A with TABLE I's correct article citation (single DOI 10.1016/0006-8993(93)90744-8), preserve blank Column C/default resolution unless the owner explicitly chooses an override, recalculate formulas/file list, and re-read the row by exact Item name before code authority is trusted.** The same owner citation correction is required for TABLE II–V, including the method-only TABLE III; this task applies none of those changes. The initial 200-row host-model window did not cover these appended rows and is not row authority. No shared workbook or generated E:L fields are edited here. Current 34-field descriptive proposals and the exact live-row evidence are private, named-field records, not applied changes.

After the owner correction and canonical R checks on a machine with R, explicit export requires `EVOM1_R_QA_CONFIRMED=true` and `EVOM1_PUBLISH_PUBLIC_TSV=true`; the script reads current `__ReadMe.xlsx` by Item name, validates the corrected citation/Column C/resolved DOI before trusting `Item encoded`, and writes only to the existing repo-level `__Public/comparative-data/`. No table-specific DOI is guessed. Default execution writes only the analysis CSV. Publication/method/species-key/merge gates remain unresolved; this package is **staged, not published**.

## Bounded scope / source disposition

This item has no whole-source README edit and does not alter TABLE I/II, shared keys, old approvals, previous archives, source-paper provenance or merge code. TABLE III is a worked coefficient-of-error / Q⁻/F/P sampling calculation from animal 1, **not a species-mean primary trait table**. A private proposal recommends retaining it as methods evidence/documented skip for primary ingestion; that disposition is **planned, not applied**. Its original registry candidate is retained unchanged. No TABLE III primary dataset is built.
