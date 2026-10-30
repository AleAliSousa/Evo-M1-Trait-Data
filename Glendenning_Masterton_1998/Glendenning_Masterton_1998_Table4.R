## Glendenning_Masterton_1998_Table4.R -- frozen snapshot -> analysis CSV + public TSV
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 4 A, B (pp. 72-73): animal rankings of each nucleus and the two
## clusters CN and SO, based on Table 3 entries -- largest at top, smallest at
## bottom; the printed "Average" row marks where the mean falls; * p<0.05,
## ** p<0.01 (deviation from average); ranks less than 6 apart not reliably
## different. Snapshot keeps the printed layout: 12 columns (A = first 6,
## p. 72; B = last 6, p. 73) x 54 printed rows. DERIVED (rank order of Table 3).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Glendenning_Masterton_1998_Table4"
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
stopifnot(nrow(snap) == 54L, ncol(snap) == 12L)

## species via Table 1 of the same paper (Tables 2-7 print common names only;
## Table 1 prints the binomial for each Animal No.), then the species key.
t1 <- read.csv(file.path(folder, "Glendenning_Masterton_1998_Table1_snapshot.csv"),
               colClasses = "character", encoding = "UTF-8", check.names = FALSE)
stopifnot(nrow(t1) == 53L)

## Common name -> Table 1 binomial. One printed misspelling is mapped to its
## Table 1 row (kept verbatim in animal_as_printed): "Gropher, pocket"
## (Table 4A, LSO column, p. 72) = "Gopher, pocket".
printed_variants <- c("Gropher, pocket" = "Gopher, pocket")
to_t1 <- function(x) { y <- ifelse(x %in% names(printed_variants), printed_variants[x], x); unname(y) }
binom <- function(x) { b <- t1$`Genus and species`[match(to_t1(x), t1$`Common name`)]
  if (anyNA(b)) stop("Common names not in Table 1: ", paste(unique(x[is.na(b)]), collapse = "; "), call. = FALSE); b }

code <- c("AVCN", "PVCN", "DCN", "CN", "MTB", "LSO", "MSO", "SO", "VLL", "DLL", "IC", "MG")

## 3. RESHAPE: one row per list x animal -------------------------------
out <- list()
for (j in seq_along(snap)) {
  cell <- snap[[j]]
  nm   <- sub("\\*+$", "", cell); mark <- sub("^[^*]*", "", cell)
  avg  <- which(nm == "Average"); stopifnot(length(avg) == 1L)
  stopifnot(setequal(to_t1(nm[-avg]), t1$`Common name`), !anyDuplicated(to_t1(nm[-avg])))
  pos  <- seq_along(nm)
  keep <- pos != avg
  out[[j]] <- tibble(
    list_as_printed = names(snap)[j], nucleus_or_cluster = code[j], table_part = ifelse(j <= 6, "A", "B"),
    printed_row = pos[keep], rank_largest_first = rank(pos[keep]),
    animal_as_printed = nm[keep], significance_mark = mark[keep],
    p_value_class = ifelse(mark[keep] == "**", "p<0.01", ifelse(mark[keep] == "*", "p<0.05", "")),
    relative_to_average = ifelse(pos[keep] < avg, "above_average", "below_average"),
    average_printed_row = avg)
}
final.dataframe <- bind_rows(out) %>%
  mutate(species_as_printed = binom(animal_as_printed), species = resolve(species_as_printed),
         data_role = "primary") %>%
  relocate(species_as_printed, species, .after = animal_as_printed)
stopifnot(nrow(final.dataframe) == 12L * 53L)

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
