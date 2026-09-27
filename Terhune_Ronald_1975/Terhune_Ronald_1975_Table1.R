## Terhune_Ronald_1975_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Terhune, J. M., & Ronald, K. (1975). Underwater hearing sensitivity of
## two ringed seals (Pusa hispida). Canadian Journal of Zoology, 53(3),
## 227-231. doi:10.1139/z75-028
##
## Source is a scanned/OCR'd photocopy (NRC Research Press reprint); the
## extracted text layer for Table 1 (a two-subject, multi-column table) was
## garbled into unusable placeholder characters. Table 1 (15 frequencies x 2
## subjects, printed p. 229) was therefore transcribed by hand from a 200
## dpi render of PDF page 3 and cross-checked digit-by-digit against the
## rendered image before writing the snapshot.
##
## NOTE ON SPECIES: this folder name (Terhune_Ronald_1975) could be
## mistaken for a harp-seal companion piece to Terhune_Ronald_1972, but this
## paper is actually about a DIFFERENT species -- the ringed seal, Pusa
## hispida (two subjects: one adult female, one adult male) -- not the harp
## seal (Pagophilus groenlandicus) of the 1972 paper. Confirmed from the
## title, abstract, and body text.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Terhune_Ronald_1975_Table1"
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
                  colClasses = "character", encoding = "UTF-8", skip = 1)
stopifnot(nrow(snap) == 15)

## 3. CLEAN -----------------------------------------------------------
## The 90-kHz row's female threshold and SD are printed in parentheses --
## "(+18)" and "(5.1)" -- flagging them as an estimate the authors marked
## as less certain (see README). Reshape wide (female/male columns) to
## long (one row per sex x frequency), matching house style.
strip_paren <- function(x) as.numeric(gsub("[()+]", "", x))
is_paren    <- function(x) grepl("^\\(", x)

wide <- tibble(
  frequency_khz = as.numeric(snap$`Frequency (kHz)`),
  thr_female = strip_paren(snap$`Threshold female (dB re 1 µbar)`),
  thr_male   = strip_paren(snap$`Threshold male (dB re 1 µbar)`),
  sd_female  = strip_paren(snap$`SD female (dB)`),
  sd_male    = strip_paren(snap$`SD male (dB)`),
  catch_female = as.numeric(snap$`Catch trials % correct female`),
  catch_male   = as.numeric(snap$`Catch trials % correct male`),
  female_is_parenthetical = is_paren(snap$`Threshold female (dB re 1 µbar)`)
)

long_female <- wide %>%
  transmute(sex = "female", frequency_khz,
            threshold_db_re_1ubar = thr_female, sd_db = sd_female,
            catch_trials_pct_correct = catch_female,
            value_is_parenthetical_estimate = female_is_parenthetical)
long_male <- wide %>%
  transmute(sex = "male", frequency_khz,
            threshold_db_re_1ubar = thr_male, sd_db = sd_male,
            catch_trials_pct_correct = catch_male,
            value_is_parenthetical_estimate = FALSE)

final.dataframe <- bind_rows(long_female, long_male) %>%
  arrange(frequency_khz, sex) %>%
  mutate(determination_row = row_number(), .before = 1) %>%
  mutate(subject_species = "Pusa hispida (ringed seal)",
         data_role = "primary", source = "this study")

## Sanity check: text states lowest threshold was -32 db re 1 µbar at 16 kHz
## -- matches the female subject's tied minimum at 11.3 and 16 kHz.
stopifnot(min(final.dataframe$threshold_db_re_1ubar) == -32)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
