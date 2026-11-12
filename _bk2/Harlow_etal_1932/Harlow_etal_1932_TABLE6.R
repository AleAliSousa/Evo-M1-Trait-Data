## Harlow_etal_1932_TABLE6 -- direct vs indirect method (p.337)
## Input : Harlow_etal_1932_TABLE6_snapshot.xlsx  (frozen; printed layout)
## Output: Harlow_etal_1932_TABLE6.csv + public TSV
## Reshaped LONG: one analysis row per animal x delay x method (10 x 3 x 2 = 60).
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

s <- as.data.frame(readxl::read_excel("Harlow_etal_1932_TABLE6_snapshot.xlsx",
                                      col_names = FALSE, .name_repair = "minimal"))
s[is.na(s)] <- ""
stopifnot(nrow(s) == 16L, ncol(s) == 7L)
delay_lab <- unlist(s[4, c(2, 4, 6)], use.names = FALSE)
stopifnot(identical(delay_lab, c("15-SECOND DELAY", "30-SECOND DELAY", "60-SECOND DELAY")))
delay_s <- as.numeric(sub("-SECOND DELAY$", "", delay_lab))
meth <- unlist(s[5, 2:7], use.names = FALSE)
stopifnot(identical(meth, rep(c("DM", "IM"), 3L)))

d <- s[6:15, ]
stopifnot(nrow(d) == 10L, d[1, 1] == "I. Mandrill (Pat)")

t1 <- read.csv("Harlow_etal_1932_TABLE1_snapshot.csv", header = FALSE,
               colClasses = "character", na.strings = NULL)
t1 <- t1[t1[[6]] %in% c("Male", "Female"), ]
roster <- setNames(paste(sub("\\*$", "", t1[[2]]), t1[[3]]), t1[[4]])
fam <- sub("^.*\\(([^)]*)\\)$", "\\1", d[[1]])
stopifnot(all(fam %in% names(roster)))
## The printed ANIMAL cells name the taxon loosely: row VI calls Blackie a
## "Macaque" although TABLE 1 lists him as the Barbary ape (Simia sylvanus),
## which the TABLE 1 footnote says the authors deliberately group with the
## macaques.  The species therefore comes from the TABLE 1 roster, not the
## taxon word printed here.
taxon_printed <- trimws(sub("\\s*\\([^)]*\\)$", "", sub("^[IVX]+\\.\\s*", "", d[[1]])))

out <- list()
for (i in seq_len(nrow(d))) for (b in seq_len(3L)) for (k in seq_len(2L)) {
  cell <- d[i, 2 * b + k - 1L]
  out[[length(out) + 1L]] <- data.frame(
    animal_number_printed = sub("^([IVX]+)\\..*$", "\\1", d[i, 1]),
    animal_as_published   = d[i, 1],
    taxon_word_printed    = taxon_printed[i],
    familiar_name         = fam[i],
    species_printed       = unname(roster[fam[i]]),
    delay_s               = delay_s[b],
    method_code           = meth[2 * b + k - 2L],
    method                = c(DM = "direct", IM = "indirect")[meth[2 * b + k - 2L]],
    n_trials              = 20,
    pct_correct           = num(cell),
    response_code         = if (cell == "NR") "NR" else NA_character_,
    value_as_published    = cell,
    row.names = NULL, check.names = FALSE)
}
final.dataframe <- do.call(rbind, out)
sp <- resolve_species(final.dataframe$species_printed, "Harlow_etal_1932")
final.dataframe$accepted_name <- sp$accepted_name
final.dataframe$species_basis <- sp$species_basis
final.dataframe$reidentified  <- sp$reidentified
final.dataframe$source        <- "Harlow_etal_1932_TABLE6"
stopifnot(nrow(final.dataframe) == 60L, !any(sp$unresolved))

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
