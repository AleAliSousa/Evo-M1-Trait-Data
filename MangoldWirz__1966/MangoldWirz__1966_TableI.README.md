# Mangold-Wirz (1966), Table I

Source: Katharina Mangold-Wirz, *Cerebralisation und Ontogenesemodus bei Eutherien*, Acta Anatomica 63(4):449–508, DOI 10.1159/000142809. The source PDF is in this folder.

The `_source.tsv` is a transcription of the printed table on pp. 456–462. The build script creates the local CSV and public TSV. `body_as_printed`, `brain_as_printed`, `TI_as_printed`, group, footnotes, and page retain source provenance. `body_weight_g` converts printed kilograms to grams; ranges have no scalar value. Historical taxon labels are retained.

This table combines literature values and the author's analyses. Rows marked `Stephan` are explicitly borrowed. Three cetacean rows footnoted as the author's own analyses have `data_role=primary`. Every row has `merge_eligible=FALSE`: the author's measurements do not report enough specimen, age, or brain-preparation detail to treat them as independent species means, and some printed body weights disagree sharply with modern species means. All masses remain accessible for comparison, pending source-level overlap and taxon review. `Desmodus rotundus` has implausible printed masses and is withheld. The Table I `TI` is the paper's total-brain cerebralisation index, not brain mass or a modern encephalization quotient.

Rebuild: `python3 MangoldWirz__1966/build_tables.py`. Do not treat a blank `source_flag` as proof of independent measurement.
