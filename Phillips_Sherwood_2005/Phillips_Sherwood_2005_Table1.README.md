# Phillips_Sherwood_2005_Table1

Table 1 | Simple Reaching Handedness Index (HI), Tube Task Mean HI, and Asymmetry Quotients (AQ) for Central Sulcus Depth for Each Monkey. Source: `Phillips-2005-Primary-motor-cortex-asymmetry-i.pdf`, PDF page 3 (journal page 1703), DOI in `__ReadMe.xlsx`.

## Build

Table 1 gives per-individual data for the 7 male capuchins of the Hiram College colony: simple reaching handedness index (HI) and z-score, tube-task mean HI (MHI) and z-score, and the asymmetry quotient (AQ) for central sulcus depth measured from MRI. Handedness was measured on the coordinated bimanual tube task (and a simple reaching task); the AQ is the only anatomical value printed — no per-hemisphere central sulcus depths appear anywhere in the paper.

From the paper folder, run:

```sh
Rscript Phillips_Sherwood_2005_Table1_snapshot.R
Rscript Phillips_Sherwood_2005_Table1.R
```

The snapshot script captures the table programmatically from the frozen publisher PDF in this folder (snapshot HOWTO method 3: poppler `pdftotext -bbox` word geometry clustered into the printed rows and columns; no value typed by hand) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Phillips_Sherwood_2005_Table1.R`. The R script reads only its item snapshot and writes `Phillips_Sherwood_2005_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Sign conventions** (printed table note): negative HI scores indicate a preference for the left hand, positive HI scores a preference for the right hand; positive central-sulcus AQ indicates right-hemisphere dominance. A handedness classification can be derived from the tube-task z-scores with the paper's own rule (|z| > 1.95 = unambiguous preference): L for CA003, CG29 and H02; R for H03, CA9207 and H06; A for H04 — which agrees with the dextral groups printed for the same animals in Phillips_Sherwood_2007_Table1.
- **Species.** The paper prints *Cebus apella*; the analysis CSV resolves to *Sapajus apella* (the name used by the dataset's species key) and keeps the printed form in `Species (printed)`.
- **Sex** is not printed in the table; the Subjects text states the seven subjects are all male, and the build carries Sex = M on that basis.
- **The 7 coded animals are named in the 2007 petalias paper.** Each code's tube-task MHI and z match exactly one named animal in Phillips_Sherwood_2007_Table1: CA003 = Vincent (−1.00 / −14.59), H03 = Alou (0.81 / 7.40), CA9207 = Miro (1.00 / 7.02), H04 = Shoeless (−0.14 / −0.68), CG29 = Carlos (−0.95 / −8.61), H02 = Sosa (−0.62 / −8.64), H06 = DiMaggio (0.39 / 10.44). This is a probable-grade inference from exact value matches, not a printed identification; the codes are kept as printed and the mapping is recorded in the Note column.
- **Printed anomaly, kept verbatim:** the simple-reaching z-scores do not always carry the sign of the simple-reaching HI (CA003: HI −0.84, z 6.52; H04: HI −0.61, z 4.34; CG29: HI 0.25, z −1.79). The tube-task columns are internally consistent. Nothing has been "corrected".
- **Capture notes.** The PDF's minus glyph is the APA font's U+2AFA; the snapshot preserves it and the build converts it to ASCII "−" for numeric analysis. The snapshot was captured programmatically and checked against an independent extraction of the same page; human visual signoff remains pending in the registry. No merge is performed by this build.
