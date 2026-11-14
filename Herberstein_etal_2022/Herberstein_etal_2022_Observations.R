# Herberstein et al. (2022), AnimalTraits. Reads only this item's frozen workbook.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- if (length(args) == 1L) sub("^--file=", "", args) else sys.frame(1)$ofile
folder <- dirname(normalizePath(script, mustWork = TRUE))
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(script))
final.dataframe <- as.data.frame(readxl::read_excel(
  file.path(folder, paste0(item_name, "_snapshot.xlsx")), sheet = "Observations", guess_max = 10000))
# Preserve all 43 supplied fields (including original values/units and authors' SI values).
# Appended project units: kg -> g (*1000); kg -> mg (*1e6); W/kg -> W/g (/1000).
final.dataframe$Source_row <- seq_len(nrow(final.dataframe)) + 1L
final.dataframe$Species_Herberstein2022 <- final.dataframe$species
final.dataframe$Body_Mass.g <- final.dataframe[["body mass"]] * 1000
final.dataframe$Body_Mass_min.g <- as.numeric(final.dataframe[["body mass - minimum"]]) * 1000
final.dataframe$Body_Mass_max.g <- as.numeric(final.dataframe[["body mass - maximum"]]) * 1000
final.dataframe$Brain_Mass.mg <- final.dataframe[["brain size"]] * 1e6
final.dataframe$Metabolic_Rate.W <- final.dataframe[["metabolic rate"]]
final.dataframe$Mass_specific_Metabolic_Rate.W_g <- final.dataframe[["mass-specific metabolic rate"]] / 1000
u <- final.dataframe[["original brain size - units"]]
v <- final.dataframe[["original brain size"]]
# Original measured volume only; never back-calculate volume from a mass value.
factor <- c(ml = 1000, mm3 = 1, um3 = 1e-9, "x6.4e-5 mm3" = 6.4e-5, "x1e6 um3" = 1e-3)
final.dataframe$Brain_Volume_original.mm3 <- v * unname(factor[u])
final.dataframe$Brain_mass_basis <- ifelse(is.na(v), NA_character_,
  ifelse(u %in% names(factor), "volume converted to mass by AnimalTraits",
         "mass reported by source; direct weighing not implied"))
final.dataframe$Brain_mass_density.g_ml <- ifelse(u %in% names(factor), 1.036, NA_real_)
# The density applies to volume-derived masses, including endocranial proxies.
# Skull filling stays identifiable in the original 'brain size - method' field.
stopifnot(nrow(final.dataframe) == 3580L,
          all(is.na(final.dataframe[["body mass - units"]]) | final.dataframe[["body mass - units"]] == "kg"),
          all(is.na(final.dataframe[["brain size - units"]]) | final.dataframe[["brain size - units"]] == "kg"),
          all(is.na(final.dataframe[["metabolic rate - units"]]) | final.dataframe[["metabolic rate - units"]] == "W"))

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "")
registry <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"))
i <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
stopifnot(length(i) == 1L)
item_encoded <- registry[["Item encoded"]][i]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", quote = TRUE, qmethod = "double", row.names = FALSE, na = "")
cat(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns\n", sep = "")
