# Grande__1950_TablaVIII

**Item name** `Grande__1950_TablaVIII` · **Item number** `Tabla VIII` · **Item encoded** `RevClinEsp%3A39%3A1-17_TablaVIII` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx` — checked by Item name on 2026-11-03; code derived as the registry formula builds it from column C: no DOI exists, so the alternate code `RevClinEsp:39:1-17` is percent-encoded + `_` + locus, the `Babushina_etal_1991` / `Brodmann__1913` convention. Paste `Grande__1950_TablaVIII_registry_row.xlsx` (sets column C to the alternate code), run `_tools/file_list.R`, rename the TSV if the registry differs.)

Grande, F. (1950). El consumo de oxígeno del cerebro. *Revista Clínica Española*, 39(1), 1-17 (15 octubre 1950). No DOI.

**Item full original title:** TABLA VIII. Consumo de oxígeno y riego sanguíneo del cerebro humano, según Kety y Schmidt (1948). Valores medios de 34 observaciones en 14 sujetos jóvenes sanos. p. 12.

## Source

PDF in this folder: `Grande-1950-[Cerebral consumption of oxygen].pdf` (17 pages = printed pp. 1-17; copied here from `/Users/crossmodal/Documents/References.Data/PDF/3829176228/`). Tabla VIII is on PDF page 12 (printed p. 12), above Tabla IX.

## Pipeline

```
Source (PDF)
  -> Grande__1950_extract_snapshot.R   writes the frozen snapshot(s) (verbatim printed-layout blocks; refuses to overwrite)
  -> Grande__1950_TablaVIII_snapshot.csv   FROZEN: 8 rows x 3 cols (3 caption rows, 5 quantity rows)
  -> Grande__1950_TablaVIII.R   clean + parse + convert units + table checks
  -> Grande__1950_TablaVIII.csv   5 rows x 14 cols  ("use this")
  -> __Public/comparative-data/RevClinEsp%3A39%3A1-17_TablaVIII.tsv
  -> reference_tables/Grande__1950_TablaVIII_definitions.csv, _references.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 170-450-dpi renders and crops of PDF page 12 (pymupdf; read as page images and zoomed crops), typed as a verbatim printed-layout block into the folder's `*_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The PDF text layer is OCR of a 1950 scan and is not a usable second reading; as a weak presence check only, 4 of the 5 numeric cells occur as tokens on the page text (`54` is an OCR misread, confirmed on the image). Every value was **re-read cell by cell from the page image at high zoom** and, checked against the earlier transcription in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` where it covers this table (see 'Compilation comparison'); that file was used only as a starting point. The build `*.R` reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row: title, caption (with the Kety & Schmidt 1948 attribution), subtitle (34 observations in 14 young healthy subjects), then the five label/value/unit rows. The table has no header row. End-of-line hyphenations (`volu-menes`, `mi-nuto`) joined; dot leaders omitted.
* The analysis CSV is **long**: one row per printed quantity (CMRO2 per 100 g, A-V difference, flow per 100 g, total brain O2, total brain flow). `value_numeric` is in the printed unit; `value_converted` in the project unit (umol O2). Observation level: **group means** of 34 observations in 14 subjects.
* The 3,3 c.c./100 g/min (= 147.312 umol/100 g/min) is Kety & Schmidt's measured human whole-brain CMRO2 as reported by Grande; it is the same value that Tabla IX prints for the brain row.

## Table checks

Result of an actual R run (2026-11-03): **3 pass, 0 mismatch, 0 not evaluable**, of 3 checks.

All checks pass.

Table VIII prints no brain weight; the checks use the 1.400 g that the running text (p. 12) gives for this subject. The Fick check passes here only because the flow (54) and A-V difference (6,3) are printed with few digits; the same relation fails in Tabla IX where the flow is printed as 54,0 (see that item and errata `Grande__1950-E004`: 54 x 6,3 / 100 = 3.40 vs the printed 3,3).

## Data role

**secondary** — secondary (five values from Kety & Schmidt 1948 as reported by Grande 1950; the measured human brain values belong to the 1948 primary papers). Per-row source citations are in `reference_tables/Grande__1950_TablaVIII_references.csv`; use them as a roadmap to the primary measurements, never re-ingest these compiled figures as if primary. Not merged (`__merging_cerebral_metabolic_rate` is untouched).

## Species names

`species_as_published` = 'cerebro humano' (caption). Taxon Homo sapiens (young healthy adults). No `_keys/` file was edited; proposals are in `reference_tables/Grande__1950_species_key_proposed.csv` (collection `General`, `source_publication` = `Grande__1950`).

## Per-row sources

The caption attributes the table to Kety & Schmidt (1948). The bibliography (p. 17) prints **two** Kety & Schmidt 1948 entries, J. Clin. Invest. 27, 476 and 27, 484; the table does not say which. Both are kept verbatim in the references table. That the 34 observations / 14 subjects are the 27:476 paper is an inference (Grande 1980 ref 25 cites 27:476 for the same figures), not printed here.

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with the Grande_1950 Tabla IX row in `classic_energetics_compilations/classic_human_brain_partition.csv` (brain 1400 g, 3,30, 46 c.c./min) after freezing: consistent with Tabla VIII's 3,3 / 46; no printed value changed.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
<!-- errata:end -->
