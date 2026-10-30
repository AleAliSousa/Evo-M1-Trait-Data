.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
folder <- dirname(.sp); base <- dirname(folder); item_name <- tools::file_path_sans_ext(basename(.sp))
source(file.path(base, "_helpers", "build_recent_source.R"))
transform <- function(x) {
  stopifnot(nrow(x) == 78L, ncol(x) == 49L)
  names(x) <- make.unique(make.names(names(x)))
  x$species_as_published <- paste(trimws(x$Genus), trimws(x$Species))
  x$body_mass_g <- suppressWarnings(as.numeric(x$MassG))
  x$source_row <- seq_len(nrow(x)) + 2L
  x$data_role <- "both"
  x
}
description <- c(species_as_published = "Genus and species exactly as supplied in Table S1",
                 body_mass_g = "Body mass in g, copied from MassG",
                 VO2max = "Maximum oxygen consumption as given in the supplement; original column retained",
                 REFSHORT = "Short source reference supplied for each row",
                 source_row = "One-based worksheet row in the frozen source",
                 data_role = "Mixed source compilation; assess per-row reference before a primary merge",
                 `_note` = "The workbook mixes the authors' measurements with literature records. Per-row role is not resolved and these data have not been merged.")
build_recent_source(folder, item_name, paste0(item_name, "_snapshot.xls"), sheet = "Sheet 1",
                    skip = 1, transform = transform, description = description,
                    source_note = "Dlugosz et al. 2013, J Exp Biol 216:4712-4721, doi:10.1242/jeb.088914, Table S1")
