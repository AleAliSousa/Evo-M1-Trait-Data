setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging")

library(dplyr)
library(tidyr)
library(tidyverse)

priority=read.csv2(file='Worth_dataframe.csv',sep = ',')
data=read.csv2(file='Intermediata_data.csv',sep = ',')
data <- data[-1]

data <- data %>%
  column_to_rownames(var = "Species")

data_long <- data %>% 
  rownames_to_column(var = "rowname") %>%  # Convert rownames to a column
  pivot_longer(
    cols = -rowname,  # Exclude the rowname column from pivoting
    names_to = "name", 
    values_to = "value",
    values_transform = list(value = as.character)  # Converting all values to character
  ) %>%
  mutate(name_split = strsplit(name, "__")) %>%
  separate(name, into = c("variable", "dataset"), sep = "__")

data_long$value <- as.numeric(data_long$value)


data
priority
data_long