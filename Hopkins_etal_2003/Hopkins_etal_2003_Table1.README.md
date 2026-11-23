# Hopkins et al. 2003, Table 1

Hopkins, W. D., Stoinski, T. S., Lukas, K. E., Ross, S. R., & Wesley, M. J. (2003). Comparative assessment of handedness for a coordinated bimanual task in chimpanzees (*Pan troglodytes*), gorillas (*Gorilla gorilla*) and orangutans (*Pongo pygmaeus*). *Journal of Comparative Psychology*, 117(3), 302–308. DOI: [10.1037/0735-7036.117.3.302](https://doi.org/10.1037/0735-7036.117.3.302).

## Source and scope

The exact local PDF is `Hopkins-2003-Comparative-assessment-of-handedn.pdf`. Table 1, printed page 304 / PDF page 3, lists 31 gorillas and 19 orangutans. `Hopkins_etal_2003_Table1_snapshot.csv` retains all 50 individual rows, the source blocks and order, sex, rearing/facility label, age, left and right hand-use counts, z-score, handedness class, and abbreviation note. The snapshot was taken from the PDF text layer and checked visually against the page on 2026-11-23. The PDF text layer omitted Sulango's z-score; Codex read its printed value −8.24 from the rendered page and recorded that one correction in the snapshot. Human visual signoff remains pending.

The item reader retains the printed counts and z-scores, and derives `pooled_LI_from_counts = (R−L)/(R+L)` for each individual. This pooled index is **not** the paper's mean-across-tests MHI used in later summaries; it must not be substituted for the Püschel compiled statistic without a separate comparison. The paper calls the orangutans *Pongo pygmaeus* in the older broad sense, while the current species identities of these captive individuals are unresolved. The source group remains printed verbatim, and the General species key uses the genus-level `Pongo sp.` anchor rather than assigning them to modern species.

## Internal check and build

The reader recomputes the signed z expected from printed counts using `(R−L)/sqrt(R+L)`. Forty-eight of 50 are within 0.12 of the printed z. Kekla has 9 left/81 right with printed z −7.58 (expected +7.59); Banga has 42 left/80 right with printed z +5.47 (expected +3.44). Both disagreements are retained as printed source-table discrepancies. No source value was changed to satisfy the check.

From the repository root, run:

```sh
Rscript --vanilla Hopkins_etal_2003/Hopkins_etal_2003_Table1.R
```

The script reads only its frozen snapshot, writes the 50-row local CSV and DOI-coded public TSV, and uses `__ReadMeAddON.xlsx` while the main registry is occupied. The table is not figure-derived, so a replot is not applicable.
