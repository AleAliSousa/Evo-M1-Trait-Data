## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"))) Sys.setenv(EVOM1_ALLOW_PUBLIC_TSV = "validated")
## Braitenberg & Schuz (1998), Fig. 62 (book p. 133; PDF p. 131): frequency distribution of the
## distances spanned by homolateral cortico-cortical connections in the mouse (Greilich, 1984).
## Digitized by Microsoft Copilot AI assistant on 2026-10-22 (America/Los_Angeles) from the embedded
## 553 x 389 px, 150 ppi greyscale figure image. This is AI digitization, NOT human visual curation.
## The snapshot freezes pixel readings; this script converts them to neuron counts. No count is
## typed in by hand anywhere. R execution and canonical build/validate remain pending; not FINISHED.
options(scipen = 999)
.sp <- local({
  is_me <- function(p) is.character(p) && length(p) == 1L && grepl("_Figure62\\.R$", p) && file.exists(p)
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    for (name in c("ofile", "file")) {
      p <- tryCatch(get(name, envir = fr[[k]], inherits = FALSE), error = function(e) NULL)
      if (is_me(p)) return(normalizePath(p))
    }
  }
  a <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(a) == 1L && is_me(a)) return(normalizePath(a))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (is_me(p)) return(normalizePath(p))
  }
  stop("Run this file with Rscript, source()/sys.source(), or save and Source in RStudio.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
read_source <- function(path) utils::read.csv(path, colClasses = "character",
  stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8", na.strings = "")
snap <- read_source(file.path(folder, paste0(item_name, "_snapshot.csv")))
cal <- read_source(file.path(folder, "reference_tables", paste0(item_name, "_calibration.csv")))
stopifnot(identical(names(snap), c("bin_order", "bin_start_mm", "bin_end_mm", "edge_left_px",
                                   "edge_right_px", "interior_cols_sampled", "bar_top_y_px", "reading_note")),
          !anyDuplicated(cal$key))
num <- function(k) {
  v <- as.numeric(cal$value[cal$key == k])
  stopifnot(length(v) == 1L, !is.na(v))
  v
}

## x calibration: least-squares line through the 11 printed major ticks (0-10 mm)
tick_mm <- 0:10
tick_px <- vapply(tick_mm, function(m) num(paste0("x_tick_", m, "_mm_px")), numeric(1))
xfit <- stats::lm(tick_px ~ tick_mm)
x0 <- unname(stats::coef(xfit)[1])
px_per_mm <- unname(stats::coef(xfit)[2])
stopifnot(max(abs(stats::residuals(xfit))) < 1.5)

## y calibration: x-axis line (0 neurons) and the single printed tick labelled 100
baseline_at <- function(x) num("baseline_intercept_y_px") + num("baseline_slope_dy_per_dx") * x
px_per_100 <- baseline_at(num("y_axis_x_px")) - num("y_tick_100_y_px")
stopifnot(px_per_100 > 45, px_per_100 < 60)

b_start <- as.numeric(snap$bin_start_mm)
b_end <- as.numeric(snap$bin_end_mm)
edge_l <- as.numeric(snap$edge_left_px)
edge_r <- as.numeric(snap$edge_right_px)
top <- as.numeric(snap$bar_top_y_px)              # NA: no bar distinguishable in that slot
stopifnot(nrow(snap) == 68L, !anyNA(b_start), !anyNA(b_end), !anyNA(edge_l), !anyNA(edge_r),
          all(abs(b_end - b_start - 0.1) < 1e-9), all(abs(diff(b_start) - 0.1) < 1e-9),
          all(abs((edge_l - x0) / px_per_mm - b_start) < 0.03),   # drawn edges agree with bin labels
          all(abs((edge_r - x0) / px_per_mm - b_end) < 0.03))
height_px <- ifelse(is.na(top), 0, baseline_at((edge_l + edge_r) / 2) - top)
stopifnot(all(height_px >= 0))
count <- height_px * 100 / px_per_100

final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  species_as_published = "mouse",
  measure_code = "neurons_per_distance_bin",
  bin_start_mm = b_start,
  bin_end_mm = b_end,
  bin_mid_mm = (b_start + b_end) / 2,
  count_digitized = round(count, 1),
  count_rounded = round(count),
  height_px = round(height_px, 2),
  px_per_100_neurons = round(px_per_100, 3),
  value_origin = "digitized_from_figure",
  reading_note = snap$reading_note,
  data_role = "primary (first publication of Greilich 1984 unpublished thesis data)",
  source_ref_key = "Greilich (1984)",
  source_locus = "Fig. 62",
  source_pdf_page = 131L,
  source_printed_page = 133L,
  source_year = 1998L,
  stringsAsFactors = FALSE, check.names = FALSE
)

## Checks against what the book prints about this figure (caption p. 133; text p. 132)
total <- sum(count)
mean_mm <- sum(count * final.dataframe$bin_mid_mm) / total
stopifnot(b_start[which.max(count)] == 2.0,                 # tallest bar 2.0-2.1 mm
          min(b_start[count > 0]) == 0.2,                   # "from less than 1 ..."
          max(b_end[count > 0]) == 7.0)                     # "... about 7 mm" longest fibres
second <- which(b_start >= 3.0)[which.max(count[b_start >= 3.0])]
stopifnot(b_start[second] >= 3.4, b_start[second] <= 3.8)  # caption: indication of a second peak
message(sprintf(paste0("Fig. 62: %d bins, about %.0f neurons in total (digitized), mean distance %.2f mm ",
                       "(bin midpoints). Zhang & Sejnowski 2000 read L of about 3 mm from this histogram."),
                nrow(final.dataframe), total, mean_mm))

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

## Fresh registry authority is resolved only by Item name; no cached row fallback.
item_encoded <- NA_character_
if (!is.na(base) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  matches <- which(nfc(filecodes$`Item name`) == nfc(item_name))
  if (length(matches) == 1L) item_encoded <- filecodes$`Item encoded`[matches]
}
authority <- length(item_encoded) == 1L && !is.na(item_encoded) &&
             nzchar(item_encoded) && !grepl("_$|[/\\\\]", item_encoded)
if (authority && identical(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"), "validated")) {
  if (!dir.exists(file.path(base, "__Public", "comparative-data"))) {
    warning("Public destination unavailable; TSV withheld.")
  } else {
    utils::write.table(final.dataframe,
                       file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                       sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  }
} else warning("Public TSV withheld: fresh authority and explicit post-validation publication gate required.")
