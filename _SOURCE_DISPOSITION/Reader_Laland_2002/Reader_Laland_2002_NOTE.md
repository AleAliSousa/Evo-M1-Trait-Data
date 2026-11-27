# Reader & Laland 2002 — documented skip (no per-species values printed)

Reader, S. M., & Laland, K. N. (2002). Social intelligence, innovation, and enhanced brain size in
primates. *PNAS*, 99(7), 4436–4441. https://doi.org/10.1073/pnas.062041299
Local PDF: `reader_laland_2002.pdf` (6 pp.). Inspected 2026-10-28 by an AI assistant (Claude Science):
text layer read in full; figure page (p. 4438) rendered and viewed.

## Why no dataset item

| locus | content | why not built |
|---|---|---|
| Table 1 (p. 4437) | P values from the reanalysis of field-only reports (across-species and contrasts) | test statistics only |
| Figs. 1–2 (pp. 4438–4439) | scatterplots of effort-corrected innovation / social-learning / tool-use frequency vs executive brain ratio, and against each other | points are unlabelled — no species can be attributed to a point |
| Methods, Data Collection (p. 4437) | survey design; totals (533 innovations, 445 social-learning observations, 607 tool-use episodes; 116 of 203 species); "The raw data are available from the authors." | totals only, no species values |

The per-species counts reach the repository only through the `*_2002` columns of
`Reader_etal_2011_Data` (same lineage — resolve, never average; documented in the definitions file).
Nothing was invented.

## Definitions file location

The pre-existing `Reader_Laland_2002_definitions.csv` sat at the folder top level (legacy location).
It was copied byte-for-byte to `reference_tables/Reader_Laland_2002_definitions.csv` (canonical
location) on 2026-10-28, and the top-level copy was put to the owner for removal to Trash so the
variable catalog does not load it twice. If the top-level file is still present, it is an identical
duplicate and should be removed.

## What the paper compiles (roadmap)

`reference_tables/Reader_Laland_2002_references.csv` — numbered refs 51–58 as printed, with the
variable each supplies (bibliography entries verbatim): behavioural counts (51, the authors' 2001
survey); brain volumes from Stephan et al. 1981 (53) and Zilles & Rehkamper 1988 (54), summed by the
authors into executive brain (neocortex + striatum) and brainstem (mesencephalon + medulla
oblongata); body weight from Rowe 1996 (56) / Harvey et al. 1987 (55); group size from Rowe (56),
Smuts et al. 1987 (57), Dixson 1998 (58); phylogeny Purvis 1995 (52). The authors' species
re-identifications of three Stephan 1981 entries (*Saguinus tamarin* → *S. midas*; genus-only →
*Alouatta palliata*, *Cebus apella*, by total brain weight vs ref 55) are recorded in the ref-53 note
as the paper's own claim. Data role if ever built: secondary.
