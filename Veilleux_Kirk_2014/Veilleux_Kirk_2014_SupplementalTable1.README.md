# Veilleux & Kirk (2014) — Supplemental Table 1

**Source paper.** Veilleux, C. C., & Kirk, E. C. (2014). Visual acuity in mammals: Effects of eye size and ecology. *Brain, Behavior and Evolution*, 83(1), 43–53. https://doi.org/10.1159/000357830

**Table.** Supplemental Table 1: *"Visual and Ecological Comparative Mammalian Dataset"* — 91 species × eye axial diameter (AD, mm), visual acuity (VA, cpd), body mass (BM, kg), measurement type (A/B), maximum running speed (kph), activity pattern (D/C/N), diet (H/P), with per-column sources resolving to a 122-entry reference list. Second Route-A sensory source folder, and **the build that lifts the VA quarantine** on the compiled sensory check fixture for VK-sourced values.

## Files in this folder

| file | what it is |
| --- | --- |
| `000357830_sm_Table.pdf` | the supplementary PDF (frozen source, publisher filename as in the registry Source URL cell; a byte-identical archive copy `Veilleaux_Kirk_2014_supptable.pdf` and a redundant Excel conversion `000357830_sm_Table.xlsx` were removed in the 2026-08-31 streamline) |
| `Veilleaux-2014-Visual Acuity in Mam.pdf` | the main paper |
| `…_SupplementalTable1_extract.py` | reproducible snapshot builder: positional (x-coordinate) extraction from the PDF text layer |
| `…_SupplementalTable1_snapshot.csv` | frozen snapshot as printed (91 rows; group rows in `Order`, sources verbatim incl. `this study:` prefixes, `**` and superscript-2 markers) |
| `…_SupplementalTable1.R` | canonical reformat: snapshot → CSV + public TSV |
| `…_SupplementalTable1_mirror.py` | offline Python mirror of the `.R` — regenerated in the 2026-08-31 streamline (the original was removed before any R run could verify it) and confirmed byte-identical to the committed CSV + TSV; delete after an RStudio run of the `.R` verifies the same |
| `…_SupplementalTable1.csv` | analysis-ready data ("use this") |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |
| `reference_tables/…_data_sources.csv` | the paper's numbered Data Sources 1–122, verbatim |
| `reference_tables/…_species_crosswalk.csv` | 9 printed misspellings/older names → corrected binomials |
| `comparison/…_vs_Part1_sheet.csv` | audit vs the Bath student extraction |
| `comparison/…_VA_offset_adjudication.csv` | the check fixture's VK-citing VA rows resolved against this primary |

Public TSV: `__Public/comparative-data/10.1159%2F000357830_SupplementalTable1.tsv` (registry row pre-existed; Item number "Supplemental Table 1").

## Extraction & snapshot

The supplementary PDF is **born-digital** with a reliable text layer, but rows differ in which cells are empty, so plain text extraction misplaces columns — the extractor bins words by x-coordinate into the printed columns (bins in `…_extract.py`). Verified against rendered page images and, in full, against the student extraction. Kept verbatim in the snapshot: group heading rows (`Primates- Haplorhines*`), `this study:` source prefixes, the `**` marker (AD estimated from retinal magnification factor) and the flattened superscript `2` (haplorhine acuity from peak **cone** density rather than ganglion-cell density).

## Cleaning applied (in `.R`)

Values → numeric; markers split into flags (`ad_estimated_from_RMF`, `va_cone_density_footnote2`, `va_this_study`); BM kg → `Body_mass.g` (project unit; printed kg kept). Printed species names survive verbatim as `Species_VK2014` — including **9 printed misspellings/older names** (*Myotis dabentonii*, *Sarcrophilus harrisii*, *Agouti paca*, *Sciurus caroliniensis*, *Macropus fulginosus*, *Setonyx brachyurus*, *Dasyprocta leoporina*, *Rhinolophus rouxi*, *Mustela putorius furo*) mapped to corrected binomials in the species crosswalk. The Bath sheets and the compilation used the corrected names silently; the crosswalk makes the correction explicit.

## Comparisons

- **vs the Bath Part-1 student sheet** (91 VK-sourced rows): **179 value/method comparisons agree; 3 mismatches, all student rounding** (0.167→0.17 ×2, 0.625→0.63); 0 species set differences after the spelling crosswalk. The student sheet's `PRIMARY SOURCE 1/2` columns correspond to the paper's bracketed sources.
- **VA-offset adjudication** (`…_VA_offset_adjudication.csv`): all **92** VA values in the check fixture citing "Veilleaux and Kirk 2014" are now resolved against the primary: **74 CONFIRMED correct** and **18 CONFIRMED displaced** (each displaced value's true owner species named; the pattern matches `sensory_VA_offset_audit.csv` — e.g. *Aonyx cinerea* 59.61 is *Alouatta caraya*'s value). No unexplained rows. Remaining quarantined VA rows cite Kirk & Kay 2004 (next build) or Heffner & Heffner 1992a (the *Macaca fuscata* 46.8 row is HH1992a's generic "macaque" acuity — rhesus-based sources — assigned to Japanese macaque by the compilation; treat as misassigned).

## Primary vs secondary (Data role: both — as already set in the registry)

`va_this_study = TRUE` rows (and the paper's own AD-based calculations) are **primary**; bracket-sourced VA/AD/BM/ecology values are **secondary**, compiled from the 122 data sources (kept per-cell in `src_*`). Only this-study values are candidates for a future sensory merge as VK2014 data; literature-sourced values would be merged from their own primaries.

## Notes for the database

- Ecology columns (MRS, AP, diet) cover only the paper's ecological-comparison subset; haplorhines deliberately excluded (`*`).
- `Tursiops truncatus` is absent here — dolphin VA in the compilation comes from other sources.
- Species-name standardisation to the repo backbone deferred; `species_key.csv` token: `VeilleuxKirk2014`.

## Streamline log (2026-08-31)

Two builds of this item were made the same day (duplicate effort); the folder now carries only the second, more rigorous chain (extract.py → snapshot.csv → .R → CSV/TSV, with crosswalk + comparisons). Removed: the first build's `…_snapshot.xlsx`, the byte-identical duplicate supplement PDF (`Veilleaux_Kirk_2014_supptable.pdf`), and a redundant Excel conversion (`000357830_sm_Table.xlsx`). Added `options(scipen = 999)` to the `.R` (house standard; the committed outputs previously printed `4e+05`/`1e+06` for two Body_mass.g cells — now plain notation) and regenerated CSV + TSV via the rebuilt mirror (byte-identical check passes). Numeric values are unchanged.
