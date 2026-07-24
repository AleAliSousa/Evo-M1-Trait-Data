# Lewitus et al. 2014 — Table S8 (neocortical neuron number, Figure 3d)

Lewitus E, Kelava I, Kalinka AT, Tomancak P, Huttner WB (2014). *An adaptive threshold in
mammalian neocortical evolution.* PLoS Biology 12(11):e1002000. doi:10.1371/journal.pbio.1002000

Neocortical **neuron number** and **gyrification index (GI)** for 25 mammal species (the data behind
Figure 3d).

## Numbering note
The supplement download (`…s020`) is registered and cited in this project as **Table S8**
("Neocortical neuron number for Figure 3d"), but the spreadsheet's own title cell reads
**"Table S9"**. The item name is kept as `Lewitus_etal_2014_TableS8` to match the registry and the
public encoded name; the discrepancy is recorded here and in the definitions.

## Source → CSV → public TSV (digital-native: no snapshot)
This is a **digital-native** source, so the snapshot step is **skipped** — the journal's own
machine-readable supplement is already the durable, faithful copy, and freezing a second copy of it
would add nothing. The build reads the source **directly** and all cleaning is reproducible from it.

- **Source:** `pbio.1002000.s020.xlsx` (sheet `Sheet1`; row 1 = "Table S9" title, row 2 = header),
  kept in this folder.
- **Reformat:** `Lewitus_etal_2014_TableS8.R` reads the source directly, drops the trailing blank
  rows, keeps neuron counts as **full-precision integers**, harmonises species, and writes:
  - `Lewitus_etal_2014_TableS8.csv` (analysis-ready, 25 species)
  - `__Public/comparative-data/10.1371%2Fjournal.pbio.1002000_TableS8.tsv` (via the
    `__ReadMe.xlsx` Item name → Item encoded lookup)

> The earlier build made a `Lewitus_etal_2014_TableS8_snapshot.xlsx`; under the current
> digital-native convention that snapshot is **retired / no longer read** by the build (kept only
> as legacy provenance). Delete it if you prefer a clean folder.

## Comparison (founder public TSV is the QA anchor)
`comparison/Lewitus_etal_2014_TableS8_compare_to_public_tsv.R` audits the build output against the
DOI-coded TSV that already existed in `__Public` before this project began (the "already there"
founder file). The founder TSV is treated **only as a comparison anchor — never as a snapshot**.
Matched by `Species`; measured columns `Neuronal_number` and `GI` compared. **Result: 25/25 matched,
0 mismatches** — the source-direct build reproduces the public TSV byte-for-byte. This step also
regression-guards every future re-run.

## Fix on record (historical)
The public TSV had once stored neuron counts in **rounded scientific notation** (`1.42E+07`); the
current file carries the **full-precision integers** from the source (`14200000`). Had the founder
file still been rounded, the comparison above would have flagged it (cf. Smaers 2011 Suppl. Table 2,
where the audit found 19/26 rounded values and the public TSV was regenerated).

## Species / role
Printed names preserved in `Species`; accepted binomials in `species_sci` via the project key
(`_keys/Stephan/species_key.csv` + `_keys/species_reference.csv`). `Neuronal_number` is **primary**;
`GI` is **secondary** (also in Table S1).
