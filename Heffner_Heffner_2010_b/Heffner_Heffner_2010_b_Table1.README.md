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
| `Heffner_Heffner_2010_b_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_Heffner_2010_b_Table1.csv` | tidy analysis rows |
| `reference_tables/Heffner_Heffner_2010_b_Table1_definitions.csv` | data dictionary |
| `reference_tables/Heffner_Heffner_2010_b_Table1_footnotes.csv` | full text of footnote letters a-jj (column definitions + per-species citations) |

## Data role
Only the *Tursiops truncatus* row (species_row 21) is marked `primary`;
it is the value used by SensoryData_compiled. The other 20 species are
printed in the same table and retained as `secondary` for completeness.

## Observation level
Species-level values, each drawn by the letter's authors from a distinct
previously published source (see footnotes csv for the citation attached
to each species' frequency and basilar-membrane-length values).

## Units
High-frequency hearing limit in kHz (60-dB-SPL criterion); functional
interaural distance in microseconds (time for a sound to travel from one
ear to the other in air, or from one bulla to the other for underwater
animals); basilar membrane length in mm.
