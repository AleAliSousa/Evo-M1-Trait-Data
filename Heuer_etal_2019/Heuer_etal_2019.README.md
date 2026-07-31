# Heuer et al. 2019 — Evolution of neocortical folding (34 primate MRI)

Source folder for a **neocortical folding** source (candidate #5 in
`SCOUTING_candidate_papers_20260731.md`; **reinstated** 2026-07-31 — owner reports no known issue
with Heuer). This is **neocortical** folding — a separate question from cerebellar folding, which is
out of scope.

## Source (freeze before cleaning)

Heuer, K., Gulban, O. F., Bazin, P.-L., Osoianu, A., Valabregue, R., Santin, M., Herbin, M., &
Toro, R. (2019). *Evolution of neocortical folding: a phylogenetic comparative analysis of MRI from
34 primate species.* Cortex 118:275–291. DOI **10.1016/j.cortex.2019.04.011**.

- **What it contributes (verified 2026-07-31 against the paper's methods):** 3-D MRI
  surface-reconstruction folding metrics across **34 primate species / 65 individuals** — an
  **absolute gyrification index**, **total folding length**, **average fold wavelength** (~stable
  12 mm ± 20 % despite ~20× cerebral-volume range), and **average fold depth**, plus cerebral surface
  area and convex-hull surface.
- **Frozen source:** the authors' archived dataset on **Zenodo doi:10.5281/zenodo.2538751**
  (digital-native → the download IS the frozen copy; also on the Toro-lab GitHub). Could not be pulled
  in the scaffolding session (network policy; no R). Download locally; keep verbatim; write
  `__Public/comparative-data/10.1016%2Fj.cortex.2019.04.011_<Table>.tsv` (invariant 2).

## DECISION: house separately — do NOT pool into `__merging_gyrification` (method differs, confirmed)

Owner decision (2026-07-31), confirmed against the paper's methods. The gyrification merge pools
**only the Zilles-method GI** — a **2-D** ratio on coronal sections (inner+buried pial contour ÷ outer
contour) — and deliberately excludes other folding constructs (e.g. Mota & Herculano-Houzel FI).
**Heuer 2019 uses a different method:** a **3-D** absolute gyrification index (the "excess" of the
cortical surface over its volume-normalised convex hull) plus folding length / wavelength / depth —
metrics the Zilles coronal method does not produce. The paper itself presents these as an
*alternative* to the classical Zilles GI. So:

- **Do not reconcile to, or pool with, the Zilles GI merge.** Even Heuer's "gyrification index" is the
  3-D convex-hull variant, not the Zilles coronal-contour GI — not interchangeable.
- **House it here** as its own MRI folding source (exactly as Mota FI lives in its own folder).
- Its **cerebral / convex-hull surface-area** columns belong with cortical-surface data
  (`__merging_cortical_areas`) if ever merged — same rule the GI README applies to Mota — **not** the
  GI merge.

## Build steps

1. Confirm the Zenodo dataset column headers (absolute gyrification index; total folding length;
   average fold wavelength; average fold depth; cerebral surface area; convex-hull surface area).
   Units: surface mm² (×100 if cm²), length mm.
2. `reference_tables/Heuer_etal_2019_definitions.csv` (scaffolded; complete once headers are known).
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = Heuer_etal_2019_<Table>`,
   `Item encoded = 10.1016%2Fj.cortex.2019.04.011_<Table>`, `Data role = secondary`,
   `Main Trait(s) = neocortical folding (MRI)`, `Taxon group = Primates`, `Team = Heuer_MRI`.
4. Wire into a merge **only after** the curator picks option 1 or 2 above — no merge script is edited
   by this scaffold.
