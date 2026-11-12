## Glendenning_Masterton_1998_Table3_internal_check.R -- cross-item check (build HOWTO 7b)
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 3 prints common names only (no binomials). Check: the 53 animal rows of Table 3 name the
## same animals, in the same order, as Table 1 ("Common name"). Formerly made in memory by
## Glendenning_Masterton_1998_Table3_snapshot.py (re-extracting Table 1); moved here because it needs
## the sibling snapshot. Reads only the two snapshots; writes only
## Glendenning_Masterton_1998_Table3_internal_check.csv in this folder. Never changes a value; a
## mismatch is warned and kept as printed.

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
check_dir <- dirname(.sp)                                 # <Paper>/internal_checks
folder    <- dirname(check_dir)                           # <Paper>
item_name <- sub("_internal_check$", "", tools::file_path_sans_ext(basename(.sp)))   # "Glendenning_Masterton_1998_TableN"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
table1_snapshot_csv <- file.path(folder, "Glendenning_Masterton_1998_Table1_snapshot.csv")
check_csv    <- file.path(check_dir, paste0(item_name, "_internal_check.csv"))

## 1. LOAD (read-only) ------------------------------------------------
snap <- read.csv(snapshot_csv, colClasses = "character", encoding = "UTF-8", check.names = FALSE)
t1   <- read.csv(table1_snapshot_csv, colClasses = "character", encoding = "UTF-8", check.names = FALSE)
stopifnot(nrow(t1) == 53L)
animals <- t1$`Common name`

## 2. CHECK -------------------------------------------------------------
stopifnot(nrow(snap) == 53L)
got <- snap$Animal[seq_len(53)]
n_same <- sum(got == animals)
table_checks <- data.frame(
  check_id = "animal_names_vs_table1",
  basis = "Table 3 'Animal' rows 1-53 vs Table 1 'Common name' rows 1-53 (same order): number of rows with an identical printed name",
  observed = n_same, printed = length(animals), difference = n_same - length(animals), tolerance = 0,
  status = ifelse(identical(got, animals), "pass", "mismatch"),
  note = "exact string match of printed names; Table 3 has 53 rows, all animals",
  stringsAsFactors = FALSE)
print(table_checks[, c("check_id", "observed", "printed", "status")], row.names = FALSE)
if (any(table_checks$status != "pass")) warning("Table 3 animal names differ from Table 1 -- kept as printed.", call. = FALSE)
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
