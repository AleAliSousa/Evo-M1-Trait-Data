# Heffner_Heffner_2016_Figure5 - README

**Source.** Heffner, H. E., & Heffner, R. S. (2016). The evolution of mammalian sound localization.
*Acoustics Today, 12*(1), 20-27.
https://acousticstoday.org/wp-content/uploads/2016/01/The-Evolution-of-Mammalian-Sound-Localization.pdf

**Item.** `Figure 5` (p. 24). Registry `Item name` = `Heffner_Heffner_2016_Figure5`,
`Item encoded` = `AcousticsToday%3A12%3A1%3A20-27_Figure5`.

## What this item is - and what it deliberately is not

Figure 5 is a log-log scatter of **width of the field of best vision (degrees)** against
**sound-localization threshold (degrees)** for **22 species of mammals**, with `r = .89`,
`p < .001, n = 22` printed in the panel. It is captioned "Modified from Heffner et al. (2001)".

This item records **what the figure states exactly**: which 22 species the relationship rests on,
the two axis quantities with their printed tick ranges, and the printed regression statistics.
**The point coordinates were deliberately not digitized** (owner decision, 2026-10-29), so every
row carries a species identity and provenance and **no measured value**. The reason is provenance,
not effort: the numbers behind the points are published as numbers elsewhere, and a digitized copy
of a republished figure would be superseded the moment the primary is ingested.

Where the values live:

- **Heffner, R. S., Koay, G., & Heffner, H. E. (2001).** Sound localization in a New-World
  frugivorous bat, *Artibeus jamaicensis*: Acuity, use of binaural cues, and its relationship to
  vision. *J. Acoust. Soc. Am. 109*, 412-421 - the figure's cited source. **Not in the registry**;
  registering and building it is the way to get these values properly.
- **`Heffner_Heffner_1992_a_TABLE1`** - already in the repo, and it tabulates *both* quantities for
  10 of these 22 species: *Bos taurus*, *Canis lupus familiaris*, *Didelphis virginiana*, *Felis catus*, *Homo sapiens*, *Meriones unguiculatus*, *Mustela nivalis*, *Onychomys leucogaster*, *Rattus norvegicus*, *Sus scrofa*.

So the figure's own contribution, once the primary is in, would be field-of-best-vision values for
the remaining 12 species: *Artibeus jamaicensis*, *Carollia perspicillata*, *Chinchilla laniger*, *Eidolon helvum*, *Eptesicus fuscus*, *Macaca fuscata*, *Marmota sp.*, *Mesocricetus auratus*, *Mus musculus*, *Mustela putorius furo*, *Phyllostomus hastatus*, *Rousettus aegyptiacus*.

## Files

| file | what it is |
|---|---|
| `heffner_heffner_2016.pdf` | the publication |
| `Heffner_Heffner_2016_Figure5_snapshot.csv` | the frozen **constructed** snapshot: caption, both axis titles, both tick-label sets, the two statistic lines, and the 22 species labels in printed panel order |
| `Heffner_Heffner_2016_Figure5.R` | build: snapshot -> analysis CSV + public TSV |
| `Heffner_Heffner_2016_Figure5.csv` | analysis CSV, 22 rows x 15 columns |
| `reference_tables/Heffner_Heffner_2016_Figure5_definitions.csv` | data dictionary (18 rows) |
| `__Public/comparative-data/AcousticsToday%3A12%3A1%3A20-27_Figure5.tsv` | public TSV (repo-level) |

## Source -> snapshot (constructed)

The figure's internal text is **outlined in the PDF** - `pdftools::pdf_data()` returns no words
inside the plot area - so there is no text layer to extract and the snapshot is a hand
transcription, the snapshot HOWTO's documented fallback. The 22 labels, the axis titles, the tick
labels and the two statistic lines were read from a **420-dpi render of p. 24** and verified
against it; the caption was taken from the page's own text layer. The build script reads that
frozen file and contains no transcribed content of its own.

**Reader.** AI assistant (Claude), 2026-10-29. Pending human RA sign-off.

## Printed quirks, preserved

- **`Virginia opposum`** is printed that way in the panel (the paper's own misspelling of
  *opossum*). Kept verbatim; the species key maps it to *Didelphis virginiana*.
- **`marmot`** and **`hamster`** are printed without a binomial anywhere in the article. Following
  the sibling item `Heffner_Heffner_2018`, marmot resolves to *Marmota* sp.
  (`species_basis = unspecified_in_source`) and hamster to *Mesocricetus auratus*
  (`species_basis = hypothesis`) - flagged, not asserted.

## Species keys

All 22 printed labels are common names. Rather than invent mappings, the 22 rows added to
`_keys/General/species_key.csv` (`source_publication = Heffner_Heffner_2016`) **mirror the sibling
item `Heffner_Heffner_2018`** - same authors, same figure lineage - which already keys 21 of these
exact labels; `big brown bat` -> *Eptesicus fuscus* comes from the same source. Paper-scoped rows
were needed because several of these common names ("cat", "chinchilla", "mouse", "macaque") are
ambiguous across papers in the shared key.

## Table checks

The figure checks itself once: it prints `n = 22`, its caption says "22 species of mammals", and
the panel carries one label per plotted point. The build compares all three - **both checks pass
exactly** (22 labels = 22 = 22).

## Data role and merge

`secondary` ("Modified from Heffner et al. 2001"), and **not wired into any merge**: with no point
coordinates there is nothing to merge, and `__merging_sensory` already carries
`Field_of_best_vision.deg` and `Sound_localization_threshold.deg` from the tabulated Heffner
primaries. The recommendation recorded for the owner is to register
Heffner, Koay & Heffner (2001, JASA 109:412-421) and build its table.
