# Gillette_etal_1973_ResultsText

## Source
Gillette, R. G., Brown, R., Herman, P., Vernon, S., & Vernon, J. (1973). The
auditory sensitivity of the lemur. *American Journal of Physical
Anthropology*, 38(2), 365-370. https://doi.org/10.1002/ajpa.1330380234

Registry Item **Results text** (no printed table gives a full audiogram;
see N.B. below). Public copy: `Gillette_etal_1973/Gillette-2005-The auditory
sensitivity of the.pdf`.

## *** N.B.: folder-name vs. PDF-filename year discrepancy (flagged, not silently resolved) ***
The source PDF supplied in this folder is named
`Gillette-2005-The auditory sensitivity of the.pdf` -- its filename implies
publication year 2005. **This is wrong.** The PDF's own title page, running
head ("AM. J. PHYS. ANTHROP., 38: 365-370"), and every in-text citation
confirm the paper is actually:

> Gillette, R. G., Brown, R., Herman, P., Vernon, S., & Vernon, J. (1973).
> The auditory sensitivity of the Lemur. *American Journal of Physical
> Anthropology*, 38(2), 365-370. doi:10.1002/ajpa.1330380234 (PMID 4689764).

This was independently confirmed via Sci-Hub, Europe PMC, and Wikidata, all
of which list the publication date as March 1973. The **folder name
`Gillette_etal_1973` is correct** and matches the true publication year; the
**PDF's own filename year (2005) is the erroneous label** and has not been
used anywhere in this registry entry (citation, year column, item name, or
item-encoded string all use 1973). Flagging here per house rule rather than
silently trusting either label.

## Why this item exists
This is the first quantitative behavioral audiogram for a strepsirrhine
primate, *Lemur catta* (ring-tailed lemur), tested with a single-lever shock
avoidance technique from 100 Hz to 75 kHz (combining a new high-frequency
study, 8-75 kHz, with a previously published low/mid-frequency study, 100
Hz-40 kHz, by the same lab). The paper's headline reported result, stated in
the Abstract, is a 60-dB hearing range of 1-32 kHz -- there is no printed
table giving the full audiogram; Table 1 in the source is only animal
demographics (age/sex/weight), and Table 2 is a test-retest comparison of
two testing methods at a few overlapping mid-range frequencies (not the
primary audiogram, and not built as a separate item here). The full
audiogram curve itself is presented only as a figure (Fig. 1), which is not
digitized here per house rule preferring stated text/table values over a
figure.

## Pipeline
Verbatim Abstract/Discussion text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Gillette_etal_1973_ResultsText_snapshot.csv` | frozen verbatim quotes |
| `Gillette_etal_1973_ResultsText.R` | re-keys the stated values, writes CSV + public TSV |
| `Gillette_etal_1973_ResultsText.csv` | tidy analysis row |
| `reference_tables/Gillette_etal_1973_ResultsText_definitions.csv` | data dictionary |

## Data role
Primary -- this is the paper's own combined new/previously-published (same
lab, same animals) measurement of *L. catta* hearing sensitivity.

## Observation level
Species-level mean sensitivity function (4 individual lemurs contributed
data across the two combined studies; see Table 1 of the source for
per-animal ages/weights, not reproduced here since it is not audiogram
data).

## Units
`sensitivity_criterion_db_below_1dyne_cm2` = 60, the dB criterion (below the
1 dyne/cm2 reference) used to define the reported hearing range -- this is
the older acoustics-reference convention also seen in Dalland (1965) in this
cluster, not modern dB SPL. `range_low_khz`/`range_high_khz` = the frequency
range (kHz) over which the animal's threshold was at least 60 dB below 1
dyne/cm2, as stated in the Abstract. `tested_range_low_khz`/
`tested_range_high_khz` = the full frequency range over which thresholds
were measured at all (100 Hz-75 kHz), for context.

## N.B. / anomalies
- Folder-name/PDF-filename year mismatch: see boxed note above. Resolved in
  favor of the PDF's own actual content (1973), not its filename (2005).
- No printed table states an exact single best-sensitivity dB value or best
  frequency (only the 60-dB range is stated numerically in text); the full
  curve is only in Fig. 1 and is not digitized here.
