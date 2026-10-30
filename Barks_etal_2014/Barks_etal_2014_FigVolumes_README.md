# Barks et al. 2014 — structure volumes digitized from the figures

Barks et al. 2014 (AJPA 156:252–262) reports mean brain-structure volumes only in **bar charts**,
not tables (Table 1 = per-subject brain volume; Table 2 = stereological sampling/CE). These two
files capture those bar values so they can be compared to the DeCasien-compiled `viaDeCasien` data.

## Files
- `Barks_etal_2014_Fig4A.csv` — **Fig 4A**, all subjects.
- `Barks_etal_2014_Fig5A.csv` — **Fig 5A**, adults only.

Each has one row per species (*Gorilla beringei*, *Gorilla gorilla*) with:
- the 26 raw bars in cm³ (`<Region>_<Hemisphere>_cm3`), exactly as plotted; plus
- whole-structure aggregates in mm³ (cm³ × 1000) matching the DeCasien/`viaDeCasien` columns:
  `Cerebellum` = CerebellumHem_L + _R + Vermis; `Neocortex_GMWM` = Σ(Frontal/Temporal/ParOcc GM+WM,
  L+R); `Neocortex_GM` = Σ(those GM only, L+R); `Striatum`/`Hippocampus`/`Amygdala`/`Insula` = L+R;
  `Thalamus` (single/bilateral bar). (Neocortex aggregates exclude Insula and Claustrum, as DeCasien.)

## ⚠ Precision — these are EYE-DIGITIZED estimates
Values were read by eye off the bar charts against the 0–45 cm³ axis (gridlines every 5). Expect
roughly **±1 cm³** on the large bars and proportionally more on the small ones (amygdala/insula
~1 cm³). They are approximations, not measured data. For publication-grade numbers, re-extract with a
plot digitizer (e.g. WebPlotDigitizer) on the high-resolution figure and replace these.

## Validation
Fig 4A aggregates reproduce the DeCasien-compiled `Barks_etal_2014_viaDeCasien` values within
**±1.8%** for every structure (Cerebellum +0.8/−0.8%, Neocortex GM+WM −1.1/−1.8%, Striatum +0.5/−0.2%,
Hippocampus +1.0/−0.7%, Amygdala +0.2/−1.0%, Insula −0.6/+0.3%). This confirms (a) the digitization is
sound and (b) DeCasien's Barks values = Fig 4A (all subjects), summed across hemispheres. Fig 5A
(adults only) is provided as the alternative subject set; it has no `viaDeCasien` counterpart.

## Wired into the merge (2026-06-30)
**Fig 4A is now the merge source for Barks's regional volumes**, replacing `Barks_etal_2014_viaDeCasien`.
Its aggregates were written to `__Public/comparative-data/Barks_etal_2014_Fig4A.tsv` (item
`Barks_etal_2014_Fig4A`, term map `standardized_term_by_reference/Barks_etal_2014_Fig4A_standardized_terms.csv`)
and the `Barks_etal_2014_viaDeCasien` row was swapped to `Barks_etal_2014_Fig4A` in both
`volumes_compiled.R` and `volumes_compiled_DeCasien.R`. The Barks primary (`Barks_etal_2014_TABLE1`)
still supplies whole-brain volume; Fig 4A supplies cerebellum/neocortex(GM+WM, GM)/striatum/
hippocampus/amygdala/insula. `viaDeCasien` files remain on disk (archival, unused). **Fig 5A
(adults only) stays comparison-only.** Because these are eye-digitized, the merge now carries Barks
regional volumes at figure-reading precision (±~1 cm³ large bars) — fine for the DeCasien comparison;
re-digitize for publication-grade values.
