# Heffner__1998_Table1

## Source
Heffner, H. E. (1998). Auditory awareness. *Applied Animal Behaviour
Science*, 57(3-4), 259–268. doi:10.1016/S0168-1591(98)00101-4

Registry Item **Table 1**, printed p. 261 ("The hearing range and
sensitivity of domestic birds and mammals compared with that of humans").
Public copy: `Heffner__1998/Heffner-1998-Auditory awareness.pdf`.

## Why this item exists
This review paper's Table 1 is a compiled comparative table of hearing
range and sensitivity for 19 domestic bird and mammal species (with humans
for comparison) — the paper's own citation for the table reads "For
individual data, see the works of Fay (1988) and Heffner and Heffner
(1992a)." It is registered here on the same basis as `Baron_etal_1996`
(a compiled book/review source treated as a citable registry item in its
own right) since it is the paper's own printed, citable table, not a
figure requiring digitization.

## Pipeline
Printed table → snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Heffner__1998_Table1_snapshot.csv` | frozen source, printed layout |
| `Heffner__1998_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner__1998_Table1.csv` | one row per species (19) |
| `reference_tables/Heffner__1998_Table1_definitions.csv` | data dictionary |

## Data role
All 19 rows are secondary: reproduced by this paper from Fay (1988) and
Heffner & Heffner (1992a), not new measurements of this paper's own.

## Printed oddities carried as-is
- **Less-than bounds on four bird rows (resolved 2026-09-29).** The PDF's
  text layer extracts the low-frequency-limit cells for zebra finch, turkey,
  pigeon and mallard duck as "-250", "-250", "-125", "-300" Hz. The page
  image of Table 1 (p. 261) shows the glyph is a **less-than sign**: "< 250",
  "< 250", "< 125", "< 300" -- the animals were still hearing at the lowest
  frequency tested, so the 60 dB limit lies below that value. The analysis
  CSV now carries the numeric bound in `low_frequency_limit_Hz` and "<" in
  `low_frequency_limit_qualifier`. Until 2026-09-29 these cells were left
  blank on the assumption the glyph was ">" (limit not reached from above);
  the change is logged in `reference_tables/Heffner__1998_errata.csv`
  (E001-E004). The snapshot keeps the literal extraction.
- Best-sensitivity values are printed with an OCR "y" standing in for a
  minus sign elsewhere in this same PDF's raw text (e.g. "y10" = "-10");
  those have been resolved unambiguously to their negative dB values here
  since the source's own footnote/units convention makes the sign clear
  from context (a threshold of "y10 dB" ~10 dB better than the reference
  makes physical sense only as -10 dB, matching the paper's own statement
  that "mammals, especially humans, cattle and goats, tend to be extremely
  sensitive at their frequency of best hearing").

## Observation level
Species-level summary value (best individual/mean thresholds as compiled
by the cited sources), not per-individual.

## Units
Hz (frequency columns), dB re 20 µPa (best sensitivity, i.e. the species'
lowest measured threshold — negative values indicate greater sensitivity
than the 0 dB reference level).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Heffner__1998_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Heffner__1998-E001 | low_frequency_limit_Hz | Table 1, p. 261 (PDF p3), row "Zebra finch", column "Low-frequency limit (Hz)" | < 250 |  | repo_transcription_error | 250 with low_frequency_limit_qualifier '<' | confirmed | Page image of Table 1 read 2026-09-29: the glyph is a less-than sign. The PDF text layer extracts it as a minus sign ('-250'); the build script had assumed '>' and left the cell blank. Fixed in Heffner__1998_Table1.R (value + new qualifier column), CSV and public TSV rebuilt. | Independently, the Bath 'Sensory Data' workbook recorded the same cell as 0.25 kHz under its Rule 4 ('<x stated as x'), which agrees with the print. |
| Heffner__1998-E002 | low_frequency_limit_Hz | Table 1, p. 261 (PDF p3), row "Turkey", column "Low-frequency limit (Hz)" | < 250 |  | repo_transcription_error | 250 with low_frequency_limit_qualifier '<' | confirmed | Page image of Table 1 read 2026-09-29: the glyph is a less-than sign. The PDF text layer extracts it as a minus sign ('-250'); the build script had assumed '>' and left the cell blank. Fixed in Heffner__1998_Table1.R (value + new qualifier column), CSV and public TSV rebuilt. | Independently, the Bath 'Sensory Data' workbook recorded the same cell as 0.25 kHz under its Rule 4 ('<x stated as x'), which agrees with the print. |
| Heffner__1998-E003 | low_frequency_limit_Hz | Table 1, p. 261 (PDF p3), row "Pigeon", column "Low-frequency limit (Hz)" | < 125 |  | repo_transcription_error | 125 with low_frequency_limit_qualifier '<' | confirmed | Page image of Table 1 read 2026-09-29: the glyph is a less-than sign. The PDF text layer extracts it as a minus sign ('-125'); the build script had assumed '>' and left the cell blank. Fixed in Heffner__1998_Table1.R (value + new qualifier column), CSV and public TSV rebuilt. | Independently, the Bath 'Sensory Data' workbook recorded the same cell as 0.125 kHz under its Rule 4 ('<x stated as x'), which agrees with the print. |
| Heffner__1998-E004 | low_frequency_limit_Hz | Table 1, p. 261 (PDF p3), row "Mallard duck", column "Low-frequency limit (Hz)" | < 300 |  | repo_transcription_error | 300 with low_frequency_limit_qualifier '<' | confirmed | Page image of Table 1 read 2026-09-29: the glyph is a less-than sign. The PDF text layer extracts it as a minus sign ('-300'); the build script had assumed '>' and left the cell blank. Fixed in Heffner__1998_Table1.R (value + new qualifier column), CSV and public TSV rebuilt. | Independently, the Bath 'Sensory Data' workbook recorded the same cell as 0.3 kHz under its Rule 4 ('<x stated as x'), which agrees with the print. |

4 recorded, 0 open (proposed), 4 confirmed, 0 withdrawn.
<!-- errata:end -->
