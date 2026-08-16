# Hutsler et al. (2005) Figure 3: species-level laminar thickness in primary
# somatosensory cortex, digitized from the embedded 646 x 834 JPEG.
#
# The snapshot freezes manually reviewed pixel boundaries. Values are estimates,
# not a substitute for a numerical source table. Figure-derived order means do
# not reproduce several narrative means in the paper; that conflict is retained.

options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or open the saved file in RStudio and click Source.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
squish <- function(x) trimws(gsub("[[:space:]]+", " ", ifelse(is.na(x), "", as.character(x))))

species_token <- "Hutsler2005"
species_lookup <- local({
  key <- NULL
  shared <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
  if (!is.na(shared) && file.exists(shared)) {
    key <- read.csv(shared, stringsAsFactors = FALSE, check.names = FALSE)
    key <- key[squish(key$source_publication) == species_token, , drop = FALSE]
  }
  if (is.null(key) || nrow(key) == 0) {
    pending <- file.path(folder, "PROPOSED_species_key_rows.csv")
    key <- read.csv(pending, stringsAsFactors = FALSE, check.names = FALSE)
    key <- key[squish(key$source_publication) == species_token, , drop = FALSE]
  }
  stats::setNames(squish(key$accepted_name), tolower(squish(key$variant_name)))
})
resolve_species <- function(...) {
  candidates <- list(...)
  out <- rep(NA_character_, length(candidates[[1]]))
  for (candidate in candidates) {
    hit <- unname(species_lookup[tolower(squish(candidate))])
    out[is.na(out)] <- hit[is.na(out)]
  }
  out
}

raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE)

absolute_scale <- 3000 / (raw$panel_A_axis_0_y_px - raw$panel_A_axis_3000_y_px)
proportion_scale <- 1 / (raw$panel_B_axis_0_y_px - raw$panel_B_axis_100_y_px)

final.dataframe <- data.frame(
  order_printed = raw$order_printed,
  common_name_printed = raw$common_name_printed,
  scientific_name_printed = raw$scientific_name_printed,
  species_sci = resolve_species(raw$common_name_printed, raw$scientific_name_printed),
  region = "primary somatosensory cortex",
  total_cortical_thickness_um = round(((raw$panel_A_axis_0_y_px - raw$panel_A_top_y_px) * absolute_scale) / 10) * 10,
  supragranular_II_III_thickness_um = round(((raw$panel_A_IIIII_IV_boundary_y_px - raw$panel_A_I_IIIII_boundary_y_px) * absolute_scale) / 10) * 10,
  infragranular_V_VI_thickness_um = round(((raw$panel_A_axis_0_y_px - raw$panel_A_IV_V_boundary_y_px) * absolute_scale) / 10) * 10,
  supragranular_II_III_proportion = round((raw$panel_B_IIIII_bottom_y_px - raw$panel_B_IIIII_top_y_px) * proportion_scale, 3),
  infragranular_V_VI_proportion = round((raw$panel_B_axis_0_y_px - raw$panel_B_V_top_y_px) * proportion_scale, 3),
  digitization_uncertainty_um = 25,
  digitization_uncertainty_proportion = 0.010,
  value_basis = "digitized from Figure 3 bars",
  digitization_flag = ifelse(nzchar(raw$digitization_flag), raw$digitization_flag, NA_character_),
  qa_note = "Figure 3-derived order means do not reproduce several narrative/Figure 6 summaries; retain separately.",
  source = item_name,
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 14L)
stopifnot(!anyNA(final.dataframe$species_sci))
stopifnot(all(final.dataframe$supragranular_II_III_proportion > 0 & final.dataframe$supragranular_II_III_proportion < 1))
stopifnot(all(final.dataframe$infragranular_V_VI_proportion > 0 & final.dataframe$infragranular_V_VI_proportion < 1))
stopifnot(all(final.dataframe$supragranular_II_III_proportion + final.dataframe$infragranular_V_VI_proportion < 1))

reported_supra_um <- c(Primate = 867.9, Carnivore = 567.1, Rodent = 438.2)
reported_supra_prop <- c(Primate = 0.44, Carnivore = 0.35, Rodent = 0.26)
for (grade in names(reported_supra_um)) {
  rows <- final.dataframe$order_printed == grade
  figure_um <- mean(final.dataframe$supragranular_II_III_thickness_um[rows])
  figure_prop <- mean(final.dataframe$supragranular_II_III_proportion[rows])
  message(sprintf("%s Figure 3 supra mean: %.1f um / %.3f; narrative: %.1f um / %.3f",
                  grade, figure_um, figure_prop, reported_supra_um[[grade]], reported_supra_prop[[grade]]))
}

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message("Wrote ", item_name, ".csv (14 digitized species rows)")

if (!is.na(base) && requireNamespace("readxl", quietly = TRUE)) {
  registry <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
  if (length(encoded) && !is.na(encoded) && nzchar(encoded)) {
    public_dir <- file.path(base, "__Public", "comparative-data")
    dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(final.dataframe, file.path(public_dir, paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  } else {
    warning("No registry row for ", item_name, "; public TSV skipped.")
  }
}
