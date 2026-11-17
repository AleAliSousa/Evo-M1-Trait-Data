# Pilot provenance map

This map separates a registered **item** from its supporting evidence. All
39 registered TSVs in the ten paper folders have live rows in __ReadMe.xlsx;
the metadata catalog now includes the 15 Buchsbaum/Kaufman siblings omitted
from the earlier 24-item catalog. The report qualification pilot still
selects columns from 17 items. A paper,
download, snapshot, source citation, item-scoped lookup, or taxon key does
not need its own registry row merely to support that item. The registry
describes the item and its public TSV; it is not a bibliography of every
work cited by every value.

## Historical eight-paper paths before the measurement inventory

~~~mermaid
flowchart LR
  subgraph MP["ManyPrimates: two registered items"]
    MP1["Trial data CSV<br/>supporting download"] --> MP2["STM snapshot CSV<br/>frozen copy"]
    MP2 --> MP3["STMperformance.R<br/>CSV and registered TSV"]
    MP4["species_predictors.xlsx<br/>Compilation for paper<br/>41 columns, 13 predictors"] --> MP5["speciespredictors_snapshot.R<br/>byte-copy"]
    MP5 --> MP6["speciespredictors_snapshot.xlsx<br/>complete frozen workbook"]
    MP6 --> MP7["speciespredictors.R<br/>CSV and registered TSV"]
    MP7 -.->|species-name lookup| MP3
  end
  subgraph MI["Mink: table and separately registered bibliography"]
    MI1["Paper PDF Table 1<br/>and footnotes"] --> MI2["TABLE1_snapshot.R<br/>transcribed snapshot XLSX"]
    MI2 --> MI3["TABLE1.R<br/>CSV and registered TSV"]
    MI4["Paper PDF bibliography"] --> MI5["REFERENCES_snapshot.csv"]
    MI5 --> MI6["REFERENCES.R<br/>CSV and registered TSV"]
    MI6 --> MI7["TABLE1_references.csv<br/>54 cited-key lookup; supporting file"]
    MI7 -.->|numbered citations| MI3
  end
  subgraph BO["Boddy: two registered supplements"]
    BO1["jeb_2491_sm_tables1.xlsx<br/>supplied supplement and frozen source"] --> BO2["TableS1.R<br/>CSV and registered TSV"]
    BO3["brain_body_database_v2.txt<br/>supplied supplement and frozen source"] --> BO4["brainbodydatabasev2.txt.R<br/>CSV and registered TSV"]
  end
  subgraph FA["Falcone: two registered paper tables"]
    FA1["Paper PDF Tables 1 and 2"] --> FA2["TABLE1_snapshot.csv<br/>and TABLE2_snapshot.csv"]
    FA2 --> FA3["TABLE1.R and TABLE2.R<br/>two CSVs and two registered TSVs"]
  end
  subgraph BU["Buchsbaum: original study, one registered item"]
    BU1["Original FDG-PET paper PDF<br/>Table I, journal p. 1354"] --> BU2["TableI_snapshot.R<br/>frozen printed table CSV"]
    BU2 --> BU3["TableI.R<br/>long region x arm CSV<br/>registered TSV"]
  end
  subgraph KA["Kaufman: later dissertation compilation, one registered item"]
    KA1["Dissertation PDF Table A3<br/>plus digitized workbook"] --> KA2["TableA3_snapshot.csv<br/>frozen study rows"]
    KA2 --> KA4["TableA3.R<br/>CSV and registered TSV"]
    KA3["source_corrections.R<br/>checked OCR overlay"] --> KA4
    KA1 --> KA5["TablesA1-A14_references.csv<br/>bibliography-based cited-work lookup; supporting"]
    KA4 -.->|Reference key to resolve| KA5
  end
  subgraph HH["Heffner 2010b: one registered comparative table"]
    HH1["Letter PDF Table 1<br/>and superscript footnotes"] --> HH2["Table1_snapshot.csv<br/>21 printed species rows"]
    HH2 --> HH3["Table1.R<br/>CSV and registered TSV"]
    HH1 --> HH4["Footnotes and references CSVs<br/>separate hearing/membrane keys"]
    HH4 --> HH5["Reviewed reference_columns.csv<br/>cell-specific source match"]
    HH5 -.-> HH3
  end
  subgraph BA["Bahney 2018: four registered tables"]
    BA1["Paper PDF Tables 1–4"] --> BA2["Four frozen snapshot CSVs"]
    BA2 --> BA3["Four item R builders<br/>CSVs and registered TSVs"]
    BA1 --> BA4["Four definitions CSVs<br/>Table 3/4 bibliography lookups"]
    BA4 --> BA5["Table 3/4 reference_columns.csv<br/>row_overall citation scope"]
  end
  BU1 -.->|Buchsbaum 1989 citation<br/>resolved by lookup| KA5
~~~

The arrow into each item R script is the input used to make its analysis
CSV. The public TSV is the registered output consumed by __measurements.
The Boddy supplements are already born-digital frozen sources, so they do
not have an additional file with a snapshot suffix. Falcone's two snapshots
are transcriptions; their READMEs say the extraction provenance is uncertain,
and the Table 2 snapshot changes one printed genus. Buchsbaum's PDF gives
an original measure with an explicit awake arm, region, sample size, unit,
mean, and SD. Kaufman's Table A3 has a secondary row citing that paper;
its lookup resolves the cited work before source choice. Neither the
Kaufman lookup nor its source-correction overlay is a registered item.
Heffner's footnotes and reference lookup are supporting metadata even though
its Table 1 TSV is registered. Bahney's Tables 1–2 are original method-by-
segment summaries; Tables 3–4 have compiled rows and two own-study ratio
rows each. Their item-specific definitions and cited-work lookups are
supporting files, and `_keys/General/species_key.csv` supplies cross-paper
taxon resolution.

## Fobbs and Kennedy: every registered item to the selector

Each line below names one registered public item. Fobbs's original Word
supplements are source evidence; the XLSX files are frozen snapshots made by
the corresponding Python scripts. The item R builders generate CSV and TSV
rows. The seven definitions CSVs and three builder-used taxa CSVs are
supporting paper-folder metadata, not separate registry items. Kennedy's
Table and Text have separate PDF transcriptions, builders, definitions, and
TSVs. `__ReadMe.xlsx` registers all nine outputs, while `_keys` supplies
project taxon authority only after paper-local context is retained.

~~~mermaid
flowchart TB
  subgraph F["Fobbs 2011: seven registered specimen catalogs"]
    F1D["S1a DOC<br/>human developmental catalog"] --> F1S["S1a snapshot.py → XLSX"] --> F1B["S1a.R → CSV → public TSV<br/>two body lengths"]
    F2D["S1b DOC<br/>non-human catalog"] --> F2S["S1b snapshot.py → XLSX"] --> F2B["S1b.R → CSV → public TSV"]
    F3D["S2 DOC<br/>brain-section catalog"] --> F3S["S2 snapshot.py → XLSX"] --> F3B["S2.R → CSV → public TSV"]
    F4D["S3 DOC<br/>non-mammalian sections"] --> F4S["S3 snapshot.py → XLSX"] --> F4B["S3.R → CSV → public TSV"]
    F5D["S4 DOC<br/>storage-box inventory"] --> F5S["S4 snapshot.py → XLSX"] --> F5B["S4.R → CSV → public TSV"]
    F6D["S5a DOC<br/>comparative sections"] --> F6S["S5a snapshot.py → XLSX"] --> F6B["S5a.R → CSV → public TSV"]
    F7D["S5b DOC<br/>non-mammalian catalog"] --> F7S["S5b snapshot.py → XLSX"] --> F7B["S5b.R → CSV → public TSV"]
    FDEF["Seven item definitions CSVs<br/>fields, methods, scope; supporting"]
    FTAX["S2, S4, S5b taxa CSVs<br/>paper-local judgments; supporting"] -.-> F3B
    FTAX -.-> F5B
    FTAX -.-> F7B
  end
  subgraph K["Kennedy 1978: two registered measurement items"]
    KP["Paper PDF<br/>table, discussion, figures, Methods, references"] --> KTS["Table_snapshot.R → CSV<br/>printed table layout"] --> KTB["Table.R → CSV → public TSV<br/>39 regional group means"]
    KP --> KXS["Text_snapshot.R → CSV<br/>one located printed value per row"] --> KXB["Text.R → CSV → public TSV<br/>10 own, cited, or repeated values"]
    KDEF["Table + Text definitions CSVs<br/>units, anatomy, grain; supporting"]
    KREF["Text_references.csv<br/>ref 20 Schmidt; ref 22 Sokoloff; supporting"]
    KPROP["Proposed species key + erratum<br/>catalogued, not adopted"]
  end
  F1B --> INV["Measurement inventory<br/>all registered TSV rows"]
  F2B --> INV
  F3B --> INV
  F4B --> INV
  F5B --> INV
  F6B --> INV
  F7B --> INV
  KTB --> INV
  KXB --> INV
  REG["__ReadMe.xlsx<br/>nine item registrations"] --> CAT["Typed metadata catalog<br/>item, artifact, field routes"]
  FDEF --> CAT
  FTAX --> CAT
  KDEF --> CAT
  KREF --> CAT
  KPROP -.-> CAT
  KEY["_keys accepted species<br/>curated project authority"] --> CAT
  INV -->|Kennedy and earlier scoped columns| GATE["Ten-paper report gate<br/>definition → source → method → taxon → qualification"]
  CAT -->|routed metadata| GATE
  INV --> FS["Fobbs catalog screen<br/>2,303 source rows; 4,252 numeric values"]
  FS -->|802 S1a body lengths| GATE
  FS --> CTX["3,450 context-only inventory values<br/>excluded from trait gate"]
  GATE --> HOLD["Held reports<br/>includes 802 Fobbs lengths + 10 Kennedy Text values"]
  GATE --> READY["Qualified reports<br/>includes 39 Kennedy Table group means"]
  READY --> SELECT["R source selector<br/>comparable reports; original preference"]
  SELECT --> OUT["Provisional species-trait view<br/>decision log; no __merging_* input"]
~~~

The `specimen_catalog_screen.csv` is the gate's audit of **2,303 Fobbs
source rows and 4,252 numeric inventory values**. It sends only the 802 S1a
body-length cells into report qualification, all held at specimen grain;
the other 3,450 numeric values are catalog or preparation context. S2,
S4, and S5b `Species_binomial` fields come from their item-scoped taxa
lookups; S1a's constant *Homo sapiens* comes from source-wide context.
Neither annotation is a shared accepted-species decision. Fobbs's
`source_row` is assigned after source-layout filtering, so it is not an
exact Word-row number. The inventory marks all 802 lengths primary from a
generic definition; the gate marks their measurement origin unresolved
because the archived lengths' original measurer is unproven.

Kennedy Table's 39 regional glucose-use group means qualify as primary.
Kennedy Text is mixed at **row** level: its own text values and the values
cited from refs 20 and 22 retain distinct `data_role` and `value_status`.
All ten Text points are held. Four Text points are labeled primary in the
generic inventory but secondary by the gate's row-level `data_role` check;
`inventory_disagreement_summary.csv` records the difference. The ref-20 `monkey` value cannot inherit
Kennedy's rhesus identity because Schmidt's source pooled animals from
more than one genus. Kennedy's own Table and own Text passages can resolve
to *Macaca mulatta* from the Methods and the active accepted-name table;
the proposed paper-local species key is not adopted globally.

## Earlier Heffner and Bahney report-schema tests

| Item | Printed and analysis grain | Paper-local metadata | Point-level decision |
| --- | --- | --- | --- |
| Heffner Table 1 | 21 species rows; one hearing-limit, one functional interaural-distance, and one basilar-membrane-length cell per row | Item definitions; footnotes; a reference table; `reference_columns.csv` assigns separate hearing and membrane keys to their own variables | All are secondary reports. The distance has no per-row citation; footnotes `h`/`j` lack full bibliography entries and `m`/`q` each bundle two works. Original source and method remain under review. Preserve the printed *Tursiops truncates* separately from the normalized binomial. |
| Bahney Tables 1–2 | One species per table; eight method × spinal-cord-segment summary rows each | Definitions specify IF versus stereology, total cells, percentages, and ratio types; species is supplied by caption/Results, not a printed table column | Original ratio and cell-count reports must keep method and segment; IF nNNR differs from stereology GNR. Table 2 has documented printed arithmetic/text inconsistencies. |
| Bahney Table 3 | 43 printed species/source/CNS-part rows | Definitions plus 22-key bibliography; `references` is declared `row_overall` | Literature ratios are secondary; two `This Study` ratios are primary. Parenthesized brain masses on those rows are estimated context with unresolved origin. |
| Bahney Table 4 | 112 analysis rows from printed row × CNS part with a value | Definitions plus 16-key bibliography; `references` is declared `row_overall`; mass unit g is inferred from Table 3 | Literature ratios are secondary; two own-study nNNRs are primary. Brain mass repeats across CNS-part rows and is not a new measurement each time; `Rest of brain` needs anatomy review. |

~~~mermaid
flowchart LR
  subgraph H["Heffner paper folder: cell-scoped citations"]
    HR["One printed species row"] --> HF["Hearing cell"] --> HK["Hearing footnote key"]
    HR --> HM["Basilar-membrane cell"] --> MK["Membrane footnote key"]
    HR --> HD["Interaural-distance cell"] --> HU["No per-row source key<br/>hold source/method review"]
    HK --> HB["Item bibliography"]
    MK --> HB
  end
  subgraph B["Bahney paper folder: row citation, cell decisions"]
    BR["Table 3/4 printed row"] --> BC["Row References key"] --> BB["Item bibliography"]
    BR --> RATIO["GNR or nNNR cell<br/>own-study or secondary"]
    BR --> MASS["Brain-mass cell<br/>possibly estimated or repeated"]
    BC -.->|row_overall only| RATIO
    BC -.->|variable source unresolved| MASS
  end
  TAX["_keys taxon and anatomy crosswalks"] --> FINAL["Point qualification and source choice"]
  HF --> FINAL
  HM --> FINAL
  HD --> FINAL
  RATIO --> FINAL
  MASS --> FINAL
~~~

The diagram distinguishes a citation key's **scope** from a measured
cell's **source role**. A row-level `data_role` or citation may be useful
context, but neither establishes original provenance for every cell in
that row. Definitions remain source-checkable supporting files; the
shared `_keys` resources resolve accepted species and comparable anatomy
after paper-local extraction. The current catalog registers the files and
routes fields; it does not yet record a separate per-definition reviewer or
source-quotation check. Those remain part of the proposed paper-folder
metadata contract, not a completed gate.

| Linked table or file | Key and grain | Role for the earlier two papers |
| --- | --- | --- |
| Paper-folder `<Item>_definitions.csv` | `Code`; one source variable or method definition | Heffner has distinct hearing, distance, and membrane definitions. Bahney defines method, segment, cell type, GNR/nNNR, estimated mass, and source locators. |
| Catalog `item` / `artifact` / `field_route` | Registered item / supporting file / item-field route | Registers each TSV separately from its definitions, footnotes, bibliography, and citation-scope files. |
| Pilot `item_variable` | `(item, column)`; one included trait mapping | Maps source columns to pilot trait IDs and units while leaving printed wording in the paper definitions. |
| Pilot `point_metadata` | `point_id`; one measured cell | Heffner's three values in a row have separate point IDs. Bahney's ratio and contextual mass in one row have separate roles and blockers. |
| Pilot `reference` / `point_reference` | Citation string / point-to-citation relation | Retains reporting and cited works. Heffner has 48 separate cell-to-key links across 42 cited cells; compound keys and Bahney's `row_overall` citations require review before claiming an original source for a specific value. |
| Pilot `lineage` / `selection_candidate` / `selection_decision` | Linked reports / candidate membership / comparison group | Records proven relays and source choices without treating repeated context or secondary compilations as independent measurements. |

## Metadata sources, registration, and checkpoints

The source catalog is [items.csv](../../__metadata/pilot/items.csv) +
[artifacts.csv](../../__metadata/pilot/artifacts.csv) +
[field_routes.csv](../../__metadata/pilot/field_routes.csv). It records an
item's registry identity, every relevant file's content and authority stage,
and the exact field/locator to read at a checkpoint. The three distinctions
are independent: a registered item can contain a reference list, an
unregistered sidecar can carry authoritative definitions, and a generated
key can be an index rather than a new publication.

~~~mermaid
flowchart TB
  subgraph PAPER["Within paper folders: evidence and item processing"]
    PUB["Paper PDF or supplied supplement<br/>methods, tables, bibliography"] --> SNAP["Frozen source or snapshot"]
    SNAP --> BUILD["Item R builder"] --> TSV["Registered public item TSV<br/>values plus embedded Source / Notes / ref keys"]
    DEFS["Item definitions CSV<br/>reference_tables"]
    REFLIST["Mink REFERENCES<br/>registered bibliography item"] --> LOOKUP["Mink TABLE1_references.csv<br/>supporting item lookup"]
    KLOOKUP["Kaufman TablesA1-A14_references.csv<br/>supporting cited-work lookup"]
    HLOOKUP["Heffner footnotes + reference_columns.csv<br/>measure-specific citation scope"]
    BLOOKUP["Bahney Table 3/4 references + reference_columns.csv<br/>row_overall citation scope"]
    FLOOKUP["Fobbs seven definitions + three taxa CSVs<br/>specimen fields and paper-local name annotations"]
    K1978["Kennedy Table/Text definitions + Text_references.csv<br/>group means, row roles, numbered cited works"]
    NOTES["READMEs, errata, manifests<br/>supporting evidence; some not parsed"]
  end
  REG["__ReadMe.xlsx<br/>registered item identity and DOI or UMI"]
  subgraph PROJECT["Outside paper folders: project metadata"]
    TAX["_keys/species_reference.csv<br/>and active species_key.csv files<br/>curated taxon authority"]
    SPEC["_keys/specimen_crosswalk/<br/>specimen_crosswalk.csv<br/>curated specimen identity; separate from item taxa"]
    ROW["__metadata/curation/brain_mass_row_basis.csv<br/>audited source-row decisions"]
    FLAGS["__metadata/curation/brain_mass_value_flags.csv<br/>evidence-backed prepool vetoes"]
    INDEX["_keys/variable_catalog.csv<br/>generated definition index"]
    BASIS["_keys/brain_size_basis.csv<br/>generated curated basis key"]
    CONFIG["__measurements/config/*.csv<br/>processing and relation rules"]
  end
  LEGACY["Other __merging_* premerge inputs<br/>legacy locations; migration queue<br/>outside this ten-paper route"]
  META["__metadata/pilot catalog<br/>item + artifact + field_route<br/>location / role / locator / checkpoint"]
  INV["__measurements/measurements.sqlite<br/>points + source_rows + item_context"]
  GATE["Pilot metadata gate<br/>definition → source trace → method → taxon → qualification"]
  HOLD["Held points<br/>blocker codes and evidence route"]
  CHOICE["Ten-paper source choice<br/>prefer verified original; retain relay link"]
  OUTPUT["Species-trait view + decision log<br/>no __merging_* input"]
  POOL["Legacy brain-mass pool builder"]
  MERGE["__merging_* outputs<br/>historical audit only"]
  TSV --> INV
  REG --> INV
  DEFS --> INV
  INDEX --> INV
  BASIS --> INV
  ROW --> INV
  REG --> META
  DEFS --> META
  TSV --> META
  LOOKUP --> META
  KLOOKUP --> META
  HLOOKUP --> META
  BLOOKUP --> META
  FLOOKUP --> META
  K1978 --> META
  NOTES --> META
  TAX --> META
  SPEC --> META
  ROW --> META
  FLAGS --> META
  INDEX --> META
  BASIS --> META
  CONFIG --> META
  LEGACY -.->|future catalog extension| META
  INV --> GATE
  META -->|routed sources| GATE
  GATE -->|missing or conflicting| HOLD
  GATE -->|qualified candidates| CHOICE
  CHOICE --> OUTPUT
  ROW --> POOL
  FLAGS --> POOL
  POOL --> MERGE
~~~

The inventory currently reads public TSVs, registry rows, definitions,
item-scoped lookups, selected `_keys` indexes, and the premerge Boddy row
decisions. It does **not** directly read paper PDFs or snapshots; item R
scripts bring their values into the public TSVs. It retains embedded
citations as source-row context even when no normalized reference link
exists. The ten-paper qualification path reads the catalog to locate
definitions, citation lookups, active taxon resources, and row decisions.
Kaufman's `Reference` is resolved through its supporting citation lookup;
the Buchsbaum source row is compared directly with the Kaufman relay.
The catalog routes metadata; it does not by itself assert that a cited work
is primary or that a point is qualified. No `__merging_*` product supplies
evidence to the qualification gate or new direct selector. The catalogued
`__merging_*` artifacts document the older audit path and are optional
historical products, not ten-paper build inputs.

| Example | Registration | Storage and content | Authority and checkpoint |
| --- | --- | --- | --- |
| Mink REFERENCES TSV | Registered reference-list item | Public TSV derived from the paper bibliography | Item output; source tracing, with no measurement points of its own. |
| Mink TABLE1_references.csv | Supporting file | `Mink_etal_1981/reference_tables/`; 54 numbered citation keys | Item-scoped lookup at source tracing. |
| ManyPrimates Source cells | Part of a registered observation item | Embedded beside predictor values in the source sheet and TSV rows | Reported citation at source tracing; does not establish an original method. |
| Buchsbaum Table I TSV | Registered observation item | Original FDG-PET study; long rows retain printed region, arm, n, mean, and SD | Source PDF and definitions establish the primary role, unit, and method before qualification. |
| Buchsbaum definitions CSV | Supporting file | `Buchsbaum_etal_1989/reference_tables/`; region, arm, and measure definitions | Item processing and method review; its proposed species key is a separate, nonactive candidate. |
| Kaufman Table A3 TSV | Registered observation item | Later dissertation's per-study compilation; `Reference`, `Mode`, and `Anesthesia` stay with each row | Source trace and method review distinguish cited-source rows from Kaufman's own study rows. |
| Kaufman citation lookup | Supporting file | `Kaufman__2004/reference_tables/`; exact `ref_key` → `source_reference_id` and source type | Source trace resolves `(Buchsbaum et al., 1989)` to the original paper. |
| Heffner footnotes, references, and scope | Supporting files | `Heffner_Heffner_2010_b/reference_tables/`; printed keys and reviewed hearing-versus-membrane attribution | Source tracing at the individual measured-cell level; interaural distance has no per-row source key. |
| Bahney Table 3/4 references and scope | Supporting files | `Bahney_vonBartheld_2018/reference_tables/`; printed keys and `row_overall` declarations | Source tracing at the row level; does not establish separate brain-mass and ratio lineages. |
| Fobbs seven public catalog TSVs | Registered `specimen_catalog` items | Each follows its own Word supplement → XLSX snapshot → R builder; S4 is box-level. | S1a body lengths reach qualification at specimen grain; six other catalogs supply collection and preparation context. |
| Fobbs definitions and S2/S4/S5b taxa | Supporting files | `Fobbs_etal_2011/reference_tables/`; seven ten-column definitions and three printed-name lookups used by item builders. | Definitions are checked against original supplements; `Species_binomial` from a local lookup is an item annotation, not accepted taxon authority. |
| Kennedy Table and Text TSVs | Registered observation items | Separate PDF transcriptions, R builders, CSVs, and public TSVs. | Table group means are primary; Text source role and repeat status are decided per row. |
| Kennedy Text numbered references | Supporting file | `Kennedy_etal_1978/reference_tables/Kennedy_etal_1978_Text_references.csv`; ref 20 Schmidt 1945, ref 22 Sokoloff 1976. | Source trace identifies ref 20's original report; ref 22's underlying human primary remains unresolved. |
| Falcone definitions CSV | Supporting file | `Falcone_etal_2019/reference_tables/` | Item definition at inventory extraction. |
| Boddy row-basis audit | Supporting file | `__metadata/curation/`; source-row decisions | Curated authority for method, role, and pooling before qualification. |
| Brain-mass value flags | Supporting file | `__metadata/curation/`; evidence-backed source-row vetoes | Prepool exclusion authority; not a merge audit output. |
| Species keys | Supporting files | `_keys/`; active name crosswalks | Curated taxon authority at taxon review. |
| Specimen crosswalk | Supporting curated file | `_keys/specimen_crosswalk/specimen_crosswalk.csv`; specimen identity and taxonomic history. | Review at exact record grain; Fobbs item `source_row` is assigned after layout filtering. |
| Variable catalog | Supporting file | `_keys/`; generated from item definitions | Search/classification index; trace back to definitions. |
| Legacy merge outputs | Supporting historical products | `__merging_*` | Older source-choice audit; not an input to the ten-paper qualification or direct selection path. |

## Where each required field is found

| Field | First available source | Additional decision before qualification |
| --- | --- | --- |
| Measure, unit, anatomy or behavior, definition | Printed heading and item definitions; the item R script names analysis columns. | Check the definition against the source cell and original units. Fobbs length and thickness fields incorrectly say `Measure=count` and need definition review. |
| Species | Paper or supplement's printed name, then the item CSV/TSV. | Resolve against active project taxon keys; retain printed and snapshot names separately. Fobbs item-scoped taxa lookups are annotations; Kennedy's cited ref-20 `monkey` cannot inherit the reporting paper's rhesus identity. |
| Reporting reference | The item's __ReadMe.xlsx row and paper DOI or dissertation UMI/citation. | Match its Item encoded value to the public TSV filename; Kaufman's cached Public TSV match is stale although its encoded file exists. |
| Upstream reference | A per-value Source/Reference column, Mink's numbered reference, Kaufman's cited-work lookup, Heffner's measure-specific superscripts, Bahney's row citation, or Kennedy Text's `cited_ref` and numbered lookup. | Trace whether the cited work is an original measurement, a compilation, or only an input. Kennedy ref 22 is a review chapter with unresolved underlying primary. `row_overall` does not prove variable-specific provenance. |
| Method and value origin | Paper methods, table footnotes, item definitions, and Boddy brain-mass row-basis audit. | Separate acquisition method from conversion, prediction, or species-mean calculation. Bahney's own-study ratio and estimated brain mass differ within one row. |
| Primary, secondary, or mixed role | The reporting paper's contribution plus its per-value citations. Registry and generic definition roles are hints. | Decide per measured cell or text row: Kennedy Text has four inventory-primary points correctly relabeled secondary from `data_role`; a row can also hold primary ratios beside contextual estimated masses. |
| Qualification and source choice | Pilot metadata plus active species and method keys. | Hold incomplete points; among qualified comparable reports, prefer the primary for the same observation and avoid counting its relay twice. |

## Registered items and supporting paths

| Registered item | Frozen source or snapshot | Analysis builder | Definitions and citation route |
| --- | --- | --- | --- |
| ManyPrimates STMperformance | [trial data](../../ManyPrimates__2022/ManyPrimates_mp1_merged_data.csv) → [snapshot](../../ManyPrimates__2022/ManyPrimates__2022_STMperformance_snapshot.csv) | [R builder](../../ManyPrimates__2022/ManyPrimates__2022_STMperformance.R) → [CSV](../../ManyPrimates__2022/ManyPrimates__2022_STMperformance.csv) → [TSV](../../__Public/comparative-data/10.26451%252Fabc.09.04.06.2022_STMperformance.tsv) | [definitions](../../ManyPrimates__2022/reference_tables/ManyPrimates__2022_STMperformance_definitions.csv); predictor CSV supplies common-name mapping |
| ManyPrimates speciespredictors | [raw workbook](../../ManyPrimates__2022/species_predictors.xlsx) → [snapshot R](../../ManyPrimates__2022/ManyPrimates__2022_speciespredictors_snapshot.R) → [snapshot](../../ManyPrimates__2022/ManyPrimates__2022_speciespredictors_snapshot.xlsx) | [R builder](../../ManyPrimates__2022/ManyPrimates__2022_speciespredictors.R) → [CSV](../../ManyPrimates__2022/ManyPrimates__2022_speciespredictors.csv) → [TSV](../../__Public/comparative-data/10.26451%252Fabc.09.04.06.2022_speciespredictors.tsv) | [definitions](../../ManyPrimates__2022/reference_tables/ManyPrimates__2022_speciespredictors_definitions.csv); per-predictor Source and Comments in the sheet/CSV |
| Mink REFERENCES | [paper PDF](../../Mink_etal_1981/Mink-1981-Ratio%20of%20central%20nervous%20system%20to%20b.pdf) bibliography → [snapshot](../../Mink_etal_1981/Mink_etal_1981_REFERENCES_snapshot.csv) | [R builder](../../Mink_etal_1981/Mink_etal_1981_REFERENCES.R) → [CSV](../../Mink_etal_1981/Mink_etal_1981_REFERENCES.csv) → [TSV](../../__Public/comparative-data/10.1152%252Fajpregu.1981.241.3.R203_REFERENCES.tsv) | [definitions](../../Mink_etal_1981/reference_tables/Mink_etal_1981_REFERENCES_definitions.csv); each numbered work is an entry, not a separate registered item |
| Mink TABLE1 | [paper PDF](../../Mink_etal_1981/Mink-1981-Ratio%20of%20central%20nervous%20system%20to%20b.pdf) Table 1 → [snapshot R](../../Mink_etal_1981/Mink_etal_1981_TABLE1_snapshot.R) → [snapshot](../../Mink_etal_1981/Mink_etal_1981_TABLE1_snapshot.xlsx) | [R builder](../../Mink_etal_1981/Mink_etal_1981_TABLE1.R) → [CSV](../../Mink_etal_1981/Mink_etal_1981_TABLE1.csv) → [TSV](../../__Public/comparative-data/10.1152%252Fajpregu.1981.241.3.R203_TABLE1.tsv) | [definitions](../../Mink_etal_1981/reference_tables/Mink_etal_1981_TABLE1_definitions.csv) and [54-key lookup](../../Mink_etal_1981/reference_tables/Mink_etal_1981_TABLE1_references.csv); proposed species key is not active |
| Boddy TableS1 | [supplied workbook](../../Boddy_etal_2012/jeb_2491_sm_tables1.xlsx) (frozen source) | [R builder](../../Boddy_etal_2012/Boddy_etal_2012_TableS1.R) → [CSV](../../Boddy_etal_2012/Boddy_etal_2012_TableS1.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1420-9101.2012.02491.x_TableS1.tsv) | [definitions](../../Boddy_etal_2012/reference_tables/Boddy_etal_2012_TableS1_definitions.csv); per-row Reference plus [row-basis audit](../../__metadata/curation/brain_mass_row_basis.csv) |
| Boddy brainbodydatabasev2.txt | [supplied text](../../Boddy_etal_2012/brain_body_database_v2.txt) (frozen source) | [R builder](../../Boddy_etal_2012/Boddy_etal_2012_brainbodydatabasev2.txt.R) → [CSV](../../Boddy_etal_2012/Boddy_etal_2012_brainbodydatabasev2.txt.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1420-9101.2012.02491.x_brainbodydatabasev2.txt.tsv) | [definitions](../../Boddy_etal_2012/reference_tables/Boddy_etal_2012_brainbodydatabasev2.txt_definitions.csv); per-row Source labels |
| Falcone TABLE1 | [paper PDF](../../Falcone_etal_2019/Falcone-2019-Cortical%20interlaminar%20astrocytes.pdf) Table 1 → [snapshot](../../Falcone_etal_2019/Falcone_etal_2019_TABLE1_snapshot.csv) | [R builder](../../Falcone_etal_2019/Falcone_etal_2019_TABLE1.R) → [CSV](../../Falcone_etal_2019/Falcone_etal_2019_TABLE1.csv) → [TSV](../../__Public/comparative-data/10.1002%252Fcne.24605_TABLE1.tsv) | [definitions](../../Falcone_etal_2019/reference_tables/Falcone_etal_2019_TABLE1_definitions.csv); no item-scoped reference lookup |
| Falcone TABLE2 | [paper PDF](../../Falcone_etal_2019/Falcone-2019-Cortical%20interlaminar%20astrocytes.pdf) Table 2 → [snapshot](../../Falcone_etal_2019/Falcone_etal_2019_TABLE2_snapshot.csv) | [R builder](../../Falcone_etal_2019/Falcone_etal_2019_TABLE2.R) → [CSV](../../Falcone_etal_2019/Falcone_etal_2019_TABLE2.csv) → [TSV](../../__Public/comparative-data/10.1002%252Fcne.24605_TABLE2.tsv) | [definitions](../../Falcone_etal_2019/reference_tables/Falcone_etal_2019_TABLE2_definitions.csv); paper/snapshot kandti discrepancy |
| Buchsbaum Table I | [original study PDF](../../Buchsbaum_etal_1989/Buchsbaum-1989-Regional%20cerebral%20glucose%20metab.pdf) p. 1354 → [snapshot R](../../Buchsbaum_etal_1989/Buchsbaum_etal_1989_TableI_snapshot.R) → [frozen snapshot](../../Buchsbaum_etal_1989/Buchsbaum_etal_1989_TableI_snapshot.csv) | [R builder](../../Buchsbaum_etal_1989/Buchsbaum_etal_1989_TableI.R) → [CSV](../../Buchsbaum_etal_1989/Buchsbaum_etal_1989_TableI.csv) → [TSV](../../__Public/comparative-data/10.1016%252F0024-3205(89)90021-0_TableI.tsv) | [definitions](../../Buchsbaum_etal_1989/reference_tables/Buchsbaum_etal_1989_TableI_definitions.csv) give regional method, unit, and primary role; [proposed species key](../../Buchsbaum_etal_1989/reference_tables/Buchsbaum_etal_1989_species_key_proposed.csv) is not active |
| Kaufman Table A3 | [dissertation PDF](../../Kaufman__2004/Kaufman__2004_dissertation.pdf) p. 125 → [frozen snapshot](../../Kaufman__2004/Kaufman__2004_TableA3_snapshot.csv) | [source corrections](../../Kaufman__2004/Kaufman__2004_source_corrections.R) → [R builder](../../Kaufman__2004/Kaufman__2004_TableA3.R) → [CSV](../../Kaufman__2004/Kaufman__2004_TableA3.csv) → [TSV](../../__Public/comparative-data/UMI%253A3147447_TableA3.tsv) | [definitions](../../Kaufman__2004/reference_tables/Kaufman__2004_definitions.csv) and [cited-work lookup](../../Kaufman__2004/reference_tables/Kaufman__2004_TablesA1-A14_references.csv) resolve each cited source, including Buchsbaum |
| Heffner & Heffner 2010b Table 1 | [letter PDF](../../Heffner_Heffner_2010_b/Heffner_Heffner_2010_b.pdf) p. 2081 → [snapshot](../../Heffner_Heffner_2010_b/Heffner_Heffner_2010_b_Table1_snapshot.csv) | [R builder](../../Heffner_Heffner_2010_b/Heffner_Heffner_2010_b_Table1.R) → [CSV](../../Heffner_Heffner_2010_b/Heffner_Heffner_2010_b_Table1.csv) → [TSV](../../__Public/comparative-data/10.1002%252Far.21292_Table1.tsv) | [definitions](../../Heffner_Heffner_2010_b/reference_tables/Heffner_Heffner_2010_b_Table1_definitions.csv), [printed footnotes](../../Heffner_Heffner_2010_b/reference_tables/Heffner_Heffner_2010_b_Table1_footnotes.csv), [cited works](../../Heffner_Heffner_2010_b/reference_tables/Heffner_Heffner_2010_b_Table1_references.csv), and [measure-specific scope](../../Heffner_Heffner_2010_b/reference_tables/Heffner_Heffner_2010_b_Table1_reference_columns.csv) |
| Bahney & von Bartheld Table 1 | [paper PDF](../../Bahney_vonBartheld_2018/Bahney-2018-The%20Cellular%20Composition%20and%20Glia-.pdf) p. 701 → [snapshot](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE1_snapshot.csv) | [R builder](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE1.R) → [CSV](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE1.csv) → [TSV](../../__Public/comparative-data/10.1002%252Far.23728_TABLE1.tsv) | [definitions](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE1_definitions.csv); original Macaca IF/stereology segment summaries |
| Bahney & von Bartheld Table 2 | [paper PDF](../../Bahney_vonBartheld_2018/Bahney-2018-The%20Cellular%20Composition%20and%20Glia-.pdf) p. 703 → [snapshot](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE2_snapshot.csv) | [R builder](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE2.R) → [CSV](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE2.csv) → [TSV](../../__Public/comparative-data/10.1002%252Far.23728_TABLE2.tsv) | [definitions](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE2_definitions.csv); original human segment summaries and documented printed checks |
| Bahney & von Bartheld Table 3 | [paper PDF](../../Bahney_vonBartheld_2018/Bahney-2018-The%20Cellular%20Composition%20and%20Glia-.pdf) p. 704 → [snapshot](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE3_snapshot.csv) | [R builder](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE3.R) → [CSV](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE3.csv) → [TSV](../../__Public/comparative-data/10.1002%252Far.23728_TABLE3.tsv) | [definitions](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE3_definitions.csv), [22-key lookup](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE3_references.csv), [row-scope declaration](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE3_reference_columns.csv) |
| Bahney & von Bartheld Table 4 | [paper PDF](../../Bahney_vonBartheld_2018/Bahney-2018-The%20Cellular%20Composition%20and%20Glia-.pdf) p. 706 → [snapshot](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE4_snapshot.csv) | [R builder](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE4.R) → [CSV](../../Bahney_vonBartheld_2018/Bahney_vonBartheld_2018_TABLE4.csv) → [TSV](../../__Public/comparative-data/10.1002%252Far.23728_TABLE4.tsv) | [definitions](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE4_definitions.csv), [16-key lookup](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE4_references.csv), [row-scope declaration](../../Bahney_vonBartheld_2018/reference_tables/Bahney_vonBartheld_2018_TABLE4_reference_columns.csv) |
| Fobbs Table S1a | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table1a.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1a_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1a_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1a.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1a.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS1a.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS1a_definitions.csv); specimen catalog, not a species brain trait table |
| Fobbs Table S1b | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table1b.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1b_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1b_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1b.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS1b.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS1b.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS1b_definitions.csv); specimen catalog, not a species brain trait table |
| Fobbs Table S2 | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table2.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS2_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS2_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS2.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS2.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS2.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS2_definitions.csv); [taxa lookup](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS2_taxa.csv) annotates printed names; specimen catalog, not a species brain trait table |
| Fobbs Table S3 | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table3.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS3_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS3_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS3.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS3.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS3.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS3_definitions.csv); specimen catalog, not a species brain trait table |
| Fobbs Table S4 | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table4.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS4_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS4_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS4.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS4.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS4.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS4_definitions.csv); [taxa lookup](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS4_taxa.csv) annotates printed names; specimen catalog, not a species brain trait table |
| Fobbs Table S5a | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table5a.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5a_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5a_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5a.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5a.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS5a.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS5a_definitions.csv); specimen catalog, not a species brain trait table |
| Fobbs Table S5b | [Word supplement](../../Fobbs_etal_2011/nyas_6036_sm_table5b.doc) → [snapshot script](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5b_snapshot.py) → [frozen XLSX](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5b_snapshot.xlsx) | [R builder](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5b.R) → [CSV](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS5b.csv) → [TSV](../../__Public/comparative-data/10.1111%252Fj.1749-6632.2011.06036.x_TableS5b.tsv) | [definitions](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS5b_definitions.csv); [taxa lookup](../../Fobbs_etal_2011/reference_tables/Fobbs_etal_2011_TableS5b_taxa.csv) annotates printed names; specimen catalog, not a species brain trait table |
| Kennedy Table | [paper PDF](../../Kennedy_etal_1978/kennedy_etal_1978.pdf) → [snapshot script](../../Kennedy_etal_1978/Kennedy_etal_1978_Table_snapshot.R) → [frozen CSV](../../Kennedy_etal_1978/Kennedy_etal_1978_Table_snapshot.csv) | [R builder](../../Kennedy_etal_1978/Kennedy_etal_1978_Table.R) → [CSV](../../Kennedy_etal_1978/Kennedy_etal_1978_Table.csv) → [TSV](../../__Public/comparative-data/10.1002%252Fana.410040402_Table.tsv) | [definitions](../../Kennedy_etal_1978/reference_tables/Kennedy_etal_1978_Table_definitions.csv); 39 primary regional group means |
| Kennedy Text | [paper PDF](../../Kennedy_etal_1978/kennedy_etal_1978.pdf) → [snapshot script](../../Kennedy_etal_1978/Kennedy_etal_1978_Text_snapshot.R) → [frozen CSV](../../Kennedy_etal_1978/Kennedy_etal_1978_Text_snapshot.csv) | [R builder](../../Kennedy_etal_1978/Kennedy_etal_1978_Text.R) → [CSV](../../Kennedy_etal_1978/Kennedy_etal_1978_Text.csv) → [TSV](../../__Public/comparative-data/10.1002%252Fana.410040402_Text.tsv) | [definitions](../../Kennedy_etal_1978/reference_tables/Kennedy_etal_1978_Text_definitions.csv); [numbered references](../../Kennedy_etal_1978/reference_tables/Kennedy_etal_1978_Text_references.csv) resolve refs 20/22 |

Paths in this table identify their actual locations: most supporting files
are in paper folders, registered TSVs are in `__Public`, and the Boddy
row-basis decisions are in `__metadata/curation`. The Buchsbaum Table I
definitions and Kaufman citation lookup live under `reference_tables`,
and Kaufman's shared definitions file also lives under `reference_tables`.
The inventory reader still supports a legacy paper-folder top-level fallback,
but all ten pilot folders now put definitions under `reference_tables`.
Heffner and Bahney keep their definitions and citation-support files under
their own `reference_tables` directories. The typed catalog registers those
files as supporting artifacts and routes them to the paper-local extraction
and source-tracing checkpoints. Fobbs has seven supporting definitions files
and three builder-used taxa lookups under `reference_tables`; Kennedy has
two definitions files and the Text numbered-reference lookup there. The
Fobbs paper role route records that the published article compiles older
museum collections, so `primary` on an item definition does not prove who
measured an archived specimen length.

### Registration and citation are separate

| Example | Registry state | Where its evidence actually sits |
| --- | --- | --- |
| ManyPrimates speciespredictors | Registered item; registry role is both at item level. | Each predictor citation is a Source cell in the sheet and analysis CSV. There is no item-scoped references CSV. A cited work such as Dunn & Smaers 2018 can have its own registered item, while an unpublished citation may not. Neither fact changes the predictor point's secondary reporting role. |
| Mink REFERENCES | A separately registered bibliography item. | The 54 works cited by Table 1 are selected into its unregistered TABLE1_references.csv lookup. A numbered bibliography entry is not automatically a registered measurement dataset. |
| Boddy TableS1 and raw database | Both items registered; registry role field is blank. | Table S1 Reference and raw database Source fields carry per-row upstream labels. There is no item-scoped references CSV; __metadata/curation/brain_mass_row_basis.csv adds curated basis and role decisions. |
| Falcone Tables 1 and 2 | Both items registered as primary. | Definitions are at the top of the paper folder, outside reference_tables. These are original table measurements, so there is no per-cell upstream bibliography lookup. |
| Buchsbaum Table I | Registered item; original-study rows are primary. | The PDF and frozen snapshot establish awake, NREM, and REM arms. The public TSV preserves region, sample size, mean, SD, and printed unit; definitions specify the measure and anatomy. |
| Kaufman Table A3 | Registered item; most per-study rows are secondary, while `Present Study` rows report Kaufman's own data. | The public TSV carries a per-row `Reference`; its supporting reference lookup resolves Buchsbaum 1989 to an original study. The registry's cached TSV-match field says `notfound`, but the encoded public TSV exists. |
| Heffner & Heffner 2010b Table 1 | Registered observation item; all reported trait values are secondary. | A footnotes table and bibliography are supporting metadata. Its two key columns cite hearing and basilar-membrane values separately; distance has no per-row cited source. |
| Bahney & von Bartheld Tables 1–4 | Four registered observation items; Tables 1–2 are primary, Tables 3–4 mix original and compiled rows. | Four definitions files and Table 3/4 citation lookups are supporting. `row_overall` declarations prevent a row citation from being treated as proof for both ratio and brain-mass cells. `_keys` resolves printed or inferred taxa. |
| Fobbs Tables S1a–S5b | Seven registered `specimen_catalog` items; primary status as a collection listing does not certify an original brain trait measurement. | Seven Word supplements and frozen XLSX snapshots provide source evidence. Seven definitions and three S2/S4/S5b taxa lookups are supporting. Only S1a body lengths enter the report gate at specimen grain; the shared specimen crosswalk is a separate curated resource. |
| Kennedy Table and Text | Two registered observation items. Table is original regional measurement; Text contains own, cited, and repeated reports. | Two definitions files and a Text numbered-reference lookup are supporting. The gate uses Text `data_role` per row; four points called primary by the generic inventory become secondary. Ref 22's underlying original remains unresolved. |

For the shared thalamus observation, source role is assigned to each report
row. Kaufman's dissertation is the reporting source of its Table A3 row;
Buchsbaum is the cited original study behind that row. The reference lookup
establishes the paper link, while the printed values and method establish
the matching observation.

~~~mermaid
flowchart LR
  B["Buchsbaum Table I<br/>awake human thalamus<br/>24.3 ± 7.2; n=10; µmol/100 g/min<br/>original FDG-PET report"] --> M{"Same source observation?"}
  K["Kaufman Table A3<br/>Homo thalamus<br/>24.3 ± 7.2; n=10; PET<br/>secondary literature row"] --> M
  L["Kaufman citation lookup<br/>Buchsbaum 1989 → primary_report"] --> M
  M -->|yes: citation, anatomy, value, SD, n, unit, arm| D["Select Buchsbaum report<br/>retain Kaufman as linked relay"]
  D --> O["Retained source-choice fixture<br/>one contributing observation"]
~~~

## Every variable in the ManyPrimates predictor sheet

The source sheet has 41 species rows. Its four identity columns and 13
predictors are now in the frozen snapshot and analysis CSV/TSV. Twelve
predictors have an adjacent Source and Comments pair; the analysis names
these fields after their predictor, preserving each citation and note.
The item CSV also has a source identifier, for 42 columns total.

| Predictor in analysis CSV | Values | Unit known from sheet? | Per-value Source/Comments |
| --- | ---: | --- | --- |
| life_expectancy | 41 | No | No paired fields |
| color_vision | 39 | Category | Yes |
| vocal_repertoire_types | 39 | Count of vocalization types | Yes |
| group_size | 39 | No | Yes |
| home_range | 39 | No | Yes |
| day_journey_length | 39 | No | Yes |
| resting_time_percent_activitybudget | 39 | Percent | Yes |
| feeding_budget | 39 | No | Yes |
| dietary_breadth | 39 | No | Yes |
| diet_diversity | 39 | Category | Yes |
| percent_frugivory | 39 | Percent | Yes |
| terrestriality | 39 | Category | Yes |
| body_size_kg | 39 | kg | Yes |

These 509 values are all reported by a compilation, so their pilot source
role is secondary. A cited paper may itself be primary, but that does not
turn the ManyPrimates report into an original observation. Original methods,
missing units, and comments about values taken from another species are
separate review tasks.

## Review is not a source type

~~~mermaid
flowchart LR
  VALUE["One reported value"] --> ROLE{"Where did the value come from?"}
  ROLE --> P["Primary"]
  ROLE --> S["Secondary"]
  ROLE --> M["Mixed"]
  ROLE --> U["Unresolved"]
  P --> QA{"Required metadata complete?"}
  S --> QA
  M --> QA
  U --> QA
  QA -->|no| H["Held for review<br/>blocker_codes explain why"]
  QA -->|yes| Q["Qualified candidate"]
  Q --> SELECT["Separate source-choice decision"]
~~~

In the legacy inventory, data_role = review means its available item and
variable metadata cannot give one confident primary/secondary label. It is
a placeholder, not a synonym for secondary. review_reason can also be
nonempty on a point already labeled primary or secondary. The pilot uses
separate source_role and qualification_pass fields, then audits selection
as a further step. A primary observation can be held; a well-documented
secondary report can qualify and remain secondary.

The **current ten-paper run, 16 November 2026**, checked **5,285 points**:
**699 qualified** and **4,586 held**, with **67 supported lineage links**.
The selector forms **698 comparison groups**: 697 singletons and the
verified Buchsbaum/Kaufman original-relay choice, with no unresolved group
and no `__merging_*` input. Its SQLite output has 59 item-variable mappings,
470 references, 8,968 point-reference links, and 699 selection candidates.
Fobbs adds 802 held S1a body-length points after screening 4,252 numeric
inventory values. Kennedy adds 39 qualified Table group means and ten held
Text values. These are report and provisional choice counts, not final
species means.

The following **historical eight-paper run, 16 November 2026**, checked
4,434 points: 660
qualified and 3,774 held, with 63 supported lineage links. The direct
selector forms 659 comparison groups, including one verified
Buchsbaum/Kaufman relay choice and no unresolved choice groups.
The SQLite output links 54 item-variable definitions and 466 distinct
reference strings through 8,112 point-reference rows; its foreign-key
check is clear.
Heffner adds 63 held reports. Bahney adds 382: Table 1 has 24/36
qualified, Table 2 has 6/36, and Tables 3–4 have 0/86 and 0/224.
These counts describe report qualification and provisional source choice,
not a final species-level dataset.

The following two count tables are the **historical six-paper baseline of
15 November 2026**. They exclude Heffner, Bahney, Fobbs, and Kennedy and
must not be used as current pilot totals.

| Pilot source role | Qualification pass | Held for review |
| --- | ---: | ---: |
| Primary | 574 | 154 |
| Secondary | 56 | 2,918 |
| Mixed | 0 | 17 |
| Unresolved | 0 | 270 |
| **All 3,989 points** | **630** | **3,359** |

That six-paper gate included all original regional rows from Buchsbaum and
all three measured quantities in Kaufman's Table A3. The pair selected for
the relay test is one qualified Kaufman glucose-rate row and its qualified
Buchsbaum original. Other Kaufman rows remain held until their cited
studies establish species identity and original methods.

| Registered observation item | Qualified | Held |
| --- | ---: | ---: |
| ManyPrimates STMperformance | 152 | 12 |
| ManyPrimates speciespredictors | 0 | 509 |
| Mink TABLE1 | 0 | 125 |
| Boddy TableS1 | 67 | 563 |
| Boddy raw database | 0 | 1,967 |
| Falcone TABLE1 | 164 | 16 |
| Falcone TABLE2 | 210 | 16 |
| Buchsbaum Table I | 36 | 12 |
| Kaufman Table A3 | 1 | 139 |
| **Total** | **630** | **3,359** |

The baseline's ten catalogued items include Mink REFERENCES, a registered bibliography
with no measurement points of its own. The nine observation items in the
table above contribute the 3,989 candidate points.

~~~mermaid
flowchart LR
  REPORT["Ten-paper item TSVs<br/>reported values + row context"] --> INVENTORY["Measurement inventory<br/>source rows + point IDs"]
  CATALOG["Expanded metadata catalog<br/>definitions, citations, footnotes and taxon routes"] --> GATE["Ten-paper qualification gate"]
  INVENTORY -->|other scoped columns| GATE
  INVENTORY --> FSCREEN["Fobbs numeric screen<br/>802 lengths scoped; 3,450 context-only"]
  FSCREEN -->|S1a lengths| GATE
  GATE --> HELD["Held reports + blocker reasons"]
  GATE --> READY["Qualified reports"]
  READY --> SELECT["One R source-choice path<br/>linked original and relay reports"]
  SELECT --> VIEW["Species-trait view + selection decisions"]
~~~

The operational ten-paper path stops after qualification and selects from
the qualified reports directly. It does not read `__merging_*` tables.

## Known gaps to resolve

- ManyPrimates' compilation has full per-value citations for 12 predictors,
  but life_expectancy has no paired Source column. Several predictor units
  are not stated by the sheet. These cells can be retained but are held for
  source or unit review.
- Mink's reference lookup identifies numbered citations, but the proposed
  species key is not active, and copied methods need tracing to the original
  works.
- Boddy's registry rows exist but leave item-level role blank. Four Table S1
  means mix Sherwood observations and external reports; component links need
  review. An endocranial-to-mass formula does not establish the original
  endocranial-volume acquisition method.
- Falcone's definitions live under `reference_tables/`. The PDF prints
  Cercopithecus kandti in Table 1 and Cercocebus kandti in Table 2; the
  Table 2 snapshot instead says Cercopithecus. The nine related pilot
  points are held pending identity review.
- Buchsbaum's Table I prints 12 measured regions across three arms, plus
  section and grand means. The 36 regional arm observations qualify; the
  12 printed aggregate rows are held rather than pooled with their own
  contributing regions. The paper's phrase "normal volunteers (male
  subjects)" requires an explicit human taxon resolution; the paper-local
  species key remains a proposal, not authority by itself.
- Kaufman Table A3 mixes cited studies with its `Present Study` entries.
  The Buchsbaum thalamus row has a resolved original citation, matching
  mean, SD, sample size, unit, and awake condition, so it qualifies as a
  secondary relay. Its other 139 candidate values remain held for cited
  study taxon or original-method review. The registry's cached public-TSV
  match for this item is stale even though the encoded TSV is on disk.
- Heffner Table 1 has different literature keys for hearing and basilar
  membrane length, including compound footnotes. Its functional
  interaural-distance values lack per-row citations, and the original
  bibliography is incomplete for footnotes `h` and `j`; `m` and `q` name
  two works under one key. The acquisition methods of copied values
  require cited-paper review. The
  final dolphin taxon is printed `Tursiops truncates` but normalized by
  the older item; the source spelling and accepted taxon must stay distinct.
- Bahney Tables 3–4 use row-level References keys. Their `row_overall`
  declarations prevent treating one citation as proof of both brain mass
  and ratio origins. The two own-study ratio rows in each table include
  parenthesized estimated brain masses, which are held as context rather
  than original direct weights. Table 4 infers a mass unit from Table 3
  and repeats mass across CNS-part rows; `Rest of brain` still needs an
  anatomical crosswalk. Tables 1–2 require IF nNNR and stereology GNR to
  remain distinct, and Table 2 has recorded internal printed mismatches.
- Fobbs S1a's two body lengths need corrected measure definitions,
  source-to-cleaned-row locators, original measurement protocol, and a rule
  for any specimen-to-species summary. All 802 inventory-primary lengths
  remain unresolved in the gate. S2/S5a thickness definitions also say
  `Measure=count`; item taxa lookups do not constitute accepted taxonomy.
- Kennedy Text needs original-study tracing for ref 22's human value and
  cited-source taxon review for Schmidt's mixed `monkey` mean. Its own
  single-animal figure values, cited values, and repeated passages remain
  separate from the 39 qualified Table group means. Four generic
  inventory-primary Text points become secondary under the per-row role
  check. The paper-local species key and printed-29 erratum remain proposals.
