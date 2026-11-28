# Barger 2012 dissertation Table 4.1: complete limbic table

Source: Nicole L. Barger, *Social Behavior from a Comparative Neuroanatomical Perspective: The Amygdala in Human Evolution* (UC San Diego dissertation, 2012), printed Table 4.1 p. 176 / local PDF p. 194. The frozen snapshot contains **all 22 printed rows**, in source order: 18 named/coded specimen rows and four unnamed taxon rows. The last *Hylobates lar* row fell below PDF table extraction and was transcribed from the rendered page. Every row was checked against the page image on 2026-11-26; human visual signoff remains pending. This is a printed table, so no figure replot applies.

Run `Rscript Barger__2012/Barger__2012_Table4.1.R` from the repository root. It reads only this item's frozen snapshot and writes the analysis CSV and `__Public/comparative-data/UCSD2012Barger_Table4.1.tsv`. All values are cubic centimeters. Printed `--` and blank cells remain distinct in the snapshot; both become missing numeric cells in the analysis output, never zero. Specimen IDs and taxon spellings remain source-specific; `0I` is visually ambiguous and is retained as printed rather than silently changed to `O1`.

The table combines current Barger analysis (`B12`), rows carrying the printed `B11` and `T04` codes, and Stephan et al. 1981/1987 (`S81`, `S87`). Row-level source codes are retained; the caption identifies `T04` as Teffer et al. 2004 but does not define `B11`. Some rows name a specimen; the `--` rows identify only a taxon and must not be linked to an individual. The entire item is marked **secondary / reference only** so its values cannot be counted as independent primary measurements alongside the journal and Stephan tables. Prefer the original peer-reviewed sources for repeated endpoints. The separately numbered [Table 4.2 continuation](Barger__2012_Table4.2.README.md) contains 23 further unnamed taxon rows.

Disco is linked to the existing public specimen crosswalk. The other named/coded rows are preserved in full but have not been newly adjudicated against collection accessions by this build.

## Disco and taxonomic provenance

Row 20 explicitly pairs `Disco` with *Hylobates concolor* and reports amygdala total 0.270, lateral 0.060, basal 0.086, accessory basal 0.022, central 0.012, and hippocampus 0.998 cc. The amygdala values agree with Disco's left-side Barger et al. 2007 row and Barger et al. 2014 case 19 (*Nomascus concolor*). The later peer-reviewed hippocampus value is **0.950 cc**; the reason for the 0.048 cc difference is unresolved. Use the journal value for analyses and retain the dissertation value for source audit. The [publication audit](reference_tables/Disco_publication_audit.csv) records the endpoint comparison.

The dissertation's Table 3.1 (printed p. 112 / PDF p. 130) has one *Hylobates concolor* F age-22 **right-hemisphere** sample, corresponding to the unique case in peer-reviewed Barger et al. 2012 Table 1. That table omits Disco's name, so the journal-to-name link is marked probable. Table 4.1 does **not** print a hemisphere; its amygdala numbers match the **left** values of Barger 2007. Do not transfer the neuron sample's right laterality to these volumes. The journal's gibbon neuron numbers are pooled group means, not Disco-specific counts.

The Barger 2007 source table labels Disco and YN81-146 only `GIBBON`; its legacy analysis CSV maps both to *Hylobates lar*. That generated taxon field is not a source-printed identification for Disco. Barger 2012 supplies the explicit *H. concolor* label, while MacLeod/de Sousa identify the same physical animal as *H. lar*; the biological species remains unresolved in the crosswalk.

## Snapshot layout correction (2026-11-27)

Restored the printed caption and the Amygdaloid Complex / Hippocampal Formation / Refs. header tier above the original column labels. The R reader skips these two source-layout rows. Run `Rscript --vanilla Barger__2012/Barger__2012_Table4.1.R` from repository root to rebuild the analysis CSV. Independent human source comparison remains separate.
