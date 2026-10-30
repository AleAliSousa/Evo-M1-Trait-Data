## ---- paths: self-contained ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  
  if (length(a))
    return(normalizePath(sub("^--file=", "", a[1])))
  
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p))
      p <- rstudioapi::getActiveDocumentContext()$path
    
    if (nzchar(p))
      return(normalizePath(p))
  }
  
  stop(
    "Run with Rscript file.R or Source from RStudio.",
    call. = FALSE
  )
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))

snapshot_file <- file.path(
  folder,
  paste0(item_name, "_snapshot.xlsx")
)

if (!file.exists(snapshot_file))
  stop("Snapshot not found: ", snapshot_file)

library(readxl)
library(readr)
library(dplyr)

snapshot <- read_excel(
  snapshot_file,
  sheet = "Table1_snapshot",
  skip = 1
)

parse_num <- function(x) {
  as.numeric(sub("°.*$", "", trimws(as.character(x))))
}

parse_sd <- function(x) {
  z <- sub(
    ".*\\(([-0-9.]+)°\\).*",
    "\\1",
    as.character(x)
  )
  
  ifelse(
    grepl("\\(", x),
    as.numeric(z),
    NA_real_
  )
}

parse_range <- function(x) {
  
  x <- gsub("°", "", as.character(x))
  
  p <- strsplit(x, "-")
  
  data.frame(
    binocular_visual_field_min_deg =
      vapply(p, function(z)
        as.numeric(z[1]), numeric(1)),
    binocular_visual_field_max_deg =
      vapply(p, function(z)
        as.numeric(z[length(z)]), numeric(1))
  )
}

rng <- parse_range(snapshot$`Binocular field as printed`)

final.dataframe <- snapshot %>%
  transmute(
    species_as_published = Species,
    common_name = `Common name`,
    n_specimens = as.integer(n),
    orbit_convergence_mean_deg =
      parse_num(`Orbit convergence as printed`),
    orbit_convergence_sd_deg =
      parse_sd(`Orbit convergence as printed`),
    binocular_visual_field_min_deg =
      rng$binocular_visual_field_min_deg,
    binocular_visual_field_max_deg =
      rng$binocular_visual_field_max_deg,
    binocular_visual_field_midpoint_deg =
      (
        rng$binocular_visual_field_min_deg +
          rng$binocular_visual_field_max_deg
      ) / 2,
    binocular_visual_field_reference = Reference,
    data_role =
      "primary_orbit_convergence_secondary_visual_field",
    note = ifelse(
      binocular_visual_field_min_deg !=
        binocular_visual_field_max_deg,
      paste0(
        "Range printed as ",
        binocular_visual_field_min_deg,
        "-",
        binocular_visual_field_max_deg,
        " degrees."
      ),
      ""
    ),
    source = "Heesy__2004 Table1"
  )

write_csv(
  final.dataframe,
  file.path(folder, paste0(item_name, ".csv")),
  na = ""
)

message(
  "Built ",
  paste0(item_name, ".csv"),
  " with ",
  nrow(final.dataframe),
  " rows"
)