## Karlsen & Pakkenberg 2011 - Table 2 (published) : snapshot -> derived
## Table 2 = mean bilateral volumes (cm3), surface (cm2), thickness (mm) per neocortical region,
## Control vs DS, with CV and 2p columns (published). Derived = numeric Volume/Surface/Thickness only.

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

raw <- read.csv("Karlsen_Pakkenberg_2011_Table2_snapshot.csv", check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(as.character(x)))
d <- data.frame(
  Region = trimws(raw$Region), Group = trimws(raw$Group),
  Volume.cm3 = num(raw$Volume.cm3), Surface.cm2 = num(raw$Surface.cm2), Thickness.mm = num(raw$Thickness.mm),
  stringsAsFactors = FALSE)
write.csv(d, "Karlsen_Pakkenberg_2011_Table2_derived.csv", row.names = FALSE)
cat("Table2 derived:", nrow(d), "rows\n")


## ---- public TSV (database "online" copy) : regenerate from the derived table ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(read.csv("Karlsen_Pakkenberg_2011_Table2_derived.csv", check.names = FALSE),
              file.path(.td, "10.1093%2Fcercor%2Fbhr033_Table2.tsv"), sep = "\t", row.names = FALSE)
}
