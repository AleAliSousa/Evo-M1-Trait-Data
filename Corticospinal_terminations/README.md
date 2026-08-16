# Corticospinal / corticomotoneuronal termination extent (compile-from-literature)

Built dataset for the most **M1-on-theme** literature-compilation candidate: the *output pathway* of
primary motor cortex. Extends the existing dexterity–corticospinal axis (Heffner & Masterton 1975/
1983, already in the repo, read by `____EvoM1_TraitTable/EvoM1_read_dexterity_corticospinal*.R`) with
the **termination-pattern** evidence that the Heffner dexterity scale is a proxy for.

## Why this is a hand-built compilation, not a download

There is **no single comparative dataset**. The trait — how far corticospinal axons descend and
whether they make direct (monosynaptic) corticomotoneuronal (CM) contacts onto motoneurons — exists
only as per-species observations scattered across tract-tracing / electrophysiology papers. So this
follows the **printed/scanned route** of `__HOWTO_build_a_dataset_file.md`: build a hand-verified
`Corticospinal_terminations_snapshot.xlsx` (one row per species, value + source), then the analysis
CSV + DOI-less/compilation TSV + definitions + README.

## Built trait and coding rubric

`CST_termination_grade` is a deliberately conservative three-level ordinal:

- `0`: absent or virtually absent from ventral horn / lamina IX
- `1`: sparse or highly restricted ventral-horn / lamina IX termination
- `2`: dense and extensive ventral-horn / lamina IX termination

The first release has the two directly compared species in Bortoff & Strick (1993): *Cebus apella*
(joined as *Sapajus apella*, grade 2) and *Saimiri sciureus* (grade 1). The source explicitly warns
that light-microscopic terminal fields do not prove monosynaptic connectivity. Therefore
`CM_monosynaptic` is blank for both rows; `CM_connection_inference` records the paper's softer
`likely` / `against` interpretation instead of turning that inference into a false binary fact.

## Frozen primary evidence

- Bortoff, G. A., & Strick, P. L. (1993). *Corticospinal terminations in two New-World primates:
  further evidence that corticomotoneuronal connections provide part of the neural substrate for
  manual dexterity.* J Neurosci 13(12):5105–5118.
- `Bortoff_Strick_1993.pdf` is the open-access 14-page article retrieved from Europe PMC on
  2026-08-15 (SHA-256 `bbb7baad6b0777f600e973dbd0911a5540ec7868528b5446fe1ae654e6f81e0c`). The snapshot
  records exact result/discussion pages and figures for each row.
- Nudo & Masterton (1990) concerns comparative **origins**, not the termination grade, so it was not
  used to manufacture termination values.
- Lemon (2008) remains a useful comparative review, but broad clade-level statements were not
  assigned to species without a species-specific primary observation.
- Heffner & Masterton's dexterity scale stays a separate behaviour variable; it is never used as a
  substitute for the anatomical grade.

## Rebuild

1. Use the committed, hand-verified `Corticospinal_terminations_snapshot.xlsx`. If the evidence rows
   change, `create_snapshot.mjs` recreates it in the Codex artifact-tool runtime.
2. `Rscript Corticospinal_terminations/Corticospinal_terminations.R`
3. `Rscript __merging_behaviour/behaviour_compiled.R`

Outputs are the snapshot, analysis CSV, DOI-less compilation TSV, and
`____EvoM1_TraitTable/corticospinal_terminations.xlsx`. The behaviour merge carries the grade and
the qualitative CM inference as separate measures.

## Caution

This is a secondary curatorial compilation. Adding a species requires a species-specific tract-
tracing or electrophysiology result with the exact page/figure recorded; broad review statements
are not enough. The compilation is registered in `__ReadMe.xlsx` under the stable
`COMPILATION:Corticospinal_terminations` identifier and is included in the Shiny source manifest.
