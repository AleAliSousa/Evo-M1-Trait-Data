# Kaskan et al. 2005 — Figure 3 (digitized), visual cortical scaling in nocturnal/diurnal species

Kaskan PM, Franco ECS, Yamada ES, Silveira LCL, Darlington RB, Finlay BL (2005). *Peripheral
variability and central constancy in mammalian visual system evolution.* Proc R Soc Lond B
272:91–100. doi:10.1098/rspb.2004.2925.

## ⚠️ This is digitized (pixel-estimated) data, not a transcribed printed table

Unlike every other item in this registry, **`Kaskan_etal_2005_Figure3.csv` contains
coordinates read off a published scatter plot image, not values printed in the source.** The paper
gives regression *equations* for each group (see below) but never tabulates the individual
species' underlying V1 / total-visual-cortex / total-neocortex area values anywhere in the text or
supplement. Figure 3's own two panels are themselves the only place these per-species values
appear, as plotted points.

**Do not treat this file as equivalent in precision to the registry's other snapshot/analysis CSVs.**
Values here carry an estimated **±0.05–0.1 log₁₀-unit** uncertainty (roughly ±10–25% in
untransformed area), and only **13–16 of each panel's ~20 nocturnal points could be individually
resolved** — the rest overlap too closely at this image resolution to separate, so this dataset
**undercounts** the true 20 nocturnal + 8 diurnal + 2 monotremata = 30 species per panel. Diurnal
(8/8) and monotremata (2/2) counts matched the paper's stated totals exactly in both panels, which
is the main basis for confidence in the method.

## Method

1. Rendered the source PDF page at 400 dpi (`Kaskan-2005-Peripheral variability and central.pdf`,
   page 5, printed page 94).
2. Located each panel's axis lines and tick marks by pixel intensity analysis (Python/PIL/NumPy):
   found the long high-contrast axis lines, then the short tick-mark segments at known label
   positions, giving a precise pixel→data linear calibration for both x (log total neocortex,
   ticks at −0.5 to 4.5) and y (log V1 or log total visual cortex, ticks at −1 to 4) in each panel
   independently.
3. Verified calibration by overlaying a computed reference grid (every 0.1 log-unit, major lines
   at integers) back onto the image and confirming the gridlines fell exactly on the printed tick
   marks and axis labels (see `fig3a_grid.jpg`-style renders used during this process — not
   uploaded, working files only).
4. Visually read each marker's (x, y) position against the calibrated grid, at 3–4× zoom for dense
   regions. Markers were distinguished by shape per the plot's own legend: **filled square =
   nocturnal, open circle = diurnal, + = Monotremata**.
5. For the 4 species explicitly arrow-labelled in panel b (*Aotus trivirgatus*, *Callithrix
   jacchus*, *Galago senegalensis*, *Saimiri sciureus* — all present in `Kaskan_etal_2005_TableS1`'s
   species roster), traced each arrow to its marker directly. Their panel-a (V1) counterparts were
   then located by matching **x-coordinate** (log total neocortex is the same value for a given
   species in both panels — the x-axis is identical), not by re-identifying the point independently;
   the *Saimiri sciureus* panel-a match is flagged `(uncertain match)` because its x-coordinate
   match was the least precise of the four.

## Why Figures 2–3 were not built as printed tables (and what changed)

The registry originally carried placeholder rows `Kaskan_etal_2005_Figure2` and
`Kaskan_etal_2005_Figure3` with no supporting data. On first pass, both figures were judged
unbuildable because they plot **phylogenetically independent contrasts** in places (Figure 2 shows
only regression lines, not points) — this repository's own convention
(`PROJECT_SCOPE_AND_DATASET_ROADMAP.md`) excludes ingesting "secondary slopes, PCA loadings, or
plot points" as a new measurement team. **Figure 3 is different from Figure 2**: its two panels
plot the actual **species-level scatter points** (not just fitted lines), grouped by
nocturnal/diurnal/monotremata, so — at the owner's explicit request — those points were digitized
here as a documented, lower-confidence exception to that general rule. Figure 2 (which truly shows
only contrast-regression lines, no raw points) remains out of scope.

## Regression equations printed alongside the plot (for reference, not re-derived here)

Diurnal V1: y = 1.0485x − 1.0095, r² = 0.959. Nocturnal V1: y = 1.2395x − 1.5015, r² = 0.923.
Monotremata V1: y = 2.1087x − 4.5928. Diurnal total visual: y = 1.1536x − 1.0634, r² = 0.990.
Nocturnal total visual: y = 1.3566x − 1.6325, r² = 0.927. Monotremata total visual:
y = 2.0652x − 4.2837.

## Next step (per owner instruction)

The owner's intent is to eventually cross-reference every digitized point against
`Kaskan_etal_2005_TableS1`'s 30-species roster to assign real species identities to the
`unidentified_NN` placeholders — likely using each species' independently-known neocortex/V1
literature values (from the studies cited in TableS1's reference-letter column) to match against
this file's `log_total_neocortex` values. That matching has **not** been attempted here.


---

## Pipeline (added 2026-10-31: frozen snapshot and build script)

Until now this item had an analysis CSV, a definitions file and this README
but **no frozen source and no build script** - a violation of invariant 1
(all cleaning must be reproducible from a frozen source). Both now exist,
and nothing in `Kaskan_etal_2005_Figure3.csv` was changed to make them fit:
the script reproduces the CSV that was already on disk **byte for byte**,
and it says so, or warns, on every run.

| file | role |
|---|---|
| `Kaskan_etal_2005_Figure3_snapshot.csv` | frozen capture: one row per resolved marker, as captured |
| `Kaskan_etal_2005_Figure3.R` | develops the capture into the analysis CSV + public TSV |
| `Kaskan_etal_2005_Figure3.csv` | analysis rows (46), unchanged |
| `reference_tables/Kaskan_etal_2005_Figure3_definitions.csv` | data dictionary, now carrying the precision caveats |
| `__Public/comparative-data/10.1098%2Frspb.2004.2925_Figure3.tsv` | public copy |

### What the frozen snapshot holds, and how honest it is
The snapshot is the **capture layer**: for each of the 46 resolved markers,
the panel, the panel's printed y-axis label (`log VI` / `log total visual
cortex`), the marker shape as drawn (filled square / open circle / +), the
legend entry that shape stands for as printed (`nocturnal species` /
`diurnal species` / `Monotremata`), the arrow label printed beside the
marker where there is one (`Galago s.`, `Aotus t.`, `Callithrix j.`,
`Saimiri s.` - panel b only), how the point was identified, any annotation
the capture recorded, and the captured x and y as captured.

The build then does the cleaning that the CSV already reflects: panel ->
`y_variable`, legend entry -> `group`, arrow label -> binomial through
`_keys/General/species_key.csv` (four rows added for this item, expanding
the abbreviations against the Electronic Appendix A roster), and sequential
`unidentified_NN` numbering within each panel in capture order. The
coordinates pass through **as captured strings**, so no numeric
re-formatting can perturb them.

**One caveat about the snapshot itself.** The original digitisation's
working files (the pixel coordinates, the calibration, the grid overlays)
were not retained, so this frozen file could not be rebuilt from them. It
reconstructs the capture layer from the published CSV plus a fresh reading
of the figure for the marker shapes, legend wording, arrow labels and
identification basis. It is therefore a faithful record of *what was
captured*, but it is not an independent re-digitisation, and it cannot
corroborate the coordinates. A genuine re-digitisation remains the only way
to do that.

## Table checks

A digitised scatter has no internal arithmetic. Two structural facts can
still be checked, and both bear directly on how far the capture can be
trusted, so the reader runs them into `table_checks`:

1. **Markers resolved vs the totals the paper states** (20 nocturnal,
   8 diurnal, 2 monotremes per panel).
2. **Cross-panel x agreement.** Figure 3a and 3b share their x-axis, so a
   species' `log_total_neocortex` must be the same in both panels, within
   the stated +-0.1 log-unit digitisation uncertainty.

Result of the recorded run (`Rscript --vanilla`, 2026-10-31):
**6 pass, 3 undercount, 1 mismatch.**

- Panel a: nocturnal 13/20 (undercount), diurnal 8/8 (pass),
  monotremata 2/2 (pass).
- Panel b: nocturnal 15/20 (undercount), diurnal **6/8 (undercount)**,
  monotremata 2/2 (pass).
- Cross-panel x: *Galago senegalensis* (0.05), *Aotus trivirgatus* (0.05)
  and *Callithrix jacchus* (0.10) pass; ***Saimiri sciureus* fails at 0.20
  log units** (panel a 3.35, panel b 3.15), twice the tolerance.

Two of these results correct statements made earlier in this README.

- The note above that "Diurnal (8/8) and monotremata (2/2) counts matched
  the paper's stated totals exactly in both panels, which is the main basis
  for confidence in the method" **is not borne out by the file**: panel b
  carries only 6 diurnal points, not 8. The monotremata claim holds, and
  the diurnal claim holds for panel a only. Since that count was "the main
  basis for confidence in the method", the confidence it supported should
  be reduced accordingly.
- The `(uncertain match)` flag on *Saimiri sciureus* in panel a was
  recorded as a subjective judgement. The cross-panel check now makes it
  quantitative and worse than "uncertain": at 0.20 log units apart the two
  panels' points cannot both be the same species under the stated
  precision. Treat the panel-a *Saimiri* identification as **unresolved**,
  not merely uncertain.

Neither finding was repaired in the data: the CSV is unchanged and both are
reported here.

## Data role
`secondary (digitised)` on every row, excluded from every measurement
merge. This item's value is as a roadmap: it shows which species the paper
plotted and roughly where, so the primary per-species areas can be fetched
from the sources compiled in `Kaskan_etal_2005_TableS1` rather than from
these coordinates.
