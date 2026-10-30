# Zilles & Rehkämper (1988) Table 12-2, Pongo — pallidum is nested in Corpus striatum, not Diencephalon

Flagged during review of `restricted_checks/Zilles_Rehkämper_1988/Zilles_vs_Stephan_ape_comparison.R`
(2026-09-20). Not yet acted on in the merge itself — this is a flag for the term map, written up here
so the fix is not lost, following the same pattern as `Smaers_frontal_grey_FINDINGS.md`.

## The finding

`Zilles_Rehkämper_1988_Table12-2.csv` prints "Globus pallidus" (1800 mm3) indented directly under
"Corpus striatum" (11500 mm3) for Pongo. The table's own arithmetic shows this is a true nesting, not
a print-layout artifact: the six telencephalic rows (Neocortex 219800 + Hippocampus 2700 + Regio
entorhinalis 1300 + Paleocortex 2400 + Septum 600 + Corpus striatum 11500) sum to Telencephalon
(238300) **exactly**, leaving no room for Globus pallidus to be an additional, non-overlapping amount.
It must already be counted inside the printed Corpus striatum total. The six major divisions likewise
sum to the whole brain (308500) exactly, so Diencephalon (13500), a separate flush-left row printed
several lines above this cluster, cannot also contain it.

Stephan et al. (1981) bracket pallidum the other way round (`Stephan_etal_1981_definitions.csv`):
Striatum (code 15) "excludes pallidum"; Diencephalon (code 9) is "including pallidum ... excluding
hypophysis". So for this one source:

- Zilles' Corpus striatum (→ `Striatum_Vol.mm3` in the current term map) is **pallidum-inclusive**.
- Zilles' Diencephalon (→ `Diencephalon_Vol.mm3`) is **pallidum-exclusive**.
- Both are the opposite polarity from the Stephan-style columns they are currently mapped onto.

This is the mirror image of an already-documented case: **Reep et al. (2007)** has diencephalon
excluding globus pallidus and striatum including it (see `README__merging.md`, the "Reep 2007 is
also `by_source`" paragraph) — same split, same direction as Zilles here — and Reep's term map already
uses `Diencephalon_excluding_globus_pallidus_Vol.mm3` / `Striatum_including_globus_pallidus_Vol.mm3`
for exactly this reason. `volumes_compiled_select.R` already carries both of those definition-specific
terms in its `bilateral_stems_exclude` list (added for Reep), so the machinery for this fix already
exists in the pipeline — Zilles' own term map was just never switched onto it.

A stale contradiction sits in the paper's own documentation, which is presumably why this slipped
through: `Zilles_Rehkämper_1988/reference_tables/Zilles_Rehkämper_1988_Table12-2_definitions.csv`
still describes `Corpus_striatum` as "corpus striatum (nucleus caudatus + putamen) fresh volume"
(pallidum excluded), which was true before the table's hierarchy columns (`printed_indent`,
`parent_structure`) were added on 2026-09-18 — that addition's own note in the same file says the
opposite: "Build asserts every parent equals the sum of its printed components (Corpus striatum
excepted: only Globus pallidus is printed under it)." The newer, arithmetic-checked note is correct;
the older prose definition was never updated to match.

## Where it currently shows up

- `standardized_term_by_reference/Zilles_Rehkämper_1988_Table12-2_standardized_terms.csv` maps
  `Corpus striatum` → `Striatum_Vol.mm3` and `Diencephalon` → `Diencephalon_Vol.mm3` (plain
  Stephan-style names, no pallidum-scope suffix).
- `volumes_long.csv` (and downstream `volumes_wide.csv`) therefore carry the Pongo row
  `Striatum_Vol.mm3 = 11500` (pallidum-inclusive) in the same column as every Stephan-collection
  ape's pallidum-exclusive Striatum value, and `Diencephalon_Vol.mm3 = 13500` (pallidum-exclusive, on
  this reading) in the same column as Stephan's pallidum-inclusive Diencephalon.
- `Globus pallidus` → `Pallidum_Vol.mm3` (1800) is unaffected and needs no change — it is a genuine
  standalone pallidum measurement, consistent in scope with Stephan's own Pallidum column; the issue
  is only the other two terms colliding with Stephan-style names under a different definition.

## Recommended fix (not applied here)

In `Zilles_Rehkämper_1988_Table12-2_standardized_terms.csv`, rename:

| Original_Term | current Standardized_Term | recommended Standardized_Term |
|---|---|---|
| Corpus striatum | `Striatum_Vol.mm3` | `Striatum_including_globus_pallidus_Vol.mm3` |
| Diencephalon | `Diencephalon_Vol.mm3` | `Diencephalon_excluding_globus_pallidus_Vol.mm3` |

Also update the stale `Corpus_striatum` definition text in
`Zilles_Rehkämper_1988_Table12-2_definitions.csv` to match the 2026-09-18 hierarchy note (pallidum
included), so the two notes in that file stop contradicting each other.

After the rename, `standardized_term.R` needs re-running to restack `standardized_term_volumes.csv`,
and any compiled output (`volumes_compiled.R` / `volumes_compiled_select.R` and their
`volumes_long`/`volumes_wide` outputs) that currently pools this Pongo row into `Striatum_Vol.mm3` or
`Diencephalon_Vol.mm3` needs regenerating so the Pongo values move to the definition-specific columns
instead (where they will sit, appropriately, alone or alongside Reep — not averaged against
pallidum-exclusive/pallidum-inclusive Stephan values of the opposite convention).

## Comparison-script workaround already applied

`restricted_checks/Zilles_Rehkämper_1988/Zilles_vs_Stephan_ape_comparison.R` was updated to add a
derived "Striatum excluding pallidum" comparison row (`Corpus striatum - Globus pallidus` = 9700 mm3
for Pongo) for a clean comparison against Stephan's pallidum-exclusive Striatum, and its crosswalk
notes for Striatum, Diencephalon, and Pallidum were corrected to state the polarity explicitly. That
fix is local to the comparison output only; it does not touch the term map or the compiled merge, both
still flagged above for the same fix at the source.
