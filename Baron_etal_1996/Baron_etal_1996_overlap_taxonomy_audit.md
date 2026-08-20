# Baron et al. 1996 overlap and taxonomy audit

**Disposition: HOLD for taxonomy/aggregation completion; do not wire yet.**

Tables 10 and 32 contain 272 source rows and 3536 regional-volume cells across 13 candidate canonical structures.
The 272 rows reduce to 259 printed species-level source concepts; 25 row(s) participate in a within-source collapse and must be averaged before Tier-1 resolution.
The frozen crosswalk leaves 7 source concept(s) (7 row(s)) in `MANUAL_REVIEW`.

## Overlap result

There are **0 eligible species × canonical-structure overlaps** with the current core `volumes_unfiltered.csv` and **0 Baron candidate species already present anywhere in that merge**.
The current Ashwell 2020 bat, *Pteropus giganteus*, is absent from Baron 1996. The previously anticipated Stephan/Baron overlap is therefore not present in the current canonical inputs: Baron is primarily a new Chiroptera block, not a duplicate block.

The machine-readable checks are `Baron_etal_1996_overlap_audit.csv` (species × structure; empty when no overlaps exist) and `Baron_etal_1996_species_overlap_audit.csv` (species-only membership), beside this report. They use only public inputs and therefore remain public.

## Taxa still requiring a curator decision

| source concept | provisional candidate | reason for hold |
|---|---|---|
| `Nyctalus stenopterus` | `Pipistrellus stenopterus` | Provisional Pipistrellus stenopterus; historical placement remains uncertain. |
| `Eptesicus flavescens` | `Nycticeinops grandidieri` | GBIF match carries multiple synonym-homonym interpretations. |
| `Scotomanes sp.` | `Scotomanes sp.` | The source identifies only the genus. |
| `Nyctophilus timoriensis` | `Nyctophilus timoriensis` | Accepted by some backbones, but BatNames reports nomen-dubium/cryptic-species concern. |
| `Tadarida beccarii` | `Tadarida beccarii` | Species is attested, but modern generic placement was not resolved reproducibly. |
| `Tadarida pumila` | `Mops pumilus` | Historical name is interpreted as Mops pumilus or Chaerephon pumilus by different catalogs. |
| `Molossus trinitatis` | `Molossus sinaloae` | Only a fuzzy GBIF route to Molossus sinaloae was found. |

All other NCBI-missed legacy names use the frozen GBIF-backed mappings embedded in the audit script. They are not re-queried during a build.

## Source integrity and required ingestion behavior

Table 32's eight telencephalic components reconstruct Table 10 telencephalon closely (median absolute difference 0.06 mm3). Two printed rows exceed the 1.5 mm3 audit threshold: *Anoura caudifer* (-1.86 mm3) and *Vampyrops brachycephalus* (+23.71 mm3). Preserve the printed component values and flags; do not force a corrected sum.

Before wiring, the Baron reader path must average rows that resolve to the same species within each Baron item. Without that preprocessing, the canonical Tier-1 most-recent rule would select one duplicated source row arbitrarily instead of forming the source's species mean. Genus-only and `MANUAL_REVIEW` rows must remain excluded until resolved.

## Taxonomy evidence consulted (2026-08-15)

- NCBI taxonomy via the local `taxizedb` snapshot for exact names.
- [GBIF Species Match API](https://api.gbif.org/v1/) for the frozen spelling/synonym/genus-transfer candidates.
- [BatNames](https://batnames.org/species/Nyctophilus%2Btimoriensis) for the *Nyctophilus timoriensis* nomen-dubium/cryptic-species warning.
- [Bat Taxonomic Alignment](https://jhpoelen.nl/bat-taxonomic-alignment/) and a [modern phylogenetic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC7236909/) for the historical *Nyctalus stenopterus* → *Pipistrellus stenopterus* interpretation and its uncertainty.
- [WorldFAIR bat-taxonomy case study](https://ris.utwente.nl/ws/portalfiles/portal/456139692/WorldFAIR_D10.1_v2.pdf) for the competing *Tadarida pumila* interpretations.

Regenerate with `Rscript Baron_etal_1996/Baron_etal_1996_overlap_taxonomy_audit.R` after the canonical volume merge changes.
