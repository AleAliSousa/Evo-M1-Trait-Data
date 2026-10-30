## Ross_Kirk_2007_Appendix1.R -- frozen snapshot -> analysis CSV + public TSV
##
## Ross, C. F., & Kirk, E. C. (2007). Evolution of eye size and shape in primates.
## Journal of Human Evolution, 52(3), 294-313. doi:10.1016/j.jhevol.2006.09.006
##
## APPENDIX 1 (pp. 308-310): eye and body measurements for 260 visually dependent terrestrial
## mammal species -- Genus, Species, Order, ACT (activity pattern), n (specimens), HBL (head
## and body length, mm), AD (axial eye diameter, mm), CD (corneal diameter, mm).
## The appendix's own Notes line, extracted into the snapshot's last row, is the authority for
## those column definitions.
##
## Frozen source: Ross_Kirk_2007_Appendix1_snapshot.csv, written by
## Ross_Kirk_2007_extract_snapshot.R from the PDF text layer (two-column reading order and the
## render check are documented there). No value is typed into either script.
##
## Role: PRIMARY for the eye measures. The eyes were dissected and measured by the authors
## (Materials and methods, "Eye dimensions were measured in eyeballs dissected from preserved
## specimens"), with eye- and body-length data from Ritland (1982) culled in; HBL was taken
## from the same specimens or estimated as the median of published ranges (Nowak, 1991;
## Rowe, 1996), so HBL is flagged secondary in the definitions file.
##
## NB this item carries NO play data: it is eye morphology plus an activity-pattern code.
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Ross_Kirk_2007_Appendix1"
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
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen snapshot, read positionally as text) -------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                        colClasses = "character", encoding = "UTF-8", check.names = FALSE)
## printed layout: title, header, 260 data rows, the Notes line
if (!identical(dim(snap), c(263L, 8L)))
  stop("snapshot shape changed: expected 263 x 8, got ", nrow(snap), " x ", ncol(snap), call. = FALSE)
stopifnot(snap[2, 1] == "Genus", snap[2, 8] == "CD",
          grepl("^Notes: ACT, activity code", snap[263, 1]))
dat <- snap[3:262, ]

## 2b. SPECIES (shared resolver; this paper's 51 spoke rows cover the printed names that
## needed anchoring -- NCBI synonyms, four misspellings and the genus-level "sp." records)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
## local = TRUE so the resolver lands in THIS environment: build_dataset_item() runs the
## script with sys.source(envir = new.env(parent = baseenv())), from which globalenv() is
## not on the search path.
source(file.path(base, "_keys", "resolve_species.R"), local = TRUE)

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
printed_sp <- trimws(paste(trimws(dat[[1]]), trimws(dat[[2]])))
res <- resolve_species(printed_sp, source_publication = basename(folder))

## Four printed names have no anchor in NCBI taxonomy and stay unresolved on purpose (they are
## kept under the cleaned printed string, the resolver's own convention). Listing them here
## means a NEW unresolved name breaks the build instead of passing unnoticed.
expected_unresolved <- c("Lutra annectans", "Hemiechinus megalotis",
                         "Neotetracus fulvescens", "Graphiurus heuti")
if (!setequal(printed_sp[res$unresolved], expected_unresolved))
  stop("Unresolved printed name(s) changed: ",
       paste(setdiff(printed_sp[res$unresolved], expected_unresolved), collapse = "; "),
       " -- resolve them in _keys/General/species_key.csv or update the expected list.",
       call. = FALSE)

act_label <- c(c = "cathemeral", d = "diurnal", n = "nocturnal")   # the appendix Notes line
act <- trimws(dat[[4]])
if (!all(act %in% names(act_label))) stop("unknown ACT code(s): ",
                                          paste(setdiff(act, names(act_label)), collapse = ", "), call. = FALSE)

final.dataframe <- tibble::tibble(
  species_as_published = printed_sp,
  genus_as_published   = trimws(dat[[1]]),
  epithet_as_published = trimws(dat[[2]]),
  Species              = res$accepted_name,
  species_basis        = res$species_basis,
  order_as_published   = trimws(dat[[3]]),
  activity_code        = act,
  activity_pattern     = unname(act_label[act]),
  n_specimens          = as.integer(num(dat[[5]])),
  head_body_length_mm  = num(dat[[6]]),
  eye_axial_diameter_mm   = num(dat[[7]]),
  corneal_diameter_mm     = num(dat[[8]]),
  data_role            = "primary",
  source_row           = seq_len(nrow(dat)) + 2L)

stopifnot(nrow(final.dataframe) == 260L,
          !any(is.na(final.dataframe$eye_axial_diameter_mm)),
          !any(is.na(final.dataframe$corneal_diameter_mm)),
          !any(is.na(final.dataframe$head_body_length_mm)),
          !any(is.na(final.dataframe$n_specimens)),
          ## CD is measured across the cornea, which sits within the eyeball, so CD <= AD.
          ## Two rows print CD exactly equal to AD -- Marmosa sp. (7.3/7.3) and Hystrix
          ## cristata (11.2/11.2), both confirmed against the page renders; kept as printed.
          all(final.dataframe$corneal_diameter_mm <= final.dataframe$eye_axial_diameter_mm),
          sum(final.dataframe$corneal_diameter_mm == final.dataframe$eye_axial_diameter_mm) == 2L,
          ## the printed Order column: "Paramelemorphia" is the paper's own misprint and the
          ## only non-standard spelling, kept verbatim
          sum(final.dataframe$order_as_published == "Paramelemorphia") == 1L)

## 3b. TABLE CHECKS (HOWTO 7a): none -- the appendix prints no totals, percentages or other
## internal relation that could check itself.

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")
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
