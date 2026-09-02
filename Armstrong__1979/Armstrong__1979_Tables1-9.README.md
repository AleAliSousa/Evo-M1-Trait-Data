# Armstrong 1979 - Tables 1-9

## Source

Armstrong, E. (1979). A quantitative comparison of the hominoid thalamus. I.
Specific sensory relay nuclei. *American Journal of Physical Anthropology, 51*(3),
365-382. https://doi.org/10.1002/ajpa.1330510308

Registry item: **Tables 1-9**. Public file:
`10.1002%2Fajpa.1330510308_Tables1-9.tsv`.

## Products

The frozen 106-row snapshot transcribes every row in Tables 1-9. The builder keeps
the mixed datatypes separate:

- `Armstrong__1979_Tables1-9_volumes.csv` - Tables 1 and 5
- `Armstrong__1979_Tables1-9_neuronal_density_counts.csv` - Tables 2-4 and 6
- `Armstrong__1979_Tables1-9_neuronal_perikaryal_volume.csv` - Tables 7-9
- `Armstrong__1979_Tables1-9.csv` - combined long-form source table used for the
  DOI-coded public TSV

Table 1's Armstrong measurements are marked `primary`. Its Hopf, Solnitzky,
Chacko, and Blinkov-Zvorykin comparison rows are marked `secondary` and keep their
source-specific structure definitions. In particular, Blinkov and Zvorykin report
MGB pars parvocellularis plus pars magnocellularis, not Armstrong's MGBp.

## Specimen identity

`Armstrong__1979_specimen_crosswalk.csv` resolves the paper's abbreviated codes.
The most important point is that `Hylo.-h` and `Hylo.-s` are the horizontally and
sagittally sectioned hemispheres of **one** gibbon brain of unknown species. They
must not be counted as two animals. `H. lar-t` is a different, presumably wild male
*Hylobates lar*.

The human estimate in Table 6 is not one specimen. It combines mean nuclear
volumes from `Homo s.-s` and `Homo s.-t` with neuronal density from the third
brain, `Homo s.-c`. This derived identity is explicit in the crosswalk and output.

## Measurement cautions

- Nuclear volumes are from one hemisphere only. Do not double them without an
  explicit laterality rule.
- LGB means dorsal LGB and includes the fibrous laminae. VB excludes the lightly
  stained small-celled VPI region.
- Brains came from different laboratories and preparations. Armstrong used ratios
  to the larger thalamus to reduce shrinkage effects; raw volumes remain
  preparation-sensitive.
- Density estimates count neurons with visible nucleoli and were not corrected for
  neuronal nuclear size. Estimated total counts are volume x density.
- Perikaryal-volume summaries are described by the author as tentative because
  sampling was limited and histological processing differed among specimens.

## QA

The builder checks all table row counts, requires all primary specimen codes to
resolve in the crosswalk, checks every Table 5 LGBp + LGBm sum against Table 1,
recomputes Table 6 MGBp/VB counts to within 0.5%, and checks completeness and
ordering of all density and perikaryal summaries. Six Table 5 component sums match
Table 1 exactly; the printed `Homo s.-s` components sum to 69.2 mm3 while Table 1
prints 69.1 mm3. Nine of ten directly comparable MGBp/VB neuron counts reproduce
to within 0.5%; the printed `Hylo.-h` MGBp volume and density imply 397,570 neurons
while Table 6 prints 413,000. Both source discrepancies are retained and explicitly
tested. The single printed missing value is the `H. lar-t` LGB neuron count in
Table 6.
