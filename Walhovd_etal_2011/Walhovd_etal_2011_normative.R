## Walhovd et al. 2011 - Table 3 normative volumes
## Complete published Table 3 snapshot -> 18-29-year overall/female/male analysis table.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source.", call. = FALSE)
})
folder <- dirname(.sp)
setwd(folder)
options(scipen = 999, stringsAsFactors = FALSE)
suppressMessages(library(readxl))

snapshot <- "Walhovd_etal_2011_normative_snapshot.xlsx"
M <- as.matrix(read_excel(snapshot, sheet = "Table 3", col_names = FALSE,
                          .name_repair = "minimal"))
M[is.na(M)] <- ""
source_labels <- c(
  "Cerebral Cor", "Cerebral WM", "Lat Vent", "Inf Lat Vent", "Cerebel WM",
  "Cerebel Cor", "Thalamus", "Caudate", "Putamen", "Pallidum", "Hippocampus",
  "Amygdala", "Accumbens", "3rd Vent", "4th Vent", "Brainstem", "CSF",
  "Total volume", "ICV"
)
output_labels <- c(
  "Cerebral Cortex (GM)", "Cerebral WM", "Lateral Ventricle",
  "Inferior Lateral Ventricle", "Cerebellum WM", "Cerebellum Cortex", "Thalamus",
  "Caudate", "Putamen", "Pallidum", "Hippocampus", "Amygdala", "Accumbens",
  "3rd Ventricle", "4th Ventricle", "Brain Stem", "CSF", "Total volume", "ICV"
)

extract_section <- function(label) {
  section <- which(M[, 1] == label)
  if (length(section) != 1L) stop("Expected one section row for '", label, "'.", call. = FALSE)
  start <- section + 3L
  rows <- start:(start + length(source_labels) - 1L)
  observed <- trimws(M[rows, 1])
  if (!identical(observed, source_labels)) {
    stop("Unexpected structure order in section '", label, "'.", call. = FALSE)
  }
  data.frame(
    Structure_source = observed,
    Mean = suppressWarnings(as.numeric(M[rows, 2])),
    SD = suppressWarnings(as.numeric(M[rows, 3])),
    stringsAsFactors = FALSE
  )
}

overall <- extract_section("Total sample (N = 883)")
female <- extract_section("Females (N = 528)")
male <- extract_section("Males (N = 355)")
final <- data.frame(
  Structure = output_labels,
  Overall_N262_mean.mm3 = overall$Mean,
  Overall_N262_SD.mm3 = overall$SD,
  Female_N154_mean.mm3 = female$Mean,
  Female_N154_SD.mm3 = female$SD,
  Male_N108_mean.mm3 = male$Mean,
  Male_N108_SD.mm3 = male$SD,
  stringsAsFactors = FALSE,
  check.names = FALSE
)
if (anyNA(final[-1])) stop("Walhovd Table 3 parsing produced missing numeric values.", call. = FALSE)
write.csv(final, "Walhovd_etal_2011_normative.csv", row.names = FALSE, na = "NA")

root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (!is.na(root)) {
  tsv <- file.path(root, "__Public", "comparative-data",
                   "10.1016%2Fj.neurobiolaging.2009.05.013_normativevolumes.tsv")
  write.table(final, tsv, sep = "\t", row.names = FALSE, quote = TRUE, na = "NA", eol = "\n")
}
cat("Wrote", nrow(final), "structures from the 18-29-year Table 3 columns.\n")
