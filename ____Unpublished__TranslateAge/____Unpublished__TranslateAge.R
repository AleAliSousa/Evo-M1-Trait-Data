# I. Read the published dataset from the source, and DO NOT pivot wider
## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____Unpublished__TranslateAge/"

library(readxl)
library(dplyr)
library(writexl)



tabledirect <- read_excel(paste0(folder_path,"M1evo_10x_libraries.xlsx"), sheet = "RNA") # Get the ages of animals to translate
data_read <- read_tsv(paste0(folder_path,"anage_data.txt")) # Get the anage dataset
translatingtime <- read_excel(paste0(folder_path,"Translating_Time_Dataset copy.xlsx"), sheet = 1) # Get the translatingtime




# Select the columns you need
summary_data <- tabledirect %>%
  select(donor_name, external_donor_name, age, species, sex) %>%
  distinct()

# Write summarized data to Excel file
write_xlsx(summary_data, paste0(folder_path, "CellProportions_summary_data.xlsx"))

# Select the columns you need
age_list <- tabledirect %>%
  select(age, species, sex) %>%
  distinct()


# Add a line to age_list with species == Mus musculus age == P56
# Create a new row as a data frame
new_row <- data.frame(
  species = "Mus musculus",
  age = "P56",
  sex = NA
  )

# Bind the new row to the existing age_list data frame
age_list <- rbind(age_list, new_row)


# Save dataframe to a CSV file
write.csv(age_list, paste0(folder_path, "./age_list.csv"), row.names = FALSE)
  
# view list of species
species_list<-unique(age_list$species)
write.csv(species_list, paste0(folder_path, "./species_list.csv"), row.names = FALSE)


# Add a row to age_list called `Maximum longevity (yrs)`
# A. Filter data
data_filtered <- data_read %>%
  # Keep only rows where Class is Mammalia
  filter(Class == "Mammalia") %>%
  # # Remove rows where `Gestation/Incubation (days)` is NA
  # filter(!is.na(`Gestation/Incubation (days)`)) %>%
  # Combine Genus and Species columns into a new Species column
  mutate(Species = paste(Genus, Species, sep = " ")) %>%
  # Combine `Sample size` and `Data quality` columns into a new .Note column
  mutate(.Note = paste0("sample size ", `Sample size`,"; data quality ", `Data quality`)) %>% #Alter this later for Maximum Lifespan
  # Rename `Gestation/Incubation (days)` to Gestation
  rename(Gestation = `Gestation/Incubation (days)`,
         # Rename `Specimen origin` to `.Environment`
         '.Environment' = `Specimen origin`) %>%
  # # Replace term and capitalize the first letters in .Environment
  mutate(.Environment = str_replace_all(.Environment, "captivity", "Captive"),
         .Environment = str_to_title(.Environment))

# merge to age_list  `Maximum longevity (yrs)` from data_read by matching age_list$species to data_read$Species
# note that there are multiple rows with the same age_list$species, but only one row per data_read$Species

# Ensure that your species columns are correctly formatted as character vectors
age_list$species <- as.character(age_list$species)
data_filtered$Species <- as.character(data_filtered$Species)

# Merge the "Maximum longevity (yrs)" from data_filtered into age_list
age_list <- merge(age_list, data_filtered[, c("Species", "Maximum longevity (yrs)", "Gestation")],
                  by.x = "species", by.y = "Species", all.x = TRUE)

# Add lists
age_list$PostConceptionDays <- NA
age_list$Years_old <- NA
age_list$Maximum_longevity <- NA
age_list$Years_old_ratio <- NA

# Extract the numerical part from the Age column and convert it to numeric
age_list$Years_old <- as.numeric(gsub("[^0-9]", "", age_list$Age))

# Ensure both columns are numeric
age_list$Maximum_longevity <- as.numeric(age_list$`Maximum longevity (yrs)`)

# Calculate the ratio and add it as a new column
age_list$Years_old_ratio <- age_list$Years_old / age_list$Maximum_longevity

