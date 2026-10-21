# Felleman & Van Essen 1991 — Table 2

Source: Felleman, D. J., & Van Essen, D. C. (1991). Distributed hierarchical processing in the primate cerebral cortex. *Cerebral Cortex, 1*(1), 1–47. https://doi.org/10.1093/cercor/1.1.1

`Felleman_VanEssen_1991_Table2_snapshot.csv` transcribes both printed pages of Table 2. The analysis CSV preserves absolute surface area and each reported percentage denominator. The source table is a synthesis measured from the authors' Figure 2 two-dimensional macaque cortical map, not a new per-animal experimental series, so `data_role` is `secondary synthesis` and the source's taxonomic precision (`Macaca sp.`) is retained.

The authors state that individual-area estimates are generally accurate only to about a factor of two. Visual-lobe totals reproduce the printed visual-cortex total exactly. The listed visual and nonvisual neocortical components sum to 9,770 mm², 200 mm² less than the printed 9,970 mm² total. Results text instead gives 9,940 mm²; that value, unlike 9,970, is consistent with the text's 10,575 mm² total cerebral cortex after adding 635 mm² of non-neocortex. The table remains canonical in `area_mm2`, while `alternative_text_area_mm2`, `component_sum_mm2`, and row-level flags preserve the conflicts.

Two regional values also differ between locations: prefrontal cortex is 920 mm² in Table 2 versus 930 mm² in text, and cingulate cortex is 520 versus 450 mm². Cross-study flags link the approximately 100 cm² macaque total and V2 at 12.2% here to Van Essen & Drury's 72 cm² and approximately 9% values. These estimates should not be pooled without reconciling specimen, reconstruction method, and denominator.
