# MacLeod et al. 2003 — Table 2 (Hirnforschung sample)

MacLeod CE, Zilles K, Schleicher A, Rilling JK, Gibson KR (2003). *Expansion of the neocerebellum
in Hominoidea.* J Hum Evol 44(4):401–429. doi:10.1016/S0047-2484(03)00028-9 · PMID 12727461

Full table title (see `__ReadMe.xlsx`): **"Table 2. Volumetric data from the Hirnforschung sample"**

## Source → Snapshot
PDF p. 410, extracted from the text layer with `pymupdf` and written verbatim to
`MacLeod_etal_2003_Table2_snapshot.csv` (50 specimens). Faithful to print: original headers
(`cm3`), specimen IDs, footnote markers in the Specimen cell, `NA` as printed, row order kept.
Published footnote legend: `†` from the Stephan Collection · `‡` brain weight not known ·
`*` horizontal · `§` sagittal (default coronal). *Recommend a visual diff against the PDF.*

## Data readable
`MacLeod_etal_2003_Table2.R` → `MacLeod_etal_2003_Table2.csv` (**use this**). Volumes → numeric;
footnotes decoded into columns `stephan_collection` (†), `brainweight_known` (‡), `section_plane`
(*/§). `sample = Hirnforschung`. Columns defined in `MacLeod_etal_2003_definitions.csv`.

## Provenance
**6 specimens carry the `†` marker = from the Stephan Collection** (1 *Gorilla gorilla*,
4 *Pan troglodytes*, 1 *Hylobates lar*) → these are the **same physical brains** as Stephan/Frahm
and can be merged specimen-to-specimen; the rest merge at species-mean level. Primary measurements,
MRI + histological sections. Fills the Heiss-2004 **Vermis** and **Cerebellar cortex** rows.

## Species note (IN PROGRESS)
Binomials as printed; reconcile to `_keys/Stephan/species_key.csv` (e.g. *Cebus apella* → *Sapajus
apella*; "*Cebus sp.*", "*Cercopithecus sp.*" unresolved).

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ⏳ → Online database ☐
