# Herculano-Houzel cell-count coverage gaps — scaffold

Result of a coverage audit (2026-07) of the Herculano-Houzel isotropic-fractionator
corpus against `__merging_cellcounts/`. The backbone (HH et al. 2015 *Brain Behav Evol*
compilation, `10.1159/000437413`, Tables 1–5) plus the post-2015 additions already in the
merge — bats (HH et al. 2020), Carnivora (Jardim-Messeder et al. 2017), mole-rats
(Kverková et al. 2018), minke whale (Avelino-de-Souza et al. 2025), marsupials + microglia
(Dos Santos et al. 2017/2020), primate spinal cords (Burish et al. 2010) — cover the
**whole-structure** scheme (cortex / cerebellum / rest-of-brain) across 87 species well.

Five HH-corpus papers add coverage the merge does not yet have. This file tracks the
scaffold for each; the per-paper folders hold the README + stub `.R` + `definitions`
stub. **Nothing here is wired live yet** — each paper is blocked on the "needs" listed
below, and its entry in `cellcounts_compiled.R` `item_name` is commented out.

## The two axes of gap

- **Finer regions** (species already in the merge, resolution the merge lacks): Gabi 2016
  (prefrontal), Ribeiro 2013 (human cortical zones), HH 2013 (mouse 18 cortical areas).
- **New species**: Kazu 2014 (extra artiodactyls), Olkowicz 2016 (28 birds — gated).

## Papers

| # | Paper | DOI | Adds | Region scheme | Status |
|---|---|---|---|---|---|
| 1 | Kazu et al. 2014 (Artiodactyla) | `10.3389/fnana.2014.00128` (+ corrigendum `10.3389/fnana.2015.00039`) | ~4–5 new artiodactyl species (peccary, gemsbok, blue wildebeest, lesser kudu, warthog — confirmed absent) + the giraffe primary | **Standard** (cortex/cerebellum/RoB) — mirrors HH 2015 | Needs PDF + registry + species-key rows |
| 2 | Gabi et al. 2016 (prefrontal) | `10.1073/pnas.1610178113` | Prefrontal / rest-of-cortex neuron & other-cell counts (grey+white) for human + primates | **NEW regional** — see design note | Needs PDF + region-scheme decision |
| 3 | Ribeiro et al. 2013 (human cortical zones) | `10.3389/fnana.2013.00028` | Human cortical grey/white neuronal-distribution zones | **NEW regional**, within-species | Needs PDF + region-scheme decision |
| 4 | HH, Watson & Paxinos 2013 (mouse, 18 areas) | `10.3389/fnana.2013.00035` | Mouse per-cortical-area neuron/other-cell counts + densities | **NEW regional**, within-species | **Data already built** in `HerculanoHouzel_etal_2013/` — needs only wiring + region-scheme decision |
| 5 | Olkowicz et al. 2016 (birds) | `10.1073/pnas.1517131113` | 28 avian species (forebrain/cerebellum/rest/tectum); HH is co-author | Bird-specific | **BLOCKED**: non-mammal — the taxonomy resolver is MDD/mammal-only (see `SCOUTING_AND_SCOPING.md` (Part 2), gap #1 / do-first step 4). Do NOT add to the mammal merge until the resolver is de-MDD'd |

## Design note — regional cortical cell counts (papers 2, 3, 4)

The merge's standardized terms are **whole-structure** (`CerebralCortex_N.n`,
`Cerebellum_N.n`, `RoB_N.n`, …). Papers 2–4 report cell counts for **sub-regions of the
cortex** — prefrontal vs rest (Gabi), grey/white zones (Ribeiro), 18 functional areas
(HH 2013). The long format (`Species × Variable × Value × Source`) absorbs new variables
additively, so this is not a schema change — but a **naming decision** is needed before
they go live, and it should be made once for all three:

- **Recommended:** treat regional cortical counts as **separate, never-pooled variables**,
  exactly as `__merging_cortical_areas/` already treats regional surface area
  (`M1_Surface_Area.mm2` is kept apart from whole-cortex `CorticalSurface_Area.mm2`). Use
  a `<Subregion>_<Measure>` term, e.g. `PrefrontalCortex_N.n`, `PrefrontalCortexGrey_N.n`,
  `RestOfCortex_N.n` (Gabi); an area prefix per mouse area (HH 2013). These must **not**
  collide with or be averaged into the whole-cortex `CerebralCortex_N.n` a species already
  has from HH 2015.
- **Alternative:** a dedicated `__merging_cortical_cellcounts/` sub-merge, if the curator
  prefers to keep whole-structure and regional cell counts in physically separate tables.

Until this is decided, the proposed standardized-term stubs for papers 2–4 carry the
recommended vocabulary with `Original_Term` marked `TODO:` (fill from the extracted table).

## Per-paper "needs" checklist

1. **Kazu 2014** — (a) PDF into `Kazu_etal_2014/` (use the **2015 corrigendum** values for
   Table 1); (b) register Table 1 in `__ReadMe.xlsx` Sheet1 (set `Item number`, descriptive
   cols; the Item name/encoded formulas fill in); (c) add the printed species names to the
   species key; (d) fill `Kazu_etal_2014_Table1.R` extraction + the standardized-terms stub;
   (e) uncomment in `item_name`; re-run `standardized_term.R` → `cellcounts_compiled.R`.
2. **Gabi 2016** — PDF + region-scheme decision, then same steps.
3. **Ribeiro 2013** — PDF + region-scheme decision; note this is within-human and
   per-sampling-site — decide row granularity (per-zone) before ingest.
4. **HH 2013 mouse** — no new PDF/extraction needed (built). Only: region-scheme decision,
   standardized-terms file, `item_name` uncomment, re-run. Registry entries for
   `HerculanoHouzel_etal_2013_Table1-a/-b` already exist (used to write the public TSVs).
5. **Olkowicz 2016** — do the resolver work in `SCOPING_...md` first; scaffold folder is a
   placeholder only.

## Not gaps (for the record)

- **Bats** are already covered (HH et al. 2020, `10.1002/cne.24985`).
- **Elephant** is covered via HH 2015 at cortex/cerebellum/RoB resolution; the standalone
  "Elephant brain in numbers" (2014, `10.3389/fnana.2014.00046`) adds no species or standard
  region.
- The pre-2015 primary papers (2006/2007/2010/2011/2014) are **aggregated by HH 2015** and
  would be superseded by the newest-wins dedup — no new whole-structure data.
- Reviews (2009, 2011, 2012), the 2005 method paper, and the 2023 theropod paper (estimates,
  not fractionator counts) are correctly out of scope.
