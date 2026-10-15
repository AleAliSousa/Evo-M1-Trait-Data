# Pirlot 1981 Table II: specimen-count metadata only

Companions: `volumes_sample_metadata_Pirlot__1981.R` and `.csv`, intended for `__merging_volumes/`. They document **28 Table II headings, each linked explicitly to one sectioned Table I brain (`N_region = 1`)**. They do not import, correct, average or admit any volume. `N_region` is a sampling field, not a new trait or a source of 28 additional independent observations alongside the volume rows.

## Evidence and scope

Pirlot, P. (1981), *A quantitative approach to the marsupial brain in an eco-ethological perspective*, *Revue Canadienne de Biologie* 40(2), 229–250; PMID:7280305.

- **Table I, pp. 230–231:** all 50 numbered specimens, their collection IDs, printed sex and S/W use codes. The p. 231 footnote defines **S** as sectioned for component analysis and encephalization; **W** as weighed for encephalization only. There are **28 S and 22 W** specimens, with 28 distinct expanded S labels. Each of the 28 Table II headings has a literal, item-local link to one of those labels and its unique S specimen.
- **Methods, p. 232:** 5 P-prefix specimens belong to Pirlot's Université de Montréal collection; 45 J-prefix specimens belong to J. I. Johnson's Michigan State University collection. Brains were formalin-fixed, paraffin- or celloidin-embedded, cut at 10–40 µm and Nissl-stained. These are study-level methods, not separately verified preparation assignments for each animal.
- **Results, p. 233:** nine didelphid brains were sectioned; the eight basal didelphines exclude *Caluromys*. This corroborates the first nine explicit links; it is not the sole basis for the remaining links. The author used **115–130 microscopic sections per brain**, not 115–130 independent animals. Specimen 11's BrW is explicitly interpolated.
- **Table II, pp. 234–236:** 28 abbreviated headings, 12 component measurements per heading, and printed summary lines. All components of a linked row refer to the **same single brain**; the 12 components and summaries are not independent specimen replicates. Neither the full study's 50 weights nor its reported 29 species is the Table II per-row N. The companion does not resolve anatomy, laterality, shrinkage, total-brain definitions or disputed values.

Inputs are **only the two frozen XLSX snapshots** in `Pirlot__1981/`, never the analysis CSVs or public TSVs. SHA-256 of the reviewed copies:

```
11c81151ef85c65551ab2b2e07f2a7970e884081fcfec59e1d0e03bcf3834317  Pirlot__1981_TABLEI_snapshot.xlsx
a8be9c2ef41f7b1b0e5dd13e77a64829742702a8724c69bf805df75cf9e2562d  Pirlot__1981_TABLEII_snapshot.xlsx
```

The helper records each input's runtime MD5 in every output row for fingerprinting; MD5 is not a source-admission decision. The SHA-256 values above identify the reviewed baseline, not an automatic acceptance of a changed workbook.

## Explicit links, not taxonomy normalization

`pirlot1981_sample_crosswalk()` contains **28 literal rows**: Table II heading → full Table I expanded label → specimen number → collection ID, with a link note. Matching uses exact strings and checks the expected individual, never volume values, array position, an epithet-only join or a general genus-to-species rule. Only `idem` is expanded, following printed specimen number; its original literal is retained separately. Source coordinates are audit locators, not join keys.

In particular, the three *Marmosa* labels remain separate; Table I's *Didelphis m. aurita* and *D. m. marsupialis* retain their printed subspecific labels; *Metachirops* is not changed to *Philander*; Table II `Potorus` stays distinct from Table I `Potorous tridactylus`. The genus-only `Petaurus` link selects *P. breviceps*'s S specimen, not the W-only *P. norfolcensis*.

The helper refuses duplicate/missing/unmatched Table II headings, duplicate specimen numbers or collection IDs, invalid S/W codes or changed global S/W counts, zero or multiple S individuals for a linked label, the wrong expected specimen/collection, reused S specimens or incomplete S coverage. Reordering numbered specimen rows or Table II columns cannot silently change the individual assigned to a heading. It does not claim to validate component numbers.

## Reading and rebuilding

**Preparation status:** the companion CSV was generated and checked by a Python source/model implementation against the frozen workbooks. The R helper has **not been parsed or executed in R** because R/Rscript is unavailable here. Static text/delimiter checks and Python source/model tests are not clean-R validation. All mapping/evidence review is **AI source review, not human by-eye sign-off**. Run the helper locally in a clean R session before treating its rebuild as validated.

Sourcing the helper only defines functions; it does not run item readers, change working directory, install packages or write files. With `readxl` already installed:

```r
source("/path/to/repo/__merging_volumes/volumes_sample_metadata_Pirlot__1981.R")
p <- "/path/to/repo/Pirlot__1981"
samples <- pirlot1981_sample_metadata(
  file.path(p, "Pirlot__1981_TABLEI_snapshot.xlsx"),
  file.path(p, "Pirlot__1981_TABLEII_snapshot.xlsx"))
stopifnot(nrow(samples) == 28L, all(samples$N_region == 1L))
```

Or write a **new private CSV**; the wrapper refuses an existing filename and does not publish it:

```text
Rscript /path/to/repo/__merging_volumes/volumes_sample_metadata_Pirlot__1981.R /path/to/repo /existing/private/directory/Pirlot_sample_check.csv
```

Compare the rebuilt CSV's fields with the companion, rather than expecting byte-identical CSV quoting. A changed snapshot fingerprint or source content requires review, not automatic replacement of this companion.

## Field interpretation and holds

- `Source` is `Pirlot__1981_TABLEII`; `sample_source` is `Pirlot__1981_TABLEI`. `tableII_heading` is the exact row-link key. Keep this source scope when attaching metadata; reject unmatched or duplicated keys rather than guessing. The two source label columns, specimen number, collection ID and coordinates preserve the audit trail. No accepted-name column is supplied.
- `N_region = tableI_S_N = 1` is **inferred individual-brain N**, not a separately printed Table II n. `N_basis`/`N_evidence` state the derivation. `tableI_W_N` and the S/W specimen-number lists are counts for that **exact expanded Table I label**, not the entire genus. Their W counts sum to 20: the remaining two W-only labels, *Didelphis azarae* (3) and *Petaurus norfolcensis* (32), have no Table II row and are not invented as rows.
- `sample_id` is a local one-brain cohort identifier. `specimen_ids` is collection-qualified; `ids_complete = yes` means the one contributing Table I individual is identified, **not** that cross-publication identity is resolved. These names preserve the existing review-field vocabulary without populating any compiler's review file or replacing its cohort/regional-N fields.
- `sex_as_printed` retains `?` for specimens 11 and 29. Age is not generally reported; specimen 8 is described as adult, while *Antechinus* specimen 15 retains the source's adult-or-young uncertainty. Do not infer a uniformly adult, male or female sample.
- Identity doubts remain separate flags/notes for specimen 8 (*Metachirops*), specimen 11 (subgenus-qualified `sp.`) and specimen 39 (*Vombatus mitchelli (ursinus?)*). No taxon is silently normalized.
- The parenthetical/interpolation flags preserve specimen 11's `(2200)` provenance. False interpolation flags mean no interpolation exception identified here, **not** independent proof that all other weights were directly measured. No new weight or volume measurement is emitted.
- The older Table I README **reports** a P313 overlap with `Pirlot_Nelson_1978_TABLE3`. That identity has **not been independently established from both primary sources here**. The flag is a review hold, not a claim that matching numbers prove common identity. Other cross-paper independence remains `not_assessed`.
- `data_role = sampling_metadata_not_trait`, `merge_status = metadata_only_not_admitted` and `review_status` explicitly prevent confusing preparation with admission or sign-off. These are descriptive sidecar fields, not compiler-enforced gates.

**No automatic intake:** Pirlot is absent from the inspected standardized-term maps and primary DeCasien source catalog. Do not add it to a compiler, invent canonical anatomy/accepted species keys, replace source-specific N for other studies, regenerate shared outputs, or infer eligibility from this sampling sidecar. Any future intake needs separate owner review of source eligibility, anatomy/laterality, species identity and cross-paper dependence. This helper and companion are deliberately not read by the existing compilers.
