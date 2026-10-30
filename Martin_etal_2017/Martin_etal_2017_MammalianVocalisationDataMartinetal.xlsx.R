.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
folder <- dirname(.sp); base <- dirname(folder); item_name <- tools::file_path_sans_ext(basename(.sp))
source(file.path(base, "_helpers", "build_recent_source.R"))
transform <- function(x) {
  stopifnot(nrow(x) == 193L)
  names(x) <- c("species_as_published", "sociality", "environment", "diet",
                "min_freq_khz", "log10_min_freq", "max_freq_khz", "log10_max_freq",
                "body_mass_g", "log10_body_mass", "source_citation", "source_reference")
  x$species_as_published <- gsub("_", " ", x$species_as_published, fixed = TRUE)
  for (nm in c("min_freq_khz", "log10_min_freq", "max_freq_khz", "log10_max_freq",
               "body_mass_g", "log10_body_mass")) x[[nm]] <- suppressWarnings(as.numeric(x[[nm]]))
  x$source_row <- seq_len(nrow(x)) + 1L
  x$data_role <- "secondary"
  x
}
description <- c(species_as_published = "Taxon as supplied, underscores displayed as spaces",
                 sociality = "Author category of sociality", environment = "Author environment category",
                 diet = "Author diet category", min_freq_khz = "Minimum vocalization frequency in kHz",
                 max_freq_khz = "Maximum vocalization frequency in kHz", body_mass_g = "Body mass in g",
                 source_citation = "Per-row source citation", source_reference = "Per-row full source reference",
                 source_row = "One-based worksheet row in frozen source", data_role = "Secondary synthesis",
                 `_note` = "Literature compilation. Source measurements overlap Garcia & Ravignani 2020; use the per-row citations before any primary ingestion.")
build_recent_source(folder, item_name, paste0(item_name, "_snapshot.xlsx"), sheet = "Sheet1",
                    transform = transform, description = description,
                    source_note = "Martin, Tucker & Rogers 2017, Evolution 71, doi:10.1111/evo.13128, Mammalian Vocalisation Data")
