## Karlsen & Pakkenberg 2011 - reported values (published Results text) : snapshot -> derived
## Values stated verbatim in the paper's Results text, incl. BASAL GANGLIA cell numbers/densities
## (which the author neocortical workbooks do not cover) and a few cortical density values.
## Derived = numeric long table (drop non-numeric), analysis-amenable.

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

s <- read.csv("Karlsen_Pakkenberg_2011_reported_values_snapshot.csv", check.names = FALSE)
s$Value <- suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(s$Value))))); s <- s[!is.na(s$Value), ]
write.csv(s, "Karlsen_Pakkenberg_2011_reported_values_derived.csv", row.names = FALSE)
if (!is.na(base)) {
  td <- file.path(base, "__Public", "comparative-data"); if (!dir.exists(td)) dir.create(td, recursive = TRUE)
  write.table(s, file.path(td, "10.1093%2Fcercor%2Fbhr033_reportedvalues.tsv"), sep = "\t", row.names = FALSE)
}
cat("reported_values derived:", nrow(s), "numeric rows; regions:", paste(unique(s$Region), collapse=", "), "\n")
