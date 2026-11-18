Source

1. Go to Source: Article and Dryad data package (open data)
https://doi.org/10.1111/evo.12943
https://doi.org/10.5061/dryad.m2tj3

<<<<<<< HEAD
2. Frozen sources (digital-native): the Dryad downloads in
this folder, kept verbatim — Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv
(596 species) and README_for_Gonzalez-Voyer_et_al_Evolution_Brain_Data.pdf
(the package's own variable documentation). Downloaded 2026-11-18.
The item-specific `_BrainData_snapshot.csv` is a byte-identical copy of
the Dryad CSV used by the R reader.
=======
2. Frozen source (digital-native, no snapshot): the Dryad data file,
downloaded 2026-11-18 and kept verbatim in this folder under its
original name (Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv); it is
listed in the registry under that name and the build script reads it
directly. The package's own README PDF
(README_for_Gonzalez-Voyer_et_al_Evolution_Brain_Data.pdf, the
package's variable documentation and reference list) is kept verbatim
alongside it.
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b

--> USE THIS FILE: Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv

Build: `GonzalezVoyer_etal_2016_BrainData.R` reads only that file,
adds species_sci, and writes `GonzalezVoyer_etal_2016_BrainData.csv`
and the DOI-coded public TSV. See
`GonzalezVoyer_etal_2016_BrainData.README.md` for the data role
(secondary compilation), the relation to González-Lagos et al. 2010,
<<<<<<< HEAD
caveats and checks. The registry row was added on 2026-11-18.
=======
and caveats. Registry row in `__ReadMe.xlsx` added 2026-11-18.
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b

Quality Notes:

1. This database is the expanded open descendant of the González-Lagos
   et al. (2010) 493-species brain/body database — the one behind the
   Ei values in Castillo-Morales et al. (2016). The 2010 file itself
   was never deposited anywhere (see the GonzalezLagos_etal_2010
   folder); this 2016 release is the closest citable form of it.

2. Folder added 2026-11-18 by Muse (Buddy), Michael Proulx's AI
<<<<<<< HEAD
   assistant, at Michael Proulx's request. The registry row was added later on 2026-11-18; descriptive metadata remain incomplete.
=======
   assistant, at Michael Proulx's request; rebuilt to the snapshot-first
   form in `_skills/build-dataset-item` the same day.
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b
