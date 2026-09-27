# Ridgway__1990 — Table 1 (brain and body size of adult bottlenose dolphins)

Ridgway, S. H. (1990). *The Central Nervous System of the Bottlenose Dolphin.* In
S. Leatherwood & R. R. Reeves (Eds.), *The Bottlenose Dolphin* (pp. 69–97). Academic
Press. https://doi.org/10.1016/B978-0-12-440280-5.50008-1

Registry item: **Table 1**, "Brain and Body Size of Adult Bottlenose Dolphins" —
printed p. 72 (PDF page 4 of the chapter reprint held in this folder,
`ridgway_1990.PDF`).

## What this covers

Body length (BdL, cm), body weight (BdW, kg), and brain weight (BrnW, kg) for 29
individual adult *Tursiops truncatus*, grouped into three geographic categories:
eastern North Atlantic and Mediterranean (n=6), eastern North Pacific (n=4), and
western North Atlantic coastal including the Gulf of Mexico (n=19). Sex and a
per-animal literature source (author-year) are printed for most rows. The source
table also prints a Mean and S.D. row for each of the three categories.

## Source → snapshot → CSV

- **Source:** `ridgway_1990.PDF` — a scanned photocopy of the book chapter (no
  usable text layer; a semantic/text search of the PDF returns only page images).
  **Table 1 was transcribed by hand from a 150 dpi render of PDF page 4** (printed
  page 72) and cross-checked digit-by-digit against the rendered image before
  writing the snapshot. Read by: AI assistant (Cowork), 2026-09-26.
- **Snapshot:** `Ridgway__1990_Table1_snapshot.csv` — journal-faithful layout:
  title line, header row, one row per animal with the category printed only on
  the first row of its group (as in the source), a Mean and S.D. row per group,
  and the lettered footnote reproduced verbatim at the end.
- **Analysis CSV:** `Ridgway__1990_Table1.csv` — long format, one row per
  individual animal plus one `group_mean`/`group_sd` row pair per geographic
  category (35 rows total): `species`, `species_sci`, `geographic_category`,
  `row_type`, `sex`, `body_length_cm`, `body_weight_kg`, `brain_weight_kg`, `n`
  (individuals per group, tallied — not printed explicitly), `source`.

## Verification

- Re-transcription checked against the rendered page image a second time before
  finalizing (all 29 individual rows + 6 summary rows).
- Recomputed group means from the 29 individual rows match the printed Mean rows
  within rounding for every category and both measures (BdW, BrnW) — e.g. E.
  North Atlantic/Mediterranean BdW: mean of the 6 printed weights = 234.7 ≈
  printed 235; BrnW: 2.0527 ≈ printed 2.053. See the `stopifnot` checks in
  `Ridgway__1990_Table1.R`.
- Group sizes (6 / 4 / 19) were counted from the individual rows, since the
  source does not print an explicit *n* — recorded as `n` on the summary rows
  only, flagged as derived (not transcribed) in the definitions file.

## Units

BdL in cm, BdW and BrnW in kg — all as printed; no unit conversion applied (this
table is body/brain **mass** in kg, not a structure volume, so the project's
mm³/mg volumetric convention does not apply here).

## Observation level

Per-individual (each row before the two group-summary rows is one adult dolphin).
The `group_mean`/`group_sd` rows are printed regional summaries and must not be
double-counted alongside the individuals they summarise in any downstream
pooling — see the `Method:observation_level` row in the definitions file.

## Data role

Primary for the animals whose source is `Ridgway (unpublished)` or a
Ridgway-authored citation; secondary (compiled from the cited literature) for the
Pilleri and Gihr (1970), Weber (1897), and Kruger (1959) rows. The whole table is
registered as a single item since it is one printed table; per-row provenance is
kept in the `source` column for anyone who needs to split primary from secondary
before merging.
