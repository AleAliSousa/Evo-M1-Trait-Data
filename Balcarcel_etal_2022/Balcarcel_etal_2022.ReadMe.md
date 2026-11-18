Source

<<<<<<< HEAD
Balcarcel, A. M., Geiger, M., Clauss, M., & Sanchez-Villagra, M. R.
(2022). The mammalian brain under domestication: Discovering patterns
after a century of old and new analyses. *Journal of Experimental
Zoology Part B*, 338(8), 460–483.
https://doi.org/10.1002/jez.b.23105

Files received on 2026-11-18:

- `Balcarcel-2022-The mammalian brain under domes.pdf`: article PDF.
- `jezb23105-sup-0001-sd1_data_for_cams_pigs_goats.xlsx`: publisher
  supplementary data workbook.
- `jezb23105-sup-0002-sd2_fm_covariance_with_size.docx`: publisher
  supplementary document.
- `jezb23105-sup-0003-sd3_calculations_for_cams_pigs_goats.docx`:
  publisher supplementary document.

This is a source-only folder. No dataset item has been selected or built.
The current `__ReadMe.xlsx` citation row has a blank Item number and a
generated Item name ending in `_`; it is a placeholder, not a registered
dataset item. The next curation step is to inspect the supplementary
workbook and select the source table(s) to freeze and build. Do not use
the placeholder as an item name or public TSV key.
=======
1. Go to Source: Article and supporting information (Wiley)
https://doi.org/10.1002/jez.b.23105

2. Frozen sources kept verbatim in this folder: the publisher PDF of
the article (Balcarcel-2022-The mammalian brain under domes.pdf) and
the three supporting-information files as downloaded:
jezb23105-sup-0001-sd1_data_for_cams_pigs_goats.xlsx (SD1, the data),
jezb23105-sup-0002-sd2_fm_covariance_with_size.docx (SD2, measurement
landmarks and FM covariance tests) and
jezb23105-sup-0003-sd3_calculations_for_cams_pigs_goats.docx (SD3,
the endocranial-volume model and the ANCOVA results).

--> USE THIS FILE: jezb23105-sup-0001-sd1_data_for_cams_pigs_goats.xlsx

Build: the SD1 file is digital-native, so there is no snapshot: it is
listed in the registry under its original name and
`Balcarcel_etal_2022_SD1.R` reads it directly, writing
`Balcarcel_etal_2022_SD1.csv` and the DOI-coded public TSV. See
`Balcarcel_etal_2022_SD1.README.md` for the data role (primary
measurements; the endocranial volumes are model estimates), caveats
and table checks. Registry row in `__ReadMe.xlsx` added 2026-11-18.

Quality Notes:

1. The published sheet stores its measurements as text and leaves the
   museum-name column unheaded; the build script types the values and
   names the column, and changes nothing else.

2. The endocranial-volume model printed in SD3 (Finarelli 2011)
   reproduces every printed log10(EV) value from the printed braincase
   dimensions to within 2.3e-4 (log10) — see the item README's table
   checks.

3. Folder sources added to the repo 2026-11-18; the dataset item was
   built 2026-11-18 by Muse (Buddy), Michael Proulx's AI assistant,
   at Michael Proulx's request, to the snapshot-first form in
   `_skills/build-dataset-item` (digital-native route: no snapshot,
   source file listed in the registry, script reads it directly).
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b
