# Compilation lessons — rules for the next compilation, each traced to an audit finding

Source of every number: stage 11 (`COMPILER_DECISIONS.md` and its five CSVs)
of the three `*_refs_check` pipelines in `Evo-M1-Trait-Data-restricted`
(Stephan_primates 2 048 cells; DeCasien & Higham 2019 MOESM3 2 234; Bath
sensory workbook 763), run 2026-09-29. Contract:
`COMPILER_DECISIONS_CONTRACT.md`. The third column says whether a
`__merging_*` build in this repo already encodes the rule; "not yet" is a
to-do for the merge layer, not a criticism of the compiler.

Vocabulary: **compiler** = the person who built the audited compilation;
**merge** = the `__merging_*` scripts, the compilation this repo builds.

## A. Provenance and citation

| rule | finding | encoded in the merge? |
|---|---|---|
| A1. Cite the table you copied from, not the paper you first read. | Stephan: 33 cells reproduce a paper other than the cited one (`wrong_citation`); Sensory: 63 (`match_in_other_source`; 40 are a different Heffner-lab paper, 19 explained by the workbook's own Rule 3); DeCasien: 1. | Yes — every merge row carries `Source_item` = the transcribed table id, never a paper-level citation. |
| A2. When you take a value from a secondary compilation, say so; do not re-cite its primary. | DeCasien cites Sherwood et al. 2005 (ref 53) for brain volumes that are the upstream tables that paper declares as its source (`traced_to_upstream_source`, 31 + 5 genus-level). | Yes — `Data_role` (primary/secondary/both) and the compilation-aware dedupe in `__merging_sensory`; volumes merge keys DeCasien rows to `source_publication == DeCasien`. |
| A3. A value the source never printed must be marked as such, with how it was obtained. | DeCasien: 258 cells "obtained from the authors" (`not_verified__value_unpublished_by_source`); Sensory: 21 cells from columns the cited paper does not publish (2 explained by a derivation, 10 with no indexed candidate). | Partly — `value_origin` (published / digitised_from_figure / recomputed / text) exists in the sensory merge; an `author_supplied` origin does not yet. |
| A4. Keep the printed precision; never copy from an unrounded working sheet. | DeCasien: 16 cells carry more decimals than the print (`unrounded_working_value`); Stephan: 8. | Yes — merges read the transcribed CSV, which is the print. |

## B. Transcription errors to test for mechanically

| rule | finding | encoded? |
|---|---|---|
| B1. Row displacement is the commonest error: test every value against the rows above and below. | Sensory 19 (acuity values on the previous species' row), Stephan 8 (an *Avahi* subspecies row), DeCasien 1 (Tarsius MOB = adjacent row). | Audit-side: stage 05 adjacency detector in all three pipelines. Not a merge rule — the merge reads transcriptions the builder already validated. |
| B2. Single-glyph substitutions (3↔8, 2↔7) survive proofreading; compare digit strings, not magnitudes. | DeCasien 3 (`DeCasien_Higham_2019-E001..E003`), Sensory 6, Stephan 1. | Audit-side: `classify_digits` (stage 04). |
| B3. Units and reference pressures slip silently by factors of 1000 or by +74/+100 dB. | Stephan 1 (mm³ ÷ 1000); Sensory 25 `structure_definition_drift` incl. criterion/reference-pressure mismatches; DeCasien audit self-check A (12 BV cells at ×1000). | Yes — `unit_scale` on every source column; sensory `method_basis` in the measure name; `README__after_changing_a_source_TSV.md` §B. |
| B4. Truncation and dropped averaging components are rare but real. | Stephan 1 each (`truncation`, `averaging_component_omitted`). | Audit-side. |
| B5. Spreadsheet artefacts (control characters, text-stored numbers, "<x stated as x") must be stripped before use. | Sensory 9 `format_artefact` (4 control-character cells, one "11.3 and 16" text cell, 4 Rule-4 bounds). | Yes — `Heffner__1998` now carries `low_frequency_limit_qualifier`; the intake decoder in `SensoryData_compiled_mirror.py` strips `_x0001_`. |

## C. Averaging and N

| rule | finding | encoded? |
|---|---|---|
| C1. A reported N that differs from the source's N almost never means a pooled mean; it means the N was relabelled. | DeCasien: of 132 N-disagreement cells, 128 equal one source exactly (`single_source_relabelled_n`); 1 pooled mean found (Saguinus oedipus LGN, mean of 33 and 34 at 0 decimals). Stephan: 26 relabelled, 2 pooled (both also equal a single candidate). | Yes — merges pool only across *distinct primary studies* and record `n_studies`; they never carry a specimen N they did not read. |
| C2. Never average a compilation's value with the primary it copied. | Sensory dedupe report: 11 shared-study rows removed; superseded report 29. | Yes — `__merging_sensory` §"Why compilation-aware resolution". |
| C3. Bilateral = 2 × unilateral or L + R must be declared per column. | DeCasien `recalculation`: 2× printed unilateral (Barger 2014), amygdala = L + R (Barger 2007); Stephan crosswalk notes "Stephan is LEFT only" for the insula columns. | Yes — `_left/_right/_unilateral` suffixes and `bilateral_terms` in `__merging_volumes`. |

## D. Priority between sources

| rule | finding | encoded? |
|---|---|---|
| D1. Stephan et al. 1981 supersedes Stephan et al. 1970 for the same species. | DeCasien: 1970 vs 1981 Tables III/VI/V/II — chosen 1981 in 89/111/104/90 cells vs 1970 in 4/3/8/6 (`newer`); Stephan_primates: 1981 in 144/127/108/96 vs 1970 in 0. | Yes — `stephan_sources` ordering in `__merging_volumes`. |
| D2. Within one lab, the most recent measurement wins. | DeCasien: MacLeod 2003 over Rilling & Insel 1998 (135 vs 18), Sherwood 2004 over Stephan 1970 (98 vs 0); Sensory: Heffner 2010b vs Koay 1998 `mixed` (3/4) — the exception. | Yes — `__merging_cellcounts` §"Within-team resolution: most recent wins"; `__merging_sensory` §5b. |
| D3. But a higher-precision or better-defined earlier value outranks a newer coarser one. | DeCasien: de Sousa 2010 SupTable2 loses to Stephan 1981 III/VI/IX and Frahm 1984 (`older`, 35/20/34/37 vs 2/0/2/2) because de Sousa reprints Stephan at coarser precision; Sensory 9 `older` pairs (5 `newer`). | Yes — `__merging_sensory` §"Precision outranks recency". |
| D4. Where the compiler's choice is `mixed`, the sources measure different things — split the measure, do not pick. | DeCasien 47 `mixed` pairs (mostly MOESM3 rows citing several refs); Sensory 5. | Yes — sensory `method_basis` splits the measure name; volumes `xwalk` keys structure definitions. |

### D′. What the papers themselves declare (source-relationship key, 2026-09-30)

`_keys/source_relationships.csv` (191 paper pairs, 220 rows; 214 drafted from
paper text or the two papers' provenance statements, 6 undeclared) replaces
"newer wins" with the relationship each pair declares: 77 independent
remeasurements, 70 reprints, 33 unrelated overlaps, 18 supersessions, 6
derivations, 5 structure redefinitions, 4 sample extensions, 1 same-specimens-
different-method. Stage 11 now tests every observed choice against it
(`follows_declared_relationship`; exceptions in
`declared_relationship_exceptions.csv`, split into *took the losing value*,
*same measurement at different precision*, *cited the non-primary for an
identical number*).

| rule | finding | encoded? |
|---|---|---|
| D5. "Last paper wins" holds only for `supersedes`; four declared **structure-level** supersessions were missed by the compiler whose pairs cover them (each pair is observed in one pipeline only). | Frahm 1984's Table 1 footnote: its area striata volumes "deviate slightly from … Stephan et al. (1981) because of a broadening of the material and/or re-investigation" — **DeCasien** kept the 1981 values in 68 cells (35 + 33) where they differ. Stephan 1984 revises the 1981 LGN the same way (footnote "+", p. 387) — **Stephan_primates** cites 1981 in 8 cells where both print the same number. Stephan 1987 (Part VII) re-delineates the amygdala over 89 species — **Stephan_primates** kept the 1981 Table XI values in 67 cells that differ. Sherwood 2005 re-averages the Stephan-collection medullae with Zilles specimens — **Stephan_primates** kept Stephan 1981 in 12 cells that differ (DeCasien does not pair these two sources). | Not yet — the merges order `stephan_sources` by paper, not by structure; the key gives the per-structure order. |
| D6. A reprint at finer precision is still a reprint — cite the primary, carry the finer print only if the primary is the same measurement. | MacLeod 2003 Table 1 prints Rilling & Insel's brain volumes to 0.01 cm³ (Rilling to 0.1): 8 DeCasien cells and 54 Stephan_primates cells are the same measurement at different precision. But 60 DeCasien BV cells differ beyond precision (Gorilla 91 367 vs 83 000): the two tables give species means over different specimen subsets, so the `reprints` row needs a narrower scope (flagged in the key's note). | Partly — `Data_role` marks compilations; precision handling is per merge. |
| D7. A compilation that cites the primary but carries the superseded number is the costly case. | DeCasien *Callicebus moloch* (r032) cites Stephan 1981 (ref 51) but its six values are Stephan 1970's (BV 14 434 vs 17 944; Cerebellum 1 287 vs 1 622 …). Total `took_losing_value` cells: DeCasien 272, Stephan_primates 97, Sensory 6. | Audit-side (stage 11); the merge never sees the superseded number because it reads the primary table. |
| D8. When a pair is `independent_remeasurement` (77 pairs — Yerkes MRI vs Stephan histology, GAAP/MGVP vs Zilles), the compiler's pick is a *choice*, not a rule; the merge pools them as distinct studies. | DeCasien picked MacLeod over Rilling & Insel 1998 (135 vs 18) and Sherwood 2004 over Stephan 1970 (98 vs 0) — 100 DeCasien pairs are declared pool/split (`not_a_choice`). | Yes — `n_studies` pooling; `method_basis` split. |

## E. Structure and species keys

| rule | finding | encoded? |
|---|---|---|
| E1. A structure name is not a definition: Zilles & Rehkämper's "Paleocortex" includes the amygdala; their cerebellum excludes the pons. | Stephan 3 (`Zilles_Rehkämper_1988-E001` ×2, `-E002` ×1) + DeCasien 1 `structure_definition_drift`; errata `Zilles_Rehkämper_1988-E001/E002`, `DeCasien_Higham_2019-E005`. | Yes — `printed_indent`/`parent_structure` columns in that item; volumes `xwalk`. |
| E2. Print-era synonyms must be crosswalked, not silently modernised. | DeCasien 226 synonym + 107 genus-level matches (27 distinct pairs recorded, e.g. *Cebuella pygmaea* → *Callithrix pygmaea*, *Lemur albifrons* → *Eulemur fulvus fulvus*); Sensory 22 (workbook binomials for common names / misspellings); Stephan 30. | Yes — `_keys/resolve_species` (SPECIES_NAMING.md v1): `species_printed`, `accepted_name`, `species_basis`, `reidentified`. |
| E3. Record the specimen when the value is one individual's. | DeCasien: 375 cells equal a named specimen record (129 specimen ids, MacLeod 2003 / Bauernfeind 2013), none named by the compiler. | Partly — `__merging_volumes` per-specimen supplement (`unf_spec`); not all merges carry a specimen id column. |
| E4. A printed zero (structure absent in the taxon) is data; leaving it blank loses the information. | DeCasien: 14 AOB = 0 cells (catarrhines, Stephan 1981 Table VI) not carried. | Not yet — decide whether merges carry explicit zeros with a `structure_absent` flag. |

## F. What the compilers left out (coverage inverse)

| rule | finding | encoded? |
|---|---|---|
| F1. Taxon scope is the largest exclusion and is intentional; state it in the metadata. | Stephan_primates: 1 811 `whole_taxon` cells (insectivores, bats from Stephan 1970/1981/1987, Baron 1983/1987); DeCasien 634; Sensory 7. | Yes — each merge README states its taxon scope. |
| F2. Whole columns skipped from a source are a variable-scope decision; list them so the next compiler can pick them up. | Stephan_primates never took the Stephan 1987 amygdaloid sub-nuclei (3 columns × 28), Matano 1986 vestibular complex (16), Frahm 1984 area striata white matter. | Not yet — the coverage inverse is the pick-list. |
| F3. Isolated gaps in a row the compiler otherwise used are the probable accidents — few, and worth filling. | DeCasien 6 (Callicebus moloch ×5 from Stephan 1970, Loris Insula from Bauernfeind); Sensory 1 (Mesocricetus best_frequency, Heffner 2001); Stephan 0. | Not yet — fill through the merge, not the compilation. |
| F4. `taken_from_other_source` is not exclusion; it is D1–D3 in action. | Stephan 1 512, DeCasien 570, Sensory 266 cells. | — |

## Open items the audits raised about their own outputs

- Stephan FINAL: `source_species_label` carries 'Alouatta sp.' on 10 Gorilla + 10 Pan cells and 'Avahi laniger occidentalis' on 8 Gorilla + 8 Pan cells (stage 04/07 labelling defect; values unaffected).
- Sensory FINAL: one `match_in_other_source` cell (*Zalophus californianus* best_sensitivity) has locator/compared_value from the cited table while `actual_source` names Schusterman & Moore 1980 (stage 07 field inconsistency).
- DeCasien: 831 index rows `unassessed` because their source tables never matched a MOESM3 column; the 41 Heffner 2020 Fig. 3 common names in Sensory likewise.
