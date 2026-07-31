# Kazu, Maldonado, Mota, Manger & Herculano-Houzel 2014 — Table 1 (Artiodactyla cell counts)

Kazu RS, Maldonado J, Mota B, Manger PR, Herculano-Houzel S (2014). *Cellular scaling
rules for the brain of Artiodactyla include a highly folded cortex with few neurons.*
Front. Neuroanat. 8:128. doi:**10.3389/fnana.2014.00128**

⚠️ **Use the corrigendum.** Kazu et al. (2015), *Corrigendum*, Front. Neuroanat. 9:39,
doi:**10.3389/fnana.2015.00039**, corrects Table 1 values. Extract from the corrected
table, and record in the snapshot that values are the corrigendum's.

## Why it's here (coverage gap)

Isotropic-fractionator neuron / non-neuronal counts for artiodactyls. The HH 2015 *Brain
Behav Evol* compilation carried **only 5** of this paper's artiodactyls forward
(*Antidorcas marsupialis*, *Damaliscus dorcas phillipsi*, *Giraffa camelopardalis*,
*Sus scrofa domesticus*, *Tragelaphus strepsiceros*). The remaining species — confirmed
**absent** from `cellcounts_source_species_ids.csv` — are the gain:

- collared peccary (*Pecari tajacu* / *Tayassu tajacu*)
- gemsbok (*Oryx gazella*)
- blue wildebeest (*Connochaetes taurinus*)
- lesser kudu (*Tragelaphus imberbis*)
- warthog (*Phacochoerus* sp.) — **confirm** against the printed roster

Kazu 2014 is also the **primary source of the giraffe count** — better ingested directly
here than via the HH 2015 re-compilation. Confirm the exact species list (and n per
species) from the corrected Table 1 when the PDF is in place.

## Region scheme — standard (mirrors HH 2015)

Whole-structure: **cerebral cortex / cerebellum / rest of brain** (and whole brain), with
mass (g), neuron number, non-neuronal number, and the densities/ratios. Maps 1:1 onto the
existing merge terms (`CerebralCortex_N.n`, `Cerebellum_N.n`, `RoB_N.n`, `WholeBrain_*`,
`*_Mass.g`, `*_N.p.mg`, `*_O.n`, `*_O.p.N`, …) — no new vocabulary needed. Model the
standardized-terms file on `HerculanoHouzel_etal_2015_Table1..5`.

## Pipeline (to complete once the PDF is added)

Source (PDF, corrigendum Table 1) → snapshot (printed/scanned → `_snapshot` required; see
`__HOWTO_make_a_snapshot.md`) → `Kazu_etal_2014_Table1.R` (extract + clean + units) →
`Kazu_etal_2014_Table1.csv` → public TSV `10.3389%2Ffnana.2014.00128_Table1.tsv` →
`reference_tables/Kazu_etal_2014_Table1_definitions.csv`.

## Needs (blockers)

- [ ] PDF of Kazu 2014 **and** the 2015 corrigendum in this folder.
- [ ] Register `Kazu_etal_2014_Table1` in `__ReadMe.xlsx` Sheet1 (set `Item number` +
      descriptive cols; `Data role = primary`; do **not** hand-edit the formula cols E–M).
- [ ] Add printed species names → accepted binomials in the species key.
- [ ] Fill the extraction in `Kazu_etal_2014_Table1.R` and complete
      `standardized_term_by_reference/Kazu_etal_2014_Table1_standardized_terms.csv`.
- [ ] Uncomment `"Kazu_etal_2014_Table1"` in `cellcounts_compiled.R` `item_name`; re-run
      `standardized_term.R` then `cellcounts_compiled.R`.

Status: **SCAFFOLD** — folder + README + stub `.R` + definitions stub only. Not merged.
