# Schenker 2007 dissertation: specimen audit (2026-11-25)

Source: local `schenker_2007.pdf`, *Comparative Analysis of Broca's Area in Hominoids* (Natalie M. Schenker, UC San Diego, 2007). This audit uses the local 140-page PDF, including printed pp. 71 and 91–106. It does not treat dissertation and published paper as independent animals.

## Chapter II: published minicolumn cohort

Table 2.1 (printed p. 71) lists 20 cases: 11 humans and nine great apes, with specimen ID, hemispheres, sex, age and brain weight. The corresponding peer-reviewed [Schenker et al. 2008](https://doi.org/10.1002/cne.21792) Table 1 prints the same 20 cases and fields, including the axial-section exception for chimpanzee `YN89` (15 µm; all others coronal 20 µm) and the human Amunts/Uylings reuse footnote. Use the 2008 paper as the measurement and cohort source for this chapter. The dissertation adds no proven case-level metadata to that published roster.

## Chapter III: additional named histology series

Table 3.1a–b (printed p. 105) has **14 specimens**: three humans (`SN207/84`, `H9/88`, `CS025`), two bonobos (`Zahlia`, `YN86`), four chimpanzees (`Schimp`, `YN89`, `Bathsheba`, `1548`), two gorillas (`YN82`, `A375`), two orangutans (`YN85`, `Harry`) and one gibbon (`Disco`). Table 3.1a gives uncorrected BA44/45 volumes; Table 3.2 (printed p. 106) adds neuron counts and densities. These two tables and the 14-case processing roster are built as dataset items. Table 3.1b's corrected values are **reference only**, with no analysis/public TSV. A matching peer-reviewed numerical table for the Chapter III named cases was not found in this audit, so the usable dissertation values remain supplemental unpublished endpoints. A matching journal publication would supersede them.

The Chapter III Methods (printed pp. 92–93) add valuable provenance: `YN89` was sectioned axially at 15 µm; `CS025` coronal at 80 µm with thionin; `A375` had cresyl violet staining; most other cases were coronal at 20 µm and Gallyas stained. `Bathsheba`, `A375` and `Harry` were wild born; `1548` has no known origin. `Bathsheba` and `YN86` had limited language training exposure. These details can support later specimen matching and interpretation.

`Schimp` in Chapter III and `Chimp1` in Chapter II are both printed as female, age 22, brain weight 440 g. The dissertation alone does not explicitly equate them, but the existing public crosswalk links `Schimp` to `PAN 1` through Barger 2007 and `Chimp 1` to `PAN 1` through MacLeod 2000. The Chapter III `Schimp` row is therefore linked to that existing canonical specimen, with the public evidence identified in `reference_tables/Schenker__2007_Chapter3SpecimensText_crosswalk.csv`. The 12 `C`-coded chimpanzees in published Schenker et al. 2010 Tables 2–3 still have no direct printed ID link to Chapter III's named cases.

The crosswalk records the 2010 `C` cases separately and now has one Chapter III source row for each of the 14 named specimens. Thirteen link to existing public canonical specimens; `CS025` is a new source-only canonical case. No measurements from different anatomical endpoints are pooled.

**Table 3.1b warning:** 50 of 54 corrected BA44/45 volumes disagree with their printed specimen correction factor; all 54 imply a multiplier near 2.0788. Corrected hemisphere volumes and corrected neuron densities do follow the specimen factors. The entire table is retained only as a source snapshot and diagnostic reference; no corrected Table 3.1b values are exposed as trait data. See the Table 3.1b README and `internal_checks/` for the cell-by-cell comparison.
