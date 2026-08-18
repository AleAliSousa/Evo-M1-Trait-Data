# DeCasien & Higham 2019 vs the merged volume dataset -- FINDINGS (Part II)

Compared 2190 DeCasien (species x region) volume cells against the merge by VALUE (same genus, tol = 2%).
Crosswalk covers the DeCasien regions that have a single clean counterpart in our merge;
MOB, 'Striatum (incl. NAcc)' and 'Agranular Insula' are intentionally outside it.

## II.A value comparison
- match (same species + same structure, value within tol): **1787**
- match_taxonomy_variant (same structure + value, species NAME differs): **218** -> see II.B
- species_mean_match (individuals unpublished, e.g. Barks; DeCasien's group mean == our species mean within tol): **36**
- value_match_other_structure (value matched a different structure/label): **88**
- decasien_only (no value match in the merge for that genus): **0**
- median |pct diff| on value matches: **0%** (most are 0% -> identical underlying Stephan data)
- merge-only: ~0 Stephan-sourced (species x crosswalked structure) cells not present in DeCasien's sheet.

DeCasien references 24 = Stephan 1981, 51 = Stephan 1970, 52 = Stephan 1988; `ref_is_stephan`
flags rows DeCasien attributes to a Stephan source. High value-match rates on those rows confirm
the merge reproduces the Stephan primaries DeCasien compiled.

## II.B taxonomy
1 species appear under a DeCasien binomial that value-matches a DIFFERENT name in the merge
(typically our genus-level 'sp.' vs DeCasien's full binomial). Proposed variant->accepted additions
to `_keys/Stephan/species_key.csv` are in `DeCasien_taxonomy_proposed_changes.csv` for HUMAN REVIEW;
they are NOT applied automatically (taxonomy lumping needs a human check).

## Outputs
- `DeCasien_vs_merge_comparison.csv` -- per-cell comparison.
- `DeCasien_taxonomy_proposed_changes.csv` -- proposed species_key edits (review before applying).

## II.C organizational practices worth borrowing from DeCasien
- explicit numeric **reference-id columns** per value (we keep `Source`/`Teams`; a stable ref-id
  map like DeCasien's would make provenance joins easier).
- explicit **GM / WM / GM+WM** split naming for cortex/insula (we already do grey/white; adopting
  DeCasien's '(GM)'/'(GM+WM)' convention in column docs would aid cross-dataset joins).
- a single tidy compiled sheet with one reference column -- useful as an export view alongside
  `volumes_long.csv`.
