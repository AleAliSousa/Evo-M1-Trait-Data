# Dupont et al. 2026 — Supplementary Table S2 (fossil phalangeal indices)

Dupont E, Klein F, Métais G, Toussaint SLD (2026). *Morphometric and ecological correlates of
phalangeal elongation in extant arboreal mammals and implication for inferring arboreality in
fossils.* Proceedings of the Royal Society B 293(2083): 20262257. doi:10.1098/rspb.2026.2257

Source file: journal supplementary workbook `rspb20262257_si_001.xlsx`. **Table S2** = 49 fossil and
extinct taxa, one specimen each, with four phalangeal indices (PI), a cited body-mass estimate and the
authors' model-inferred % time arboreal (point estimate with lower/upper bound) for each PI.

## What was built
- **Snapshot:** `Dupont_etal_2026_TableS2_snapshot.xlsx`, an untouched copy of the journal download
  (its own copy, not shared with Table S3; only sheet `Table S2` is read).
- **Reformat:** `Dupont_etal_2026_TableS2.R` -> `Dupont_etal_2026_TableS2.csv` (49 rows) and public TSV
  `10.1098%2Frspb.2026.2257_TableS2.tsv`.
- **Conversions:** `BodymassKg` x 1000 -> `Body_Mass.g` (one value `>0,03` is parsed with a decimal comma and
  its bound kept in `Body_Mass_bound`); text `NA` -> blank.
- **Check:** all PI and time-arboreal values were compared with the snapshot: 0 mismatches.

## Data role and use
- **Primary:** the four PI columns (specimen-level measurements on fossils).
- **Secondary:** `Body_Mass.g` (literature estimate) and the `TimeArbo_*` columns (the authors' model output).
- **Specimen-level, fossil.** Do not pool with extant species values; keep out of merges until each taxon is
  confirmed. Some rows are casts or literature-sourced (see `Origin`).

## Species identity
Evidence for every name is in `reference_tables/Dupont_etal_2026_taxon_resolution.csv` (GBIF backbone match type,
status and key, then the Paleobiology Database for names where GBIF differed or had no species, checked 2026-11-19;
MDD does not cover most fossils). 41 printed names were not in the extant species hub and all now have paper-scoped
rows in `_keys/General/species_key.csv`:
- exact accepted GBIF species, kept as printed (`verbatim`), and three orthographic variants (`spelling`);
- PBDB accepted species kept as printed where GBIF lists a different treatment (Nannodectes intermedius, Apatemys
  chardini, Tetraclaenodon puercensis);
- two PBDB synonyms (`synonym:PBDB`): Ectoconus majusculus -> Ectoconus ditrigonus (GBIF agrees on the species but
  places it in Periptychus) and Godinotia neglecta -> Pronycticebus neglectus;
- two `sp` labels (`unspecified_in_source`);
- three Messel taxa with no species record in GBIF or PBDB (Kopidodon macrognathus, Messelogale kessleri,
  Paroodectes feisti), kept as printed with `our_judgment`. **Lower confidence: confirm in the Messel literature.**
No NCBI taxid was assigned. `species_unresolved` is FALSE for all 49 rows.

## Not built / for the owner
- Registry row: paste `Dupont_etal_2026_TableS2_registry_row.xlsx` (same procedure as Table S3) and type the
  printed Table S2 caption into `Item full original title`, which is not in the supplement.
