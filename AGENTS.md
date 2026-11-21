# Replot extracted figure data

For every new or updated figure-derived dataset, add a separate `<Item>_replot.R`
in the paper folder. Read the extracted item table directly and use the simplest
practical R plotting code (prefer base R) to reproduce the figure's shape for an
easy visual check. Preserve panel/series identity, source order, axis scale and
units; include extracted error bars when available, without inventing their type.
Do not hardcode measurements, refit/smooth the data, or rerun extraction/merges.
Save `<Item>_replot.png` beside the script, run it, inspect it against the source,
and document the command and any omissions in the item README. This supplements
source/snapshot checks; it does not constitute human visual signoff.

Past figures are an active backfill task: see
`____TODO/figure_replots_handoff.md`. Itoh Figure 2 is the worked example.

# Missing taxonomic orders

NCBI is the first lookup because it is quick and genome-linked, not a requirement
for recognizing a taxon. **An NCBI miss must proceed to another database.**
For living/recently extinct mammals use the Mammal Diversity Database (MDD),
including its synonyms; then GBIF and ITIS. Use the Paleobiology Database for
older fossils and taxonomic literature/source-paper evidence when needed.
Follow `_keys/README_navigation_taxonomy.md` and the executable lookup ladder.

Do not close a genuine animal's missing Order as "not in NCBI". Record database
attempts, resolve synonyms/spelling from evidence, and preserve the source label.
An unresolved scientific name remains an active curation task with a specific
next action. Distinguish non-taxon text, unspecified animal labels, API errors,
ambiguous matches, and taxonomic conflicts. An API outage is not a no-match.

These navigation classifications do not authorize changing species identity,
pooling measurements, inventing an NCBI taxid, or assigning order to anatomical
or clinical text accidentally occupying a Species field.
