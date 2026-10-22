# Braitenberg_Schüz_1998_Text — built in R; re-run after context revision; human visual check pending

Braitenberg, V., & Schüz, A. (1998). *Cortex: Statistics and geometry of neuronal connectivity* (2nd ed.). Springer. DOI: [10.1007/978-3-662-03733-1](https://doi.org/10.1007/978-3-662-03733-1).

**Scope:** a bounded Text item holding the printed statements behind the mouse values that Zhang & Sejnowski (2000) cite as ref. 30, other than Fig. 62 (built separately as `Braitenberg_Schüz_1998_Figure62`).

## Source and legibility

Source PDF: `Braitenberg-1998-Cortex_ Statistics and Geomet.pdf`, SHA-256 `6a47a11f3a81d6bf18f6211f5c75701e2cfa4a4d3121102e4c885a711e07e6e8`. Springer eBook PDF (2012, 243 pages) built from 600-dpi page scans with an OCR text layer. The pages are clearly legible. The OCR layer has errors (e.g. "Schiiz", "9,2x10 4"), so every value here was confirmed on the rendered page images, not only in the text layer.

## Constructed frozen snapshot

`Braitenberg_Schüz_1998_Text_snapshot.csv` is constructed from prose, not a printed table. Each of its five records keeps the printed value, unit and hedging word, the passage, the PDF and printed pages, any printed citation key and an extraction note:

| record_id | printed | where |
|---|---|---|
| cortex_incl_hippocampus_volume_one_hemisphere | about 87 mm³, one hemisphere | Ch. 4, p. 27 (PDF 36) |
| neocortex_volume_one_hemisphere | 56 mm³, one hemisphere | Ch. 4, p. 27 (PDF 36) |
| cortex_thickness_mean_paraffin | 0.65 mm, paraffin-embedded material, excluding hippocampus and fascia dentata | Ch. 31, p. 169 (PDF 166) |
| cortex_thickness_mean_unfixed_estimate | should be between 0.8 and 0.9 mm (unfixed) | Ch. 31, p. 169 (PDF 166) |
| neurons_per_mm2_cortical_surface | about 10⁵ per square millimetre | Ch. 4, pp. 25 and 27 (PDF 34 and 36) |

Interpretation sits apart from the printed facts, in `reference_tables/Braitenberg_Schüz_1998_Text_context.csv`: structure scope, hemisphere scope, statistic, approximate flag, data role, provenance and merge gate, joined one-to-one on `record_id`.

## Values Zhang & Sejnowski 2000 attribute to ref. 30

See `reference_tables/Braitenberg_Schüz_1998_Text_source_crosswalk.csv`.

- **G = 112 mm³** (their Fig. 2 caption; reused in Sect. 5 and 8) is **2 × 56 mm³**: the book prints the neocortex volume for one hemisphere. The doubling is theirs; 112 is not printed.
  - **Read as grey matter.** The book does not say how the 56 mm³ (or the 87 mm³) was measured, nor that it excludes white matter. But p. 27 treats it as neuron-bearing tissue: it multiplies the volume directly by the cortical neuron density of 9.2 × 10⁴/mm³, with no allowance for white matter, to estimate the total number of neurons (56 × 2 × 9.2 × 10⁴ = 1.03 × 10⁷, printed as "1x10⁷ in both hemispheres"; 87 × 2 × 9.2 × 10⁴ = 1.6 × 10⁷). That density comes from the Schüz and Palm (1989) counts on semithin sections, with the Abercrombie correction, in sample areas inside cortical layers II–VI (pp. 23–25). Such a density excludes white matter, so it can only give a sensible total if multiplied by a grey-matter volume. This reading matches Zhang & Sejnowski using 112 mm³ as their grey-matter volume G. It is an inference, not a printed statement.
- **W = 13 mm³** (their Fig. 2 caption) is **not printed anywhere in this edition**. Checked: the full OCR text layer, plus the index entries "white substance" (pp. 129, 133 f., 223) and "volume of the white substance" (p. 133). Page 133 says only that the observed white-substance volume agrees with the square-root-compartment expectation, with no number. Origin unresolved.
  - W cannot be derived as total minus grey from this book: no brain or hemisphere total is printed, and 87 − 56 = 31 mm³ per hemisphere is allocortex including the hippocampus, not white matter.
  - Arithmetic note: with Zhang's G = 112 mm³ and T = 0.85 mm, W × T / G = 0.099 mm. So 13 mm³ is what a white-matter layer about 0.1 mm thick (their D, the average white-matter thickness) under a cortical surface of G / T ≈ 132 mm² would give (0.1 × 131.8 = 13.2 mm³). It may therefore be an estimate rather than a measured volume. Still unresolved: Braitenberg (1978b) and the 1991 first edition are unchecked.
- **Thickness 0.8–0.9 mm** (their Sect. 4) is the book's p. 169 estimate for unfixed cortex; their T = 0.85 mm (Sect. 8) is its midpoint. The existing Zhang items do not record this value.
- **About 10⁵ neurons per mm²** (their Sect. 8, cited with refs 22 and 28) matches the book's pp. 25/27 statement, an order-of-magnitude summary of the Schüz and Palm (1989) counts shown in Fig. 12.

Nearby values that Zhang & Sejnowski do not use are not extracted: the neuron density of 9.2 × 10⁴ per mm³, the total neuron numbers on p. 27, and the local thicknesses in Fig. 72 on p. 167. Fig. 80 (p. 186) repeats the cortex volume as "2 x 87 mm³" (iso- and allocortex), consistent with the first record.

## R transformation and analysis CSV

`Braitenberg_Schüz_1998_Text.R` reads the snapshot and the context table and parses only printed notation:

- a single number;
- "between A and B", kept as a range with no midpoint imputed;
- 10⁵, printed with a superscript.

It assigns explicit units (mm³, mm, neurons/mm²) and writes `Braitenberg_Schüz_1998_Text.csv` (5 rows, long format). Checks: one-to-one join with the context table; neocortex volume below the whole-cortex volume; the paraffin thickness below the unfixed estimate; data roles limited to primary and secondary.

The CSV was first prepared by a Python implementation of the same steps, from the same frozen inputs, because Rscript was not available to the AI reader. **R was run on 22 October 2026** (outputs written at about 12:04 PDT). Its CSV was identical to the Python build, and it wrote the public TSV `__Public/comparative-data/10.1007%2F978-3-662-03733-1_Text.tsv` under the registry's Item encoded (owner decision of 16 October 2026). Later that day the context table was revised (volumes read as grey matter; see above). The CSV and the public TSV predate that revision until the script is run again.

## Data role and merge gates

The volumes and thicknesses are primary to this book: no upstream source is printed for them. The volumes are **per hemisphere** and are read as grey matter (see above); double them only explicitly. The 0.8–0.9 mm figure is an estimate. The neuron-per-area statement is secondary to Schüz and Palm (1989) and gives an order of magnitude only. Every row carries a HOLD merge gate. Not wired into any merge.

## Reader and review status

Read by Microsoft Copilot AI assistant on 22 October 2026 (America/Los_Angeles). This is AI inspection, not human visual curation; the registry's "Human visual check of snapshot" stays blank. The grey-matter reading of the volumes was proposed by Alexandra de Sousa in review on 22 October 2026, from the book's use of the volumes with the stereological neuron density; that is an interpretive decision, not a human visual check of the snapshot.

## Still to do

Re-run R to carry the revised context into the CSV and the public TSV; human visual check.
