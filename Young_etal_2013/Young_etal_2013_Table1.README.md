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
| *Macaca nemestrina* | 2 | (not measured) | Washington NPRC |
| *Papio cynocephalus anubis* | 1 | 653.8 | Washington NPRC |
| *Papio hamadryas anubis* | 1 | 636.4 | Texas Biomedical |
| *Pan troglodytes* | 1 | 2700 | Texas Biomedical |

## Source → Snapshot → Data readable
`Young_etal_2013_Table1_snapshot.xlsx` (sheet `reformatted`) is the frozen snapshot (already present).
`Young_etal_2013_Table1.R` → `Young_etal_2013_Table1.csv` (**use this**): SD strings (` ± x`) parsed to
numbers, `N/A` → NA, `Saimiri sciuresis` → *sciureus* (typo). Printed names kept in
`species_as_published`. The snapshot's `Specimen` column is an older curator-added field rather than
a printed Table 1 column; it is therefore preserved but ignored. `specimen_source` is reconstructed
from the Materials and Methods: Vanderbilt supplied the galagos and New World monkeys, Washington
NPRC supplied the macaques and *P. cynocephalus* case 09-27, and Texas Biomedical supplied
*P. hamadryas* case 11-31 and the chimpanzee. Columns are defined in
`reference_tables/Young_etal_2013_Table1_definitions.csv`.

## Overlap with Collins et al. 2010 (flagged — do not double-count)
This is the Kaas lab's **M1-specific** companion to Collins 2010 (whole cortex), using the same
flow/isotropic-fractionator program. The overlap is not all-or-none:

- ***Otolemur garnettii*** — **partial overlap**. Young averages three galagos. One has a 1,850 mm²,
  2.87 g cortex, matching Collins case 08-07 (1,849.493 mm², 2.8721 g); the other two are unresolved.
  The three-animal Young mean cannot be decomposed or wholly deduplicated.
- ***Aotus nancymaae*** — **probable same animal as Collins case 07-78**: Young reports 5.21 g and
  about 2,000 mm²; Collins's pieces sum to 5.2155 g and 2,036.45 mm².
- ***Papio cynocephalus anubis*** — **probable case 09-27**, the Collins 2010 baboon. Young's reported
  18,577 mm² surface is the exact Collins value; Young 2013b identifies case 09-27 as the Washington
  NPRC normal baboon.
- ***Papio hamadryas anubis*** — **probable case 11-31**, the Texas Biomedical normal baboon also
  reported in Young 2013b and Turner 2016; it is not in Collins 2010.
- ***Saimiri sciureus*** and ***Macaca nemestrina*** — no known Collins 2010 overlap. Collins's
  macaque was *M. mulatta* case 08-59.

**Merge guidance:** M1 area/mass/density are **regional (M1-only)** — they must **not** be pooled with
whole-cortex surface or whole-cortex cell counts. In `__merging_cortical_areas`, M1 area enters as a
distinct regional sub-trait `M1_Surface_Area.mm2`, never as `CorticalSurface_Area.mm2`.

## Chimpanzee overlap with Collins et al. 2016

The chimpanzee is registered under `KAAS-PAN-11_38` as a **high-confidence probable** match to the
53-year-old female documented by Collins 2016 and the Turner/Miller dissertations. Young and Collins
are the same Kaas/Vanderbilt team, both report a single Texas Biomedical chimpanzee, and both report
27% neurons in M1; the M1 areas (2,700 versus 2,497 mm²) are compatible with different dissection
boundaries. Turner 2016 also consistently refers to the program's singular chimpanzee while naming
multiple baboons. Young prints no age, sex, accession, or case number, so the registry retains
`probable` rather than `matched`; nevertheless, the Young and Collins chimp rows must not be treated
as independent by default.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
