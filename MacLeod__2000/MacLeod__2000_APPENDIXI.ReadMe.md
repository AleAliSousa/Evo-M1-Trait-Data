# MacLeod 2000 -- Appendix I (Hirnforschung sample)

MacLeod CE (2000). *The Cerebellum and Its Part in the Evolution of the Hominoid Brain.* Ph.D. dissertation, Simon Fraser University.

Full appendix title: **"Duesseldorf records of primates used in volumetric study (Hirnforschung sample)"**.

## Source -> Snapshot
`macleod_2000.pdf`, Appendix I, printed pp. 199-200 (PDF pages 218-219). The table was taken from rendered page images of the scanned dissertation and transcribed into `MacLeod_2000_APPENDIXI_snapshot.xlsx`.

Snapshot fidelity: original row order, line breaks, `NA` values, units (`K.`, `G.`, `GR.`), section-plane labels, stain labels, and the `STEPHAN *` footnote marker were retained. The snapshot is intentionally not cleaned.

## Data readable
`MacLeod_2000_APPENDIXI.R` -> `MacLeod_2000_APPENDIXI.csv` and `MacLeod_2000_APPENDIXI.tsv` (**use these**).

Cleaning performed in the script:

- derives `species` from the printed `SPECIMEN` cell;
- keeps the printed specimen text in `specimen_printed` and the printed ID in `identification_number`;
- parses `body_weight_kg`, `brain_weight_g`, and `fixed_volume_cm3` while retaining the original raw fields;
- uses the estimated brain weight when a row prints both a with-meninges weight and an estimated weight (e.g. A375);
- normalizes `CUT` into `section_plane` while retaining `section_plane_raw`;
- decodes flags for `stephan_database_specimen` (`*`), `stephan_related_note` (printed Stephan/source note), and `semendeferi_record`.

## Provenance
This appendix records the Duesseldorf/Hirnforschung specimens used for the volumetric study. It is a specimen-record/provenance table, not the final volumetric Table I from the Results chapter. Some rows include Zilles, Stephan, Semendeferi, Yerkes, or trader/source notes in the printed specimen/source cells.

## Species note (IN PROGRESS)
Binomials were standardized only enough for a readable specimen-level table. Some printed rows are genus-only or abbreviated in the appendix (`GIBBON`, `CEBUS`, `AOTUS`, `CERCOPITHECUS`, etc.), so reconcile to project species keys before online-database use.

Pipeline: Source -> Snapshot ✅ -> Data readable ✅ -> Species note ⏳ -> Online database ☐
