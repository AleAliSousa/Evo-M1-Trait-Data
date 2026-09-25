# Dell et al. 2016 — Table 4 (calcium-binding protein density, harbor porpoise)

Dell, L.-A., Patzke, N., Spocter, M. A., Siegel, J. M., & Manger, P. R. (2016). Organization of
the Sleep-Related Neural Systems in the Brain of the Harbour Porpoise (*Phocoena phocoena*).
*Journal of Comparative Neurology*, 524(10), 1999-2017. doi:10.1002/cne.23929

**Table 4** — "Density of Neurons and Terminal Networks of the Calcium Binding Proteins
Calbindin (CB), Calretinin (CR), and Parvalbumin (PV) in Relation to Various Sleep-Wake Nuclei
in the Brain of the Harbor Porpoise." Qualitative density scores (-, +, ++, +++) for each of 19
sleep/wake-related nuclei (grouped under the cholinergic, catecholaminergic, serotonergic, and
orexinergic systems, plus the thalamic reticular nucleus), crossed with 3 calcium-binding
proteins x 2 measure types (neurons / terminal networks) = 114 data rows.

## What was already built (folder had no README/definitions)
- **Frozen source:** `Dell_etal_2016_TABLE4_snapshot.xlsx` — hand-verified capture of the printed
  Table 4 (this is a printed/scanned source: the table is a picture of qualitative symbols in the
  PDF, not a machine-readable export, so a snapshot is required per
  `__HOWTO_build_a_dataset_file.md` §0a invariant 1).
- **Reformat:** `Dell_etal_2016_Table4.R` reads the snapshot positionally, fills the `System`
  group label down from the four printed group headings (Cholinergic/Catecholaminergic/
  Serotonergic/Orexinergic), tags the thalamic reticular nucleus row separately (it prints outside
  any of the four systems), reshapes wide-to-long (one row per nucleus x protein x measure type),
  and derives a numeric `Density_Score` + plain-language `Density_Description` from the printed
  symbol. Writes:
  - `Dell_etal_2016_Table4.csv` (analysis-ready, 114 rows x 8 columns)
  - `__Public/comparative-data/10.1002%2Fcne.23929_Table4.tsv` (public, DOI-encoded — already
    present, confirmed against the registry's `Item encoded`)
- **Definitions:** `reference_tables/Dell_etal_2016_Table4_definitions.csv` (added now).

## Known issue — orphan TSV in the paper folder
A copy of the TSV (`Dell_etal_2016_Table4.tsv`) is sitting **inside this paper folder** as well as
in `__Public/comparative-data/`. Per `audit_dataset_item()` / the build-dataset-item skill, any
`.tsv` inside a paper folder (other than a `*_snapshot.tsv` frozen source) is an orphan — public
TSVs belong only in `__Public/comparative-data/`. The two copies are byte-identical to the current
CSV, so nothing is lost, but the stray copy should be deleted from this folder (file deletion isn't
available through this session's tools — please remove
`General/Species/Evo-M1-Trait-Data/Dell_etal_2016/Dell_etal_2016_Table4.tsv` by hand).

## Data role
**Primary.** First (and only) systematic report of calcium-binding-protein density across these
sleep/wake nuclei in *Phocoena phocoena*.

## Species names
Single-species paper (harbor porpoise) — the species is not a printed table column (it lives in
the title/methods), so `Species_Dell2016` carries the printed common name on every row per house
rule §5 ("single-species papers are not exempt").

## Quality caveats (from the source)
- Table 4 pools **both** study animals — the paper states "the description provided below applies
  to both animals" — so densities are qualitative per nucleus/protein/measure-type, not per
  individual specimen.
- Density is a **qualitative, ordinal** score (the paper's own -/+/++/+++ symbols), not a cell count
  or concentration; `Density_Score` (0-3) and `Density_Description` are derived for analysis
  convenience but the printed symbol (`Density`) remains the primary transcribed value.

## Checks
- Analysis CSV = 114 rows (19 nuclei x 3 proteins x 2 measure types), matching the printed table's
  cell count exactly; no accidental empty columns.
- No independent curated copy exists to audit against (first report of this specific measure) — no
  `comparison/` step applies (§7).

## Extraction / build record
Snapshot, reformat script, CSV, and public TSV were already in place. This README and the
definitions file were added by Microsoft Copilot (AI assistant) on 2026-09-25, reading the frozen
snapshot, the existing `.R` script, and the source PDF's Table 4 (with its footnote defining the
density symbols) to document the pipeline. No values were re-transcribed or changed.
