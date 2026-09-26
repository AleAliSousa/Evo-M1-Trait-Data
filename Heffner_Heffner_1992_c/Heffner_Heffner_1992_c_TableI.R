## Heffner_Heffner_1992_c_TableI.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1992). Hearing and sound localization
## in blind mole rats (Spalax ehrenbergi). Hearing Research 62(2):206-216.
## doi:10.1016/0378-5955(92)90188-S
##
## Source is a SCANNED PDF (OCR text layer). Table I (17 rows) was
## transcribed and cross-checked against the paper's own prose discussion
## of the same figures (see README).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1992_c_TableI"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
foot_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_footnotes.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                  colClasses = "character", encoding = "UTF-8")
foot <- read.csv(foot_csv, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 17)
footkey <- setNames(foot$text_as_printed, as.character(foot$footnote))

## known, confirmable binomials only (see README for what was NOT resolved)
binomial_map <- c(
  "Groundhog" = "Marmota monax", "Guinea pig" = "Cavia porcellus",
  "Chinchilla" = "Chinchilla lanigera", "Blind mole rat" = "Spalax ehrenbergi",
  "Naked mole rat" = "Heterocephalus glaber", "Pocket gopher" = "Geomys bursarius",
  "Norway rat" = "Rattus norvegicus", "Darwin's mouse" = "Phyllotis darwini",
  "Spiny mouse" = "Acomys cahirinus", "House mouse (wild)" = "Mus musculus"
)

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(x))
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  common_name = snap$Animal,
  binomial    = unname(binomial_map[snap$Animal]),
  rodent_group = paste0(snap$Group, " (based on 60-dB low-frequency limit)") |>
                 str_remove(" \\(based.*\\)") ,  # keep printed group label only
  low_frequency_limit_kHz  = num(snap$`Low-frequency limit (kHz)`),
  high_frequency_limit_kHz = num(snap$`High-frequency limit (kHz)`),
  best_frequency_kHz       = num(snap$`Best frequency (kHz)`),
  lowest_threshold_dB      = num(snap$`Lowest threshold (dB)`),
  data_role = ifelse(snap$Animal == "Blind mole rat", "primary", "secondary"),
  source = unname(footkey[snap$Footnote])
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
