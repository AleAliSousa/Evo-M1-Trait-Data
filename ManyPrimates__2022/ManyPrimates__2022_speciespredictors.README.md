# ManyPrimates 2022 — species predictors

ManyPrimates et al. (2022). The evolution of primate short-term memory.
Animal Behavior and Cognition 9(4), 428–516.
DOI: 10.26451/abc.09.04.06.2022.

## Source and frozen copy

The author's species_predictors.xlsx workbook is the source. Its
"Compilation for paper" sheet has 41 species rows and 41 populated columns:
four identity fields, life_expectancy, and 12 further predictors each
followed by a Source and Comments column. The workbook also has iv_models,
species, sources_iv_models, and HomeRange sheets. Those sheets remain in the
snapshot but are not additional rows of this item.

Run ManyPrimates__2022_speciespredictors_snapshot.R to copy the entire
born-digital workbook byte-for-byte to
ManyPrimates__2022_speciespredictors_snapshot.xlsx. The snapshot keeps
all five sheets, including repeated Source/Comments headers, row order,
cell types, and unused presentation cells. The snapshot is evidence;
the separate item script reads only its "Compilation for paper" sheet.

## Analysis output

Run ManyPrimates__2022_speciespredictors.R to write the 41-row
ManyPrimates__2022_speciespredictors.csv and the registry-named TSV in
__Public/comparative-data/. The script looks up its Item encoded value by
Item name in the live __ReadMe.xlsx registry. Existing Species and
vocal_repertoire_types column names and vocal numeric values are retained
for downstream users.

The 13 predictor value fields are:

| Analysis column | Printed source column | Companion citation/comment fields |
| --- | --- | --- |
| life_expectancy | life_expectancy | None printed |
| color_vision | color_vision | color_vision_source, color_vision_comment |
| vocal_repertoire_types | vocal_repertoire (# vocalization types) | vocal_repertoire_source, vocal_repertoire_comment |
| group_size | group_size | group_size_source, group_size_comment |
| home_range | home_range | home_range_source, home_range_comment |
| day_journey_length | day_journey_length | day_journey_length_source, day_journey_length_comment |
| resting_time_percent_activitybudget | resting_time_percent_activitybudget | resting_time_percent_activitybudget_source, resting_time_percent_activitybudget_comment |
| feeding_budget | feeding_budget | feeding_budget_source, feeding_budget_comment |
| dietary_breadth | dietary_breadth | dietary_breadth_source, dietary_breadth_comment |
| diet_diversity | diet_diversity | diet_diversity_source, diet_diversity_comment |
| percent_frugivory | percent_frugivory | percent_frugivory_source, percent_frugivory_comment |
| terrestriality | terrestriality | terrestriality_source, terrestriality_comment |
| body_size_kg | body_size (kg) | body_size_kg_source, body_size_kg_comment |

The source also supplies species_latin, species_english, family, and
superordinate_group. Species replaces the underscores in species_latin
with spaces. Common name, family, group, categories, numerical strings,
citations, and comments are retained without source-level interpretation;
line breaks inside citation cells become spaces in the analysis CSV/TSV.
All 13 predictors are compiled reports and are labeled secondary at the
item level; a cited paper is not automatically the original measurement
source. The species-specific citation and comment stay beside each value.

The source sheet gives no paired Source/Comments for life_expectancy. It
does not state units for life_expectancy, group_size, home_range,
day_journey_length, feeding_budget, or dietary_breadth; these require
source-specific review before comparable pooling. Resting time and
frugivory explicitly print percent in their headers, and body size prints
kg. The definitions file records these limits rather than supplying
guessed units or methods.

Thirty-nine species have values in each of the 12 cited predictor blocks;
Cercopithecus hamlyni and Allenopithecus nigroviridis have blank values
there. All 41 have a life_expectancy value. This yields 509 nonblank
predictor cells. Comments flag congeneric substitutions and other
provenance issues that must be checked per value.

The live registry already has the item row
ManyPrimates__2022_speciespredictors with data role "both"; the row has
not been edited by this rebuild. The workbook's provenance does not make
its individual predictor cells primary observations.
