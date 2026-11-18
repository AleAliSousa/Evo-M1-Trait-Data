# Röhrs 1986 — Table 2 (mustelid brain-part volumes, 10 species)

Röhrs M (1986). *Cephalisation, Telencephalisation und
Neocorticalisation bei Mustelidae.* Zeitschrift für Zoologische
Systematik und Evolutionsforschung 24: 157–166.
doi:10.1111/j.1439-0469.1986.tb00624.x

**Table 2** — species-typical net volumes (mm³) of whole brain (HV),
telencephalon (TELV), neocortex (NEOCV) and allocortex + corpus
striatum (ALLO+CSTRV) for **10 mustelid species**.

This is the source of the ferret row in Castillo-Morales et al. (2016)
Table 1 (their ref 91): the *Mustela putorius* row here (brain
8899.6 mm³, neocortex 4147 mm³) is printed there as *Mustela putorius
furo*, 8.8996 cm³ / 4.147 cm³.

## Source → Snapshot → Data readable → Online database

- **Source:** the publisher PDF scan of the paper, held in this folder
  (`Ro_hrs-1986-Cephalisation__Telen.pdf`, supplied by Michael Proulx
  2026-11-18); Table 2 is printed on journal p. 163.
- **Snapshot:** `Röhrs__1986_Table2_snapshot.csv` — the table
  transcribed exactly as printed (German decimal commas, printed
  header abbreviations), frozen **before** any cleaning. Transcribed
  by Buddy (AI assistant) on 2026-11-18 and verified value by value
  against the rendered page image of journal p. 163.
- **Data readable:** `Röhrs__1986_Table2.R` reads **only** the
  snapshot and writes `Röhrs__1986_Table2.csv` (10 rows) and the
  public TSV. The script runs clean under Rscript and reproduces the
  committed CSV/TSV exactly.
- **Definitions:** `reference_tables/Röhrs__1986_Table2_definitions.csv`.
- **Online database:** public TSV
  `10.1111%2Fj.1439-0469.1986.tb00624.x_Table2.tsv` in
  `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `Röhrs__1986_Table2`).

## Table checks

The reader checks the identity the table implies, TELV = NEOCV +
ALLO+CSTRV, per species (build HOWTO §7a). **Result (R run,
2026-11-18): 9 of 10 pass exactly; the printed *Conepatus humboldti*
row fails** — its parts sum to 8449.69 mm³ against a printed TELV of
8446.1 mm³ (difference 3.59 mm³). The script reports the mismatch as a
warning on every run and changes nothing; the values are kept as
printed and the discrepancy is recorded as erratum
`Röhrs__1986-E001` in `reference_tables/Röhrs__1986_errata.csv`.

## Data role and caveats

- **Secondary.** The volumes rest on the volume determinations of
  Schumacher (1963) and Thiede (1973), converted by Röhrs to
  species-typical values using Table 1's mean brain/body weights,
  subadults removed.
- Tables 3 (compartment percentages) and 4 (telencephalisation /
  neocorticalisation indices) of the paper are derived quantities and
  were not transcribed as items.
- Names as printed are kept verbatim.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Röhrs__1986_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Röhrs__1986-E001 | Telencephalon_volume_mm3 | Tabelle 2, row "Conepatus humboldti" | 8446,1 | 8446.1 | publication_error |  | proposed | The printed parts do not add to the printed telencephalon: NEOCV 5735,9 + ALLO+CSTRV 2713,79 = 8449,69, but TELV is printed as 8446,1 (difference 3,59 mm3). For the other nine species the identity TELV = NEOCV + ALLO+CSTRV holds exactly. One of the three printed values in this row is a misprint; which one cannot be told from the paper. | Values kept as printed in the snapshot and the analysis CSV; the item build script's table_checks report this row as a mismatch on every run. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
