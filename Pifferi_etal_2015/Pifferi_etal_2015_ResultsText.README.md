# Pifferi_etal_2015_ResultsText

**Item name** `Pifferi_etal_2015_ResultsText` · **Item number** `Results Text` · **Item encoded**
`10.1194%2Fjlr.M058933_ResultsText` — *derived, awaiting registration* (not yet in `__ReadMe.xlsx`;
the code is what the registry formula builds from the DOI and `Item number`, following the
`Results Text` → `ResultsText` convention of the existing rows). Until the owner pastes
`Pifferi_etal_2015_ResultsText_registry_row.xlsx` the build writes only the analysis CSV and prints
`not yet registered - TSV skipped`.

Pifferi, F., Dorieux, O., Castellano, C.-A., Croteau, E., Masson, M., Guillermier, M., Van Camp, N.,
Guesnet, P., Alessandri, J.-M., Cunnane, S., Dhenain, M., & Aujard, F. (2015). Long-chain n-3 PUFAs from
fish oil enhance resting state brain glucose utilization and reduce anxiety in an adult nonhuman
primate, the grey mouse lemur. *Journal of Lipid Research*, 56(8), 1511–1518.
<https://doi.org/10.1194/jlr.M058933> (DOI verified on Crossref 2026-11-11.)

**Item full original title:** RESULTS, "Brain glucose uptake and metabolism" (p. 1515): SUVmax and
CMRglu values (control vs. n-3) printed in the text; the same data are plotted in Fig. 3 (SUV time
courses) and Fig. 4 (CMRglu box plots).

## Source

`Pifferi-2015-Long-chain n-3 PUFAs from fish oi.pdf` in this folder, COPIED (not moved) from
`_other_sources_metab_correlates_candidates/`. Born-digital typeset PDF with a clean text layer.
**There is no table**: the values are printed only in two sentences of the Results, so the snapshot is
**constructed** (snapshot HOWTO, *When there is no table*).

## Pipeline

```
Source (PDF p. 1515, right column)
  -> Pifferi_etal_2015_ResultsText_snapshot.R         pdftools::pdf_data text layer -> anchored sentence frames
  -> Pifferi_etal_2015_ResultsText_snapshot.csv   FROZEN, constructed: 16 rows x 11 cols (one per printed clause)
  -> Pifferi_etal_2015_ResultsText.R              split "mean ± SEM", one row per region x diet group
  -> Pifferi_etal_2015_ResultsText.csv            16 rows x 20 cols ("use this")
  -> __Public/comparative-data/10.1194%2Fjlr.M058933_ResultsText.tsv   (after registration only)
  -> reference_tables/Pifferi_etal_2015_ResultsText_definitions.csv
```

## Who read the values, when, and how it was checked

**Extraction from the PDF text layer at run time** (snapshot HOWTO method 3, the `Jacob_etal_2021`
pattern), written by an AI assistant (Claude) on 2026-11-11: the right column of PDF page 5 is rebuilt
from word coordinates, the two sentences are located by anchored printed frames ("Maximal SUVs (SUV ,
in g/ml) were max the following (control vs. n-3): …" and "CMR values glu (µmol/min/100 g) in the
different brain regions were the following ( Fig. 4 ) (control vs. n-3): …" — the subscripts `max`
and `glu` are displaced by the text layer), and each clause `<region>, <control> versus <n-3>` becomes
one snapshot row with its printed lexemes untouched. **No value is typed in any script.** The extract
script refuses to overwrite a differing frozen copy.

All 32 captured lexemes were then read against a 300-dpi render of the page (row by row, region and
group, not just the number) and agree; the staged extraction `s5_cross_species_extracted_values.csv`
(earlier session; control group only) agrees on all 16 control values. Build run with
`Rscript --vanilla` (conda env `evom1-r`, R 4.4.3, pdftools) from a clean session on 2026-11-11.

## What the data are

**16 rows = 8 regions × 2 diet groups**, each a mean ± SEM of **n = 6 male grey mouse lemurs**
(*Microcebus murinus*; 23 ± 4 months old at inclusion, PET in the last month of 12 months'
supplementation; age at PET not stated):

* `group_as_printed` = **`control`** — **the healthy control**: home-made food isoenergetically
  supplemented with **olive oil** (<1% n-3 PUFA, as α-linolenic acid). Flag `is_control = 1`.
* `group_as_printed` = **`n-3`** — the same food supplemented with **tuna oil** rich in n-3 LCPUFA
  (about 6 mg EPA and 30 mg DHA per animal per day, Methods p. 1512) — the treatment arm ("fish oil" in the title).

Regions (VOIs manually segmented on each animal's 7 T MRI) as printed: whole brain, hippocampus,
thalamus, cerebellum (whole-cerebellum VOI), caudate nucleus, temporal lobe, occipital lobe, frontal lobe.

* **CMRglu** — FDG PET (MicroPET Focus 220, 60 min dynamic, 9 µCi/g), Patlak graphical analysis with an
  **image-derived input function from the liver TAC**, **lumped constant 0.344** and CBV 5% taken from
  the literature (refs 29, 30), **µmol/min/100 g**.
* **SUVmax** — maximal SUV, SUV = CPET/(injected dose/body mass), **g/ml**; a semi-quantitative uptake
  index, not a metabolic rate.

**Units: per 100 g of tissue mass** (`µmol/min/100 g` = the merge's µmol/100 g/min; no conversion), not
per 100 cm³. Column names carry the units.

**Dispersion.** Taken as **SEM** from the Methods ("All results are reported as mean ± SEM"); but the
CMRglu sentence cites Fig. 4, whose legend says median (minimum, maximum), and the Methods call the
CMRglu data non-normal (gamma GLM). Recorded as errata E002; read as SEM, the control SDs are 6.9–12.7
µmol/min/100 g (CV 57–84%).

**Anaesthesia.** s.c. atropine 20 min before induction with **isoflurane 5%, maintained at 1–2%**;
24 h fasted; rectal temperature held at 36 °C. Isoflurane depresses CMRglc; with the borrowed lumped
constant and liver-derived input function, absolute values are low (control whole brain 13.9).

**Brain size.** **No brain mass or volume is reported** (body weights were measured but not given).
A species brain mass exists in `__merging_brain_mass/brain_mass_long.csv` (*Microcebus murinus*
1.7735 g, measured, 4 teams) — mentioned only, **not merged**.

**Observation level:** diet-group means, not species means (definitions `Method:observation_level`):
select `is_control == 1` (or pool deliberately) before any species-level use.

Not in this item: the P values printed in the same paragraph (per-region SUV comparisons; CMRglu GLM
treatment effect P = 0.0003), the behavioural and plasma fatty-acid results, and Fig. 4 (not
digitised). The text says the n-3 group's SUVs and CMRglu were "~30%" higher; the printed whole-brain
means differ by 46% (SUVmax 4.20/2.88) and 47% (CMRglu 20.5/13.9) — noted, not an erratum.

## Table checks

The passage prints no totals or arithmetic relations; there is nothing to check (no `table_checks`).
The build asserts the structure instead: 8 regions in identical order in both sentences, every
lexeme of the form `a ± b` except the one recorded as E001.

## Data role

**primary** — the authors' own PET measurements.

## Species names

`species_as_published` = `Microcebus murinus` (Abstract, Introduction; Methods print `M. murinus`),
`common_name_as_published` = `gray mouse lemur` (title: "grey"). **No `_keys/` file was edited.**
Proposed rows in `reference_tables/Pifferi_etal_2015_species_key_proposed.csv` (both → *Microcebus
murinus*, NCBI 30608, verified by esummary 2026-11-11).

## Suitability as a primary input to `__merging_cerebral_metabolic_rate`

Assessed against `__merging_cerebral_metabolic_rate/README__merging.md` ("Primary-item extension"):

* **Suitable as a primary item for provenance, not for the conservative pool.** Rule 1 admits only
  conscious, non-anaesthetised control arms. The `control` (olive oil) group is the eligible *arm*, but
  it was measured under isoflurane, so rule 4 (anaesthetised primaries are provenance only) applies;
  the `n-3` group is a treatment arm and is never eligible.
* Region mapping (rule 2) is one-to-one for all 8 VOIs (`region_canonical_proposed`: Whole_brain,
  Hippocampus, Thalamus, Cerebellum, Caudate_nucleus, Temporal/Occipital/Frontal_cortex via the merge's
  lobe≈cortex harmonisation) — a proposal only, not applied.
* Units are already the merge's per-100 g standard. The dispersion is SEM (convert with √6 for SD).
* Neither compilation cites this paper (no Kaufman or Karbowski row), and *Microcebus murinus* is not yet
  a merge species, so the item would add a new taxon to provenance. Ingestion goes through the
  restricted-repo `primary_item_ingestion_manifest.csv` builder; nothing in the merge folder was edited.

## Audit and validation (2026-11-11, actual R run)

`audit_dataset_item()` on the paper folder: snapshot, csv, readme, definitions all **PASS**, orphan_tsv
**PASS** (no TSV in the folder). `validate_dataset_item()`: csv, readme, definitions, frozen_source and
errata_file_valid **PASS**; **registry_row FAIL** and **tsv FAIL** (expected: the item is not yet in
`__ReadMe.xlsx`, so no public TSV is written); tsv_name_match and no_trailing_underscore **SKIP** (no
`Item encoded` yet). `build_dataset_item()` stops with "not found in registry" for the same reason.
All four will pass once the owner pastes the registry row, runs `_tools/file_list.R` and re-runs the
build script.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside p. 1515, read a few clauses
**across** (region → control value → n-3 value), including mid-sentence ones, and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Pifferi_etal_2015_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Pifferi_etal_2015-E001 | SUVmax_SEM.g_ml | RESULTS 'Brain glucose uptake and metabolism', p. 1515, right column, SUVmax sentence, clause 'caudate nucleus' (snapshot text_row 5), n-3 group | 4.83 versus 0.68 |  | publication_error | 0.68 | proposed | Every other clause of the sentence has the form '<region>, a ± b versus c ± d'; this one prints 'caudate nucleus, 3.48 ± 0.24 versus 4.83 versus 0.68'. Read on a 300-dpi page render and identical in the PDF text layer. The intended lexeme is almost certainly '4.83 ± 0.68' (0.68 is in the range of the other n-3 SEMs, 0.51-1.50). | CSV keeps the printed lexeme in SUVmax_printed and leaves SUVmax_SEM.g_ml NA for that row; the mean 4.83 is kept. |
| Pifferi_etal_2015-E002 | CMRglu_SEM.umol_min_100g | RESULTS p. 1515, CMRglu sentence (all 16 values, snapshot text_rows 9-16) vs Statistical analysis p. 1514 and Fig. 4 legend p. 1516 | ± (dispersion type not stated in the sentence) |  | publication_ambiguity |  | proposed | The sentence prints 'mean ± x' and cites Fig. 4. Methods p. 1514: 'All results are reported as mean ± SEM'; the same section says CMRglu data 'were not normally distributed' and were analysed with a gamma GLM, and the Fig. 4 legend says 'Values are median (minimum, maximum)'. The printed numbers are taken as mean ± SEM (dispersion_type = SEM). A by-eye reading of Fig. 4 (not digitised; approximate) shows a control whole-brain spread of roughly 7 to 23 µmol/min/100 g, which is incompatible with 3.6 being an SD for n = 6 (the minimum SD a range of ~16 allows is about 5.1) and at the edge of what an SEM allows (SEM 3.6 -> SD 8.8; the maximum SD for a range of ~16 is about 8.8). Read as SEM, the control values imply SDs of 6.9-12.7 µmol/min/100 g (CV 57-84%). | Interpretation, not a correction. Use SEM x sqrt(6) for an SD. Large control-group dispersion. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
