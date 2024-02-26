# Note: there is a big problem with Tragelaphus strepsiceros cell counts in Dos Santos et al., 2020 

# Extract the WholeBrain_C.n columns for both datasets
WholeBrain_Cn_HerculanoHouzel <- cellcounts_data_list$HerculanoHouzel_etal_2015_Table5[c("Species", "WholeBrain_C.n")]
WholeBrain_Cn_DosSantos <- cellcounts_data_list$DosSantos_etal_2020_Table1[c("Species", "WholeBrain_C.n")]

# Merge the dataframes based on the Species column
merged_df <- merge(WholeBrain_Cn_HerculanoHouzel, WholeBrain_Cn_DosSantos, by = "Species", all = TRUE)

# Calculate the difference between WholeBrain_C.n.x and WholeBrain_C.n.y
merged_df$Difference <- merged_df$WholeBrain_C.n.x - merged_df$WholeBrain_C.n.y

# Print the merged dataframe
print(merged_df)


