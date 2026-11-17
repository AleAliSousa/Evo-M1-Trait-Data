# Sokoloff_etal_1977_Table3

**Item name** `Sokoloff_etal_1977_Table3` · **Item number** `Table 3` · **Item encoded** `10.1111%2Fj.1471-4159.1977.tb10649.x_Table3` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Sokoloff_etal_1977_Table3_registry_row.xlsx`.

Sokoloff, L., Reivich, M., Kennedy, C., Des Rosiers, M. H., Patlak, C. S., Pettigrew, K. D., Sakurada, O., & Shinohara, M. (1977). The [14C]deoxyglucose method for the measurement of local cerebral glucose utilization: theory, procedure, and normal values in the conscious and anesthetized albino rat. *Journal of Neurochemistry*, 28(5), 897-916. <https://doi.org/10.1111/j.1471-4159.1977.tb10649.x>

**Item full original title:** Table 3. Comparison of values of local cerebral glucose utilization determined at 30 and 45 min following pulse of [14C]deoxyglucose in the normal conscious rat, p. 912.

## Source

PDF in this folder: `Sokoloff-1977-The [14C]deoxyglucose method for.pdf` (Wiley Online Library download; DOI verified against the PDF margin stamp and CrossRef on 2026-11-17: J Neurochem 28: 897-916, 1977).

**Other tables in the paper (not built):** TABLE 1 (p. 911) prints the rate constants k1*, k2*, k3* (min^-1, estimate ± S.E. from a non-linear least-squares fit to data from 15 conscious animals), the distribution volume k1*/(k2*+k3*) (ml/g) and the precursor-pool half-life log_e2/(k2*+k3*) (min) for 15 gray and 3 white structures with gray/white means ± S.E.M. TABLE 2 (p. 912) prints the lumped constant (mean ± S.D., S.E.M.) in conscious (n = 15: 0.464 ± 0.099), anesthetized (n = 9: 0.512 ± 0.118) and combined (n = 24: 0.483 ± 0.107, S.E.M. ± 0.022) rats; 0.483 is the value used to compute the Table 3 and 4 rates. Both are method-parameter tables, recorded here for context only.

**Relation to other items:** this is the rat analogue of `Kennedy_etal_1978_Table` (macaque, same NIMH laboratory, same [14C]deoxyglucose method); the column design of the analysis CSV mirrors that item so the two can be stacked.

## Pipeline

```
Source (PDF page 16)
  -> Sokoloff_etal_1977_Table3_snapshot.R   writes the frozen snapshot (hand-typed printed-layout block)
  -> Sokoloff_etal_1977_Table3_snapshot.csv   FROZEN: 43 rows x 3 cols
  -> Sokoloff_etal_1977_Table3.R   clean + parse + table checks
  -> Sokoloff_etal_1977_Table3.csv   66 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1111%2Fj.1471-4159.1977.tb10649.x_Table3.tsv   (written by the build once the item is registered)
  -> reference_tables/Sokoloff_etal_1977_Table3_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-17 from a 300-dpi render of PDF page 16 (`pdfplumber`), checked cell by cell against zoomed crops of the render, typed as a verbatim printed-layout block into `Sokoloff_etal_1977_Table3_snapshot.R` (freezes, refuses to overwrite a differing copy). A preliminary transcription made earlier by the lead agent was compared with the page image cell by cell: every cell agreed, no correction was needed. The PDF's OCR text layer is legible for words but garbles the ± signs ("f", "k", "&", "rl:") and drops digits; it was used only to cross-read words, never values.

The build script `Sokoloff_etal_1977_Table3.R` reads the frozen file and contains no table values. It was run with
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
* 33 structure rows: 29 under "Gray matter" (six cortical areas; four thalamic/geniculate; six limbic/diencephalic; eleven basal-ganglia, brainstem and auditory nuclei; two cerebellar) and 4 under "White matter", each with a 30-min and a 45-min cell (66 analysis rows).

### Arms printed

conscious_30min (n = 10) and conscious_45min (n = 10): normal conscious rats with 30-min and 45-min experimental periods after the [14C]deoxyglucose pulse (same lumped constant 0.483); mean ± S.E.M. (footnote *). Footnote † marks the only cell with a statistically significant 30-vs-45-min difference (P < 0.05): Hypothalamus, 45 min (54 ± 2 vs 61 ± 2).

### Animals and physiological state (METHODS, p. 899)

"normal, adult, male Sprague-Dawley rats weighing between 325 and 450 g", fed Purina chow and water ad lib (some fasted ~16 h). Femoral catheters were placed under light halothane anesthesia; "the animals were immobilized by means of loose-fitting, partially bisected plaster casts and then allowed to recover from the anesthesia for at least 2 h before the initiation of the experimental procedure. Animals studied in the conscious state were kept alert by tactile stimulation as required." The project shorthand "conscious, lightly restrained" paraphrases this (loose plaster-cast immobilization of the lower body, awake). Anesthetized animals (Table 4) were re-induced and "maintained throughout the experimental procedure at the level of extinction of the corneal reflex by intravenous administration of sodium thiopental as required."

## Table checks

Result of an actual R run (2026-11-17): **4 pass, 0 mismatch, 0 not evaluable**, of 4 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_structures` | structure rows vs RESULTS p. 912 '33 cerebral structures examined' | 33 | 33 | 0 | 0 | pass |
| `n_significant_cells` | cells marked † vs RESULTS p. 912 'all but one of the 33' | 1 | 1 | 0 | 0 | pass |
| `highest_is_inferior_colliculus_30min` | highest 30-min value is the Inferior colliculus row (RESULTS p. 912) | 203 | 203 | 0 | 0 | pass |
| `gray_to_white_ratio_30min` | mean of gray rows / mean of white rows (30 min) vs RESULTS p. 912 'about 3 times' | 2.83 | 3 | -0.17 | 0.3 | pass |

Cross-item check against Table 4 (control column): see `internal_checks/Sokoloff_etal_1977_Table4_internal_check.csv` and the Table 4 README.


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
