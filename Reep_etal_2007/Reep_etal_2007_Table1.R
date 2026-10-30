## Reep RL, Finlay BL, Darlington RB (2007). The limbic system in
## mammalian brain evolution. Brain Behav Evol 70(1):57-70. Table 1.
## DOI 10.1159/000101491.
##
## Frozen printed-table snapshot -> analysis CSV -> DOI-coded public TSV.

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(stringr)
})

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source.", call. = FALSE)
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv <- paste0(item_name, ".csv")
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

pos <- c(
  "order", "family", "common_name", "species", "specimen_number",
  "medulla_mm3", "cerebellum_mm3", "mesencephalon_mm3",
  "diencephalon_mm3", "striatum_mm3", "septum_mm3", "amygdala_mm3",
  "paleocortex_mm3", "hippocampus_mm3", "schizocortex_mm3", "isocortex_mm3"
)
volume_cols <- pos[6:16]
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a."))

raw <- read_excel(snapshot_xlsx, sheet = "Table1", col_names = FALSE, col_types = "text")
dat <- raw[-c(1, 2), seq_along(pos), drop = FALSE]
names(dat) <- pos

clean <- dat %>%
  filter(!is.na(num(medulla_mm3))) %>%
  mutate(
    across(all_of(c("order", "family", "common_name", "species", "specimen_number")), str_squish),
    across(all_of(volume_cols), num),
    source = "Reep_etal_2007"
  ) %>%
  select(all_of(pos), source)

stopifnot(nrow(clean) == 29L)
stopifnot(n_distinct(clean$species) == 29L)
stopifnot(n_distinct(clean$specimen_number) == 29L)
stopifnot(sum(is.na(clean[volume_cols])) == 0L)
stopifnot(sum(vapply(clean[volume_cols], function(x) sum(x <= 0), integer(1))) == 0L)

write_csv(clean, output_csv, na = "NA")

if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
    stop("Registry item missing or uncached in __ReadMe.xlsx: ", item_name, call. = FALSE)
  }
  expected <- "10.1159%2F000101491_Table1"
  if (!identical(item_encoded, expected)) {
    stop("Unexpected registry encoding for ", item_name, ": ", item_encoded,
         " (expected ", expected, ")", call. = FALSE)
  }
  public_dir <- file.path(base, "__Public", "comparative-data")
  dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(clean, file.path(public_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
}

message("Reep Table 1: 29 species x 11 regional volumes; 319/319 cells present.")

