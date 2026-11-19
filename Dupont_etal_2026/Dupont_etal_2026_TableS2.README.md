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
Evidence for every name is in `reference_tables/Dupont_etal_2026_taxon_resolution.csv` (GBIF backbone match
type, status and key, checked 2026-11-19; MDD does not cover most fossils). 41 printed names were not in the
extant species hub; 33 now have paper-scoped rows in `_keys/General/species_key.csv`: exact accepted GBIF
species (verbatim), three orthographic variants (`spelling`) and two `sp` labels (`unspecified_in_source`).
No NCBI taxid was assigned.

**8 names remain unresolved** (`species_unresolved = TRUE`). Next action: check each in the Paleobiology
Database (`paleobiodb.org` is not reachable from the build container) and the source papers cited in `Origin`.
- `Paroodectes feisti`: species absent from GBIF backbone (genus only, doubtful); PBDB (paleobiodb.org) not reachable from build container
- `Kopidodon macrognathus`: species absent from GBIF backbone (genus only, doubtful); PBDB (paleobiodb.org) not reachable from build container
- `Tetraclaenodon puercensis`: GBIF lists as synonym of Phenacodus puercensis Cope, 1881; fossil synonymy not confirmed, printed name retained as unresolved until PBDB/source check; PBDB (paleobiodb.org) not reachable from build container
- `Ectoconus majusculus`: GBIF lists as synonym of Periptychus ditrigonus (Cope, 1882); fossil synonymy not confirmed, printed name retained as unresolved until PBDB/source check; PBDB (paleobiodb.org) not reachable from build container
- `Apatemys chardini`: GBIF lists as synonym of Teilhardella chardini (Jepsen, 1930); fossil synonymy not confirmed, printed name retained as unresolved until PBDB/source check; PBDB (paleobiodb.org) not reachable from build container
- `Messelogale kessleri`: species absent from GBIF backbone (genus only, doubtful); PBDB (paleobiodb.org) not reachable from build container
- `Nannodectes intermedius`: GBIF lists as synonym of Pronothodectes intermedius (Gazin, 1971); fossil synonymy not confirmed, printed name retained as unresolved until PBDB/source check; PBDB (paleobiodb.org) not reachable from build container
- `Godinotia neglecta`: GBIF lists as synonym of Pronycticebus neglectus (Thalmann et al., 1989); fossil synonymy not confirmed, printed name retained as unresolved until PBDB/source check; PBDB (paleobiodb.org) not reachable from build container

## Not built / for the owner
- Registry row: paste `Dupont_etal_2026_TableS2_registry_row.xlsx` (same procedure as Table S3) and type the
  printed Table S2 caption into `Item full original title`, which is not in the supplement.
