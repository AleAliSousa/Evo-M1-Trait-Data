# Smith & Jungers 1997 — Table 5 body masses

Smith, R. J., & Jungers, W. L. (1997). Body mass in comparative primatology. *Journal of Human Evolution*, 32(6), 523–559. https://doi.org/10.1006/jhev.1996.0122

## Source item built — 2026-11-26

Table 5, PDF pp. 16–26 / printed pp. 538–548, is a literature compilation with some previously unpublished measurements. The local full-text PDF is `Smith-1997-Body mass in compara.pdf`. `Smith_Jungers_1997_Table5_snapshot.py` reads the held PDF text layer page by page, records page and source line, original family/species labels, the four male/female sample-size and kg cells as printed, and the full raw line. It includes no-data taxa and multiple population/source lines under a species. The item R reader produces a CSV and a public DOI-coded TSV. Exact decimal values are converted from printed middle-dot decimals; uncertain/approximate cells (`?`, `~`, `<`, `>`) remain as printed strings with numeric value blank.

Run `python3 Smith_Jungers_1997/Smith_Jungers_1997_Table5_snapshot.py`, then `Rscript --vanilla Smith_Jungers_1997/Smith_Jungers_1997_Table5.R`. Both ran on 2026-11-26. The snapshot contains 317 source-layout rows, all 249 species labels in the printed table, and 18 species-label rows without mass cells. Its 299 numeric rows fall under 231 labels. The article abstract says adult masses for 230 species; this one-species count difference, and text-layer parsing of wrapped comments/references, warrant page-image review before treating any row as merge eligible. Each raw line is retained, but linewrapped reference text is **not** reconstructed as a complete citation. Human visual signoff is pending.

## Overlap and merge status

This is a **built source table**, not 317 new independent biological observations. The existing body-mass merge includes values derived from Smith & Jungers through later compilations (including Kamilar & Cooper 2013 and Kappeler & Pereira 2003). Among 231 labels with a printed numeric mass, 33 lack an exact spelling match in `__merging_body/body_long.csv`; that is a naming screen, not proof of 33 uncovered taxa or measurements. Resolve synonyms, sex, population and original study citations before any merge wiring. Keep the paper's compilation role distinct from primary specimen samples.
