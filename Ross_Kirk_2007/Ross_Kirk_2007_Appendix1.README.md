# Ross_Kirk_2007_Appendix1 - README

**Source.** Ross, C. F., & Kirk, E. C. (2007). Evolution of eye size and shape in primates.
*Journal of Human Evolution, 52*(3), 294-313. https://doi.org/10.1016/j.jhevol.2006.09.006

**Item.** `Appendix 1` (pp. 308-310), "Data, activity patterns, and taxon and activity codes used
for analyses". Registry `Item name` = `Ross_Kirk_2007_Appendix1`, `Item encoded` =
`10.1016%2Fj.jhevol.2006.09.006_Appendix1`.

## What the data are - and what they are not

Eye and body measurements for **260 visually dependent terrestrial mammal species** across
19 orders as printed (Primates 91, Carnivora 40, Rodentia 40, Artiodactyla 27, Didelphimorphia 11, ...):
**AD** (axial eye diameter, mm), **CD** (corneal diameter, mm), **HBL** (head and body length, mm),
the number of specimens, and an **activity-pattern code** (c = cathemeral, d = diurnal,
n = nocturnal).

**This item contains no play data.** It was built alongside `Pellis_Iwaniuk_2000_Table1` and
`Graham__2011_TABLEI` but belongs to the sensory/eye-morphology domain, not the play domain; its
`ACT` column is an activity pattern, not a behavioural play measure. It is therefore **not wired
into `__merging_behaviour`**. The natural consumer is the sensory merge, where
`Veilleux_Kirk_2014_SupplementalTable1` already carries eye axial diameter - that wiring was not
part of this task and is left for the owner.

## Data role

**Primary for the eye measures.** The authors measured AD and CD on eyeballs dissected from
preserved museum, university and private specimens (Materials and methods), with eye- and
body-length data from Ritland (1982) culled in. **HBL is flagged secondary** in the definitions
file: it was taken from the same specimens *or* estimated as the median of ranges published in
Nowak (1991) / Rowe (1996), and the appendix does not say which applies to a given row.
Activity pattern is likewise compiled from the literature plus the authors' own observations.

## Files

| file | what it is |
|---|---|
| `ross_kirk_2007.pdf` | the publication |
| `Ross_Kirk_2007_extract_snapshot.R` | PDF text layer -> frozen snapshot (two printed columns per page, reading order reconstructed) |
| `Ross_Kirk_2007_Appendix1_snapshot.csv` | the frozen source: title, header, 260 rows in printed order, the appendix's Notes line |
| `Ross_Kirk_2007_Appendix1.R` | build: snapshot -> analysis CSV + public TSV |
| `Ross_Kirk_2007_Appendix1.csv` | analysis CSV, 260 rows x 14 columns |
| `reference_tables/Ross_Kirk_2007_Appendix1_definitions.csv` | data dictionary (18 rows) |
| `__Public/comparative-data/10.1016%2Fj.jhevol.2006.09.006_Appendix1.tsv` | public TSV (repo-level) |

## Source -> snapshot

Printed appendix, so a snapshot is required. Each appendix page prints **two independent table
columns**, so one text-layer line carries up to two data rows; the extract script splits them on
the match offset and keeps printed reading order (all left-column rows of a page, then the right).
Row counts: p. 308 62 + 64, p. 309 65 + 64, p. 310 5 = **260**, the sample size the paper states.
The appendix's own Notes line is extracted as the snapshot's last row and is the authority for the
column definitions.

**Reader.** AI assistant (Claude), 2026-10-28. Checked against 170-dpi renders of pp. 308, 309 and
310: the two-column reading order, the per-column row counts, the Notes line, the printed Order
spelling "Paramelemorphia", and the two rows where CD equals AD. Pending human RA sign-off.

## Printed quirks, preserved

- **"Paramelemorphia"** is printed as the Order for *Perameles nasuta* (misprint for
  Peramelemorphia). Kept verbatim; the build asserts it is the only non-standard Order spelling.
- **Two rows print CD equal to AD**: *Marmosa* sp. (7.3 / 7.3) and *Hystrix cristata*
  (11.2 / 11.2). Both confirmed on the page renders. The build allows CD <= AD and asserts that
  exactly two rows are equal, so a parse error that produced a third would fail.
- **24 records are genus-level** ("sp."), keyed to `<Genus> sp.` with the NCBI genus taxid.

## Species keys

51 printed names needed anchoring and were added to `_keys/General/species_key.csv`
(`source_publication = Ross_Kirk_2007`), each with its NCBI taxid and basis, checked against NCBI
taxonomy on 2026-10-28:

- NCBI synonym redirects, e.g. *Selenarctos thibetanus* -> *Ursus thibetanus*,
  *Hylobates leucogenys* -> *Nomascus leucogenys*, *Allactaga elater* -> *Scarturus elater*,
  *Strigocuscus gymnotis* -> *Phalanger gymnotis*, *Strepsiceros spekei* -> *Tragelaphus spekii*.
- Four printed misspellings, each resolved to the nearest NCBI name **within the printed genus**
  (edit distance 1), not from memory: `Kobus ellipsprymnus` -> *K. ellipsiprymnus*,
  `Galago sengalensis` -> *G. senegalensis*, `Lophocebus albingena` -> *L. albigena*,
  `Calomyscus baliwardi` -> *C. bailwardi*.
- `Rattus rattus` needed an explicit paper-scoped row because the variant name was **ambiguous**
  across existing spokes.

**Four printed names have no anchor in NCBI taxonomy and are deliberately left unresolved**
(kept under the printed string, `species_basis = unresolved`): `Lutra annectans`,
`Hemiechinus megalotis`, `Neotetracus fulvescens`, `Graphiurus heuti`. Each looks like a misprint
or a lapsed combination, but no candidate could be confirmed from the genus's NCBI species list, so
none was guessed. The build asserts exactly this set, so a new unresolved name breaks it.

## Table checks

None: the appendix prints no totals or other internal relation that could check itself (HOWTO 7a).
