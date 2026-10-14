# Elston_etal_2005_a_Table4 — prepared estimated basal-tree spines

**Source locus:** printed p.1064, PDF page 8, Table 4. Two printed VM rows × five
area columns become **10 case × area preview rows**. The snapshot preserves the
caption, `Case`, area order `7, 5, 1/2, 4, 6`, ten integer estimates and the printed
area-1/2 note. Analysis reshaping traverses VM1 then VM2 in printed area order.

## Interpretation and dependency

These are the authors' **estimates** of total spines on the basal dendritic tree
of an “average” layer III pyramidal cell. Source pp.1061–1062 describe combining
Sholl branching and spine-density data. The printed estimates are retained,
not recalculated from rounded summaries. They are not newly observed individual
neurons, synapses or independent biological counts.

Conservative measurement role is **secondary (author-derived from this paper's
primary morphology measurements)**, not a claim of a separate literature cohort.
The same two adult male monkeys VM1/VM2, left hemisphere and layer III underlie
these and the source's other morphology tables. Do not merge Table 4 as an extra
independent cohort or sum it with Table 3's technical spine tallies. No independent
contributor n is printed here; it is not borrowed from Table 1 or Table 5.

The published `1/2` label is retained: VM1 was sampled more anteriorly, probably
area 1, and VM2 more posteriorly, probably area 2. This is a caveat, not a certain
anatomical relabelling. Title `Cercopethicus pygerythrus` and methods
`Cercopithecus pygerythrus` remain separate provenance spellings with no inline
accepted-name mapping. Context joins on `Reference + Case + Area_as_published`.

## Bounded source-method caution

No independent contributor n is printed in Table 4; do not import n from another table. Methods state 20 horizontally-projecting dendrites of different neurons in each cortical area. Keep 20 as a study-method quantity: a 20-per-case allocation, panel/case assignment and endpoint-contributing n are not established; do not assume a complete denominator of 20 at every distance. These technical samples are not new animals.

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
