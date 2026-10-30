#!/usr/bin/env Rscript
# Heuer et al. 2023, Diversity and evolution of cerebellar folding in mammals.
# Frozen author release -> analysis CSV + DOI-coded public TSV.

suppressWarnings(suppressMessages(library(readxl)))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  stop("Run with Rscript file.R, or open the saved script in RStudio.", call. = FALSE)
})
paper_dir <- dirname(.sp)
root <- normalizePath(file.path(paper_dir, ".."))
item_name <- "Heuer_etal_2023_Data"

d <- read.csv(file.path(paper_dir, "source_data", "data.csv"),
              stringsAsFactors = FALSE, check.names = FALSE)
required <- c("Microdraw_name", "Binomial_name", "Binomial_name_timetree", "English_name",
              "Provenance", "Log10Area.cb", "Log10Length.cb", "Log10Area.ctx",
              "Log10Length.ctx", "Log10WidthMedian", "Log10PeriodMedian",
              "Log10ThicknessMedian", "Log10BodyWeight", "Log10BrainWeight")
missing <- setdiff(required, names(d))
if (length(missing)) stop("Author data.csv is missing: ", paste(missing, collapse = ", "))

printed <- gsub("_", " ", d$Binomial_name, fixed = TRUE)
# Source-scoped nomenclatural normalization. The paper's name is retained separately.
variants <- c(
  "Canis familiaris" = "Canis lupus familiaris",
  "Chinchilla lanigera" = "Chinchilla laniger",
  "Equus burchellii" = "Equus burchelli",
  "Galictis vittata" = "Galictis vittatus"
)
species_sci <- unname(ifelse(printed %in% names(variants), variants[printed], printed))

pow10 <- function(x) ifelse(is.na(x), NA_real_, 10^as.numeric(x))
out <- data.frame(
  Species_Heuer2023 = printed,
  species_sci = species_sci,
  Binomial_name_timetree = gsub("_", " ", d$Binomial_name_timetree, fixed = TRUE),
  English_name = d$English_name,
  Microdraw_name = d$Microdraw_name,
  Provenance = d$Provenance,
  Cerebellar_section_area_mm2 = pow10(d$Log10Area.cb),
  Cerebellar_section_length_mm = pow10(d$Log10Length.cb),
  Cerebral_section_area_mm2 = pow10(d$Log10Area.ctx),
  Cerebral_section_length_mm = pow10(d$Log10Length.ctx),
  Folial_width_median_mm = pow10(d$Log10WidthMedian),
  Folial_perimeter_median_mm = pow10(d$Log10PeriodMedian),
  Molecular_layer_thickness_median_mm = pow10(d$Log10ThicknessMedian),
  Log10Area_cb_source = d$Log10Area.cb,
  Log10Length_cb_source = d$Log10Length.cb,
  Log10Area_ctx_source = d$Log10Area.ctx,
  Log10Length_ctx_source = d$Log10Length.ctx,
  Log10WidthMedian_source = d$Log10WidthMedian,
  Log10PeriodMedian_source = d$Log10PeriodMedian,
  Log10ThicknessMedian_source = d$Log10ThicknessMedian,
  LogBodyWeight_source = d$Log10BodyWeight,
  LogBrainWeight_source = d$Log10BrainWeight,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

analysis_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
write.csv(out, analysis_csv, row.names = FALSE, na = "NA", fileEncoding = "UTF-8")

encoded <- "10.7554%2FeLife.85907_Data"
registry <- file.path(root, "__ReadMe.xlsx")
if (file.exists(registry)) {
  reg <- tryCatch(read_excel(registry, sheet = "Sheet1"), error = function(e) NULL)
  if (!is.null(reg) && item_name %in% reg$`Item name`) {
    hit <- reg$`Item encoded`[match(item_name, reg$`Item name`)]
    if (!is.na(hit) && nzchar(hit)) encoded <- hit
  }
}
public_dir <- file.path(root, "__Public", "comparative-data")
dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
write.table(out, file.path(public_dir, paste0(encoded, ".tsv")), sep = "\t",
            row.names = FALSE, na = "NA", quote = TRUE, fileEncoding = "UTF-8")

cat(sprintf("Heuer 2023: %d species; %d complete thickness measurements\n",
            nrow(out), sum(!is.na(out$Molecular_layer_thickness_median_mm))))
