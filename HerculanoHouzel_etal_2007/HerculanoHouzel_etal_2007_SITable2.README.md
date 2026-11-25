# Herculano-Houzel et al. 2007 — SI Table 2

Charvet et al. Figure 8 uses the six primate **Cortex** rows; the tree shrew is excluded from that series. The paper's Methods state that one hemisphere was processed and doubled for the published values. The unilateral coordinates and caption's 1.036 g/cm³ conversion are assembled in `../Charvet_etal_2013/internal_checks/Charvet_etal_2013_Figure8_source_points.README.md`.

**Source.** Herculano-Houzel, S., Collins, C. E., Wong, P., & Kaas, J. H. (2007). Cellular scaling rules for primate brains. *PNAS*, 104(9), 3562–3567. DOI: 10.1073/pnas.0611396104. The publisher's HTML supporting table is frozen locally as `index.html`; its link is also exposed by `fulltext.html`. The printed title is “Table 2. Cellular composition of primate brains.”

**Scope.** The HTML has three sections in order—Cortex, Cerebellum, and Remaining areas—with seven species each. The source-order snapshot retains each section heading, its own printed header row, all 21 data rows, source spellings, SDs where printed, and the source's replacement glyph `�` for the mean–SD separator. The footnote explicitly says all values are mean ± SD. The R reader converts cell counts to absolute counts; densities remain cells/mg. It keeps both the printed species name and the analysis name. *Otolemur garnetti* is resolved to *O. garnettii* using this paper's Methods; printed *Cebus apella* is carried as *Sapajus apella* following the existing Table 1 item.

**Source erratum.** The HTML prints `931.03 x 10^9` non-neuronal cells for the macaque cerebellum and `966.52 x 10^9` for its remaining areas. These are inconsistent with its own whole-brain total (7,162.90 × 10^6 non-neuronal cells), the cortex value (5.27 × 10^9), and the listed densities and masses. The snapshot preserves `10^9`; the analysis CSV/TSV interprets both as `10^6` and marks those two rows in `source_exponent_note`. No other printed value is corrected.

**Build.** From the repository root:

```sh
Rscript --vanilla HerculanoHouzel_etal_2007/HerculanoHouzel_etal_2007_SITable2_snapshot.R
Rscript --vanilla HerculanoHouzel_etal_2007/HerculanoHouzel_etal_2007_SITable2.R
```

The snapshot script parses only `index.html` and refuses to overwrite a differing snapshot. The item reader uses only its frozen snapshot and looks up its DOI-coded TSV filename in `__ReadMeAddON.xlsx`. Output: 21 structure-by-species rows and the matching public TSV. The seven species are the same sampled animals behind Table 1; inspect specimen overlap and later compilations before merging. Human source-to-snapshot visual signoff remains pending. No figure-derived dataset is created here, so no figure replot applies.
