# González-Lagos, Sol & Reader 2010 — Appendix I references

The publisher PDF in this folder prints 43 brain/body source citations in Appendix I, but does not publish the 493-species measurement table or a species-to-source map. This item is a bibliography and local coverage audit, **not** 493 brain or body observations.

`GonzálezLagos_etal_2010_AppendixI_snapshot.csv` freezes the citations in source order with line wraps normalized. The source citation column was checked against the PDF; page-footer text from the two-page appendix was removed. `_checks/gonzalez_lagos_appendixI_source_audit_2026-11-26.csv` classifies exact local source coverage: 14 exact cited publications with brain items, three false author/year candidates, and 26 without a verified exact brain item. These statuses do not establish the original authors' per-species input values.

Run `Rscript --vanilla 'GonzálezLagos_etal_2010/GonzálezLagos_etal_2010_AppendixI.R'` from the repository root to join the frozen citations with the coverage audit and regenerate the 43-row item CSV and public TSV. No figure is involved, so a replot is not applicable. The missing 493-species table stays a separate source acquisition task.

## Related coauthor data leads

- [Sol, Bacher, Reader & Lefebvre 2008](https://www.journals.uchicago.edu/doi/10.1086/588304) shares Sol and Reader. Its journal page identifies a supplemental PDF (`42861apa.pdf`) with Table A1 on brain measures and sources of appendix brain data. This is a promising **separate** source to obtain and inspect; the page does not prove its values are the 2010 table's values.
- [Reader & MacDonald 2003](https://www.mcgill.ca/reader-lab/publications) is an exact Appendix I citation (GL2010-A26). The Reader Lab publication list advertises a brain component volume appendix, but its linked PDF currently returns 404. Recover that exact appendix before claiming measurements from it.
- `Reader_etal_2011_Data.csv` is a locally built later Reader dataset about primate innovation and behavior. It has a shared coauthor, but its variables and date do not make it the 2010 mammal brain table.
- [Gonzalez-Voyer et al. 2016 Dryad](https://datadryad.org/dataset/doi%3A10.5061/dryad.m2tj3) is a separate 596-species brain compilation by different authors. It is not an established descendant or replacement for the unavailable 2010 dataset.
