# Reference and definition tables in the pilot

This audit distinguishes catalog registration from the operational
`run_pilot.R` route, which starts from the already-built measurement
inventory. **Direct use** means the qualification
or choice script opens the file and uses its rows; the catalog also checks
that routed files exist, but a catalog route alone does not apply their data.

| Paper | Metadata files and route | How they are made | Public registry |
| --- | --- | --- | --- |
| ManyPrimates | `ManyPrimates__2022_STMperformance_definitions.csv` and `ManyPrimates__2022_speciespredictors_definitions.csv` are read for the STM measure/method and all 13 predictor definitions. Predictor Source and Comments are carried from the frozen workbook into the value TSV. | Definitions are reviewed project tables; Source/Comments are emitted with values by the item builder. | Two observation items registered; definitions are supporting. |
| Mink | `Mink_etal_1981_TABLE1_definitions.csv` and `Mink_etal_1981_TABLE1_references.csv` are read. The reference lookup resolves the *measure-specific* printed keys. `Mink_etal_1981_REFERENCES_definitions.csv` is catalogued but not read by this gate. Errata and the proposed species key are catalogued, not adopted as authority. | `Mink_etal_1981_TABLE1.R` generates the 54-key lookup from its extracted cell keys and the sibling `Mink_etal_1981_REFERENCES.csv`, which is built from its own frozen bibliography snapshot. Definitions, errata, and proposed taxon mappings are reviewed project tables. | TABLE1 and REFERENCES are separate registered items; the derived lookup and definitions are supporting. |
| Boddy | `Boddy_etal_2012_TableS1_definitions.csv` and `Boddy_etal_2012_brainbodydatabasev2.txt_definitions.csv` are read. Table S1 `Reference`/`Notes` and raw database `Source` are carried with the values; the gate also reads the reviewed row-basis table in `__metadata/curation`. | Item builders read the supplied frozen supplements. Definitions and row-basis judgments are maintained separately. | Two observation items registered; definitions and curation table are supporting. |
| Falcone | `Falcone_etal_2019_TABLE1_definitions.csv` and `Falcone_etal_2019_TABLE2_definitions.csv` are read from `reference_tables/`. | Reviewed definitions cite printed table legends and Methods. The item builders do not regenerate them. | Two observation items registered; definitions are supporting. |
| Buchsbaum | `Buchsbaum_etal_1989_TableI_definitions.csv` is read for measure, region, unit, role, and arm method. The long value TSV already carries region, arm, *n*, SD, and printed unit. Errata and the proposed species key are catalogued but not used as approved mappings. The separate `Buchsbaum_etal_1989_Text_definitions.csv` is outside this Table I scope. | The item builder derives the long rows from the frozen Table I snapshot. Definitions and proposed keys are reviewed project tables, not build outputs. | Table I registered; sidecars supporting. |
| Kaufman | `reference_tables/Kaufman__2004_definitions.csv` and `reference_tables/Kaufman__2004_TablesA1-A14_references.csv` are read. Table A3's value TSV carries per-row Reference, *n*, SD, Mode, and Anesthesia. The lookup resolves the Buchsbaum citation; `Present Study` is classified as original at the **row** level. | The item builder emits values/context from the frozen snapshot plus its correction overlay. The shared citation lookup and definitions are reviewed project tables; the item builder does not regenerate the lookup. | Table A3 registered; definitions and lookup supporting. |
| Heffner & Heffner 2010b | The gate reads the ten-column definitions and resolves `ref_freq_key` and `ref_bm_length_keys` separately through the canonical `references.csv` lookup. The reviewed `reference_columns.csv` declaration and generated source-match tables document that variable scope. Functional interaural distance has no per-row citation and remains held. The item retains the PDF's printed `Tursiops truncates` separately from the normalized name; the discrepant taxon remains held. All three measures are secondary reports, including Tursiops. | The item builder reads its printed-layout snapshot and emits a species-row CSV and TSV plus source-match outputs. The printed-letter footnote table and bibliography lookup are supporting source metadata. | Table 1 registered; definitions, footnotes, lookup, scope declaration, and generated matches supporting. |
| Bahney & von Bartheld 2018 | The gate reads all four ten-column definitions. Tables 3 and 4 join the row's lowercase `references` token to their bibliography lookups; reviewed `reference_columns.csv` declarations set `applies_to=row_overall`. The cited work is retained as row context, while source attribution to brain mass versus ratio stays unresolved. The gate interprets `data_role` per measured cell: an own-study ratio does not make its estimated brain mass an original measurement. | Four item builders read frozen table snapshots. Tables 1 and 2 report original spinal-cord counts, percentages, and ratios with IF or stereology context. Tables 3 and 4 mix two own-study spinal-cord rows with compiled rows. | Four observation items registered; definitions, Table 3/4 lookups, and scope declarations supporting. |
| Fobbs et al. 2011 | The gate reads Table S1a definitions for the two specimen body-length fields. It holds those values at specimen grain because the definition calls length `Measure=count`, acquisition method is not resolved, and species pooling would lose specimen context. S2 and S5a section-thickness definitions also say `Measure=count` despite being thicknesses. Definitions for S1b, S2, S3, S4, S5a, and S5b and the S2/S4/S5b taxa lookups are catalogued, but the gate does not treat their section, slide, and box fields as species brain traits. | Each published Word supplement has a frozen XLSX snapshot made by a Python extractor and an item R builder. The ten-column definitions are reviewed project tables. S2/S4/S5b builders use their item-scoped taxa lookup; the resulting `Species_binomial` is an item annotation, not a published name or active `_keys` authority. The shared specimen crosswalk is a separate curated resource; `source_row` is assigned after printed-layout filtering. | Seven `specimen_catalog` items registered; definitions and three taxa lookups supporting. |
| Kennedy et al. 1978 | The gate reads Table and Text definitions plus `Kennedy_etal_1978_Text_references.csv`. Table rows are primary regional group means; Text has both primary and secondary rows, and its per-row `data_role` and `value_status` take precedence over a generic definition role. Numbered ref 20 identifies Schmidt 1945; ref 22 is a review chapter whose underlying human primary remains unresolved. The proposed species key and printed-29 erratum are catalogued, not adopted by the gate. | The item builders parse two frozen PDF transcriptions. The Table snapshot preserves printed layout; the Text snapshot has one constructed row per printed value with page and passage. The reviewed lookup resolves Text citations; a separate cross-item check records the printed-29 versus recomputed-30.04 discrepancy. | Table and Text observation items registered; definitions, citation lookup, proposed key, erratum, and check supporting. |

The catalog stores every routed file as an artifact and identifies its field,
locator, and checkpoint in `field_routes.csv`. The original six-paper gate
read definitions for **nine scoped observation items**, plus the Mink and
Kaufman citation lookups. The eight-paper gate added Heffner's definitions
and per-variable reference lookup and Bahney's four definitions, Table 3/4
reference lookups, and row-level citation-scope declarations. The ten-paper
gate also reads Fobbs S1a definitions and Kennedy Table/Text definitions and
Text references. It does not read every file merely because it is under
`reference_tables/`. The catalog validates the Mink REFERENCES item, but
the gate consumes its derived Table 1 lookup rather than reopening the
bibliography item. Source role, taxon, method, and qualification remain
separate per-point decisions; an item-level definition such as Kaufman's
`secondary` is not a verdict on its `Present Study` rows.

## Parallel metadata contract to adopt

The original six-paper run **used** these tables; it did not co-generate all
of them with the values. The [dataset build guide](../../_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md)
requires a frozen source, one item builder that reads it, a public TSV, and
ten-column definitions. Its §8 calls item-scoped reference lists
`ref_key, cited_in_column, citation, note` and asks that contextual facts
outside the printed table remain bindable. The
[source-match convention](../../_tools/dataset_builder/SOURCE_MATCH_CONVENTION.md)
adds a generated `(source row, variable, cited key)` table and an issues table;
it recommends running `build_source_match()` after the item CSV is written.
None of the original six-paper item builders invokes that tool.

The expanded gate deliberately holds metadata claims that a paper-local
table cannot certify. Heffner's interaural-distance values lack a per-value
source and original acquisition method. Bahney Tables 3 and 4 supply a
row-level citation, so copied brain masses and ratios need separate original
source checks; the own-study rows' estimated brain masses are not primary
brain-mass measurements. In Bahney Tables 1 and 2, `cells_million` has a
definition code `O.n` that does not yet identify the proposed total-cell
concept, and GNR rows use the definition code `O.p.N` for a non-neuron ratio;
the gate holds those mappings rather than treating the codes as verified.
Table 2's human IF non-neuronal percentage, neuronal percentage, and nNNR
combine IF total counts with stereology-derived cell fractions because the
human fixed-tissue neuron antibody was unreliable; the gate records this
cross-method origin and holds these cells pending component linkage.

Fobbs makes the table-type boundary explicit: a registered museum catalog
can contain numeric fields without being a species trait dataset. Table S1a
lengths are real reported specimen values, but their incorrect `Measure=count`
definitions and unresolved measurement/pooling context keep them held. The
remaining six Fobbs tables provide catalog and preparation metadata. Kennedy
makes the source-role boundary explicit: Text's `data_role` must be checked
per row, repeated values must not become independent observations, and cited
`monkey` values must retain the taxonomic scope of the cited Schmidt source
rather than inherit Kennedy's rhesus scope.

For this pilot's next build contract:

1. Emit **verbatim reported context with each value** from the same frozen
   source: printed species/region, unit, statistic, *n*, SD, citation key,
   footnote, method label, and exact source row/column. The original six paper builders
   already do much of this; retain these fields rather than retyping them in
   the gate.
2. Generate the item-scoped source match **in the same item build** after
   writing the CSV. Declare which citation column supports which measure in
   a reviewed `<Item>_reference_columns.csv` where the source is ambiguous.
   Mink's brain and oxygen columns need distinct declarations; do not let a
   row-level default attribute both to one citation. A shared Kaufman
   bibliography can feed a generated Table A3-specific projection, while
   the reviewed source IDs and source-type decisions remain separate.
3. Keep definitions, taxon resolutions, and role overrides as **reviewed
   metadata**, with source locators and status. Validate that every scoped
   measure has exactly one applicable definition, every reported citation
   key resolves or enters an issues table, and every derived source match
   refers to an existing item row and column. Never infer that a citation
   or matching number alone establishes an original measurement.

The project registry should describe a **public item with its own reusable
rows**, as it does for Mink REFERENCES. Definitions, item-scoped joins,
errata, and proposed keys are supporting artifacts in the typed catalog;
registering each as another public item would duplicate the observation
item's identity. If the Kaufman bibliography is extracted as a standalone
public reference list from the dissertation, that list could be registered
once; the curated citation-to-source lookup would still be a supporting
table derived from it.
