# Ten-paper single-pipeline pilot

## Decision

Use **one R qualification and source-choice path after the frozen snapshots**
for ManyPrimates, Mink, Boddy, Falcone, Buchsbaum, Kaufman, Heffner & Heffner
2010b, Bahney & von Bartheld 2018, Fobbs et al. 2011, and Kennedy et al.
1978. Their public
TSVs remain the outward-facing item outputs. The R path takes reported values and their
metadata from those items, qualifies every point, and generates source-choice
decisions and species-trait views directly. It does not consume a
`__merging_*` table.

This is a ten-paper pilot, not a switch of the production merges. The
accompanying `test_direct_selection.R` uses
reports prepared by the existing pilot gate's `--qualification-only` mode.
That mode stops before the old merge audits. Together they test a route from
the measurement inventory through qualification to selection with no
`__merging_*` input, including the Buchsbaum/Kaufman primary/secondary relay
inside the same source-choice output.
The upstream paper builders have not yet been refactored to emit the
proposed long reports, and the current inventory still scans all registered
items rather than just these ten papers.

The [provenance map](../pilot_metadata/PROVENANCE_MAP.md) draws all seven
Fobbs specimen catalogs and Kennedy's Table and Text as separate source
paths before the inventory, metadata gate, and selector. Fobbs catalog
metadata is kept distinct from species traits; Kennedy Text's cited and
original values are decided at row level.
In the relational `point_reference` table, a primary Boddy row's descriptive
`Sherwood data/this study` text remains report context and does not become an
upstream work link. Kennedy's two citations through the Sokoloff review are
typed `intermediate_review`, separately from an original source link.

~~~mermaid
flowchart LR
  subgraph P["Ten paper folders"]
    S["Paper/supplement<br/>and frozen snapshot"] --> B["Item builder"]
    B --> T["Public item TSV"]
    D["Definitions, footnotes, reference tables<br/>and citation-scope declarations"]
  F["pipeline_files.csv + file_dependencies.csv<br/>same file contract in each folder"]
  end
  T --> I["Measurement inventory<br/>temporary pilot input"]
  D --> M["Typed metadata catalog<br/>and item-column variable map"]
  F --> M
  R["Item registry"] --> M
  A["Shared taxon and method decisions"] --> M
  I --> G["Ten-paper R metadata gate"]
  M --> G
  G --> E["Point assertion + evidence audit<br/>with locator precision"]
  M --> E
  G --> Q["Held reports with reasons"]
  G --> C["Qualified reports + point links"]
  C --> X["R source choice"]
  X --> O["One SQLite: reports, references,<br/>lineage, candidates, decisions"]
~~~

The intended simplification is **one interpretation of each source cell**.
Today `build_measurements.py` reads all registered public TSVs into a large
inventory, `pilot_metadata/build_pilot.R` interprets a selected column map again, and
brain-mass or behavior merges independently read TSVs or trait workbooks
and choose values. The legacy default pilot builder also reads three
`__merging_*` outputs for audits; the no-merge entrypoint stops before
that code. The future build should keep the snapshot and public TSV
contracts while emitting reports, qualification, and selection from one R
path. This pilot verifies the metadata and choice rules but still depends
on the large existing inventory. The typed catalog remains a provenance
audit; the operational build needs a compact variable map and reviewed
decisions.

## Post-snapshot contract

Each paper builder should emit one generated **long report row per measured
cell**, with `item_id`, a stable cleaned `source_row`, the direct
`snapshot_locator` (printed section and row or passage), `source_column`,
`point_id`, raw value and unit, printed species, reported citation key or
string, source comment, reported method, and any stated calculation. A
cleaned row number cannot by itself locate a source row after headings and
blank rows have been filtered, as in the Fobbs Word supplements. The builder
should emit an explicit cleaned-row-to-snapshot map and an `issues`
table for ambiguous source cells at the same time. Raw snapshots stay
frozen, and the registered TSV remains reproducible from the same script.
The long rows are generated views, not another manually edited source.

The shared map has one row per included item-column. It supplies the
`trait_id`, definition, anatomy or behavior target, value type, expected
unit, statistic, basis, and the names of any citation/comment columns.
Project-level decisions stay in reviewed tables keyed to exact source rows
or point IDs. Thus missing metadata becomes a visible issue, not a later
guess from a column name or a merge output.

| Paper | Information to prepare in its item build | Held until reviewed |
| --- | --- | --- |
| ManyPrimates | All 13 predictor columns; each predictor’s adjacent Source and Comments; STM trial aggregation method and sample-size scope. | Unstated predictor units and original protocols; life expectancy’s missing per-row source; values copied from another species/group. |
| Mink | The numbered citation keys **for each measure column**, joined to the registered REFERENCES item; model predictions and extrapolations marked as derivations. | Proposed species crosswalk and original methods of copied values. REFERENCES contributes bibliography rows, not measurements. |
| Boddy | Table S1 Reference/Notes joined to the audited row-basis table by exact source row and column; original and converted quantities kept separate. | Raw database methods; mixed means without component lineage; original ECV acquisition methods. |
| Falcone | Top-level definitions; categorical ILA presence and numeric morphometry retained as different value types; printed and snapshot names both kept. | The Table 1/Table 2 `kandti` genus disagreement and other unresolved taxa. |
| Buchsbaum | Table I awake, NREM, and REM arm, region, *n*, mean, SD, FDG-PET method, and printed unit; distinguish measured regions from printed section/grand means. | Printed aggregate rows cannot be pooled as independent regions. |
| Kaufman | Table A3's glucose, oxygen, and blood-flow means; *n* and SD as report metadata; per-row citation resolved through its reference table. | Most literature rows need their original protocols and taxon resolution. `Present Study` rows are primary reports within this otherwise largely secondary table. |
| Heffner & Heffner 2010b | Table 1 has 21 species rows and three quantities. A hearing-limit superscript applies only to the hearing cell; a separate key applies only to basilar-membrane length. Preserve footnotes and compound cited works. | Functional interaural distance has no per-row citation. The original hearing and anatomical methods require cited-paper review; the printed dolphin name differs from the normalized item name. |
| Bahney & von Bartheld 2018 | Tables 1–2 contain original method × spinal-cord-segment summaries. Tables 3–4 combine literature rows with the paper's own ratio rows; definitions and bibliography lookups remain in `reference_tables`. Their row citation is declared `row_overall`. | A Table 3/4 own-study row does not make its parenthesized estimated brain mass a primary weighing. Table 4's brain-mass unit is inferred from Table 3; literature methods and source-to-variable attribution need review. Repeated masses and min/max representations are not independent observations. |
| Fobbs et al. 2011 | Seven registered specimen catalogs each have a published Word supplement, frozen XLSX snapshot, R builder, CSV/TSV, and item definitions. S2, S4, and S5b builders also consume item-scoped taxon lookups. S1a's two body-length columns enter the gate at specimen grain; `specimen_catalog_screen.csv` accounts for all other numeric catalog columns. | All 802 S1a body-length points are held: the definition mislabels length as `Measure=count`, and acquisition and pooling need review. Its generic primary inventory role becomes unresolved in the gate because the original measurer is unproven. Section, slide, and box counts are preparation or collection metadata. |
| Kennedy et al. 1978 | Separate registered Table and Text items are built from frozen PDF transcriptions. Table has 39 regional group means; Text has ten printed values. Definitions describe units and observation grain; Text has an item-scoped lookup for numbered refs 20 and 22. | All 39 Table points qualify as primary regional glucose-use group means. Text's per-row `data_role` and `value_status` separate own, cited, and repeated values; all ten are held. Ref 22 is a review chapter with unresolved original source, and cited `monkey` values must not inherit Kennedy's rhesus taxon. |

## Minimal output model

The pilot SQLite holds `item_variable` (the map), `point_metadata` (one
source cell and all point metadata), `reference`/`point_reference`, `lineage`
(copied from, calculated from, component of), `selection_decision`, and
`selection_candidate`. `point_metadata` has separate `source_role` values
of primary, secondary, mixed, or unresolved and an explicit
`qualification_pass` flag. It
retains verbatim and standardized values/names, original acquisition
method, transformation method, and evidence locators. The provisional
report-choice output is a view/export of `selection_decision` rows, with selected or
contributing point IDs. R can build and query SQLite through DBI/RSQLite;
SQL does not have to be the authoring language.

The six stops are: **extract and define → trace cited work → verify original
method and any transformation → resolve taxon → qualify → choose source**.
Only qualified points enter choice. A singleton is a *provisional pilot
choice*, because another paper outside the pilot may supply the same
observation. On overlap, prefer a primary report only when quantity, basis,
statistic, taxon, and shared lineage are established. Independent reports
require an explicit aggregation rule; a team mean cannot become primary
because one of its inputs is primary. Held points never enter the selected
view, but remain queryable with blocker codes.

## Retained Buchsbaum/Kaufman source-choice test

Buchsbaum et al. 1989 Table I reports original FDG-PET measurements of
thalamic glucose metabolism in awake human volunteers (*n* = 10, mean 24.3,
SD 7.2 µmol/100 g/min). Kaufman 2004 Table A3 cites Buchsbaum, labels the
study `none` for anesthesia, and repeats the awake arm's region, sample
size, mean, and SD. These values were checked against Buchsbaum's paper
(journal p. 1354; PDF p. 6) and Kaufman's dissertation (PDF p. 125).

The qualification gate puts the original and relay in the same
`(accepted_species, trait_id, anatomy, basis, statistic, unit)` group. Its
confirmed `reprinted_compilation_report` link runs from the Buchsbaum point
to the Kaufman point. The direct selector checks that both qualify and
that their value, *n*, and SD agree before choosing Buchsbaum in the main
`selection_decisions.csv`; Kaufman remains a linked candidate. This is a
source choice for one duplicated report, not a final species mean.
Buchsbaum's printed human-volunteer label and Kaufman's genus `Homo` are
preserved with the source-backed taxon resolution for this exact cited row.

The **16 November 2026 ten-paper run** has **5,285 report points**:
**699 qualified**, **4,586 held**, and **67 supported point links**.
Fobbs S1a contributes 802 held specimen body-length points; the other six
Fobbs catalog items are screened as specimen or preparation metadata. The
screen covers 2,303 source rows and 4,252 numeric inventory values: 802
scoped lengths and 3,450 context-only values.
Kennedy Table contributes 39 qualified primary regional group means;
Kennedy Text contributes ten held primary/secondary/repeated text values.
The selector forms **698 comparison groups**: 697 singletons and the
verified Buchsbaum/Kaufman relay choice, with no unresolved group and no
`__merging_*` input.

The following **16 November 2026 eight-paper run is historical**. It had
**4,434 report points**,
**660 qualified**, **3,774 held**, and **63 supported point links**.
Heffner adds 63 held secondary reports; Bahney adds 382 points, of which
30 qualify (24 from Table 1 and six from Table 2). Tables 3–4 retain all
310 scoped points for source, method, context, or anatomy review. The
direct selector forms **659 comparison groups**: 658 singletons and the
verified Buchsbaum/Kaufman relay choice. No group has an unresolved choice.

The following numbers are the **15 November 2026 six-paper baseline**, before
Heffner, Bahney, Fobbs, and Kennedy were added. They are historical, not
current pilot totals.
That run has **3,989 report points**, **630 qualified**,
**3,359 held**, and **63 supported point links**. The qualified reports
occupy **629 comparison groups**: 628 provisional singletons and the one
Buchsbaum/Kaufman overlap. Buchsbaum contributes 36 qualified measured
region-by-arm means; its 12 printed aggregate rows are held from selection.
Kaufman Table A3 contributes one qualified, traced literature relay; its
other 139 measured means are held for source, method, or taxon review.

~~~mermaid
flowchart LR
  B["Buchsbaum 1989 Table I<br/>original awake thalamus: 24.3 ± 7.2, n=10"] --> BT["Primary report row + definition"]
  K["Kaufman 2004 Table A3<br/>literature row: 24.3 ± 7.2, n=10"] --> KT["Secondary report row + citation lookup"]
  BT --> C["Verify same measure, region, unit,<br/>n, mean, SD, and source link"]
  KT --> C
  C --> D["One retained selection decision:<br/>choose Buchsbaum; retain Kaufman relay"]
~~~

Both items have registry rows. Kaufman's cached `Public TSV match` field in
`__ReadMe.xlsx` currently says `notfound` even though the matching public
TSV exists. The pilot reads that TSV directly; the registry export link
needs synchronization.

The prior Stephan 1981 → Boddy brain-mass comparison is not a clean fixture
for primary preference. Stephan's team improved its collection across
publications, and the sample behind this particular value is unclear.
That report's relationship to earlier and later team publications needs
collection-lineage review before source selection.

Run the ten-paper no-merge-input path from the repository root after the
measurement inventory has been built:

```sh
Rscript __measurements/pilot_single_pipeline/run_pilot.R
```

The entrypoint builds the 39-item metadata catalog, derives metadata routes
from the common `pipeline_files.csv` inventory in every paper folder, runs
the 17-item measurement qualification scope and assertion audit, makes direct
source choices, checks the results, and finally validates the combined
file-level registry and declared dependencies.
It stops on the first failure and never invokes the legacy merge-dependent
audit.

It writes `pilot_single_pipeline.sqlite`, a provisional `species_traits.csv`,
`selection_decisions.csv`, `held_reports.csv`, and `primary_relay_check.csv`
in this directory. `selection_decisions.csv` carries every qualified
candidate ID and the selected point ID; the SQLite `selection_candidate`
table stores candidate membership as separate rows with foreign keys.
`species_traits.csv` is a provisional report-choice export with anatomy and
condition/basis retained, plus point ID, measure, species, source role,
reporting and cited references, method, trait definition, units, and their
evidence fields. It is not the production trait dataset. The
qualification-only build and direct selector both avoid merge-folder
inputs. The future item builders can emit long reports directly, removing
the oversized all-item inventory and duplicate interpretation step.

The ten-paper SQLite file has `point_metadata` (5,285 rows),
`item_variable` (59), `reference` (470), `point_reference` (8,968),
`lineage` (67), `selection_decision` (698), and `selection_candidate`
(699). Foreign-key checks pass. The candidate junction makes the two reports in the thalamus
choice queryable without parsing a semicolon-separated CSV field. The reference
junction retains 48 separate Heffner cell-to-key links across 42 cited cells;
302 Bahney Table 3/4 links are labeled `row_context`, so they do not claim
variable-specific original sources.

## Precedents and useful vocabulary

- [AnimalTraits' R workflow](https://github.com/animaltraits/animaltraits.github.io/blob/main/R/README.md)
  standardizes paper data into observations, then aggregates species traits
  from those observations.
- [AusTraits/traits.build file organization](https://traitecoevo.github.io/traits.build-book/content/file_organisation.html)
  pairs study data with a metadata mapping and shared trait, taxon, and unit
  rules. This pilot borrows that pattern without its full data model.
- [Open Traits Network guidance](https://opentraits.org/best-practices/05_structure-trait-data.html)
  names taxon, trait, observation ID, value, unit, and source as minimum
  fields and recommends preserving raw and processed versions.
- [Darwin Core MeasurementOrFact](https://dwc.tdwg.org/terms/) and the
  [Ecological Trait-data Standard](https://ecologicaltraitdata.github.io/ETS/)
  provide vocabulary for measurement, verbatim values/names, method,
  statistical method, and cited source. The ETS page linked here is its
  development branch; its published release should be checked before
  claiming conformance.
- [Data Package Table Schema](https://datapackage.org/standard/table-schema/)
  can describe the CSV fields and their keys. [W3C PROV-O](https://www.w3.org/TR/prov-o/)
  gives names to report derivation and attribution relationships.

These are design precedents, not a claim that the pilot conforms to those
standards.
