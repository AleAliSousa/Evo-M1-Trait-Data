# Measurements after the paper-folder build

This is the processing stage between the paper folders / `__Public/comparative-data/` and species-level merges. It separates reported measurements by quantity and source role, preserves the row context needed to interpret them, and gives every retained measurement a persistent number and identifier. It does not aggregate species means or resolve independence by equality of numbers.

Run from the repository root:

```sh
python __measurements/build_measurements.py
```

Requires Python 3 and openpyxl. The public TSVs, registry, paper folders, keys and existing merges are inputs. They are read without modification. `config/` contains deliberate processing decisions, with AnimalTraits as the first explicit adapter. Other tables use their existing definitions, variable catalog and brain-size basis keys. This first inventory is not a claim that every measurement has been fully curated.

The [metadata architecture](../__metadata/README.md) and its
[eight-item source catalog](../__metadata/pilot/README.md) distinguish
registered observation and bibliography items, paper-folder metadata,
project authority, derived indexes, and downstream merge products. The
pilot gate uses catalog routes; this full inventory builder still reads its
legacy input paths directly.
The [single-pipeline pilot proposal](pilot_single_pipeline/README.md)
describes a smaller R path from post-snapshot reports to qualified species
choices and includes a direct-selection feasibility check.

## Outputs and context

- `measurements.sqlite`: the complete relational dataset. `points` holds measurements, `source_rows` holds each successfully parsed source row as JSON, `reference_links` holds value-to-reference links, and `files` records source hashes and coverage. `item_context` captures the registry row, definitions and reference list used in this build; `report_relations` links alternate representations of the same report. `basis_context` captures the brain-size basis keys, including fixation state and olfactory-bulb or CSF boundaries.
- `primary/by_measure/*.csv`: source records classified primary by the available metadata.
- `secondary/by_measure/*.csv`: source records classified secondary. These remain secondary even when the cited source may eventually be identified as primary.
- `review/by_measure/*.csv`: records whose primary/secondary role is unresolved or conflicting.
- `review/column_queue.csv`: work needed to classify quantities, units or methods, including issues in primary and secondary records.
- `other_public_files.csv`: non-TSV directory entries, including documentation and legacy raw files; these are not counted as independent canonical tables.
- `source_tables.csv`: one inventory row per public TSV, including tables that require an adapter.
- `measure_files.csv`: exact measurement labels and their partition filenames.
- `measurement_summary.csv`: counts by provenance, measurement type and basis.

A CSV record joins to `source_rows` on `row_id` for sex, n, specimen/group identifiers, conditions, age, original values and units, comments and other row context. `definition_file` and `basis_evidence` in the database locate the supporting definitions and method evidence. The public TSV numeric text stays in `raw_value` (a paper-folder snapshot remains the authority for the publication's original precision); parsing never destroys it. Non-scalar measured cells stay available with a review reason. Malformed records are preserved verbatim as parsed fields in `source_issues`, exported to `review/source_issues.csv`; these require a table adapter and are not counted as processed measurements.

Numeric cells without adequate definitions are candidates for review, not certified measurements; some will turn out to be metadata. Empty cells are absent observations.

`number` is a persistent sequential data-point number. `point_id` identifies a report in one source table. IDs derive from Item name, unchanged full row content, duplicate occurrence and column. Reordering distinct unchanged rows preserves their IDs; changing row content creates new IDs and leaves prior versions inactive. Identical duplicate rows receive distinct occurrence numbers but cannot acquire specimen identities from this alone. Keep the database when rebuilding to preserve the sequential numbers. The generated SQLite database and exports are local build products; the scripts and config are the reproducible source. Back up the SQLite database to preserve assigned numbers across computers. These identifiers describe reports, not unique animals or independent experiments.

## Three brain filters

The database views and corresponding CSVs in **both** source-role folders are:

| Filter | Included basis |
|---|---|
| `direct_brain_weights` | Explicit direct weighing / fresh or fixed weighed mass |
| `combined_brain_weights` | Direct mass plus mass explicitly estimated from brain volume or endocranial volume |
| `endocranial_volumes` | Actual reported endocranial volume, converted to mm3 when units are known |

Source provenance and measurement method are separate axes. For example, AnimalTraits reports direct weights copied from older sources; these belong in the secondary direct-weight filter. Their presence does not establish that an underlying primary report is already ingested.

Unknown methods are excluded from all method-specific filters. Explicit masses excluding the olfactory bulbs have their own quantity and do not enter the whole-brain weight filters. A mass value in g does not prove weighing. An endocranial-derived mass is not included in the endocranial-volume view unless an actual source volume is also present. Fresh/fixed state, histological boundaries and other details remain in source context and basis evidence; they are not made interchangeable by these broad filters. The combined filter retains reports; it does not average or select one value per species.

Use an additional source-role condition for primary-only analysis, for example:

```sql
SELECT * FROM direct_brain_weights
WHERE data_role = 'primary' AND review_reason = '';
```

Select multiple measurement types with `points.measure`; no broad brain/mass name guess determines biological quantity. Existing brain basis keys can identify brain mass or endocranial volume. Other definitions retain their existing measure classes until explicitly mapped. A review reason means a value needs work before analysis, including when its source role is known.

## Source role and review are different questions

Primary and secondary describe the value's source. A primary report can still
need review because its species, method, unit, or definition is unresolved.
A secondary report can have complete metadata and pass a qualification gate,
while remaining secondary. Mixed values combine original and relayed inputs.

The current inventory uses data_role = review as a placeholder when it
cannot choose a single primary or secondary role from the item and variable
metadata. It is not another kind of source and does not mean secondary.
Also, review_reason may be nonempty even when data_role is primary or
secondary. The pilot in pilot_metadata/ records these axes separately as
source_role, qualification_pass, and blocker_codes; later source
selection is a further decision.

## AnimalTraits processing choices

The adapter retains one measurement for each supplied standardized body mass, brain mass, whole-body metabolic rate, and mass-specific metabolic rate. Body-mass range endpoints are separate statistics. Appended aliases such as `Brain_Mass.mg` and `Source_row`, original-value audit columns and sample sizes remain context rather than becoming additional observations. Project units are g, mg, W, W/g, and mm3. Original brain volumes are preserved as volume representations of the same source observation; they must not be counted as an additional independent animal or experiment alongside the converted mass.

The adapter distinguishes skull filling from direct weighing using original methods and units. It never upgrades an unspecified mass method. AnimalTraits' already-adjusted metabolic values retain their original temperature/RQ and method context; they are not reconverted. Its supplied bibliography is joined exactly; reference identity is not proof that a cited work is primary.

## Primary and secondary source lineage

Primary/secondary assignments use explicit definitions and registry roles. A conflict goes to review. `both`, mixed and conditional roles require further row/cell decisions. AnimalTraits has an explicit secondary override because its literature-compilation status is established while the live registry update is pending.

`source_reference_id` identifies an exactly supplied cited work. `primary_reference_id` remains blank until primary lineage is explicitly resolved. A cited review, book or secondary compilation must not be promoted merely because its bibliography entry is available. Compound citation cells are retained in row context until a curated reference adapter can split the links without splitting the reported value.

Relationships between reports belong in `report_relations` (the AnimalTraits alternate-representation links are already generated): reproduced from, component of average, derived from volume, corrected by, or possible same specimen. A secondary report may check a primary report, preserve a compiler correction, or point to a missing primary source. Its evidence must not count as another independent primary measurement. When an older primary source is obtained, build that paper in its own folder, ingest it here and then resolve its links.

## Remaining curation

The inventory accounts for every current TSV, including blocked or partially processed tables; mapping completion is recorded per column and table. Existing metadata vary in quality. Unknown units are not guessed, arbitrary methods are not inferred from mass units, and legacy nonstandard dictionaries require adapters. Many existing definitions have roles or quantities that need review. The next curation units are the rows of `review/column_queue.csv`, followed by explicit source lineage and specimen/collection overlap. Existing species-level merges remain separate downstream consumers while this stage is developed.

An interrupted initial import can be continued with `--resume`, which reuses tables with unchanged SHA-256 hashes. Use a normal full build after changing mappings, keys, definitions or processing rules. Do not run two builds against the same database simultaneously.

Curated primary↔secondary relationships can be added to `config/report_links.csv` using the two stable point IDs, a relation, evidence and reviewer. The builder validates that both active reports exist and regenerates these links without changing either source value or promoting a secondary report. This is where a compiler correction or other special case can inform the interpretation of a primary record. New or unresolved primary references still require explicit source-lineage curation.

The command builds and indexes SQLite in local temporary storage, then copies the completed database and CSVs into this folder. This avoids database locking and index-write errors observed when SQLite writes directly inside OneDrive. Failed runs do not replace the last completed dataset. `--exports-only` regenerates filters and partitions from the saved inventory.

Current inventory (rebuilt 2026-11-14): 1,017 canonical TSVs accounted for;
1,013 fully parsed, three partially parsed, one blocked by header structure.
The 102 malformed rows are retained in review/source_issues.csv. There are
2,330,859 reported/candidate cells, including unresolved candidates that
can turn out to be metadata; this is not a count of independent biological
observations. The ManyPrimates predictor item now contributes 509 values
across 13 compiled predictors. AnimalTraits contributes 8,935 report
representations/statistics, with 1,250 explicit links between original-volume
and standardized-mass representations.
