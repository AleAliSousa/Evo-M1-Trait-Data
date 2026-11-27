# Baizer et al. 2014 — documented note (qualitative observations; no registered item)

Baizer, J. S., Sherwood, C. C., Noonan, M., & Hof, P. R. (2014). Comparative organization of the
claustrum: what does structure tell us about function? *Frontiers in Systems Neuroscience*, 8, 117.
https://doi.org/10.3389/fnsys.2014.00117 — local `baizer_etal_2014.pdf` (10 pp.).
Decision made 2026-10-28 by an AI assistant (Claude Science) after reading the text layer and the two
existing constructed snapshots; owner may overrule (recipe below).

## Decision: no R build / analysis CSV / registry row

The folder holds two constructed snapshots made earlier from text and figures
(`Baizer_etal_2014_claustrum_islands_snapshot.csv`, 4 rows; `Baizer_etal_2014_dorsal_enlargement_snapshot.csv`,
2 rows; documented in `Baizer_etal_2014_claustrum_islands_snapshot.README.md`). They are kept as
documented qualitative evidence, untouched. They are **not** promoted to a dataset item because:

1. **No contrast in the observed character.** All four island rows are `yes` (clusters observed); the
   paper codes no negative states, so the character carries no between-taxon variation except the
   `island_pattern_class` (few_local_clusters vs many_dispersed_islands).
2. **That class is our coding inside a "snapshot".** It is an analytical interpretation of the
   abstract/conclusion, which the snapshot HOWTO forbids in a frozen source (coding belongs in the R
   step). A build would first need the snapshot re-cut to printed phrases only.
3. **Review paper; little new measurement.** The only numbers are approximate whole-claustrum extents
   of an unattributed gorilla brain (text PDF p. 6: claustrum "present over about 33 mm" rostrocaudally,
   dorso-ventrally "as far as 20 mm"; brain rostro-caudal extent "about 130 mm") and a cited cat value
   ("about 11 mm", Snider and Niemer 1961, PDF p. 2). Single specimen, "about", and the gorilla
   individual is not identified among the two brains examined.
4. **Reused evidence.** Figure 5 redraws Kowiański et al. (1999) Figure 7; cat/macaque enlargement
   observations rest on earlier archival work (LeVay & Sherk 1981a,b; Baizer et al. 1993, 1997).
5. **Overlap.** The dolphin island observation overlaps `Buchanan_Johnson_2011_ResultsText`, whose
   registry note already warns not to merge with a Baizer island class without harmonisation.

Note for the owner: the paper folder now has `_snapshot` files but no CSV/README/definitions, so
`audit_dataset_item()` reports MISSING for csv/definitions — expected for this documented skip.

## Source roadmap

`reference_tables/Baizer_etal_2014_references.csv` — 7 works the paper relies on for reused or cited
observations (Kowiański et al. 1999; Snider & Niemer 1961; LeVay & Sherk 1981a, 1981b; Baizer et al.
1993, 1997; Buchanan & Johnson 2011), keys as printed, bibliography verbatim (diacritics restored
from the page where the text layer splits them).

## If the owner wants an item later

Mirror `Buchanan_Johnson_2011_ResultsText`: re-cut a constructed `Baizer_etal_2014_ResultsText_snapshot.csv`
holding only printed phrases + figure/page loci (and the gorilla 33 mm / 20 mm text values), derive
`island_pattern_class` in `Baizer_etal_2014_ResultsText.R`, data role `primary` for the gorilla,
dolphin and whale archival observations and `secondary` for Figure 5, Item number "Results Text"
(→ Item encoded `10.3389%2Ffnsys.2014.00117_ResultsText` by the house formula).
