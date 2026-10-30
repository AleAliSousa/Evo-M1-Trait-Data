## Glendenning_Masterton_1998_Table5.R -- frozen snapshot -> analysis CSV + public TSV
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 5: animal rankings based on similarity in form of each animal's ascending auditory system with average form of system (p. 77); ranks less than 10 apart not reliably different.
## r = correlation of the animal's profile with the average profile. Printed
## twice -- alphabetical and descending (with "Average similarity" row and the
## "least deviant" / "most deviant" annotations); the snapshot keeps both
## lists side by side with the printed headers (54 rows). DERIVED from Table 3.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Glendenning_Masterton_1998_Table5"
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

## 2. LOAD (headers as printed: "r" twice, unlabelled annotation column) ---
snap <- read.csv(snapshot_csv, colClasses = "character", encoding = "UTF-8", check.names = FALSE)
stopifnot(nrow(snap) == 54L, identical(names(snap), c("Alphabetical order", "r", "Descending order", "r", "")))
names(snap) <- c("alpha", "r_alpha", "desc", "r_desc", "annotation")

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

num <- function(x) as.numeric(gsub("\u2013", "-", x))
alpha <- snap[nzchar(snap$alpha), c("alpha", "r_alpha")]
avg   <- grep("^Average similarity", snap$desc); stopifnot(length(avg) == 1L)
avg_r <- num(snap$r_desc[avg]); desc_an <- snap[-avg, c("desc", "r_desc", "annotation")]
stopifnot(nrow(alpha) == 53L, nrow(desc_an) == 53L, setequal(to_t1(alpha$alpha), t1$`Common name`),
          setequal(alpha$alpha, desc_an$desc))

## 3. TABLE CHECKS -----------------------------------------------------
same <- num(alpha$r_alpha) == num(desc_an$r_desc[match(alpha$alpha, desc_an$desc)])
dr <- num(snap$r_desc)
table_checks <- data.frame(
  check_id = c("alphabetical_equals_descending", "descending_is_monotone", "average_position"),
  basis = c("r printed in the alphabetical list equals r printed in the descending list, per animal",
            "descending list is non-increasing in r (Average similarity row included)",
            "Average similarity row sits where its r falls in the descending list"),
  observed = c(sum(same), sum(diff(dr) <= 0), sum(dr[-avg] > avg_r)),
  printed = c(53, 53, avg - 1),
  tolerance = 0, stringsAsFactors = FALSE)
table_checks$difference <- table_checks$observed - table_checks$printed
table_checks$status <- ifelse(table_checks$difference == 0, "pass", "mismatch")
table_checks$note <- paste0("Average similarity printed r = ", snap$r_desc[avg])
print(table_checks[, c("check_id", "observed", "printed", "status")], row.names = FALSE)
if (any(table_checks$status != "pass")) warning("Table checks not passed", call. = FALSE)

## 4. CLEAN ------------------------------------------------------------
final.dataframe <- tibble(
  animal_as_printed = alpha$alpha,
  species_as_printed = binom(alpha$alpha),
  r_similarity_to_average_form = num(alpha$r_alpha),
  rank_most_similar_first = match(alpha$alpha, desc_an$desc),
  deviance_annotation = desc_an$annotation[match(alpha$alpha, desc_an$desc)],
  relative_to_average_similarity = ifelse(num(alpha$r_alpha) > avg_r, "above_average", "below_average"),
  average_similarity_r_printed = avg_r) %>%
  mutate(species = resolve(species_as_printed), data_role = "primary") %>%
  relocate(species, .after = species_as_printed)

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
