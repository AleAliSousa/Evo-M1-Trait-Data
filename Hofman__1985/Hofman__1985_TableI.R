## Hofman MA (1985). Size and shape of the cerebral cortex in mammals. I. The cortical surface.
## Brain Behav Evol 27(1):28-40. Table I (size comparisons of brain structures in 44 mammals; facing pages pp. 30-33).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written as published; harmonisation to the project key happens downstream.
## Table compiled by Hofman from cited sources (refs 1-12; Stephan 1981 and Frahm 1982 are in the repo) -> secondary.
##
## Input : Hofman__1985_TableI_snapshot.csv  (transcribed from the scanned print)
## Output: <script stem>.csv   one row per printed row (44)

options(scipen = 999)
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- sub("_Table1$", "", item_name)             # Hofman__1985_TableI -> Hofman__1985
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers); printed "-" and unprinted blanks -> NA ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA", "-"), colClasses = "character")
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
idx <- trimws(snap[["Index of folding"]])
clean <- data.frame(
  species              = trimws(snap$Mammal),
  group                = trimws(snap$Group),
  brain_volume_cm3     = num(snap[[3]]),
  prosencephalon_volume_cm3 = num(snap[[4]]),
  cortex_volume_gray_cm3    = num(snap[[5]]),
  cortex_volume_gray_white_cm3 = num(snap[[6]]),
  cortex_total_surface_cm2  = num(snap[[7]]),
  cortex_outer_surface_cm2  = num(snap[[8]]),
  cortex_mean_thickness_cm  = num(snap[[9]]),
  index_of_folding     = num(sub("^>\\s*", "", idx)),
  index_of_folding_is_lower_bound = grepl("^>", idx),   # printed '>' = only a lower bound
  reference_numbers    = trimws(snap$References),
  source               = source_name,
  stringsAsFactors = FALSE)
stopifnot(nrow(clean) == 44)
message("rows: ", nrow(clean))

## ---- internal-consistency checks (printed only; nothing is corrected) ----
k <- with(clean, !is.na(cortex_total_surface_cm2) & !is.na(cortex_outer_surface_cm2) & !index_of_folding_is_lower_bound)
chk_idx <- with(clean, round(cortex_total_surface_cm2 / cortex_outer_surface_cm2, 2))
message("index of folding = St/So: ", sum(k), " rows testable, ",
        sum(abs(chk_idx[k] - clean$index_of_folding[k]) > 0.011), " disagree at 2 dp (tol 0.01)")
k2 <- with(clean, !is.na(cortex_volume_gray_cm3) & !is.na(cortex_mean_thickness_cm))
d <- with(clean, cortex_volume_gray_cm3 / cortex_total_surface_cm2)
rel <- abs(d - clean$cortex_mean_thickness_cm) / clean$cortex_mean_thickness_cm
message("thickness = Vg/St: ", sum(k2), " rows testable, ", sum(rel[k2] > 0.03, na.rm = TRUE), " differ by >3%")
print(clean[which(k2 & rel > 0.03), c("species", "cortex_mean_thickness_cm")])

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
