# Nelson et al. 2015, Table 1

Nelson, E. L., Figueroa, A., Albright, S. N., & Gonzalez, M. F. (2015). Evaluating handedness measures in spider monkeys. *Animal Cognition*, 18, 345–353. [DOI](https://doi.org/10.1007/s10071-014-0805-5).

## Source and scope

The open [author PDF](https://faculty.fiu.edu/~elnelson/2015%20-%20Nelson%2C%20Figueroa%2C%20Albright%2C%20Gonzalez%20-%20Animal%20Cognition%20-%20Evaluating%20handedness%20measures%20in%20spider%20monkeys.pdf) is frozen here as `Nelson-2015-Evaluating-handedness-measures-in-spider-monkeys.pdf`. Table 1 is on printed page 350/PDF page 6. The snapshot retains its 10 named subjects, rearing, sex, age, TUBE/REACH left and right counts, and HI with preference class in source row and column order. The paper identifies the subjects as *Ateles fusciceps rufiventris*; the analysis maps this to species *Ateles fusciceps* while preserving the source label. MDD lists the subspecies under this species.

`Nelson_etal_2015_Table1.R` reads only its frozen snapshot, produces 20 individual-by-task rows, checks all 90-response totals and the published two-decimal HI against `(R-L)/(R+L)`, and writes the local CSV and DOI-coded public TSV. All 20 HI checks pass within printed rounding. TUBE and REACH are distinct tasks; the table does not print a species MHI/MABSHI directly. Compare the task-specific individual data with Püschel S1 Data before adopting a species summary.

Run from the repository root: `Rscript --vanilla Nelson_etal_2015/Nelson_etal_2015_Table1.R`. No figure-derived data are in this item, so no replot applies. Snapshot checked by Codex against the source PDF text and table on 2026-11-23; human visual signoff pending. The registry entry is in `__ReadMeAddON.xlsx` while the main registry is occupied.
