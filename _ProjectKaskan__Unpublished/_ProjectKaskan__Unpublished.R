setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/_ProjectKaskan__Unpublished")
## Compare and combine data from Summer Alznati, Jack Gaston and Rachael Robinson's dissertations


library(tidyverse)
library(readxl)

# Read Jacks's means
jack <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/_ProjectKaskan__Unpublished/Jack_Gaston_dissertation_file_copies/Jack Gaston Raw Cortical Data.xlsx", sheet = "means")
jack <- as.data.frame(jack)

# Read Rachael's means
rachael <- read_csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/_ProjectKaskan__Unpublished/Rachael_Robinson_dissertation_file_copies/Rachael_data.csv")
rachael <- as.data.frame(rachael)

# Read Summer's means
summer <- read_csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/_ProjectKaskan__Unpublished/Summer_Alznati_dissertation_file_copies/data_analysis.csv")
summer <- as.data.frame(summer)

## 1 Compare Rachael and Summer which are very similar

# 1.1  Remove the "Total_neocortex" column which is only in the "summer" dataset
summer_noneo <- select(summer, -Total_neocortex)

# 1.2 Comparison in different libraries 
library(compare)
compare(rachael, summer_noneo)

library(arsenal)
summary(comparedf(rachael, summer_noneo))

# 1.3 Write function to compare values between two data frames
compare_values <- function(df1, df2) {
  identical_values <- sapply(1:nrow(df1), function(i) {
    sapply(1:ncol(df1), function(j) {
      identical(df1[i, j], df2[i, j])
    })
  })
  return(identical_values)
}
comparison_values <- compare_values(rachael, summer_noneo)
comparison_df <- as.data.frame(comparison_values)
print(comparison_df)

## Conclusion: these are the same although Summer also has Total neocortex added.

## 2 Check Summer's work: check the difference between the sum of all areas and Total neocortex

## 3 Compare Summer to Jack