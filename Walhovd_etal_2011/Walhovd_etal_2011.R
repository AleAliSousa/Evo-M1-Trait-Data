## Walhovd et al. 2011 - normative volumes : snapshot -> derived
## Snapshot = normative regional volume table (Overall N=262 + Female/Male, mean/SD, voxel mm3).
## Derived = numeric long-friendly table (all structures; Overall mean/SD retained), analysis-amenable.

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

snap <- read.csv("Walhovd_etal_2011_normative_snapshot.csv", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))
d <- data.frame(
  Structure = trimws(snap$Structure),
  Overall_N262_mean.mm3 = num(snap$Overall_N262_mean.mm3),
  Overall_N262_SD.mm3   = num(snap$Overall_N262_SD.mm3),
  Female_N154_mean.mm3  = num(snap$Female_N154_mean.mm3),
  Female_N154_SD.mm3    = num(snap$Female_N154_SD.mm3),
  Male_N108_mean.mm3    = num(snap$Male_N108_mean.mm3),
  Male_N108_SD.mm3      = num(snap$Male_N108_SD.mm3),
  stringsAsFactors = FALSE)
write.csv(d, "Walhovd_etal_2011_derived.csv", row.names = FALSE)
cat("derived:", nrow(d), "structures\n")


## ---- public TSV (database "online" copy) : regenerate from the derived table ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(read.csv("Walhovd_etal_2011_derived.csv", check.names = FALSE),
              file.path(.td, "10.1016%2Fj.neurobiolaging.2009.05.013_normative.tsv"), sep = "\t", row.names = FALSE)
}
