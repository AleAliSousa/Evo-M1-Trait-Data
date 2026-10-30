## Glendenning_Masterton_1998_Table1.R -- frozen snapshot -> analysis CSV + public TSV
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 1 (p. 62, printed rotated): in vitro volumes (mm3) of the 10 largest
## ascending auditory nuclei in 53 mammals (one specimen per species), with
## body and brain weights (g) and the printed 10-nucleus total. Methods (p. 61):
## each nucleus was measured on BOTH sides and "The left and right volumes for
## each nucleus were then averaged" -- so the printed volumes are UNILATERAL
## (mean of left and right). Body weights in parentheses are estimates from
## Nowak [1991] (secondary); bat body/brain courtesy of D. Wong.
##
## Frozen source: Glendenning_Masterton_1998_Table1_snapshot.csv, written by
## Glendenning_Masterton_1998_extract_snapshot.py from the born-digital text
## layer (word coordinates; no values typed) and checked against page renders.
## No __ReadMe.xlsx row yet: Item encoded derived by the house convention.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Glendenning_Masterton_1998_Table1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed names carry Greek/µ/’)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, colClasses = "character", encoding = "UTF-8", check.names = FALSE)
nuc <- c("AVCN", "PVCN", "DCN", "MTB", "LSO", "MSO", "VLL", "DLL", "IC", "MG")
stopifnot(nrow(snap) == 53L,
          identical(names(snap), c("Animal No.", "Common name", "Genus and species", "Source",
                                   "Body gm", "Brain gm", nuc, "Total")))
num <- function(x) suppressWarnings(as.numeric(gsub("[(),]", "", x)))   # "5,000" / "(580)"

## 3. TABLE CHECKS (HOWTO 7a): 10 nuclei summed vs printed Total --------
hu <- function(x) { d <- nchar(sub("^[^.]*\\.?", "", x)); ifelse(nzchar(x), 0.5 * 10^(-d), 0) }
vol <- sapply(nuc, function(k) num(snap[[k]]))
tot <- num(snap$Total)
tl  <- rowSums(sapply(nuc, function(k) hu(snap[[k]]))) + hu(snap$Total)
obs <- rowSums(vol)
table_checks <- data.frame(
  check_id   = paste0("total_", snap$`Animal No.`, "_", snap$`Common name`),
  basis      = "sum of the 10 printed nuclear volumes vs printed Total (mm3)",
  observed   = round(obs, 4), printed = tot, difference = round(obs - tot, 4),
  tolerance  = round(tl, 4),
  status     = ifelse(abs(obs - tot) <= tl + 1e-9, "pass", "mismatch"),
  note       = "tolerance = half a unit of each summed cell's last printed digit",
  stringsAsFactors = FALSE)
bad <- table_checks[table_checks$status == "mismatch", ]
print(bad[, c("check_id", "observed", "printed", "difference", "tolerance")], row.names = FALSE)
if (nrow(bad)) warning(nrow(bad), " Table 1 row totals do not match the summed nuclei -- kept as printed (see errata).",
                       call. = FALSE)

## 4. CLEAN ------------------------------------------------------------
## Project units: body g (as printed); brain g x 1000 -> mg; volumes mm3 (as printed).
## Printed volumes are the mean of left and right sides (unilateral);
## *_bilateral_mm3 = 2 x printed value, the combined-sides merge unit (HOWTO 6).
final.dataframe <- tibble(
  animal_no             = as.integer(snap$`Animal No.`),
  common_name_as_printed = snap$`Common name`,
  species_as_printed    = snap$`Genus and species`,
  species               = resolve(snap$`Genus and species`),
  specimen_source       = snap$Source,
  body_mass_g           = num(snap$`Body gm`),
  body_mass_estimated_Nowak1991 = ifelse(grepl("^\\(", snap$`Body gm`), "yes", "no"),
  brain_mass_mg         = num(snap$`Brain gm`) * 1000,
  body_brain_source_note = ifelse(snap$`Common name` == "Bat, little brown",
                                  "body and brain weight estimate courtesy of Dr. Donald Wong (Table 1 footnote)", "")
)
for (k in nuc) final.dataframe[[paste0(k, "_unilateral_mm3")]] <- num(snap[[k]])
final.dataframe$total10_unilateral_mm3 <- tot
for (k in nuc) final.dataframe[[paste0(k, "_bilateral_mm3")]] <- 2 * num(snap[[k]])
final.dataframe$total10_check <- table_checks$status
final.dataframe$data_role <- "primary"
stopifnot(sum(is.na(final.dataframe$brain_mass_mg)) == 2L,      # Chinchilla, Mink printed blank
          !anyNA(final.dataframe$body_mass_g), !anyNA(final.dataframe$species))

## WRITE CSV + PUBLIC TSV ---------------------------------------------
## No __ReadMe.xlsx row yet: Item encoded is derived by the house convention
## (url-encoded DOI + "_" + compacted Item number) and, once the owner pastes
## the registry row, must equal the registry value (checked below).
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
doi <- "10.1159/000006530"
expected_encoded <- paste0(utils::URLencode(doi, reserved = TRUE), "_", sub("^.*_", "", item_name))
item_encoded <- expected_encoded
if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  ix <- match(item_name, filecodes$`Item name`)
  if (!is.na(ix)) {
    item_encoded <- filecodes$`Item encoded`[ix]
    if (!identical(item_encoded, expected_encoded))
      stop("Registry Item encoded '", item_encoded, "' != derived '", expected_encoded,
           "' -- the registry is the authority; rename the TSV.", call. = FALSE)
  } else warning("Item not yet in __ReadMe.xlsx; using derived Item encoded ", expected_encoded)
}
if (grepl("_$", item_encoded)) stop("Item encoded ends with '_'", call. = FALSE)
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
