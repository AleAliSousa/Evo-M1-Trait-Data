### The purpose of this script is to checck against to other datasets of brain region volumes, and to extract the data from the DeCasien & Higham 2019 supplementary data (MOESM3) for use in the online database.


## 1. READ FILE
# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/DeCasien_Higham_2019")

#1.1 Set up: packages and simple reference mapping
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

#2.1.1 make a small mapping table for the DeCasien reference numbers that correspond to Stephan’s studies:

ref_map <- tibble::tribble(
  ~ref_id, ~ref_citation,
  24, "Stephan et al. 1981, Folia Primatol. 35:1–29",
  51, "Stephan et al. 1970, in The Primate Brain",
  52, "Stephan et al. 1988, in Comparative Primate Biology"
)


#2 Tidy the MOESM3 brain sheet and filter by Stephan references
#2.2 Read the brain-region sheet
moesm3_raw <- read_excel(
  "41559_2019_969_MOESM3_ESM.xlsx",
  sheet = "Brain Region Data (mm3)"
)

#inspect column names:
names(moesm3_raw)

#2.2. Reshape to long format and parse the reference numbers
moesm3_long <- moesm3_raw %>%
  # 1) Standardize species column name
  rename(species = Taxon) %>%   # change "Taxon" if needed
  
  # 2) Keep species, References, and the brain regions you care about
  select(
    species,
    References,
    BV,
    Medulla,
    Cerebellum,
    Mesencephalon,
    Diencephalon,
    Telencephalon,
    MOB,
    AOB,
    `Piriform Lobe`,
    Septum,
    Striatum,
    `Striatum (incl. NAcc)`,
    Schizocortex,
    Hippocampus,
    `Neocortex (GM+WM)`,
    `Neocortex (GM)`,
    Epithalamus,
    Thalamus,
    Hypothalamus,
    Subthalamus,
    Pallidum,
    `Subthalamic Nucleus`,
    `Optic Tract`,
    `V1 (GM)`,
    LGN,
    Paleocortex,
    Amygdala,
    Vmo,
    VII,
    XII,
    `Granular Insula`,
    `Dysgranular Insula`,
    `Agranular Insula`,
    `Insula (GM)`    
  ) %>%
  
  # 3) Pivot brain regions into long format
  pivot_longer(
    cols = -c(species, References),
    names_to  = "structure",
    values_to = "volume_mm3"
  ) %>%
  
  # 4) Expand entries where References has multiple numbers
  mutate(References = as.character(References)) %>%
  tidyr::separate_rows(References, sep = "[,; ]+") %>%
  filter(References != "") %>%
  mutate(ref_id = as.integer(References)) %>%
  select(-References) %>%
  
  mutate(dataset = "MOESM3_DeCasien")

# filter to rows that come specifically from Stephan et al. 1981 (ref 24):
moesm3_stephan1981 <- moesm3_long %>%
  filter(ref_id == 24) %>%      # 24 = Stephan et al. 1981
  left_join(ref_map, by = "ref_id")

#filter to rows that come specifically from the three Stephan sources (1970, 1981, 1988):
moesm3_stephan_all <- moesm3_long %>%
  filter(ref_id %in% c(24, 51, 52)) %>%      # 24 = Stephan et al. 1981, 51 = Stephan et al. 1970, 52 = Stephan et al. 1988
  left_join(ref_map, by = "ref_id")

# 3. Tidy the Stephan metadata workbook
# 3.1. Read the main data sheet
stephan_raw <- read_excel(
  "Stephan_primates_Stephan_primates_metadata.xlsx",
  sheet = "Stephan_primates_Stephan_primat"
)

names(stephan_raw)

#3.2. Read the variable–source metadata (to find which columns are from Stephan 1981)
excel_sheets("Stephan_primates_Stephan_primates_metadata.xlsx")

stephan_meta <- read_excel(
  "Stephan_primates_Stephan_primates_metadata.xlsx",
  sheet = "Stephan_NHprimates metadata"
)
# read the metadata sheet 
names(stephan_meta)

# A typical pattern (adjust to match your actual column names):
stephan_1981_vars <- stephan_meta %>%
  filter(str_detect(Source, "Stephan") & str_detect(Source, "1981")) %>%
  pull(Variable)    # or the column that stores names like "Medulla_oblongata"


#3.3. Pivot Stephan data (Stephan 1981 variables only) to long format
stephan_stephan1981_long <- stephan_raw %>%
  rename(species = Species) %>%   # adjust if the column name differs
  select(
    species,
    all_of(stephan_1981_vars)
  ) %>%
  pivot_longer(
    cols      = -species,
    names_to  = "structure",
    values_to = "volume_mm3"
  ) %>%
  mutate(
    dataset      = "Stephan_metadata",
    ref_id       = 24L,  # match DeCasien reference number for Stephan 1981
    ref_citation = "Stephan et al. 1981, Folia Primatol. 35:1–29"
  )