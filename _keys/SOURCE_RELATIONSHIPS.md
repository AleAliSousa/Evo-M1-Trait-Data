# Source relationships — why one source outranks another for the same cell

`source_relationships.csv`: one row per unordered pair of paper folders that
publish a value for the same species × measure, stating the relationship the
**papers themselves declare** between their data, with the passage that
declares it. Read by the `__merging_*` builds (priority) and by stage 11 of the
`*_refs_check` pipelines (does the compiler's observed choice follow the
declared relationship?). It replaces "newer wins" — which is correct for only
one of the relationships below — with a rule per pair.

## Relationship vocabulary

| relationship | the later paper (B) says of the earlier (A) … | rule for the same cell |
|---|---|---|
| `supersedes` | same laboratory and collection; B re-measures or re-averages A's specimens (often with new ones) and states that unchanged values are repeated | take B; mark A superseded. Never carry both. |
| `reprints` | B copies A's values (possibly converted, rounded or under a new column name) and says so | take A (primary); cite B as `secondary` for those rows |
| `derives_from` | B computes its value from A's printed data (mass / 1.036, 2 × unilateral, L + R) | take A's printed quantity as the primary; B's derived value is a recalculation, recorded not merged |
| `extends_sample` | B adds specimens to A's series but does not restate A's mean | take B for the species mean; A survives as per-specimen data only |
| `independent_remeasurement` | different specimens (or collection), comparable method and definition | both are data: pool as distinct primary studies (`n_studies`), or split if the method differs |
| `same_specimens_different_method` | B re-measures A's specimens with another method (MRI vs histology, different shrinkage correction) | different measure — split by `method_basis`, never choose |
| `redefines_structure` | B's structure or criterion boundary differs from A's (Zilles "Paleocortex" incl. amygdala; cerebellum ± pons; a 60 dB vs other threshold) | different variable — split, never choose |
| `unrelated_overlap` | the two papers happen to publish the same species × measure with no stated connection | treat as `independent_remeasurement` until one of the papers says otherwise |

`direction` names the winner (`X over Y`) or `none` (pool) or `split`.
`scope` limits the row ("non-hominoid rows of Supp. Table 2", "LGN only"); a
pair may have several rows with different scopes.

## Evidence

`evidence_quote` is verbatim from the paper (Introduction, Methods, table
caption or footnote), `evidence_locator` gives paper, section and page, and
`evidence_type` says where it came from:

- `paper_text` — quoted from the PDF (preferred);
- `readme` — the transcribed item's README already records the statement;
- `inferred_from_profiles` — no passage names the pair, but each paper's own
  provenance statement (collection, specimens, method) settles it — the two
  passages are quoted;
- `undeclared` — nothing found; the row keeps the observed counts only.

`status`: `drafted` (entered from text by a session; to be read by the
curator), `confirmed` (curator read the passage), `undeclared`.

## Observed columns

`cells_both_offer`, `observed_chosen_a/b/neither`, `pipelines` are copied from
stage 11 (`source_priority.csv`, collapsed from table pairs to paper pairs) at
the date in `date`; they are the compiler's behaviour, not part of the rule.
Stage 11 recomputes them on every run and reports
`follows_declared_relationship` per pair and the exceptions per cell.

## Rules of use

1. Never infer a relationship from year alone; `newer` is what the audit
   *observed*, not a reason.
2. A `reprints`/`derives_from` row does not make the later paper worthless —
   it is primary for whatever it measured itself (de Sousa 2010: the hominoid
   and *Macaca fascicularis* specimens). Give that a second row with its own
   scope.
3. `supersedes` requires the paper to say that the earlier specimens are
   included; if it only adds specimens, use `extends_sample`.
4. When the observed choice contradicts the declared relationship, the
   compiler decision goes to the pipeline's `COMPILER_DECISIONS.md` exceptions
   table with the cell ids; it is never "fixed" in the key.

## State of the key (2026-09-30)

191 paper pairs / 220 rows (27 pairs carry more than one scope): 214 `drafted`,
6 `undeclared` (Frahm 1984 vs Stephan 1970 — no common measure; Heffner 1998
vs Heffner 1994b; the four pairs with Heffner 2020 Fig. 3, which carries no
reference key). Evidence: 75 `paper_text`, 132 `inferred_from_profiles`, 7
`readme`. Drafted by three reading passes over the PDFs (Stephan-lab papers;
1998–2015 primate papers; sensory papers) on 2026-09-29; the two curator
passages (Stephan 1981 Introduction; de Sousa 2010 Methods) are kept verbatim
as their own rows. Every `drafted` row awaits the curator's `confirmed`. Paper
profiles behind the drafts (collection, specimens, method, up to three quotes
each) are saved as session artifacts `paper_profiles_*.csv`.

Stage 11 conformity at that date — pairs: Stephan_primates yes 27 / no 8 /
scoped_mixed 14; DeCasien yes 21 / no 9 / scoped_mixed 12 / pool-or-split 100;
Sensory yes 11 / no 7 / scoped_mixed 5. `scoped_mixed` pairs need the cell's
column to resolve (the key has different winners for different structures);
adding a `comp_column` to the stage-11 cells table is the next step.

Note on identifiers: the pipeline token `Sherwood_etal_2004` is the *Am. J.
Primatol.* 63 MRI paper (folder `Sherwood_etal_2004`), not the Brain Behav.
Evol. GLI paper (`Sherwood_etal_2004_I`).
