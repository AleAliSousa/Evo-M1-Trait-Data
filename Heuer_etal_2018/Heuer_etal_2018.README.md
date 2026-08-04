# Heuer et al. 2018 — Primate Brain Anatomy: new volumetric MRI measurements

Source folder for a modern **MRI-derived brain-region volumes** source feeding `__merging_volumes`
(candidate #1 in `SCOUTING_candidate_papers_20260731.md`; **reinstated** 2026-07-31 — the earlier
drop was an attribution error, owner reports no known issue with Heuer).

## Source (freeze before cleaning)

Heuer, K., Gulban, O. F., Bazin, P.-L., Osoianu, A., Valabregue, R., Santin, M., Herbin, M., &
Toro, R. (2018). *Primate Brain Anatomy: New Volumetric MRI Measurements for Neuroanatomical
Studies.* Brain, Behavior and Evolution 91(2):109–128. PMID **29894995**;
DOI **10.1159/000489791** *(verify — search metadata also showed 10.1159/000488136; confirm on the
article page before registering)*. Erratum: Brain Behav Evol 92(3-4):182.

- **What it contributes:** volumetric measurements of **16 brain structures** across **39 primate
  species** (46 brains from the Netherlands Institute of Neuroscience Primate Brain Bank at 9.4 T,
  plus 7 donated MRIs of 4 species), **~20 species new to the volumetric literature** — the largest
  single source of *new primate species* for the volumes merge, and the modern MRI counterpart to the
  histological Stephan/Düsseldorf collection.
- **Frozen source:** the paper's supplementary volume table (digital-native → the download IS the
  frozen copy). Could not be pulled in the scaffolding session (org network policy blocked the
  publisher at the egress proxy; no R runtime). Download locally; keep verbatim; write the DOI-coded
  public TSV `__Public/comparative-data/10.1159%2F000489791_SupplementaryData.tsv` (invariant 2).
  Scans are also on the PRIMatE Data Exchange (PRIME-DE) / a primate-MRI repository.

## Its own MRI team — never pooled with the histological volumes

`__merging_volumes` is **team-aware and citation-dependency-aware**. Heuer is **MRI**; the Stephan/
Baron/Frahm/Matano/Zilles/de Sousa collection is **histology**. Different modality → register Heuer as
its **own team** (`team = "Heuer_MRI"`), so that where a species/structure is measured by both, the
merge **resolves** rather than averaging MRI against histology. Do **not** map Heuer onto a
Stephan-collection team. This mirrors how Ashwell 2020 and the Zilles/de Sousa sub-teams sit beside
the Stephan collection.

## Build steps

1. Confirm the **16 structure column headers** in the SI table. Map each onto the project's canonical
   standardized terms (see the template
   `__merging_volumes/standardized_term_by_reference/Heuer_etal_2018_SupplementaryData_standardized_terms.csv`,
   already scaffolded with the high-confidence rows — whole brain / telencephalon / neocortex /
   cerebellum / diencephalon / mesencephalon / hippocampus / amygdala / striatum — plus TODOs for the
   rest). Project unit = **mm³** (convert if the SI reports cm³ or mL: ×1000).
2. `reference_tables/Heuer_etal_2018_definitions.csv` (scaffolded; complete once headers are known).
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = Heuer_etal_2018_SupplementaryData`,
   `Item encoded = 10.1159%2F000489791_SupplementaryData`, `Data role = secondary` (MRI compilation),
   `Main Trait(s) = brain-region volumes (MRI)`, `Taxon group = Primates`, `Team = Heuer_MRI`.
4. In `__merging_volumes/volumes_compiled.R`: add the item to the `item_name`/team table with
   `"Heuer_etal_2018_SupplementaryData", "Heuer_MRI", 2018`. Re-run `standardized_term.R` then
   `volumes_compiled.R`; check the new primate species appear and that MRI/histology conflicts resolve
   (not average) via the team rule.

## Checks

Cross-check Heuer species against the existing volumes species list (Stephan/Isler/deSousa) so the
overlap is handled by the team rule, and spot-check a few structures for the mm³ unit.
