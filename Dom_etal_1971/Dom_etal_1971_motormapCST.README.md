# Dom_etal_1971_motormapCST

## Source
Dom, R., Martin, G. F., Fisher, B. L., Fisher, A. M., & Harting, J. K. (1971). The motor cortex
and corticospinal tract of the armadillo (*Dasypus novemcinctus*). *Journal of the Neurological
Sciences*, 14(2), 225–236. https://doi.org/10.1016/0022-510X(71)90092-X

## Why a constructed snapshot
The paper has no tables. The registry item "motor map CST" is the electrical-stimulation motor
map (Fig. 2 and Results pp. 227–228) and the corticospinal-tract degeneration results (p. 230),
plus the cortical histology measurements (pp. 228–230). These are written as 42 trait
statements in `Dom_etal_1971_motormapCST_snapshot.csv`: section, printed page, trait label,
value as printed, unit, and the verbatim passage.

## Reader / provenance
Transcribed 2026-10-28 by an AI assistant from 2× renders of the scanned pages (pp. 225–228,
230, 234–235). The OCR text layer is unreliable ("Woofsey", "t~m", "Das)Tus"; p. 228 is largely
missing), so each passage was read from the page image.

## Pipeline
| file | role |
|---|---|
| `Dom_etal_1971_motormapCST_snapshot.csv` | constructed text snapshot (42 rows) |
| `Dom_etal_1971_motormapCST.R` | snapshot → CSV + public TSV |
| `Dom_etal_1971_motormapCST.csv` | 42 rows: trait, value_printed, value_min/max (project units), qualifier, passage |
| `reference_tables/Dom_etal_1971_motormapCST_references.csv` | Harting & Martin 1970 (one secondary statement) and Fisher et al. 1969 (re-evaluated earlier CST study) |
| `reference_tables/Dom_etal_1971_motormapCST_definitions.csv` | data dictionary |
| `Dom_etal_1971_motormapCST_registry_row.xlsx` | registry row |
| public TSV | `__Public/comparative-data/10.1016%2F0022-510X(71)90092-X_motormapCST.tsv` |

## Key traits (Evo-M1)
CST reaches **rostral thoracic** levels; fibres are very small, thinly myelinated, run in the
dorsal contralateral ventral funiculus and the contralateral lateral funiculus; main termination
in medial **laminae IV–VI** (cervical), minor in medial III / lateral V–VI, a few in VII–VIII at
rostral cervical levels only. The motor map lies caudal to the supraorbital sulcus, with large
lip/tongue/snout representation, hind limb on the medial surface, no supplementary motor area;
thresholds 0.2 mA (face) to 0.5–0.7 mA (caudal extremity).

## Data role
primary (41 rows); one Discussion statement attributed to Harting & Martin (1970) is `secondary`.

## Provenance note for comparisons
Dom et al. re-examined the material of **Fisher et al. (1969)** and conclude that the cortical
areas "were reversed" and that presupraorbital-lesion degeneration was probably silver precipitate.
`Iwaniuk_etal_1999` Table 1 cites Fisher et al. 1969 (ref 18) for the armadillo CST depth/length
scores — a candidate `_keys/source_relationships.csv` row (Dom 1971 re-evaluates Fisher 1969;
not added here, curator decision).

## Units
Body weight kg → g; currents mA; sizes µm; thickness mm. Categorical findings kept as wording.

## Species
*Dasypus novemcinctus* (title), harmonised via `_keys/General/species_key.csv`.

## Table checks
Not applicable (no table).
