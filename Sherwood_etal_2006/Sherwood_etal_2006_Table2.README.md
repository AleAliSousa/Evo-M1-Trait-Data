# Sherwood et al. (2006), Table 2 — prepared ratio dataset

**Preparation only. R: NOT RUN. Public TSV: WITHHELD. Shared publication: NOT ATTEMPTED. Merge: HOLD. No FINISHED certification or human visual-curation claim.**

## Source

Sherwood, C. C., et al. (2006). *Evolution of increased glia–neuron ratios in the human frontal cortex*. Proceedings of the National Academy of Sciences USA, 103(37), 13606–13611. https://doi.org/10.1073/pnas.0605843103

The source is the actual publication PDF, `Sherwood-2006-Evolution of increased glia-neur.pdf`. Table 2 is on printed p. 13608, PDF page 3; explanatory Results are on p. 13607 and Materials and Methods on pp. 13609–13610. This package prepares **only `Sherwood_etal_2006_Table2`**, not Table 1, supplementary cell-density Table 3, demographic Table 4, or any other item. The source PDF is not redistributed in this package.

## Snapshot

`Sherwood_etal_2006_Table2_snapshot.csv` is the frozen published-table view: caption, exact six headers, three species rows in printed order, four regional mean (standard error) cells per species, and the printed uncertainty footnote. The caption's line break and the meaningful empty cells around caption/footnote are retained. The PDF text-layer fraction-slash encoding is represented by the visible slash in `II/III`; typography and page decoration are not measurement data.

GitHub Copilot (AI assistant), on 2026-10-10, extracted the actual PDF page's text layer into this frozen grid and checked all twelve cells, species/order, header/order, caption and footnote against a rendered view of the actual PDF page. This is AI source reading, **not human visual curation**. All measurement decimal strings, including `1.20` and each parenthesized `0.xx` standard error, remain unchanged. The R reader reads this saved snapshot; it never writes or reconstructs the snapshot from hardcoded measurement values.

## Data readable and transformations

- `Sherwood_etal_2006_Table2.csv`: actual **Python-generated preview**, twelve species-by-area summary records. It is not evidence of R execution.
- `Sherwood_etal_2006_Table2.R`: reproducible item reader, statically inspected but **not run or parsed by R**.
- `reference_tables/Sherwood_etal_2006_Table2_context.csv`: item-scoped interpretation/method metadata constructed from the cited main-paper passages. Join keys are `Reference`, `species_as_published`, `area_as_published`, exactly one context row per analysis row.
- `reference_tables/Sherwood_etal_2006_Table2_definitions.csv`: exact ten-column dictionary for every analysis column, plus observation-level and method notes.

The R reader locates its saved filename through source-frame `ofile` and `file` before an Rscript `--file` wrapper; derives `folder`, `base` and `item_name`; reads the frozen grid; removes presentation-only caption/header/footnote rows from the analysis view; reshapes the four regional columns in printed species-major/area order; separates each mean and parenthesized SE into **both printed strings and numeric values**; parses biological n; joins the scoped context without reordering records; and parses the six numerical method-metadata fields. Metadata formatting such as `400.0` versus `400` is not a change in printed measurement precision. No ratio, SE, SD, cell density, cell count, percent, regional average or pooled statistic is recomputed. There is no unit conversion: the ratio and its SE are dimensionless.

`ratio_cell_as_published`, `ratio_mean_printed` and `ratio_se_printed` are the precision-preserving evidence fields. `ratio_mean` and `ratio_se` are their numeric equivalents; a CSV numeric formatter may omit a trailing zero, so use the printed fields for exact source-string comparison.

The reader re-reads the current repository `__ReadMe.xlsx`, Sheet1, matches the exact `Item name` (never a cached row position), obtains `item_encoded`, and checks the retained original-source primary role. The reviewed current registry stem is `10.1073%2Fpnas.0605843103_Table2`. It does not create or update a registry row. The default run writes only the local analysis CSV. A separate, owner-controlled R run may set `EVOM1_WRITE_PUBLIC_TSV=TRUE` to use the current registry stem at repository-level `__Public/comparative-data/`; no TSV is present or produced during this preparation. That opt-in is **not merge approval** or a clean-R/build-validation certificate.

## Observation level, uncertainty and dependence

The printed footnote explicitly says **mean (standard error)**. Parentheses are **SE, not SD**, not a confidence interval and not the stereologic method's coefficient of error. Figure 1C's 95% confidence intervals are not silently substituted.

Each species has **six biological specimens**, and the same six are sampled across four areas in the source's repeated-measures design. The twelve long records are twelve regional author summaries, not twelve independent cohorts or individual records. There are not twenty-four animals per species. Repeating `n_biological = 6` in the long view must not be summed across regions; the constructed `within_species_sample_group` tracks regional dependence and is not an author specimen identifier or a cross-paper case key. Individual observations, covariances, specimen IDs, exact ages and sex assignments are unavailable from this table and are not fabricated.

The reported ratios are the **original authors' derived statistical summaries** of stereologic estimates. Their source role remains **primary**, but the derived ratio is not an independent primary neuronal/glial count observation. The held source does not explicitly resolve mean-of-individual-ratios versus ratio-of-means aggregation; no choice is inferred. Do not back-calculate constituent counts or densities, convert the ratios to percent, or supply pseudo-individual data from the means and SEs.

## Cell and tissue methods

- The glial pool is **astrocytes plus oligodendrocytes without distinction; microglia are excluded**. It is not all glia, all non-neuronal cells or an astrocyte-only ratio. Endothelial cells are distinguished from neurons, not silently added to the glial numerator.
- Neurons were distinguished morphologically in Nissl-stained tissue by dark coarse cytoplasmic Nissl substance, a large nucleus, a distinct nucleolus and lightly stained proximal dendritic segments. Glia lack a conspicuous nucleolus and have less endoplasmic reticulum.
- Left postmortem hemisphere; combined layer II/III. This is neither bilateral whole-cortex data nor layer V/full-depth M1 counts; no hemisphere doubling or layer splitting is performed.
- Nissl optical disector: three sections per cortical area for each cell type, spaced 400 µm apart from a random start; systematic random 30 × 30 µm counting frames; 6 µm disectors; minimum 2 µm guard zones on either side. These are technical sampling dimensions, not biological n.
- The source's upstream cellular densities (Nv) were corrected for histological-processing shrinkage using number-weighted mean section thickness. The published ratios are retained without new shrinkage arithmetic or reconstruction of the unavailable density observations.
- Fixation varied across the study: 10% buffered formalin immersion versus 4% paraformaldehyde transcardial perfusion. Human specimens were immersion-fixed in 10% buffered formalin; some Macaca maura material is described among perfusion-fixed samples. Do not assign a uniform protocol or invent missing specimen-level fixation assignments.
- Humans were nongeriatric adults under 55 years. Exact ages and sex/case identifiers are not in Table 2; supplementary demographic Table 4 is not held and has not been imputed from other publications. None of the main-paper brain samples showed neuropathological abnormality on routine examination, but no per-case health metadata are fabricated.

## Region and species notes; merge hold

Original species labels survive unchanged: `Homo sapiens`, `Pan troglodytes`, `Macaca maura`. No inline accepted-taxonomy mapping is supplied. The package does not import the full paper's eighteen-species sample scope into this three-species table.

Only **Area 4** is the sampled primary motor cortex, specifically the hand-representation region. Area 9L is dorsolateral prefrontal cortex, Area 32 anterior paracingulate cortex, and Area 44 inferior frontal cortex (the paper discusses Broca's area in humans). Regions were identified by topology and confirmed cytoarchitecturally in the source. These author descriptions do not establish a universal homologous cell-count term for all four areas or all species. An item/region-specific anatomy review is still required.

**Scientific merge HOLD:** dimensionless original-derived ratios must not enter a neuronal-count/density merge as independent primary observations. Any future method-explicit ratio product must preserve the restricted glial definition, combined layer, laterality, region identities, SE interpretation and regional repeated-measures dependence. Taxonomy/anatomy review and specimen-collection crosswalks are unresolved. Do not assume biological independence from the Raghanti papers or other collection-associated publications merely because the citation differs. No existing key, merge, source disposition or specimen crosswalk has been modified.

## Online database and checks

Current identity is the exact existing registered item, original-source role `primary`; the registry's human-curation cell remains blank. Descriptive owner-paste corrections are proposals only, not automated workbook changes; in particular Table-1 eighteen-species and cell-density descriptions must not be imported into this Table-2 ratio scope. Blank proposal cells mean **no clear**, including DOI override, Progress stage and Human visual curation. Reserved/generated columns B and E:L are not manually populated; M is descriptive.

Source-string/shape checks, numerical parsing checks, context join, complete ten-column dictionary coverage and static R-reader checks were performed in Python/private preparation material. No independently curated table was available for comparison, and no public comparison folder or audit code is included. The scientific files omit private manifests, renders and original PDFs.

**R/Rscript is unavailable.** R parsing, clean-session execution, canonical audit/dry-run/build/validation and R-vs-Python output parity are all **NOT RUN**. Public TSV release, shared-repository publication and FINISHED status are withheld. Original sources, the registry, central keys/merges, earlier handoffs and the portable workflow remain unchanged. This package stops at one prepared item.
