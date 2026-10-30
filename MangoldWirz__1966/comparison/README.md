# Regional indices and neocortex-ratio provenance comparison

This is a source-only companion to Mangold-Wirz (1966) Table II. It does not feed `__merging_volumes/volumes_compiled.R` and does not create new regional volume measurements.

## Outputs

- `MangoldWirz__1966_regional_index_proportion_long.csv`: 744 source-coordinate records, eight printed measures for each of 93 Table II rows. Blank index cells remain explicit blanks. `NI`, `RhI`, `CI`, and `StI` are the author's allometric indices; the four percentages are reported regional proportions. The author's names are Neopallium, Riechrinde, Cerebellum, and Stammrest (paper p. 455). These are historical delineations, not automatic synonyms for later volume-merge structures.
- `MangoldWirz__1966_neocortex_ratio_comparison.csv`: one row per 1966 species and later comparator candidate (96 rows total). For the reported `N/TH` percentage `p`, the algebraic analogue of a neocortex/rest-of-brain ratio is `p/(100-p)`. This is **not** Dunbar's measured ratio: the 1966 percentage comes from the paper's brain-part framework, while Dunbar's comparators use histological volumes or estimates derived from volumes. Rounding, source specimens, anatomical boundaries, and species versus genus averages also differ. No value is pooled or substituted.
- `MangoldWirz__1966_downstream_provenance_audit.csv`: paper/table-level source statements and limits on row-level attribution.

Rebuild all three: `python3 MangoldWirz__1966/comparison/build_regional_comparison.py`.

## Provenance findings

[Shultz & Dunbar (2006)](https://doi.org/10.1098/rspb.2005.3283) **explicitly cite Mangold-Wirz (1966)** among five sources of ungulate brain and body data in their Methods. They analyze neocortex mass and ratios of neocortex to other brain components. That establishes a paper-level path into a Dunbar-coauthored neocortex analysis. The article does not assign a source to each species/measure in the accessible Methods, so this audit does not label any particular 1966 Table II value as copied into the 2006 dataset. Its online supplementary PDF was not accessible in this audit; row-level tracing remains open.

The 1966 paper itself describes an expansion of Wirz's 1950/1954 work with additional Basel Zoological Institute material (preface, pp. 449–450). Its Table II lacks a per-specimen source key, so a 1950/1966 overlap cannot be treated as independent observations.

The primate [Dunbar (1992)](https://doi.org/10.1016/0047-2484(92)90081-J) Table 1 attributes neocortex and total-brain **volumes** to Stephan et al. (1981) (Methods, local PDF p. 5). [Dunbar & Bever (1998)](https://doi.org/10.1111/j.1439-0310.1998.tb00103.x) attribute carnivore volumes to Rohrs and Kamiya & Pirlot, and insectivore volumes to Frahm and Stephan (article pp. 697–699). [Shultz & Dunbar (2010)](https://doi.org/10.1037/a0018894) again specify Stephan, Frahm & Baron (1981) for their primate neocortex/brain volumes (local PDF p. 3). These methods provide no direct Mangold-Wirz attribution for their ratios. Indirect historical data dependence is not ruled out by this audit.

Within the repo, `Hofman__1985_Table1` documents use of literature fractions including Mangold-Wirz for some calculated prosencephalon volumes (paper p. 31), but its reference braces are block-level rather than value-level. `Baron_etal_1996_Table5` source code 9 identifies Mangold-Wirz for the brain/body values of *Myotis myotis* and *Nyctalus noctula*. `Sacher_Staffeldt_1974_Appendix` source key 2 marks 14 brain/body rows; `Stephan_etal_1991_Table5` key 41 marks four records for two taxa. These are reuse evidence for mass or calculated forebrain values, not proof of reuse of Table II's regional indices.

## Numeric comparison limits

20 of the 93 Mangold-Wirz rows have an exact printed species or same-genus candidate in the local Dunbar 1992 / Dunbar & Bever 1998 tables. There are 23 comparator rows, of which 22 carry a numeric ratio (Dunbar 1992 has no printed ratio for *Homo*). Only 14 comparisons are exact printed-species matches; the other 9 compare a species with a genus mean. Exact names do not establish specimen identity.

Examples: the transformed 1966 ratio is 1.703 for *Mustela erminea*, versus Dunbar & Bever (1998) 0.897 in Table 1 and 0.85 in Table 2. For *Procyon lotor* the values are 1.433 versus 1.407 and 1.35. Close values are not evidence of copying; divergent values show that the series cannot be interchanged without a source and measurement audit.

The comparison intentionally uses only exact printed binomials (stripping a comparator's trailing footnote digit) and exact genus names. Historical synonyms and misspellings are left unmatched rather than silently joined. Genus rows must never be interpreted as species matches.
