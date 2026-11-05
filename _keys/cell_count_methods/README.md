# Cell-count methods: summary, decisions and how to update them

This folder records **how every cell number, density and ratio in the repository was counted**, what
each method can and cannot tell apart, and how the merges treat it. The merges read these tables;
method rules are not written into merge scripts. Experts can propose changes through
`expert_reviews.csv` (see *How to update*, below).

Started 4 Nov 2026 (owner decisions RV-2026-001 to RV-2026-005). Checked by
`_checks/check_cell_count_methods.R`.

## Files

| File | One row per | Edited by |
|---|---|---|
| `methods.csv` | counting method: what it counts, what it can tell apart, outputs, limitations, default treatment | owner, after an accepted review |
| `source_methods.csv` | source item, or part of an item (`filter`): its method, target merge, treatment and flag | owner or builder; experts propose |
| `pooling_rules.csv` | quantity x method pair: whether values may be combined in the opt-in pooled product | owner, after an accepted review |
| `expert_reviews.csv` | proposal or decision; every change to the other three tables cites a `review_id` | anyone proposes; owner decides |

## Where cell counts go

| Merge | Holds |
|---|---|
| `__merging_cell_counts_isotropic_fractionator` | nuclei counted in suspension (isotropic fractionator; flow fractionator): whole dissected structures, and later per-area tables |
| `__merging_cell_counts_histology` | counts made in tissue sections: design-based stereology by default; older model-based counts kept but off by default |
| `__merging_cell_morphology` | named cell types described by size or shape (von Economo neurons, interlaminar astrocytes, soma volumes) |

Folder names follow the 4 Nov 2026 decision (RV-2026-004); `_tools/__rename_cell_counts_20261104.R`
renames the existing merge and every reference to it.

## The methods in brief

| Method id | Family | Counts | Tells apart | Usual outputs | Main limits | Default |
|---|---|---|---|---|---|---|
| `STEREO_OPTICAL_FRACTIONATOR` | design-based stereology | cells in optical disectors at known sampling fractions | neurons, glia, glial subtypes, endothelium (by morphology or markers) | total N; density per mm3 with a volume | small neurons scored as glia; z-axis shrinkage, lost caps | include |
| `STEREO_DISECTOR` | design-based stereology | cells per disector volume (Nv) | as above | Nv per mm3; N = Nv x volume; GNR | density depends on shrinkage and the reference volume (the reference trap) | include |
| `STEREO_UNSPECIFIED` | design-based stereology | as reported | as reported | as reported | probe not yet recorded here | include |
| `HIST_PROFILE_CORRECTED` | model-based histology | nuclear or nucleolar profiles, corrected by formula (e.g. Abercrombie) | neurons vs glia | density per mm3 | depends on assumed particle size and shape and on section thickness | off by default |
| `HIST_PROFILE_UNCORRECTED` | model-based histology | profiles or nucleoli per section, box or strip, no size correction | neurons (sometimes glia) | counts per sample; density | unequal sampling of large and small cells; shrinkage; few animals | off by default |
| `HIST_METHOD_UNVERIFIED` | histology | as reported (includes 1980s early stereology) | as reported | as reported | probe not checked | include, flagged |
| `HIST_SECTION_AREAL` | 2-D histology | profiles per mm2 of section or per field | as reported | cells per mm2 of section | depends on section thickness and cell size | own label, never pooled |
| `IF_HEMOCYTOMETER` | homogenate | all nuclei of a dissected structure; NeuN fraction | neurons vs all other cells (glia plus endothelium) | cells, neurons, non-neurons; per mg; nNNR | no spatial detail; NeuN-negative neurons counted as non-neuronal | include |
| `IF_FLOW` | homogenate | as above, counted by flow cytometry | as above | per piece, per g, per area of cortex | as above; per-area values depend on the surface measurement | include |
| `HOMOGENATE_DIRECT_ENUMERATION` | homogenate (1950s-70s) | nuclei of unfixed or sonicated tissue | poorly | total cells | counts too low; poor cell typing | exclude |
| `DNA_EXTRACTION` | DNA (1950s-70s) | DNA content / DNA per nucleus | none | total cells | incomplete recovery; fixed white matter; polyploidy | exclude |
| `TRACER_LABELLED` | tract tracing | neurons labelled from an injection | one projection population | labelled number or density | not a count of all cells | own label, never pooled |
| `COMPILATION` | secondary | values re-reported from other papers | as cited | mixed | mixed methods; duplicates primary data | not merged |
| `NOT_A_COUNT` | routing | soma size, axons, vessels, synapses, fibres | | | | sent to another merge |

## Why the methods are kept apart

- **Different "other cells".** The fractionator separates NeuN-positive nuclei from everything else,
  so its non-neuronal cells include endothelial cells (about 12-30% of non-neuronal cells). It gives
  a non-neuron to neuron ratio (nNNR), never a glia-neuron ratio (GNR). Stereology classifies cells in
  sections, so it gives a GNR, but small neurons can be scored as glia (Bahney & von Bartheld 2018).
- **Different density bases.** Section counts give cells per mm3 of fixed, processed tissue, which
  moves with shrinkage and with how the reference volume is drawn; the fractionator gives cells per mg;
  2-D counts give cells per mm2 of section; some studies give cells per mm2 of cortical surface.
- **Where the methods agree.** Side-by-side tests found the fractionator recovers about 100% of the
  nuclei stereology finds in primate white matter (Bahney & von Bartheld 2014), and spinal-cord
  totals did not differ significantly between the methods (Bahney & von Bartheld 2018). That is the
  basis for pooling **totals** in the opt-in product; neuron numbers pool only with a flag.

## Treatments (`treatment` in `source_methods.csv`)

| Value | Meaning |
|---|---|
| `include` | enters its merge under a method-labelled variable |
| `include_flagged` | enters with the `flag` text shown beside the value |
| `include_own_label` | enters under its own label and is never pooled with other studies |
| `off_by_default` | kept in the merge output with `merge_default = FALSE`; shown only when a user opts in |
| `not_merged` | built and browsable, not merged (secondary re-reports, clinical or within-species groups, duplicate printings) |
| `exclude` | never merged (an owner decision with evidence) |
| `queued` | method known; merge design pending |
| `route_elsewhere` | part of a counting source that belongs in another merge |

A row with an empty `filter` covers the item's rows that no more specific row of the same item matches.
Filters are R expressions on the item's public TSV columns, as in
`__merging_supplementary/supplementary_sources.csv`.

## Older and flagged sources (4 Nov 2026)

- **Excluded:** Rockel et al. 1980 (two-dimensional profile counts per strip; RV-2026-002). Carlo &
  Stevens 2013 re-counted the same question with modern stereology.
- **Off by default (model-based; RV-2026-003):** Campos & Welker 1976; Armstrong 1979 neuron
  densities and numbers; Huttenlocher 1979 neuron density; the pre-1985 rows of Bahney & von Bartheld
  2018 Table 3 (Friede 1954, Hawkins & Olszewski 1957, Giuffrida et al. 1979).
- **Flagged, secondary:** the 1980s rows of Bahney & von Bartheld 2018 Table 3 (Haug 1987,
  Stolzenburg et al. 1989); Feinberg et al. 1990 (re-plot of Huttenlocher 1979).
- **Not cell counts:** Lassek & Rasmussen 1940 (fibres); Huttenlocher 1979 synapse density.
- **Live elsewhere, decision pending:** Armstrong 1979 perikaryal volumes in the cell-morphology merge.
- **Not old, but flagged by later work:** Burish et al. 2010 spinal-cord ratios, and the African
  elephant ratios (Herculano-Houzel et al. 2014, in the 2015 dataset), lie well above the trend of
  other species (Bahney & von Bartheld 2018).

## How to update (for experts)

1. **Propose.** Add one row per changed field to `expert_reviews.csv` with `status = proposed`:
   your name, your expertise, `target_file` and `target_id` (a `method_id`, a `rule_id`, or an
   `item_name` with its `filter`), the `field`, its current and proposed values, your rationale, and
   evidence (DOI or PMID with page, table or figure). Do not edit the other three tables yourself.
   On GitHub, open a pull request that adds the row, or an issue that quotes it.
2. **Decide.** The owner (or a named delegate) sets `status` to `accepted`, `rejected` or
   `superseded`, with `decided_by` and `decided_date` (YYYY-MM-DD).
3. **Apply.** For an accepted review, edit the target row, and set its `status = accepted`,
   `decided_by`, `decided_date` and `review_id`. Never delete a row: set `status = retired` and name
   the replacement in `notes`.
4. **Check.** Run `Rscript _checks/check_cell_count_methods.R`. It fails if a method, rule or review
   id does not resolve, if a value is outside the vocabulary, or if an exclusion lacks a reason and
   evidence.
5. **Re-run** the affected merge(s).

Guidance: evidence outranks age. Prefer a source-level change in `source_methods.csv` when the
evidence concerns one study; change a method default only when the evidence concerns the method.
Rows written by the AI assistant carry `status = proposed` until the owner or an expert confirms them.

## Open questions for experts

- **PR06:** neurons under 1 mm2 of cortex from stereology (Carlo & Stevens 2013) and from the
  fractionator with a measured surface (Herculano-Houzel et al. 2008; Collins; Young) measure the same
  quantity but reached opposite conclusions about uniformity. May they ever be pooled?
- Probe and correction used by Haug 1987 and Stolzenburg et al. 1989, and the stereological probe of
  Lewitus et al. 2012 and Carlo & Stevens 2013 (recorded as `STEREO_UNSPECIFIED`).
- Keep or hold the outlying ratios flagged by Bahney & von Bartheld 2018 (Burish 2010; elephant 2014)?
- Default for Armstrong 1979 perikaryal volumes in the cell-morphology merge.

## References (read for this summary)

- von Bartheld CS, Bahney J, Herculano-Houzel S (2016). The search for true numbers of neurons and
  glial cells in the human brain: a review of 150 years of cell counting. *J Comp Neurol* 524:3865-3895.
  doi:10.1002/cne.24040
- Herculano-Houzel S, von Bartheld CS, Miller DJ, Kaas JH (2015). How to count cells: the advantages
  and disadvantages of the isotropic fractionator compared with stereology. *Cell Tissue Res* 360:29-42.
  doi:10.1007/s00441-015-2127-6
- Bahney J, von Bartheld CS (2014). Validation of the isotropic fractionator: comparison with unbiased
  stereology and DNA extraction for quantification of glial cells. *J Neurosci Methods* 222:165-174.
  doi:10.1016/j.jneumeth.2013.11.002
- Bahney J, von Bartheld CS (2018). The cellular composition and glia-neuron ratio in the spinal cord
  of a human and a nonhuman primate. *Anat Rec* 301:697-710. doi:10.1002/ar.23728
- Herculano-Houzel S, Collins CE, Wong P, Kaas JH, Lent R (2008). The basic nonuniformity of the
  cerebral cortex. *PNAS* 105:12593-12598. doi:10.1073/pnas.0805417105
- Carlo CN, Stevens CF (2013). Structural uniformity of neocortex, revisited. *PNAS* 110:1488-1493.
  doi:10.1073/pnas.1221398110

Cited through those reviews and not re-checked here: Abercrombie 1946; Nurnberger & Gordon 1957;
Herculano-Houzel & Lent 2005; Collins et al. 2010; Miller et al. 2014; Haug et al. 1984.
