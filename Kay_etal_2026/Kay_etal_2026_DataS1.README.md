# Kay et al. 2026 — Data S1 — endocast, brain, orbit and gray-matter measures (104 euarchontan genera)

Kay, R. F., Organ, C. L., Morse, P. E., Allen, K. L., & Kirk, E. C. (2026). Fossil evidence favors a role for
vision in the modular evolution of the primate neocortex. *Science*, 393(6811), 622–627.
doi:10.1126/science.aee3541

Registry: row exists — Item name **`Kay_etal_2026_DataS1`**, Item encoded **`10.1126%2Fscience.aee3541_DataS1`**
(looked up live by the script). Descriptive columns to update: `Kay_etal_2026_DataS1_registry_row.xlsx`.

## Frozen source (born-digital)
`Kay_etal_2026_DataS1_snapshot.xlsx` is the journal file `science.aee3541_data-s1.xlsx` (from
`science.aee3541_data_s1_to_s5.zip`, folder `science.aee3541_data_s1_to_s5/`), copy-renamed with bytes
untouched (sha256 `4710f8114049d1e47c20f11f1d92c101ff943bef151ba7a86c5d58eececc783b`, identical to the original).
Human visual check: *Not applicable: tabulated and digital already*.

## What the data are
Sheet1: 104 genera (84 living, 20 fossil; Haplorhini 65, Strepsirrhini 32, Plesiadapiformes 3,
Scandentia 3, Dermoptera 1) × 13 measures, all **natural logs** (Notes row). `-` and blank = not available.
Notes row (verbatim): "All measurements are in natural logs. Brain and neocortex volume data from ref. 8;
Orbital data updated and supplemented  from refs 24, 25,  Volume of frontal and non-frontal gray matter
from Bush and Allman (18)".

Data role: **both** — primary: endocast volume and the three endocast surface areas (main text: "we
measured"); secondary: brain and neocortex volume (ref 8 = Stephan, Frahm & Baron 1981), frontal and
non-frontal gray matter (ref 18 = Bush & Allman 2004); both: orbit diameter/area (refs 24, 25 "updated and
supplemented"); unattributed: olfactory bulb volume, optic foramen area, prosthion–inion. Per-column role
is in `measure_role`; keys in `source_keys` bind to `reference_tables/Kay_etal_2026_DataS1_references.csv`.

## Build
`Kay_etal_2026_DataS1.R` → `Kay_etal_2026_DataS1.csv` (long: 1,033 genus × measure rows) + public TSV
`__Public/comparative-data/10.1126%2Fscience.aee3541_DataS1.tsv`. Keeps the printed ln value and adds
`value_project_unit = exp(ln)`. **Units are not printed in Data S1; they are inferred:** volumes mm³ (exp of
Ln BrainVol / Ln Neocortex vol equals Stephan 1981 mm³ values exactly, e.g. *Alouatta* 49009 and 31660),
areas mm² (main text reports optic foramen area in mm²), lengths mm, and the two gray-matter columns
**cm³** (exp equals Bush & Allman 2004 Table 2 cm³, e.g. *Alouatta palliata* 5.54 / 11.62) → × 1000 to mm³.
Species: genus as printed → `<Genus> sp.` via `_keys/General/species_key.csv`
(`source_publication = Kay_etal_2026`); fossil genera carry no NCBI taxid by design.

## Value match to the cited sources (provisional, genus-name matching)
`reference_tables/Kay_etal_2026_DataS1_value_match.csv`: BrainVol and NeocortexVol each equal a Stephan 1981
species value for 29 genera and a two-species genus mean for 3 (incl. *Cercopithecus* = mean of *C. mitis* and
*C. ascanius*; *C. talapoin* appears as *Miopithecus*); 9 genera use names absent from Stephan's tables (not
checked). Gray matter equals Bush & Allman 2004 for 23 of 25 genera. Disagreements: *Nasalis* brain 92000
vs Stephan 92797 mm³; *Mandrillus* frontal 9.9 / non-frontal 20.63 cm³ vs Bush & Allman 19.17 / 52.16 cm³.
These are findings about the publication, not corrections; CSV keeps the published values.

## Data S5 and other supplements
Data S5 (`science.aee3541_data-s5.pdf`, 44 pp.) is the list of morphological characters for the
phylogenetic matrix (Data S2/S4 .nex). It cites character sources by supplementary-materials numbers
(e.g. "Seiffert et al. (2020) (8)", Ross et al. 1998 (26), refs 104–115, 125) but contains no bibliography,
and the SM text PDF is not in this folder. None of these are sources of Data S1 values. Note that S5's "(8)"
(Seiffert 2020) differs from main-text ref 8 (Stephan et al. 1981); the Data S1 "ref. 8" is read with the
main-text list, which the value match confirms. Data S2 and S4 are NEXUS phylogeny files (not trait tables). Data S3 (`science.aee3541_data-s3.xlsx`,
headed "SD 4. List of fossil specimens with virtual endocasts": taxon binomial, catalog number, locality,
age, publications, scan link) names the fossil species behind the Data S1 fossil genus rows; it was not
built in this pass (outside the task) and is the natural join for fossil species identity.

## Table checks
None (no totals).
