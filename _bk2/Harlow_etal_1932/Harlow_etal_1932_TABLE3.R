## Harlow_etal_1932_TABLE3 -- effect of bodily orientation (p.331)
## Input : Harlow_etal_1932_TABLE3_snapshot.xlsx  (frozen; printed layout)
## Output: Harlow_etal_1932_TABLE3.csv + public TSV
## Reshaped LONG: one analysis row per animal x orientation condition (10 x 3).
##
## ERRATUM Harlow_etal_1932-E001 (publication_ambiguity).  The printed table has
## ELEVEN label lines for TEN value rows: line 1 reads "I. Mandrill" and carries
## its own values, while lines 2 and 3 ("II. Pat" and "II. Baboon Min") are
## joined by a printed brace to a single set of values -- and "II." is printed
## twice.  Tables 4 and 6 list the same animals in the same order as
## "I. Mandrill (Pat)" and "II. Baboon (Min)", so the brace has evidently
## slipped one line and "Pat" belongs to the mandrill of row I.  The printed
## labels are carried verbatim in `animal_as_published`; the interpretation is
## confined to `familiar_name` and flagged by `errata_id`.  No printed value is
## altered anywhere.
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

s <- as.data.frame(readxl::read_excel("Harlow_etal_1932_TABLE3_snapshot.xlsx",
                                      col_names = FALSE, .name_repair = "minimal"))
s[is.na(s)] <- ""
stopifnot(nrow(s) == 15L, ncol(s) == 5L)
cond <- unlist(s[4, 3:5], use.names = FALSE)
stopifnot(identical(cond, c("NEUTRAL ORIENTATION", "UNFAVORABLE ORIENTATION",
                            "FAVORABLE ORIENTATION")))

d <- s[5:15, ]                                   # the 11 printed label lines
stopifnot(nrow(d) == 11L)
## the braced pair: line 2 carries the shared values, line 3 is blank
stopifnot(d[1, 1] == "I. Mandrill", d[2, 1] == "II. Pat",
          d[3, 1] == "II. Baboon Min", d[3, 3] == "")
lab <- d[[1]]
printed_label <- c(lab[1], paste(lab[2], lab[3], sep = " | "), lab[4:11])
val <- d[-3, 3:5]                                # 10 value rows
stopifnot(nrow(val) == 10L, all(val != ""))

## roster: FAMILIAR NAME -> printed binomial, from this paper's TABLE 1
t1 <- read.csv("Harlow_etal_1932_TABLE1_snapshot.csv", header = FALSE,
               colClasses = "character", na.strings = NULL)
t1 <- t1[t1[[6]] %in% c("Male", "Female"), ]
roster <- setNames(paste(sub("\\*$", "", t1[[2]]), t1[[3]]), t1[[4]])

## familiar name = the TABLE 1 roster name the printed label ends with ...
fam <- vapply(printed_label, function(s0) {
  hit <- names(roster)[endsWith(s0, names(roster))]
  if (length(hit) == 1L) hit else NA_character_
}, character(1), USE.NAMES = FALSE)
## ... except row I, whose printed label carries no individual name (E001)
stopifnot(is.na(fam[1]), identical(fam[2], "Min"))
fam[1] <- "Pat"
errata_id <- ifelse(seq_along(fam) <= 2L, "Harlow_etal_1932-E001", NA_character_)
stopifnot(!anyNA(fam), !anyDuplicated(fam), all(fam %in% names(roster)))

n_an <- length(fam)
final.dataframe <- data.frame(
  animal_number_printed   = rep(sub("^([IVX]+)\\..*$", "\\1", printed_label), each = 3L),
  animal_as_published     = rep(printed_label, each = 3L),
  familiar_name           = rep(fam, each = 3L),
  species_printed         = rep(unname(roster[fam]), each = 3L),
  orientation_as_published = rep(cond, times = n_an),
  orientation             = rep(tolower(sub(" ORIENTATION$", "", cond)), times = n_an),
  delay_s                 = 30,
  n_trials                = 50,
  pct_correct             = as.numeric(t(as.matrix(val))),
  errata_id               = rep(errata_id, each = 3L),
  row.names = NULL, check.names = FALSE)
sp <- resolve_species(final.dataframe$species_printed, "Harlow_etal_1932")
final.dataframe$accepted_name <- sp$accepted_name
final.dataframe$species_basis <- sp$species_basis
final.dataframe$reidentified  <- sp$reidentified
final.dataframe$source        <- "Harlow_etal_1932_TABLE3"
stopifnot(nrow(final.dataframe) == 30L, !any(sp$unresolved),
          !anyNA(final.dataframe$pct_correct))

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
