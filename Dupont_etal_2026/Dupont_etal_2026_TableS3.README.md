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
Paper-scoped rows for the 163 resolved species were added to `_keys/General/species_key.csv`
(`source_publication = Dupont_etal_2026`). The printed name is kept in `Species`.
The authors' `Species used in phylogenetic tree` column is a tree proxy and is **never** used as identity.

**42 printed names did not resolve to a `_keys/species_reference.csv` row** (`species_unresolved = TRUE`).
No identity was invented and no taxid assigned. Per `AGENTS.md` these stay active curation tasks.
Next action for each: look the name up in MDD (then GBIF/ITIS), record synonyms/spelling, and add the
species to the hub or a General key row; they are *not* "not in NCBI" cases.

*Unspecified animal labels (`sp.`) — keep unspecified; do not substitute the tree proxy:*
- `Manis sp.` (tree proxy: Manis pentadactyla)
- `Pithecia sp.` (tree proxy: Pithecia sp.)
- `Dasyprocta sp.` (tree proxy: Dasyprocta punctata)
- `Echimys sp.` (tree proxy: Echimys chrysurus)
- `Pteromys sp.` (tree proxy: Pteromys volans)
- `Tupaia sp` (tree proxy: Tupaia montana)

*Subspecies / trinomial labels — decide species-level assignment (`subspecies_assign`) from evidence:*
- `Martes melampus tsuensis` (tree proxy: Martes melampus)
- `Galeopterus variegatus peninsulae` (tree proxy: Galeopterus variegatus)
- `Ateles fusciceps robustus` (tree proxy: Ateles fusciceps)
- `Eulemur fulvus albifrons` (tree proxy: Eulemur albifrons)
- `Piliocolobus badius temminckii` (tree proxy: Piliocolobus badius)
- `Propithecus coronatus (deckenii)` (tree proxy: Propithecus deckenii)

*Binomials missing from the hub (valid-looking names, or older synonyms to check):*
- `Leopardus colocolo` (tree proxy: Leopardus colocolo)
- `Paradoxurus philippinensis` (tree proxy: Paradoxurus zeylonensis)
- `Urva auropunctata` (tree proxy: Urva auropunctata)
- `Dendrolagus inustus` (tree proxy: Dendrolagus inustus)
- `Micoureus demerarae` (tree proxy: Marmosa demerarae)
- `Micoureus regina` (tree proxy: Marmosa regina)
- `Spilocuscus maculatus` (tree proxy: Spilocuscus maculatus)
- `Phataginus tetradactyla` (tree proxy: Phataginus tetradactyla)
- `Smutsia gigantea` (tree proxy: Smutsia temminckii)
- `Aotus felinus` (tree proxy: Aotus nigriceps)
- `Cebus flavus` (tree proxy: Sapajus flavius)
- `Macaca irus` (tree proxy: Macaca fascicularis)
- `Pithecia satana` (tree proxy: Chiropotes satanas)
- `Dendrohyrax arboreus` (tree proxy: Dendrohyrax arboreus)
- `Callosciurus finlaysonii` (tree proxy: Callosciurus finlaysonii)
- `Callosciurus prevostii` (tree proxy: Callosciurus prevostii)
- `Dactylomys dactylinus` (tree proxy: Dactylomys dactylinus)
- `Eliomys melanurus` (tree proxy: Eliomys melanurus)
- `Eliurus myoxinus` (tree proxy: Eliurus myoxinus)
- `Funambulus palmarum` (tree proxy: Funambulus palmarum)
- `Hylopetes alboniger` (tree proxy: Hylopetes alboniger)
- `Marmota sibirica` (tree proxy: Marmota sibirica)
- `Petaurista petaurista` (tree proxy: Petaurista petaurista)
- `Petaurista elegans` (tree proxy: Petaurista elegans sybilla)
- `Petaurista alborufus` (tree proxy: Petaurista alborufus)
- `Phloeomys cumingi` (tree proxy: Phloeomys cumingi)
- `Ratufa indica` (tree proxy: Ratufa affinis)
- `Tamiops macclellandii` (tree proxy: Tamiops mcclellandii)
- `Xerus erythropus` (tree proxy: Xerus erythropus)
- `Tupaia gracilis` (tree proxy: Tupaia gracilis)

## Not built
- Table S2 (49 fossil/extinct taxa with per-specimen IDs): to be built as its own item once taxa are
  resolved (Paleobiology Database / source papers); excluded from merges until then.
- Table S1 (specimen list), S4–S7 (statistics): not data for this repository.
- `Item full original title` (registry col M) needs the printed Table S3 caption, which is not in the
  supplement; type it from the paper.
