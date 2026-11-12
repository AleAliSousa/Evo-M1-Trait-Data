# Van Essen & Drury 1997 — Table 1 (surface area of cortical lobes, Visible Man)

Van Essen, D. C., & Drury, H. A. (1997). Structural and functional analyses of human cerebral cortex using a surface-based atlas. *Journal of Neuroscience, 17*(18), 7079–7102. https://doi.org/10.1523/JNEUROSCI.17-18-07079.1997

The item contains the per-hemisphere Table 1 areas for the Visible Man: total neocortex, five lobes, and sulcal and gyral totals (16 rows). `VanEssen_Drury_1997_Table1_snapshot.xlsx` preserves Table 1 (its sheet `text_V1` is an older note of the V1 text values and is not read).

The Visible Man is one adult male cadaver digital atlas reconstructed from 1 mm section images. Areas are tile-area sums on the three-dimensional reconstruction, not flat-map areas, and the authors consider the total a slight underestimate.

**Update 2026-11-10.** The Results-text values (human V1 and estimated visual cortex, the macaque case 79-0 comparison, and the human V1 ranges the authors cite) moved to their own item, `VanEssen_Drury_1997_Text`, when the owner replaced `VanEssen_Drury_1997_Table1_text_snapshot.csv` with `VanEssen_Drury_1997_Text_snapshot.csv` (9 Nov 2026). The R script no longer reads a text snapshot; this item's CSV and TSV now hold the 16 Table 1 rows only (they held 22). The macaque flags (case 79-0 from Drury et al. 1996a; 72 cm² versus Felleman & Van Essen's 99.4 cm²) now sit on the macaque rows of `VanEssen_Drury_1997_Text`, and `Drury_etal_1996_Table2` shows that 72 cm² is the whole case 79-0 cortex (7,205 mm²), not its neocortex (6,878 mm²). R NOT RUN: the 10 Nov CSV was written by a Python mirror (identical to the Table 1 rows the R script wrote before).

The live registry uses `VanEssen_Drury_1997_Table1`; the R script writes the DOI-coded public TSV from that row.
