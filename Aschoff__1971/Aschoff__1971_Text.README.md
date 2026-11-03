# Aschoff__1971_Text

**Item name** `Aschoff__1971_Text` · **Item number** `Text` · **Item encoded** `Aschoff%3A1971%3AEnergiehaushalt_Text` — *derived, awaiting registration*
( Paste `Aschoff__1971_Text_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Aschoff, J. (1971). Temperaturregulation [section of: Aschoff, J., Günther, B., & Kramer, K., *Energiehaushalt und Temperaturregulation*]. In O. H. Gauer, K. Kramer, & R. Jung (Eds.), *Physiologie des Menschen, Band 2*. Urban & Schwarzenberg. (No DOI; scanned 12-page excerpt, Tabelle 1 on p. 44, Abb. 1 on p. 45.)

**Item full original title:** Values printed in Abb. 1 (Topographie der Wärmebildung, p. 45) and in the running text and the Tabelle 1 caption of pp. 44-45.

## Source

PDF in this folder: `aschoff_1971.pdf`. Constructed item (there is no printed table): one row per printed value, with page, location, the label line or sentence it comes from, quantity, state and organ group. Abb. 1 prints, per organ group, the percentage of heat production at rest and at work and of body weight, a shading legend in cal/100 g/min and surface/volume ratios on leader lines.

## Pipeline

```
Source (PDF)
  -> Aschoff__1971_extract_snapshot.R   writes the frozen snapshot(s)
  -> Aschoff__1971_Text_snapshot.csv   FROZEN (constructed): 30 rows x 10 cols
  -> Aschoff__1971_Text.R   parse + label + table checks (cross-checks Aschoff__1971_Tabelle1.csv when present)
  -> Aschoff__1971_Text.csv   29 rows x 17 cols  ("use this")
  -> __Public/comparative-data/Aschoff%3A1971%3AEnergiehaushalt_Text.tsv
  -> reference_tables/Aschoff__1971_Text_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-03 from 170/300-dpi renders of PDF page 2 (book pp. 44-45), typed as a verbatim printed-layout block into `Aschoff__1971_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. Abb. 1 is a figure: every printed number was read from the 300-dpi crop of the figure (the OCR text layer garbles it); the running-text sentences were checked against the OCR text layer afterwards and agree. The build script reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`) on 2026-11-03.

### Values included

* Abb. 1 (rows 1-12): brain 16 / 3 / 2; Brust und Baucheingeweide 56 / 22 / 6; Haut und Muskel 18 / 73 / 52; restliche Anteile (Knochen usw.) 10 / 2 / 40 (heat % at rest / at work, weight %).
* Abb. 1 legend (rows 13-17): 45,0 / 35,0 / 15,0 / 1,0 / 0,5 cal/100 g·min (shading classes at rest, no organ named) and surface/volume cm⁻¹ 0,1 / 0,6 / 1,0 / 2,2 / 0,9 on leader lines (rows 18-22; the body part is not named in print).
* Caption values 65 kg and 270 cm³/min (rows 23-24); text percentages 8, >70, 52, 18 (rows 25-28) and 25 (row 29).
* Observation level: group-of-organs shares of a textbook reference body.


## Table checks

Result of an actual R run (2026-11-03, `Rscript`, conda env `r`): **11 pass, 1 mismatch, 0 not evaluable**, of 12 checks. Rule: rounding of each printed factor (half a unit of its last printed decimal) or, for a percentage recomputed from a printed total, one unit of its last decimal (HOWTO 7a). Every mismatch is kept as printed and explained below; nothing was changed to make a check pass.

Not-pass checks (the passing checks are in the table_checks object of the build and listed by `build_dataset_item()`):

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `abb1_skinmuscle_weight_vs_tab1` | Abb. 1 Haut und Muskel weight share (52) vs Tabelle 1 Haut + Muskel (5.000 + 27.000 g) / 65 kg | 49.2308 | 52 | -2.76923 | 0.5 | mismatch |

## Printed-vs-recomputed discrepancies

1. **Abb. 1 'Haut und Muskel' weight 52% vs Tabelle 1 (49,2%)**: Tabelle 1 lists Haut 5.000 g + Muskel 27.000 g = 32 kg of 65 kg = 49,2%. The figure's group is larger than the two tabulated tissues (the text calls it the 'Schale', 52% of body weight); a difference in grouping, not an arithmetic error. All other Abb. 1 / text / Tabelle 1 relations pass: Abb. 1 columns each add to 100; 2 + 6 = 8% weight and 16 + 56 = 72% (>70%) heat for the core organs agree with Tabelle 1 (7,7% of weight; 72,0% of 270 mL O2/min); brain 43,0/270 = 15,9% ≈ 16%; 1.350/65.000 = 2,1% ≈ 2%.
2. The 'brain 16% of heat at rest' value attributed to Aschoff in later papers is this Abb. 1 value (printed as an integer %).

## Data role

**secondary** (textbook figure credited to Aschoff & Wever 1958; text cites `[1]`).

## Species names

`species_as_published` keeps the printed label. Rows for this paper folder were appended to `_keys/General/species_key.csv` (collection General; 2026-11-03, pending owner sign-off) and the build stops if the key returns no rows for the folder. No species is printed; `human` is inferred.

## Per-row source citations

`[1]` is printed after the 52%/18% statement. The chapter bibliography is not in the scanned excerpt, so the citation cannot be given; `reference_tables/Aschoff__1971_Text_references.csv` records the key, the statement it supports and the unresolved citation (rows 27-28 carry `ref_key = [1]`). The Abb. 1 caption credits Aschoff & Wever, Naturwissenschaften 45 (1958) 477 for the figure as a whole.

## Compilation comparison (done AFTER the snapshot was frozen)

The working transcriptions and the cross-source comparison live in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`CLASSIC_COMPILATIONS_FINDINGS.md`); they were compared with this snapshot only after it was frozen, and no printed value was changed. The merged `__merging_cerebral_metabolic_rate` was not modified. The 16% / 2% brain share of `classic_human_brain_partition.csv` comes from this item's Abb. 1 and from Tabelle 1 (43,0 of 270).

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
<!-- errata:end -->
