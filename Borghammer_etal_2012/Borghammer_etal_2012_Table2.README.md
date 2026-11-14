# Borghammer et al. 2012 — Table 2

**Citation:** Borghammer, P., et al. (2012). Glucose metabolism in small subcortical structures in Parkinson's disease. *Acta Neurologica Scandinavica*, 125(5), 303–310. DOI: 10.1111/j.1600-0404.2011.01556.x.

**Source locus:** Table 2, “Normalized CMRglc values in subcortical VOIs,” journal p.307, PDF page 5 of `Borghammer-2012-Glucose metabolism in small su.pdf`. The original folder was named `Borghammer_etal_2011` after the DOI year; it was aligned to the article and registry year, 2012. The supplied `ane_1556_sm_tablesi_s2-figures1.doc` remains an untouched supplementary source in this folder.

## Build

`Borghammer_etal_2012_Table2_snapshot.R` extracts the PDF text layer into the frozen `Borghammer_etal_2012_Table2_snapshot.csv`. Its first three rows retain the caption and nested column headers; the 18 printed data rows remain under their region headings in printed order. The printed `±` is encoded as U+0006 in the PDF text layer; the snapshot script restores the visible glyph. The four footnote lines are retained. The script refuses to replace a frozen snapshot with different bytes without review.

`Borghammer_etal_2012_Table2.R` reads only this snapshot and writes 108 analysis rows: 18 structure/side rows × three reference normalizations × two clinical groups. It preserves every cell as printed, parses the two numeric components and any significance stars, and keeps right and left values separate. `*` means P < 0.05 uncorrected; `**` means P < 0.05 after Bonferroni correction. The table does not label the quantity after `±`, so its dispersion type remains unspecified. These are relative CMRglc ratios, not absolute rates. The groups are human controls and PD patients; Table 1 lists 11 and 21 participants, respectively, across the two centers. Group summaries must not be counted as independent species observations.

The printed values were checked against a rendered view of PDF page 5 by the AI assistant on 2026-11-12. **Human side-by-side visual curation remains pending.** The companion definitions file records variables, units, provenance, and observation level.

## Registry and export

The live registry has a Borghammer et al. 2012 citation row with the correct caption but no `Item number`. Its generated `Item name` and `Item encoded` therefore end with `_`, which is not a valid public item stem. The item script writes the analysis CSV and exports a public TSV when an exact `Borghammer_etal_2012_Table2` row with a complete encoded stem is present. The item-scoped registry row file proposes setting `Item number` to `Table 2` and records the remaining metadata for owner paste. No public TSV or completed registry state is asserted before that update.

## Supplement

The supplied legacy Word `.doc` contains Supplementary Table 1 (absolute CMRglc across centers) and a Supplementary Table 2 on voxel coordinates. Supplementary Table 1 is built separately as `Borghammer_etal_2012_TableS1`; its Word-to-HTML conversion retains the printed `±` glyph and table cells. Supplementary Table 2 loses cell boundaries in the tested converters and still needs a reliable visual transcription. Neither supplementary table is folded into this item.
