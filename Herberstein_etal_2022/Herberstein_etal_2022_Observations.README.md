# Herberstein_etal_2022_Observations

Source: Herberstein et al. (2022), AnimalTraits — a curated animal trait database for body mass, metabolic rate and brain size. Scientific Data 9, 265. https://doi.org/10.1038/s41597-022-01364-9

## Source and snapshot

The user supplied `observations.xlsx`, downloaded from AnimalTraits (https://animaltraits.org/); the precise download date and release/commit were not supplied. Do not assume this is a separately versioned 2022 release merely from the article year. `Herberstein_etal_2022_Observations_snapshot.xlsx` is a byte-identical copy of that workbook, frozen on 2026-11-13. Each registered sheet has its own unchanged workbook copy, per the item convention. Read sheet `Observations`. The supplied workbook has incorrect worksheet dimension metadata (A1); readxl discovers the data correctly. No transcription or resaving was performed. Human visual check: Not applicable: tabulated and digital already.

## Build and outputs

Run `Rscript Herberstein_etal_2022/Herberstein_etal_2022_Observations.R` from the repository root. This writes `Herberstein_etal_2022_Observations.csv` and the public TSV named by exact Item name lookup in the live `__ReadMe.xlsx`. The registry already contains this item. The separate `Herberstein_etal_2022_Observations_registry_row.xlsx` proposes descriptive metadata for the owner to paste by header name and Item name. The live registry was not edited. Definitions are in `reference_tables/Herberstein_etal_2022_Observations_definitions.csv`.

The full sheet contains 3,580 observations and 43 supplied columns, including 1,020 Mammalia observations. Preserve observation granularity: an observation can describe an individual or a group, and repeated species names are not duplicate records. No averaging or taxonomy replacement is applied. All 43 fields remain, and 11 columns are appended, giving 54 analysis columns. `Source_row` locates the supplied record; `Species_Herberstein2022` preserves its species label explicitly.

## Units and methods

Project columns: `Body_Mass.g` = supplied kg × 1,000; minimum/maximum body mass converted similarly. `Brain_Mass.mg` = supplied kg × 1,000,000. `Metabolic_Rate.W` retains the supplied whole-body watts; `Mass_specific_Metabolic_Rate.W_g` = supplied W/kg ÷ 1,000. Source values, source units, method fields, sex, sample size, and all comments remain available. Empty source fields remain missing.

`Brain_Volume_original.mm3` only converts a volume actually present in `original brain size`; it is missing for mass-source records. ml × 1,000; mm3 unchanged; um3 × 1e-9; x6.4e-5 mm3 × 6.4e-5; x1e6 um3 × 1e-3. A skull-filling volume is an endocranial proxy. This field must not be interpreted as a direct brain-tissue volume irrespective of method.

The paper's Methods, Unit standardisation, explicitly accepts brain mass and volume and converts volume with density **1.036 g/ml**. `Brain_mass_basis` identifies those volume-derived values, and `Brain_mass_density.g_ml` records the assumption. A source already expressed in grams may also derive from endocranial capacity; grams do not prove weighing. Retain `brain size - method`. Among 839 Mammalia brain records, 299 say brain weighed, 274 skull filling, and 266 have no method recorded. Bininda-Emonds (2000) and Stankowich & Romero (2017) include skull-filling records reported in mass units; Ashwell (2008) includes skull filling in ml. These are AnimalTraits method annotations, not independent verification of every primary paper.

The supplied metabolic rates are whole-body power, not cerebral metabolism. AnimalTraits uses 20 J/ml O2; CO2 is converted using the recorded respiratory quotient. Ectotherm rates are adjusted to 25 C using Q10 2.21 (amphibians), 2.44 (reptiles), or 2 (other ectotherms). Original temperature and respiratory quotient remain in the data. Whole-body and mass-specific power may be derived from each other using body mass. Do not describe the supplied W values as unadjusted raw observations.

## Provenance and reuse

This is a **secondary compilation**, including sources that may themselves compile earlier measurements. It is not added as independent primary evidence to the volume or cerebral metabolism merge. Join `inTextReference` to `reference_tables/Herberstein_etal_2022_Observations_references.csv` on `ref_key` (219 cited works). Per-observation full citations are also retained. Source-level and specimen-level overlap must be resolved before pooling with other repo papers.

The original 77 Mammalia CSVs in `animaltraits_raw_Mammalia/` remain untouched. Their 1,549 long measurement records include body mass alongside brain/metabolic records, despite the absence of a separate body-mass directory. Observation IDs restart in each file, and a raw observation can span multiple trait rows. The raw-file path, local observationID, trait and row are needed for tracing; a bare ID is not a global identifier. Original `X.U.FEFF.observationID` header artefacts are preserved in those files.

## Table checks and validation

Executed 2026-11-13: all **1,549/1,549 raw measurements** find a workbook original value and unit for the same citation, genus, epithet and sex after whitespace trimming. This is a coverage/value check, not a one-to-one specimen identity assertion: candidate rows are reported. The raw archive contains 77 files and the workbook's Mammalia records cite 79 works; it is a subset rather than a replacement for the workbook.

Independently recomputed **2,361/2,361 standardized brain masses** from original units, using 1.036 g/ml for volumes: all pass (relative tolerance 1e-9, absolute tolerance 1e-15 kg). Raw-to-workbook checks use relative tolerance 1e-9, absolute tolerance 1e-10 in source units. No source values were changed. The reproducible check and row-level reports live in the restricted companion repo at `restricted_checks/Herberstein_etal_2022/`. There are no printed total relations to assess. Both R item scripts were run in clean Rscript sessions; the item-specific validator checks the expected files and registry names.

## Model for other source builds

Use the two-layer pattern here: keep the source's values, units, method, citation, specimen/group context and any conversion assumptions alongside standardized values. Standardize body mass to g, brain mass to mg, actual source volumes to mm3, and whole-body power to W (W/g for mass-specific power). Distinguish direct brain mass, tissue volume and endocranial proxies by method; preserve unspecified methods. Metabolic type, gas, temperature and respiratory quotient are needed to reproduce energy conversions. Cerebral metabolic rates need their own measure-specific units and cannot be combined directly with these whole-body rates. This item provides the model; applying it to other papers requires their source-specific conversions and provenance audits.
