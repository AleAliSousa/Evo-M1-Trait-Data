# Changizi 2001 — Figure 3

Changizi MA (2001). *Principles underlying mammalian neocortical scaling.* Biol Cybern 82(3):207–215.
doi:10.1007/s004220000205

Figure 3 title (see `__ReadMe.xlsx`): **log10(number of cortical areas) vs log10(neocortical grey-matter volume)**

## Source → Snapshot
The 12 (x, y) points are given only in the **Fig. 3 caption**, not as a printed table, so they were
transcribed by hand to `Changizi__2001_Figure3_snapshot.csv` (column `Species` holds the **common
name**, then `log brain volume`, `log # areas`). Frozen/archival — all cleaning happens in the `.R`.

## Data readable
`Changizi__2001_Figure3.R` → `Changizi__2001_Figure3.csv` (**use this**). It unlogs the two axes
(`10^log`, truncated — the log-derived digits aren't significant) and adds a binomial **`Species`**
column. Columns are defined in `reference_tables/Changizi__2001_Figure3_definitions.csv`.

## Species note (DONE)
The caption gives **common names only**. Following the repo policy for common-name tables
(`__merging_volumes/SPECIES_STANDARDIZATION_PLAN.md` §3), a binomial **`Species`** column was added
and the printed labels kept in **`common_name`**. Every mapping is recorded, with its basis, in the
reviewable **`common_name_to_species.csv`** (for sign-off):

- **collection_match** to Finlay et al. 2006 Table 6.1 (the sibling dataset, same Kaas/Krubitzer
  mapping literature): hedgehog→*Erinaceus europaeus*, tenrec→*Echinops telfairi* (also stated in
  Changizi's text), opossum→*Didelphis marsupialis*, quoll→*Dasyurus hallucatus*,
  marmoset→*Callithrix jacchus*, cat→*Felis catus*, owl monkey→*Aotus trivirgatus*,
  macaque→*Macaca mulatta* (Finlay's "Rhesus Macaque").
- **research_model / cited source**: star-nosed mole→*Condylura cristata* (Catania & Kaas),
  echidna→*Tachyglossus aculeatus* (Krubitzer et al. 1995 monotreme map), squirrel→*Sciurus
  carolinensis* (Krubitzer 1995, which Changizi cites), human→*Homo sapiens*.

All resolved names except *Tachyglossus aculeatus* are already in `_keys/species_reference.csv`
(this table is not part of any merge, so the reference was not modified).

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
