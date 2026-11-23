# Candidate vocabulary links: brain cells & molecules, brain metabolism & blood flow

Mapped on 2026-11-23. Every row has `mapping_status = candidate`. Nothing here has been reviewed by a curator and nothing licenses pooling.

## Files

- [vocabulary_links_cells_molecules_metabolism.csv]({{artifact:c1e58c7f-aee5-4291-b9f4-a089e7d014e9}}): the mapping table, 207 rows, one per project term x ontology term.
- [vocabulary_term_labels_cells_molecules_metabolism.csv]({{artifact:07c9afde-59c6-49ba-a54c-e03b2607d3c1}}): which variable labels use each project term (2064 term-label pairs).
- [build_vocabulary_links_cells_molecules_metabolism.py]({{artifact:9f8117a3-ac66-4224-b9d5-dbfe44a7d8de}}): builds both tables from `_keys/variable_definitions.csv`, the query list and the cache.
- [ols_search_queries.csv]({{artifact:942fed78-0e6a-4944-8fe5-e90f1082493d}}): the 261 OLS searches that were run.
- [ols_cache_cells_molecules_metabolism.zip]({{artifact:b807b950-e17e-43ba-bc77-c8fe06420f49}}): raw OLS4 responses (search, term-by-id, ontology metadata) plus `ols_search_log.csv` (ids returned per search). Unzip next to the script to rebuild offline.

## What was mapped

Slice: the 666 variable labels whose domain is `brain cells & molecules` or `brain metabolism & blood flow`. All 666 labels reach at least one specific (non-class) term.

| term_kind | terms |
|---|---|
| cell_type | 26 |
| measure_class | 67 |
| molecule | 18 |
| process | 7 |

`measure_class` holds the five measure classes and 62 measured quantities taken from the `Measure` column. Structure prefixes were removed and spelling variants merged (for example `Amygdala_basal_neuron_number` -> `neuron_number`, `ILA_linear_density` -> `ila_linear_density`); the script's `norm_measure` function is the exact rule. Cell parts that a measure refers to (soma, dendrite, dendritic spine, synapse, postsynaptic density, mitochondrion, astrocyte process) are given as GO cellular-component rows on the measure term, relation `related`, because the allowed term kinds have no cell-part kind.

Of 118 project terms, 111 have at least one link and 7 have none: `G.p.mm3.Stereology`, `HRP (horseradish peroxidase, method tag)`, `I.p.mg`, `O.p.mg`, `direct_LGN_input`, `fork_cell`, `glia_density`.

## Counts

By relation (rows):

| relation | rows |
|---|---|
| broad | 97 |
| related | 49 |
| close | 23 |
| exact | 18 |
| none | 17 |
| narrow | 3 |

By confidence (rows):

| confidence | rows |
|---|---|
| high | 119 |
| medium | 76 |
| low | 12 |

For `none` rows, confidence means confidence that no adequate term exists in the vocabulary searched.

By term kind and relation:

| term_kind | broad | close | exact | narrow | none | related |
|---|---|---|---|---|---|---|
| cell_type | 12 | 8 | 6 | 1 | 1 | 3 |
| measure_class | 72 | 7 | 0 | 2 | 15 | 33 |
| molecule | 3 | 6 | 12 | 0 | 1 | 3 |
| process | 10 | 2 | 0 | 0 | 0 | 10 |

By ontology and relation:

| ontology | broad | close | exact | narrow | none | related |
|---|---|---|---|---|---|---|
| chebi | 2 | 2 | 2 | 0 | 1 | 0 |
| cl | 12 | 8 | 6 | 1 | 1 | 2 |
| go | 0 | 1 | 0 | 0 | 0 | 35 |
| oba | 25 | 11 | 0 | 2 | 0 | 9 |
| pato | 57 | 0 | 0 | 0 | 15 | 2 |
| pr | 1 | 1 | 10 | 0 | 0 | 1 |

Ontology versions as reported by OLS:

| ontology | ontology_version |
|---|---|
| chebi | 257 |
| cl | 2026-11-13 |
| go | 2026-07-26 |
| oba | 2026-10-10 |
| pato | 2026-10-01 |
| pr | 73.1 |

## How to read `relation`

`broad` means the ontology term is broader than the project term; `narrow` means it is narrower. `related` is used where the project term is a measurement, rate or marker of the ontology entity rather than the entity itself. `exact` appears only on 18 rows, all cell types or molecules; no measured quantity or process is `exact`.

## The ten least certain choices

1. `Cat301` -> PR:000003606 *aggrecan core protein* (related, low). The aggrecan identity of the Cat-301 antigen is background knowledge from the literature, not in the project glossary. Confirm or delete.
2. `LYinj (Lucifer Yellow, method tag)` -> CHEBI:52106 *lucifer yellow carbohydrazide dye* (close, low). The project says only 'Lucifer-Yellow injection'. ChEBI has several Lucifer yellow entries; the carbohydrazide salt was chosen without source evidence.
3. `meynert` -> CL:2000056 *Meynert cell* (close, medium). Label matches, but the definition OLS returns is generic and does not mention giant size or V1.
4. `subpial interlaminar astrocyte` -> CL:4042011 *subpial interlaminar astrocyte* (close, medium). CL puts the soma in the upper first layer; cell_type_definitions.csv says layer II; the glossary says layer I for all ILA. The project files disagree with each other.
5. `corticospinal` -> CL:4023041 *L5 extratelencephalic projecting glutamatergic cortical neuron* (broad, medium). A projection-defined project term mapped to a transcriptomically defined CL class. The second row (upper motor neuron, related, low) is weaker still.
6. `NPNF` -> PR:000011118 *neurofilament heavy polypeptide* (broad, medium). The glossary names the epitope and antibody (SMI-32), not the subunit. Heavy-subunit assignment is background knowledge.
7. `astrocyte (GFAP-immunoreactive)` -> CL:4042009 *interlaminar astrocyte* (related, low). Rests on one source note about the layer I label; does not apply to the white-matter labels that share the term.
8. `cellular_composition` -> OBA:2045379 *prefrontal cortex cell composition* (narrow, low). The only OBA cell-composition trait found is prefrontal-specific and its definition is ambiguous. May be better dropped.
9. `cells (total: neurons plus non-neuronal cells)` -> CL:0002319 *neural cell* (close, medium). Depends on whether brain endothelial cells count as 'part of the nervous system' in CL.
10. `ila_complexity` -> PATO:0002009 *branchiness* (related, low). A composite Neurolucida index mapped to a generic shape quality; PATO 'complexity' was avoided because its own definition says it is to be obsoleted.

## What a reviewer should look at first

1. The 18 `exact` rows, because an error there does the most damage. `horizontal`, `inverted` and `neurogliaform` are `exact` on a shared name only: the project definition is the name, with no geometry stated.
2. `other (non-neuronal) cells` -> glial cell is `narrow`. The isotropic-fractionator "other cells" include endothelial cells; this row must not be read as "O = glia".
3. `gigantopyramidal` -> Betz cell is `close`, not `exact`. The project pools Jacobs 2018 'gigantopyramidal' with Sherwood 2003 'betz'; decide whether that pooling is intended to mean Betz cells in every species.
4. The subpial interlaminar astrocyte soma position: `_keys/glossary.csv` (layer I) and `__merging_cell_morphology/cell_type_definitions.csv` (layer II) disagree.
5. The number-density gap. Of the 15 PATO `none` rows, 14 are densities (cells/mg, cells/mm3, per mm2, per mm, spines/um) and 1 is the connectivity label: PATO's density qualities are mass-based and OBA has no neuron- or glia-density trait. If densities matter, another vocabulary is needed.
6. Labels that look misfiled, found while mapping (not changed): `V1_L4A_direct_LGN_input_Preuss2002Fig11` is a connectivity character under `cellular_composition`; the two `PFC_area9_GLUT1_vessel_*` labels are vessel morphometry under `cerebral_metabolic_rate`; `ven_count`, `ven_pct`, `fork_pct`, `GLR` and `HSD.um` are counts, percentages and spacing under `cellular_morphology`.
7. Statements marked "background knowledge" in `reason` (Cat-301/aggrecan, SMI-32/heavy subunit, NeuN in the isotropic fractionator). They come from general knowledge of the literature, not from the project files, and were not checked against a source in this session.

## Method

1. Read the project definitions: the `definition` column for one representative label per distinct measure and cell type (about 190 groups, not all 666 labels one by one; long definitions were read to 330-520 characters), all of `cell_type_definitions.csv`, `cell_morphology_definitions.csv`, histology `cell_classes.csv` and `measures.csv`, and the glossary entries for the codes in the slice. The per-merge READMEs were read in part (cell morphology, GLI, fossil brain glucose, cerebral metabolic rate); the isotropic-fractionator README was only searched for 'NeuN'.
2. Searched OLS4 (`/api/search`, top 3-8 hits per query) in cl, chebi, pr, go, oba and pato.
3. Re-fetched every chosen identifier by id (`/api/ontologies/<ont>/terms?obo_id=`), read its definition and synonyms, and stored the label OLS returned. The script refuses an identifier that no logged search returned, and refuses obsolete terms. A read-back check found 0 label mismatches between the table and the cached by-id responses.

## Not done

- Structures (another agent's slice).
- Method tags that are not molecules (`golgi`, `nissl_count`, `nissl_perikaryal`, `stereology`, `fractionator`), antibodies (SMI-32, HM-2, Cat-301 antibody), and molecules named only inside definitions (2-deoxyglucose, FDG tracers; NeuN) were not given rows.
- Denominator populations ("layer V neurons", "CNS neurons") were not made separate terms.
- No vocabulary outside cl, chebi, pr, go, oba, pato was searched (for example EFO, CMO, VT, NCIT, MeSH), so "no adequate term" means none in these six.
- One oddity seen and avoided: the definition OLS returns for CL *fibrous astrocyte* reads like the interlaminar astrocyte definition, so that class was not used for the white-matter GFAP labels.
