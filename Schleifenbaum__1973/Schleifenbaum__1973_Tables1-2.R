# Schleifenbaum 1973 Tables 1-2: postnatal poodle and wolf individuals.

suppressPackageStartupMessages(library(readxl))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
root_dir <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

table1 <- read.csv(file.path(paper_dir, "Schleifenbaum__1973_Table1_snapshot.csv"),
                   check.names = FALSE, colClasses = "character", stringsAsFactors = FALSE)
table2 <- read.csv(file.path(paper_dir, "Schleifenbaum__1973_Table2_snapshot.csv"),
                   check.names = FALSE, colClasses = "character", stringsAsFactors = FALSE)
stopifnot(nrow(table1) == 33L, nrow(table2) == 16L)

num_de <- function(x) {
  x <- gsub("[()]", "", trimws(as.character(x)))
  x[x %in% c("", "-", "–", "—")] <- NA_character_
  suppressWarnings(as.numeric(sub(",", ".", x, fixed = TRUE)))
}

volume_codes <- c(
  "medulla_oblongata_mm3", "cerebellum_mm3", "mesencephalon_mm3",
  "diencephalon_mm3", "telencephalon_mm3", "neocortex_mm3", "striatum_mm3",
  "allocortex_mm3", "periventricular_matrix_mm3", "olfactory_bulb_mm3",
  "olfactory_allocortex_nucleus_amygdalae_mm3", "nonolfactory_allocortex_mm3",
  "septum_mm3", "hippocampus_mm3", "schizocortex_mm3", "total_brain_volume_mm3"
)
stopifnot(length(volume_codes) == nrow(table2))

volume_for <- function(id) {
  if (!id %in% names(table2)) return(setNames(rep(NA_real_, length(volume_codes)), volume_codes))
  setNames(num_de(table2[[id]]), volume_codes)
}

rows <- lapply(seq_len(nrow(table1)), function(i) {
  printed_id <- table1$Nr_printed[i]
  id <- sub("\\*$", "", printed_id)
  volumes <- volume_for(id)
  group <- table1$species_group_printed[i]
  data.frame(
    source_row = i,
    Species_Schleifenbaum1973 = group,
    Species = if (group == "Großpudel") "Canis lupus familiaris" else "Canis lupus",
    domestication_status = if (group == "Großpudel") "domestic" else "wild",
    individual = id,
    individual_printed = printed_id,
    sectioned_for_Table2 = grepl("\\*$", printed_id),
    sex_printed = table1$sex_printed[i],
    sex = if (table1$sex_printed[i] == "♂") "male" else if (table1$sex_printed[i] == "♀") "female" else "unknown",
    age_printed = table1$age_printed[i],
    body_mass_g = num_de(table1$NKG_g_printed[i]),
    brain_mass_mg = num_de(table1$HG_g_printed[i]) * 1000, # printed g -> project mg
    source_value_parenthesized = grepl("^\\(", table1$NKG_g_printed[i]) | grepl("^\\(", table1$HG_g_printed[i]),
    as.list(volumes), check.names = FALSE, stringsAsFactors = FALSE
  )
})
final.dataframe <- do.call(rbind, rows)
rownames(final.dataframe) <- NULL

core_volume_codes <- setdiff(volume_codes, "periventricular_matrix_mm3")
if (sum(complete.cases(final.dataframe[core_volume_codes])) != 12L) {
  stop("Expected complete core Table 2 profiles for 12 individuals (1-9 and 11-13)")
}
if (sum(!is.na(final.dataframe$periventricular_matrix_mm3)) != 6L) {
  stop("Periventricular matrix should be printed only for young poodles 1-6")
}
local_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, local_csv, row.names = FALSE, na = "")

registry <- read_excel(file.path(root_dir, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  stop("No cached Item encoded value for ", item_name, " in __ReadMe.xlsx")
}
public_tsv <- file.path(root_dir, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, public_tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "")
message("Wrote ", local_csv, " and ", public_tsv, " (", nrow(final.dataframe), " individuals)")
