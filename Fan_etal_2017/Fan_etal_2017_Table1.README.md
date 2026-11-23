# Fan et al. 2017, Table 1

Fan, P., Chen, H., Liu, X., Zhao, D., Zhang, J., Liu, C., & Liu, D. (2017). Preliminary study on hand preference in captive northern white-cheeked gibbons (*Nomascus leucogenys*). *Primates*, 58, 75–82. [DOI](https://doi.org/10.1007/s10329-016-0573-8).

## Source and scope

The exact local PDF is `Fan-2017-Preliminary study on hand preference.pdf`. Table 1 is rotated on printed page 79/PDF page 5. Its snapshot retains nine named subjects, sex, age class, and each printed L, R, Total, P, HI and preference class for ground-reaching, box and tube tasks; the printed Mean (SE) row is also retained. Codex checked the rendered page on 2026-11-23; human visual signoff pending.

The reader reshapes the nine subjects into 27 individual-by-task rows, excluding the printed group mean from analysis to avoid double counting. It checks each printed total against `L+R`. There are **two published total discrepancies**, preserved verbatim: subject 93-1 Ground prints 733 while 285+548=833, and subject Y00-2 Box prints 152 while 59+83=142. The printed HIs 0.316 and 0.169 agree with counts, respectively. The printed mean response counts (387, 137, 190) agree with rounded averages of L+R, rather than the inconsistent printed totals in those two cells. No values were silently corrected.

Run from the repository root: `Rscript --vanilla Fan_etal_2017/Fan_etal_2017_Table1.R`. The reader writes a local CSV and DOI-coded public TSV. The table does not directly identify which task and statistic Püschel uses for its species MHI/MABSHI; compare before any merge. No figure-derived data are in this item, so no replot applies. The registry entry is in `__ReadMeAddON.xlsx` while the main registry is occupied.
