.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
folder <- dirname(.sp); base <- dirname(folder); item_name <- tools::file_path_sans_ext(basename(.sp))
source(file.path(base, "_helpers", "build_recent_source.R"))
transform <- function(x) {
  stopifnot(nrow(x) == 164L)
  names(x) <- c("species_as_published", "vocal_learning_taxon", "min_freq_khz",
                "max_freq_khz", "body_mass_g", "source_citation", "source_reference",
                "max_frequency_residual", "min_frequency_residual")
  for (nm in c("min_freq_khz", "max_freq_khz", "body_mass_g", "max_frequency_residual", "min_frequency_residual"))
    x[[nm]] <- suppressWarnings(as.numeric(x[[nm]]))
  x$species_as_published <- gsub("_", " ", x$species_as_published, fixed = TRUE)
  x$source_row <- seq_len(nrow(x)) + 4L
  x$data_role <- "secondary"
  x
}
description <- c(species_as_published = "Taxon as supplied, underscores displayed as spaces",
                 vocal_learning_taxon = "VLtaxon flag supplied by authors",
                 min_freq_khz = "Minimum vocalization frequency in kHz",
                 max_freq_khz = "Maximum vocalization frequency in kHz",
                 body_mass_g = "Body mass in g",
                 source_citation = "Per-row source citation",
                 source_reference = "Per-row full bibliographic source",
                 max_frequency_residual = "Author-supplied maximum-frequency residual",
                 min_frequency_residual = "Author-supplied minimum-frequency residual",
                 source_row = "One-based worksheet row in frozen source",
                 data_role = "Secondary synthesis; frequency and mass values overlap Martin et al. 2017",
                 `_note` = "The supplied frequencies and masses overlap Martin et al. 2017. This item preserves the vocal-learning classification and residuals; do not count shared measurements twice. OneDrive added an empty MediaServiceImageTags custom XML property to the copied snapshot; all worksheet payloads remain identical to the supplied workbook.")
build_recent_source(folder, item_name, paste0(item_name, "_snapshot.xlsx"),
                    sheet = "rawOutputDataOrdered_21042020", skip = 3,
                    transform = transform, description = description,
                    source_note = "Garcia & Ravignani 2020, Biology Letters 16:20200081, doi:10.1098/rsbl.2020.0081, supplement sp1")
