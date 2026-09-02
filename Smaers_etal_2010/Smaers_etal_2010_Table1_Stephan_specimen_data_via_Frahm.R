# Smaers_etal_2010_Table1_Stephan_specimen_data_via_Frahm.R
#
# Extract the specimen-level values printed in Smaers et al. (2010) Table 1
# and attributed there to H. Frahm's unpublished individual-specific data
# underlying Stephan et al. (1981).
#
# This is not a new independent measurement source. The values became public
# through Smaers et al. (2010), and this file only makes that provenance-rich
# subset explicit for later specimen-level comparison.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).",
       call. = FALSE)
})

folder <- dirname(.sp)
input_file <- file.path(folder, "Smaers_etal_2010_Table1.csv")
output_file <- file.path(
  folder,
  "Smaers_etal_2010_Table1_Stephan_specimen_data_via_Frahm.csv"
)

if (!file.exists(input_file)) {
  stop("Missing input: ", input_file, call. = FALSE)
}

x <- read.csv(
  input_file,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  na.strings = c("", "NA"),
  colClasses = c(catalogue_number = "character")
)

required <- c(
  "species",
  "species_printed",
  "catalogue_number",
  "stephan_unpublished_neopallium_volume_mm3",
  "total_brain_volume_mm3",
  "basal_ganglia_volume_mm3"
)
missing_columns <- setdiff(required, names(x))
if (length(missing_columns)) {
  stop(
    "Input is missing required column(s): ",
    paste(missing_columns, collapse = ", "),
    call. = FALSE
  )
}

# The Table 1 caption attributes the specimen-level Stephan columns to data
# supplied by H. Frahm. Pan paniscus and Pongo pygmaeus have no Stephan
# neopallium or basal-ganglia value; their brain values are explicitly sourced
# to MacLeod et al. (2003), so they do not belong in this extract.
keep <- !is.na(x$stephan_unpublished_neopallium_volume_mm3) |
  !is.na(x$basal_ganglia_volume_mm3)

out <- data.frame(
  specimen_key = paste0(
    x$species[keep],
    "__catalogue_",
    x$catalogue_number[keep]
  ),
  species = x$species[keep],
  species_printed = x$species_printed[keep],
  catalogue_number = x$catalogue_number[keep],
  neopallium_volume_mm3 =
    x$stephan_unpublished_neopallium_volume_mm3[keep],
  total_brain_volume_mm3 = x$total_brain_volume_mm3[keep],
  basal_ganglia_volume_mm3 = x$basal_ganglia_volume_mm3[keep],
  basal_ganglia_definition = ifelse(
    is.na(x$basal_ganglia_volume_mm3[keep]),
    NA_character_,
    "striatum_plus_pallidum"
  ),
  neopallium_provenance =
    "Stephan_unpublished_specimen_data_via_H_Frahm",
  total_brain_provenance =
    "Stephan_unpublished_specimen_data_via_H_Frahm",
  basal_ganglia_provenance = ifelse(
    is.na(x$basal_ganglia_volume_mm3[keep]),
    NA_character_,
    "Stephan_unpublished_specimen_data_via_H_Frahm"
  ),
  underlying_reference = "Stephan_etal_1981",
  publication_source = "Smaers_etal_2010_Table1",
  source_doi = "10.1371/journal.pone.0009123",
  data_status = "published_in_Smaers_etal_2010_from_previously_unpublished_specimen_data",
  stringsAsFactors = FALSE
)

if (nrow(out) != 16L) {
  stop("Expected 16 Stephan/Frahm specimens; found ", nrow(out), ".", call. = FALSE)
}
if (anyDuplicated(out$specimen_key)) {
  stop("specimen_key is not unique.", call. = FALSE)
}
if (anyNA(out$catalogue_number) || any(!nzchar(out$catalogue_number))) {
  stop("Every extracted row must retain its printed specimen number.", call. = FALSE)
}
if (sum(!is.na(out$neopallium_volume_mm3)) != 16L) {
  stop("Expected 16 neopallium values.", call. = FALSE)
}
if (sum(!is.na(out$total_brain_volume_mm3)) != 16L) {
  stop("Expected 16 total-brain values.", call. = FALSE)
}
if (sum(!is.na(out$basal_ganglia_volume_mm3)) != 11L) {
  stop("Expected 11 basal-ganglia values.", call. = FALSE)
}

write.csv(out, output_file, row.names = FALSE, na = "")

message(
  "Wrote ", basename(output_file), ": ", nrow(out), " specimens; ",
  sum(!is.na(out$basal_ganglia_volume_mm3)), " basal-ganglia values."
)
