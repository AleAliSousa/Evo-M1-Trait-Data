# Baron, Stephan & Frahm (1996) — Comparative Neurobiology in Chiroptera  — ON HOLD (scope decision)

> **Status: parked, awaiting a scope decision.** This is the single largest body of
> Stephan-collection volumetric data not in the repo, but it is **bats**, i.e. outside the
> current insectivore/primate scope of `__merging_volumes`. Do not ingest until the
> Class/scope question below is settled (see `../SCOPING_backbone_traits_and_taxonomy.md`).

## Source

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in Chiroptera.*
Basel: Birkhäuser Verlag. Three volumes:

- **Vol. 1 — Macromorphology, Brain Structures, Tables and Atlases.** ISBN 3-7643-5370-8 /
  978-3-7643-5370-4. Holds the quantitative volumetric core: 53 tables of species-level
  brain-structure volumes + megachiropteran and microchiropteran brain atlases.
- **Vol. 2 — Brain Characteristics in Taxonomic Units.** ISBN 3-7643-5371-6 /
  978-3-7643-5371-1. Volume/structure data organised by taxon + literature survey.
- **Vol. 3 — Brain Characteristics in Functional and Ecoethological Units.**
  ISBN 3-7643-5372-4. Interprets the data against ecology/behaviour.

~10,000 measurements on up to 336 bat species — the **bat counterpart to the
Stephan/Frahm/Baron 1981 insectivore/primate dataset**, same measurement suite (fresh
structure volumes + progression indices vs the basal-insectivore baseline). Print
monographs, no DOI — cite by ISBN.

## Why it is parked, not ingested

`__merging_volumes` and `_keys/species_reference.csv` are currently mammal-**and**
insectivore/primate-scoped (no `Class` axis wired into the app yet — this is exactly gap #1
in `../SCOPING_backbone_traits_and_taxonomy.md`). Adding ~336 Chiroptera species is a
scope expansion, not a drop-in. Recommended prerequisites before ingest:

1. Add a `Class` / order axis to `_keys/species_reference.csv` and the app (SCOPING steps 1–3).
2. Decide whether Chiroptera enter the same volumes merge or a sibling merge.
3. Then scaffold per-table folders under this directory following the Stephan/Baron pattern.

## What to add when unparked

- The Vol. 1 tables (PDF scans or transcriptions) → one snapshot per printed table.
- Per-table `.R` + `.csv` + DOI/ISBN-encoded TSV, `reference_tables/*_definitions.csv`,
  `comparison/` QA — same layout as `../Baron_etal_1988/`.
- Registry rows in `../__ReadMe.xlsx` (1st Author `Baron`, year `1996`, Collection
  `Stephan`, Taxon group `Chiroptera`).
