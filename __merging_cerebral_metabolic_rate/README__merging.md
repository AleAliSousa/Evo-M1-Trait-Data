# Merging cerebral metabolic-rate data

This is the canonical public merge for regional and whole-brain cerebral
metabolic rate.  It reconciles the underlying primary studies in two secondary
compilations rather than treating the compilations as independent evidence.

The reusable procedure is `_skills/reconcile-data-compilations/SKILL.md`.

## Sources and roles

| Source | Data role | Treatment |
|---|---|---|
| `Heiss_etal_2004` | primary study | Its 26 regional CMRgl rows enter directly under `heiss_2004`. |
| `Kaufman__2004` Tables A1-A14 | secondary compilation, with a small number of self-primary “Present Study” rows | Each table row is joined to its underlying primary work. Table A15 compiler means are not used. |
| `Karbowski__2007` Tables S1-S23 | secondary compilation | Direct singleton-source rows are joined to their primary works. Compiler/derived rows remain in provenance but not in primary-only means. |

Kaufman and Karbowski are recorded in `Compilation`. Every cited bibliography
work is recorded separately in `source_reference_ids`, with an explicit
`reference_level`/`source_type`; only a work classified as a primary report also
receives a `primary_reference_id`. A shared primary work counts once even when
both compilations reprint it.

## Reference catalogs

Run `build_primary_reference_catalogs.py` when a source table or its reference
resolution changes.  It reads only the PDFs in the two source folders and writes:

- `Kaufman__2004/reference_tables/Kaufman__2004_TablesA1-A14_references.csv`
- `Karbowski__2007/reference_tables/Karbowski__2007_TablesS1-S23_references.csv`
- `cerebral_metabolic_rate_reference_resolution_issues.csv`

The first four catalog columns follow the repository contract:
`ref_key,cited_in_column,citation,note`.  `ref_key` is the exact string in the
data table. Added columns provide the stable cited-source ID, source level/type,
primary ID where applicable, conservative repaired core, resolution status,
source PDF/locator, tables, and occurrence count.

The catalogs contain 424 Kaufman citation aliases resolving to 319 cited-source
IDs (317 primary) and 56 Karbowski aliases resolving to 36 cited-source IDs (34
primary). Seventeen primary IDs occur in both catalogs; one is the compound-only
Madsen 1991b case, leaving 16 direct shared works.

Four resolved citations are not independent primary reports: Dastur 1985 is a
review, Clarke 1994 is a textbook chapter, Sokoloff 1984 is a monograph, and
Madsen 1993 is a pooled methodological reanalysis of earlier study series. Their
25 direct compiled measurement rows remain fully traceable but do not enter the
primary pool because row-level experimental lineage is not recoverable from the
supplied source folders. Kaufman's Madsen row is additionally internally
incompatible: it combines a corrected 15-minute-subgroup CBF estimate with a
pooled measured CMRO2 estimate, so its two measurement records are explicitly
held out pending component reconstruction.

One source-local limitation is retained explicitly: Kaufman Table A14 cites
`(Zimmer, 1975)`, but the dissertation bibliography and the rest of that folder
contain no Zimmer entry.  The raw citation is preserved in the Kaufman catalog
and the issue CSV; no external citation was guessed.  Its data row is explicitly
anesthetized and therefore does not enter the merged means.
The same issue CSV also records the four resolved non-primary sources whose
row-level primary lineage remains open.

`cerebral_metabolic_rate_cited_references.csv` is the complete merge-level
catalog (335 primary works plus those four non-primary works).
`cerebral_metabolic_rate_primary_references.csv` is the strict primary-only
subset. For shared works both retain each compilation's printed bibliography
form and use the cleaner typeset Karbowski entry as the canonical display
citation when Kaufman's bibliography OCR is damaged. The many-to-many
`cerebral_metabolic_rate_value_reference_links.csv` is authoritative for
row-to-cited-source lineage; joined fields in the main CSVs are convenience
views.

## What enters the merge

Every row is classified before aggregation.  Only a row satisfying all of these
conditions enters the primary pool:

1. It is a direct or self-primary measurement, not a compiler mean, estimate,
   cross-area summary, or derived total.
2. Its printed value resolves to exactly one primary work.  A single value cited
   to several works is a compound-source summary and is not split into fictitious
   independent observations.
3. It belongs to the accepted `nonanesthetized_unspecified_arm` merge category.
   Kaufman provides a row-level anesthesia field. Karbowski generally provides
   only a secondary-compilation claim (main-paper Methods, PDF p. 8:
   unanesthetized adult animals at rest); that statement does not establish an
   awake or control arm for every cited primary experiment. This category is
   deliberately not called baseline: Kaufman's `none` token likewise does not
   distinguish control, treatment, disease, task, age, or temperature arms.
   `condition_evidence` records whether an arm was checked in a primary source.
4. Within one compilation, that primary work has only one row for the complete
   source/cell/condition/unit key. Multiple rows are quarantined until their
   study arms can be reconstructed; they are never silently averaged.

The following remain in `cerebral_metabolic_rate_unfiltered.csv` with
`include_in_primary_merge=False` and an explicit reason:

- 73 Karbowski compiler-average rows;
- 7 Table S11 cross-source cortical summaries (`N=4`, `N=6`, `N=8` are counts,
  not citations);
- 10 Quelven-based compiler estimates (lineage records both Quelven's ratio and
  Bouilleret's absolute calibration);
- 17 compiler-derived whole-brain totals;
- 3 compound-source mass-specific rows;
- 25 direct values cited only to Dastur's review, Clarke's chapter, Sokoloff's
  monograph, or Madsen's pooled reanalysis, without row-level primary lineage;
- primary-specific Karbowski condition contradictions (anesthetized cohorts,
  Haier's task-active Tetris values, plus three Lydic values whose primary paper
  has quiet-wake and REM arms but whose copied numeric arm remains unresolved);
- 157 otherwise-eligible Kaufman rows in 77 within-primary full-key groups with
  unresolved arm identity (75 groups contain genuinely different values);
- Kaufman rows not confirmed conscious and the unresolved Zimmer citation.

`cerebral_metabolic_rate_arm_ambiguity_report.csv` gives each quarantined group
a stable ID, all record/value members, its primary citation, and the required
resolution action. If Kaufman and Karbowski each provide one eligible row for
the same primary source/cell/condition/unit, the build retains Kaufman's
source-level value for the canonical mean, preserves both reports in the
provenance table, and logs the resolution in
`cerebral_metabolic_rate_dedupe_report.csv`.  A disagreement is not independent
evidence and is not averaged as a second study.

Positive arm evidence is retained too: Passero rows are verified normal
conscious controls, Maquet values are the wakefulness-control column rather than
stage-2 sleep, and Schwartzman values are awake stationary controls rather than
the walking arm. These checks refine `conscious` and `condition_evidence` but
remain inside the deliberately broad nonanesthetized merge category.

This is therefore a nonanesthetized, condition-unspecified compilation—not a
healthy resting-control dataset. The multirow quarantine prevents known arm
collisions from being averaged, but a singleton copied row can still come from a
disease, drug, sleep, task, stimulation, or temperature protocol. A future
baseline-only analysis must resolve those primary-paper arms explicitly; the
present build never infers “control” from a citation title or an anesthesia
token alone.

The final aggregation is across distinct `primary_reference_id` values.  Each
row therefore includes `n_primary_references`, sorted `Primary_reference_ids`,
full `Primary_references`, `Compilations_reporting`, and `Compilations_used`.
Legacy `n_studies` and `Compilations` columns are retained as aliases for current
consumers.

## Source repairs and units

The frozen snapshots are unchanged. The Kaufman cleaners apply a checked overlay
to 11 rows whose PDF extraction shifted `Sokoloff et al. (1977)`, `n=10`, and
CMRgl/SD across columns; three rows whose scanned `n` and `Anesthesia` tokens ran
together; and PDF-verified collapsed/misaligned measurements or methods in A1,
A3, A6, A11, A13, and A14. The repair manifest guards the entire frozen row plus
its PDF locator before changing anything. `source_correction` marks all 43
affected output observations, and the validator checks every repaired printed
mean/SD lexeme. A positional audit covered all 1,435 logical A1-A14 rows.
For unaffected Kaufman records, `Value_raw` and `SD_raw` come directly from the
frozen snapshot, preserving decimal commas and printed trailing zeros. Karbowski's
extractor retains the published supplement PDF's `value_printed` and `sd_printed`
lexemes (S1 to three decimals; S2–S23 to two); its frozen workbook supplies numeric
values and row locations but loses some display-only zeros.
`source_snapshot_row` records the corresponding frozen-source data row; for
Karbowski this remains correct when one workbook row expands into two measures or
when printed subdivision rows are omitted from the analysis table.

Project-standard mass-specific units are:

| Measure | Standard unit | Conversion |
|---|---|---|
| `CMRgl` | µmol/100 g/min | Karbowski µmol/g/min × 100 |
| `CMRO2` | µmol/100 g/min | Karbowski mL O2/g/min × 100 × 44.64 µmol/mL |
| `CBF` | mL/100 g/min | Kaufman is already standardized |

Raw values and units remain alongside standardized values.  Conversion sentinels
are enforced in the build: Linde 1999, `0.084 mL/g/min -> 374.976 µmol/100g/min`,
and Nemoto 1994, `0.060 -> 267.84`.

Karbowski's distinct printed subregions are used for cell identity rather than
being lost under their parent headings: superior/inferior colliculus, mammillary
body, corpus callosum, and internal capsule are separate canonical regions.

## Build

From the repository root:

```sh
# Only needed when reference resolution changes:
PDFTOTEXT=/path/to/pdftotext \
  python3 __merging_cerebral_metabolic_rate/build_primary_reference_catalogs.py

# Canonical data build:
python3 __merging_cerebral_metabolic_rate/build_cerebral_metabolic_rate_merge.py

# Fixed-count, foreign-key, role, correction, and conversion checks:
python3 __merging_cerebral_metabolic_rate/validate_cerebral_metabolic_rate_merge.py
```

The catalog generator uses `PDFTOTEXT` when set, otherwise `pdftotext` on
`PATH`.  The main builder uses the repository species resolver (`_keys/resolve_species.py`),
which requires pandas, plus the generated catalog CSVs.

## Outputs

- `cerebral_metabolic_rate_long.csv`: 235 Species × Region × Measure cells,
  covering 14 species and 40 canonical regions. There are 201 metabolic cells
  (`CMRgl`, `CMRO2`) and 34 perfusion cells (`CBF`).
- `cerebral_metabolic_rate_wide.csv`: one row per species.
- `cerebral_metabolic_rate_unfiltered.csv`: all 2,161 source/provenance records,
  including excluded compiler and derived rows; 1,444 are currently in the
  conservative primary pool.
- `cerebral_metabolic_rate_arm_ambiguity_report.csv`: 77 unresolved
  within-primary arm groups covering 157 quarantined Kaufman rows.
- `cerebral_metabolic_rate_value_reference_links.csv`: 2,361 value-source links,
  including compound, estimate, compiler-average, and cross-area-summary lineage.
  Only the three unresolved Zimmer measurement records have no link.
- `cerebral_metabolic_rate_cited_references.csv`: all 339 resolved cited works,
  with source level/type.
- `cerebral_metabolic_rate_primary_references.csv`: the 335 true primary works
  across both compilations plus Heiss.
- `cerebral_metabolic_rate_reference_resolution_issues.csv`: explicit unresolved
  and non-primary-lineage issues (Zimmer plus the four non-primary cited works).
- `cerebral_metabolic_rate_dedupe_report.csv`: 44 same-source, same-taxon,
  same-region, same-measure, same-unit, same-condition collisions resolved for
  the merge.
- `cerebral_metabolic_rate_source_species_ids.csv`: printed-to-canonical taxon
  provenance.

Detailed value agreement is a check, so it lives in the restricted companion
repository.  The renamed audit driver is
`__energetics_comparison/cerebral_metabolic_rate_primary_source_comparison.R` and
its main output is `cerebral_metabolic_rate_Kaufman_vs_Karbowski.csv`. It compares
all direct singleton-primary rows, not just rows admitted to the conservative merge,
and records merge eligibility separately. Current counts are generated in the
restricted findings file rather than copied here, so this public documentation
cannot silently drift from the comparison output.

## Known comparison cautions

- Matching a bibliography work is necessary but not sufficient: taxon, region,
  measure, condition, and unit must also agree.
- Primary-specific taxon evidence resolves Kaufman's `Lepus` Passero 1981 rows
  to *Oryctolagus cuniculus* and its `M fascic` Kennedy 1978 rows to *Macaca
  mulatta*. Printed labels remain unchanged in provenance; the validator guards
  both overrides and the resulting eight shared-source matches.
- Heiss anatomical lobes and compilation “cortex” labels remain a documented
  lobe≈cortex harmonization in the canonical region map.
- `Basal_ganglia` is not pooled with its component nuclei.
