# Corticospinal / corticomotoneuronal termination extent (compile-from-literature)

Scaffold for the most **M1-on-theme** Tier-3 candidate (#8 in
`SCOUTING_candidate_papers_20260731.md`; kept per curator, 2026-07-31): the *output pathway* of
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

## Candidate trait (ordinal, graded across the phylogeny)

`CST_termination_grade` — extent of corticospinal termination in the spinal grey, coded ordinally,
e.g. 0 = dorsal horn / intermediate zone only → … → maximal direct CM contact on distal-limb
motoneuron pools. Optionally `CM_monosynaptic` (0/1 presence of direct CM connections). Values are
categorical/ordinal → treated like the other categorical behaviour measures (never averaged).

## Primary sources to compile (gather locally; network policy blocked fetches in-session)

- Bortoff, G. A., & Strick, P. L. (1993). *Corticospinal terminations in two New-World primates:
  further evidence that corticomotoneuronal connections provide part of the neural substrate for
  manual dexterity.* J Neurosci 13(12):5105–5118.
- Nudo, R. J., & Masterton, R. B. (1990). *Descending pathways to the spinal cord* (comparative
  corticospinal series, J Comp Neurol).
- Lemon, R. N. (2008). *Descending pathways in motor control.* Annu Rev Neurosci 31:195–218
  (comparative synthesis of CM-system across species).
- Heffner, R. S., & Masterton, R. B. (1975, 1983) — already in the repo; the dexterity scale is the
  behavioural read-out of this axis (keep the CST-grade and the dexterity measure as **separate
  variables** — dexterity already lives in `__merging_behaviour`).

## Build outline

1. Hand-build `Corticospinal_terminations_snapshot.xlsx` (sheet `Table1`): `Species_printed`,
   `species_sci`, `CST_termination_grade`, `CM_monosynaptic`, `Source` (one primary paper per datum;
   preserve the printed species name — invariant 3).
2. `Corticospinal_terminations.R`: read snapshot → resolve species via `_keys` → analysis CSV +
   public TSV (`__Public/comparative-data/…`; since it is a multi-paper compilation, code it under a
   compilation item name, not one DOI).
3. `reference_tables/Corticospinal_terminations_definitions.csv` (scaffolded).
4. Register in `__ReadMe.xlsx`; **role = secondary** (a compilation); `Team = CST_compilation`.
5. Feed the trait table (a reader beside the dexterity_corticospinal readers) → then
   `__merging_behaviour` as a new `Measure` (`CST_termination_grade`), single-source for now.

## Caution

Ordinal grading is a curatorial judgement — document the coding rubric explicitly in the definitions
and README so it is reproducible, and cite the exact source page/figure per species.
