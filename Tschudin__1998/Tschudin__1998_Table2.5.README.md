# Tschudin__1998 — Table 2.5 (odontocete neuroanatomical volumes and ratios from MRI)

Tschudin, A. J.-P. C. (1998). *Relative neocortex size and its correlates in
dolphins: Comparisons with humans and implications for mental evolution*
(Doctoral dissertation, University of Natal). CorpusID:142614626.

Registry item: **Table 2.5**, "Odontocete neuroanatomical volumes and ratios
from MRI" — printed pp. 58–59 (PDF pages 68–69 of `Tschudin_Alain_1998.pdf`,
an Adobe Paper Capture OCR scan held in this folder).

## What this covers

Per-specimen total brain, neocortex, posterior fossa (= brainstem +
cerebellum), brainstem, and cerebellum volumes (cm³), plus a neocortex ratio
(neocortex volume ÷ posterior fossa volume), for 44 MRI-scanned odontocete
specimens across 8 species: bottlenose dolphin *Tursiops truncatus* (n=14),
common dolphin *Delphinus delphis* (n=16), Indo-Pacific humpback dolphin
*Sousa chinensis* (n=8, incl. the printed duplicate "HUM 7"), spotted dolphin
*Stenella attenuata* (n=2), striped dolphin *Stenella coeruleoalba* (n=1),
Fraser's dolphin *Lagenodelphis hosei* (n=1), Risso's dolphin *Grampus
griseus* (n=1), and dwarf sperm whale *Kogia simus* (n=1).

## Source → snapshot → CSV

- **Source:** `Tschudin_Alain_1998.pdf` — an Adobe Acrobat "Paper Capture"
  OCR of a scanned/typed dissertation (243 pp.). The OCR text layer is mostly
  usable but not fully reliable for a dense numeric table, so **every value
  was cross-checked against a 200 dpi render of the two source pages** (PDF
  pages 68–69, printed pp. 58–59) before being written to the snapshot. Read
  by: AI assistant (Cowork), 2026-09-26.
- **Species resolution:** subject-code prefixes (BOT, COM, HUM, SPO, STR,
  FRA, RIS, DWA) resolved to binomials via the dissertation's own **Appendix:
  Table of selected abbreviations** (p. 84), not assumed.
- **Snapshot:** `Tschudin__1998_Table2.5_snapshot.csv` — journal-faithful
  layout: title line, header row (as printed, split across two pages in the
  source and combined here into one continuous table), one row per subject
  in printed order, the `-` (not-reported) cells for HUM 2 kept as printed,
  and the footnote (unit + abbreviation key) reproduced at the end.
- **Analysis CSV:** `Tschudin__1998_Table2.5.csv` — one row per specimen (44
  rows): `subject_id`, `species_sci`, `common_name`,
  `total_brain_volume_cm3`, `neocortex_volume_cm3`,
  `posterior_fossa_volume_cm3`, `brainstem_volume_cm3`,
  `cerebellum_volume_cm3`, `neocortex_ratio`, `note`.

## Verification

- **Internal arithmetic check, all 44 rows:** `total_brain_volume` =
  `neocortex_volume` + `posterior_fossa_volume`, and `posterior_fossa_volume`
  = `brainstem_volume` + `cerebellum_volume` (where printed), and
  `neocortex_ratio` = `neocortex_volume` / `posterior_fossa_volume`. Every
  row reconciles exactly or within normal print rounding (≤0.5 cm³), with
  **one exception**: **BOT 9** prints a posterior fossa volume 10.00 cm³
  higher than its own brainstem+cerebellum sum (296.34 vs. 286.34) — this was
  re-verified against the page-image render (not a transcription error) and
  is kept as printed, flagged in the `note` column, not silently corrected.
- **HUM 2** prints `-` for brainstem and cerebellum volume (not reported);
  kept blank in the analysis CSV, not imputed.
- **"HUM 7" is printed twice**, as two distinct rows with different values,
  in the source table — kept verbatim (both rows retained, both labelled
  "HUM 7"), flagged via the `note` column on the second occurrence, not
  renumbered or merged.
- The prose text (p. 57) states that "animals BOT 8, CaM 5 and CaM 9 were
  subsequently identified as outliers and were therefore excluded from
  further analysis" — no "CaM" subject code exists anywhere in this table or
  the paper's own abbreviation key, so this is almost certainly an OCR/print
  rendering of "COM 5" and "COM 9" (which do exist and do appear as
  comparatively extreme values: COM 5 has the highest neocortex ratio in the
  table, 5.91). Recorded as a `Method:observation_level` note in the
  definitions file rather than silently substituted — **Table 2.5 itself is
  the pre-exclusion per-specimen listing**, so all 44 rows (including BOT 8,
  COM 5, COM 9) are retained here; the exclusion applies only to the
  dissertation's own downstream statistical analysis, not to this table.

## Units

cm³ throughout, as printed (footnote "¹cm³"). No unit conversion applied —
kept in the source's native units rather than converted to the project's mm³
volumetric convention, since this dissertation's own text and every internal
cross-check (sums, ratios) are self-consistent in cm³; converting risked
introducing a rounding mismatch against the verification checks above. Flag
for whoever merges this into `__merging_volumes`: multiply by 1000 for mm³.

## Observation level

Per-individual (each row is one MRI-scanned specimen, not a species mean).
