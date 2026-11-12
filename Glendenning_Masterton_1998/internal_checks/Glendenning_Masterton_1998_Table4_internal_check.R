## Glendenning_Masterton_1998_Table4_internal_check.R -- cross-item check (build HOWTO 7b)
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 4 lists, for each of 12 nuclei / clusters, all 53 animals plus "Average" in rank order
## (common names only). Check: each of the 12 rank columns is a permutation of the 53 Table 1
## common names + "Average". Formerly made in memory by Glendenning_Masterton_1998_Table4_snapshot.py
## (re-extracting Table 1); moved here because it needs the sibling snapshot. Trailing significance
## stars are ignored; one printed misspelling, "Gropher, pocket" (Table 4A, LSO column, p. 72), is
## mapped to Table 1's "Gopher, pocket" for this comparison only (it stays as printed in the snapshot).
## Reads only the two snapshots; writes only Glendenning_Masterton_1998_Table4_internal_check.csv in
## this folder. Never changes a value; a mismatch is warned and kept as printed.

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
stopifnot(nrow(snap) == 54L, ncol(snap) == 12L)
printed_variants <- c("Gropher, pocket" = "Gopher, pocket")
expect <- sort(c(animals, "Average"))
res <- lapply(seq_along(snap), function(j) {
  nm <- sub("\\*+$", "", snap[[j]])
  nm <- ifelse(nm %in% names(printed_variants), printed_variants[nm], nm)
  nm <- unname(nm)
  n_ok <- sum(nm %in% expect & !duplicated(nm))
  data.frame(
    check_id = paste0("rank_list_names_", j, "_", names(snap)[j]),
    basis = paste0("Table 4 column '", names(snap)[j], "': printed names (stars removed) vs Table 1 'Common name' x 53 + 'Average'"),
    observed = n_ok, printed = length(expect), difference = n_ok - length(expect), tolerance = 0,
    status = ifelse(identical(sort(nm), expect), "pass", "mismatch"),
    note = "each name exactly once; 'Gropher, pocket' read as 'Gopher, pocket' (printed misspelling, kept as printed in the snapshot)",
    stringsAsFactors = FALSE)
})
table_checks <- do.call(rbind, res)
print(table_checks[, c("check_id", "observed", "printed", "status")], row.names = FALSE)
if (any(table_checks$status != "pass")) warning("Table 4 rank-list names differ from Table 1 -- kept as printed.", call. = FALSE)
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
