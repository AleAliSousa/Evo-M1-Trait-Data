# MacLeod et al. 2003 — Table 1 (Yerkes sample)

MacLeod CE, Zilles K, Schleicher A, Rilling JK, Gibson KR (2003). *Expansion of the neocerebellum
in Hominoidea.* J Hum Evol 44(4):401–429. doi:10.1016/S0047-2484(03)00028-9 · PMID 12727461

Full table title (see `__ReadMe.xlsx`): **"Table 1. Volumetric data from the Yerkes sample"**

## Source → Snapshot
PDF p. 409, extracted from the text layer with `pymupdf` and written verbatim to
`MacLeod_etal_2003_Table1_snapshot.csv` (47 specimens). Faithful to print: original headers
(`cm3`), specimen IDs, footnote markers in the Specimen cell, `NA` as printed, row order kept.
*Recommend a visual diff against the PDF before publication (text-layer extraction).*

## Data readable
`MacLeod_etal_2003_Table1.R` → `MacLeod_etal_2003_Table1.csv` (**use this**). Volumes → numeric;
footnotes decoded into columns `stephan_collection` (†), `brainweight_known` (‡), `section_plane`
(*/§). `sample = Yerkes`. Columns defined in `MacLeod_etal_2003_definitions.csv`.

## Provenance
The Yerkes specimens are **not** from the Stephan Collection (separate brains) → merge at the
species-mean level. (The Stephan-Collection specimens are in Table 2.) Primary measurements,
MRI + histological sections. Fills the Heiss-2004 **Vermis** and **Cerebellar cortex** rows.

## Species note (IN PROGRESS)
Binomials as printed; reconcile to `_keys/Stephan/species_key.csv` (e.g. *Cebus apella* → *Sapajus
apella*).

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ⏳ → Online database ☐
