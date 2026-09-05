.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## snapshot: printed Table 2 "Weights in grams of the brain stem, prosencephalon and cerebellum
## and the ratios of the suprasegmental parts to the brain stem" -- frog and turtle are printed
## without a binomial (unspecified taxon); rat/baboon/man values are the paper's own footnoted
## secondary citations (Donaldson 1924; Riese & Riese 1952; Donaldson 1909), not this lab's own
## dissections -- data_role reflects that per row.
x <- readr::read_csv("Latimer__1956_Table2_snapshot.csv", show_col_types = FALSE)

key <- readr::read_csv(file.path(base, "_keys", "Stephan", "species_key.csv"), show_col_types = FALSE)
key_lat <- key[key$source_publication == "Latimer1956", ]
lk <- setNames(key_lat$accepted_name, key_lat$variant_name)
x$Species <- lk[x$species_as_published]  ## NA for Frog/Turtle -- no binomial given in the paper

x$weight_brain_stem_mg     <- x$brain_stem_g * 1000
x$weight_prosencephalon_mg <- x$prosencephalon_g * 1000
x$weight_cerebellum_mg     <- x$cerebellum_g * 1000
x$source_location <- 'Table 2, "Weights in grams of the brain stem, prosencephalon and cerebellum and the ratios of the suprasegmental parts to the brain stem"'

out <- x[, c("Species", "species_as_published", "weight_brain_stem_mg", "weight_prosencephalon_mg",
             "ratio_prosencephalon_to_brainstem", "weight_cerebellum_mg",
             "ratio_cerebellum_to_brainstem", "data_role", "secondary_source", "source_location")]

readr::write_csv(out, "Latimer__1956_Table2.csv", na = "")
message(item_name, ": ", nrow(out), " rows written")

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)][1]
} else NA_character_
if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "'; TSV skipped.")
} else if (dir.exists(path.expand(tsv_dir))) {
  write.table(out, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote TSV: ", item_encoded)
}
