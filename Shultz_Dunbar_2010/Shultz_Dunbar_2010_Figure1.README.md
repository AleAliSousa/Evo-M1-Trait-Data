# Shultz & Dunbar (2010), Figure 1

Reconstruction of the **63 separately visible markers** in Figure 1, p. 258,
doi:10.1037/a0018894. The original figure is an embedded 2700 x 2247 grayscale
JPEG. Marker centres were visually read on its half-size display and stored
in native image pixels (origin upper left). Axis tick centres were measured
from the native raster. The y calibration is anchored at the zero tick;
the zero-aligned detour marker was confirmed from its native pixel bounding box.
The snapshot is constructed from the figure, not
an author-supplied numerical dataset.

## Rebuild

Run `Rscript Shultz_Dunbar_2010_Figure1.R` from any working directory.
Inputs are the adjacent `_snapshot.csv`, `_calibration.csv`, and
`_identity_audit.csv`. The script writes the analysis CSV, a reconstruction
PNG, and `__Public/comparative-data/10.1037%2Fa0018894_Figure1.tsv` when that
repository directory exists. The PNG fits the visible points; its dashed
line is explicitly distinct from the original published regression.

## Values and uncertainty

The x scale is base-10 logarithm: numerous plotted positions agree with
log10 of the Stephan (1981) hippocampus volumes in mm3. Both ln and log10
comparisons are retained in the restricted audit. The reverse-transformed
column is `10^digitized_x`; it is never replaced by a Stephan value.
The nominal centre-reading uncertainty is +/-4 native pixels (about
0.0035 log10 units and 0.0033 ability units), not a statistical confidence
interval. Original raster resolution, overlapping symbols and source
rounding limit recovery. Printed precision in CSV calculations does not
imply that precision in the observations.

The y values remain on the authors' plotted Ability scale. The methods
say proportions were arcsin-transformed but do not specify the full
formula; no percent-correct inversion is asserted.

## Identity is inferred at genus level

The methods (p. 254) say duplicated performances were averaged to one
measure per genus per task; Table 1 lists genera, despite the Figure 1
caption saying individual species. `genus_candidates` records inferred
labels and `species_candidates_in_supplement` records the contributing
species that are possible for that task. The `species` column is empty
by design: a genus-level score must not be copied onto each species.
The full published names, including spelling errors, remain in Table S1.

Each identity has an explicit status. Close source-volume matches support
Callithrix, Saguinus, Saimiri, Nycticebus, Miopithecus (historical
Cercopithecus talapoin), Macaca, Ateles, Varecia (Lemur variegatus),
Cercocebus, Lagothrix and Gorilla. This supports a genus association,
not necessarily the same behavioural species as the anatomical specimen.

Several assignments remain hypotheses:

- Cebus: plotted volume approximately 843 mm3 versus Stephan Cebus sp. 890.
- Eulemur: approximately 1111 versus Lemur fulvus 752.
- Pan: approximately 3585 versus Pan troglodytes 3779.
- Lemur: approximately 1181; Lemur catta is absent from Stephan Tables V-VI.
  Main-paper Table 1 includes Lemur in Delay, but the supplement does not.
- Cercopithecus: approximately 1093. The mean of three historical
  Cercopithecus rows is 1086.7, but one is talapoin, separately represented
  as Miopithecus. This averaging scenario is not adopted as established fact.
- At x approximately 3.171, two Delay and two String markers cannot be
  separated between Cercocebus and Mandrillus. Learning sets and Reverse
  reward at this x are compatible with Cercocebus. Stephan's anatomical
  Cercocebus albigena is not a behavioural species listed in the supplement.
- A column compatible with Lagothrix is visible although the methods say
  Lagothrix was dropped from analyses.

## Completeness limitation

OLS on 63 visible marker centres gives R-squared 0.30481; Figure 1 prints
0.323. This difference exceeds digitization rounding. The main-table
roster implies 65 genus-task combinations: the Cebus Reversal and Pan
Displacement symbols cannot be independently identified in the image.
Overplotting is possible, but their values have not been invented. The
file therefore reconstructs the visible figure and preserves unresolved
identification and completeness issues. It is not a verified recovery of
the authors' complete analytical dataset.

## Audit provenance

Restricted checks contain the original raster, point-centre snapshot,
axis calibration, explicit identity hypotheses, an R audit, all 48
Stephan primate candidates for every point, and task coverage reports.
The anatomical sources are public `Stephan_etal_1981_TableV.csv` and
`Stephan_etal_1981_TableVI.csv`. The revised supplemental transcription
reads the original Word table structurally: **121 study rows, nine blank
individual counts**. The paper's prose says 122 task-by-species
combinations; that discrepancy is retained, not repaired by adding a row.
