# Nguyen et al. 2019 — Table 2

## Source

Nguyen, V. T., et al. (2019). *Comparative neocortical neuromorphology in
felids: African lion (Panthera leo leo), African leopard (Panthera pardus
pardus), and cheetah (Acinonyx jubatus jubatus).* **Journal of Comparative
Neurology**. DOI **10.1002/cne.24823**. Registry item
`Nguyen_etal_2019_Table2`.

Table 2 spans article pages 1400–1401 (PDF pages 9–10). It reports mean ± SEM
for 49 species × cortical-region × neuron-type combinations. Measures are
dendritic volume, total dendritic length, mean segment length, dendritic segment
count, spine count/density, soma area, and soma depth; `n` is neurons traced.

## Pipeline and representation

1. `Nguyen_etal_2019_Table2_extract_snapshot.R` contains the visually checked
   transcription and writes `Nguyen_etal_2019_Table2_snapshot.csv`. Each printed
   `mean ± SEM` cell is split into adjacent mean/SEM fields without changing the
   numbers; dashes remain missing.
2. `Nguyen_etal_2019_Table2.R` retains the printed common and scientific names,
   adds accepted species binomials, maps printed `Motor` → `M1` and `Visual` →
   `V1`, and writes the local CSV plus
   `10.1002%2Fcne.24823_Table2.tsv`.

Micrometre-scale morphology is not converted to mm³: dendritic/soma measures
are a regional cell-morphology lineage, not whole-structure volumes. Neuron type
and cortical region remain explicit and must never be averaged away.

## Checks and cautions

- 49 rows: African lion 13, African leopard 19, cheetah 17;
- DSN and DSD are jointly present for spinous neurons and jointly missing for
  aspiny/neurogliaform rows;
- single-neuron rows retain a mean with missing SEM exactly as printed;
- the paper's footnote that African-lion values—especially DSN/DSD—are
  underestimates is repeated on every lion row;
- future compilation should treat this as region- and method-specific Golgi
  morphology, alongside but not pooled with Jacobs stereology or whole-cortex
  cell counts.
