# MacLean et al. 2014 supplementary Tables S1–S7

MacLean EL et al. (2014). The evolution of self-control. *PNAS* 111:E2140–E2148. doi:[10.1073/pnas.1323533111](https://doi.org/10.1073/pnas.1323533111). The [article](https://pmc.ncbi.nlm.nih.gov/articles/PMC4034204/) points to the online supporting information.

## Sources and rebuild

The seven `pnas.1323533111.st0*.docx` files are byte-preserved copies of the publisher supplementary tables supplied in the main checkout. `extract_supplement_snapshots.py` reads their displayed Word-table cells into `MacLean_etal_2014_TableS*_snapshot.csv`. Each snapshot includes the table's header and any blank or footnote rows, with a one-based `source_row` locator. These snapshots preserve printed values, spellings, missing markers, and row order.

Run:

```sh
python3 MacLean_etal_2014/extract_supplement_snapshots.py  # needs python-docx
for n in 1 2 3 4 5 6 7; do Rscript "MacLean_etal_2014/MacLean_etal_2014_TableS${n}.R"; done
```

Each item has its own snapshot CSV and standalone R reader. Each R reader checks its source layout and writes its analysis CSV plus `_definitions.csv`. Numeric columns parse printed numbers; the raw snapshots retain formatting such as trailing zeroes. No taxon names, scores, or published statistics are corrected or recomputed.

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

`compare_sources.py` extracts the 201 main-paper references from the PDF and the 31 distinct SI references from `MacLean_etal_2014_SIText_extracted.txt`. The latter text snapshot was extracted from the publisher SI PDF in this chat; that PDF was subsequently removed from the project folder, so the text is retained for reproducibility. Tables S1 and S2 have 38 and 66 species-reference links, respectively. S1 ECV is compared against the repository ECV merge for exact printed binomial matches: 23 matches, 11 identical values, and 12 differing values. The remaining 13 need taxonomic review or are absent from the merge. S2 range and journey units are not printed and are not numerically compared.

## Boundaries

S4 identifies living cognitive-test subjects, whereas S1 brain volumes are literature-derived species data. They are distinct evidence types. The supplementary tables do not establish that any S4 subject contributed an S1 brain measurement. Common-name spellings vary between tables (`white carneau pigeon` in S4 versus `white carnea pigeon` in S5; `Scurius niger` in S1/S5 versus `Sciurus niger` in S3), so joins should use an explicitly reviewed name crosswalk rather than an automatic exact-string match.
