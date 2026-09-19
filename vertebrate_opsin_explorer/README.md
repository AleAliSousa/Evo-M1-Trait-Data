# VPOD Mammalian Opsin Explorer

An interactive R Shiny application for exploring recorded opsin diversity and spectral sensitivity across mammals using data from the Visual Physiology Opsin Database (VPOD).

## Overview

This project combines comparative visual physiology data with a mammalian phylogeny to provide an interactive way to explore how recorded opsin diversity and wavelength sensitivity vary among mammalian species.

The application allows users to:

- Explore a mammalian phylogenetic tree.
- Select a primary species and a comparison species.
- Visualise VPOD-labelled opsin-family diversity across the phylogeny.
- Compare recorded spectral ranges between species.
- Inspect individual recorded λmax values.
- View a species' recorded opsin profile.
- Explore relationships between opsin-family diversity and recorded spectral range.
- Review the underlying records used for each selected species.

## Data source

The primary dataset is the **Visual Physiology Opsin Database (VPOD)**, using the vertebrate metadata file:

`VPOD/vert_meta.tsv`

VPOD is a curated database of visual physiology data containing opsin genotypes and corresponding spectral sensitivity measurements from published research.

This project uses the VPOD records as the basis for exploring **recorded opsin diversity** and **recorded spectral sensitivity**.

> **Important terminology:** opsin-family diversity in this project refers to the number of distinct opsin-family labels recorded in VPOD. It should not be interpreted automatically as the number of functionally expressed photoreceptor types or as functional chromatic vision.

## Project structure

```text
vpod_mammalian_opsin_explorer/
│
├── app.R
├── setup_data.R
├── README.md
├── opsin_explorer_data.RData
│
├── VPOD/
│   └── vert_meta.tsv
│
├── Murphy_&_Westerman_2022/
│   └── Optional separate analysis dataset
│
└── docs/
    └── [workflow documentation, if included]
```

The main scripts are:

### `setup_data.R`

Prepares the VPOD data for use in the application. It:

1. Reads the VPOD vertebrate metadata.
2. Removes records that are not suitable for the species-level phylogenetic analysis, including ancestral/pigment entries and selected problematic species labels.
3. Standardises several species names and taxonomy labels.
4. Creates species-level measures of:
   - VPOD-labelled opsin-family diversity
   - minimum recorded λmax
   - maximum recorded λmax
   - recorded spectral range
   - number of VPOD opsin records
5. Selects mammalian species.
6. Retrieves a mammalian phylogeny using `rtrees`.
7. Matches the VPOD species to the phylogeny.
8. Calculates exploratory correlation and regression analyses.
9. Saves all processed objects and pre-computed statistics to `opsin_explorer_data.RData`.

### `app.R`

Runs the interactive Shiny application using the processed data created by `setup_data.R`.

## Main measures

### Opsin-family diversity

The project calculates:

**VPOD-labelled opsin-family diversity = number of distinct `Opsin_Family` labels recorded for a species.**

This is a database-derived measure rather than a direct measure of functional photoreceptor diversity.

### Recorded spectral range

For each species:

**Recorded spectral range = maximum recorded λmax − minimum recorded λmax**

where λmax represents the recorded peak wavelength of an opsin.

A larger value therefore indicates a wider range of recorded peak sensitivities in the VPOD records available for that species.

### Number of VPOD records

The project also counts the number of VPOD records available for each species. This provides important context because species with more records may have more opportunities for different opsin families or spectral sensitivities to be represented.

## Exploratory analysis

Exploratory statistical summaries are calculated during the preprocessing workflow (`setup_data.R`) and stored in `opsin_explorer_data.RData`.

These include:

```text
spectral_range ~ family_label_diversity + n_opsin_records
```

This is an **observational exploratory analysis**. The model describes associations within the VPOD dataset and should not be interpreted as demonstrating causation.

The measures are also derived from the same underlying database records, meaning that record availability and sampling coverage should be considered when interpreting the relationship.

In addition, species are evolutionarily related, so phylogenetic non-independence is an important limitation of simple species-level regression.

## Phylogenetic analysis

The mammalian phylogeny is generated using the `rtrees` package and matched to the VPOD species included in the analysis.

Species that could not be matched exactly to the selected tree are not included in the final mammalian phylogeny used by the application.

The phylogeny is therefore intended as an exploratory visualisation of evolutionary relationships rather than a formal phylogenetic comparative analysis.

## Requirements

The project requires R and the following packages:

```r
library(tidyverse)
library(ape)
library(ggtree)
library(ggrepel)
library(rtrees)
library(piggyback)
```

The Shiny application also requires:

```r
library(shiny)
```

## Running the project

Clone or download the repository and open the project directory in R/RStudio.

First, run:

```r
source("setup_data.R")
```

This creates the processed data file:

```text
opsin_explorer_data.RData
```

Then run the Shiny application:

```r
shiny::runApp()
```

Alternatively, open `app.R` in RStudio and select **Run App**.

The project currently assumes that the working directory is the project root, so the relative path to the VPOD data is:

```text
VPOD/vert_meta.tsv

No absolute file paths are used in this project. All scripts use relative paths and are intended to be run from the project root directory.

## Reproducibility

The intended workflow is:

```text
VPOD raw metadata
        ↓
setup_data.R
        ↓
Species-level summary metrics
        ↓
Mammalian phylogeny
        ↓
opsin_explorer_data.RData
        ↓
app.R
        ↓
Interactive Shiny explorer
```

The raw VPOD data should be retained separately from processed objects so that the data-preparation workflow can be rerun when the source data or cleaning decisions change.

## Limitations

Several limitations should be considered when interpreting the application:

- VPOD records represent published observations and therefore do not provide equal sampling across species.
- The number of recorded opsin families is not necessarily equivalent to functional chromatic vision.
- Multiple records for the same species may reflect different studies, sequences, mutations or experimental measurements.
- Recorded spectral sensitivity does not by itself establish which opsins are expressed together in the retina.
- The regression analysis is observational and does not establish causality.
- Record number may influence both the number of recorded opsin families and the observed spectral range.
- Species are not statistically independent because of their shared evolutionary history.
- The mammalian phylogeny is used primarily for visual exploration and species matching rather than formal phylogenetic hypothesis testing.
- Species-name standardisation and exclusion decisions are documented in `setup_data.R`.

## Related data

A separate dataset from Murphy & Westerman (2022), *Evolutionary history limits species' ability to match colour sensitivity to available habitat light*, is retained in the project directory for a separate evolutionary-ecology analysis.

It is not merged with the VPOD dataset in this application.

## Status

This project is an exploratory comparative neuroscience / visual physiology project developed as part of a research apprenticeship.

The current application focuses on mammals and is intended as a reproducible starting point for exploring the relationship between recorded opsin diversity, spectral sensitivity and evolutionary history.

## Author

Developed as part of the University of Bath Research Apprenticeship in comparative/evolutionary neuroscience.
