## Heffner__1998_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, H. E. (1998). Auditory awareness. Applied Animal Behaviour
## Science 57(3-4):259-268. doi:10.1016/S0168-1591(98)00101-4
##
## Source is a born-digital PDF; Table 1 (19 rows) was transcribed directly.
## Four bird rows print a less-than bound on the low-frequency limit ("< 250"
## etc.; page image read 2026-09-29) -- carried as value + qualifier column.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner__1998_Table1"
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
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                  colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 19)

binomial_map <- c(
  "Laboratory mouse" = "Mus musculus", "Cat" = "Felis catus",
  "Laboratory rat" = "Rattus norvegicus", "Rabbit" = "Oryctolagus cuniculus",
  "Guinea pig" = "Cavia porcellus", "Dog" = "Canis lupus familiaris",
  "Sheep" = "Ovis aries", "Pig" = "Sus scrofa domesticus",
  "Goat" = "Capra hircus", "Cattle" = "Bos taurus",
  "Horse" = "Equus caballus", "Chinchilla" = "Chinchilla lanigera",
  "Human" = "Homo sapiens", "Canary" = "Serinus canaria domestica",
  "Budgerigar" = "Melopsittacus undulatus", "Zebra finch" = "Taeniopygia guttata",
  "Turkey" = "Meleagris gallopavo", "Pigeon" = "Columba livia",
  "Mallard duck" = "Anas platyrhynchos"
)
## Four bird low-frequency-limit cells extract from the text layer with a
## leading minus sign ("-250", "-250", "-125", "-300"). The page image of
## Table 1 (p. 261) was read on 2026-09-29: the printed glyph is a LESS-THAN
## sign -- "< 250", "< 250", "< 125", "< 300" -- i.e. the low limit is below
## the lowest frequency tested. (Until then these cells were left blank on
## the assumption the glyph was ">"; see reference_tables/Heffner__1998_errata.csv
## E001-E004.) The snapshot keeps the literal extraction; here the sign is
## decoded to the bound with a qualifier column, so the value is usable and
## its meaning is explicit.
bird_less_than <- c("Zebra finch", "Turkey", "Pigeon", "Mallard duck")

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(x))
lf_raw <- snap$`Low-frequency limit (Hz) as extracted`
lf_is_lt <- snap$Animal %in% bird_less_than
stopifnot(all(grepl("^-", lf_raw[lf_is_lt])), !any(grepl("^-", lf_raw[!lf_is_lt])))
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  common_name = snap$Animal,
  binomial    = unname(binomial_map[snap$Animal]),
  low_frequency_limit_Hz = num(sub("^-", "", lf_raw)),
  low_frequency_limit_qualifier = ifelse(lf_is_lt, "<", ""),
  high_frequency_limit_Hz = num(snap$`High-frequency limit (Hz)`),
  best_sensitivity_dB = num(snap$`Best sensitivity (dB)`),
  best_frequency_Hz = num(snap$`Best frequency (Hz)`),
  data_role = "secondary"
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
