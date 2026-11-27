# Morino et al. 2017 Table 3

Source: `Morino-2017-Tube task hand preference in capti.pdf`, Table 3 on
printed p. 406 (PDF p. 4). The manual snapshot preserves the seven printed
rows, their order, left/right/ambiguous counts, mean frequency handedness
index (HI-Freq.), SE, and the superscript `a` on wild siamangs. The PDF page
and snapshot were compared on 2026-11-26; no human visual signoff is claimed.

Run `Rscript Morino_etal_2017/Morino_etal_2017_Table3.R` from the repo root
to rebuild the seven-row analysis CSV. The script checks numeric cells, HI
range, the 37 classified individuals in the sitting row, and the single
secondary row. It also calculates each row's classified total from the three
printed counts without changing any source value.

The rows are **overlapping subsets**, not independent samples. Sitting,
hanging, finger-use, siamang and non-siamang rows must not be summed. The
sample contained 42 captive hylobatids overall, but the sitting row classifies
37 in this table; do not silently replace that printed denominator. Only the
siamang-only rows are assigned *Symphalangus syndactylus* in `Species`;
mixed-hylobatid rows leave it blank. The wild-siamang row is explicitly
secondary data from Morino (2011) and should not be counted again as a new
2017 observation. Owner review of the proposed
`Morino_etal_2017_Table3_registry_row.xlsx` is needed before public export.
