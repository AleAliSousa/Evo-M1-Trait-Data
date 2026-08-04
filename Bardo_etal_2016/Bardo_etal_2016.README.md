# Bardo et al. 2016 — manipulative potential from hand proportions

Source folder for a **hand-morphology / manipulation** source feeding `__merging_behaviour`
(candidate #2 in `SCOUTING_candidate_papers_20260731.md`; kept per curator, 2026-07-31).

## Source (freeze before cleaning)

Bardo, A., Cornette, R., Borel, A., & Pouydebat, E. (2016). *Assessing the manipulative potentials of
monkeys, apes and humans from hand proportions: implications for hand evolution.* Proceedings of the
Royal Society B 283(1843):20161923. DOI **10.1098/rspb.2016.1923**.

- **What it contributes:** a **manipulability / dexterous-workspace** measure derived from hand
  proportions, for **13 anthropoid species** (137 hand samples: humans, apes, Old- and New-World
  monkeys). Extends the manipulation axis for anthropoids Baker 2025 does not cover.
- **Frozen source:** the paper's supplementary data table (per-species hand-proportion indices /
  manipulability). Digital-native → the download IS the frozen copy; keep it verbatim in this folder.
  Could not be pulled in the scaffolding session (org network policy blocked the publisher/Dryad at
  the egress proxy; no R runtime). Download locally, then write the DOI-coded public TSV
  `__Public/comparative-data/10.1098%2Frspb.2016.1923_<Table>.tsv` (invariant 2).

## Build steps

1. Reader `____EvoM1_TraitTable/EvoM1_read_hand_bardo.R` (scaffolded) — reads the public TSV,
   resolves species via `_keys`, writes `____EvoM1_TraitTable/hand_bardo.xlsx`. **Confirm the exact
   source column name(s)** for the manipulability index at the `TODO(curator)` marker.
2. `reference_tables/Bardo_etal_2016_definitions.csv` (scaffolded; adjust to confirmed headers).
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = Bardo_etal_2016_<Table>`,
   `Item encoded = 10.1098%2Frspb.2016.1923_<Table>`, `Data role = secondary`,
   `Main Trait(s) = hand manipulability / dexterous workspace`, `Taxon group = Primates`,
   `Team = Bardo`.

## Wire into `__merging_behaviour/behaviour_compiled.R` (only after hand_bardo.xlsx exists)

- Add `Bardo = "Bardo"` to `TEAM`.
- Add a `grab("hand_bardo.xlsx","<col>","Manipulability_index","bardo")` line.
- Add a `META` row: `mclass = "hand_morphology"`, single-source unless keyed with Baker (below).

### Construct note — citation-dependency with Baker

Baker 2025 already carries `peak_workspace` (the **Feix et al. 2015 manipulability index**). Bardo's
manipulability derives from the **same Feix-style construct** → if mapped to the same `Measure` it is
**citation-dependent, never averaged** (resolve; Baker or Bardo as primary per curator). If Bardo's
index is methodologically distinct enough, keep it as its own `Measure` (`Manipulability_index_Bardo`)
rather than keying it onto `peak_workspace`. Curator to decide which; default here is a **secondary**
key on the workspace measure, following the VocalRepertoire/Dexterity precedent.
