# Lázaro et al. 2021 — Table 2

“Geographic patterns in seasonal changes of body mass, skull, and brain size of common shrews,” *Ecology and Evolution* 11:2431–2448, DOI 10.1002/ece3.7238. The exact open-access PDF is in this folder. Table 2 spans PDF pages 5–7. The item-specific snapshot script uses the local PDF text layer to freeze 114 printed model-result rows in source order. Run the snapshot script once only; it refuses to overwrite the frozen CSV. The reader retains the source response/predictor labels, F statistic, degrees of freedom, adjusted R², source P string, and printed correlation label. These are regression results about geographic/climate associations, not raw skull or brain measurements. Do not merge as trait observations.

Build command from repository root: `Rscript --vanilla Lázaro_etal_2021/Lázaro_etal_2021_Table2.R`. It reads only its frozen snapshot, writes the analysis CSV and DOI-coded public TSV via `__ReadMeAddON.xlsx`, and preserves source comparison fields. Human visual signoff remains pending. No figure-derived data were extracted.

Layout audit (2026-11-27): Compared printed Table 2 on PDF pp. 5–7. The
snapshot now keeps the caption, six response section rows, blank response
cells on 114 model rows, and both printed page continuations with repeated
headers. The R reader propagates section labels and omits page furniture.
Both snapshot extraction scripts regenerated the corrected grids exactly in
a temporary folder; the analysis CSV rebuilt cell-identically. Human source
signoff remains independent.
