# Feinberg et al. 1990 — documented skip, WITH TWO EXCEPTIONS SINCE 2026-10-31

> **2026-10-31 — the folder-wide skip below now has two exceptions.** The owner registered
> `Feinberg_etal_1990_Figure1(a)` and `Feinberg_etal_1990_Figure1(c)`, which supersedes the
> screening decision of 2026-10-28 **for those two items only**. Both are now built (constructed
> snapshot, extract script, R, CSV, public TSV, definitions, item-scoped references, README) with
> **Data role = secondary**, because Fig. 1 replots other people's observations: panel (a) is
> Huttenlocher (1979) synaptic density (N = 12) and panel (c) is Chugani et al. (1987) frontal-cortex
> metabolic rate (N = 29). Both items were checked back against the primary studies as built in this
> repo (`Huttenlocher__1979_Figure3`, `Chugani_etal_1987_Table2`/`_Figure2A`) and the agreement is
> reported in their READMEs.
>
> **The rest of the folder is still skipped.** Tables 1 and 2 remain goodness-of-fit statistics, and
> Fig. 1(b) (synaptic density squared) and Fig. 1(d) (delta amplitude, Feinberg et al. 1977) remain
> unbuilt. Everything below this box is the original 2026-10-28 screening record, unchanged.

---

## Original screening record (28 Oct 2026)

Feinberg, I., Thode, H. C., Jr., Chugani, H. T., & March, J. D. (1990). Gamma distribution model
describes maturational curves for delta wave amplitude, cortical metabolic rate and synaptic density.
*Journal of Theoretical Biology*, 142, 149–161. PDF in this folder: `SynapticDensityDevelopment.pdf`
(13 pp., scanned; OCR text layer unreliable — tables and references were read from page images).

## Screening result (28 Oct 2026, AI assistant)
- **Table 1** (p. 151): order of best polynomial and fraction of explained sum of squares
  (polynomial vs gamma) for delta amplitude, frontal-cortex CMR, synaptic density and synaptic
  density squared.
- **Table 2** (p. 153): N (DA 57, CMR 29, SD² 12) and R² of individual vs combined gamma models,
  with % change in R².
- **Figs 1–2**: scattergrams of the raw data with fitted curves, no printed values.

Both tables are goodness-of-fit statistics for curves fitted to **three earlier human data sets**
(Huttenlocher 1979 synaptic density; Chugani et al. 1987 PET cortical metabolic rate; Feinberg et al.
1977 delta EEG amplitude). They are not trait measurements, and the underlying values are secondary
and only plotted. No item is built and no registry row is proposed.

## What could be built later (owner decision)
The text prints fitted **peak ages** (3.2, 6.1 and 7.4 years for SD, CMR and DA; p. 151 and Fig. 1
legend). If developmental-timing parameters become in scope, they could become a constructed
`Feinberg_etal_1990_text_snapshot.csv` (secondary, derived from the three cited data sets).

## Citation roadmap
`reference_tables/Feinberg_etal_1990_references.csv` — the three primary data sets, citations
transcribed from the page image of the bibliography (p. 160), with the N each contributed.
