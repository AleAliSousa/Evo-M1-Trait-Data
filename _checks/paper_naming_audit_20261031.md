# Paper naming audit — 2026-10-31

Scope: `Evo-M1-Trait-Data` paper folders, `__ReadMe.xlsx` Sheet1 and its generated TSV list, public comparative TSVs, and `Evo-M1-Trait-Data-restricted/restricted_checks`. Existing unrelated worktree edits were preserved.

## Verified after repairs

- Registry: 942 Sheet1 data rows; no formula error values in naming columns; 0 publication keys without a corresponding paper folder; 0 trailing-underscore item keys.
- Public comparative data: 858 TSVs; 0 names absent from registry `Item encoded`; generated `AUTO_Public_TSV_FileList` exactly equals the TSV directory; workbook ZIP integrity passes.
- Accented folder keys and files: normalized to NFC for Ballesteros-Yáñez, Braitenberg-Schüz, de Magalhães 2024, Lethmate-Dücker, Medina-González, Norlén, Sjölin, and Zilles-Rehkämper. The active folder auditor now folds accents when comparing names.
- Single-author folders: `Krubitzer__1995`, `Krubitzer__1998`, and restricted `Weigl__2005` now use the double underscore. `Lukas_CluttonBrock_2013` now includes its year.
- The four Hardus 2009 registry rows and the Pasquaretta 2014 row now resolve to their actual paper folders. The R registry-list rebuild helper recognizes the abbreviated `et al.` citation style and Hardus's initials.
- Seven Galán-Acedo 2019 registry item labels no longer include `.csv`; the IUCN reader and its files now share one item stem. Gillette 1973 uses the DOI stated in its citation instead of the old PMID override. Three whole-paper rows without a dataset item use `NoDatasetItem` rather than a trailing underscore.
- Corrected DOI encoding, stray spaces, and stale duplicate TSV names. Byte-identical duplicates and `NA.tsv` were removed. Four vision text items, Owren 1988, and Schusterman 1974 were aligned to the stems of their existing reader scripts; the printed source locus remains in the registry title or item README.
- Stephan 1970 Tables 1–6 and Stephan 1988 Table 1 now use their registered `TABLEn` stems in file and code references. Møhl 1968 uses the registered `TableII` stem. Renamed R scripts parsed successfully; four modified Python scripts parsed successfully.

## Remaining content decisions

Seven unique registered items have a TSV but no top-level source or reader file with the same item stem. These are not safe mechanical renames:

| Registry row | Item | Why it needs review |
|---:|---|---|
| 325 | `Heffner_etal_2010_ResultsText` | Folder contains `TableI` files; verify whether this is the same paper and locus. |
| 379 | `HerculanoHouzel_etal_2013_Figure2TopLeft` | Folder contains Table 1 files; locate the figure extraction. |
| 471 | `Kamiya_Pirlot_1988_Table1` | The 1988 folder also contains four `Kamiya_Pirlot_1980_TABLE1` files; a separate 1980 folder exists. Verify provenance before moving or deleting either set. |
| 497–498 | Karlsen & Pakkenberg 2011 `authordata(groupmeans)` and `reportedvalues` | Source file stems use `_groupmeans` and `_reported_values`; the TSVs match the registry. Confirm desired product identity. |
| 585 | `Mackes_etal_2020_ERABIS(cortical)` | Folder files are at the broader `ERABIS` stem; confirm whether cortical is a subset. |
| 859 | `Walhovd_etal_2011_normativevolumes` | The reader uses this registry key, while source/product files use `_normative_snapshot` and `_derived`. This may be intentional. |

Rows 940–943 repeat the Karlsen, Walhovd, and Mackes keys; the seven cases above are unique keys. There are also registry items without public TSVs, but those include explicit holds, reference-only rows, and unbuilt items. This audit does not infer missing data from a name mismatch.

## Proposed naming rule for new registrations

Use one stable, exact key for the paper folder, item files, reader lookup, and registry `Item name`. Paper keys use `<FirstAuthor>_<SecondAuthor|etal>_<Year>` and `<FirstAuthor>__<Year>` for a single author. Normalize path components to Unicode NFC. Put source PDF filenames, printed labels (for example “Table I” or “Tables 1 and 3”), and descriptive loci in their own fields; they do not define the item key. Item keys should use an ASCII token such as `TABLE1`, `FIGURE3A`, or `TEXTRESULTS`, with no file extension, spaces, colon, parentheses, or trailing underscore. Use `NoDatasetItem` for reference-only or held whole-paper rows. Preserve legacy keys through an explicit alias map rather than silently changing all historical rows, because existing code and citations depend on their current spellings.

A preflight check should compare NFC-normalized publication keys to folders, exact `Item name` keys to reader/product stems, and exact `Item encoded` keys to public TSV filenames before a build or registry refresh. Source filenames should be checked separately.

## Follow-up build and provenance check

After the seven-row review workbook was prepared, the Herculano-Houzel 2013 Figure 2 top-left item was rebuilt from the paper's frozen printed Table 1 snapshot. Its new same-stem reader calculates the 18 plotted cortical-area volumes as mean neurons divided by neurons per mm³, writes a same-stem CSV and the registered TSV, and preserves the earlier approximate digitized TSV for comparison. The two versions use the same 18 region keys; the largest relative difference is 1.74% for neuron count and 3.47% for volume. A human visual check remains to be recorded.

The Heffner deer item already has a conventional reader and frozen source in `Heffner_Heffner_2010`; its registry row 325 still needs the author-key correction staged in the review workbook. The reader now accepts both current and corrected registry keys while that paste is pending.

The Kamiya 1988 folder PDF is the Malayan bear paper (pp. 225–235), while registry row 471 cites the lesser panda paper (pp. 65–72). The current TSV contains bear taxa. It cannot be validated as the registered lesser-panda item from the available local source. The four 1980-labeled files in the 1988 folder are a separate provenance issue. These are source-identity decisions, not safe file renames.

## Workbook repair after sheet-index error

The temporary TSV-list update code used `sheet2.xml` as if it were `AUTO_Public_TSV_FileList`. In this workbook, `sheet2.xml` is `SOURCE_DISPOSITION`; it was overwritten with filenames while the actual auto-list (`sheet3.xml`) remained stale. On 2026-10-31, `SOURCE_DISPOSITION` was restored from `_checks/__ReadMe_before_naming_20261031.xlsx` (the 14:39 pre-audit copy), `Sheet1` was preserved byte-for-byte from the immediately preceding current workbook, and the actual `AUTO_Public_TSV_FileList` was rebuilt from the directory's then-current 865 TSVs. `_tools/check_readme_integrity.py` now checks all three sheets and the TSV list read-only.

A second Excel recovery warning remained after the sheet restoration. Five modified author formulas (`F282:F285`, `F672`) had lost their array-formula markers while `xl/calcChain.xml` still marked them as arrays. The repair restored those markers, preserved current cell data and formulas, and restored the native XML headers for altered parts. An exact-byte copy then opened in desktop Excel without a warning; the live `__ReadMe.xlsx` also opened without a warning and was saved by Excel. The read-only integrity checker now compares array-formula markers with the calculation chain. After Excel saved, the three sheets retained their shapes, the auto-list still matched 865 TSVs, and 132 cached match values in Sheet1 column L refreshed from `notfound` to filenames.
