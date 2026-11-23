# Semendeferi_etal_2011_Table1

Table 1 | Specimens. Source: `Semendeferi-2011-Spatial organization of.pdf`, PDF page 3 (journal page 1486), DOI in `__ReadMe.xlsx`.

## Build

Table 1 lists the 19 hominoid brains (8 humans, 11 apes) whose layer III neuronal spacing is summarised in Tables 2 and 3 of the same paper: group, specimen, sex, age (years) and brain weight (g). The ape specimens were donated after natural death by Busch Gardens Zoo, Henry Doorly Zoo, Milwaukee County Zoo and the Yerkes National Primate Research Center (a collective donor list, not assigned per specimen), and all specimens were processed at the Cécile & Oskar Vogt Institute, Düsseldorf.

From the paper folder, run:

```sh
Rscript Semendeferi_etal_2011_Table1_snapshot.R
Rscript Semendeferi_etal_2011_Table1.R
```

The snapshot script captures the table programmatically from the frozen publisher PDF in this folder (snapshot HOWTO method 3: poppler `pdftotext -bbox` word geometry clustered into the printed rows and columns; no value typed by hand) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Semendeferi_etal_2011_Table1.R`. The article is not in PubMed Central or Europe PMC, so the PDF is the capture source (the Azevedo_etal_2009 pattern). The R script reads only its item snapshot and writes `Semendeferi_etal_2011_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Species are printed as group names only** (Human, Bonobo, Chimpanzee, Gorilla, Orangutan, Gibbon), printed once per group and filled down in the build. The analysis CSV resolves them to binomials and keeps the printed form in `Group (printed)`. The resolution that needs evidence is the gibbon: both gibbon specimens are *Hylobates lar* in the collection records — Disco is `ZILLES-HYLOBATES-GPZ-5542` (de Sousa et al., 2010, Table 1; MacLeod, 2000, Appendix I) and YN81 is the *Hylobates lar* "YN81-146" of Stacho et al. (2024, Table 2). Orangutan = *Pongo pygmaeus* (YN85, Briggs, Harry in the same records) and Gorilla = *Gorilla gorilla* (YN82).
- **Disco's row** (Gibbon, F, 22 yrs, 120 g) is the only published source that gives this crosswalk specimen's age and brain weight together; it is one of the two sources registered as PUB_SEMENDEFERI_2011 in the specimen source registry.
- **Printed forms kept verbatim in the snapshot:** the young bonobo is "Zahlie" (the Zahlia of the /97 cohort elsewhere), and YN81's age is "Ad" (adult) — the analysis CSV leaves her `Age, years` empty and records the printed form in its Note column.
- **Capture checks.** The build asserts the paper's own text values: human ages span 21–75 years and the two bonobos are 2 and 11, as the Subjects text states. The same text gives the ape age range as "16.5–37 years", which matches no reading of this table (the printed ape ages run 2–37); the slip is in the text, not the table, and is recorded here only.
- The snapshot was captured programmatically and checked by the assistant against the rendered PDF page and the paper's text; human visual signoff remains pending in the registry. No merge is performed by this build.
