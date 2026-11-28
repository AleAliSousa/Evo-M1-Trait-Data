## Heffner__2004_TABLE1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S. (2004). Primate hearing from a mammalian perspective.
## Anat Rec A 281A(1):1111-1122. doi:10.1002/ar.a.20117
##
## IMAGE-VERIFIED: the PDF text layer fuses footnote superscripts into
## numeric cells and silently drops several minus signs on "best
## sensitivity" values. Every one of the 19 rows was re-read from a
## 300-dpi render of PDF page 3 rather than transcribed from the raw text
## layer (see README for the full list of corrections).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner__2004_TABLE1"
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
source_grid <- read.csv(snapshot_csv, skip = 2L, header = FALSE, nrows = 19L,
                        col.names = c("Species", "High-frequency limit (kHz)",
                                      "Low-frequency limit (kHz)", "Best frequency (kHz)",
                                      "Best sensitivity (dB)", "Hearing range (octaves)"),
                        stringsAsFactors = FALSE, check.names = FALSE,
                        colClasses = "character", na.strings = NULL, encoding = "UTF-8")
marker <- function(x) {
  z <- sub("^.*([¹²³⁴])$", "\\1", x)
  z[!grepl("[¹²³⁴]$", x)] <- ""
  out <- unname(c("¹"="1", "²"="2", "³"="3", "⁴"="4")[z])
  out[is.na(out)] <- ""
  out
}
value <- function(x) sub("[¹²³⁴]$", "", x)
snap <- data.frame(Species = value(source_grid[[1]]),
                   `Footnote on species` = marker(source_grid[[1]]),
                   `High-frequency limit (kHz)` = value(source_grid[[2]]),
                   `HF footnote` = marker(source_grid[[2]]),
                   `Low-frequency limit (kHz)` = value(source_grid[[3]]),
                   `LF footnote` = marker(source_grid[[3]]),
                   `Best frequency (kHz)` = value(source_grid[[4]]),
                   `BF footnote` = marker(source_grid[[4]]),
                   `Best sensitivity (dB)` = value(source_grid[[5]]),
                   `BS footnote` = marker(source_grid[[5]]),
                   `Hearing range (octaves)` = value(source_grid[[6]]),
                   `Range footnote` = marker(source_grid[[6]]), check.names = FALSE)
foot <- read.csv(foot_csv, stringsAsFactors = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 19)
footkey <- setNames(foot$text_as_printed, foot$footnote)

common_map <- c(
  "Lemur catta" = "Ring-tailed lemur", "Eulemur fulvus" = "Brown lemur",
  "Nyctecebus coucang" = "Slow loris", "Perodicticus potto" = "Potto",
  "Galago senegalensis" = "Lesser bushbaby", "Callithrix jacchus" = "Common marmoset",
  "Saimiri sciureus" = "Squirrel monkey", "Aotus trivirgatus" = "Owl monkey",
  "Erythrocebus patas" = "Patas monkey", "Macaca fascicularis" = "Cynomolgus macaque",
  "Macaca fuscata" = "Japanese macaque", "Macaca mulatta" = "Rhesus macaque",
  "Macaca nemestrina" = "Pig-tailed macaque", "Cercopithecus aethiops" = "Vervet monkey",
  "Cercopithecus mitis" = "Blue monkey", "Cercopithecus neglectus" = "DeBrazza's monkey",
  "Papio cynocephalus" = "Yellow baboon", "Pan troglodytes" = "Chimpanzee",
  "Homo sapiens" = "Human"
)
ft <- function(x) unname(ifelse(nzchar(x), footkey[x], ""))

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(ifelse(x == "", NA, x)))
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  common_name = unname(common_map[snap$Species]),
  binomial    = snap$Species,
  species_footnote = snap$`Footnote on species`,
  species_footnote_text = ft(snap$`Footnote on species`),
  high_frequency_limit_kHz = num(snap$`High-frequency limit (kHz)`),
  hf_footnote = snap$`HF footnote`, hf_footnote_text = ft(snap$`HF footnote`),
  low_frequency_limit_kHz = num(snap$`Low-frequency limit (kHz)`),
  lf_footnote = snap$`LF footnote`, lf_footnote_text = ft(snap$`LF footnote`),
  best_frequency_kHz = num(snap$`Best frequency (kHz)`),
  bf_footnote = snap$`BF footnote`, bf_footnote_text = ft(snap$`BF footnote`),
  best_sensitivity_dB = num(snap$`Best sensitivity (dB)`),
  bs_footnote = snap$`BS footnote`, bs_footnote_text = ft(snap$`BS footnote`),
  hearing_range_octaves = num(snap$`Hearing range (octaves)`),
  range_footnote = snap$`Range footnote`, range_footnote_text = ft(snap$`Range footnote`),
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
