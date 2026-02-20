# Load the necessary library
library(tidyr)
library(dplyr)

# Create a dataframe with the provided data
df <- data.frame(
  Species = c('Mouse', 'Rat', 'Rabbit', 'Monkey', 'Orangutan'),
  Brain_Mass.g = c(0.4, 0.5, 2.1, 70, 1400),
  Brain_I.p.mg = c(4, 5, 20, 600, NA),
  Body_Mass.g = c(20, 250, 2000, 7000, 70000),
  Body_I.p.mg = rep(NA, 5),
  WholeBrain_Mass.g = c(0.35, 0.4, 1.8, 60, 1200),
  WholeBrain_I.p.mg = c(3.5, 4, 18, 550, NA),
  WholeBrain_Vol.mm3 = c(0.1, 0.15, 0.8, NA, NA),
  WholeBrain_N.n = c(0.35, 0.4, 1.8, 60, NA),
  Cerebellum_Mass.g = c(0.05, 0.06, 0.3, 10, 200),
  Cerebellum_I.p.mg = c(0.5, 0.6, 3, 100, NA),
  Cerebellum_Vol.mm3 = c(0.1, 0.15, 0.8, NA, NA),
  Cerebellum_N.n = c(0.35, 0.4, 1.8, 60, 1200),
  RoB_Mass.g = c(0.1, 0.15, 0.8, 20, NA),
  RoB_I.p.mg = c(1, 1.5, 8, 200, NA),
  RoB_N.n = c(0.1, 0.15, 0.8, 20, NA),
  Source = c("A", "B", "C", "C", "C"),
  priority = c("A", "B", "C", "C", "C"),
  DECISION = c("A", "B", "C", "C", "C")
)

# Melt the dataframe
df_long <- df %>%
  pivot_longer(
    cols = -c(Species, Source, priority, DECISION), # Exclude Species, Source, priority, and DECISION from pivoting
    names_to = "Variable", 
    values_to = "Value"
  )

# Split the Variable column into Type and Measure
df_widen <- df_long %>%
  separate(Variable, into = c("Type", "Measure"), sep = "_", remove = FALSE)

# Correctly align Mass.g and I.p.mg in the same row
df_corrected <- df_widen %>%
  group_by(Species, Type, Source, priority, DECISION) %>%
  summarise(Mass.g = Value[Measure == "Mass.g"],
            I.p.mg = Value[Measure == "I.p.mg"])

# Calculate _I.n values
df_calc <- df_corrected %>%
  mutate(I.n = Mass.g * I.p.mg * 1000)

# Pivot longer again, to return to a fully long format, and combine Type and Measure into Variable
df_long_calc <- df_calc %>%
  pivot_longer(cols = c(`Mass.g`, `I.p.mg`, `I.n`), names_to = "Measure", values_to = "Value") %>%
  unite("Variable", Type, Measure, sep = "_", remove = TRUE) %>%
  select(Species, Source, Variable, Value, priority, DECISION)

# Remove rows with NA values in the Value column
df_long_calculated <- df_long_calc %>%
  filter(!is.na(Value))

## NOTES
# could try independently calculated I.n then append to entire dataframe df_long (or any step until it gets reduced)
#  what happens to SOURCE, priority, DECISION since the values for those would be combined from TWO DIFFERENT SOURCES.  Are there already any double sources?
# it might be easier to convert it to the ORIGINAL LIST and then use the old code.