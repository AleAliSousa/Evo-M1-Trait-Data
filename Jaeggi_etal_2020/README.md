# Jaeggi et al. 2020: population social organization

Variable social organization is ubiquitous in Artiodactyla and probably evolved from pair-living ancestors. DOI: https://doi.org/10.1098/rspb.2020.0035

Author workbook downloaded 2026-10-23 from https://github.com/adrianjaeggi/artiodactyl.socialorg (Artiodactyla_Dataset_corrected_11Mar.xlsx). The original workbook and GitHub file metadata are preserved in source/ and SHA256 hashes in source_manifest.csv.

All 245 population records across 100 printed species are transcribed from the population sheet, including locations, adult sex-composition codes and reference strings. These are SECONDARY classifications drawn from primary field studies, not 245 new primary observations. Primary-paper verification remains pending; references are retained per row. Numerical codes indicate categories/presence, not group sizes. The author species-level summary and phylogenetic proxy substitutions are not used as extra observations.

The merge table contains the set of states observed across populations, never a first or modal species state. No counts are inferred from solitary or pair labels. The original population rows remain available. The historical guanaco name Lama glama guanicoe maps to Lama guanicoe using MDD taxon 1006386; it must not map to the domestic llama.

Rebuild (changed 2026-10-31): `python3 _checks/social_variables/build_population_censuses.py` from the
repository root freezes the snapshot and the readable sheet twin; the analysis layer is then built in R
by `Jaeggi_etal_2020_Populations.R` (frozen workbook -> 245 population rows) and
`Jaeggi_etal_2020_SocialStates.R` (those rows -> 100 species state sets, run second). The python no
longer writes the two CSVs, so each file has one writer. The R rebuild reproduces them cell for cell
except that `primary_paper_verified` now prints R's `FALSE` instead of python's `False`. Neither item is
in `__ReadMe.xlsx`, so each script writes its CSV and reports that the public TSV is skipped until a
registry row exists. Source input is unchanged. Definitions and the supplementary source mapping specify the app label and secondary role.

Source integrity: local Office copies acquired added custom metadata without changes to worksheet/document content. Authoritative original bytes are preserved inside ZIP archives; the rebuild reads the archived workbook. source_manifest.csv hashes the archives and other non-Office evidence, not mutable display copies.

## Snapshot provenance — repaired 2026-10-31

`Jaeggi_etal_2020_Populations_snapshot.xlsx` is now **byte-identical to the author's workbook**
(177,036 bytes), extracted straight from `source/author_workbook_original.zip` by
`build_population_censuses.py`. The previous file was an Office display copy that had gained local
metadata on open (183,616 bytes), so it was not the untouched download the house rule requires.

`Jaeggi_etal_2020_Population_snapshot.csv` has been renamed to
`Jaeggi_etal_2020_Population_sheet_rows.csv`: it is a readable twin of the frozen sheet — the
workbook's own column headers and row order, with the workbook row number on every record — not a
second snapshot. `Jaeggi_etal_2020_Populations.csv` and `_SocialStates.csv` are unchanged
(245 population rows, 100 species).
