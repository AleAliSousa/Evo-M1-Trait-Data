# Elston_etal_2005_a_Table6 — prepared historical cortical surfaces

**Source locus:** printed p.1066, PDF page 10, Table 6. **12 printed taxon-label
rows** × total, motor and visual surface-area columns. The snapshot retains the
caption, its attribution to Brodmann (1913), header order, printed common-name
labels, Baboon parentheticals, row order and thousands separators. Parsing removes
thousands separators only in the analysis view; no species labels or measurements
are inserted into R.

## Historical secondary provenance and unresolved scope

All three measures are **secondary**: Elston 2005 reprints Brodmann 1913. They are
not newly measured vervet data and must not enter a primary merge as independent
observations. Original Brodmann works, specimens and translations were not
independently inspected here.

**mm² is contextual**: Fig.6 p.1065 says both plotted axes are mm², but the Table 6
caption/header does not itself print a unit. The contextual interpretation stays
outside the faithful snapshot and is explicit in definitions and context. Fig.6
defines precentral motor cortex as **areas 4 and 6 together**, not M1 alone. Visual
cortex is retained under its published scope without inventing a new anatomical
boundary.

Original specimen n and unilateral/whole/bilateral convention are **unresolved**.
No doubling, hemisphere total or animal n is inferred. Printed labels such as
`Guenon`, `Macaque`, `Capuchin monkey` and the two `Baboon (P. …)` labels survive;
no modern species mapping is invented.

Context joins on `Reference + taxon_as_published`. The analysis keeps
`ref_key = Brodmann (1913)` and joins to
`reference_tables/Elston_etal_2005_a_Table6_references.csv` on `ref_key`. That lookup
contains only the numerical source and the actually used Fig.6 contextual works:
Brodmann (1909), Garey (1994), Elston and Garey (2004). For contextual joins split
`context_ref_keys` on `; ` before joining. Translations are provenance routes,
not additional independent measurements; this is not the full bibliography.

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
