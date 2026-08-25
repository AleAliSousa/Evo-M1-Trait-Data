# Young et al. 2013 — Table 1 (primary motor cortex, M1)

Young NA, Collins CE, Kaas JH (2013). *Cell and neuron densities in the primary motor cortex of
primates.* Front Neural Circuits 7:30. doi:10.3389/fncir.2013.00030 · Team **Kaas** (Vanderbilt).

Registry (`__ReadMe.xlsx`): Item **`Young_etal_2013_Table1`**, encoded
`10.3389%2Ffncir.2013.00030_Table1`. ⚠️ The epileptic-baboon paper (folder `Young_etal_2013_b`,
PNAS) carries the **same Item name** `Young_etal_2013_Table1` under a different DOI — the build
disambiguates by DOI when writing the TSV.

## What the data are
Per-species **primary motor cortex (M1)** measurements — M1 mass, M1 surface area (mm²), M1 as % of
total cortex, and M1 cell/neuron densities (millions per g and per mm²) with SDs — for **6 primate
species** (7 rows; the two *Papio* labels are NCBI homotypic synonyms):

| Species | n hemispheres | M1 area (mm²) | source institution |
|---|---|---|---|
| *Otolemur garnettii* | 3 | 43.22 | Vanderbilt |
| *Aotus nancymaae* | 1 | 221.83 | Vanderbilt |
| *Saimiri sciureus* | 1 | 125.1 | Vanderbilt |
| *Macaca nemestrina* | 2 | (not measured) | Texas Biomedical |
| *Papio cynocephalus anubis* | 1 | 653.8 | Washington NPRC |
| *Papio hamadryas anubis* | 1 | 636.4 | Washington NPRC |
| *Pan troglodytes* | 1 | 2700 | Texas Biomedical |

## Source → Snapshot → Data readable
`Young_etal_2013_Table1_snapshot.xlsx` (sheet `reformatted`) is the frozen snapshot (already present).
`Young_etal_2013_Table1.R` → `Young_etal_2013_Table1.csv` (**use this**): SD strings (` ± x`) parsed to
numbers, `N/A` → NA, `Saimiri sciuresis` → *sciureus* (typo). Printed names kept in
`species_as_published`. Columns in `reference_tables/Young_etal_2013_Table1_definitions.csv`.

## Overlap with Collins et al. 2010 (flagged — do not double-count)
This is the Kaas lab's **M1-specific** companion to Collins 2010 (whole cortex), same
flow/isotropic-fractionator method. The `specimen_overlap_Collins2010` column records:
- ***Otolemur garnettii*** and ***Aotus nancymaae*** — `likely_same_specimens`: the Vanderbilt animals
  are the same brains as Collins 2010 (whose galagos were 07‑104/08‑07 and owl monkey 07‑78). M1 here
  is a **regional dissection of those same hemispheres**.
- ***Papio*** — `unconfirmed`: Collins's baboon was case 09‑27; Young's M1 baboons are from Washington
  NPRC.
- ***Saimiri sciureus***, ***Macaca nemestrina***, ***Pan troglodytes*** — `no`: not in Collins 2010
  (Collins's macaque was *M. mulatta*).

**Merge guidance:** M1 area/mass/density are **regional (M1-only)** — they must **not** be pooled with
whole-cortex surface or whole-cortex cell counts. In `__merging_cortical_areas`, M1 area enters as a
distinct regional sub-trait `M1_Surface_Area.mm2`, never as `CorticalSurface_Area.mm2`.

## Chimpanzee overlap with Collins et al. 2016

The chimpanzee is registered under `KAAS-PAN-11_38` as a **probable** match to
the 53-year-old female documented by Collins 2016 and the Turner/Miller
dissertations. Young prints no age, sex, or case number, so the registry does
not call this confirmed. It does, however, block treating the two chimp rows as
independent by default.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
