# MacLean et al. 2014 supplementary Tables S1–S7

MacLean EL et al. (2014). The evolution of self-control. *PNAS* 111:E2140–E2148. doi:[10.1073/pnas.1323533111](https://doi.org/10.1073/pnas.1323533111). The [article](https://pmc.ncbi.nlm.nih.gov/articles/PMC4034204/) points to the online supporting information.

## Sources and rebuild

The seven `pnas.1323533111.st0*.docx` files are byte-preserved copies of the publisher supplementary tables supplied in the main checkout. The per-item `MacLean_etal_2014_TableS<N>_snapshot.R` scripts read their displayed Word-table cells into `MacLean_etal_2014_TableS<N>_snapshot.csv`. Each snapshot includes the table's header and any blank or footnote rows, with a one-based `source_row` locator. These snapshots preserve printed values, spellings, missing markers, and row order.

Run:

```sh
for n in 1 2 3 4 5 6 7; do Rscript "MacLean_etal_2014/MacLean_etal_2014_TableS${n}_snapshot.R"; done  # needs xml2; refuses to overwrite a differing frozen snapshot
for n in 1 2 3 4 5 6 7; do Rscript "MacLean_etal_2014/MacLean_etal_2014_TableS${n}.R"; done
```

The snapshot scripts were ported from Python (python-docx) to R (xml2) and regenerate the frozen snapshots byte for byte; the Python scripts are kept as `*_snapshot.py.retired`. Each item has its own snapshot CSV and standalone R reader. Each R reader checks its source layout and writes its analysis CSV plus `_definitions.csv`. Numeric columns parse printed numbers; the raw snapshots retain formatting such as trailing zeroes. No taxon names, scores, or published statistics are corrected or recomputed.

| Item | Content | Analysis rows | Important handling |
|---|---|---:|---|
| S1 | Endocranial volume, body mass, and source numbers | 36 | Retains printed Latin names, including `Scurius niger`; source note says rodent brain data from reference 22 were corrected per reference 23. |
| S2 | Primate ecology and source numbers | 23 | `NA` becomes blank in numeric outputs; home-range and day-journey units are left unspecified because the table headers print none. `A`/`T` substrate codes remain as printed. |
| S3 | Test locations | 42 | Multiple rows can describe one species at different locations. |
| S4 | Subject information and experiment participation | 567 | Subject key is species common name + population + subject. Ages stay free text, including `adult`, `juvenile`, and separate `(a)`/`(b)` ages. Asterisk and dash markers are preserved and also exposed as Boolean participation fields. |
| S5 | Species-average task and composite scores | 36 | Printed dash becomes blank in numeric outputs; composite scores are not recalculated. |
| S6 | Within-species population comparisons | 6 | The two-level header, blank separator, and identical-performance footnote remain in the snapshot. Censored p-values such as `< 0.01` remain text. |
| S7 | Primate socioecological associations | 45 | The Word table grid repeats each `df` cell as a second `p` cell. The rendered table shows one `df` column and one `p` column. The reader verifies the duplicated cells and uses the actual p-value from grid column 6. Censored p and r² values remain text. |

## References and comparison to existing data

Cross-item checks and provenance files live in `internal_checks/` (build HOWTO 7b); the item scripts read only their own snapshot. `internal_checks/MacLean_etal_2014_TableS1_internal_check.R` and `..._TableS2_internal_check.R` (R ports of the corresponding parts of `compare_sources.py`) parse the 31 distinct SI references from `MacLean_etal_2014_SIText_extracted.txt` and resolve the source numbers cited in `MacLean_etal_2014_TableS1.csv` / `_TableS2.csv`. Tables S1 and S2 have 38 and 66 species-reference links, respectively. The S1 script also compares S1 ECV with the repository ECV merge for exact printed binomial matches: 23 matches, 11 identical values, and 12 differing values; the remaining 13 need taxonomic review or are absent from the merge. S2 range and journey units are not printed and are not numerically compared. Their outputs (`*_internal_check.csv`, `MacLean_etal_2014_SIReferences.csv`, `*_source_links.csv`, `MacLean_etal_2014_S1_vs_ECV_merge.csv`) are written to `internal_checks/` and are byte-identical to the copies of the same names that `compare_sources.py` left in this folder.

`compare_sources.py` still extracts the 201 main-paper references from the PDF (`MacLean_etal_2014_MainPaperReferences.csv`): that step needs `pypdf`, because an R PDF reader (poppler) lays the text out differently (it reproduces only 40 of the 201 entries, 30 of them identical text) and so cannot regenerate the committed file. The text snapshot `MacLean_etal_2014_SIText_extracted.txt` was extracted from the publisher SI PDF in this chat; that PDF was subsequently removed from the project folder, so the text is retained for reproducibility.

## Table checks

Cross-item checks in `internal_checks/` (run in a temporary copy of the repo, results as written there):

| item | check | result |
|---|---|---|
| S1 | `si_reference_list_complete`: 31 SI references parsed, numbered consecutively | pass (31 of 31) |
| S1 | `source_numbers_resolve`: every source number cited in `MacLean_etal_2014_TableS1.csv` resolves to an SI reference | pass (8 of 8 distinct numbers; 38 links) |
| S2 | `si_reference_list_complete` | pass (31 of 31) |
| S2 | `source_numbers_resolve`: reference numbers cited in `MacLean_etal_2014_TableS2.csv` | pass (9 of 9 distinct numbers; 66 links) |

The tables print no totals or other relation that can be recomputed within a single item, so the item scripts carry no `table_checks`.

## Boundaries

S4 identifies living cognitive-test subjects, whereas S1 brain volumes are literature-derived species data. They are distinct evidence types. The supplementary tables do not establish that any S4 subject contributed an S1 brain measurement. Common-name spellings vary between tables (`white carneau pigeon` in S4 versus `white carnea pigeon` in S5; `Scurius niger` in S1/S5 versus `Sciurus niger` in S3), so joins should use an explicitly reviewed name crosswalk rather than an automatic exact-string match.
