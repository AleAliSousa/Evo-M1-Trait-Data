# Sarko et al. 2011 — Results text

Source: Sarko, D. K., Leitch, D. B., Girard, I., Sikes, R. S., & Catania, K. C. (2011). Organization of somatosensory cortex in the northern grasshopper mouse (*Onychomys leucogaster*), a predatory rodent. *Journal of Comparative Neurology, 519*(1), 64–74. https://doi.org/10.1002/cne.22504

`Sarko_etal_2011_ResultsText_snapshot.csv` is a constructed frozen snapshot of the six cortical-area summaries reported on p. 68: total neocortex, V1, and the posteromedial barrel subfield (PMBSF) of S1 for juveniles and adults. The source reports means with `±` values but does not identify those values as SD or SEM, so the cleaned file uses `reported_plusminus_area_mm2` and explicitly leaves the statistic unresolved. The source's approximate percentages are retained only where printed.

The juvenile PMBSF value is printed as 0.90 mm², approximately 5% of a 36.70 mm² neocortex. That arithmetic gives 2.45%, not 5%. The builder preserves the printed 5% in `approx_pct_neocortex`, supplies the arithmetic result in `recomputed_pct_neocortex`, and flags the row. Both age groups are also marked as small samples (juvenile n=2; adult n=4).
