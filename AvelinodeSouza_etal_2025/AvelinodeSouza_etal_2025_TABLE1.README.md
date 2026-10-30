# AvelinodeSouza_etal_2025_TABLE1

**Citation:** Avelino-de-Souza, K., Patzke, N., Karlsson, K. A. E., Manger, P. R., & Herculano-Houzel, S. (2025). Cellular Composition of the Brain of a Northern Minke Whale. *J Comp Neurol*, 533(9), e70089. https://doi.org/10.1002/cne.70089

**Species:** *Balaenoptera acutorostrata* (northern/common minke whale) — the first cetacean added to the compilation.

**Main trait:** neuron number (whole brain and by region).

## Source

Download publication PDF from source (DOI): https://doi.org/10.1002/cne.70089

## Snapshot

Table 1 extracted from the PDF (page 5) with `tabulapdf` (`extract_tables(pdf_file, pages = c(5))`); headers reassembled and broken row-labels merged in the script.

- `AvelinodeSouza_etal_2025_TABLE1.R` — extraction + standardization script
- `AvelinodeSouza_etal_2025_TABLE1_snapshot.csv` — raw snapshot (Structure × Measure, long)

## Data readable

- `AvelinodeSouza_etal_2025_TABLE1.csv`  <-- USE THIS (wide: one row for the species, 72 measure columns + species name)

## Online database / comparative-data

Staged as a DOI-coded TSV in `__Public/comparative-data/`:

- `10.1002%2Fcne.70089_TABLE1.tsv`  <-- ONLINE COPY (read by the merge pipeline)
- Code registered in `__ReadMe.xlsx` (Item name `AvelinodeSouza_etal_2025_TABLE1` → Item encoded `10.1002%2Fcne.70089_TABLE1`).

## Relationship to Herculano-Houzel et al. 2015 — **same scheme**

Suzana Herculano-Houzel is a co-author, and this paper uses the **same isotropic-fractionator method and the same core anatomical definitions** as Herculano-Houzel et al. (2015). It is therefore merged on the **Herculano-Houzel team** (whole brain **excludes** the olfactory bulbs), and its terms map onto the existing standardized columns:

| This paper (Table 1)                              | Standardized term            | Same as HH 2015? |
|---------------------------------------------------|------------------------------|------------------|
| Whole brain                                       | `WholeBrain`                 | yes (excl. olfactory bulb) |
| Cerebral cortex (including Hp + amygdala)          | `CerebralCortex`             | yes (incl. hippocampus, amygdala, piriform) |
| Cerebellum                                         | `Cerebellum`                 | yes |
| Rest of brain (dienceph.+striatum, mesenceph., pons, medulla) | `RoB`            | yes (same scope) |

**Finer subdivisions reported here that HH 2015 did not break out** (added as new tracked columns; they do not affect the shared columns above):

- Cerebral cortex split into grey vs white matter → `CerebralCortexGrey`, `CerebralCortexWhite`
- Rest of brain split into → `DiencephalonStriatum`, `Mesencephalon`, `Pons`, `Medulla`
- `Hippocampus` and `Amygdala` reported separately

**Measures** (per structure): `Mass.g`, `N.n` (neurons), `O.n` (other/non-neuronal cells), `N.p.mg`, `O.p.mg`, `O.p.N` (other-per-neuron) — identical to the HH measure set.

See `AvelinodeSouza_etal_2025_definitions.csv` for full per-term definitions, and `__merging_cellcounts/standardized_term_by_reference/AvelinodeSouza_etal_2025_TABLE1_standardized_terms.csv` for the term→standardized mapping used by the pipeline.
