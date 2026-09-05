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

## snapshot: printed Table 3 "Grey-level index in area 10" (mean +/- SD, overall and by
## layer group), one right hemisphere per species, transcribed from semendeferi_etal_2001.pdf
raw <- readr::read_csv("Semendeferi_etal_2001_TABLE3_snapshot.csv", show_col_types = FALSE)

species_map <- c(Human="Homo sapiens", Chimpanzee="Pan troglodytes", Bonobo="Pan paniscus",
                  Gorilla="Gorilla gorilla", Orangutan="Pongo pygmaeus", Gibbon="Hylobates lar",
                  Macaque="Macaca mulatta")

wide <- do.call(rbind, lapply(split(raw, cumsum(!is.na(raw$Cortical_Mean))), function(g) {
  sp <- g$Species[1]
  data.frame(
    Species = species_map[[sp]],
    species_as_published = tolower(sp),
    specimen_as_published = tolower(sp),
    area_as_published = "area10",
    n_specimens = 1L,
    GLI_pct_mean_all_layers   = g$Cortical_Mean[1],
    GLI_pct_mean_supragranular = g$Layer_Mean[g$Layers == "II, III"],
    GLI_pct_mean_granular      = g$Layer_Mean[g$Layers == "IV"],
    GLI_pct_mean_infragranular = g$Layer_Mean[g$Layers == "V, VI"],
    source_location = 'Table 3 ("Grey-level index in area 10"); one right hemisphere per species, multiple measurement locations',
    data_role = "primary"
  )
}))

readr::write_csv(wide, "Semendeferi_etal_2001_TABLE3.csv", na = "")
message(item_name, ": ", nrow(wide), " rows written")

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)][1]
} else NA_character_
if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "'; TSV skipped.")
} else if (dir.exists(path.expand(tsv_dir))) {
  write.table(wide, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote TSV: ", item_encoded)
}
