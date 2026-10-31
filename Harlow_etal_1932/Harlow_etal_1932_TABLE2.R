## Harlow_etal_1932_TABLE2 -- Summary of correct responses (p.323)
## Input : Harlow_etal_1932_TABLE2_snapshot.xlsx  (frozen; printed layout)
## Output: Harlow_etal_1932_TABLE2.csv + public TSV
## Reshaped LONG: one analysis row per animal x printed delay block that carries
## any value.  Species come from this paper's own TABLE 1 roster, joined on the
## printed FAMILIAR NAME, then through _keys/General/species_key.csv.
options(scipen = 999, stringsAsFactors = FALSE)
## the printed dagger footnote mark must survive into the CSV/TSV; a C locale
## would write it as the literal "<U+2020>"
if (!grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed = TRUE))
  suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))
if (!grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed = TRUE))
  stop("a UTF-8 LC_CTYPE is required to write this item's footnote marks", call. = FALSE)

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

s <- as.data.frame(readxl::read_excel("Harlow_etal_1932_TABLE2_snapshot.xlsx",
                                      col_names = FALSE, .name_repair = "minimal"))
s[is.na(s)] <- ""
stopifnot(nrow(s) == 33L, ncol(s) == 26L)

delay_lab <- unlist(s[4, seq(3, 26, by = 3)], use.names = FALSE)   # 8 printed blocks
stopifnot(length(delay_lab) == 8L, delay_lab[1] == "0 second")
delay_s <- suppressWarnings(as.numeric(sub("^([0-9]+).*$", "\\1", delay_lab)))
delay_s[delay_lab == "Over 180 seconds"] <- NA_real_

d <- s[7:30, ]                                   # the 24 printed animal rows
stopifnot(nrow(d) == 24L, d[1, 1] == "Orang-outan", d[24, 1] == "Lemur")

## roster: FAMILIAR NAME -> printed binomial, from this paper's TABLE 1
t1 <- read.csv("Harlow_etal_1932_TABLE1_snapshot.csv", header = FALSE,
               colClasses = "character", na.strings = NULL)
t1 <- t1[t1[[6]] %in% c("Male", "Female"), ]
roster <- setNames(paste(sub("\\*$", "", t1[[2]]), t1[[3]]), t1[[4]])
stopifnot(length(roster) == 24L, all(d[[2]] %in% names(roster)))

## Footnote marks printed in an "Over 180 seconds" cell resolve the delay.
## The marks and their meanings are taken from the snapshot's own footnote
## rows, so the comparison never depends on the session's locale/encoding.
foot_rows <- s[32:33, 1]
stopifnot(grepl("Three hundred seconds", foot_rows[1]),
          grepl("Six hundred seconds",   foot_rows[2]))
foot_mark <- substr(foot_rows, 1, 1)
foot_secs <- c(300, 600)
stopifnot(!anyDuplicated(foot_mark))

out <- list()
for (i in seq_len(nrow(d))) {
  free_text <- grepl("^\\(", d[i, 3])            # "(Failed to grasp problem)"
  for (b in seq_len(8)) {
    cells <- unlist(d[i, 3 * b + c(0, 1, 2)], use.names = FALSE)
    if (free_text && b > 1L) next
    if (!free_text && all(cells == "")) next
    mk   <- match(cells[3], foot_mark)
    mark <- if (!is.na(mk)) cells[3] else character(0)
    out[[length(out) + 1L]] <- data.frame(
      animal_number_printed   = i,
      animal_as_published     = d[i, 1],
      familiar_name           = d[i, 2],
      species_printed         = unname(roster[d[i, 2]]),
      delay_block_as_published = delay_lab[b],
      delay_s                 = if (length(mark)) foot_secs[mk] else delay_s[b],
      delay_s_from_footnote   = length(mark) > 0L,
      footnote_marker         = if (length(mark)) mark else NA_character_,
      n_trials                = if (free_text) NA_real_ else num(cells[1]),
      pct_correct             = if (free_text) NA_real_ else num(cells[2]),
      pct_correct_last50      = if (free_text) NA_real_ else num(cells[3]),
      note_as_published       = if (free_text) d[i, 3] else NA_character_,
      row.names = NULL, check.names = FALSE)
  }
}
out <- do.call(rbind, out)
stopifnot(sum(out$delay_s_from_footnote) == 2L)   # Jiggs 300 s, Pat 600 s
sp <- resolve_species(out$species_printed, "Harlow_etal_1932")
out$accepted_name <- sp$accepted_name
out$species_basis <- sp$species_basis
out$reidentified  <- sp$reidentified
out$source        <- "Harlow_etal_1932_TABLE2"
final.dataframe <- out
stopifnot(!any(sp$unresolved))

## ---- table checks (section 7a) -------------------------------------------
## LFC is "per cent last 50 trials correct": with 50 trials every attainable
## percentage is a multiple of 2.  Nothing else in this table is self-checking.
lfc <- final.dataframe$pct_correct_last50
lfc <- lfc[!is.na(lfc)]
bad <- lfc[lfc %% 2 != 0]
table_checks <- data.frame(
  check_id   = "lfc_multiple_of_2",
  basis      = "LFC (per cent of the last 50 trials correct) must be a multiple of 2",
  observed   = length(bad),
  printed    = 0,
  difference = length(bad),
  tolerance  = 0,
  status     = if (length(bad) == 0L) "pass" else "mismatch",
  note       = paste0(length(lfc), " printed LFC cells checked"),
  stringsAsFactors = FALSE)
if (length(bad)) warning("TABLE 2: ", length(bad), " LFC value(s) are not multiples of 2")
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
