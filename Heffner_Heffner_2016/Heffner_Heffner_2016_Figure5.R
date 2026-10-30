## Heffner_Heffner_2016_Figure5.R -- frozen snapshot -> analysis CSV + public TSV
##
## Heffner, H. E., & Heffner, R. S. (2016). The evolution of mammalian sound localization.
## Acoustics Today, 12(1), 20-27.
##
## FIGURE 5 (p. 24): "Relationship between the width of the field of best vision (75% isodensity
## contour) and sound-localization thresholds for 22 species of mammals ... Modified from Heffner
## et al. (2001)" -- a log-log scatter with r = .89, p < .001, n = 22.
##
## SCOPE OF THIS ITEM (owner decision, 2026-10-29): the figure's point coordinates are NOT
## digitized. What is captured is what the figure states exactly: which 22 species the
## relationship rests on, the two axis quantities, and the printed regression statistics. The
## numeric values behind the points belong to the cited primary -- Heffner, R. S., Koay, G., &
## Heffner, H. E. (2001), J. Acoust. Soc. Am. 109, 412-421 -- which is not yet in the registry,
## and to Heffner_Heffner_1992_a_TABLE1, which tabulates both quantities for 10 of these species.
## So every row here carries a species identity and provenance, and no measured value.
##
## Frozen source: Heffner_Heffner_2016_Figure5_snapshot.csv -- a CONSTRUCTED snapshot (snapshot
## HOWTO: "constructed snapshots from figures/text"). The figure's internal text is outlined in
## the PDF, so there is no text layer to extract: the 22 labels, both axis titles, the tick
## labels and the two statistic lines were transcribed by hand from a 420-dpi render of p. 24 and
## verified against it (AI assistant, 2026-10-29). The caption itself comes from the page's text
## layer. This script READS that file; it contains no transcribed content of its own.
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_2016_Figure5"
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
stopifnot(identical(names(snap), c("element", "printed_text", "figure_role")))
el <- function(x) snap$printed_text[snap$element == x]
caption  <- el("caption");       stopifnot(length(caption) == 1L)
axis_x   <- el("axis_title_x");  axis_y <- el("axis_title_y")
ticks_x  <- el("axis_ticks_x");  ticks_y <- el("axis_ticks_y")
stats    <- el("statistic");     stopifnot(length(stats) == 2L)
sp_lab   <- el("species_label")

## 2b. SPECIES KEY (collection-scoped: _keys/General; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
## local = TRUE so the resolver is defined in THIS script's evaluation environment: under
## build_dataset_item() the script runs via sys.source() in an env whose parent is baseenv(),
## where a default source() (which evaluates into globalenv()) would be invisible.
source(file.path(base, "_keys", "resolve_species.R"), local = TRUE)
res <- resolve_species(sp_lab, source_publication = basename(folder))
if (any(res$unresolved))
  stop("Printed label(s) not resolvable: ", paste(sp_lab[res$unresolved], collapse = "; "),
       " -- add a row to _keys/General/species_key.csv.", call. = FALSE)

## 3. TABLE CHECKS (HOWTO 7a) --------------------------------------
## The figure checks itself in one way: it prints n = 22 and its caption says "22 species",
## and the panel carries one label per plotted point. All three must agree.
n_printed  <- as.integer(sub(".*n = ([0-9]+).*", "\\1", stats[grepl("n = ", stats)]))
n_caption  <- as.integer(sub(".*for ([0-9]+) species of mammals.*", "\\1", caption))
table_checks <- data.frame(
  check_id   = c("label_count_vs_printed_n", "label_count_vs_caption_n"),
  basis      = c("number of species labels in the panel vs the printed 'n = 22'",
                 "number of species labels in the panel vs the caption's '22 species of mammals'"),
  observed   = rep(length(sp_lab), 2L),
  printed    = c(n_printed, n_caption),
  difference = c(length(sp_lab) - n_printed, length(sp_lab) - n_caption),
  tolerance  = c(0, 0),
  stringsAsFactors = FALSE)
table_checks$status <- ifelse(table_checks$difference == 0, "pass", "mismatch")
table_checks$note   <- "exact counts; a label is a plotted data point"
if (any(table_checks$status != "pass"))
  warning("Table check mismatch(es): ",
          paste(table_checks$check_id[table_checks$status != "pass"], collapse = ", "), call. = FALSE)

## 4. BUILD -----------------------------------------------------------
final.dataframe <- tibble::tibble(
  species_as_published = sp_lab,
  Species              = res$accepted_name,
  species_basis        = res$species_basis,
  in_figure5           = "Y",
  x_quantity           = axis_x,
  y_quantity           = axis_y,
  x_axis_ticks_printed = ticks_x,
  y_axis_ticks_printed = ticks_y,
  correlation_r        = sub("^r = ", "", stats[grepl("^r = ", stats)]),
  significance_printed = stats[grepl("^p ", stats)],
  n_species_printed    = n_printed,
  value_status         = paste("roster only: this item records figure membership, not point",
                               "coordinates; the figure was not digitized (owner decision)"),
  primary_source       = paste("Heffner, R. S., Koay, G., & Heffner, H. E. (2001).",
                               "J. Acoust. Soc. Am. 109, 412-421 (cited as the figure's source);",
                               "Heffner_Heffner_1992_a_TABLE1 tabulates both quantities for 10 of these species"),
  data_role            = "secondary",
  source_row           = which(snap$element == "species_label"))

stopifnot(nrow(final.dataframe) == 22L,
          length(unique(final.dataframe$species_as_published)) == 22L,
          !any(is.na(final.dataframe$Species)))

## 5. WRITE CSV + PUBLIC TSV ------------------------------------------
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
if (any(table_checks$status != "pass"))
  print(as.data.frame(table_checks[table_checks$status != "pass", ]))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
