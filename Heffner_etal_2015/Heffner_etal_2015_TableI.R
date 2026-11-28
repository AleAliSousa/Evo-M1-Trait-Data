## Heffner_etal_2015_TableI.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2015). Sound localization in
## common vampire bats: Acuity and use of the binaural time cue by a small
## mammal. J Acoust Soc Am 137(1):42-52. doi:10.1121/1.4904529
##
## Source is a born-digital PDF; Table I (8 rows) was transcribed directly,
## cross-checked word-for-word against the extracted text layer.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2015_TableI"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
grid <- read.csv(snapshot_csv, skip = 1, header = FALSE,
                 col.names = c("Species", "Functional head size", "Minimum audible angle", "Highest frequency"),
                 stringsAsFactors = FALSE, check.names = FALSE, colClasses = "character",
                 encoding = "UTF-8", blank.lines.skip = FALSE)
stopifnot(grid$Species[1] == "Species")
num <- function(x) suppressWarnings(as.numeric(x))
ix <- which(!is.na(num(grid[["Functional head size"]])))
stopifnot(length(ix) == 8)
snap <- grid[ix, , drop = FALSE]
## The source prints each common name and binomial in one cell, with a group heading above.
snap$binomial <- sub(".*\\(([^()]*)\\).*", "\\1", snap$Species)
snap$common_name <- sub(" [a-i,]+$", "", sub("\\n.*", "", snap$Species))
groups <- character(nrow(snap))
for (i in seq_along(ix)) {
  previous <- grid$Species[seq_len(ix[i] - 1L)]
  heading <- tail(previous[previous %in% c("Echolocators", "Atypical echolocator", "Non-echolocators")], 1)
  groups[i] <- switch(heading, Echolocators = "Echolocator",
                      `Atypical echolocator` = "Atypical echolocator",
                      `Non-echolocators` = "Non-echolocator")
}
context <- read.csv(file.path(folder, "reference_tables", "Heffner_etal_2015_TableI_analysis_context.csv"),
                    stringsAsFactors = FALSE)
stopifnot(setequal(context$species, snap$binomial))
context <- context[match(snap$binomial, context$species), , drop = FALSE]
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial = snap$binomial,
  common_name = snap$common_name,
  echolocation_group = groups,
  functional_head_size_us = num(snap[["Functional head size"]]),
  minimum_audible_angle_deg = num(snap[["Minimum audible angle"]]),
  phase_cue_used = snap[["Highest frequency"]] != "Cue not used",
  phase_cue_upper_limit_kHz = ifelse(phase_cue_used, num(snap[["Highest frequency"]]), NA_real_),
  data_role = ifelse(snap$binomial == "Desmodus rotundus", "primary", "secondary"),
  source = context$source
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
stopifnot(!is.na(tsv_dir), dir.exists(tsv_dir))
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
hits <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
stopifnot(length(hits) == 1L)
item_encoded <- filecodes$`Item encoded`[hits]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "")
