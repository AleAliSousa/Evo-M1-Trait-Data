# Herculano-Houzel, Watson & Paxinos 2013 — Table 1 (mouse cortical neuron distribution)

Herculano-Houzel S, Watson C, Paxinos G (2013). *Distribution of neurons in functional areas of the
mouse cerebral cortex reveals quantitatively different cortical zones.* Front. Neuroanat. 7:35.
doi:10.3389/fnana.2013.00035.

Registry (`__ReadMe.xlsx`): Table 1 is split into two items —
**`HerculanoHouzel_etal_2013_Table1-a`** (`10.3389%2Ffnana.2013.00035_Table1-a`) and
**`HerculanoHouzel_etal_2013_Table1-b`** (`…_Table1-b`).

## ⚠️ Single-species (mouse) reference dataset
Isotropic-fractionator neuron counts in **one species** (*Mus musculus*, n=4 mice). Like Johansen
2024, this is a within-species regional reference — it contributes mouse per-area values (notably
**Motor/M1+M2**, `is_M1=1`) rather than a cross-species row set. Counts are per **one cortical
hemisphere**, corrected for sectioning losses.

## Two parts
- **Table 1-a** — the 18 functional cortical **areas** (Infralimbic … Piriform): `%cortical_area`,
  `%cortical_volume`, `Neurons` (±SEM), `%cortical_neurons`, `N_per_mm2`, `N_per_mm3`, `OtherCells`
  (±SEM), `Thickness_mm`, `Areas_in_atlas` (Franklin & Paxinos 2007). The printed **Total** row
  (83.864 mm² area; 55,591 mm³ volume; 5,048,837 ± 412,123 neurons; 6,640,234 ± 244,643 other cells)
  is kept in the snapshot only, not as a data row.
- **Table 1-b** — the 7 functional **groups** (Motor, Sensory, Visual, Somatosensory, Auditory,
  Insular, Piriform): `%cortical_area`, `%cortical_volume`, `Neurons`, `%cortical_neurons`. These are
  aggregates of the 1-a areas; don't double-count 1-a and 1-b together.

## Source → Snapshot → Data readable  (printed PDF → snapshot required)
Table 1 (PDF) → `…_Table1-a_snapshot.xlsx` / `…_Table1-b_snapshot.xlsx` (values as printed, "mean ±
SEM", commas kept) → `Herculano-Houzel_etal_2013_Table1-a.R` / `-b.R` → the two analysis CSVs +
public TSVs `10.3389%2Ffnana.2013.00035_Table1-a.tsv` / `-b.tsv`. Column meanings:
`reference_tables/…_definitions.csv`.

Units: neuron / other-cell numbers are **absolute counts** (per hemisphere); densities N/mm² and
N/mm³ as printed; thickness in mm; the `%` and density columns are the source's derived values.

## Build note
Generated in an environment without R; outputs produced by the equivalent step and the two `.R`
scripts reproduce them from the frozen snapshots (readxl → CSV + TSV with the `Item encoded` lookup).
The `.R` filenames use the hyphenated author ("Herculano-Houzel_…") but set `item_name` to the
registry spelling ("HerculanoHouzel_…") so the lookup matches.

Pipeline: Source → Snapshot ✅ → Data readable ✅ (a + b) → definitions ✅ → README ✅ · single-species mouse reference (Motor = M1/M2 row).
