# Pontzer et al. 2014 — Table S1

Pontzer H et al. (2014), *Primate energy expenditure and life history*, PNAS 111:1433–1437, DOI 10.1073/pnas.1316940111. The registered item is `Pontzer_etal_2014_TableS1`, encoded `10.1073%2Fpnas.1316940111_TableS1`. The source is `pnas.201316940si.pdf`, PDF page 7 of 10: “Additional information for primate TEE samples (Table 1).”

## Build and contents

Run from the repository root:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Pontzer_etal_2014/Pontzer_etal_2014_TableS1_snapshot.R
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Pontzer_etal_2014/Pontzer_etal_2014_TableS1.R
```

The separate snapshot script reads the PDF text layer with `pdftotext -layout`, joins cells that wrap onto a second printed line, and freezes 19 source-order rows in `Pontzer_etal_2014_TableS1_snapshot.csv`. It preserves the printed species spellings, the `Adult` and em-dash age cells, missing SD/range cells, and the notes. The item script reads only that snapshot and writes the 19-row analysis CSV and registered public TSV. Body mass is converted from kg to the project unit g (×1000); TEE remains in the printed kcal/day. Numeric range endpoints are parsed into separate columns, while the printed range strings remain available. `SD` is the table's stated dispersion type; no error-bar type is inferred.

Layout edit: restored the printed caption and the `Body mass` / `TEE` spanning headings above
their Mean, SD, and Range columns. The extractor now emits this source grid; the R reader derives
flat analysis names. Both scripts ran, and the 19-row analysis CSV is byte-identical to its
pre-edit version.

The source page was rendered and visually compared with the snapshot on 2026-11-26 by an AI assistant: all 19 population rows, column order, wrapped species/population/notes cells, units, missing cells, and first/last rows matched. This is **not human visual signoff**. Human review remains pending in the registry.

The item name and citation already exist in the main registry. `Pontzer_etal_2014_TableS1_registry_row.xlsx` supplies the missing descriptive fields for that existing row and includes a paste guide; it leaves generated name/formula cells blank. The live registry workbook was not changed during this build.

## Identity and use

`species_as_published` preserves `Aloutta palliata` and `M. mulata` as printed. The paper-scoped rows in `_keys/General/species_key.csv` resolve those spellings and the abbreviations without changing the snapshot. `Eulemur sp.` remains genus-only. `P. pygmaeus` is retained as the source's *Pongo pygmaeus* concept; the three zoo individuals are not assigned to a modern Bornean/Sumatran split. The Hadza and Westerner human rows, and the wild and research-station *Lemur catta* rows, remain separate populations.

This table supplements the article's Table 1 with sample size, mean age, body-mass and TEE SD/ranges, and population notes. The article combines original measurements with previously published samples, but Table S1 gives no per-row citation key. Treat its values as a **mixed-provenance compiled table**; do not add its population means as a second independent measurement team in a cross-publication merge until the original sources are resolved. No row-level reference is invented.

## Checks and limits

The build checks 19 source rows, a unique registry match, complete N/means, and that every printed numeric range encloses its corresponding mean. Table S1 prints no totals that support a stronger internal arithmetic check. Missing ranges and SDs remain blank. The separate source PDF is retained beside the snapshot; the public TSV is `__Public/comparative-data/10.1073%2Fpnas.1316940111_TableS1.tsv`.
