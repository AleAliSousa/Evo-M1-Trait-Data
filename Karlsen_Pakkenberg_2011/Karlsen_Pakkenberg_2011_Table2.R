## Karlsen & Pakkenberg 2011 - Table 2 : snapshot -> analysis-ready CSV
## The XLSX snapshot preserves the complete published Table 2; this script keeps numeric
## bilateral volume, surface area and cortical thickness for both groups.

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

raw <- as.data.frame(read_excel("Karlsen_Pakkenberg_2011_Table2_snapshot.xlsx", sheet = "Table 2",
                                skip = 3, .name_repair = "minimal"), check.names = FALSE)
raw <- raw[raw$Group %in% c("Control", "DS"), , drop = FALSE]
num <- function(x) suppressWarnings(as.numeric(as.character(x)))
d <- data.frame(
  Region = trimws(raw$Region), Group = trimws(raw$Group),
  Volume.cm3 = num(raw$Volume), Surface.cm2 = num(raw$Surface), Thickness.mm = num(raw$Thickness),
  stringsAsFactors = FALSE)
write.csv(d, "Karlsen_Pakkenberg_2011_Table2.csv", row.names = FALSE, na = "NA")
cat("Table 2:", nrow(d), "analysis-ready rows\n")


## ---- public TSV (database online copy) ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(d, file.path(.td, "10.1093%2Fcercor%2Fbhr033_Table2.tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA", eol = "\n")
}
