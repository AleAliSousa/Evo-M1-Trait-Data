# Hutsler et al. (2005) Figure 6: order-level supragranular thickness across
# primary motor, premotor, and primary somatosensory cortex.
#
# Visual axes show panel A = absolute thickness (um) and panel B = proportional
# thickness (%). Both panels plot the same three region series and have bar heights
# consistent with supragranular layers II/III. The printed caption instead calls A
# and B supragranular and infragranular "proportional" panels. This internally
# impossible caption is flagged rather than followed silently.

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

raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE)

absolute <- (raw$panel_A_axis_0_y_px - raw$panel_A_bar_top_y_px) /
  (raw$panel_A_axis_0_y_px - raw$panel_A_axis_1600_y_px) * 1600
proportion <- (raw$panel_B_axis_0_y_px - raw$panel_B_bar_top_y_px) /
  (raw$panel_B_axis_0_y_px - raw$panel_B_axis_60_y_px) * 0.60

n_by_order <- c(Primate = 5L, Carnivore = 3L, Rodent = 5L)
reported_sensory_um <- c(Primate = 867.9, Carnivore = 567.1, Rodent = 438.2)
reported_sensory_prop <- c(Primate = 0.44, Carnivore = 0.35, Rodent = 0.26)
is_sensory <- raw$region == "primary somatosensory cortex"

final.dataframe <- data.frame(
  order_printed = raw$order_printed,
  region_printed = raw$region_printed,
  region = raw$region,
  layer_or_compartment = "supragranular layers II/III",
  n_species = unname(n_by_order[raw$order_printed]),
  absolute_thickness_um = round(absolute / 5) * 5,
  proportional_thickness = round(proportion, 3),
  digitization_uncertainty_um = 10,
  digitization_uncertainty_proportion = 0.005,
  reported_sensory_absolute_um = ifelse(is_sensory, unname(reported_sensory_um[raw$order_printed]), NA_real_),
  reported_sensory_proportion = ifelse(is_sensory, unname(reported_sensory_prop[raw$order_printed]), NA_real_),
  value_basis = "digitized from Figure 6 bars",
  caption_flag = "Axes and bars indicate A=absolute and B=proportional supragranular II/III; printed caption is internally inconsistent.",
  source = item_name,
  stringsAsFactors = FALSE
)
final.dataframe$digitized_minus_reported_sensory_um <-
  final.dataframe$absolute_thickness_um - final.dataframe$reported_sensory_absolute_um
final.dataframe$digitized_minus_reported_sensory_proportion <-
  final.dataframe$proportional_thickness - final.dataframe$reported_sensory_proportion

stopifnot(nrow(final.dataframe) == 9L)
stopifnot(sum(final.dataframe$n_species[raw$region_printed == "Motor"]) == 13L)
stopifnot(all(final.dataframe$proportional_thickness > 0 & final.dataframe$proportional_thickness < 1))
message("Figure 6 sensory digitization vs narrative (um): ",
        paste(final.dataframe$order_printed[is_sensory],
              round(final.dataframe$digitized_minus_reported_sensory_um[is_sensory], 1), collapse = "; "))

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message("Wrote ", item_name, ".csv (9 order x region rows)")

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
