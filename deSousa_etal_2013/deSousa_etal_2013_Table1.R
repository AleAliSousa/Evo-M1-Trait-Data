## de Sousa et al. 2013, Table 1. Printed table -> established analysis schema.
## The snapshot retains all eight printed columns, source order, and the footnote.
options(scipen = 999)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required")
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(.sp)
item <- tools::file_path_sans_ext(basename(.sp))
raw <- as.data.frame(readxl::read_excel(file.path(folder, paste0(item, "_snapshot.xlsx")),
                                       sheet = "Table1", col_names = FALSE, col_types = "text"),
                     stringsAsFactors = FALSE)
stopifnot(ncol(raw) == 8L, nrow(raw) == 23L,
          raw[1, 1] == "Table 1. LGN parvocellular lamination, species mean brain weights and LGN volumes",
          identical(as.character(raw[2, ]), c("Species", "Leaflets", "n", "Brain weight (g)",
                                                 "n", "LGN volume (cm³)", "n", "LGN residual")))
body <- raw[3:22, , drop = FALSE]
names(body) <- c("Species", "Leaflets", "n_leaflets", "Brain_weight_g", "n_brain",
                 "LGN_volume_cm3", "n_LGN", "LGN_residual")
stopifnot(nrow(body) == 20L, !anyDuplicated(body$Species))
body <- body[body$LGN_volume_cm3 != "NA", , drop = FALSE]
lookup <- read.csv(file.path(folder, "reference_tables", paste0(item, "_precision_lookup.csv")),
                   stringsAsFactors = FALSE)
stopifnot(nrow(body) == nrow(lookup), setequal(body$Species, lookup$Species))
lookup <- lookup[match(body$Species, lookup$Species), , drop = FALSE]
printed_lgn <- as.numeric(body$LGN_volume_cm3) * 1000
printed_brain <- as.numeric(gsub(",", "", body$Brain_weight_g)) * 1000
## Earlier curated values carry sub-µL and sub-0.1-g precision not printed in
## this table. Keep them outside the source snapshot and assert that each
## rounds to the printed cell before using them in the established data file.
stopifnot(all(abs(as.numeric(lookup$LGN_volume_mm3_curated) - printed_lgn) <= 0.5 + 1e-8),
          all(abs(as.numeric(lookup$brain_weight_mg_curated) - printed_brain) <= 50 + 1e-8))
clean <- data.frame(
  species = body$Species,
  corpus_geniculatum_laterale_mm3 = as.numeric(lookup$LGN_volume_mm3_curated),
  brain_weight_mg = as.numeric(lookup$brain_weight_mg_curated),
  source = sub("_Table[^_]*$", "", item),
  stringsAsFactors = FALSE
)
clean <- clean[order(clean$species), , drop = FALSE]
rownames(clean) <- NULL
write.csv(clean, file.path(folder, paste0(item, ".csv")), row.names = FALSE)

base <- dirname(folder)
if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
  codes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- codes$`Item encoded`[match(item, codes$`Item name`)]
  if (!is.na(encoded) && nzchar(encoded))
    write.table(clean, file.path(base, "__Public", "comparative-data", paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
}
