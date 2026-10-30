## Pellis_Iwaniuk_2000_Table1.R -- frozen snapshot -> analysis CSV + public TSV
##
## Pellis, S. M., & Iwaniuk, A. N. (2000). Adult-adult play in primates: comparative
## analyses of its origin, distribution and evolution. Ethology, 106(12), 1083-1104.
## doi:10.1046/j.1439-0310.2000.00627.x
##
## TABLE 1 (pp. 1087-1088): "Information on play and social organization for the species
## used". 71 primate species scored for adult-adult play fighting in sexual and non-sexual
## contexts, whether play is absent/present, and (strepsirrhines only) social organization.
## This is the PRIMARY table for these ordinal play scores; Iwaniuk, Nelson & Pellis (2001)
## Table 4 republishes the same scores for 64 primate species (see the README's value match).
##
## Frozen source: Pellis_Iwaniuk_2000_Table1_snapshot.csv, written by
## Pellis_Iwaniuk_2000_extract_snapshot.R from the PDF text layer (glyph map and the
## 200-dpi page-render check are documented there). No score is typed into either script.
##
## Scoring, as the paper defines it (pp. 1085-1086 and the Table 1 footnotes):
##   sexual / non-sexual play context: 0 = play absent, 1 = play present but rare,
##     2 = play present and common (ceiling raised to 3 for the species where the
##     strepsirrhine comparison needed a higher ceiling -- printed as "2/3": the first
##     value tests the byproduct hypothesis, the second the social assessment hypothesis).
##   Play absent (0) or present (1): the paper's binary presence column.
##   Social organization: scored for strepsirrhines only (0-3); "-" elsewhere.
## A printed en dash means NOT SCORED and becomes NA -- never 0.
## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Pellis_Iwaniuk_2000_Table1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
## Namespace-qualified so the script also runs under build_dataset_item(), which
## sys.source()s it into an environment whose parent is baseenv().
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen snapshot, read positionally as text) -------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                        colClasses = "character", encoding = "UTF-8", check.names = FALSE)
## printed layout: 3 header rows, 71 data rows, 2 footnote rows
if (!identical(dim(snap), c(76L, 5L)))
  stop("snapshot shape changed: expected 76 x 5, got ", nrow(snap), " x ", ncol(snap), call. = FALSE)
stopifnot(snap[3, 1] == "Species*", snap[3, 5] == "Play absent (0) or present (1)")
dat <- snap[4:74, ]

## 2b. SPECIES KEY (collection-scoped: _keys/General; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
## This paper's own spoke rows cover only the three printed names that need correcting;
## every other printed binomial resolves through the shared resolver, so harmonisation
## goes through resolve_species() rather than a local lookup table.
## local = TRUE so the resolver lands in THIS environment: build_dataset_item() runs the
## script with sys.source(envir = new.env(parent = baseenv())), from which globalenv() is
## not on the search path.
source(file.path(base, "_keys", "resolve_species.R"), local = TRUE)

## 3. CLEAN -----------------------------------------------------------
dash <- "\u2013"
num <- function(x) {
  x <- trimws(x)
  out <- suppressWarnings(as.integer(x))
  out[x %in% c("", dash)] <- NA_integer_
  out
}
## "2/3": the printed dual value. First number = the score used for the byproduct
## hypothesis, second = the score used for the social assessment hypothesis (footnote **).
dual_first  <- function(x) num(sub("/.*$", "", trimws(x)))
dual_second <- function(x) num(sub("^.*/", "", trimws(x)))

printed_sp <- trimws(dat[[1]])
res <- resolve_species(printed_sp, source_publication = basename(folder))
if (any(res$unresolved))
  stop("Printed name(s) not resolvable: ", paste(printed_sp[res$unresolved], collapse = "; "),
       " -- add a row to _keys/General/species_key.csv.", call. = FALSE)

final.dataframe <- tibble::tibble(
  species_as_published                 = printed_sp,
  Species                              = res$accepted_name,
  species_basis                        = res$species_basis,
  social_organization                  = num(dat[[2]]),
  play_sexual                          = num(dat[[3]]),
  play_nonsexual_printed               = trimws(dat[[4]]),
  play_nonsexual_byproduct             = dual_first(dat[[4]]),
  play_nonsexual_social_assessment     = dual_second(dat[[4]]),
  play_presence                        = num(dat[[5]]),
  observation_level                    = "species score (literature ratings, verified against the authors' own observations for 10 species)",
  data_role                            = "primary",
  source_row                           = seq_len(nrow(dat)) + 3L)
final.dataframe$play_nonsexual_printed[final.dataframe$play_nonsexual_printed == dash] <- NA_character_

stopifnot(nrow(final.dataframe) == 71L,
          all(final.dataframe$play_sexual %in% c(0:2, NA)),
          all(final.dataframe$play_nonsexual_byproduct %in% c(0:3, NA)),
          all(final.dataframe$play_nonsexual_social_assessment %in% c(0:3, NA)),
          all(final.dataframe$play_presence %in% c(0:1, NA)),
          all(final.dataframe$social_organization %in% c(0:3, NA)),
          ## the only blank presence cell on the page is the last row (Varecia variegata)
          identical(final.dataframe$species_as_published[is.na(final.dataframe$play_presence)],
                    "Varecia variegata"),
          ## social organization is scored for the 20 strepsirrhine species only
          sum(!is.na(final.dataframe$social_organization)) == 20L)

## 3b. TABLE CHECKS (HOWTO 7a): none. The table prints no totals, percentages or other
## internal relation that can check itself. The cross-publication value match against
## Iwaniuk et al. (2001) Table 4 is reported in the README, not here: that is a different
## published table and its values are not hardcoded in this script.

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")                # readr: always UTF-8
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
