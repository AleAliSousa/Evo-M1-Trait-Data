## Harlow_etal_1932_TABLE1 -- Classification of the animals (p.316)
## Input : Harlow_etal_1932_TABLE1_snapshot.csv  (frozen; printed layout)
## Output: Harlow_etal_1932_TABLE1.csv + public TSV
## One analysis row per animal (specimen roster, 24 animals).
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

snap <- read.csv("Harlow_etal_1932_TABLE1_snapshot.csv", header = FALSE,
                 colClasses = "character", check.names = FALSE,
                 na.strings = NULL, encoding = "UTF-8")
stopifnot(nrow(snap) == 31L, ncol(snap) == 6L)
names(snap) <- c("family", "genus", "species", "familiar", "age", "sex")

## carry the printed suborder heading down over the rows it spans
is_sub <- grepl("^Suborder ", snap$family)
snap$suborder <- NA_character_
snap$suborder[is_sub] <- snap$family[is_sub]
for (i in seq_len(nrow(snap))[-1]) if (is.na(snap$suborder[i])) snap$suborder[i] <- snap$suborder[i - 1]

## data rows are exactly the rows carrying a printed SEX value
d <- snap[snap$sex %in% c("Male", "Female"), ]
stopifnot(nrow(d) == 24L)

## "11 1/2" -> 11.5
age_years <- function(x) {
  whole <- suppressWarnings(as.numeric(sub("^([0-9]+).*$", "\\1", x)))
  half  <- ifelse(grepl("1/2", x, fixed = TRUE), 0.5, 0)
  whole + half
}

genus_clean <- sub("\\*$", "", d$genus)
sp <- resolve_species(paste(genus_clean, d$species), "Harlow_etal_1932")

final.dataframe <- data.frame(
  animal_number_printed        = seq_len(nrow(d)),
  suborder_as_published        = sub("^Suborder ", "", d$suborder),
  family_as_published          = trimws(sub("\\s*\\(.*$", "", d$family)),
  common_name_as_published     = ifelse(grepl("\\(", d$family),
                                        sub("^[^(]*\\((.*)\\)$", "\\1", d$family), NA_character_),
  genus_as_published           = genus_clean,
  genus_footnote_marker        = ifelse(grepl("\\*$", d$genus), "*", NA_character_),
  species_epithet_as_published = d$species,
  species_printed              = paste(genus_clean, d$species),
  familiar_name                = d$familiar,
  estimated_age_years          = age_years(d$age),
  estimated_age_as_published   = d$age,
  sex                          = d$sex,
  accepted_name                = sp$accepted_name,
  species_basis                = sp$species_basis,
  reidentified                 = sp$reidentified,
  source                       = "Harlow_etal_1932_TABLE1",
  row.names = NULL, check.names = FALSE)

stopifnot(!any(sp$unresolved), !anyNA(final.dataframe$estimated_age_years),
          !anyDuplicated(final.dataframe$familiar_name))

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
