# Rockel et al. (1980), TABLE 3 — prepared source-backed package

**Item:** `Rockel_etal_1980_TABLE3`  
**Registry identity:** `10.1093%2Fbrain%2F103.2.221_TABLE3`  
**Citation:** Rockel, A. J., Hiorns, R. W., & Powell, T. P. S. (1980). The basic uniformity in structure of the neocortex. *Brain, 103*(2), 221–244. https://doi.org/10.1093/brain/103.2.221

## Source → snapshot

Printed Table 3, **“COMPARISON OF CELL COUNTS,” p.226 (document page 6)** is the frozen source. Methods on pp.221–223, Table 1 on p.223, Table 2 on p.224 and discussion on pp.230–232 supply the separate item-scoped context.

Microsoft Copilot AI assistant manually transcribed the published grid on **2026-10-10**, using the rendered paper to decide the glyphs and then checking all cells, headings, order and the footnote against the rendered page. The OCR/text layer was only a reading aid. Important readings include Rat Motor **108.2**, Rat Mean of means **106.7**, and Man Visual **258.9 ± 15.8**. This is an **AI source check, not human visual curation**; the human-review field remains blank.

`Rockel_etal_1980_TABLE3_snapshot.csv` retains the caption, original printed labels and row/column order, five species rows, six cortical-area columns, the separate Mean of means column, the two meaningful missing dashes for Monkey and Man, and the full table footnote. Centred decimal typography is rendered as ordinary decimal points; typesetting whitespace/line wraps are regularized without changing digits, one-decimal precision or meaning. All nonmissing cells remain unsplit mean ± SD strings. The snapshot is the published grid, **not a long cleaned dataframe saved twice**.

## Data readable → scripted transformations

Files:

- `Rockel_etal_1980_TABLE3_snapshot.csv`: faithful 9-row × 8-column published-grid capture, including caption/header/blank/footnote rows.
- `Rockel_etal_1980_TABLE3.R`: self-locating R reader; reads the snapshot and context, reshapes, parses and supplies every transformation.
- `Rockel_etal_1980_TABLE3.csv`: **actually generated Python analysis preview**, not an R-validated release.
- `reference_tables/Rockel_etal_1980_TABLE3_context.csv`: five species-keyed source-method/context records; not a second measured table or a taxonomy key.
- `reference_tables/Rockel_etal_1980_TABLE3_definitions.csv`: exact ten-column dictionary, covering every analysis column plus explicit method/observation-level entries.

The analysis preview has **35 rows and 36 columns**: **30 species-by-area summary records**, **3 dependent printed author aggregates**, and **2 preserved missing aggregate positions**. These are heterogeneous records, **not 35 subjects**. There are 33 nonmissing mean/SD pairs. Source cohorts contain 2 Mouse, 2 Rat, 2 Cat, 3 Monkey and 2 Man animals; the same cohorts recur across areas and in their aggregates. No individual-animal records are reconstructed.

The reader keeps the published string, adds parsed `Count_mean`/`Count_SD`, joins species-scoped context by the exact printed label, assigns record type/provenance, and keeps aggregates out of `Cortical_area_as_published`. Numeric values retain the source magnitude; the original string retains printed precision. No counts, surface estimates, SEM, raw individuals or corrected values are calculated. Numeric metadata formatting such as `30` versus `30.0` is value-equivalent; printed measurement strings are checked exactly.

## What these values mean — mandatory method gate

These are **historical neuronal-cell-body/nucleolar PROFILE counts**, intended by the authors to count neurons in thionine-stained, paraffin histological sections. Cell somata with distinct nuclei and nucleoli were counted through a **nominal 30-µm width × 25-µm section thickness prism, from pia to white matter through the full cortical depth**. They are **not modern unbiased neuron counts, whole-area totals, volumetric density or already neurons/mm² of cortical surface**. The raw count-per-prism unit is retained. Do not multiply to a surface count, assign an unbiased-neuron catalog term, or infer a missing depth denominator.

The authors acknowledge occasional glial inclusion, omissions in lightly stained sections, fixation/processing effects, oblique sections/traverses, and uncertainty at the grey/white boundary. The two human brains were immersion-fixed, unlike the perfused nonhuman brains. Human visual counts require particular caution: initially low counts were attributed to inadequate staining of small cells, probably imperfect fixation; deep restaining raised the counts. The final Table 3 value is retained without reconstructing earlier values.

The **18% linear shrinkage estimate came from a separate human brain not used for the counts**. No section/shrinkage correction is inferred or applied to these observations.

## Sampling and SD

The Table 3 footnote says mouse, rat, cat and man means come from **two samples of ten counts, one sample from each of two animals, in each area**. Monkey values use **three animals**, with **two samples of twenty counts per animal**. Samples/traverses are technical replication, not extra animals. Context sampling fields describe the area-level protocol; their repetition on aggregate-position rows does not define an aggregate's independent sample size.

**All printed SDs are obtained from within-animal pooled variances.** They are not between-animal SDs, SEMs or confidence limits. Do not derive SEM, effective biological n, animal values or raw distributions from the pooled SDs.

## Dependency, names, anatomy and laterality

- The three printed **Mean of means** entries are dependent author summaries of the same six areas. Retain the author's means and SDs unchanged; do not recompute/replace them or promote them as a seventh cortical area or additional animals. Monkey/Man aggregate positions remain missing, not zero or imputed.
- All six Monkey mean/SD pairs already appear in Table 2 (its Visual counterpart is labelled Striate). **Only Table 3 is prepared. No separate Table 2 build and no double counting.** The Table 2 caption is retained as source context, not an independent biological cohort.
- Keep **Mouse, Rat, Cat, Monkey, Man**. `Macaca mulatta` is printed in Table 2 and recorded only as Monkey source context, not a globally accepted mapping. No species/strain is invented. An existing **collection-specific key review is pending**; keys are unchanged. Tupaia is not a Table 3 row.
- Area labels remain as published. Primates' methods/results context includes motor area 4, somatic sensory cortex, probably frontal area 9, parietal area 7, and temporal area 22; no blanket primate Brodmann mapping is imposed on other species. Visual refers to source area 17. Anatomical/merge homology remains owner-reviewed.
- Human visual source sampling includes **both hemispheres**, specifically posterior/middle calcarine-sulcus thirds. Other positions have **unstated laterality**. There is no blanket LEFT/bilateral designation, hemisphere multiplication, or conversion to a whole-structure bilateral total.

`Record_type`, `Data_role` and `Primary_area_record` are row-level dependency gates. The registry's source role remains **primary**, but **every `Merge_eligible` value is FALSE** under historical-method, collection-specific taxonomy/anatomy and owner-routing holds. Neither the existing method hold nor source primary origin authorizes promotion to a modern neuron-count merge.

## R execution and online database — NOT RUN / WITHHELD

R and Rscript are unavailable in the preparation environment. **R parse, clean-session execution, canonical audit, dry-run build, actual build and validation: NOT RUN.** Python preview generation and source/schema/static-reader checks are preparation evidence only. No public TSV is delivered or uploaded, no shared scientific-file publication is attempted, and no FINISHED certification or registry edit is made.

For future exact-item execution, place these files together in `Rockel_etal_1980/` under a complete repository containing the current `__ReadMe.xlsx`, with `readxl` available. The R reader derives `folder`, `base`, `item_name` and output names from its saved filename; it inspects source frames' `ofile` **and** `file` before a wrapper's `--file`, uses explicit `utils` I/O, and freshly resolves exactly one current registry row by `Item name` to obtain `Item encoded` and source role. It never uses a cached row number or guessed public stem. Run the exact saved reader in a clean R session and validate the explicit matching outputs; a folder wrapper's first-file choice is not proof this item ran.

By default the reader writes only the analysis CSV. A later owner-authorized shelf TSV requires actual R execution/validation and both `EVOM1_WRITE_PUBLIC_TSV=YES` and `EVOM1_R_VALIDATED=YES`; these are explicit declarations, **not automated validation or scientific comparability certification**. The canonical public output location is repository-level `__Public/comparative-data/`, with the fresh registry's encoded filename. Any such later TSV must preserve record-level gates. No present package authorizes merge edits, taxonomy/key changes, registry stage changes or FINISHED status.

The accompanying owner correction proposal is keyed to this existing item; it is not a new registration. Blank proposal cells mean **no change** and must never clear existing values or human-curation evidence. Source legibility is described in Source format, not a new quality field. Owner acceptance remains separate from the present source-backed preparation.
