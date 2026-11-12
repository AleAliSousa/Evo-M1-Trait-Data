## Harlow_etal_1932_TABLE5 -- Tests of retention (p.334)
## Input : Harlow_etal_1932_TABLE5_snapshot.csv  (frozen; printed layout)
## Output: Harlow_etal_1932_TABLE5.csv + public TSV
## Reshaped LONG: one analysis row per animal x printed test occasion
## (blank cells are not emitted).
options(scipen = 999, stringsAsFactors = FALSE)

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
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Repository root (__ReadMe.xlsx) not found above ", folder, call. = FALSE)
source(file.path(base, "_keys", "resolve_species.R"))

## numbers as printed -> numeric; blanks and the printed non-numeric tokens stay NA
num <- function(x) {
  x <- gsub("\u00a0", " ", as.character(x), fixed = TRUE)
  x <- gsub(",", "", trimws(x))
  x[x %in% c("", "-", "\u2013", "\u2014", "NA", "n.a.", "NR", "NE")] <- NA_character_
  suppressWarnings(as.numeric(x))
}

s <- read.csv("Harlow_etal_1932_TABLE5_snapshot.csv", header = FALSE,
              colClasses = "character", check.names = FALSE, na.strings = NULL)
stopifnot(nrow(s) == 24L, ncol(s) == 5L)
occ_lab <- unlist(s[3, 2:5], use.names = FALSE)
stopifnot(occ_lab[1] == "ORIGINAL TEST SCORE")
occ_code <- c("original", "retest_10_14_days", "after_4_6_weeks_no_practice",
              "after_9_12_weeks_no_practice")

d <- s[4:24, ]
stopifnot(nrow(d) == 21L, d[1, 1] == "Mandrill (Pat)")

t1 <- read.csv("Harlow_etal_1932_TABLE1_snapshot.csv", header = FALSE,
               colClasses = "character", na.strings = NULL)
t1 <- t1[t1[[6]] %in% c("Male", "Female"), ]
roster <- setNames(paste(sub("\\*$", "", t1[[2]]), t1[[3]]), t1[[4]])
fam <- sub("^.*\\(([^)]*)\\)$", "\\1", d[[1]])
stopifnot(all(fam %in% names(roster)), !anyDuplicated(fam))

out <- list()
for (i in seq_len(nrow(d))) for (k in seq_len(4L)) {
  cell <- d[i, k + 1L]
  if (cell == "") next
  out[[length(out) + 1L]] <- data.frame(
    animal_as_published     = d[i, 1],
    familiar_name           = fam[i],
    species_printed         = unname(roster[fam[i]]),
    test_occasion           = occ_code[k],
    test_occasion_as_published = occ_lab[k],
    occasion_order          = k,
    total_correct_responses = num(cell),
    row.names = NULL, check.names = FALSE)
}
final.dataframe <- do.call(rbind, out)
sp <- resolve_species(final.dataframe$species_printed, "Harlow_etal_1932")
final.dataframe$accepted_name <- sp$accepted_name
final.dataframe$species_basis <- sp$species_basis
final.dataframe$reidentified  <- sp$reidentified
final.dataframe$source        <- "Harlow_etal_1932_TABLE5"
stopifnot(!any(sp$unresolved), !anyNA(final.dataframe$total_correct_responses))

## ---- table checks (section 7a) -------------------------------------------
## p.335: "The total number of correct responses on the first series was
## correlated with the number correct on the second; this gives a correlation
## coefficient of .971" (Hull's product-moment formula = Pearson r).  Both
## series are the first two columns of this table, so the table checks itself.
r_obs <- cor(num(d[[2]]), num(d[[3]]))
table_checks <- data.frame(
  check_id   = "retest_reliability_r",
  basis      = "Pearson r of ORIGINAL TEST SCORE vs RETEST SCORE 10-14 DAYS LATER over all 21 printed rows, against the .971 stated on p.335",
  observed   = round(r_obs, 4),
  printed    = 0.971,
  difference = round(r_obs - 0.971, 4),
  tolerance  = 0.001,
  status     = if (abs(r_obs - 0.971) <= 0.001) "pass" else "mismatch",
  note       = "rounding of the printed integer scores is the only slack allowed",
  stringsAsFactors = FALSE)
if (table_checks$status != "pass")
  warning("TABLE 5: retest r is ", round(r_obs, 4), ", the paper states .971")
print(table_checks)

## ---- write the analysis CSV and the DOI-coded public TSV -----------------
stopifnot(is.data.frame(final.dataframe), nrow(final.dataframe) > 0L)
write.csv(final.dataframe, paste0(item_name, ".csv"), row.names = FALSE, na = "")

fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
if (is.na(item_encoded)) stop("No registry row for Item name '", item_name, "'", call. = FALSE)
## Column A of Sheet1 has carried trailing whitespace, which the Item-name
## formula pastes into Item encoded ("10.1037%2Fh0073864<NBSP>_TABLE1").  No
## legitimate encoded stem contains a space, so strip every space (incl. NBSP)
## before using it as a filename.  Harmless once file_list.R has been re-run.
item_encoded <- gsub("[[:space:]]", "",
                     gsub("\u00a0", "", item_encoded, fixed = TRUE))
if (!nzchar(item_encoded)) stop("Empty 'Item encoded' for ", item_name, call. = FALSE)
out_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(out_dir)) {
  write.table(final.dataframe, file.path(out_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "")
} else warning("__Public/comparative-data not mounted; public TSV skipped.")
message(item_name, ": ", nrow(final.dataframe), " rows -> ", item_encoded, ".tsv")
