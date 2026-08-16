# Ebinger 1974 Tables 3-4: per-individual sheep brain and region volumes.

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

snapshot <- read.csv(file.path(paper_dir, paste0(item_name, "_snapshot.csv")),
                     check.names = FALSE, stringsAsFactors = FALSE)
ids <- c("M1", "M2", "M3", "M4", "Sk1", "Sk2", "Sk3", "H1", "H2", "H3")
stopifnot(nrow(snapshot) == 26L, all(ids %in% names(snapshot)))

code <- c(
  "brain_mass_mg", "total_brain_volume_mm3", "remaining_parts_mm3", "ventricle_mm3",
  "pure_brain_volume_mm3", "medulla_oblongata_mm3", "cerebellum_mm3",
  "mesencephalon_mm3", "diencephalon_mm3", "telencephalon_mm3", "neocortex_mm3",
  "corpus_striatum_mm3", "allocortex_mm3", "olfactory_allocortex_mm3",
  "olfactory_bulbs_mm3", "regio_retrobulbaris_mm3", "regio_praepiriformis_mm3",
  "regio_periamygdalaris_amygdala_mm3", "tuberculum_olfactorium_mm3",
  "basal_nuclei_commissura_anterior_mm3", "limbic_structures_mm3", "septum_mm3",
  "septal_nuclei_mm3", "diagonal_band_mm3", "hippocampus_mm3", "schizocortex_mm3"
)
stopifnot(length(code) == nrow(snapshot))

rows <- lapply(ids, function(id) {
  values <- as.numeric(snapshot[[id]])
  names(values) <- code
  values["brain_mass_mg"] <- values["brain_mass_mg"] * 1000 # printed g -> project mg
  data.frame(
    Species_Ebinger1974 = if (grepl("^M", id)) "Ovis ammon musimon" else "Ovis ammon f. aries",
    individual = id,
    source_table = if (grepl("^M", id)) "Table 3" else "Table 4",
    status_printed = if (grepl("^M", id)) "wild sheep" else "domestic sheep",
    breed_printed = if (grepl("^Sk", id)) "Blackhead Sheep" else if (grepl("^H", id)) "North German Moorland Sheep" else "Mufflon",
    as.list(values), check.names = FALSE, stringsAsFactors = FALSE
  )
})
final.dataframe <- do.call(rbind, rows)
rownames(final.dataframe) <- NULL

if (any(!complete.cases(final.dataframe))) stop("Unexpected missing value in Ebinger Tables 3-4")
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
