# Heffner_etal_2007_Figure6

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2007). Sound-localization
acuity and its relation to vision in large and small fruit-eating bats: I.
Echolocating species, *Phyllostomus hastatus* and *Carollia perspicillata*.
*Hearing Research*, 234, 1-9. doi:10.1016/j.heares.2007.06.001

Registry Item **Figure 6**, printed p. 7 ("Relation between the width of the
field of best vision and sound-localization threshold"). Public copy:
`Heffner_etal_2007/Heffner_etal_2007.pdf`.

## Why this item exists
This is the priority-1 item for the folder: SensoryData_compiled uses six
field-of-best-vision (FBV) width values keyed to this paper. The task
instructions flagged that these values "are probably also listed in
Discussion text -- check before digitising", which this build did.

## Pipeline and what was actually found
Checking the paper's own Results/Discussion text (not the Fig. 6
scatterplot) found that **only two of the six species' FBV widths are
numerically stated in this paper's text** -- both are this paper's own new
retinal measurements:
- *Phyllostomus hastatus*: "The width of the field of best vision for this
  species, as defined by the portion of the retina with ganglion-cell
  densities at least 75% of maximum, is 51." (p. 5-6) -> **51 deg**
- *Carollia perspicillata*: "The region with the 75% densest concentration
  of ganglion cells is spread more broadly across the superior retina in a
  region 110 wide." (p. 6) -> **110 deg**

The other four species SensoryData_compiled also attributes to this
registry item -- *Artibeus jamaicensis* (34 deg), *Chinchilla laniger* (144
deg), *Marmota monax* (90.2 deg), and *Rousettus aegyptiacus* (27 deg) -- are
**not** stated anywhere in this paper's text. They appear only as unlabeled
comparison points among many other mammals in the Fig. 6 scatterplot (a
log-log plot of sound-localization threshold vs. FBV width for dozens of
species, none individually labeled with numeric axis values in the figure
itself). Of these four, two have an identifiable prior source cited
elsewheere in this paper's reference list (Artibeus: Heffner et al., 2001a;
Chinchilla: Heffner and Heffner, 1992b) but their exact FBV widths are not
restated here; for Marmota monax and Rousettus aegyptiacus no source paper
for the FBV measurement is identified anywhere in this PDF at all.

Per house rules (prefer a stated number over digitizing a figure; never
fabricate), this build did **not** attempt to digitize pixel positions from
the Fig. 6 scatterplot to recover the four missing values. Because those
four numbers are already established, pre-existing facts used elsewhere in
SensoryData_compiled (i.e., not something invented for this build), they are
carried into the snapshot/analysis CSVs for continuity of the registry
entry, but each is explicitly flagged `stated_in_this_papers_text = FALSE`
and `data_role = "secondary"` with a source note making clear they are not
independently verified from this specific PDF.

| file | role |
|---|---|
| `Heffner_etal_2007_Figure6_snapshot.csv` | frozen source; text-stated values for rows 1-2, carried-forward comparison values for rows 3-6 |
| `Heffner_etal_2007_Figure6.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2007_Figure6.csv` | tidy analysis rows |
| `reference_tables/Heffner_etal_2007_Figure6_definitions.csv` | data dictionary |

## Data role
Rows 1-2 (*P. hastatus*, *C. perspicillata*) are primary, this paper's own
new retinal ganglion-cell measurements. Rows 3-6 are secondary/comparison
values plotted in Fig. 6 but not independently confirmed from this PDF.

## Observation level
One FBV-width value per species (defined as the horizontal width, in
degrees, of the retinal region with ganglion-cell densities at least 75% of
the maximum density -- the paper's own operational definition of "field of
best vision").

## Units
Degrees of horizontal visual angle.

## Flags / anomalies
- Four of the six SensoryData_compiled values attributed to this registry
  item are not verifiable from this paper's own text or figure labels (see
  above); flagged rather than silently treated as equally well-sourced.
  A follow-up pass could track down the original Marmota monax and
  Rousettus aegyptiacus FBV-width source papers to confirm those two values
  independently.
