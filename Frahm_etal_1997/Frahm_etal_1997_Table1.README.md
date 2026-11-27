# Frahm et al. (1997), printed Tables 1 and 2

Frahm, H. D., Rehkämper, G., and Nevo, E. (1997). Brain structure volumes in
*Spalax ehrenbergi* in comparison to the rat and subterranean insectivores.
*Journal of Brain Research* 38(2):209–222. PMID 9176733. The source is
`Frahm1997.pdf`, PDF p. 3 / printed p. 211.

## Snapshot layout

`Frahm_etal_1997_Table1_snapshot.xlsx` has `Table1` and `Table2` sheets. Each
sheet keeps its own printed caption, columns, the *Spalax* and *Rattus* blocks,
eight specimen rows in each block, the printed `(n=8)` means and `±SD` rows,
and the gap between species blocks. The two tables are on the same source page.
The item retains its historical `Table1` name because its output has always
combined structures from both printed tables; the workbook now makes that
combination explicit without joining or transposing either source table.

Codex transcribed the two tables from a 300–600 dpi page render on 2026-11-27,
cross-checking the source page's OCR text where legible and recomputing means and
sample SDs from the specimen rows. This is an assistant check, not human visual
signoff. The group labels alone appear in the tables; scientific names are
joined from `reference_tables/Frahm_etal_1997_Table1_species_lookup.csv`, which
cites the paper title and Methods.

## Reader and corrected data

Run `Rscript --vanilla Frahm_etal_1997/Frahm_etal_1997_Table1.R` from the
repository root. The reader takes each structure from the correct printed mean
column, joins the two sheets by group, and writes the CSV and public TSV. It
checks specimen IDs, row layout, and the printed means and SDs. The output now
has the `body_weight_g` and `brain_weight_mg` columns listed in the item
definitions and retains all 11 structure columns.

The former reader assigned column meanings by position against a normalized
14-column snapshot. It therefore placed body weight under `cerebellum_mm3`,
brain weight under `diencephalon_mm3`, and shifted most other structures. The
old CSV and downstream volume merge were affected. The item CSV, public TSV,
and canonical `__merging_volumes/volumes_compiled.R` outputs were rebuilt on
2026-11-27. The merge now records the printed *Spalax* cerebellum as 298.80 mm³
and rat neocortex as 495.13 mm³ under their correct structures. The merge run
initially exposed stale Smaers 2011 `_a_` item names in the term map; those were
corrected in the global and item-specific maps before the successful run.
The restricted DeCasien comparison was not run because that repository was not
available at its documented local path.

## Printed discrepancy

The *Spalax* Table 1 diencephalon specimen column reads `109.75`, `196.74`,
`199.62`, `199.40`, `172.45`, `181.77`, `182.24`, `173.33` in the scan. Those
values yield mean 176.91 and sample SD 29.30, whereas the table prints mean
187.04 and SD 11.15. Both are retained exactly in the snapshot; the reader
uses the printed group mean `187.04` for the group-level output. A value near
190.77 in place of `109.75` would explain the printed summary, but this is an
inference and was **not** substituted. The source scan should receive human
cell review before resolving whether this is a print or transcription issue.
