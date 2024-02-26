# # Load the necessary library
# library(dplyr)
# 
# # Create a dataframe with the provided data
# df <- data.frame(
#   Species = c('Mouse', 'Rat', 'Rabbit', 'Monkey', 'Orangutan'),
#   Brain_Mass.g = c(0.4, 0.5, 2.1, 70, 1400),
#   Brain_I.p.mg = c(4, 5, 20, 600, NA),
#   Body_Mass.g = c(20, 250, 2000, 7000, 70000),
#   Body_I.p.mg = rep(NA, 5),
#   WholeBrain_Mass.g = c(0.35, 0.4, 1.8, 60, 1200),
#   WholeBrain_I.p.mg = c(3.5, 4, 18, 550, NA),
#   Cerebellum_Mass.g = c(0.05, 0.06, 0.3, 10, 200),
#   Cerebellum_I.p.mg = c(0.5, 0.6, 3, 100, NA),
#   RoB_Mass.g = c(0.1, 0.15, 0.8, 20, NA),
#   RoB_I.p.mg = c(1, 1.5, 8, 200, NA)
# )
# 
# # Calculate _I.n values
# prefixes <- c('Brain', 'Body', 'WholeBrain', 'Cerebellum', 'RoB')
# for (prefix in prefixes) {
#   df[[paste0(prefix, '_I.n')]] <- df[[paste0(prefix, '_I.p.mg')]] * df[[paste0(prefix, '_Mass.g')]] * 1000
# }
# 
# # Display the dataframe
# print(df)


# Create a dataframe with the provided data
df <- data.frame(
  Species = c('Mouse', 'Rat', 'Rabbit', 'Monkey', 'Orangutan'),
  Brain_Mass.g = c(0.4, 0.5, 2.1, 70, 1400),
  Brain_I.p.mg = c(4, 5, 20, 600, NA),
  Body_Mass.g = c(20, 250, 2000, 7000, 70000),
  Body_I.p.mg = rep(NA, 5),
  WholeBrain_Mass.g = c(0.35, 0.4, 1.8, 60, 1200),
  WholeBrain_I.p.mg = c(3.5, 4, 18, 550, NA),
  Cerebellum_Mass.g = c(0.05, 0.06, 0.3, 10, 200),
  Cerebellum_I.p.mg = c(0.5, 0.6, 3, 100, NA),
  RoB_Mass.g = c(0.1, 0.15, 0.8, 20, NA),
  RoB_I.p.mg = c(1, 1.5, 8, 200, NA)
)

# Melt the dataframe
df_long <- df %>%
  pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
  mutate(Source = "source") %>%
  select(Species, Variable, Source, Value)
df_long

# Assuming df_long is your starting point

# Step 1: Separate the 'Variable' into 'Structure' and 'Measure'
df_long$Structure <- gsub("_.*", "", df_long$Variable)
df_long$Measure <- gsub(".*_", "", df_long$Variable)

# Perform a self-join to align Mass.g and I.p.mg for the same structure and species
df_joined <- merge(df_long[df_long$Measure == "Mass.g", ],
                   df_long[df_long$Measure == "I.p.mg", ],
                   by = c("Species", "Structure"),
                   suffixes = c(".Mass", ".Ipmg"))

# Calculate I.n directly in the joined dataframe
df_joined$I_n <- df_joined$Value.Mass * df_joined$Value.Ipmg * 1000

# This result now has one row per structure per species with the calculated I.n value
