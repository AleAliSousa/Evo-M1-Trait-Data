## Heffner_etal_2001_a_Figure6.R -- frozen snapshot -> analysis CSV (+ public TSV once registered)
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2001). Sound localization in a new-world
## frugivorous bat, Artibeus jamaicensis: Acuity, use of binaural cues, and relationship to
## vision. J. Acoust. Soc. Am. 109(1), 412-421. doi:10.1121/1.1329620
##
## FIG. 6 (p. 419): "Relationship between the width of the field of best vision ... and
## sound-localization threshold for 24 species of mammals (note logarithmic scale on both axes)
## ... r = 0.916, P < 0.0001." This is the PRIMARY version of the relationship that
## Heffner & Heffner (2016) Figure 5 reproduces for 22 species ("Modified from Heffner et al.,
## 2001") -- see Heffner_Heffner_2016_Figure5.
##
## SCOPE: roster only, matching the 2016 item (owner decision). The figure plots points, prints
## no coordinates, and its caption points elsewhere for the values ("for citations, see Heffner
## et al., 1994"), so this item records which 24 species the relationship rests on, their letter
## codes, the binomials the legend prints for each, and the printed statistics -- no measured
## value. The one value this PAPER contributes itself (Artibeus jamaicensis, 34 deg field of
## best vision) is in Heffner_etal_2001_a_ResultsText.
##
## Frozen source: Heffner_etal_2001_a_Figure6_snapshot.csv -- a CONSTRUCTED snapshot. Unlike the
## 2016 figure, this caption IS in the PDF text layer, so the legend was extracted from it; the
## text layer mis-maps some characters ("~"/"!" for parentheses, "5" for "=", "," for "<"), and
## the corrected caption was verified against a 200-dpi render of printed p. 419 (AI assistant,
## 2026-10-29).
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2001_a_Figure6"
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

## 2. LOAD (frozen constructed snapshot) ----------------------------
snap <- utils::read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = "character",
                        encoding = "UTF-8", check.names = FALSE)
stopifnot(identical(names(snap), c("element", "code", "printed_text", "figure_role")))
el <- function(x) snap$printed_text[snap$element == x]
caption <- el("caption");  stopifnot(length(caption) == 1L)
stats   <- el("statistic_caption"); stopifnot(length(stats) == 2L)
panel_r <- el("statistic_panel");   stopifnot(length(panel_r) == 1L)
sp      <- snap[snap$element == "species_label", , drop = FALSE]

## The legend prints "<common name> (<binomial>)" for each letter code.
common   <- trimws(sub("\\s*\\(.*$", "", sp$printed_text))
binomial <- trimws(sub("^.*\\(([^)]*)\\).*$", "\\1", sp$printed_text))
stopifnot(all(nzchar(common)), all(grepl("^[A-Z][a-z]+ [a-z]+$", binomial)))

## 2b. SPECIES (shared resolver; all 24 printed binomials resolve through existing spokes, so
## this paper adds no rows of its own -- including the printed "Mesocricetus auritus", which the
## key already carries as a spelling variant of M. auratus, and "Felis domesticus" -> Felis catus)
source(file.path(base, "_keys", "resolve_species.R"), local = TRUE)
res <- resolve_species(binomial, source_publication = basename(folder))
if (any(res$unresolved))
  stop("Printed binomial(s) not resolvable: ",
       paste(binomial[res$unresolved], collapse = "; "), call. = FALSE)

## 3. TABLE CHECKS (HOWTO 7a) --------------------------------------
## The caption states "24 species of mammals" and then lists the legend entries: the two must agree.
n_caption <- as.integer(sub(".*for ([0-9]+) species of mammals.*", "\\1", caption))
table_checks <- data.frame(
  check_id   = "legend_entries_vs_caption_n",
  basis      = "number of letter-coded legend entries vs the caption's '24 species of mammals'",
  observed   = nrow(sp), printed = n_caption, difference = nrow(sp) - n_caption, tolerance = 0,
  stringsAsFactors = FALSE)
table_checks$status <- ifelse(table_checks$difference == 0, "pass", "mismatch")
table_checks$note   <- "exact count; one legend entry per plotted point"
if (any(table_checks$status != "pass"))
  warning("Table check mismatch: ", table_checks$check_id, call. = FALSE)

## 4. BUILD -----------------------------------------------------------
final.dataframe <- tibble::tibble(
  figure_code            = sp$code,
  species_as_published   = binomial,
  common_name_as_printed = common,
  Species                = res$accepted_name,
  species_basis          = res$species_basis,
  in_figure6             = "Y",
  x_quantity             = el("axis_title_x"),
  y_quantity             = el("axis_title_y"),
  correlation_r          = sub("^r = ", "", stats[grepl("^r = ", stats)]),
  significance_printed   = stats[grepl("^P ", stats)],
  correlation_r_panel    = sub("^r = ", "", panel_r),
  x_axis_ticks_printed   = el("axis_ticks_x"),
  y_axis_ticks_printed   = el("axis_ticks_y"),
  n_species_printed      = n_caption,
  value_status           = paste("roster only: this item records figure membership, not point",
                                 "coordinates; the figure was not digitized (owner decision)"),
  value_sources_printed  = el("citation_note"),
  data_role              = "secondary",
  source_row             = which(snap$element == "species_label") + 1L)

stopifnot(nrow(final.dataframe) == 24L,
          length(unique(final.dataframe$figure_code)) == 24L,
          length(unique(final.dataframe$Species)) == 24L)

## 5. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")
## TSV is PREPARED until the owner pastes this paper's registry rows (see the ResultsText script).
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit       <- match(item_name, filecodes$`Item name`)
  if (is.na(hit)) {
    warning("No registry row for ", item_name,
            " yet -- public TSV pending the owner's registry paste (Progress stage: PREPARED).",
            call. = FALSE)
  } else {
    item_encoded <- filecodes$`Item encoded`[hit]
    if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
      stop("Registry row for ", item_name, " has no usable 'Item encoded'.", call. = FALSE)
    readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
  }
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
