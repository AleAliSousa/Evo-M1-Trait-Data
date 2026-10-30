# Semendeferi et al. 1998 — Table 4 (Grey-Level Index, area 13)

Semendeferi K, Armstrong E, Schleicher A, Zilles K, Van Hoesen GW (1998). *Limbic Frontal Cortex in
Hominoids: A Comparative Study of Area 13.* Am J Phys Anthropol 106(2):129-155.

Full table title (for `__ReadMe.xlsx`): **"Table 4. Grey-Level Index in area 13"**

## Why this item exists
This item was built during the `__merging_GLI` gap check: the paper's Table 4 GLI values were not
previously extracted into this repo (only the Table 2 volumetric item existed — see
`Semendeferi_etal_1998_TABLE2.ReadMe.md`, which flagged "Neuron/GLI tables (paper Tables 4-5)" as
unbuilt beyond the cell-count table). Re-checking against `__merging_cellcounts` confirmed Table 4
GLI values are not present anywhere in the repo. This item extracts them.

## What GLI is
Grey-level index (GLI): the percent area of a cortical section occupied by cell-body somata versus
neuropil (Schleicher & Zilles, 1989), measured from digitized cortical-depth profiles and averaged
over the entire profile and over three layer groups (supragranular II/III, granular IV,
infragranular V/VI). Same method family as Palomero-Gallagher & Zilles (2018) area 44/45
(`PalomeroGallagher_Zilles_2018`).

## Source -> Snapshot
Extracted from the PDF text layer (`semendeferi_etal_1998.pdf`, Table 4, p. 145). No supplementary
spreadsheet is available for this paper, so the snapshot is a manual transcription:
`Semendeferi_etal_1998_TABLE4_snapshot.csv` preserves the paper's row layout (species-level
cortical mean + SD, followed by three layer-group rows with layer mean + SD), matching the printed
table exactly, including its layer labels ("L II, III", "L IV", "L V, VI").

## Data readable
`Semendeferi_etal_1998_TABLE4.csv`: one row per species, reshaped to match the wide-format
schema used by the `PalomeroGallagher_Zilles_2018_TableS3` GLI item (`Species`,
`species_as_published`, `specimen_as_published`, `area_as_published`, `n_specimens`,
`GLI_pct_mean_all_layers`, `GLI_pct_mean_supragranular`, `GLI_pct_mean_granular`,
`GLI_pct_mean_infragranular`, `source_location`, `data_role`) so the two items can be merged
directly.

## Granularity — species-level, not per-specimen
Unlike Palomero-Gallagher & Zilles (2018) (per-specimen: 2-4 named individuals per species), this
paper quantified **one right hemisphere per species** (footnote 1: "Measurements were taken from
the right hemisphere in each species"), with the reported SD reflecting variation across multiple
measurement locations within that one hemisphere, not across specimens. `n_specimens = 1` for every
row, and `specimen_as_published` is therefore the species common name, not an individual ID.

## Species
Seven hominoids: human, chimpanzee, bonobo, gorilla, orangutan, gibbon, and one Old World monkey
described in the paper's Materials as "the rhesus monkey" (Macaca mulatta) — confirmed in the
Materials and Methods text ("one Old World monkey, the rhesus monkey... two macaque brains").
Binomials follow the same mapping used in `Semendeferi_etal_1998_TABLE2.R`, with `Macaca mulatta`
added for the rhesus/macaque row (the Table 2 volumetric item did not include this species).

## Provenance
Same specimen collections as `Semendeferi_etal_1998_TABLE2` (C. & O. Vogt Institute / Van Hoesen /
Armstrong / Yakovlev collections — see that item's README footnote for full specimen sourcing).

## Data role
`data_role = primary` — paper's own measured GLI data.

## Cross-paper context
This item, together with `Semendeferi_etal_2001_TABLE3_GLI` (area 10), fills part of the GLI gap
identified in `PalomeroGallagher_Zilles_2018`'s README (its Fig. 15 compares area 44/45 GLI against
area 10, 13, V1/V2, and area 4/M1 GLI from other papers). `Sherwood_etal_2004` and
`deSousa_etal_2010` were re-checked in the same pass and confirmed to carry only volumetric
measures (no GLI columns, no GLI table found in their source PDFs) — see
`__merging_GLI/README__merging.md` for the full gap-check record.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note OK -> Online database (pending
registry insertion)

## Update
Renamed from `..._TABLE4_GLI` to `..._TABLE4` to match the registry row the project owner had
already added to `__ReadMe.xlsx` (Item name `Semendeferi_etal_1998_TABLE4`, Item number
`TABLE 4`) -- the Item-encoded lookup now resolves directly and the public TSV has been written
to `__Public/comparative-data/`. Added a minimal `.R` reformat script
(`Semendeferi_etal_1998_TABLE4.R`) reading the frozen snapshot per the standard build convention
(the original build wrote the CSV via a Python merge script only).

NB: `__ReadMe.xlsx` currently has TWO rows sharing Item name `Semendeferi_etal_1998_TABLE4` (rows
with Item number "TABLE 4"): one titled "TABLE 4. Grey-Level Index in area 13" (this item) and one
titled "TABLE 5. Total numbers of neurons and neuronal density (per mm3) in area 13" -- the second
looks like a paste/labelling slip (its title says Table 5 but Item number says TABLE 4). Not
corrected here (registry edits are the owner's); flagging for the owner to fix the Item number on
the neuron-density row.
