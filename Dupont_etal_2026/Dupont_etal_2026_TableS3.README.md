# Dupont et al. 2026 — Supplementary Table S3 (phalangeal indices of arboreal mammals)

Dupont E, Klein F, Métais G, Toussaint SLD (2026). *Morphometric and ecological correlates of
phalangeal elongation in extant arboreal mammals and implication for inferring arboreality in
fossils.* Proceedings of the Royal Society B 293(2083): 20262257. doi:10.1098/rspb.2026.2257

Source file: journal supplementary workbook `rspb20262257_si_001.xlsx` (Royal Society figshare
collection). **Table S3** = 205 extant species with four phalangeal indices (PI), body mass,
% time arboreal and the source of each.

## What was built
- **Snapshot:** `Dupont_etal_2026_TableS3_snapshot.xlsx` is the untouched download, copy-renamed
  (digital-native source; all sheets kept, only sheet `Table S3` is read).
- **Reformat:** `Dupont_etal_2026_TableS3.R` -> `Dupont_etal_2026_TableS3.csv` (205 rows) and the
  public TSV `10.1098%2Frspb.2026.2257_TableS3.tsv`.
- **Conversions:** `BodymassKg` x 1000 -> `Body_Mass.g`; `TimeArbo%` `~25` -> `Time_Arboreal_pct` 25
  (printed string kept); text `NA` -> blank.
- **Check:** every PI value and body mass in the CSV was compared with the snapshot: 0 mismatches.

## Data role
- **Primary:** the four PI columns and `Time_Arboreal_pct` (new traits; the time-arboreal value is an
  approximate category compiled from literature/Animal Diversity Web, not a measurement).
- **Secondary:** `Body_Mass.g` (authors' compilation, mostly Animal Diversity Web) — not merged.

## Species identity (read before using)
Paper-scoped rows for all 205 printed names are in `_keys/General/species_key.csv`
(`source_publication = Dupont_etal_2026`); the printed name stays in `Species`. Evidence for each of the
42 names that were not in the species hub is in `reference_tables/Dupont_etal_2026_taxon_resolution.csv`
(MDD v2.5, release 2026-07-28, checked 2026-11-19; GBIF cross-check for the fuzzy matches; NCBI snapshot
2026-10-22 for six names). The authors' `Species used in phylogenetic tree` column is a tree proxy and is
never used as identity. No NCBI taxid was assigned to the new rows.

- **Accepted in MDD, kept verbatim (19):** e.g. Paradoxurus philippinensis, Urva auropunctata, Smutsia
  gigantea, Petaurista spp., Ratufa indica.
- **Synonym / spelling (12):** six from the NCBI snapshot (Macaca irus -> Macaca fascicularis, Xerus
  erythropus -> Euxerus erythropus, ...) and six from MDD (Phataginus tetradactyla, Tamiops macclellandii,
  Cebus flavus -> Sapajus flavius, Pithecia satana -> Chiropotes satanas, Micoureus regina -> Marmosa
  isthmica, Aotus felinus -> Aotus trivirgatus).
- **Subspecies assigned to species (5, `subspecies_assign`):** Martes melampus tsuensis, Galeopterus variegatus
  peninsulae, Ateles fusciceps robustus, Piliocolobus badius temminckii, and `Propithecus coronatus (deckenii)` ->
  Propithecus deckenii (project convention; MDD v2.5 keeps the two as separate species, so review). The subspecies is not kept in the
  species value; keep `Species` if a subspecies analysis is needed.
- **Genus-only labels (6, `unspecified_in_source`):** Manis sp., Pithecia sp., Dasyprocta sp., Echimys sp.,
  Pteromys sp., Tupaia sp. They are not assigned to the authors' proxy species.

**Review these:** the three MDD synonym assignments that differ from the authors' tree proxy
(Micoureus regina, Aotus felinus) or that change the species a reader would expect (Cebus flavus,
Pithecia satana). Several new accepted names are not yet rows in `_keys/species_reference.csv`; the hub
backfill and NCBI sync are separate steps.

## Not built
- Table S2 (49 fossil/extinct taxa with per-specimen IDs) is a separate item, `Dupont_etal_2026_TableS2`. It is
  skipped by the body_ecology body-mass pool and enters only the specimen-level fossil table of
  `__merging_postcranial`.
- Table S1 (specimen list), S4–S7 (statistics): not data for this repository.
- `Item full original title` (registry col M) needs the printed Table S3 caption, which is not in the
  supplement; type it from the paper.
