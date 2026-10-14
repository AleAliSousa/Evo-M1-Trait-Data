# Elston_etal_2005_a_Table5 — prepared tangential somal areas

**Source locus:** printed p.1065, PDF page 9, Table 5. **10 case × area cell-sample
summary rows**, in VM1/VM2 group order and area order `7, 5, 1/2, 4, 6`. The frozen
snapshot retains caption, group-only rows, original `Visual area` header (despite
sensory-motor data), `n`, mean, S.D., S.E.M., minimum and maximum, printed μm²
labels and all printed decimal precision. The erroneous-looking header is not
silently repaired in the evidence; the analysis calls the field
`Area_as_published`.

## Interpretation and dependency

These are original **layer III pyramidal soma outline areas in the tangential
plane**, in μm². They are not soma volumes, dendritic field areas or whole-cortex
surfaces. Methods p.1062 describe drawing cell bodies in that plane. Five area
statistics are retained exactly as numerical values; SD and SEM are distinct
printed fields and are not recomputed or substituted. R reads rather than embeds
the measurements.

Role is **primary for these original within-animal somal summaries**, with a
same-cohort dependency hold: the two adult male animals, left hemisphere and
layer III are shared with the source's other morphology tables. `n_cells` is the
sample of cells within that case/area, not the number of animals. **VM2 area 6
has n=40 in Table 5 but n=41 in Table 1**; both source values remain uncorrected.
Do not invent the excluded-cell identity or use either count as an animal n.

The likely anterior area-1/posterior area-2 distinction under the combined `1/2`
label remains explicit context. Both title and methods taxonomic spellings are
preserved without accepted mapping. Context joins on
`Reference + Case + Area_as_published`.

## Bounded source-method caution

Table 1 printed cell-n values sum to 274, Table 5 values sum to 273, and Results reports 273 analysed cells. VM2 area 6 has Table 1 n=41 versus Table 5 n=40. Keep every printed value and the inconsistency unchanged; do not repair, infer missing-cell identity or treat these technical cell counts as independent animal n.

## Source identity and owner decisions

The correct source is the vervet paper in *Neuroscience* 134 (2005), 1057–1068,
DOI **10.1016/j.neuroscience.2005.04.054**. The current source holdings are swapped:
`Elston_etal_2005_b/Elston-2005-Specialization in pyramidal cell s.pdf` contains this
vervet article, whereas `Elston_etal_2005_a/elston_etal_2005.pdf` contains the baboon
article, DOI 10.1002/ar.a.20217. Neither original was changed, moved or renamed.
This discrepancy is recorded as unprinted context, not inserted into the snapshot.
Owner resolution of source placement is required.

Current exact registry item matches encode DOI suffix **.056**, not the printed
**.054**; Citation A therefore has an owner-only correction proposal. Column C is
blank/default and is **not** silently overridden. The original registry, keys,
merges, source originals and earlier portable workflow are unchanged. There is no
new public TSV or shared upload.

## Files and reproducibility

- `_snapshot.csv`: frozen printed-table view; caption, headings, groups, order,
  precision and any table note precede cleaning. Open it alongside the source.
- `.csv`: real Python-generated analysis preview, not output from executed R.
- `.R`: self-locating reader of the frozen snapshot and item context. Source-frame
  `ofile` and `file` candidates are tested before an `Rscript --file` fallback.
- `reference_tables/*_context.csv`: separate item-scoped, joinable interpretation
  and source-location record, including blank human-curation fields.
- `reference_tables/*_definitions.csv`: exact ten-column dictionary, covering
  every analysis column plus observation-level and method notes.

The saved reader derives `item_name` from its own filename and retains the house
`folder`, `base`, `item_name`, `item_encoded`, `final.dataframe` variables. It writes
an analysis CSV from frozen inputs; it never reconstructs the snapshot from
measurement literals. In a complete local repository it looks up the registry by
**exact Item name**, requiring one match, and reads **Item encoded** without
substituting another stem. `utils::` CSV/table functions are qualified for the
canonical base-parent execution environment.

Default execution writes **analysis only**. Public export is opt-in via
`options(evom1.export_public = TRUE)`, but refuses before writing a TSV unless the
current registry stem equals the DOI printed in the context and the owner has
resolved source placement (`source_placement_status = owner_resolved`). Neither
condition is satisfied in this prepared package. Do not bypass those holds or
paste a FINISHED state.

## Preparation checks, not completion

Reader/transcriber: **AI assistant, 2026-10-10**. Numerical strings were extracted
from the source text with `pdftotext -layout` and checked with independently
positioned `pdfplumber` table extraction. μm² transcribes the printed unit glyph;
line wraps and decorative spacing are the only presentation adaptations. Python
reads the saved snapshots and contexts to produce the supplied previews, checks
numeric/source parity, row order, joins, dictionary coverage and fixed schema.
Static checks inspect saved R code and public-export guards.

**R NOT RUN**: no R parse, clean-session execution, canonical audit/build/validate,
or R/Python output parity has been certified. AI source-text checks are not human
by-eye curation; **Human visual curation remains blank**. Prepared files do not
establish accepted taxonomy, scientific comparability, merge eligibility or a
completed shared-repository build. The owner should perform source-side visual
review and exact-item R execution only after resolving the identity holds.
