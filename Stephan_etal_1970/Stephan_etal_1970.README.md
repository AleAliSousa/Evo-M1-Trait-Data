# Stephan, Bauchot & Andy (1970) — per-table data

Stephan, H., Bauchot, R., & Andy, O. J. (1970). *Data on the size of the brain and of the
various brain parts in insectivores and primates.* In C. R. Noback & W. Montagna (Eds.),
**The Primate Brain** (Advances in Primatology vol. 1), pp. 289-297. Appleton-Century-Crofts.
ISBN 0390672505. (DeCasien & Higham 2019 reference #51.)

## Layout — one snapshot per printed table (project convention)

The 1970 volume data span **6 printed tables = 2 structure-groups × 3 taxa**:

| | Insectivore | Prosimian | Simian |
|---|---|---|---|
| **fundamental brain parts** (body/brain weight, total brain, medulla, cerebellum, mesencephalon, diencephalon, telencephalon) | Table 1 (22 spp) | Table 2 (20 spp) | Table 3 (21 spp) |
| **telencephalon components** (bulbus olfactorius, palaeocortex+amygdala, septum, striatum, schizocortex, hippocampus, neocortex) | Table 4 (22 spp) | Table 5 (20 spp) | Table 6 (21 spp) |

Each printed table is its own item: `Stephan_etal_1970_Table{1..6}` with a matching
`_snapshot.csv`, `.R`, `.csv`, and public TSV (`ISBN%3A0390672505_TABLE{1..6}.tsv`).
The taxon is named in each printed caption. The R reader derives its `group`
column from the table number; the source snapshots do not add one.

> **History.** These tables were previously bundled as a single `Tables1-6` item that
> `left_join`ed Tables 1-3 with 4-6 and dropped the group label. That bundle was replaced by
> this per-table split (matching HerculanoHouzel_etal_2015 and every other multi-table item).
> The split is merge-invariant: `volumes_long.csv` / `volumes_wide.csv` are byte-identical
> before and after (see `__merging_volumes/…` and the split invariance report).

## Files per table
- `Stephan_etal_1970_Table{n}_snapshot.csv` — source-shaped transcription with caption, printed header and column numbers, numbered species rows, and subgroup rows where printed
- `_read_printed_table.R` — reads the numbered rows and derives analysis fields from the table caption and column positions
- `Stephan_etal_1970_Table{n}.R` — reads the snapshot through the helper, then writes the CSV + public TSV
- `Stephan_etal_1970_Table{n}.csv` — cleaned local output
- `__Public/comparative-data/ISBN%3A0390672505_TABLE{n}.tsv` — the merge's input

## Cross-table QA
`Stephan_etal_1970_crosstable_QA.R` checks the 7 telencephalon components (Tables 4-6) sum to
the Telencephalon total (Tables 1-3), per species. **PASS**: max |diff| 0.345 %, median 0.006 %
(n=63). This check was previously internal to the bundled build script; it now stands alone
because the components and totals live in separate items.

## Notes
- Layout audit (2026-11-27): Tables 1–6 were compared with the six scanned
  pages of `stephan_etal_1970.pdf`. The six item snapshots and the two aggregate
  snapshots now follow the printed table orientation and row order. Tables 1
  and 4 retain the A/B insectivore section rows. Aggregate snapshots concatenate
  three separate printed tables rather than joining their columns. The source
  footnotes are condensed after the data grid; the full wording remains on the
  scanned pages. Decimal display may differ from the print, while numeric
  values are retained. This is an assistant layout check, not human signoff.
- Rebuild: from the repository root, run
  `for n in {1..6}; do Rscript Stephan_etal_1970/Stephan_etal_1970_Table${n}.R; done`
  and `Rscript Stephan_etal_1970/Stephan_etal_1970_Tables1-6.R`.
  All six per-table analysis CSVs and the 63-row aggregate CSV matched their
  pre-layout versions cell for cell after the rebuild.
- `palaeocortex_plus_amygdala` (Tables 4-6, a combined 1970 structure) must NOT be merged with
  the separate Palaeocortex / Amygdala structures Stephan reports from 1981 onward.
- Status: DRAFT transcription (verify against the source before publication use).
