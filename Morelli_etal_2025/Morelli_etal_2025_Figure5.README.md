# Morelli et al. 2025 — Figure 5 — white matter volume and sleep time (9 labelled mammals)

Morelli, A. M., Saada, A., & Scholkmann, F. (2025). Myelin: A possible proton capacitor for energy storage
during sleep and energy supply during wakefulness. *Progress in Biophysics and Molecular Biology*, 196,
91–101. doi:10.1016/j.pbiomolbio.2025.03.001

Registry: row exists — Item name **`Morelli_etal_2025_Figure5`**, Item encoded
**`10.1016%2Fj.pbiomolbio.2025.03.001_Figure5`** (looked up live by the script). Descriptive columns to
update: `Morelli_etal_2025_Figure5_registry_row.xlsx`.

## What the data are
Fig. 5 (printed p. 97) plots ln(sleep time, % of 24 h) against ln(white matter volume, mm³) for 23
mammals (text: r = 0.5562, p < 0.01; figure annotation prints r = 0.5561). Nine animals are labelled and
carry printed text annotations "WMV: ~n mm³ / ST: n%": Bat, Mouse, Rat, Pig, Hedgehog (left panel),
Human, Dolphin, Elephant, Horse (right panel). **Only these nine annotations are data here.** The 14
unlabelled points were not digitised: no species identity is printed for them.
Data role: **secondary** — the legend credits sleep times to Eric H. Chudler's tabulated values (after
Aserinsky 1999; Campbell & Tobler 1984; Gravett et al. 2017; Kryger et al. 1989; Siegel 2022; Tobler 1989;
mouse lemur from Hozer et al. 2019) and WMV to Zhang & Sejnowski (2000) and Mota et al. (2019), with no
per-animal attribution.

## Source → Snapshot → Data
- Constructed snapshot `Morelli_etal_2025_Figure5_snapshot.csv`: one row per printed annotation, in panel
  order top-to-bottom, label and annotation strings verbatim (`~`, `mm³`, `%` kept). **Reader:** AI
  assistant, 28 Oct 2026, from a 400-dpi render of the figure (the labels are part of the embedded raster,
  so the PDF text layer does not contain them). Human visual check pending.
- Build `Morelli_etal_2025_Figure5.R` → `Morelli_etal_2025_Figure5.csv` (9 rows) + public TSV
  `__Public/comparative-data/10.1016%2Fj.pbiomolbio.2025.03.001_Figure5.tsv`. WMV already in mm³ (project
  unit); `~` kept as `WhiteMatter_Vol_approximate`; sleep hours derived (`SleepTime.h_derived` = % × 24/100).
- Species via `_keys/General/species_key.csv` (`source_publication = Morelli_etal_2025`): Human → *Homo
  sapiens*, Horse → *Equus caballus*, Pig → *Sus scrofa domesticus*; Mouse → *Mus* sp., Rat → *Rattus* sp.,
  Hedgehog/Dolphin/Elephant → species unspecified; Bat → *Noctilio leporinus* by WMV value match
  (Zhang & Sejnowski 2000 Fig. 2 caption prints W = 43 mm³ for *N. leporinus*). The bat's ST (82.9% = 19.9 h)
  may come from a different bat in Chudler's table — the Bat row may combine two species.

## Secondary sources
`reference_tables/Morelli_etal_2025_Figure5_references.csv` — ref_key as printed in the legend, bibliography
entries verbatim. Bind with `WMV_source_keys` / `ST_source_keys` (split on `"; "`, join on `ref_key`).
Cited-but-absent: Chudler (no bibliography entry). The legend misspells Zhang as "Thang" (kept in note).
Provisional value checks: Mouse 13, Rat 59, Bat 43 mm³ equal Zhang & Sejnowski 2000 (repo
`Zhang_Sejnowski_2000`); Horse 2.9 h and Human 8 h equal Siegel 2022 (repo `Siegel__2022`); no labelled
WMV equals Mota et al. 2019 S1.

## Table checks
None (no totals).
