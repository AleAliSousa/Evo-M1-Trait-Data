Source

1. Herculano-Houzel, S., Ribeiro, P. F. M., Campos, L., da Silva, A. V.,
Torres, L. B., Catania, K. C., & Kaas, J. H. (2011). Updated neuronal
scaling rules for the brains of Glires (rodents/lagomorphs). Brain,
Behavior and Evolution, 78(4), 302–314.
https://doi.org/10.1159/000330825 — open access, PMCID PMC3237106.

2. Frozen sources kept verbatim in this folder: the publisher PDF of
the article (Herculano-Houzel-2011-Updated_neuronal_sca.pdf, supplied
by the curator) and the PubMed Central full text
(fulltext.html, https://pmc.ncbi.nlm.nih.gov/articles/PMC3237106/).

--> USE THIS FILE: fulltext.html (Table 1 is captured from the PMC
rendering; the PDF is the cross-check — its text layer agrees with
the PMC values on every checkable cell but corrupts the ± and ×
glyphs. The Europe PMC fullTextXML endpoint returned a server error
when the snapshot was made, 2026-11-20, so the PMC HTML was frozen
instead of the XML used for some other items.)

Build: `HerculanoHouzel_etal_2011_Table1_snapshot.R` captures Table 1
verbatim into `HerculanoHouzel_etal_2011_Table1_snapshot.csv`;
`HerculanoHouzel_etal_2011_Table1.R` reads only the snapshot and
writes `HerculanoHouzel_etal_2011_Table1.csv` and the DOI-coded
public TSV. See `HerculanoHouzel_etal_2011_Table1.README.md` for the
data role (primary source for the Glires rows re-reported by
Herculano-Houzel et al. 2015), the fidelity checks and the caveats.
Registry row in `__ReadMe.xlsx` added 2026-11-20 via
`_tools/registry_apply.R`.

Quality Notes:

1. The 2011 table prints one demonstrable misprint: prairie dog brain
   neurons 473.94 × 10^6, a digit transposition of 437.94 × 10^6 (its
   own parts sum; the 2015 compilation prints the corrected value
   with the same SD). The built table stays verbatim; the
   isotropic-fractionator merge corrects the cell in a guarded block
   (compiled.R §3.4d).
2. The rabbit cerebellum counts printed here (396.67 × 10^6 neurons,
   124.58 × 10^6 other cells) confirm that the O/N of 1.222 printed
   for that cell in Herculano-Houzel et al. (2015) Table 2 is an
   error in the 2015 paper (the counts give 0.314). This item takes
   precedence over the 2015 tables in the merge, so the correction
   lands as a merge derivation from these primary counts.
3. The paper prints no densities and no O/N ratios.
