# Report-level metadata gate: ten-paper pilot

This pilot checks ManyPrimates, Mink, Boddy, Falcone, Buchsbaum, Kaufman,
Heffner & Heffner 2010b, Bahney & von Bartheld 2018, Fobbs et al. 2011,
and Kennedy et al. 1978
at the report level after their snapshots. It reads the current
`measurements.sqlite` and the
[typed metadata source catalog](../../__metadata/pilot/README.md), which
routes it to source definitions, taxon resolutions, and audited brain-mass
basis decisions. It does not edit source items, the inventory builder, or
production merges.
The separate ManyPrimates item build now includes all predictors, and the
measurement inventory was rebuilt from its expanded public TSV. Production
species-level merges still follow their existing rules.
PROVENANCE_MAP.md diagrams the paper/supplement-to-snapshot-to-TSV paths,
registry and reference lookups, and the separate role, review, and
source-choice decisions.

Run the [single-pipeline path](../pilot_single_pipeline/README.md) from the
repository root. It covers all ten papers without reading a `__merging_*`
output:

    Rscript __metadata/pilot/build_catalog.R
    Rscript __metadata/pilot/build_folder_metadata.R
    Rscript __measurements/pilot_metadata/build_pilot.R --qualification-only
    Rscript __measurements/pilot_single_pipeline/test_direct_selection.R
    Rscript __measurements/pilot_metadata/check_pilot.R --qualification-only

The qualification step writes points, review points, and report lineage;
the direct selector chooses among the qualified reports. The older default
build mode still creates separate merge audits for comparison.

The implementation uses R with DBI, RSQLite, dplyr, dbplyr, readr, and
jsonlite. The measurement inventory connection is read-only. `scope.csv`
names 59 item-columns across 17 scoped items; reported n and SD remain
row metadata, and
Buchsbaum's duplicate `value_numeric` column stays out of the scope. The
seven registered Fobbs museum catalogs are in the metadata catalog; only
S1a's two specimen body-length columns enter the report gate. The other
Fobbs numeric columns are recorded in `specimen_catalog_screen.csv` as
collection or preparation metadata. The
direct selector writes a separate `pilot_single_pipeline.sqlite`; the
existing measurements.sqlite is not changed. This is enough to use
relational tables without moving curation out of R.
The catalog builder must be rerun after changing its three CSV manifests;
the folder validator reads `pipeline_files.csv` in all ten folders and
the R→CSV→TSV contract for all 39 registered items before qualification.
The pilot then reads the catalog's routed paths rather than guessing whether
an item definition is in `reference_tables` (with a legacy top-level fallback).

## Qualification rule

Each selected point_id retains its source locator and raw value. The pilot
adds a trait definition, anatomy or behavior target, unit, printed and
resolved species, reporting reference, any cited upstream reference, method
with evidence, report role, and value origin. These are separate:

- source_role: primary for an original report, secondary for a relay,
  mixed for a value combining the reporting paper's observation with an
  externally sourced input, or unresolved.
- value_origin: original or compiled mass summary, mixed-source mean, trial
  aggregate, categorical score, copied value, estimate from volume, model
  prediction, extrapolation, or calculated index. A primary paper's
  calculated index is not an independent measured cell count.
- upstream_reference: the cited source of an input or copied value, distinct
  from the DOI of the item in reporting_reference. A cited compilation is
  not automatically the original primary measurement.

metadata_complete requires a classified measure/unit and value type,
resolved species, reporting reference, resolved role, upstream reference
where the role is secondary, a supported method, and a trait definition with
an anatomy or behavior target. A mixed report also requires traced component
lineage; none of the mixed cases in this pilot passes that check.
qualification_pass also requires the source's pool eligibility. The method check
accepts an explicitly documented broad mass basis such as measured mass
with fixation unspecified; it does not claim fresh and fixed tissue are
interchangeable. Source rows with an unknown method stay in review. The
qualification decision is a test of this contract, not a change to a merge.
qualification_pass means the point can enter a later source-choice review;
it does not mean the point was selected or counted in a species mean.

Primary and secondary reports remain in pilot_points.csv. The ten-paper
selector groups qualified reports by species, trait, anatomy, condition,
statistic, and unit. It keeps the Kaufman copy linked to Buchsbaum's original
report and chooses the original for that verified overlap. Its
`species_traits.csv` is a provisional selected view, not a final species
mean. The older `primary_preference_audit.csv` lists Boddy secondary measured-mass reports
that have primary candidates for the same species and mass basis in the
existing source pool. The intended rule is to prefer a qualified primary
report within a comparable basis, retain secondary reports as corroboration
or fallback, and verify shared lineage before counting reports as independent.
An updated compilation can receive an explicit selection override without
being relabeled as a primary measurement. No new species means are computed
here.

## Standard checkpoints

| Stop | Required evidence | If missing |
| --- | --- | --- |
| Snapshot extraction | Item, stable cleaned row, direct snapshot/printed-row locator, source column, raw value, measure, unit, trait definition, and anatomy or behavior target. Use each item's definition CSV and snapshot; Fobbs cleaned `source_row` alone does not locate a Word row. | Hold as measure_or_unit, value_type, or trait_definition. |
| Source tracing | Reporting paper, per-cell cited source, report role, and any known source-to-source link. Use the source's reference keys, row citation, and original study. A `row_overall` citation identifies a row source without assigning it to every variable. | Hold secondary reports with no traceable upstream reference; mark role unresolved when the reporting source's contribution is unclear. |
| Method and transformation | Original acquisition or observation method, then any separate calculation, prediction, or conversion. Use source methods, footnotes, and the brain-mass basis audit. | Hold if the original method or a required transformation remains unresolved. Do not use a prediction as a direct measurement. |
| Species resolution | Name as printed in the paper, source snapshot name, accepted name, and an active project key; inspect source comments for congeneric or group-level values. | Hold unresolved, unanchored, or mismatched taxa. |
| Qualification stop | All required metadata and component lineage are present, and the source pool allows the basis. | Keep the point in review and record blocker_codes. |
| Source choice | Compare qualified reports within the same measured quantity, anatomy, condition, and basis; identify relays and shared inputs. Prefer the verified original report for a copied observation. | Leave source choice pending when lineage is uncertain; never average a source with its relay. Stephan–Boddy remains held for collection-lineage review. |

The pilot records all statuses in pilot_points.csv. review_points.csv is the
work queue: each blocker points to the evidence to find next. The policy is
applied per point, including columns within a single source row. Bahney's
own-study ratio and estimated brain mass in the same row are the explicit
test that a row-wide `data_role` cannot decide every cell's source role.

## Ten-paper qualification run, 16 November 2026

The gate checked **5,285 report points**: **699 qualified** and **4,586
held**. Fobbs S1a contributes 802 held specimen body-length points.
Kennedy Table contributes 39 qualified primary regional group means; Kennedy
Text contributes 10 held points with row-level primary/secondary roles.
All seven Fobbs items are catalogued, and `specimen_catalog_screen.csv`
records why numeric inventory columns outside S1a are collection or
preparation metadata. The direct selector forms **698 comparison groups**
from 699 qualified reports: 697 singletons and the verified
Buchsbaum/Kaufman original-to-relay choice, with no unresolved groups.
There are **67 supported lineage links** and no `__merging_*` inputs.

| New paper/item | Points checked | Qualified | Held | Interpretation |
| --- | ---: | ---: | ---: | --- |
| Fobbs Table S1a body lengths | 802 | 0 | 802 | Specimen-grain lengths; incorrect `Measure=count` definitions, acquisition method, and pooling need review. |
| Fobbs S1b, S2, S3, S4, S5a, S5b | 0 | 0 | 0 | Registered specimen catalogs; numeric fields are screened as collection or preparation metadata. |
| Kennedy Table | 39 | 39 | 0 | Original conscious macaque regional glucose-use group means. |
| Kennedy Text | 10 | 0 | 10 | Original, cited, and repeated values need separate row-level and grain checks. |
| **Added-paper subtotal** | **851** | **39** | **812** | |

Qualification is a report-level stop. Fobbs's held specimen values are not
selected species means, and Kennedy's regional group means retain their
anatomy and conscious condition in the selection key.

## Historical eight-paper qualification run, 16 November 2026

The earlier gate checked **4,434 measured cells** from 54 mapped
item-columns: **660 qualified** and
**3,774 held**. Heffner and Bahney account for 445 of those cells. These
are baseline counts, not the current ten-paper results.
Qualification means a report can enter source-choice review; it does not
make a selected species value.

| Added item | Points checked | Qualified | Held | Main observed blockers |
| --- | ---: | ---: | ---: | --- |
| Heffner Table 1 | 63 | 0 | 63 | Original method; missing per-value source for distance; three taxon identity checks. |
| Bahney Table 1 | 36 | 24 | 12 | Measure/unit mapping for total cell counts and some ratios. |
| Bahney Table 2 | 36 | 6 | 30 | Measure/unit mapping and printed-table pool checks. |
| Bahney Table 3 | 86 | 0 | 86 | Original cited-source attribution and methods; estimated brain-mass context. |
| Bahney Table 4 | 224 | 0 | 224 | Original cited-source attribution and methods; inferred unit, repeated/context masses, and anatomy scope. |
| **Added-paper subtotal** | **445** | **30** | **415** | |

That eight-paper run retained 63 supported lineage links. Its direct selector
forms **659 comparison groups** from 660 qualified reports: 658 singletons
and the verified Buchsbaum/Kaufman relay choice, with no unresolved choice
groups.

## Historical six-paper baseline checked 15 November 2026

The counts below describe the prior six-paper run. They remain as a
comparison baseline and must not be read as results for the current
ten-paper scope. The current counts are reported above.

| Source group | Points checked | Qualification pass | Main review reason |
| --- | ---: | ---: | --- |
| ManyPrimates STM | 164 | 152 | The task and individual-first summary method are documented; 12 points have species absent from the active project reference. |
| ManyPrimates species predictors | 509 | 0 | All 13 compiled predictors are retained, including 39 vocal counts. Original studies' protocols remain unverified; several units are unstated and life expectancy has no per-row source. Source comments also flag congeneric substitutions. |
| Mink Table 1 | 125 | 0 | Source-specific species key is still proposed; copied measurements need original methods. Predictions and extrapolations remain distinct from measurements. |
| Boddy Table S1 brain mass | 630 | 67 | The qualified points comprise 12 original Sherwood mass summaries and 55 secondary measured-mass summaries. The 273 endocranial estimates have a known conversion but unresolved original volume-acquisition method; 280 rows are held by the basis review, two volume estimates lack a subtype, four measured-mass points lack an active species entry, and four otherwise eligible means mix original and relayed reports without component lineage. |
| Boddy raw brain/body compilation | 1,967 | 0 | The per-row original method and mass basis have not been established. Its 94 Sherwood rows are original reports; 1,873 rows relay other sources. |
| Falcone ILA Tables 1 and 2 | 406 | 374 | 23 points across three printed taxa lack resolution; nine kandti points are held because the paper's Tables 1 and 2 print different genera and the Table 2 snapshot changed the printed name. Categorical presence values are valid observations. |
| Buchsbaum Table I | 48 | 36 | Original FDG-PET group means for 12 measured regions × three arms qualify with distinct region and arm keys. Twelve printed section/grand means are held because they are summaries rather than independent measured regions. |
| Kaufman Table A3 | 140 | 1 | The Buchsbaum-cited thalamus row qualifies as a secondary relay. Other literature rows need original-study species and method review. The two `Present Study` rows are primary at the row level but remain held. |
| **Total** | **3,989** | **630** | **3,359 remain in review.** |

That six-paper run established 63 supported links: 37 Mink model outputs and 16
spinal-cord derivations to their row's brain mass, seven original Sherwood
brain-mass reports to Boddy's human mean (reproduced arithmetically), and two
raw-to-summary Boddy relays, plus the Buchsbaum-to-Kaufman copied report.
These are in lineage_links.csv.
Expanding the ManyPrimates TSV changed its full row content and therefore
its inventory point IDs. The measurement inventory was rebuilt with that
TSV and the added Heffner and Bahney public TSVs before this pilot ran.

In that run, the direct selector made **629 comparison groups** from 630 qualified
reports: 628 groups contain one provisional report, and the thalamus group
contains Buchsbaum's original and Kaufman's copied report. It selects the
Buchsbaum point and records Kaufman as its relay. Both values have mean 24.3,
SD 7.2, n = 10, the same thalamic target and µmol/100 g/min unit; Kaufman's
reference key resolves to the original study. The other 139 Kaufman reports
remain in the review queue.

## Legacy merge-dependent comparison audits

The following audits come from the older default build. They are retained
for comparison and are not inputs to the ten-paper no-merge selector or
outputs of `run_pilot.R`.

The cross-source audit finds 31 species where a qualified Boddy secondary measured-mass
report has primary candidates in the same broad basis. These are candidate
rows for review, not 31 automatic choices. Two source-choice examples are in
selection_examples.csv:

- Atelerix algirus: Boddy's 3.2 g report cites Stephan 1981; Stephan Table I
  prints 3,200 mg. The active taxon and basis keys establish comparability,
  but do not identify the underlying specimens, sample size, or relationship
  to the team's earlier and later collections. Source choice is held pending
  that lineage review. Do not average the two reports.
- Ursus americanus: the current eligible measured-mass pool has no primary
  record. Retain Boddy's 248 g secondary report as a fallback while tracing
  its cited Spitzka 1903 original before final selection.

The current brain-mass source pool also has 45 species × measure × team × basis
groups containing both primary and secondary rows; mixed_team_audit.csv lists
them for pooling review. The behavioral audit finds 15 species with both a
ManyPrimates vocal count and a Schniter updated count. The current merge
selects Schniter on overlap (Pan paniscus: 11 versus ManyPrimates 38), but
Schniter's original measurement provenance is not qualified in this pilot.

## Source-specific findings

- ManyPrimates' source sheet has 13 predictors, each now in the snapshot,
  analysis CSV/TSV, and pilot. Twelve have paired Source and Comments fields;
  life expectancy has no paired citation. These values are secondary
  compilation reports regardless of whether a cited work is itself primary.
  The existing behavior merge already labels vocal repertoire secondary.
  The 10 vocal comments about another species or a broader group block
  species-level qualification; similar comments on other predictors are
  also held.
  For STM, n_individuals_source_row is an all-delay participant count; do
  not treat it as a delay-specific denominator for the short, medium, or
  long performance columns.
- Mink's source references must be matched by point column. On the cat
  row, brain and spinal mass cite ref 57, while brain oxygen consumption cites
  ref 30. The current inventory builder links row references too broadly.
  The pilot's links use the corresponding ref_keys_* field.
- Boddy Table S1's row-basis audit separates original Sherwood mass,
  secondary measured mass, secondary endocranial-derived estimates, and held
  rows. The separate raw compilation needs its own row decisions; the Table
  S1 decisions are not applied to it. Four Table S1 means combine Sherwood
  observations with cited external data; these are mixed-source summaries
  and need component-level lineage before qualification.
- Falcone Table 1 records Yes, No, and the source extraction's
  rudimetary category. No numeric conversion is required. Table 2
  complexity has primary reporting provenance and formula-derived value
  origin. The original PDF prints Cercocebus kandti in Table 2 and
  Cercopithecus kandti in Table 1; the saved Table 2 snapshot transcribes
  Cercopithecus kandti. The pilot preserves both paper and snapshot labels
  and holds all nine related points for taxonomic review.
- Buchsbaum Table I reports original FDG-PET group means for awake, NREM,
  and REM arms. The gate preserves each region and arm in the comparison
  key, so sleep conditions cannot be pooled with awake values. The 12
  section/grand means remain visible but are held as summaries of measured
  regions. The paper and definitions supply µmol/100 g/min even though the
  generic inventory's `source_unit` field is blank.
- Kaufman Table A3 contributes 140 measured-quantity cells from 126 study
  rows; its n and SD columns are metadata, not separate trait observations.
  The exact citation lookup resolves all study references. The two `Present
  Study` rows are Kaufman's own primary reports despite the table's mostly
  secondary role; both are held pending species and method review. Other
  literature rows likewise need their original-study method and species
  checked. Only the Buchsbaum-cited thalamus row passes, using the original
  paper to resolve its printed genus `Homo` and method. The registry has a
  row for Kaufman Table A3 but its cached `Public TSV match` says `notfound`
  despite the TSV existing. The gate treats the registry's `#N/A` DOI URL
  as missing and uses the dissertation citation as reporting reference.
- Heffner & Heffner Table 1 is a 21-species secondary compilation. Hearing
  frequency and basilar-membrane length have separate printed superscript
  keys, footnotes, and reviewed key-column scopes; the functional
  interaural-distance values have no per-row citation. The source paper's
  original methods are not established by the lookup alone. Footnotes `h`
  and `j` lack complete published bibliography entries, while `m` and `q`
  bundle two works under one printed key. Preserve
  `Tursiops truncates` as printed and resolve its accepted name through
  project taxonomy rather than rewriting the source name.
- Bahney & von Bartheld Tables 1–2 give original IF and stereology summaries
  by spinal-cord segment. Tables 3–4 compile literature values alongside
  two own-study ratio rows each. Their reference keys have a reviewed
  `row_overall` scope: a citation names the row source, but does not prove
  the same work measured both brain mass and GNR or nNNR. The own-study
  brain masses `(75)` and `(1300)` are estimated context, not primary
  direct weights; Table 4's mass unit is inferred from Table 3. Table 4
  repeats brain mass across CNS-part rows, and single-value min/max fields
  are representations of the same report. Original methods for compiled
  rows and the `Rest of brain` anatomy mapping remain for review. The
  generic measurement inventory labels all Table 3/4 points secondary;
  this pilot uses the paper row and variable together to distinguish the
  own-study ratios from the estimated brain-mass context.
- Fobbs's seven registered public TSVs are museum catalogs. Their published
  Word supplements pass through frozen XLSX snapshots and item R builders;
  seven definitions files and the S2/S4/S5b taxon lookups are supporting
  paper-folder metadata. S1a contributes two real body-length columns at
  specimen grain, but its definitions label them `Measure=count` and the
  acquisition/pooling basis is incomplete, so all 802 points are held.
  All 802 have inventory role `primary` from the generic definition but
  pilot role `unresolved`: the original measurer of those archived lengths
  is not established. `inventory_disagreement_summary.csv` records this
  difference.
  The S2/S5a thickness definitions also misuse `Measure=count`. The other
  Fobbs numeric fields describe sectioning, slides, or boxes and are listed
  in `specimen_catalog_screen.csv`, not promoted as species brain traits.
  Paper-local `Species_binomial` annotations and the project specimen
  crosswalk remain separate taxon layers.
- Kennedy Table contributes 39 original regional glucose-use group means
  from conscious macaques, each qualified with its printed region and
  group-mean context. Kennedy Text has 10 separately extracted values:
  rows 1–3 and 5–6 are cited secondary values, while 4 and 7–10 are the
  paper's own reports. The row's `data_role` and `value_status` govern;
  the generic primary role in the Text definitions does not override them.
  The inventory labels four Text points primary from that generic
  definition, but the report gate correctly classifies them secondary from
  their row-level `data_role`; `inventory_disagreement_summary.csv` records
  this correction.
  The Text references lookup identifies Schmidt 1945 as ref 20 and Sokoloff
  1976 as ref 22; the original study behind the cited human value remains
  unresolved. The cited `monkey` value cannot inherit Kennedy's rhesus
  identity because Schmidt pooled animals from more than one genus. The
  proposed species key and printed-29 erratum are not adopted as authority.
- definition_parse_issues.csv still shows seven malformed or short
  definition rows (four ManyPrimates STM and three Boddy) in the historical
  eight-paper run. The pilot uses valid rows and leaves source files untouched.

## Output files

- `../pilot_single_pipeline/pilot_single_pipeline.sqlite`: ten-paper
  `point_metadata`, `item_variable`, `reference`, `point_reference`,
  `lineage`, `selection_decision`, and `selection_candidate` tables. The
  completed run has 5,285 report rows, 59 item-variable mappings, 470
  references, 8,968 point-reference links, 67 lineage links, 698 decisions,
  and 699 candidates; foreign keys check cleanly. A source
  string with multiple citations stays one citation bundle until the works
  can be disambiguated. The older default build also writes
  `pilot_metadata.sqlite` for its legacy audits.
- pilot_points.csv: all scoped source reports, including primary,
  secondary, mixed, qualified, and held points.
- review_points.csv: held points with blocker_codes.
- summary.csv: counts by item, role, origin, and qualification status.
- lineage_links.csv: confirmed point-to-point relationships.
- primary_preference_audit.csv: legacy merge audit of comparable Boddy
  secondary reports and external primary candidates; the single-pipeline
  selector does not read it.
- selection_examples.csv: legacy audit with a held Stephan collection-lineage
  question and a provisional secondary fallback.
- behavior_preference_audit.csv: legacy audit of the current vocal-count
  overlap choice, with Schniter original-study method still unverified.
- mixed_team_audit.csv: legacy source-pool groups that mix roles within one
  basis.
- inventory_disagreement_summary.csv: cases where the pilot's role differs
  from the initial measurement inventory.
- excluded_context.csv: candidate inventory columns that the pilot treats
  as context rather than independent trait measurements.
- specimen_catalog_screen.csv: all Fobbs numeric inventory columns, with
  the S1a body lengths scoped at specimen grain and the remaining catalog
  counts and thicknesses screened from species-trait use.
- definition_parse_issues.csv: dictionary row-width problems.
- `../pilot_single_pipeline/selection_decisions.csv`: 698 qualified
  comparison groups and their report-level source choices.
- `../pilot_single_pipeline/species_traits.csv`: provisional selected values
  carrying chosen point IDs and evidence fields.
- `../pilot_single_pipeline/primary_relay_check.csv`: the verified
  Buchsbaum-to-Kaufman pair, with both source locators.

For example, the review queue can be queried from R:

    con <- DBI::dbConnect(RSQLite::SQLite(),
                          "__measurements/pilot_single_pipeline/pilot_single_pipeline.sqlite")
    DBI::dbGetQuery(con,
      "SELECT item, blocker_codes, COUNT(*) AS n
       FROM point_metadata WHERE qualification_pass = 'FALSE'
       GROUP BY item, blocker_codes ORDER BY n DESC")
    DBI::dbDisconnect(con)

Next production work would promote the checked role, method, and taxon
decisions into the shared measurement builder and keys, then rerun a final
gate on the selected merge outputs. The pilot reports are review artifacts;
production __merging_* outputs still follow their current rules.
