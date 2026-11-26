# Sokoloff_etal_1977_Table4

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Sokoloff_etal_1977/Sokoloff_etal_1977_Table4.R` wrote `__Public/comparative-data/10.1111%2Fj.1471-4159.1977.tb10649.x_Table4.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `Sokoloff_etal_1977_Table4` · **Item number** `Table 4` · **Item encoded** `10.1111%2Fj.1471-4159.1977.tb10649.x_Table4` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Sokoloff_etal_1977_Table4_registry_row.xlsx`.

Sokoloff, L., Reivich, M., Kennedy, C., Des Rosiers, M. H., Patlak, C. S., Pettigrew, K. D., Sakurada, O., & Shinohara, M. (1977). The [14C]deoxyglucose method for the measurement of local cerebral glucose utilization: theory, procedure, and normal values in the conscious and anesthetized albino rat. *Journal of Neurochemistry*, 28(5), 897-916. <https://doi.org/10.1111/j.1471-4159.1977.tb10649.x>

**Item full original title:** Table 4. Effects of thiopental anesthesia on local cerebral glucose consumption in the albino rat, p. 913.

## Source

PDF in this folder: `Sokoloff-1977-The [14C]deoxyglucose method for.pdf` (Wiley Online Library download; DOI verified against the PDF margin stamp and CrossRef on 2026-11-17: J Neurochem 28: 897-916, 1977).

**Other tables in the paper (not built):** TABLE 1 (p. 911) prints the rate constants k1*, k2*, k3* (min^-1, estimate ± S.E. from a non-linear least-squares fit to data from 15 conscious animals), the distribution volume k1*/(k2*+k3*) (ml/g) and the precursor-pool half-life log_e2/(k2*+k3*) (min) for 15 gray and 3 white structures with gray/white means ± S.E.M. TABLE 2 (p. 912) prints the lumped constant (mean ± S.D., S.E.M.) in conscious (n = 15: 0.464 ± 0.099), anesthetized (n = 9: 0.512 ± 0.118) and combined (n = 24: 0.483 ± 0.107, S.E.M. ± 0.022) rats; 0.483 is the value used to compute the Table 3 and 4 rates. Both are method-parameter tables, recorded here for context only.

**Relation to other items:** this is the rat analogue of `Kennedy_etal_1978_Table` (macaque, same NIMH laboratory, same [14C]deoxyglucose method); the column design of the analysis CSV mirrors that item so the two can be stacked.

## Pipeline

```
Source (PDF page 17)
  -> Sokoloff_etal_1977_Table4_snapshot.R   writes the frozen snapshot (hand-typed printed-layout block)
  -> Sokoloff_etal_1977_Table4_snapshot.csv   FROZEN: 36 rows x 4 cols
  -> Sokoloff_etal_1977_Table4.R   clean + parse + table checks
  -> Sokoloff_etal_1977_Table4.csv   75 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1111%2Fj.1471-4159.1977.tb10649.x_Table4.tsv   (written by the build once the item is registered)
  -> reference_tables/Sokoloff_etal_1977_Table4_definitions.csv
  -> internal_checks/Sokoloff_etal_1977_Table4_internal_check.R / .csv   cross-item check vs the Table 3 snapshot (read-only)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-17 from a 300-dpi render of PDF page 17 (`pdfplumber`), checked cell by cell against zoomed crops of the render, typed as a verbatim printed-layout block into `Sokoloff_etal_1977_Table4_snapshot.R` (freezes, refuses to overwrite a differing copy). A preliminary transcription made earlier by the lead agent was compared with the page image cell by cell: every cell agreed, no correction was needed. The PDF's OCR text layer is legible for words but garbles the ± signs ("f", "k", "&", "rl:") and drops digits; it was used only to cross-read words, never values.

The build script `Sokoloff_etal_1977_Table4.R` reads the frozen file and contains no table values. It was run with
`Rscript` (conda env `evom1-r`, R 4.5.3 with readxl; `LANG=en_US.UTF-8` is required — under a C locale R truncates µ, ± and † on write) from a clean session on 2026-11-17. The run stopped, as expected for an unregistered item, at the registry lookup ("Expected one registered item row") after writing the analysis CSV; the public TSV is written once the registry row is pasted and `file_list.R` has run.

### Structure of the snapshot and of the analysis CSV

* One snapshot row per printed row (caption, header tier(s), section headings, printed vertical gaps as empty rows, structure rows in printed order, footnote rows). Footnote glyphs are kept as printed (`*`, `†`); a label printed on two lines carries a line break in the snapshot cell and is joined with one space in the CSV.
* The analysis CSV is **long**: one row per printed cell (structure x column), ordered as the page is
  read (along each row). `cell_as_printed` keeps the cell verbatim; `mean_printed` /
  `dispersion_printed` keep the exact printed lexemes; `CMRglc.umol_100g_min` is the parsed rate.
  `species_as_published` keeps the paper's wording ("albino rat"); `Species` is the accepted binomial
  (Rattus norvegicus) from `_keys/General/species_key.csv`.
* **Observation level: printed group means per arm, not species means.** Pool or choose arms
  explicitly before any species-level use.
* 25 structure rows: 21 under "Gray matter" and 4 under "White matter", each with a Control, an Anesthetized and a % Effect cell (75 analysis rows; the % Effect rows have `measure = percent_effect`, `CMRglc.umol_100g_min = NA`). All 25 structures are also printed in Table 3, which adds 8 gray structures (Olfactory and Frontal cortex, Mamillary body, Dentate gyrus, Septal nucleus, Nucleus accumbens, Globus-pallidus, Substantia nigra).
* The spanning header "Local cerebral glucose utilization (µmol/100 g/min)" over the two rate columns is kept in `group_as_published`; the header footnote † and title footnote * are recorded in `footnote_marks` / `note` on every rate cell.

### Arms printed

conscious_control (n = 6) and thiopental (n = 8): 30-min experimental period (footnote *); mean ± S.E.M.; footnote †: all control-vs-anesthetized differences statistically significant at P < 0.05. percent_effect: the printed % Effect column, kept as printed (n and dispersion NA).

### Animals and physiological state (METHODS, p. 899)

"normal, adult, male Sprague-Dawley rats weighing between 325 and 450 g", fed Purina chow and water ad lib (some fasted ~16 h). Femoral catheters were placed under light halothane anesthesia; "the animals were immobilized by means of loose-fitting, partially bisected plaster casts and then allowed to recover from the anesthesia for at least 2 h before the initiation of the experimental procedure. Animals studied in the conscious state were kept alert by tactile stimulation as required." The project shorthand "conscious, lightly restrained" paraphrases this (loose plaster-cast immobilization of the lower body, awake). Anesthetized animals (Table 4) were re-induced and "maintained throughout the experimental procedure at the level of extinction of the corneal reflex by intravenous administration of sodium thiopental as required."

## Table checks

Result of an actual R run (2026-11-17): **27 pass, 0 mismatch, 0 not evaluable**, of 27 checks.

| check | basis | result |
|---|---|---|
| `pct_effect_recomputed_1..25` | % Effect recomputed from the two printed means, round(100 x (anesthetized - control)/control), vs the printed % Effect (tolerance 1 for integer rounding of the means) | 25/25 pass, all 25 exact (rounded recomputation equals the printed integer) |
| `all_reduced` | structures with anesthetized < control vs RESULTS p. 912 'reduced the rates ... in all structures' | 25 of 25, pass |
| `white_effect_smaller` | mean % effect of the 4 white rows minus mean of the 21 gray rows (sign check vs RESULTS 'effects in white matter were relatively small') | +16.2 points (white mean -21.0 %, gray mean -37.2 %), pass |

### Cross-item internal check (HOWTO 7b): Table 4 Control vs Table 3 30-min

`internal_checks/Sokoloff_etal_1977_Table4_internal_check.R` reads both frozen snapshots and compares the Control (n = 6) mean of each of the 25 Table 4 structures with the Table 3 30-min (n = 10) mean of the same structure. These are different groups of conscious animals, so the tolerance is 2 x sqrt(SEM3^2 + SEM4^2) per structure. Result (2026-11-17): **25 of 25 within tolerance**; differences range from -6 to +3 µmol/100 g/min (Table 4 minus Table 3), mean -1.16, mean absolute difference 2.20 (about 2 % of the gray-matter mean); Spearman rho between the two sets of 25 means = 0.999. The largest differences are Auditory cortex (157 vs 163), Sensory-motor cortex (118 vs 124) and Superior olivary nucleus (141 vs 147). For a single "conscious rat" baseline use Table 3 (30 min, n = 10, 33 structures); use the Table 4 control column only when pairing with the anesthetized arm.


## Data role

**primary**: all values are this paper's own measurements.

## Species names

The table prints no species in its rows; `species_as_published` carries the paper's wording ("albino rat": title and Table 4 caption; the Table 3 caption prints "normal conscious rat"; METHODS: Sprague-Dawley). Three variant rows (`albino rat`, `Sprague-Dawley rat`, `rat` -> Rattus norvegicus, NCBI taxid 10116, `source_publication = Sokoloff_etal_1977`) were appended to `_keys/General/species_key.csv` on 2026-11-17 and the build script resolves `Species` through them (it stops if the key filter returns no rows).

## Units

µmol glucose/100 g tissue/min (printed; the project unit for CMRglc). No conversion.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to
lay the snapshot beside the page, read a few rows **across** (including mid-table rows), and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
