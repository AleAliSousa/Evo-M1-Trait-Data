# Brain Museum chimpanzee accession 63-397

## Identity issue

The [Brain Museum chimp atlas](https://brainmuseum.org/specimens/primates/chimp/sections/coronal-cell/thumbnail.html) heads its gallery `#63-307`, but the section images themselves print `63-397`. The gallery filenames use `63-397` except `0285chimp63-395.jpg`; [that image](https://brainmuseum.org/specimens/primates/chimp/sections/coronal-cell/0285chimp63-395.jpg) also prints `63-397` on the slide. Thus `63-307` is an erroneous website heading, and `63-395` is an erroneous image filename, not demonstrated alternate accessions or separate chimpanzees.

## Evidence chain

1. The Brain Museum [gallery](https://brainmuseum.org/specimens/primates/chimp/sections/coronal-cell/thumbnail.html) identifies the taxon as *Pan troglodytes* but prints `#63-307` in the heading. Its [section 60](https://brainmuseum.org/specimens/primates/chimp/sections/coronal-cell/0060chimp63-397.jpg) and [section 285](https://brainmuseum.org/specimens/primates/chimp/sections/coronal-cell/0285chimp63-395.jpg) each visibly print `63-397` on the slide.
2. Fobbs & Johnson 2011 supplementary Table S2, [row 61](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS2.csv), catalogs Welker chimp `63-397`: coronal Thionin/Mahon sections, total 2310. It prints only the common name, so the binomial is taken from the atlas.
3. Heuer et al. 2023 [article](https://elifesciences.org/articles/85907) names the Brain Museum as the source of most histological sections but does not print the chimp accession. Its [source table](../../Heuer_etal_2023/source_data/01_cb_data.csv) points to `chimp_cor_cell`; the [author-repository chimp image](https://github.com/neuroanatomy/comp-cb-folding/blob/main/data/raw/img/cb/chimp_cor_cell.json.cb-50%25.png) visibly prints `63-397`. Heuer and Brain Museum share image provenance; they are not independent specimens.
4. Fobbs & Johnson 2011 supplementary Table S3, [row 127](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS3.csv), lists `W63-397`, *Pan troglodytes*, `Chimpanzee -UW`, coronal, 2324 sections. The `W` prefix and `-UW` label suggest the same University of Wisconsin animal, but S2 reports 2310 sections. Retain its separate canonical registration until museum documentation explains the difference.

## Registry treatment

The Brain Museum, Fobbs S2, and Heuer source-image rows now use `UW-WELKER-63-397` in the public crosswalk. Preserve `63-307` and `63-395` only in notes about the website errors. Do not count the three rows as three animals. Fobbs S3 remains an unresolved possible duplicate and should not be counted as an independently confirmed animal.

The restricted Bush & Allman author-workbook registry also uses `UW-WELKER-63-397`. Its paper-level accession link rests on private evidence and remains in the restricted overlay. The present public evidence establishes the Brain Museum–Fobbs S2–Heuer image chain without exposing that private link.
