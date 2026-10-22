# GalánAcedo_etal_2019_BodyMass

Galán-Acedo, C., Arroyo-Rodríguez, V., Andresen, E., & Arasa-Gisbert, R. (2019). Ecological traits of the world’s primates. Scientific Data, 6(1), 55. https://doi.org/10.1038/s41597-019-0059-9

Source: Zenodo version 3, record 2600338, `BodyMass.csv`. The original download is copied byte-for-byte to `GalánAcedo_etal_2019_BodyMass_snapshot.csv` (SHA-256 c288ae427a52b25e4ee10b51c583ed5f1fda743cea19204dac9cfea54a99be0f). Reader: Codex, 2026-10-21, readr with Windows-1252 encoding. Frozen raw fields and record order are preserved. 629 records are retained, including records with no numerical trait value. They must not be counted as species with measurements.

The reader keeps both source name columns. Species uses the published Species field and falls back to the published Species (ITIS) field only when the former is missing. Harmonization occurs downstream through the shared resolver. This avoids dropping the 22 named taxa whose Species field is NA. Multiple studies, sites, methods and references remain separate rows.

Numeric derived fields accept only strict numeric scalars. Ranges, NI, NA, decimal-comma strings, malformed counts and Excel-like month/date corruption remain in the original columns and are not silently converted to point estimates. No midpoint is invented. Dietary percentages outside 0–100 are excluded from numeric point fields. kg is multiplied by 1000 for g; ha by 0.01 for km2. An unnamed, entirely empty trailing column in TrophicGuild is removed after checking it is empty.

Numbered references are extracted only for keys cited by this item and stored in the item-scoped references CSV. Source fields remain unchanged; derived *_keys fields separate multi-citations with semicolons. The bibliography source is source_files/References.docx. Historical IUCN status and population trend are explicitly historical.

The R script writes an analysis CSV and public TSV; all columns are documented. Registry-row workbook and source-specific merge mapping are generated with the full ManyPrimates batch. Until owner registry insertion, set DATASET_REGISTRY to the full-batch staging registry. Data role: secondary. Do not average repeated compilations with their primaries or interpret the record count as independent animals.
