# Semendeferi et al. 2001 — Table 3 (Grey-level index, area 10)

Semendeferi K, Armstrong E, Schleicher A, Zilles K, Van Hoesen GW (2001). *Prefrontal Cortex in
Humans and Apes: A Comparative Study of Area 10.* Am J Phys Anthropol 114(3):224-241.

Full table title (for `__ReadMe.xlsx`): **"Table 3. Grey-level index in area 10"**

## Why this item exists
Built during the `__merging_GLI` gap check: the paper's Table 3 GLI values were not previously
extracted into this repo (only the Table 2 volumetric item existed — see
`Semendeferi_etal_2001_TABLE2.ReadMe.md`, which flagged "Neuron/GLI tables" as pointing only to
`__merging_cellcounts`, and `__merging_cellcounts` was confirmed to carry no GLI column). This item
extracts them, as the area-10 counterpart to `Semendeferi_etal_1998_TABLE4_GLI` (area 13).

## What GLI is
Grey-level index (GLI): percent area of a cortical section occupied by cell-body somata versus
neuropil (Schleicher & Zilles, 1989), from digitized cortical-depth profiles, averaged over the
whole profile and over three layer groups (supragranular II/III, granular IV, infragranular V/VI).
Same method family as `PalomeroGallagher_Zilles_2018` (area 44/45) and
`Semendeferi_etal_1998_TABLE4_GLI` (area 13).

## Source -> Snapshot
Extracted from the PDF text layer (`semendeferi_etal_2001.pdf`, Table 3). No supplementary
spreadsheet is available, so `Semendeferi_etal_2001_TABLE3_snapshot.csv` is a manual
transcription preserving the printed layout (cortical mean + SD per species, followed by three
layer-group rows with layer mean + SD).

## Data readable
`Semendeferi_etal_2001_TABLE3.csv`: reshaped to the same wide schema as
`PalomeroGallagher_Zilles_2018_TableS3` and `Semendeferi_etal_1998_TABLE4_GLI` (`Species`,
`species_as_published`, `specimen_as_published`, `area_as_published`, `n_specimens`,
`GLI_pct_mean_all_layers`, `GLI_pct_mean_supragranular`, `GLI_pct_mean_granular`,
`GLI_pct_mean_infragranular`, `source_location`, `data_role`).

## Granularity — species-level, not per-specimen
"One hemisphere (right) per species was quantified" (Materials and Methods); the printed SD
reflects multiple measurement locations within that one hemisphere, not multiple specimens.
`n_specimens = 1` throughout; `specimen_as_published` is the species common name.

## Species
Human, chimpanzee, bonobo, gorilla, orangutan, gibbon, plus "the rhesus monkey" (confirmed in
Materials and Methods: "One Old World monkey, the rhesus monkey, was also included as an outgroup
comparison") — encoded as `Macaca mulatta`.

## Provenance
Same specimen collections as `Semendeferi_etal_2001_TABLE2` (the 2001 paper's README notes brain
volumes are identical to the 1998 area-13 paper — same specimens).

## Data role
`data_role = primary`.

## Cross-paper context
Companion item to `Semendeferi_etal_1998_TABLE4_GLI` (area 13). Together the two partially fill the
GLI gap noted in `PalomeroGallagher_Zilles_2018`'s README. `Sherwood_etal_2004` (area 4/M1) and
`deSousa_etal_2010` (V1/V2) were re-checked and confirmed to have no GLI table anywhere in their
built CSVs or source PDFs — no further GLI extraction was possible from those two papers within
this pass. See `__merging_GLI/README__merging.md` for the full record.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note OK -> Online database (pending
registry insertion)
