# Weisbecker_etal_2013_TableS1

Weisbecker, V., Ashwell, K., & Fisher, D. (2013). An improved body mass dataset for the study of marsupial brain size evolution. Brain, Behavior and Evolution, 82, 81–82. https://doi.org/10.1159/000348647

The supplied Orlin workbook contains 191 taxon rows in Sheet1; two other sheets are empty. The native file is frozen untouched. Body columns are grams; the “Brain volume (ml)” column becomes endocranial volume mm³ (×1000), following the article’s identification of Ashwell (2008) ECV data. It is not converted to brain mass. Missing sex-specific masses remain missing; mandible estimates never fill them silently.

The publisher article (https://karger.com/bbe/article/82/2/81/326143/An-Improved-Body-Mass-Dataset-for-the-Study-of) explains taxonomic averaging and an adult-only correction for Dendrolagus bennettianus. These are revisions to the Ashwell collection, not an independent sample. The separate Table S2 bibliography is absent from the supplied workbook; literature body-mass source attribution therefore remains unresolved at species level. The named placeholder in the item lookup makes that limitation joinable. Reader checks the stated sex average with 0.5-g rounding tolerance; all original values are retained.

The supplied digital workbook is preserved byte-for-byte. No PDF transcription check applies.

Rebuild with `Rscript Weisbecker_etal_2013_TableS1.R` from any directory. The frozen source is read locally and the registry supplies the encoded public TSV name. Published taxon labels remain unchanged apart from explicitly described formatting. No global species key or unsupported hemisphere conversion is introduced. Source records enter the database and variable catalog; aggregate merge inputs are unchanged pending source/specimen and anatomical mapping.
