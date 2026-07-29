# Barger et al. 2012 — Table 3 (amygdala neuron numbers by nucleus)

Barger N, Stefanacci L, Schumann CM, Sherwood CC, Annese J, Allman JM, Buckwalter JA, Hof PR,
Semendeferi K (2012). *Neuronal populations in the basolateral nuclei of the amygdala are
differentially increased in humans compared with apes: A stereological study.* J. Comp. Neurol.
520(13):3035–3054. doi:10.1002/cne.23118.

Registry (`__ReadMe.xlsx`): Item name **`Barger_etal_2012_Table3`**, encoded
`10.1002%2Fcne.23118_Table3`. *(New catalog row added in this pass — the folder was previously
uncatalogued; Item number = "Table 3".)*

## What the data are
Stereological (optical-fractionator) **neuron numbers** for the amygdala and its nuclei across **7
primate species**: whole **amygdala** plus the **lateral**, **basal**, **accessory basal**
(basolateral division) and **central** nuclei. Species-level means with SD; one row per species.
Printed as ×10⁶ in Table 3, stored here as **absolute counts** (cell-count convention). Total sample
35 specimens (`n_specimens` per species from Table 1).

## ⚠️ Two taxonomy caveats (see `taxon_concept`)
- **"Gibbon" is a pooled multi-species mean** (n=3): *Hylobates muelleri* + a white-cheeked gibbon
  (*Nomascus*, printed "Hylobates concolor") + *Hylobates lar* — spanning two genera by modern
  taxonomy. Accepted as **`Hylobatidae sp.`**, `decomposable = FALSE`: do **not** assign this row to
  a single species or pool it into a species mean.
- **"Orangutan" = *Pongo pygmaeus*** (n=4), island/subspecies not stated → flagged
  **`Pongo pygmaeus (s.l.)`** (registry concept). Don't treat as confirmed Bornean *P. p. s.s.*

Other species are unambiguous: Homo sapiens, Pan troglodytes, Pan paniscus, Gorilla gorilla (western
lowland), Macaca fascicularis (long-tailed macaque). Printed labels preserved in
`Species_Barger2012`; harmonised via `_keys/Stephan/species_key.csv` (token `Barger2012`).

## Source → Snapshot → Data readable  (printed PDF → snapshot required)
Table 3 (PDF) → **`Barger_etal_2012_Table3_snapshot.xlsx`** (sheet "Table3"; "mean (SD)" ×10⁶ as
printed) → `Barger_etal_2012_Table3.R` → **`Barger_etal_2012_Table3.csv`** (use this) + the public
TSV `__Public/comparative-data/10.1002%2Fcne.23118_Table3.tsv`. Columns:
`reference_tables/…_definitions.csv`. (Table 1 = specimen list; Table 2 = stereology grid sizes,
methods only, not extracted.)

Units: neuron numbers stored as **absolute counts** (Table 3 ×10⁶ × 1,000,000).

## Build note
Generated in an environment without R; outputs produced by the equivalent step and
`Barger_etal_2012_Table3.R` reproduces them from the frozen snapshot (readxl → CSV + TSV with the
`Item encoded` lookup). Re-run in R to regenerate.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → species note ✅ (pooled-gibbon + orang s.l. flagged) → definitions ✅ → README ✅ · Data role = primary.
