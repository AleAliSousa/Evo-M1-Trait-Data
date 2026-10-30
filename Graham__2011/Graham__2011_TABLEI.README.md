# Graham__2011_TABLEI - README

**Source.** Graham, K. L. (2011). Coevolutionary relationship between striatum size and social play
in nonhuman primates. *American Journal of Primatology, 73*(4), 314-322.
https://doi.org/10.1002/ajp.20898

**Item.** `TABLE I` (p. 317), "Percentages of Social and Nonsocial Play, Adult Body and Brain
Weights and Striatum Volumes in Nonhuman Primates". Registry `Item name` = `Graham__2011_TABLEI`,
`Item encoded` = `10.1002%2Fajp.20898_TABLEI`.

## What the data are

For **14 primate taxa** (12 species plus *Papio* spp. and *Pithecia* spp. at genus level): the
percentage of the activity budget spent in **social play** and in **nonsocial play**, with adult
**brain size (g)**, **body size (g)**, **striatum volume (mm3)** and the per-row literature the play
percentages were derived from.

This is a **time-budget play measure** - a percentage of activity - and so a different quantity from
the ordinal adult-adult play ratings in `Pellis_Iwaniuk_2000_Table1` / `Iwaniuk_etal_2001_Table4`,
and a different denominator from the Bartlett 2003 ("share of social activity") and Kerney 2017
("share of all activity") measures already in `__merging_behaviour/social_mirror_play_long.csv`.

## Data role: secondary

Every column is compiled or republished, and the registry `Data role` is `secondary`:

| column | printed basis |
|---|---|
| % social / % nonsocial play | footnote a - "mean percentages derived from the sources provided in this table" |
| Brain size (g) | footnote b - Barton [1999] |
| Body size (g) | footnote c - Barton [1999] |
| Striatum (mm3) | footnote d - Stephan et al. [1981] (the volumes merge is authoritative for this) |

The play percentages are nonetheless a **quantity no other registered item carries**: Graham
aggregated them from 37 primary studies that are not themselves registered here.

## Files

| file | what it is |
|---|---|
| `Graham-2011-Coevolutionary relationship betwee.pdf` | the publication |
| `Graham__2011_extract_snapshot.R` | PDF text layer -> frozen snapshot (values, per-row sources and footnotes all extracted, nothing typed) |
| `Graham__2011_TABLEI_snapshot.csv` | the frozen source: caption, header, 14 rows, the 6 footnotes |
| `Graham__2011_TABLEI.R` | build: snapshot -> analysis CSV + public TSV |
| `Graham__2011_TABLEI.csv` | analysis CSV, 14 rows x 14 columns |
| `reference_tables/Graham__2011_TABLEI_definitions.csv` | data dictionary (17 rows) |
| `reference_tables/Graham__2011_TABLEI_references.csv` | the per-row citations as data (37 printed keys) |
| `__Public/comparative-data/10.1002%2Fajp.20898_TABLEI.tsv` | public TSV (repo-level) |

## Source -> snapshot

Printed table, so a snapshot is required. `Graham__2011_extract_snapshot.R` reads the PDF text layer
at run time and reattaches the wrapped binomials ("Callithrix" / "  jacchus") and the wrapped
Sources cells; the six footnote texts are extracted too, so the only literals in the script are the
caption and the column-header stubs, each anchor-verified. A differing extraction is written to
`*_snapshot_NEW.csv` and the run stops.

**Reader.** AI assistant (Claude), 2026-10-28. Checked against a 200-dpi render of p. 317: the 14
rows and their values, the three en dashes in % nonsocial play, the wrapped binomials, the
superscript e/f on every citation, and the genus-level *Papio* spp. / *Pithecia* spp. labels.
Pending human RA sign-off.

## Per-row citations (the Sources column is data)

`reference_tables/Graham__2011_TABLEI_references.csv` holds one row per printed citation key
(`ref_key` exactly as printed, including its superscript letter), with the verbatim bibliography
entry and a note giving the study setting and which taxa the key is cited for. The join is:
split `sources_printed` on `"; "`, match `ref_key`. The build script fails if any printed key is
missing from that file.

- 36 of the 37 printed keys resolve to a bibliography entry.
- **`Lewis, 1997` is cited in Table I (for *Callithrix jacchus* and *Nycticebus coucang*) but does
  not appear in the paper's reference list**, which carries Lewis KP 2000, 2003, 2005, 2010 and
  Lewis & Barton 2004, 2006. Recorded in the `note` and left as printed, not corrected.
- Two printed keys each cover two works (`Owens, 1975a,b` and `Stevenson and Poole, 1976, 1982`);
  both bibliography entries are given in one row, separated by ` || `.

## Table checks

None: the table prints no totals or other internal relation that could check itself (HOWTO 7a).

## Units

Brain size is converted g -> mg (x1000) for the project standard and kept as printed as well; body
mass (g) and striatum volume (mm3) are already in project units.
