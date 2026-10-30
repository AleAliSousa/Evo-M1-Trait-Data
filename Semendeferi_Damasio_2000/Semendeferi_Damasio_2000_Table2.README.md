# Semendeferi & Damasio 2000 — Table 2 (hominoid brain & subdivision volumes)

Semendeferi K, Damasio H (2000). *The brain and its main anatomical subdivisions in living hominoids
using magnetic resonance imaging.* J. Hum. Evol. 38(2):317–332. doi:10.1006/jhev.1999.0381.

Registry (`__ReadMe.xlsx`): Item name **`Semendeferi_Damasio_2000_Table2`**, encoded
`10.1006%2Fjhev.1999.0381_Table2`. *(Set Item number = "Table 2" on the publication row so the code
resolves — done in this pass.)*

## What the data are
Primary comparative MRI volumetrics for **29 individual hominoids** — 10 human, 3 bonobo, 6
chimpanzee, 2 gorilla, 4 orang-utan, 4 gibbon — each with **whole brain, cerebellum, cerebral
hemispheres (both sides), frontal, temporal, insula, parieto-occipital, and core** volumes. One row
per individual (`Specimen`). Tables 3–4 of the paper are relative percentages (derived) and are
**not** transcribed (house rule §7); only the absolute volumes (Table 2) are built.

## Taxonomy (printed names preserved)
Printed taxon kept in `Species_Semendeferi2000`; accepted binomial in `Species`, harmonised via
`_keys/Stephan/species_key.csv` (token `Semendeferi2000`). Two careful calls:
- **Orang-utan → `Pongo pygmaeus`, flagged `taxon_concept = "Pongo pygmaeus (s.l.)"`.** These are
  pre-2001 animals of unknown island origin; the concept (Bornean + Sumatran, `decomposable=FALSE`)
  already exists in `_keys/specimen_crosswalk/taxon_concept_registry.csv`. Do **not** silently treat
  these as modern Bornean *P. pygmaeus s.s.* These are individuals (not a pooled mean), so a single
  animal *could* be reassigned via `specimen_crosswalk.resolved_taxon` if identifiers ever surface;
  the paper gives none (just "Orang-utan 1–4"), so resolution stays open.
- **Gibbon → `Hylobates sp.`** — the paper does not state the gibbon species, so it is left at genus
  with `sp.` rather than guessed.

## Source → Snapshot → Data readable  (printed PDF → snapshot required)
Table 2 (PDF) → **`Semendeferi_Damasio_2000_Table2_snapshot.xlsx`** (sheet "Table2"; values in cm³
with the source's "·" decimal rendered as ".") → `Semendeferi_Damasio_2000_Table2.R` →
**`Semendeferi_Damasio_2000_Table2.csv`** (use this) + the public TSV
`__Public/comparative-data/10.1006%2Fjhev.1999.0381_Table2.tsv`. Columns:
`reference_tables/…_definitions.csv`.

Units: volumes converted **cm³ → mm³** (×1000); cm³ originals remain in the frozen snapshot.
Granularity: **per-individual** — aggregate to species means at the merge, not here.

## Merge notes
Primary volumetric data (Data role = primary). A Stephan/Düsseldorf-lineage comparison against
existing hominoid volumes could be added under `comparison/`. Because the orang-utans are `(s.l.)`,
any species mean built from them must carry the concept flag and not be pooled with confirmed
*P. pygmaeus s.s.* or *P. abelii* values.

## Build note
Generated in an environment without R; outputs were produced by the equivalent step and
`Semendeferi_Damasio_2000_Table2.R` reproduces them from the frozen snapshot (readxl → CSV + TSV with
the `Item encoded` lookup and the `species_key` harmonisation). Re-run in R to regenerate.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → species note ✅ (taxon_concept flagged) → definitions ✅ → README ✅ · comparison ⬜.
