# Lewitus et al. 2014 — External Database S1, reference list

Lewitus E, Kelava I, Kalinka AT, Tomancak P, Huttner WB (2014). *An adaptive threshold in
mammalian neocortical evolution.* PLoS Biology 12(11):e1002000. doi:10.1371/journal.pbio.1002000

The numbered reference list (88 entries) printed at the end of **External Database S1**
(`pbio.1002000.s021.doc`), the supplement that gives per-species sources for Table S1. The
document's intro paragraph names refs **1–15**, AnAge and PanTHERIA (ref **16**) as dataset-wide
sources; every other number is cited per species in the table above the list (rolled up in
`Lewitus_etal_2014_ExternalDatabaseS1variablesources`).

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `pbio.1002000.s021.doc` | **Raw** journal supplement (Word 97–2003, 24 pp.; citations are EndNote fields). Kept for provenance; not read by the script. |
| `Lewitus_etal_2014_ExternalDatabaseS1references_snapshot.xlsx` | **Snapshot** (sheet `References`). |
| `Lewitus_etal_2014_ExternalDatabaseS1references.R` | Preparation → `Lewitus_etal_2014_ExternalDatabaseS1references.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `../__Public/comparative-data/10.1371%2Fjournal.pbio.1002000_ExternalDatabaseS1references.tsv` | Public TSV, named from `__ReadMe.xlsx` (Item name → Item encoded). |

## Why a snapshot (not digital-native)

Tables S1 and S8 are read straight from the journal's own `.xlsx` files. This supplement is a Word
document: the reference numbers are EndNote field results and the list is running text, which R
cannot read. The snapshot freezes the document's text layer verbatim (field results kept, field
codes dropped), so the build is reproducible in R without converting the `.doc`.

## Snapshot layout

Row 1 the document title (`External Database S1`); row 2 the printed intro paragraph; row 3 column
labels `No.` / `Reference` (added — the printed list has no header); then one row per reference: the
number as printed (`1.`) and the citation exactly as printed, EndNote artefacts included.

## Preparation → `Lewitus_etal_2014_ExternalDatabaseS1references.csv`

One row per reference (88): `ref_number`, `citation`. Only EndNote export artefacts are removed —
` (Translated from eng)` wherever it occurs and ` (in eng).` at the end of a citation — and runs of
spaces are squeezed (refs 55 and 79 carry four). Authors, titles, typos and punctuation stay as
printed (e.g. ref 21 `Ganzhorn JrU`, ref 31 `(On-line).).`, ref 35
`Food & Mammals AOotUNWPoM (1981)`). The script stops if the numbers are not 1…n in order.

## Checking

Rebuilt from the snapshot on 2026-09-28, the 88 citations are identical, character for character,
to the earlier `textutil` extraction of the same document.

## Names

Registered in `__ReadMe.xlsx` as Item number `External Database S1 _references` → Item name
`Lewitus_etal_2014_ExternalDatabaseS1references`; the registry formula drops spaces and underscores.
On 2026-09-28 the files were renamed from `Lewitus_etal_2014_ExternalDatabaseS1_references.*` (and
the CSV moved up from `reference_tables/`) so that snapshot, script, CSV and TSV share the Item name
the script looks up.

## Related checks (restricted repo)

`Evo-M1-Trait-Data-restricted/restricted_checks/Lewitus_etal_2014/comparison/` holds the source
audit (`Lewitus_SOURCE_AUDIT.md` / `.html`), the per-species × item provenance
(`Lewitus_etal_2014_ExternalDatabaseS1_provenance.csv`) and the neocortex attribution
(`Lewitus_etal_2014_Neocortex_source_attribution.csv`) built on this list.

## Data role

Citations, not trait values; `secondary` in the registry.
