# Herculano-Houzel et al. 2020 - TABLE 3 (fractional mass and neuron numbers of cerebral cortex and cerebellum; 13 bat species)

Herculano-Houzel, S., da Cunha, F. B., Reed, J. L., Kaswera-Kyamakya, C., Gillissen, E., & Manger, P. R. (2020). Microchiropterans have a diminutive cerebral cortex, not an enlarged cerebellum, compared to megachiropterans and other mammals. J Comp Neurol, 528(17), 2978-2993. https://doi.org/10.1002/cne.24985

**Status: built 2026-11-24, not yet registered.** No row in `__ReadMe.xlsx`, so no public TSV yet (see "Still to do").

Source
1. Read Table 3 into R from pdf (downloaded): `HerculanoHouzel_etal_2020_TABLE3_snapshot.R` (tabulapdf, page 5 of the PDF = journal p. 2982; fixed area and column separators; no value is typed in the script).

--> Snapshot

`HerculanoHouzel_etal_2020_TABLE3_snapshot.csv`: 13 rows x 9 columns, row and column order as printed, cells as printed (text, trailing zeros kept). Column headers as printed, with the subscripts written on the line (M_CX/M_BR -> `MCX/MBR`). Printed caption: "TABLE 3 Fractional mass and numbers of neurons in cerebral cortex and cerebellum, shown as percentages of total mass or number of neurons in the brain". The table has no footnote.

2. Fixed formatting in R: `HerculanoHouzel_etal_2020_TABLE3.R` (reads only the snapshot).

--> Data readable

3. Made the six value columns numerical. No unit conversion: `MCX/MBR`, `NCX/NBR`, `MCB/MBR`, `NCB/NBR` are percentages; `MCX/MCB`, `NCB/NCX` are ratios.

--> Species update

4. Corrected species name typo based on text in paper ("Hypsignathus mostrosus" -> "Hypsignathus monstrosus"), as in TABLE1 and TABLE2. The snapshot keeps the printed name.

HerculanoHouzel_etal_2020_TABLE3.csv <-- USE THIS

--> Online database

5. Not done yet: the TSV copy named with the DOI is written by `HerculanoHouzel_etal_2020_TABLE3.R` once the item has its row in `__ReadMe.xlsx` (expected name `10.1002%2Fcne.24985_TABLE3.tsv`). Until then the script writes the CSV, warns, and skips the TSV.

## Who read the values, and how they were checked
- Reader: the snapshot script (tabulapdf / tabula-java on the PDF text layer), run by an AI assistant on 2026-11-24. No cell was typed by hand.
- Check 1: the same page was parsed a second time with a different PDF library (PyMuPDF), once in reading order and once by word coordinates. All 117 cells (13 x 9) are identical to the snapshot in both.
- Check 2: the table region of page 5 was rendered to an image and read against the snapshot by the AI assistant; all rows agree.
- **RA side-by-side check of the snapshot against the PDF: pending** (to be recorded in `__ReadMe.xlsx`, `Human visual check of snapshot`).

## Table checks
- In the item script (`table_checks`, R run 2026-11-24): each printed ratio is the quotient of two of the table's own percentage columns - `MCX/MCB` = `MCX/MBR` / `MCB/MBR`, and `NCB/NCX` = `NCB/NBR` / `NCX/NBR`. Tolerance = rounding of the three printed cells. Result: 26 of 26 pass.
- Cross-item check in `internal_checks/` (`HerculanoHouzel_etal_2020_TABLE3_internal_check.R` -> `.csv`, R run 2026-11-24; reads the TABLE1, TABLE2 and TABLE3 snapshots). 119 checks, 77 pass, 42 outside rounding (kept as printed):
  - `NBRAIN` (TABLE1) = `NCX` + `NCB` + `NRoB` (TABLE2): 13 of 13.
  - TABLE3 neuron fractions and neuron ratio against TABLE1 and TABLE2: 39 of 39.
  - `MBRAIN` (TABLE1) against the sum of the structure masses implied by TABLE2 (N / DN): equal within rounding for 5 species; the other 8 differ by 0.25 to 1.41 % of the brain mass.
  - TABLE3 mass fractions and mass ratio against the masses implied by TABLE2: 14 of 39 within rounding; the rest differ by up to 0.7 percentage points.
  - Mass closure (`MCX/MBR` + `MCB/MBR` + implied rest-of-brain fraction = 100): within rounding for 5 species, otherwise within 1.6 points.
  - The mismatches are not printing errors. The relations are exact for one animal; the table prints means over two animals, and the quotient of two means is not the mean of the quotients. The species measured on both hemispheres (*Chaerephon pumilus*) shows the largest closure difference (-1.57 points) and a mass difference (-1.38 %) second only to *Rousettus aegyptiacus* (-1.41 %).
  - What the check shows about the brain mass: `MBRAIN` is the sum of the dissected structures, on the same basis as the neuron numbers (2 x the available hemisphere for the 12 species marked "(1H each)"), not a brain weighed whole. Limits: for 8 species this rests on the differences being small and no larger than in the control, not on an exact identity; that the structure data are 2 x one hemisphere is stated in Methods 2.1, not shown by the tables.

## Interpretation
- Percentages and ratios of species means; they do not depend on the hemisphere doubling.
- The structure masses are not printed anywhere in the paper. `MCX/MBR` x `MBRAIN` gives a cortex mass to three significant digits; it differs from N / DN of TABLE2 by up to 1.9 %.
- Relative values: recomputable downstream; not intended for a merge.

## Still to do (owner's routine)
1. RA side-by-side check of the snapshot with the PDF.
2. Add the row to `__ReadMe.xlsx` (Item number `TABLE 3`; Item name `HerculanoHouzel_etal_2020_TABLE3`), run `_tools/file_list.R`.
3. Re-run `HerculanoHouzel_etal_2020_TABLE3.R` to write the public TSV; confirm its name equals `Item encoded`.
4. `build_dataset_item()` / `validate_dataset_item()`; `_keys/build_variable_catalog.R`.
