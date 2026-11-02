## Morgan et al. 2014 - Data S1 : snapshot -> analysis-ready CSV
## Snapshot = the originally published PLoS ONE Data S1 spreadsheet (Morgan_etal_2014_DataS1_snapshot.xlsx),
## verbatim. The clean CSV keeps per-individual data rows only (drops Mean/SD/note rows),
## all measured columns coerced numeric. Both groups (ASD, Control) kept.

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
folder <- dirname(.sp); setwd(folder); options(scipen = 999, stringsAsFactors = FALSE)
suppressMessages(library(readxl))

snap <- read_excel("Morgan_etal_2014_DataS1_snapshot.xlsx", sheet = "Final Data Clean")
df <- snap[snap$Diagnosis %in% c("ASD", "Control"), ]          # per-individual rows only
## coerce all non-identifier columns to numeric
idcols <- c("Case","Diagnosis","Hemisphere")
for (cc in setdiff(names(df), idcols)) df[[cc]] <- suppressWarnings(as.numeric(df[[cc]]))
write.csv(df, "Morgan_etal_2014_DataS1.csv", row.names = FALSE, na = "NA")
cat(sprintf("Data S1: %d individuals (%d Control, %d ASD), %d columns\n",
            nrow(df), sum(df$Diagnosis == "Control"), sum(df$Diagnosis == "ASD"), ncol(df)))


## ---- public TSV (database online copy) ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(df, file.path(.td, "10.1371%2Fjournal.pone.0110356_DataS1.tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA", eol = "\n")
}
