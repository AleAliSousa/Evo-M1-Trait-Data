# Salvesen_etal_2015_text

**Item name** `Salvesen_etal_2015_text` · **Item number** `text` · **Item encoded** *not yet registered* — paste
`Salvesen_etal_2015_text_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, run `_tools/file_list.R`, then re-run the build to
write the public TSV (the build prints `not yet registered - TSV skipped` until then).

Salvesen, L., Ullerup, B. H., Sunay, F. B., Brudek, T., Løkkegaard, A., Agander, T. K., Winge, K., & Pakkenberg, B. (2015). Changes in total cell numbers of the basal ganglia in patients with multiple system atrophy — a stereological study. *Neurobiology of Disease*, 74, 104–113. <https://doi.org/10.1016/j.nbd.2014.11.008>

**Item full original title:** Results text, p. 110: overall mean volumes (range) of putamen, caudate nucleus, globus pallidus, subthalamic nucleus and red nucleus in control and MSA brains (paraffin-embedded tissue)

## What the data are

The regional **volumes are printed only in the Results text** (p. 110), not in a table. This is a
**constructed snapshot** (`Salvesen_etal_2015_text_snapshot.csv`): one row per region × group (**10 rows**),
each carrying the verbatim source sentence, the comparison sentence that follows it, and its p-value. The
sentences come from the text layer in two-column reading order, located by the anchored phrase
"The overall mean volume(s) of the …"; all five appear on p. 110. Volumes are converted to **mm³**
(cm³ × 1000). **SN volume is not reported** anywhere in the paper.

| region | Controls | MSA | p |
|---|---|---|---|
| putamen | 4.9 cm³ (3.8–5.8) | 4.0 cm³ (2.1–6.2) | 0.19 |
| caudate nucleus | 3.3 cm³ (2.3–4.2) | 3.1 cm³ (1.9–4.1) | 0.41 |
| globus pallidus | 1.9 cm³ (1.2–2.6) | 1.6 cm³ (0.9–2.4) | 0.09 |
| subthalamic nucleus | 114.4 mm³ (84.7–192.6) | 128.8 mm³ (102.5–177.4) | 0.09 |
| red nucleus | 193.2 mm³ (128.8–275.8) | 222.2 mm³ (143.3–308.5) | 0.16 |

## Pipeline

```
PDF p. 7 -> Salvesen_etal_2015_text_snapshot.R -> Salvesen_etal_2015_text_snapshot.csv (FROZEN, constructed)
  -> Salvesen_etal_2015_text.R (also reads the Table 1 and Table 4 snapshots for n and area codes)
  -> Salvesen_etal_2015_text.csv (10 rows) -> reference_tables/Salvesen_etal_2015_text_definitions.csv
```

The `volume_sentence_as_printed` column of the snapshot is the text layer verbatim, including its superscript
artefacts ("cm 3"); the parsed fields carry the printed superscript (cm³).

## Groups (disease paper)

`Group` is kept exactly as printed. **`Controls` is the healthy control group**: neurologically healthy
subjects (10 died of acute myocardial infarction, 1 of an aortic aneurysm), `is_healthy_control = 1`.
`MSA` = multiple system atrophy (8 parkinsonian, 3 cerebellar subtype). The paper states that several control
brains were also used in Karlsen et al. 2014 and Karlsen & Pakkenberg 2011, so these are **not independent**
of those items' controls.

## Shrinkage and hemispheres

* **Volumes: NOT shrinkage-corrected.** The Cavalieri reference volume is "uncorrected for shrinkage"
  (Methods p. 105). The Results give the volumes as paraffin-embedded tissue. Contrast Karlsen & Pakkenberg 2011,
  whose published *volumes* are shrinkage-corrected (mean 46.7%) while its densities use the paraffin volume.
* **Densities (Nv)** are per mm³ of paraffin-embedded (shrunken) tissue. **Totals (N)** = Nv × uncorrected V,
  which makes them shrinkage-independent.
* **Bilateral:** one hemisphere counted, multiplied by 2 (Methods p. 105; Results "estimated bilateral quantities").

Hemisphere basis of the volumes is **inferred**: the text does not say bilateral, but Table 4 bilateral N / Nv
reproduces the control volumes within 1–2% for PU, CN, GP and STN, and within 9% for RN.

## Table checks

None: the text prints no arithmetic relation among these values. One unit slip in the comparison sentence
(the putamen difference printed as "0.9 mm3" for 0.9 cm³) is errata E003. The volumes themselves are
unaffected.

## Who read the values, when, and how it was checked

Born-digital Elsevier PDF with a clean text layer. **Extracted by `Salvesen_etal_2015_text_snapshot.R`**
(AI assistant, Claude, 2026-11-11) with `pdftools::pdf_text`: anchored structural literals, regex captures of
every value, and **no value typed in any script**. Text-layer glyph repairs, each confirmed on the page image:
flattened exponents (`× 106` → `× 10⁶`, `× 103` → `× 10³`), `b0.001` → `<0.001`, `mm3` → `mm³` in the section
heading, and ligatures expanded. Superscript footnote letters are written `^a`. The extract script refuses to
overwrite a frozen snapshot that differs and writes `*_NEW` instead.

Every cell of the frozen snapshot was then **read against 300-dpi renders of the page** (PDF p. 2 Table 1;
p. 5 Table 4, in two zoomed halves; p. 7 Results text), reading **across rows**. No disagreement was found.
Cross-check: the earlier staged extraction (`s1a_stereology_extracted_values.csv`, controls only) agrees with
this item for every comparable value and CV. 47 Salvesen values were compared and 0 differ; staged rows marked
DERIVED or "not reported" were not compared.

Note: OneDrive rewrites `.xlsx` files on sync (adds `customXml/` and `[trash]/` parts). Cell content is
unchanged; the extract script's guard compares cell content via `readxl` and still reports the frozen copy
as unchanged.

The **human visual check** of the snapshot is still pending (registry column AL).

## Species

Single-species human study. The tables print no species name, so `species_as_published = "human"` (from
Methods) and `Species = "Homo sapiens"`. No species key was edited. A proposed row is in
`reference_tables/Salvesen_etal_2015_species_key_proposed.csv`, for `_keys/General/species_key.csv`.

## Data role

**Proposed: `primary`.** These are the authors' own stereological measurements (registry row file).


<!-- errata:begin -->
## Errata

Generated from `reference_tables/Salvesen_etal_2015_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Salvesen_etal_2015-E003 | comparison_text_as_printed | Results, Putamen, p. 110 left column: 'The mean putaminal volume in the MSA brains was 0.9 mm3 (~17.5%) lower ...' | 0.9 mm3 |  | publication_error | 0.9 cm3 | proposed | The preceding sentence prints control 4.9 cm3 and MSA 4.0 cm3; 4.9 - 4.0 = 0.9 cm3 (= 900 mm3). 0.9 mm3 would be a 0.02% difference, not ~17.5%. Read on the page render (PDF p. 7). | Only the comparison sentence is affected; volume_mean.mm3 values come from the volume sentence and are unaffected. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
