# Westergaard_Hyatt_1994 — reconciliation note (2026-10-30)

Westergaard GC, Hyatt CW (1994). The responses of bonobos (*Pan paniscus*) to their mirror images: Evidence of self-recognition. *Human Evolution* 9(4):273–279. doi:10.1007/BF02435514. PDF in folder (7 pp.).

## What exists
| Object | Location | Matches a Sheet1 `Item name`? |
|---|---|---|
| `Westergaard_Hyatt_1994_Figure1` | `__ReadMe.xlsx` Sheet1, Progress stage **HOLD — primary evidence only for a demonstrated gap** | registry row; no files |
| `Westergaard_Hyatt_1994_Figure2` | same, HOLD | registry row; no files |
| `archive/Westergaard_Hyatt_1994_Figures1and2{.R, .csv, _snapshot.csv, .README.md}` + `archive/reference_tables/…_Figures1and2_{definitions,references}.csv`, `…_build.json` | built 2026-10-25 by the Nick/Fran batch (`_helpers/build_source_table.R`) | **no** |
| `__Public/comparative-data/10.1007%2FBF02435514_Figures1and2.tsv` | public TSV (1 row) | **no** — orphan. It is listed in `AUTO_Public_TSV_FileList`, but no Sheet1 row has Item encoded `10.1007%2FBF02435514_Figures1and2` |

The archive record is one constructed row: *Pan paniscus*, 9 subjects, 4 showing mirror-aided self-inspection (Bosondjo; Jill; Laura; Zalia), mark test not administered. Checked against the PDF text layer:
- p.1 Methods: "The subjects were nine bonobos";
- p.2 Table 1: nine named subjects;
- p.5 Results: "Four animals (Bosondjo, Jill, Laura, and Zalia) exhibited mirror-aided self-inspection".

These values come from **Methods / Table 1 / Results text, not from Figure 1 or Figure 2**. Figure 1 plots adjusted-frequency differences and Figure 2 relative-duration differences, by behaviour and age class. Neither was digitised.

## Decision
- **Not aligned to Figure1/Figure2.** The archive product holds no figure values, so renaming it to `…_Figure1`/`…_Figure2` would misstate its locus.
- **HOLD respected.** The registry HOLD allows primary extraction only for a documented gap in the chosen compilation. None is documented. No figure digitisation was done, and the archive was not promoted.
- **Nothing deleted or moved.** `archive/` stays as is.

## Owner actions proposed
1. Either delete the orphan `__Public/comparative-data/10.1007%2FBF02435514_Figures1and2.tsv` or register it. To register it, add a row for a text/Table-1 item (e.g. Item number `ResultsText`), rename the archive build to that Item name, and rebuild.
2. If a gap is later demonstrated, digitise Figure 1 and Figure 2 as constructed snapshots: panel × behaviour category × age class, with method and error documented. Table 1 (subject, age in months, sex, mirror exposures; `*` = age estimated) is printed and can be transcribed directly.
