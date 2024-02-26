library(dplyr)

# Update metadata_flags with a Flag_Condition column
metadata_flags <- data.frame(
  PaperID = c("HerculanoHouzel_etal_2015", "HerculanoHouzel_etal_2015"),
  TableID = c("Table1", "Table2"),
  Variable = c("WholeBrainN.n", "NeuronCount"),
  Flagged_Values = c("Homo sapiens", "<0"),
  Flag_Description = c("Typo in species name", "Negative values not biologically plausible"),
  Flag_Condition = c("Species == 'Homo sapiens'", "TRUE")
)

# Hypothetical data tables
HerculanoHouzel_etal_2015_Table1 <- data.frame(
  Species = c("Homo sapiens", "Pan troglodytes", "Gorilla gorilla", "Pongo pygmaeus", "Pan paniscus"),
  Age = c(25, 30, 140, 160, 45),
  Height = c(160, 170, 180, 175, 165)
)

HerculanoHouzel_etal_2015_Table2 <- data.frame(
  Species = c("Homo sapiens", "Pan troglodytes", "Gorilla gorilla", "Pongo pygmaeus", "Pan paniscus"),
  WholeBrainN.n = c(100, 200, -10, 300, 150),
  WholeBrainMass = c(1.2, 1.5, 1.0, 1.8, 1.4)
)

# Merge tables based on Species
merged_table <- left_join(HerculanoHouzel_etal_2015_Table1, HerculanoHouzel_etal_2015_Table2, by = "Species")

# Apply the filtering based on conditions in metadata for each table
flagged_table <- merged_table
for (i in seq_len(nrow(metadata_flags))) {
  condition <- metadata_flags$Flag_Condition[i]
  if (!is.na(condition)) {
    flagged_table <- flagged_table %>% filter(eval(parse(text = condition)))
  }
}

# Create a table with not flagged values
not_flagged_table1 <- anti_join(merged_table, flagged_table, by = c("Species"))

# Display not_flagged_table1
print(not_flagged_table1)
