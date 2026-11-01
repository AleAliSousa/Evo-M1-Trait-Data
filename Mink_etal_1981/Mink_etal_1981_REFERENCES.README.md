# Mink_etal_1981_REFERENCES

**Item name** `Mink_etal_1981_REFERENCES` · **Item number** `REFERENCES` ·
**Item encoded** `10.1152%2Fajpregu.1981.241.3.R203_REFERENCES`

Mink, J. W., Blumenschine, R. J., & Adams, D. B. (1981). Ratio of central nervous system to
body metabolism in vertebrates: its constancy and functional basis. *American Journal of
Physiology* 241(3), R203–R212. <https://doi.org/10.1152/ajpregu.1981.241.3.R203>

## What this item is

The paper's printed **REFERENCES** list, pp. R211–R212: **92 numbered entries**, in printed
order. It carries no measurements, no species and no traits.

Its job is to be the **lookup layer for `Mink_etal_1981_TABLE1`**. Nearly every cell of TABLE 1
prints a reference number in parentheses (`0.097 (20)`), and the footnotes do too
(`[Latimer (56)]`); those numbers index this list. The item is built on the same pattern as
`Kaskan_etal_2005_References`.

## Pipeline

```
Source (scanned PDF pp. 10-11)
  -> Mink_etal_1981_REFERENCES_snapshot.csv   FROZEN: 92 rows, ref_number + reference_as_printed
  -> Mink_etal_1981_REFERENCES.R              reads the snapshot, parses the year
  -> Mink_etal_1981_REFERENCES.csv            92 rows x 3 cols  ("use this")
  -> __Public/comparative-data/10.1152%2Fajpregu.1981.241.3.R203_REFERENCES.tsv
  -> reference_tables/Mink_etal_1981_REFERENCES_definitions.csv
```

**Build this item before `Mink_etal_1981_TABLE1.R`**, which reads its CSV.

## Who read the values, when, and how it was checked

**Manual transcription (method 5 of the snapshot HOWTO) by an AI assistant (Claude) on
2026-10-31**, typed directly into the frozen `_snapshot.csv` and read from 400-dpi renders of
PDF pages 10 and 11 at roughly 1.5–2× zoom, column by column. The build script reads that file
and contains no citation text.

The scan's OCR text layer was used only as a cross-read and was **not** trusted: it misreads the
year of entry 11 as 1970 where the page prints 1978, and mangles several accented names. Where
the two disagreed the page image was re-read and the image reading taken.

Checks run:

* the frozen file has exactly 92 rows and `ref_number` is `1:92` in printed order (asserted in
  the build script, so the build fails if an entry is ever lost);
* `year`, parsed as the last four-digit year in each entry, agrees with the last four-digit run
  anywhere in the string on **all 92 rows** (range **1878–1978**);
* all **54** reference numbers that `Mink_etal_1981_TABLE1` cites resolve against this list, with
  no unresolved key and no year mismatch.

## Fidelity

Entries are verbatim, including the paper's own typographic errors, which are **not corrected**:

| ref | printed | evidently intended |
|---|---|---|
| 1 | Anatomie **cómparée** du cerveau | comparée |
| 41 | Blood flow and oxygen **untake** in mammals | uptake |
| 48 | Über die **Oberflächeroregel** des Stoffwechsels | Oberflächenregel |

Entries 1 and 48 were re-checked at 2× zoom to confirm the accent and the spelling are on the
page and are not scan artefacts. These are typography in a bibliography and affect no value, so
they are recorded here rather than in `reference_tables/Mink_etal_1981_errata.csv`.

**The one character-level change made:** en dashes in page ranges are transcribed as plain
hyphens (`453-474`). Accented and non-ASCII characters are preserved as printed (`EKLÖF`,
`SIESJÖ`, `RÖHRS`, `RABL-RÜCKHARD`, `LIPÁK`, `Données`, `métabolisme`, `√2-sprüngen`), so the
file must be read as UTF-8.

## Data role

**Proposed: `secondary`** (the registry cell is currently blank — see
`Mink_etal_1981_REFERENCES_registry_row.xlsx` and `_checks/registry_pending.csv`).
A bibliography holds no data of its own; this item is provenance infrastructure and is excluded
from every merge.

## Taxon

**Proposed: `Not applicable (bibliography; no taxa)`.** The works listed cover the 42 vertebrate
species of TABLE 1, but this item itself carries no species column.

## Human visual check of snapshot

Not yet recorded in `__ReadMe.xlsx`. A human should read a sample of entries — including some
from the middle of each printed column and the three typographic oddities above — against
pp. R211–R212 and record `DDMMYYYY_initials`.

## Errata

No errata are filed against this item. The paper's errata file,
`reference_tables/Mink_etal_1981_errata.csv`, holds four rows, all of them against
`Mink_etal_1981_TABLE1`.
