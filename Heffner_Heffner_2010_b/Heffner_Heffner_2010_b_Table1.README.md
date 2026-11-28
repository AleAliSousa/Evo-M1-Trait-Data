# Heffner_Heffner_2010_b_Table1

## Source
Heffner, R., & Heffner, H. (2010). Explaining High-Frequency Hearing.
*Anat Rec (Hoboken)*, 293, 2080-2082. doi:10.1002/ar.21292

Registry Item **Table 1**, printed p. 2081. Public copy:
`Heffner_Heffner_2010_b/Heffner_Heffner_2010_b.pdf`.

**Folder-identity note:** this is a Letter to the Editor responding to
Kirk and Gosselin-Ildari (2009) about cochlear volume and high-frequency
hearing, and is filed under the `_b` disambiguation suffix because a
different, unrelated paper (Heffner & Heffner, "Use of binaural cues for
sound localization...") occupies the plain `Heffner_Heffner_2010` folder.
The registry row for this item was originally mis-labeled H =
"Heffner_Heffner_2010" (missing "_b") with J/K also missing the "_b"
marker; these have been corrected to H = "Heffner_Heffner_2010_b",
J = "Heffner_Heffner_2010_b_Table1", K =
"10.1002%2Far.21292_Table1" to match this folder and this paper's DOI.

## Why this item exists
The letter argues that functional head size (interaural distance), not
cochlea/basilar-membrane size, is the primary determinant of
high-frequency hearing limits across mammals, using a partial-correlation
analysis over 21 species. Table 1 is the small data table listing, for
each of the 21 species, the high-frequency hearing limit (60-dB-SPL
criterion), the functional interaural distance, and the basilar-membrane
length, each with its own literature citation (superscript letters). It is
the direct printed source of the two *Tursiops truncatus* (bottlenose
dolphin, "in water") values used by SensoryData_compiled:
audible_freq_high_60dBSPL = 136 kHz and interaural_distance_functional =
75 us.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_Heffner_2010_b_Table1_snapshot.csv` | frozen source, printed layout, incl. footnote letters |
| `Heffner_Heffner_2010_b_Table1.R` | reads the snapshot, writes CSV + public TSV, and builds source matches |
| `Heffner_Heffner_2010_b_Table1.csv` | tidy analysis rows; retains two independent printed citation-key columns and the taxon as published |
| `reference_tables/Heffner_Heffner_2010_b_Table1_definitions.csv` | ten-column item dictionary with variable-level quantity, role, method limitations, and exact table/footnote locators |
| `reference_tables/Heffner_Heffner_2010_b_Table1_footnotes.csv` | wording of printed footnotes a-jj |
| `reference_tables/Heffner_Heffner_2010_b_Table1_references.csv` | item-scoped key-to-citation lookup; full bibliography from printed p. 2082 where available |
| `reference_tables/Heffner_Heffner_2010_b_Table1_reference_columns.csv` | reviewed key-column-to-measure declarations |
| `reference_tables/Heffner_Heffner_2010_b_Table1_source_match*.csv` | regenerated cell-level citation matches and issues |

## Data role
All 21 rows are secondary reports from a comparative letter. Use by
SensoryData_compiled does not make its *Tursiops* row an original measurement.
For that row, hearing limit 136 kHz cites Johnson (1967), and basilar
membrane length 40.7 mm cites Ketten (1992), through footnotes ii and jj.
The functional interaural distance of 75 microseconds has no per-row
citation or acquisition protocol in Table 1; its original source remains
unresolved. A cited work is not automatically confirmed as the original
measurement; review the cited work before assigning primary lineage.

## Observation level
Species-level values. Frequency and basilar-membrane-length values have
*separate* printed superscript references, now preserved as `ref_freq_key`
and `ref_bm_length_keys`. Some membrane cells cite two keys; hearing
footnotes m and q each name two works under one key. These are retained
as compound citations until the original value can be attributed to one
work. The distance column has only a quantity definition (footnote b).

The PDF prints *Tursiops truncates* in the last row. The older frozen
snapshot silently normalized this to *Tursiops truncatus*. The built
item now preserves the PDF wording in `species_as_published`, retains
`binomial = Tursiops truncatus` for existing consumers, and leaves
accepted-name validation to `_keys`.

## Snapshot layout recheck (2026-11-27)
Compared the snapshot with the local source PDF, printed p. 2081. The
snapshot now has the four printed columns: the common and scientific names
share the Species cell, and superscript reference keys remain attached to
their measured values. The caption and footnotes follow the printed table.
The R reader separates names and reference keys for the analysis CSV and
normalizes the published *Tursiops truncates* spelling there. Command:
`Rscript Heffner_Heffner_2010_b/Heffner_Heffner_2010_b_Table1.R` from the
repository root. The rebuilt 21-row analysis CSV matches the prior version
cell for cell. This is a source layout check, not independent human signoff.

## Units
High-frequency hearing limit in kHz (60-dB-SPL criterion); functional
interaural distance in microseconds (time for a sound to travel from one
ear to the other in air, or from one bulla to the other for underwater
animals); basilar membrane length in mm.
