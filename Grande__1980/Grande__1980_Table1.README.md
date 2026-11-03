# Grande__1980_Table1

**Item name** `Grande__1980_Table1` · **Item number** `Table 1` · **Item encoded** `AssessEnergyMetab%3A1980%3A88-92_Table1` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx` — checked by Item name on 2026-11-03; code derived as the registry formula builds it from column C: no DOI exists, so the alternate code `AssessEnergyMetab:1980:88-92` is percent-encoded + `_` + locus, the `Babushina_etal_1991` / `Brodmann__1913` convention. Paste `Grande__1980_Table1_registry_row.xlsx` (sets column C to the alternate code), run `_tools/file_list.R`, rename the TSV if the registry differs.)

Grande, F. (1980). Energy expenditure of organs and tissues. In *Assessment of energy metabolism in health and disease: Report of the First Ross Conference on Medical Research* (pp. 88-92). Columbus, Ohio: Ross Laboratories. No DOI. (Editor not printed on the supplied pages.)

**Item full original title:** Table 1. Various estimates of BMR partition in man, as percent of total BMR. p. 88.

## Source

PDF in this folder: `Grande_1980.pdf` (British Library On Demand copy; cover sheet = PDF page 1; PDF page 2 = printed p. 88, ... page 6 = p. 92; copied here from `/Users/crossmodal/Documents/References.Data/PDF/0304089163/`). The BL order sheet reads the year field as '1989' (OCR of the sheet) but the imprint line says c1980; the item uses 1980. Table 2 (Krebs-based log-log regressions) is not built.

## Pipeline

```
Source (PDF)
  -> Grande__1980_extract_snapshot.R   writes the frozen snapshot(s) (verbatim printed-layout blocks; refuses to overwrite)
  -> Grande__1980_Table1_snapshot.csv   FROZEN: 10 rows x 6 cols (caption, header, 7 organ rows, footnote)
  -> Grande__1980_Table1.R   clean + parse + convert units + table checks
  -> Grande__1980_Table1.csv   35 rows x 12 cols  ("use this")
  -> __Public/comparative-data/AssessEnergyMetab%3A1980%3A88-92_Table1.tsv
  -> reference_tables/Grande__1980_Table1_definitions.csv, _references.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 170-450-dpi renders and crops of PDF page 2 (printed p. 88) (pymupdf; read as page images and zoomed crops), typed as a verbatim printed-layout block into the folder's `*_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The text layer of the British Library scan is partly usable: as a presence check only (not positional), all 33 numeric cells occur as tokens on the page text. Every value was **re-read cell by cell from the page image at high zoom** and, checked against the earlier transcription in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` where it covers this table (see 'Compilation comparison'); that file was used only as a starting point. The build `*.R` reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row: caption, header (`Organ | Ref 15 | Ref 19 | Ref 16* | Ref 17 | Ref 18`), seven organ/subtotal rows, the footnote row. The two blank cells (Ref 18, Muscle and Subtotal 2) are kept blank. The brain row is highlighted on the scan (reader's annotation, not print).
* The analysis CSV is **long**: one row per printed cell (7 rows x 5 estimates = 35). `ref_key` is the printed column header (`Ref 16*` keeps its asterisk; `ref_number` is the numeral), so the references table joins on `ref_key`. Observation level: **five separate published estimates** of the human BMR partition, not a sample; **never pool across columns as if independent** (Ref 15 is Grande's own 1950 line).
* **Brain share of total BMR by estimate:** Ref 15 = 19, Ref 19 = 18.3, Ref 16* (Aschoff) = 16, Ref 17 = 20, Ref 18 = 21 (%). This five-estimate range (16-21 %) is where the compilation quotes '16-21 % of the total energy' from.

## Table checks

Result of an actual R run (2026-11-03): **9 pass, 0 mismatch, 1 not evaluable**, of 10 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `subtotal2_Ref18` | Ref 18: printed Subtotal 1 + muscle vs printed Subtotal 2 |  |  |  | 1 | not_evaluable |

Every printed subtotal reproduces. Not evaluable: Ref 18 Subtotal 2 (muscle and Subtotal 2 are printed blank in that column). Ref 19 is the only column printed with a decimal (26,4 etc. as 26.4); its two subtotals (61.1, 86.7) reproduce exactly.

## Data role

**secondary** — secondary compilation of five earlier estimates (refs 15, 16*, 17, 18, 19), one of them Grande's own (1950). Per-row source citations are in `reference_tables/Grande__1980_Table1_references.csv`; use them as a roadmap to the primary measurements, never re-ingest these compiled figures as if primary. Not merged (`__merging_cerebral_metabolic_rate` is untouched).

## Species names

`species_as_published` = 'man' (caption). Taxon Homo sapiens. No `_keys/` file was edited; proposals are in `reference_tables/Grande__1980_species_key_proposed.csv` (collection `General`, `source_publication` = `Grande__1980`).

## Per-row sources

Each column header **is** the source (Ref 15, 19, 16*, 17, 18). `reference_tables/Grande__1980_Table1_references.csv` carries the verbatim entry of each from the reference list on pp. 91-92 (Ref 15 Grande 1950; Ref 19 Brozek & Grande 1955; Ref 16 Aschoff 1960 in Landois-Rosenmann ed. 28, p. 332, 'recalculated from original data' per the footnote; Ref 17 Wade & Bishop 1962; Ref 18 Holliday et al. 1967). Printed typos kept ('Muchen', 'Schwarzenber').

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with the five-estimate list in `classic_energetics_compilations/CLASSIC_COMPILATIONS_FINDINGS.md` after freezing (Grande 19, Brozek & Grande 18.3, Aschoff 16 recalculated by Grande, Wade & Bishop 20, Holliday 21): identical; no printed value changed.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
<!-- errata:end -->
