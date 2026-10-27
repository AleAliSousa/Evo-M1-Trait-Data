# Orlin third batch: six additional papers

Built 2026-10-26 from the local Orlin sources. Six previously unregistered papers contribute nine dataset items and 2,072 analysis rows. These rows are not a count of independent animals or species. Each item has a frozen source, reproducible R reader, analysis CSV, DOI-coded public TSV, definitions, README and registry entry.

| Paper | Items | Rows | Contribution |
|---|---|---:|---|
| West & Schwerdtfeger 1985 | TableI, TableII, TableIII | 11 + 52 + 52 | Specimen/reference weights and standardized hippocampal components in hedgehog, tree shrew and marmoset |
| Jacobs & Spencer 1994 | Table1 | 7 | Brain/body mass and hippocampal volume in three kangaroo-rat species; 22 animals in overlapping sex/all summaries |
| Patzke et al. 2015 (online 2013) | Table1, Table2 | 381 + 96 | Eleven current-study MRI rows among compiled brain data; 71 current-study AHN evidence rows among 96 species |
| Weisbecker et al. 2013 | TableS1 | 191 | Sex-specific literature body masses, Ashwell ECV and mandible-derived mass alternatives |
| Gómez et al. 2016 | TableIXA | 1,052 | Compiled deaths and conspecific-death percentages, with taxonomic footnotes and original source keys |
| Opie et al. 2013 | DataS1 | 230 | Primate mating, care, ranging, reproductive timing and infanticide categories with bibliography |

## Interpretation and source overlap

These additions enter the source database and variable catalog (31 measured variables). Aggregate volume/cell/sensory merges are unchanged. Source/specimen mapping is needed before pooling.

- West’s regional volumes are **reference-size-standardized**, not raw volumes. Their catalog measure class remains separate from ordinary volume. Hedgehogs reuse West et al. (1984) material; external species means reuse Stephan et al. (1981). Hypothetical reference volumes and repeated group means are metadata, not extra observations. A normalization-description conflict precludes a justified inverse transformation.
- Jacobs retains mean ± SE and overlapping sex/all summaries. The hippocampal boundary is dentate gyrus plus Ammon’s horn. Fixed brain mass and serial-section volume are distinct measures; no extra hemisphere doubling.
- Patzke separates every numbered source. Brain volume is described as derived from mass, so its catalog class is distinct from measured volume. Source 5 MRI rows and source 2 AHN evidence refer to the Manger collection and are not automatically independent of other collection papers. AHN-negative staining is assay evidence, not proof of universal biological absence.
- Weisbecker’s native workbook is unchanged. Brain-volume entries are Ashwell-based ECV, with 2013 taxonomic/adult-only revisions, not new independent brain specimens. The separate Table S2 literature bibliography is absent from the supplied file; per-species body-mass citations remain explicitly unresolved. No estimates silently fill missing sex-specific measurements. [Publisher methods](https://karger.com/bbe/article/82/2/81/326143/An-Improved-Body-Mass-Dataset-for-the-Study-of).
- Gómez’s 1,052 rows include synonyms/subspecies; preserve the four taxonomic-footnote meanings. Percentages describe sampled causes of death, not annual risk. Three concatenated reference tokens remain unresolved as printed. Human historical/archaeological sections IX.B/C are outside this intake.
- Opie preserves DD, Low, Absent, No and blank separately, and distinguishes column-wide references from row-specific additional sources. Publication counts measure evidence coverage, not sample size. Author categories remain categories, not rates or universal population descriptions.

## Validation and review status

All nine R readers ran successfully from saved files. Repository validation: **78 PASS, 3 SKIP, no FAIL**. Skips are absent errata files where no discrepancy is recorded. All output columns have definitions; every analysis CSV matches its public TSV. Independent source-to-output checks pass **23,740 assertions**, covering native workbook fields, numerical units, PDF numerical coverage, reference joins and source hashes. Sources are preserved byte-for-byte in manifests; transcribed CSVs retain published order and notes.

Twenty source discrepancies/ambiguities are documented: West’s normalization wording, two printed means and six component/composite discrepancies; eight Patzke mass/volume mismatches; three concatenated Gómez references. Original values remain unchanged. No unprinted correction was substituted. The 913 recomputable relations comprise 753 passes, 16 retained mismatches and 144 cases not evaluable because required source data are missing.

PDF transcriptions received AI comparisons; **human RA verification remains pending**. The untouched Excel sources are recorded as “Not applicable: tabulated and digital already.” Detailed QA scripts and results are retained under the restricted repository’s `restricted_checks/orlin_batch3_2026-10-26/`.
