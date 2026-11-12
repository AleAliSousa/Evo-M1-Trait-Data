# Karlsen_etal_2014_Table2

**Item name** `Karlsen_etal_2014_Table2` · **Item number** `Table 2` · **Item encoded** *not yet registered* — paste
`Karlsen_etal_2014_Table2_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, run `_tools/file_list.R`, then re-run the build to
write the public TSV (the build prints `not yet registered - TSV skipped` until then).

Karlsen, A. S., Korbo, S., Uylings, H. B. M., & Pakkenberg, B. (2014). A stereological study of the mediodorsal thalamic nucleus in Down syndrome. *Neuroscience*, 279, 253–259. <https://doi.org/10.1016/j.neuroscience.2014.08.046>

**Item full original title:** Table 2. Estimated quantities of the MDT nucleus (unilateral) (journal p. 256)

## What the data are

Mean, CE and CV, for **Controls (N = 6)** and **DS (N = 4)**, of the mediodorsal thalamic (MDT) nucleus:
volume (mm³), total neurons, large neurons, small neurons, total glia, oligodendrocytes and astrocytes (10⁶).
That is **2 analysis rows** (one per group) × 7 quantities × (mean, CE, CV). All values are **unilateral**.
Ranges are given only in the Results text (controls: volume 325–565 mm³, neurons 4.97–7.30, glia 15.1–43.9,
oligodendrocytes 10.4–25.7, astrocytes 4.71–18.1 ×10⁶). They are not built here, and the text prints the DS
oligodendrocyte range with a typo ("8.52–27.2.4").

## Pipeline

```
Karlsen-2014-A stereological study of the medi.pdf (born-digital)
  -> Karlsen_etal_2014_Table2_snapshot.R -> Karlsen_etal_2014_Table2_snapshot.xlsx
     (FROZEN: 10 rows x 9 cols, sheet "Table2"; blank row = the printed gap between groups)
  -> Karlsen_etal_2014_Table2.R -> Karlsen_etal_2014_Table2.csv (2 rows)
  -> reference_tables/Karlsen_etal_2014_Table2_definitions.csv
```

Units: volume printed in mm³, which is the project unit, so no conversion. Cell numbers stay ×10⁶, with the
unit in the column name (`*.x10e6`).

## Groups (disease paper)

`Group` is kept exactly as printed. **`Controls` is the healthy control group**: six female controls
(5 acute myocardial infarction, 1 congestive heart failure; no neurodegenerative signs), `is_healthy_control = 1`.
`DS` = four females with Down syndrome (The Netherlands Brain Bank). **Overlap:** comparing the printed
individual rows with Karlsen & Pakkenberg 2011 Table 1, 3 controls match exactly (74/160/469/AMI/48:00,
60/161/377/AMI/48:00, 70/169/482/AMI/04:00). A fourth (64/154/AMI/24:00) matches except that K11 leaves the
weight blank. One shares only the hemisphere weight (389 g), and one (75/159/575) is new. Salvesen et al. 2015
also reuses some of these controls. The DS brains are the K11 DS brains, except that K11's 70-year-old US case is
replaced by an 80-year-old NED case.

## Shrinkage and hemispheres

* **Volume: NOT shrinkage-corrected.** "The reported volume estimates were unilateral and were not corrected
  for tissue shrinkage" (Methods p. 256). Shrinkage of the same tissue was estimated in Karlsen & Pakkenberg 2011
  (no group difference; mean 46.7%), but it is not applied here.
* **Unilateral:** every value is for one hemisphere. Multiply by 2 before comparing with the bilateral totals of
  Karlsen & Pakkenberg 2011 or Salvesen et al. 2015. Cell numbers come from the optical fractionator, which is
  independent of shrinkage.
* No densities are printed. N / V would be a derived ratio of group means on a paraffin-volume basis.

## Glial classification vs Karlsen & Pakkenberg 2011

**Partial match.** Same lab, stain and sectioning as Karlsen & Pakkenberg 2011 (`Karlsen_Pakkenberg_2011/`):
Giemsa, 40-µm paraffin sections (measured mean 39 µm). But:

* **Criteria are less explicit and not cited to Pelvig et al. (2008).** Neurons are separated from astrocytes
  and oligodendrocytes by "a diffuse and even chromatin pattern, somal size, size and shape of the nucleus, a
  clearly visible nucleolus, and well-defined surrounding cytoplasm"; the same morphology-and-size approach
  "was also used for the glial cell population" (p. 255). No astrocyte-vs-oligodendrocyte descriptors are given
  (Fig. 2 only illustrates them); K11 gives explicit ones (oligodendrocytes small/round/dense heterochromatin,
  astrocytes paler with granular heterochromatin and sharp nuclear membrane).
* **Microglia are excluded** ("Due to the sparse number of microglia, these numbers were not included", p. 255),
  so `glia_total` = oligodendrocytes + astrocytes (Table 2 sums confirm this), whereas K11 total glia includes
  microglia (13.6% of control neocortical glia in K11). Do not pool `glia_total` with K11 or Salvesen totals
  without adding a microglia term.
* **Different estimator:** optical fractionator (number counted directly; nucleolus = counting item for
  neurons, nucleus for glia), not disector Nv × V as in K11 and Salvesen.
* Neurons are additionally split into large and small by somal size (bimodal distribution).

## Table checks

Neurons, total = large + small, and Glial cells, total = oligodendrocytes + astrocytes, were checked in both
groups (tolerance: half a unit in each of the three cells). **R run 2026-11-11: 4 pass, 0 mismatch.**
Text vs table: the Results text quotes CV 0.13 for control total neurons (table 0.15) and CV 0.47 for DS total
glia (table 0.51). These are errata E006 and E007; the table values are kept.

## Who read the values, when, and how it was checked

Born-digital Elsevier PDF with a clean text layer. **Extracted by `Karlsen_etal_2014_Table2_snapshot.R`**
(AI assistant, Claude, 2026-11-11) with `pdftools::pdf_text`: anchored structural literals, regex captures of
every value, and **no value typed in any script**. Text-layer glyph repairs, each confirmed on the page image:
flattened unit superscripts (`(mm3)` → `(mm³)`, `(106)` → `(10⁶)`) and ligatures expanded. Superscript
footnote asterisks are written `^*`, `^**`, `^***`. The Table 2 footnote formula is garbled in the text layer, so
its words are anchored and the formula itself is typed as printed (a structural literal, not a value). The extract script refuses to
overwrite a frozen snapshot that differs and writes `*_NEW` instead.

Every cell of the frozen snapshot was then **read against 300-dpi renders of the page** (PDF p. 2 Table 1,
p. 4 Table 2; Karlsen & Pakkenberg 2011 Table 1 at p. 2520 for the cross-source errata), reading **across rows**. No disagreement was found.
Cross-check: the earlier staged extraction (`s1a_stereology_extracted_values.csv`, controls only) agrees with
this item for every comparable value and CV. 7 Karlsen values (control volume and six cell numbers, with CVs) were compared and 0 differ; staged rows marked
DERIVED or "not reported" were not compared.

Note: OneDrive rewrites `.xlsx` files on sync (adds `customXml/` and `[trash]/` parts). Cell content is
unchanged; the extract script's guard compares cell content via `readxl` and still reports the frozen copy
as unchanged.

The **human visual check** of the snapshot is still pending (registry column AL).

## Species

Single-species human study. The tables print no species name, so `species_as_published = "human"` (from
Methods) and `Species = "Homo sapiens"`. No species key was edited. A proposed row is in
`reference_tables/Karlsen_etal_2014_species_key_proposed.csv`, for `_keys/General/species_key.csv`.

## Data role

**Proposed: `primary`.** These are the authors' own stereological measurements (registry row file).


<!-- errata:begin -->
## Errata

Generated from `reference_tables/Karlsen_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Karlsen_etal_2014-E006 | neurons_total_CV | Table 2, p. 256, Controls N = 6, CV row, column Neurons, total | 0.15 |  | publication_ambiguity |  | proposed | Results text p. 256 (Neuron number) prints the controls' total as '5.97 x 10^6 (0.13) neurons', i.e. CV 0.13, whereas Table 2 prints 0.15. Both read on the page render (PDF p. 4). All other CVs quoted in the Results agree with Table 2 except E007. | CSV keeps the table value 0.15. |
| Karlsen_etal_2014-E007 | glia_total_CV | Table 2, p. 256, DS N = 4, CV row, column Glial cells, total | 0.51 |  | publication_ambiguity |  | proposed | Results text p. 256 (Glial cell number) prints '24.4 x 10^6 (0.47) glial cells in the DS group', i.e. CV 0.47, whereas Table 2 prints 0.51. Read on the page render (PDF p. 4). | CSV keeps the table value 0.51. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
