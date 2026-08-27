# Sensory Audiovisual Data Extraction Plan

## Aim

Convert the contents of `____Sensory_audiovisual` into standardized, traceable paper-level datasets and a curated sensory master dataset.

## 1. Inventory the source material

Create an inventory of:

- PDFs containing comparative visual or auditory data
- Existing Excel or Google Sheets compilations, such as `Visual Acuity database in progress.xlsx`
- Values digitized from figures
- Records taken from the Heffners’ online species pages

For each source, record its sensory domain, paper or webpage citation, extraction status, and any related manual spreadsheet.

## 2. Build each paper separately

Move each paper into the repository’s regular paper-build structure, for example:

```text
Author_etal_Year/
├── paper.pdf
├── raw_data/
├── extracted/
├── scripts/
├── checks/
└── README.md
```

Extract data in this order of preference:

1. Published tables or supplementary tables
2. Values stated in the text
3. Values digitized from figures

Retain the original trait name, value, unit, species name, table/figure/page location, sample size, and extraction method.

## 3. Compare independent extractions

Compare newly extracted PDF data with the existing student spreadsheets. Flag:

- Conflicting values
- Missing species or traits
- Unit differences
- Taxonomic-name differences
- Different interpretations of the same measurement

Treat student spreadsheets as independent extraction attempts, not as final authority. Keep unresolved differences visible for manual review.

## 4. Incorporate figure and online data

For figure-derived values, retain the figure number, digitization method, and original image or plot reference.

For the Heffners’ database, record the species-page URL, displayed value, access date, and underlying publication where available. Check whether the webpage and paper represent the same specimens or measurement before merging them.

## 5. Standardize and merge

Create a sensory trait dictionary linking original trait names and units to standardized fields. Keep visual and auditory measurements distinct unless they are demonstrably equivalent.

Compile validated paper-level datasets using the repository’s existing merging rules:

- Preserve raw and extracted source files
- Retain value-level provenance
- Identify reused specimens and duplicated measurements
- Remove duplicates before averaging independent estimates
- Preserve sample size and specimen metadata when reported
- Flag uncertain or unresolved records rather than silently choosing one value

## 6. Outputs

The completed workflow should produce:

- Standardized paper-level datasets
- A source and extraction inventory
- A sensory trait dictionary
- PDF-versus-spreadsheet comparison reports
- A discrepancy log for manual review
- A compiled audiovisual sensory dataset with provenance and QC status

No value should enter the final compiled dataset without a traceable source and a documented QC decision.
