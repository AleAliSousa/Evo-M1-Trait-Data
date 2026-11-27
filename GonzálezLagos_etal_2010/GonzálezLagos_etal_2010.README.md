Source

1. Go to Source: Article
González-Lagos C, Sol D, Reader SM (2010). Large-brained mammals live
longer. Journal of Evolutionary Biology 23: 1064–1074.
https://doi.org/10.1111/j.1420-9101.2010.01976.x

2. Frozen source in this folder: the publisher PDF of the article
(González-Lagos-2010-Large-brained mammals live.pdf), supplied by
Michael Proulx on 2026-11-18. The article's 493-species dataset (brain
mass, body mass and the life-history variables) is NOT in the PDF and
has not been found in a public repository. The open Gonzalez-Voyer et al.
2016 Dryad dataset is a separately authored compilation, **not a verified
descendant** of the 2010 table; it is built as a separate Evo-M1 item
`GonzalezVoyer_etal_2016`. See its item README.

--> USE THIS FILE: González-Lagos-2010-Large-brained mammals live.pdf

Why this paper is in Evo-M1: Castillo-Morales et al. (2016, Open Biology
6:160132) took their encephalization index Ei from it — Ei = ln(brain
mass / body mass^0.64), the slope 0.64 being the allometric slope
estimated from this paper's 493-species brain/body dataset (Castillo's
ref 83). The paper's "residual brain mass" is exactly that quantity:
log[brain mass / body mass^b] with b = 0.64 (Methods).

Methods facts that matter for Evo-M1 (from the paper):
- Brain and body masses are species means compiled from multiple
  sources, listed in the paper's Appendix I; body mass taken from the
  same sources as brain mass when available.
- Where only endocranial volumes were available, brain masses were
  estimated following the corrective procedure of Isler & van Schaik
  (2006) (after Mace et al. 1981) — i.e. the dataset mixes measured
  masses and ECV-derived estimates, per row unflagged in the article.
- Data role: SECONDARY compilation (493 mammal species).

Quality Notes:

1. Appendix I has been built as a separate 43-reference bibliographic item,
   [`GonzálezLagos_etal_2010_AppendixI.csv`](GonzálezLagos_etal_2010_AppendixI.csv), with its own [item README](GonzálezLagos_etal_2010_AppendixI.README.md). It was originally transcribed to
   `Evo-M1-Trait-Data-restricted/__gonzalez_lagos_2010_source_coverage/AppendixI_brain_sources.csv`
   in the restricted repository.
   Its 43 entries are bibliographic leads, not 43 confirmed primary brain
   measurement datasets. Candidate folder matches use author and year only;
   each row remains unverified until the exact brain item, measurement basis,
   and potential upstream duplication are checked. The 493-species data
   table remains unavailable, so no **trait** item has been built from it.

   **2026-11-26 source-by-source pass:** `_checks/gonzalez_lagos_appendixI_source_audit_2026-11-26.csv` checked all 43 printed citations against exact local publication titles and brain/ECV item CSVs: 14 have an exact cited-publication item, 3 earlier author-year folder candidates are different papers, and 26 have no exact brain-data item verified here. This verifies source availability, not which of the 493 species came from a cited work. The missing species-to-source map and unpublished 493-species table still prevent a faithful González-Lagos trait build.

2. The item-level decision is recorded in `_SOURCE_DISPOSITION_REGISTER.md`
   as an item-level `HOLD` for the unavailable species table. Appendix I
   is a built reference item, not a trait dataset. The paper stays
   in its normal folder while that audit is open. If the 493-species file is obtained, assess
   it as a separate dataset item with its own registry row and provenance.

Appendix I transcription: `pdftotext -raw "GonzálezLagos_etal_2010/González-Lagos-2010-Large-brained mammals live.pdf" /tmp/gonz_raw.txt`; the Appendix I section was then transcribed
into citation entries in printed order. Line wraps and hyphenation were
normalized; bibliographic spelling and punctuation otherwise follow the PDF.
The Stephan collection entry has no publication year. No species-to-source
map is present in the article, so Appendix I cannot prove which cited work
contributed a given species value.
