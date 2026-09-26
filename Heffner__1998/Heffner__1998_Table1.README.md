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
- **Negative-sign / "S" OCR ambiguity for four bird rows.** The PDF's own
  text layer extracts a leading minus sign on the low-frequency-limit cells
  for zebra finch, turkey, pigeon, and mallard duck ("-250", "-250", "-125",
  "-300" Hz). A negative frequency is not physically meaningful, and the
  paper's own prose says low-frequency hearing in birds is "less well
  studied" with only "some indication that pigeons may be sensitive to very
  low-frequency sounds" — consistent with these four values being a printed
  "&gt;" (greater-than, i.e. lower limit not established below this value)
  misread as a minus sign by the extraction, not a genuine negative
  reading. Rather than silently converting or guessing, the snapshot keeps
  the literal extracted character and the analysis CSV leaves
  `low_frequency_limit_Hz` blank for these four rows.
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
