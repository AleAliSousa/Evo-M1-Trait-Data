# Van Essen & Drury 1997 — surface-area values printed in the Results text

Van Essen, D. C., & Drury, H. A. (1997). Structural and functional analyses of human cerebral cortex using a surface-based atlas. *Journal of Neuroscience, 17*(18), 7079–7102. https://doi.org/10.1523/JNEUROSCI.17-18-07079.1997

Registry item: **`VanEssen_Drury_1997_Text`** (row "Text"; public TSV `10.1523%2FJNEUROSCI.17-18-07079.1997_Text.tsv`). Table 1 of the same paper is the separate item `VanEssen_Drury_1997_Table1`.

## What the item holds (13 rows)
Every surface-area value the Results text prints, one row per value:

| Rows | Value | Where (journal page) |
|---|---|---|
| 2 | Visible Man V1, average-sized (Rademacher et al. 1993 extents mapped to the atlas): right 22 cm² (2.7%), left 26 cm² (3.4%) | "Estimating the extent of area V1", p. 7089 |
| 2 | Visible Man estimated visual cortex: right 197 cm² (25%), left 164 cm² (21%) | p. 7098 |
| 2 | Macaque case 79-0 (right hemisphere): neocortex 72 cm²; buried cortex 59% | "Comparisons between human and macaque cortex", p. 7098 |
| 5 | Visible Man buried cortex 70% (average); frontal lobe 26% macaque vs 36% Visible Man; occipital lobe 32% vs 19% | pp. 7098–7099 |
| 2 | Human V1 ranges the authors quote: Stensaas et al. (1974) 15–37 cm²; Filiminoff (1932) 22–29 cm², one hemisphere | p. 7089 |

The two quoted ranges are **reference provenance only**: they are not case-level data and must not enter a pooled V1 merge alongside primary values. The Kaskan workbook's derived midpoints are excluded.

## Frozen source and reader
- `VanEssen_Drury_1997_Text_snapshot.csv` — the owner's transcription of the Results text (updated 9 Nov 2026; human check recorded in the registry as 09112026 AdS). The R script only reads it.
- Values were re-read against the PDF text on 10 Nov 2026 by an AI assistant (Copilot): all 13 rows match the printed text.
- `VanEssen_Drury_1997_Text.R` (rewritten 10 Nov 2026) reads the snapshot, keeps every printed value, adds `area_mm2` and the range ends in mm² (cm² × 100), adds row flags, runs the text checks below, writes `VanEssen_Drury_1997_Text.csv` and the public TSV. It no longer stops on a fixed row count (the 9 Nov stub stopped unless the snapshot had exactly 2 rows) and it finds its own folder, so `source()` with a full path works.
- **R NOT RUN:** the CSV and TSV of 10 Nov 2026 were written by a Python mirror of the script. Run `Rscript VanEssen_Drury_1997_Text.R` (or `bash run_all_scripts.sh VanEssen_Drury_1997`) to confirm.

## Table checks
The text's percentages are recomputed from the hemisphere totals in Table 1 of the same paper (frozen `VanEssen_Drury_1997_Table1_snapshot.xlsx`: left 766 cm², right 803 cm²). Tolerance: half the last printed unit plus the effect of the area being printed to whole cm². Result: **12 of 12 pass** (Python mirror).
- V1 share: right 22/803 = 2.74% (printed 2.7); left 26/766 = 3.39% (printed 3.4).
- Visual cortex share: right 197/803 = 24.5% (printed 25); left 164/766 = 21.4% (printed 21).
- Macaque 72 cm² is "only 9% of that for the Visible Man": 72/803 = 8.97%.
- Visible Man buried 70%, frontal 36% and occipital 19% each lie within Table 1's two hemisphere values (70/69, 36/37, 19/18).
- The snapshot's mm² columns equal cm² × 100 for both quoted ranges (4 checks).

## Flags a merge must read (`source_flags`)
- `single_atlas_individual` — Visible Man rows: one adult male cadaver atlas.
- `secondary_value` — Visible Man V1 (Rademacher et al. 1993 extents mapped onto the atlas).
- `secondary_citation_range|not_case_level` — the Stensaas and Filiminoff ranges.
- `secondary_reconstruction|single_case|species_unspecified` — macaque rows (case 79-0 from Drury et al. 1996a).
- `denominator_includes_non_neocortex` — the macaque "neocortex 72 cm²". Drury et al. (1996a) give 72 cm² for the whole case 79-0 reconstruction; their Table 2 (item `Drury_etal_1996_Table2`) has 7,205 mm² total cerebral cortex, of which neocortex is 6,878 mm², the rest hippocampal, transitional and paleocortex. Felleman & Van Essen's 99.4 cm² is a different hemisphere (case 80-G, planimetric flat map).

## Not in the snapshot
p. 7099 also says V1 and V2 occupy "~13% and ~9%" of macaque cortex. These are not in the snapshot; Drury et al. (1996a) Table 2 prints 13.1% and 9.6% for case 79-0. Add them to the snapshot if you want them in this item.
Five rows (macaque frontal/occipital, Visible Man buried/frontal/occipital) have blank `hemisphere`, `method` and/or `data_role` in the snapshot; the reader keeps them blank.

## Species
Visible Man = *Homo sapiens*. Case 79-0 = *Macaca* sp.: Drury et al. (1996a) describe it as a commercially acquired macaque brain of unknown species. Species-key rows: `_keys/General/species_key.csv`, source `VanEssen_Drury_1997`.

## Owner notes (9 Nov 2026, kept)
The source paper PDF is already in this folder. A scan of Filiminoff (spelled Filimonoff in the EndNote filename) 1932 was found in the local EndNote library and copied to `Filiminoff__1932/` for a future primary-source extraction. No Stensaas 1974 PDF was found in the local EndNote PDF directory; its DOI is [10.3171/jns.1974.40.6.0747](https://doi.org/10.3171/jns.1974.40.6.0747). Neither cited primary has been represented here as an independently verified case-level dataset.

Case 79-0 is from Drury 1996a. Drury 1996a says it is a "macaque brain (species unknown) that had been acquired commercially (Carolina Biological. Burlington, NC)".
