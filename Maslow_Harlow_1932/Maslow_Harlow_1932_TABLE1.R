## Maslow_Harlow_1932_TABLE1 -- Classification of the animals (p.99)
## Input : Maslow_Harlow_1932_TABLE1_snapshot.csv  (frozen; printed layout)
## Output: Maslow_Harlow_1932_TABLE1.csv + public TSV
## One analysis row per animal (specimen roster, 18 animals).
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

snap <- read.csv("Maslow_Harlow_1932_TABLE1_snapshot.csv", header = FALSE,
                 colClasses = "character", check.names = FALSE,
                 na.strings = NULL, encoding = "UTF-8")
stopifnot(nrow(snap) == 23L, ncol(snap) == 5L)
names(snap) <- c("family", "genus", "species", "age", "sex")

is_sub <- grepl("^Suborder ", snap$family)
snap$suborder <- NA_character_
snap$suborder[is_sub] <- snap$family[is_sub]
for (i in seq_len(nrow(snap))[-1]) if (is.na(snap$suborder[i])) snap$suborder[i] <- snap$suborder[i - 1]

d <- snap[snap$sex %in% c("Male", "Female"), ]
stopifnot(nrow(d) == 18L)

## printed numbering "1." ... "18." is the paper's own animal number
animal_no <- as.integer(sub("^([0-9]+)\\..*$", "\\1", d$family))
stopifnot(identical(animal_no, 1:18))
fam_txt <- trimws(sub("^[0-9]+\\.\\s*", "", d$family))

## "4 1/2 years" -> 4.5 ; "Baby (2 years)" -> 2 ; "Adult"/"Young adult" -> NA
age_years <- function(x) {
  n <- suppressWarnings(as.numeric(sub("^.*?([0-9]+)\\s*(1/2)?\\s*years.*$", "\\1", x)))
  n[!grepl("year", x)] <- NA_real_
  n + ifelse(grepl("1/2", x, fixed = TRUE), 0.5, 0)
}

sp <- resolve_species(paste(d$genus, d$species), "Maslow_Harlow_1932")

final.dataframe <- data.frame(
  animal_number_printed        = animal_no,
  suborder_as_published        = sub("^Suborder ", "", d$suborder),
  family_as_published          = trimws(sub("\\s*\\(.*$", "", fam_txt)),
  common_name_as_published     = ifelse(grepl("\\(", fam_txt),
                                        sub("^[^(]*\\((.*)\\)$", "\\1", fam_txt), NA_character_),
  genus_as_published           = d$genus,
  species_epithet_as_published = d$species,
  species_printed              = paste(d$genus, d$species),
  estimated_age_as_published   = d$age,
  estimated_age_years          = age_years(d$age),
  age_class                    = ifelse(grepl("^Young", d$age), "young adult",
                                 ifelse(grepl("^Old", d$age), "old adult",
                                 ifelse(grepl("^Baby", d$age), "infant",
                                 ifelse(d$age == "Adult", "adult", "juvenile")))),
  sex                          = d$sex,
  accepted_name                = sp$accepted_name,
  species_basis                = sp$species_basis,
  reidentified                 = sp$reidentified,
  source                       = "Maslow_Harlow_1932_TABLE1",
  row.names = NULL, check.names = FALSE)
stopifnot(!any(sp$unresolved))

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
