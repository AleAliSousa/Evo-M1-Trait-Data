## Karlsen & Pakkenberg 2011 - reported values (published Results text) : snapshot -> derived
## Values stated verbatim in the paper's Results text, incl. BASAL GANGLIA cell numbers/densities
## (which the neocortical counting workbooks do not cover) and a few cortical density values.
## Derived = numeric long table (drop non-numeric), analysis-amenable, WITH one documented correction
## of a published error (see section 3) so downstream analysis uses the correct value.

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
folder <- dirname(.sp); item_name <- "Karlsen_Pakkenberg_2011_reported_values"
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder); options(scipen = 999, stringsAsFactors = FALSE)

## 1. READ SNAPSHOT (faithful to the published text; keeps the erroneous value)
s <- read.csv("Karlsen_Pakkenberg_2011_reported_values_snapshot.csv", check.names = FALSE)
s$Value <- suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(s$Value)))))
s <- s[!is.na(s$Value), ]

## 2. add a Correction_note column (blank unless a cell is corrected below)
s$Correction_note <- ""

## 3. CORRECT A KNOWN PUBLISHED ERROR (documented; snapshot keeps the original)
## The paper's control temporal-cortex astrocyte density is reported as 46.7 x10^6/cm3. This value is
## wrong: (a) it is exactly 2x the value in the authors' own counting records (23.13 x10^6/cm3);
## (b) 46.7 would make astrocytes 53% of temporal glial density (88.6), contradicting the paper's OWN
## stated glial composition (astrocytes ~29% of glia); 23.13 gives ~26%, consistent with the paper.
## We therefore replace 46.7 with 23.13 so downstream analysis is correct. (DS temporal astrocyte
## 85.9 is left as published: it could not be independently verified - the authors' DS records are the
## pre-correction version - so it is flagged, not changed.)
row_err <- which(s$Region == "Temporal" & s$Group == "Control" & s$Measure == "Astrocyte_density")
stopifnot(length(row_err) == 1)
cat("BEFORE correction: Temporal/Control/Astrocyte_density =", s$Value[row_err], "\n")
s$Value[row_err] <- 23.13
s$Correction_note[row_err] <- "Corrected from published 46.7 (2x error; see ReadMe). Value = authors' record 23.13; restores 29% astrocyte fraction."
cat("AFTER  correction: Temporal/Control/Astrocyte_density =", s$Value[row_err], "\n")

## flag (do not change) the DS counterpart as unverified
row_ds <- which(s$Region == "Temporal" & s$Group == "DS" & s$Measure == "Astrocyte_density")
if (length(row_ds) == 1) s$Correction_note[row_ds] <- "Published 85.9 kept as-is; not independently verifiable (DS records are pre-correction). Use with caution."

## 4. SAVE derived (USE THIS) + online TSV
write.csv(s, "Karlsen_Pakkenberg_2011_reported_values_derived.csv", row.names = FALSE)
if (!is.na(base)) {
  td <- file.path(base, "__Public", "comparative-data"); if (!dir.exists(td)) dir.create(td, recursive = TRUE)
  write.table(s, file.path(td, "10.1093%2Fcercor%2Fbhr033_reportedvalues.tsv"), sep = "\t", row.names = FALSE)
}
cat("reported_values derived:", nrow(s), "numeric rows; regions:", paste(unique(s$Region), collapse=", "), "\n")
