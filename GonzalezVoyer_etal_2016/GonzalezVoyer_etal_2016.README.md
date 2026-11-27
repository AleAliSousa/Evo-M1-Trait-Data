Source

1. Go to Source: Article and Dryad data package (open data)
https://doi.org/10.1111/evo.12943
https://doi.org/10.5061/dryad.m2tj3

2. Frozen source (digital-native, no snapshot): the Dryad data file,
downloaded 2026-11-18 and kept verbatim in this folder under its
original name (Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv); it is
listed in the registry under that name and the build script reads it
directly. The package's own README PDF
(README_for_Gonzalez-Voyer_et_al_Evolution_Brain_Data.pdf, the
package's variable documentation and reference list) is kept verbatim
alongside it.

--> USE THIS FILE: Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv

Build: `GonzalezVoyer_etal_2016_BrainData.R` reads only that file,
adds species_sci, and writes `GonzalezVoyer_etal_2016_BrainData.csv`
and the DOI-coded public TSV. See
`GonzalezVoyer_etal_2016_BrainData.README.md` for the data role
(secondary compilation), the relation to González-Lagos et al. 2010,
and caveats. Registry row in `__ReadMe.xlsx` added 2026-11-18.

Quality Notes:

1. This is a separately authored 596-species compilation, **not a verified
   descendant** of González-Lagos et al. (2010)'s unavailable 493-species
   brain/body table. The similar surnames do not identify the same authors.
   The 2016 article cites the 2010 work as background, while its methods
   describe compilation from PanTHERIA and further literature. See the
   BrainData item README for the source-lineage caveat.

2. Folder added 2026-11-18 by Muse (Buddy), Michael Proulx's AI
   assistant, at Michael Proulx's request; rebuilt to the snapshot-first
   form in `_skills/build-dataset-item` the same day.
