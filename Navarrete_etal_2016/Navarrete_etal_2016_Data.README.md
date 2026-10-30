# Navarrete et al. 2016 — Dryad data

## Source

Navarrete, A. F., Reader, S. M., Street, S. E., Whalen, A., and Laland,
K. N. (2016). *The coevolution of innovation and technical intelligence in
primates.* **Philosophical Transactions of the Royal Society B 371**:
20150186. Article DOI **10.1098/rstb.2015.0186**; Dryad dataset DOI
**10.5061/dryad.dk10k**. Registry item `Navarrete_etal_2016_Data`.

The frozen source is
`ESMNavarreteReaderStreetWhalenLaland_dataset.csv` (167 species; MD5
`74eefe75e9e0bb2abcb84010e6317b87`), obtained from Dryad's full-dataset ZIP.
The ZIP is retained beside it as received. Dryad licenses this deposit CC0.

## Pipeline and representation

`Navarrete_etal_2016_Data.R` verifies the source checksum, gives the fields
stable machine-readable names, and writes the local CSV plus
`10.1098%2Frstb.2015.0186_Data.tsv`. All three source taxonomies are retained;
`Species_Navarrete2016` is the Arnold et al. (2010) name used as the primary
row label, while the Isler and Reader names remain explicit alternatives.

The source calls several fields “innovation rate (nr)”, but their values are
non-negative integer report counts. The article controls for research effort
in statistical models; the deposited file contains no effort denominator and
no pre-corrected rate. This build therefore labels these fields `_count` and
does not invent an effort-normalized value. The subtype counts complement the
earlier Reader data but should not be added to its total innovation count as
though they were independent observations.

## Verification and cautions

- 167 source rows are retained, with no taxonomic harmonization or aggregation;
- `innovator` is `Yes` exactly when the original technical plus non-technical
  count is greater than zero;
- both printed partitions of the foraging count reproduce exactly;
- the broader technical/non-technical fields are preserved independently and
  are not forced to sum to the original classification;
- `life_history_composite` is a source-derived phylogenetic composite and is
  missing for 96 species;
- downstream merges should resolve the three historical taxonomies explicitly
  and avoid double-counting the underlying Reader innovation reports.
