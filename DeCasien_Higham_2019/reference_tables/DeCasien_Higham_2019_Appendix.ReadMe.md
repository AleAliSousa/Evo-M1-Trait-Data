# DeCasien & Higham 2019 — Appendix, tabulated

Source: `41559_2019_969_MOESM1_ESM.pdf` (Supplementary Information), **Appendix**,
pages 12–16. Transcribed 2026-09-21. Two tables:

| file | rows | grain |
|---|---|---|
| `DeCasien_Higham_2019_AppendixStructureDefinitions.csv` | 67 | one row per (structure x source paper) |
| `DeCasien_Higham_2019_AppendixSourceNotes.csv` | 10 | one row per source/species decision |

## What this is, and what it is not

These tables record **the compiler's stated intent** — what DeCasien & Higham say
each source measured and how they combined it. That is a third and separate class
of evidence from:

1. **the source's own definitions file** (`<Paper>/reference_tables/<Paper>_definitions.csv`) —
   what the source itself says it measured; and
2. **this repo's crosswalk note** — how a term was keyed for the audit.

Do not substitute this appendix for (1). The house convention exists because the
crosswalk once asserted that Stephan's striatum *excluded* the nucleus accumbens
while Stephan's own definitions file says it includes it. An appendix is a
secondary account and can be wrong about a source in the same way. Its value is
that **a disagreement between (1) and this table is itself a finding** — it
locates a place where the published analysis may rest on a definition the source
does not support.

## Columns

`structure`, `source_paper`, `ref_numbers` (DeCasien's own reference numbers),
`includes`, `excludes`, `derivation_rule` (doubling, combining, unit conversion),
`comparability_note`, `used_in_analysis`, `pdf_page`, `verbatim` (the clause, for
anything a paraphrase could distort).

## Uses in the audit pipeline

- **Exclusion guard.** Five (structure, source) pairs are stated as *not used*:
  Semendeferi & Damasio throughout (whole brain excludes medulla, pons and most of
  the midbrain), Stephan's V1 (white-matter borders arbitrarily defined; Frahm's V1
  grey matter used instead), and Barks' thalamus (posterior thalamus omitted).
  Crediting one of these as `actual_source` would attribute a value to a source the
  compiler says she did not use. Checked by `check_appendix_exclusions.R`.
- **Derivation rules the audit must reproduce.** Frahm BV = V1 volume / (V1 as % of
  brain weight) / 1.036; Stimpson BV = fresh brain weight / 1.036; de Sousa V1 and
  LGN are left-hemisphere measurements doubled; Zilles neocortex = neocortex + V1
  grey matter; de Sousa neocortex = neocortex + corpus callosum; MacLeod and Barks
  cerebellum = hemispheres + vermis.
- **Anatomy key.** `includes` / `excludes` give the structure key a documented
  starting point per source, to be confirmed against that source's own definitions.
- **Species identity.** The appendix states that Cebus and Alouatta identities come
  from the 1988 listing of the same data — the co-cited-reference route the audit
  already uses.

## Known gaps in the appendix itself

12 (structure, source) pairs record that the source gives no delineation
detail, and 4 are explicitly assumptions by the compiler rather than statements
by the source: Zilles_Rehkampfer Telencephalon, Barks_etal Striatum, Stephan_etal LGN, Bush_Allman LGN.
Those are flagged in `comparability_note` and should not be read as source facts.
