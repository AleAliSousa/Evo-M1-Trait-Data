# Gómez_etal_2016_TableIXA

Gómez, J. M., Verdú, M., González-Megías, A., & Méndez, M. (2016). The phylogenetic roots of human lethal violence. Nature, 538, 233–237. https://doi.org/10.1038/nature19758

Supplement IX.A (pp.12–52) contains 1,052 printed taxon rows, including subspecies and synonym/substitution footnotes. Preserve these rows for audit; they are not a count of independent extant species. The number of sampled deaths is the denominator and the percentage is the published proportion attributed to intraspecific interactions. Do not treat zero as proof of no lethal behavior, a sampled percentage as annual risk, or a rounded percentage as an exact integer count of killings.

The 1,042 distinct printed source tokens join an item-specific bibliography lookup (supplement pp.53–118). Three source cells concatenate reference numbers without separators; their exact tokens remain explicitly unresolved rather than guessed. Published taxon/family misspellings and superscript footnote digits remain traceable. Main-study human historical and archaeological tables IX.B/C are outside this intake. This is a secondary behavioral dataset, not additional primary observations from the cited studies. There is no published additive total to check. Validation covers all numerical cells, row coverage and reference joins.

AI source comparison performed on 2026-10-26. Human RA verification remains pending.

Rebuild with `Rscript Gómez_etal_2016_TableIXA.R` from any directory. The frozen source is read locally and the registry supplies the encoded public TSV name. Published taxon labels remain unchanged apart from explicitly described formatting. No global species key or unsupported hemisphere conversion is introduced. Source records enter the database and variable catalog; aggregate merge inputs are unchanged pending source/specimen and anatomical mapping.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Gómez_etal_2016_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Gómez_etal_2016-E001 | source_key | IX.A, p.18; Cercopithecus mitis stuhlmanni2 | 396701 |  | publication_ambiguity |  | confirmed | PDF visibly prints concatenated reference digits without separator; exact key kept with unresolved lookup entry, not silently split. | Published values retained; no inferred correction. |
| Gómez_etal_2016-E002 | source_key | IX.A, p.31; Manis tricuspis | 898999 |  | publication_ambiguity |  | confirmed | PDF visibly prints concatenated reference digits without separator; exact key kept with unresolved lookup entry, not silently split. | Published values retained; no inferred correction. |
| Gómez_etal_2016-E003 | source_key | IX.A, p.35; Myotis brandtii | 468998 |  | publication_ambiguity |  | confirmed | PDF visibly prints concatenated reference digits without separator; exact key kept with unresolved lookup entry, not silently split. | Published values retained; no inferred correction. |

3 recorded, 0 open (proposed), 3 confirmed, 0 withdrawn.
<!-- errata:end -->
