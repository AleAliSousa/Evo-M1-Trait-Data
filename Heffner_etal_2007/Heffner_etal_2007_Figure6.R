## Heffner_etal_2007_Figure6.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2007). Sound-localization
## acuity and its relation to vision in large and small fruit-eating bats: I.
## Echolocating species, Phyllostomus hastatus and Carollia perspicillata.
## Hearing Research 234:1-9. doi:10.1016/j.heares.2007.06.001
##
## Fig. 6 (p. 7) is a scatterplot of sound-localization threshold vs. width
## of the field of best vision (FBV) for the five bat species studied to date
## plus many other mammals, all shown as unlabeled points on a log-log plot.
## Per house rules (prefer text/table over digitizing a figure), this paper's
## own Discussion/Results text (checked first, as instructed) explicitly
## states the FBV width, in degrees, for its own two NEW species only:
##   - Phyllostomus hastatus: "The width of the field of best vision for this
##     species ... is 51." (p. 5-6)
##   - Carollia perspicillata: "... a region 110 wide." (p. 6)
## These two rows are PRIMARY data (this paper's own retinal measurement) and
## were not digitized.
##
## The remaining four species that SensoryData_compiled also attributes to
## this registry item (Artibeus jamaicensis 34 deg, Chinchilla laniger 144
## deg, Marmota monax 90.2 deg, Rousettus aegyptiacus 27 deg) are NOT stated
## numerically anywhere in this paper's text -- they appear only as unlabeled
## comparison points in the Fig. 6 scatterplot, carried over from other
## papers (Artibeus: Heffner et al., 2001a; Chinchilla: Heffner and Heffner,
## 1992b; the exact source papers for Marmota monax and Rousettus aegyptiacus
## FBV width are not identified anywhere in this PDF's text or reference
## list). These four values were NOT independently re-derived or digitized
## from the scatterplot for this build; they are carried forward from
## SensoryData_compiled's existing compilation (already trusted elsewhere in
## this registry) for continuity, and are marked "secondary" / not
## text-verified. See README for full discussion.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2007_Figure6"
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
stopifnot(nrow(snap) == 6)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  field_of_best_vision_width_deg = as.numeric(snap$`Field of best vision width (deg)`),
  stated_in_this_papers_text = grepl("^Yes", snap$`Stated in this paper's text`),
  data_role = ifelse(snap$`Data role` == "this study", "primary", "secondary"),
  source = snap$Source
)

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
