# Deaner et al. 2007 — documented skip (no extractable per-taxon data)

Deaner, R. O., Isler, K., Burkart, J., & van Schaik, C. (2007). Overall brain size, and not
encephalization quotient, best predicts cognitive ability across non-human primates. *Brain,
Behavior and Evolution*, 70, 115–124. https://doi.org/10.1159/000102973
Local PDF: `deaner_etal_2007.pdf` (10 pp.). Inspected 2026-10-28 by an AI assistant (Claude Science):
text layer read in full; figure pages (PDF pp. 5–6) rendered and viewed.

## Why no dataset item

| locus | content | why not built |
|---|---|---|
| Table 1 (p. 118) | r², F, p for regressions of global cognition on body mass, brain mass, progression index, EQ, residuals, neocortex measures — (A) unweighted, (B) weighted, (C) independent contrasts; n = 24 genera (brain) / 20 (neocortex) | model statistics only; no per-genus value |
| Fig. 1 (p. 119), Fig. 2 (p. 120) | scatterplots (8 panels each) of global cognition vs each measure, genus values and contrasts | points are unlabelled — no genus can be attributed to a point, so digitising would yield values without taxa |
| Methods, Data Sources (pp. 116–117) | names the sources of every variable | no values printed |

No supplement is referenced. The per-genus values used (global cognition, genus-mean brain/body
mass, neocortex volumes) are therefore not recoverable from this paper. Nothing was invented.

## What the paper compiles (roadmap)

`reference_tables/Deaner_etal_2007_references.csv` lists the 11 works the Methods name as sources,
with the variable each supplies and the passage (bibliography entries verbatim, author-year keys as
printed). In short: global cognition = Deaner et al. 2006 (built: `Deaner_etal_2006_Table1`, the
rank matrix; the reduced-model estimates are its Fig. 1b) and the Johnson et al. 2002 model (built:
`Johnson_etal_2002_Table1`); brain/body mass = Bauchot & Stephan 1966, 1969 + Stephan unpublished
(via Deaner & Nunn 1999) + Kirk 2006 (*Phaner furcifer*); neocortex = Stephan et al. 1981 (+ Rilling &
Insel 1999 for *Pongo*); derived indices from Stephan et al. 1988 and Jerison 1973. Any of these
values should be ingested from the original sources, never from this paper.

Verbatim bibliography quirks (not corrected): Johnson et al. 2002 is listed as "Bayesian analysis of
multi-study rank data with application to primate intelligence ratings. J Am Stat Soc" — the article
itself is titled "Bayesian analysis of rank data with application to primate intelligence
experiments", *J Am Stat Assoc*. Data role if ever built: secondary.
