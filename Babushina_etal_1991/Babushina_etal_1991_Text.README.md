# Babushina_etal_1991_Text

## Source
Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and
underwater hearing characteristics of the northern fur seal: audiograms,
frequency and differential thresholds. *Biophysics*, 36(5), 909-913. No DOI;
registry alternate identifier `Biophysics:36:909-913`. Public copy:
`Babushina_etal_1991/Babushina1991.pdf` (library scan with an OCR text layer).

Registry Item **Text**: Abstract (p. 909), unheaded Introduction (p. 909) and
Results (pp. 910-913).

## Snapshot
`Babushina_etal_1991_Text_snapshot.csv` is a constructed data-from-text snapshot: one record per
hearing value printed in the running text (T01-T28, reading order), wording,
units, raised decimal points and en dashes as printed. Method and reader:
`Babushina_etal_1991_Text_snapshot_notes.txt` (transcribed 2026-10-26 by an AI assistant from page
images at 200-400 dpi; each quoted sentence compared against the text layer).

## Build
`Babushina_etal_1991_Text.R` (run clean 2026-10-30, R 4.5.3, `LANG=en_US.UTF-8 Rscript --vanilla`)
reads the snapshot as text, parses each printed value into `value_from` /
`value_to` (first and second number as printed; `·` -> `.`, `−` -> `-`), parses
the frequency ranges the same way, harmonises names through
`_keys/General/species_key.csv` (rows `source_publication = Babushina_etal_1991`;
group names "seals" / "true seals" are left without a binomial), expands the
bracketed reference keys, and checks that the five Abstract/Results restatement
pairs (T03/T12, T04/T14, T05/T17, T06/T20, T07/T21) agree. Writes
`Babushina_etal_1991_Text.csv` and the public TSV `__Public/comparative-data/Biophysics%3A36%3A909-913_Text.tsv`.

## Flags (kept as printed)
- T01: the Abstract prints "05–40 kHz"; the Results (T11) print "0·5–40". T01's
  value is NOT parsed (NA, `parse_flag` set) rather than read as 5 kHz.
- T23: "over 16%" is a lower bound (`parse_flag`).
- Units are not converted: water dB re 1 µbar (add 100 for dB re 1 µPa), air
  dB re 0·0002 dyne/cm² (= dB SPL).

## Secondary data
Records T08-T10 summarise cited literature ([1–14], [13, 15, 16], [10, 11]);
T15-T16 compare the fur seal with cited common-seal and sea-lion curves (no key
printed in that sentence; the figure captions cite [5], [8], [10]).
`reference_tables/Babushina_etal_1991_Text_references.csv` has one row per individual number
(`ref_key`), the column that prints it, and the citation transcribed from the
References list (p. 913, checked against a page render). Join: split
`ref_numbers` on "; " and join on `ref_key`.

## Data role
Both: T01-T07, T11-T14, T17-T28 primary (one adult 8–9-year-old male
*Callorhinus ursinus*); T08-T10 secondary; T15-T16 both.

## Files
| file | role |
|---|---|
| `Babushina_etal_1991_Text_snapshot.csv` | constructed snapshot (frozen) |
| `Babushina_etal_1991_Text_snapshot_notes.txt` | transcription notes and reader |
| `Babushina_etal_1991_Text.R` | snapshot -> analysis CSV + public TSV |
| `Babushina_etal_1991_Text.csv` | analysis CSV (28 rows) |
| `reference_tables/Babushina_etal_1991_Text_definitions.csv` | data dictionary |
| `reference_tables/Babushina_etal_1991_Text_references.csv` | cited works for T08-T10 |
| `Babushina_etal_1991_Text_registry_row.xlsx` | registry UPDATE proposal (row exists) |

Human visual check of the snapshot: pending.
