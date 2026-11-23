# Stacho_etal_2024_Table2

Table 2 | Overview of postmortem non-human primate brains. Source: `fulltext.html` (PubMed Central, PMC10976583), DOI in `__ReadMe.xlsx`.

## Build

Table 2 lists the 25 non-human primate brains of the study — the paper's text: 25 non-human brains from the C. & O. Vogt Institute collection — with taxon (family/group), species, archive name, sex, section plane and staining. The table's footnote reads: "The family and species name, brain code, as well as sectioning and staining type. Sections are stained using silver staining for cell bodies according to Merker (1983) or Nissl staining with cresyl-violet." The build renames the printed "Name" column to Specimen and keeps every value verbatim.

From the paper folder, run:

```sh
Rscript Stacho_etal_2024_Table2_snapshot.R
Rscript Stacho_etal_2024_Table2.R
```

The snapshot script captures the table from the frozen PubMed Central full text in this folder (`fulltext.html`; snapshot HOWTO method 2) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Stacho_etal_2024_Table2.R`. The snapshot was cross-checked cell-by-cell against the Frontiers JATS XML (`fulltext_frontiers.xml`, same folder): the two renderings agree on every cell. The R script reads only its item snapshot and writes `Stacho_etal_2024_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Why a measurement-free table is an item.** This is the only published list that places the archive label "3_97" (*Hylobates lar*) inside the Vogt collection's /97 cohort, alongside 1_97 (bonobo), 2_97 and 5_97 (orangutans) and 4_97 (chimpanzee) — the named Zahlia, Harry, Briggs and Bathsheba of de Sousa et al. (2010). That cohort pattern is the evidence identifying "3_97" as the gibbon **Disco** (`ZILLES-HYLOBATES-GPZ-5542`) in the specimen crosswalk, where this paper is registered as PUB_STACHO_2024 with match *probable* (the name Disco is not printed here). The second *Hylobates lar*, "YN81-146", is YN81 of Semendeferi et al. (2011, Table 1).
- **Verbatim quirks kept:** numeric archive names keep their printed thousands separators ("1,548", "2,408", "1,091", "1,514", "1,333"); "YN 85–38" keeps its printed space and en dash; the sex code "NA" (six specimens) is the paper's "not available", not a missing cell, and is carried as the string `NA`; one species is printed "Cercopithecus Spec." (indeterminate), as in the paper.
- **Checks.** The build asserts 25 rows, the printed per-taxon counts (Hominidae 11, Cercopithecidae 4, Platyrrhini 3, Prosimiae 7) and the two *Hylobates lar* rows in order.
- The snapshot was captured programmatically and checked by the assistant against the Frontiers XML rendering; human visual signoff remains pending in the registry. No merge is performed by this build.
