# Heuer et al. 2019 — Evolution of neocortical folding (34 primate MRI)

Source folder for a **neocortical folding** source (candidate #5 in
`SCOUTING_candidate_papers_20260731.md`; **reinstated** 2026-07-31 — owner reports no known issue
with Heuer). This is **neocortical** folding — a separate question from cerebellar folding, which is
out of scope.

## Source (freeze before cleaning)

Heuer, K., Gulban, O. F., Bazin, P.-L., Osoianu, A., Valabregue, R., Santin, M., Herbin, M., &
Toro, R. (2019). *Evolution of neocortical folding: a phylogenetic comparative analysis of MRI from
34 primate species.* Cortex 118:275–291. DOI **10.1016/j.cortex.2019.04.011**.

- **What it contributes:** folding metrics (folding index, and typically surface area / exposed
  surface / average fold size) across **34 primate species** from MRI.
- **Frozen source:** the paper's supplementary data (digital-native → download IS the frozen copy).
  Could not be pulled in the scaffolding session (network policy; no R). Download locally; keep
  verbatim; write `__Public/comparative-data/10.1016%2Fj.cortex.2019.04.011_<Table>.tsv` (invariant 2).
  The analysis code/data are also on the authors' repository (Toro lab / OHBM-style GitHub).

## Do NOT auto-pool into `__merging_gyrification` — method mismatch

The gyrification merge pools **only the Zilles-method neocortical GI** (inner+buried contour ÷ outer
contour, on coronal histological sections) and **deliberately excludes** other folding constructs
(e.g. the Mota & Herculano-Houzel folding index). Heuer's folding index is an **MRI surface-based**
measure — a different construct/method. Two acceptable homes, **curator's choice**:

1. **Reconcile to GI** — only if Heuer's metric can be shown equivalent to the Zilles GI definition;
   then it may enter the GI merge as its own team (MRI), resolved not averaged against Zilles/Lewitus.
2. **House separately** (default) — keep as an MRI folding source in this folder (like Mota FI lives
   in its own folder), exposing folding index + surface columns, and decide later whether/how it
   joins a folding comparison. Its **surface-area** columns belong with cortical-surface data
   (`__merging_cortical_areas`), not the GI merge — same rule the GI README applies to Mota.

## Build steps

1. Confirm the SI column headers (folding index; total/exposed surface area; average fold size;
   any GI-equivalent column). Units: surface mm² (×100 if cm²).
2. `reference_tables/Heuer_etal_2019_definitions.csv` (scaffolded; complete once headers are known).
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = Heuer_etal_2019_<Table>`,
   `Item encoded = 10.1016%2Fj.cortex.2019.04.011_<Table>`, `Data role = secondary`,
   `Main Trait(s) = neocortical folding (MRI)`, `Taxon group = Primates`, `Team = Heuer_MRI`.
4. Wire into a merge **only after** the curator picks option 1 or 2 above — no merge script is edited
   by this scaffold.
