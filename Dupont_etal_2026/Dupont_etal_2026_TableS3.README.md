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
Paper-scoped rows for the 169 resolved species are in `_keys/General/species_key.csv`
(`source_publication = Dupont_etal_2026`). The printed name is kept in `Species`.
The authors' `Species used in phylogenetic tree` column is a tree proxy and is **never** used as identity.

**Resolved offline (6, `synonym:NCBI`):** Leopardus colocolo -> Leopardus colocola; Micoureus demerarae ->
Marmosa demerarae; Spilocuscus maculatus -> Phalanger maculatus (hub name; NCBI name Spilocuscus
maculatus); Eulemur fulvus albifrons -> Eulemur albifrons; Macaca irus -> Macaca fascicularis; Xerus
erythropus -> Euxerus erythropus. Evidence: `_keys/ncbi_taxonomy_snapshot.csv` (2026-10-22) synonym lists.

**36 printed names remain unresolved** (`species_unresolved = TRUE`). No identity was invented and no
taxid assigned. **Status of the lookup ladder:** local keys and the NCBI snapshot were checked; MDD, GBIF and
ITIS were **not reachable from the build container (network policy), which is a service error, not a
no-match**, so nothing was logged to `navigation_taxonomy_search_log.csv`. Next action: allow
`www.mammaldiversity.org`, `api.gbif.org` and `www.itis.gov`, run the MDD -> GBIF -> ITIS ladder on these names
(synonyms/spelling first), then add hub rows or `General` key rows with the evidence. These are not
"not in NCBI" cases. "order/family on file" below comes from `species_taxonomy.csv` and is classification
only, not species identity.

*Unspecified animal labels (`sp.`): keep unspecified; do not substitute the tree proxy:*
- `Manis sp.` (tree proxy: Manis pentadactyla)
- `Pithecia sp.` (tree proxy: Pithecia sp.; order/family on file: Primates/Pitheciidae)
- `Dasyprocta sp.` (tree proxy: Dasyprocta punctata)
- `Echimys sp.` (tree proxy: Echimys chrysurus)
- `Pteromys sp.` (tree proxy: Pteromys volans)
- `Tupaia sp` (tree proxy: Tupaia montana)

*Subspecies / trinomial labels: decide species-level assignment (`subspecies_assign`) from evidence:*
- `Martes melampus tsuensis` (tree proxy: Martes melampus)
- `Galeopterus variegatus peninsulae` (tree proxy: Galeopterus variegatus)
- `Ateles fusciceps robustus` (tree proxy: Ateles fusciceps)
- `Piliocolobus badius temminckii` (tree proxy: Piliocolobus badius)
- `Propithecus coronatus (deckenii)` (tree proxy: Propithecus deckenii)

*Binomials missing from the hub (valid-looking names, or older synonyms/spellings to check):*
- `Paradoxurus philippinensis` (tree proxy: Paradoxurus zeylonensis)
- `Urva auropunctata` (tree proxy: Urva auropunctata; order/family on file: Carnivora/Herpestidae)
- `Dendrolagus inustus` (tree proxy: Dendrolagus inustus; order/family on file: Diprotodontia/Macropodidae)
- `Micoureus regina` (tree proxy: Marmosa regina; order/family on file: Didelphimorphia/Didelphidae)
- `Phataginus tetradactyla` (tree proxy: Phataginus tetradactyla)
- `Smutsia gigantea` (tree proxy: Smutsia temminckii)
- `Aotus felinus` (tree proxy: Aotus nigriceps)
- `Cebus flavus` (tree proxy: Sapajus flavius)
- `Pithecia satana` (tree proxy: Chiropotes satanas)
- `Dendrohyrax arboreus` (tree proxy: Dendrohyrax arboreus; order/family on file: Hyracoidea/Procaviidae)
- `Callosciurus finlaysonii` (tree proxy: Callosciurus finlaysonii; order/family on file: Rodentia/Sciuridae)
- `Callosciurus prevostii` (tree proxy: Callosciurus prevostii; order/family on file: Rodentia/Sciuridae)
- `Dactylomys dactylinus` (tree proxy: Dactylomys dactylinus; order/family on file: Rodentia/Echimyidae)
- `Eliomys melanurus` (tree proxy: Eliomys melanurus; order/family on file: Rodentia/Gliridae)
- `Eliurus myoxinus` (tree proxy: Eliurus myoxinus; order/family on file: Rodentia/Nesomyidae)
- `Funambulus palmarum` (tree proxy: Funambulus palmarum; order/family on file: Rodentia/Sciuridae)
- `Hylopetes alboniger` (tree proxy: Hylopetes alboniger; order/family on file: Rodentia/Sciuridae)
- `Marmota sibirica` (tree proxy: Marmota sibirica; order/family on file: Rodentia/Sciuridae)
- `Petaurista petaurista` (tree proxy: Petaurista petaurista; order/family on file: Rodentia/Sciuridae)
- `Petaurista elegans` (tree proxy: Petaurista elegans sybilla; order/family on file: Rodentia/Sciuridae)
- `Petaurista alborufus` (tree proxy: Petaurista alborufus; order/family on file: Rodentia/Sciuridae)
- `Phloeomys cumingi` (tree proxy: Phloeomys cumingi; order/family on file: Rodentia/Muridae)
- `Ratufa indica` (tree proxy: Ratufa affinis; order/family on file: Rodentia/Sciuridae)
- `Tamiops macclellandii` (tree proxy: Tamiops mcclellandii; order/family on file: Rodentia/Sciuridae)
- `Tupaia gracilis` (tree proxy: Tupaia gracilis; order/family on file: Scandentia/Tupaiidae)

## Not built
- Table S2 (49 fossil/extinct taxa with per-specimen IDs): to be built as its own item once taxa are
  resolved (Paleobiology Database / source papers); excluded from merges until then.
- Table S1 (specimen list), S4–S7 (statistics): not data for this repository.
- `Item full original title` (registry col M) needs the printed Table S3 caption, which is not in the
  supplement; type it from the paper.
