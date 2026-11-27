# Hertz & Clausen 1963 Table 1

The source is `Hertz-1963-Effects of Potassium and Sodium on.pdf`, printed p. 530,
PDF p. 5. `Hertz_Clausen_1963_Table1_snapshot.csv` is a manual transcription of
all 14 printed tissue rows, in source order, with the two rate columns, their
parenthetical tissue-sample counts, and the printed stimulation percentage.
The page image and text layer were inspected on 2026-11-26; the centered dot in
numbers is a decimal mark and is parsed in the item R reader. No human visual
sign-off is claimed.

Run `Rscript Hertz_Clausen_1963/Hertz_Clausen_1963_Table1.R` from the repo root.
It writes the 14-row analysis CSV and the registry-coded public TSV. The DOI
`10.1042/bj0890526` and page range 526–533 were verified against PubMed on
2026-11-26, added to the registry, and the reader then regenerated the CSV
byte-identically and created a TSV with the same 14 rows and cells.
The rate unit is µmol O₂/g fresh weight/hour, as printed. The with-KCl header
prints 48 mM added, while the caption describes a final concentration of 50 mM;
both statements are retained. Parenthetical counts are **tissue samples**, not
animals; 21 calves were studied in total and multiple samples could come from
one animal. The printed stimulation column is based on an extrapolated and
corrected comparison, not a simple ratio of the displayed rate columns.

`Species` remains blank because the paper's source label is only “calf”; the
accepted species and Order need source-backed curation before a species merge.
This ex-vivo assay is separate from the current in-vivo cerebral-metabolic pool.
The Hertz value cited via Mink et al. 1981 must be linked as the same source,
not pooled again as an independent measurement.
