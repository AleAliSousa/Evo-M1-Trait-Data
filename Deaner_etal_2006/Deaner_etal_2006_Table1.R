## Deaner, van Schaik & Johnson 2006, Evol Psychol 4:149-196 — Table 1 (the full data set)
## doi:10.1177/147470490600400114 · "Do some taxa have better domain-general cognition than
## others? A meta-analysis of nonhuman primate studies."
## 24 primate GENERA × 30 experimental procedures; 113 filled cells; rank values (lower =
## better; fractional = ties). Paradigm→procedure mapping from the paper's sections AND the
## printed grid borders (image-verified): DP=1-3, PS=4, ID=5-7, TU=8-9, DL=10-17, RL=18-23,
## OD=24-26, SO=27, DR=28-30 (procedure 26 is described inside the Oddity section).
## SECONDARY (meta-analysis): per-procedure primary studies are cited in the paper's text.
## Largely overlaps Johnson_etal_2002_Table1 (same Deaner/Johnson/van Schaik lineage) — never
## treat the two as independent. Extracted via pdftotext -bbox word coordinates (each value
## assigned to its nearest procedure-column center), spot-verified against the page image.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))              # Deaner_etal_2006_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "Table1"))
stopifnot(nrow(raw) == 24, ncol(raw) == 31)
para <- c(rep("detour problems (DP)", 3), "patterned-string problems (PS)",
          rep("invisible displacement (ID)", 3), rep("tool use (TU)", 2),
          rep("object discrimination learning set (DL)", 8), rep("reversal learning (RL)", 6),
          rep("oddity learning (OD)", 3), "sorting (SO)", rep("delayed response (DR)", 3))
stopifnot(length(para) == 30)
note <- paste0("lower rank = better performance; ties fractional; genus-level meta-analysis ",
               "ranks - SECONDARY (per-procedure primary studies cited in the paper's text ",
               "sections); overlaps Johnson_etal_2002_Table1 (same lineage) - never independent")
long <- do.call(rbind, lapply(seq_len(nrow(raw)), function(i) {
  v <- suppressWarnings(as.numeric(raw[i, 2:31]))
  k <- which(!is.na(v))
  if (!length(k)) return(NULL)
  data.frame(Genus = raw$GENUS[i], procedure = k, paradigm = para[k], rank = v[k],
             note = note, source = item_name, stringsAsFactors = FALSE)
}))
long <- long[order(match(long$Genus, raw$GENUS), long$procedure), ]
stopifnot(nrow(long) == 113)
write.csv(long, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(long), " genus x procedure rows written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(long, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
