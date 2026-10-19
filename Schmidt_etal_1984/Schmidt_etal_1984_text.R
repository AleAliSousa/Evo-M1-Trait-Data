## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"))) Sys.setenv(EVOM1_ALLOW_PUBLIC_TSV = "YES")
# Frozen text snapshot + item-scoped source context -> analysis CSV.
# PREPARED / R_PENDING: this script has not been executed in this environment.
.sp <- local({
  saved_R <- function(p) is.character(p) && length(p) == 1L && !is.na(p) &&
    grepl("\\.[Rr]$", p) && file.exists(p)
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (saved_R(of)) return(normalizePath(of, mustWork = TRUE))
    sf <- tryCatch(fr[[k]]$file, error = function(e) NULL)
    if (saved_R(sf)) return(normalizePath(sf, mustWork = TRUE))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  p <- if (length(a) == 1L) sub("^--file=", "", a) else NULL
  if (saved_R(p)) return(normalizePath(p, mustWork = TRUE))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (saved_R(p)) return(normalizePath(p, mustWork = TRUE))
  }
  stop("Run this saved item with Rscript or source().", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("Place this item in the repository before running.")
  d
})
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", stringsAsFactors = FALSE,
                 check.names = FALSE, na.strings = character(), fileEncoding = "UTF-8")
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
                    colClasses = "character", stringsAsFactors = FALSE,
                    check.names = FALSE, na.strings = character(), fileEncoding = "UTF-8")
stopifnot(!anyDuplicated(snap$Trait), !anyDuplicated(context$Trait),
          setequal(snap$Trait, context$Trait))
context <- context[match(snap$Trait, context$Trait), , drop = FALSE]
num <- function(x) {
  x <- gsub("−", "-", trimws(x), fixed = TRUE)
  x <- gsub("°", "", x, fixed = TRUE)
  ok <- grepl("^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)$", x)
  out <- rep(NA_real_, length(x))
  out[ok] <- as.numeric(x[ok])
  out
}
# Values retain their source units; only degree glyphs/minus glyphs are parsed.
final.dataframe <- data.frame(
  source_row_id = context$source_row_id,
  species_as_published = snap$Species,
  common_name_as_published = snap$`Common name`,
  measurement = context$measurement,
  value_as_printed = snap$Value,
  value = num(snap$Value),
  unit = snap$Unit,
  source_location = snap$Source_location,
  source_note = snap$Source_note,
  stringsAsFactors = FALSE, check.names = FALSE
)
for (nm in setdiff(names(context), c("Trait", "source_row_id", "measurement")))
  final.dataframe[[nm]] <- context[[nm]]
for (nm in c("criterion_value", "burst_duration_ms", "bursts_per_trial",
             "interburst_interval_ms", "stimulus_frequency_low_kHz",
             "stimulus_frequency_high_kHz", "test_separation_degrees", "n_main", "n_corroborating"))
  final.dataframe[[nm]] <- num(final.dataframe[[nm]])
# Frequency magnitudes are converted only for Hz/kHz observations, never dB.
final.dataframe$frequency_Hz <- ifelse(final.dataframe$unit == "Hz", final.dataframe$value,
  ifelse(final.dataframe$unit == "kHz", final.dataframe$value * 1000, NA_real_))
final.dataframe$threshold_dB_SPL <- ifelse(final.dataframe$unit == "dB SPL",
                                          final.dataframe$value, NA_real_)
# Overall threshold-range endpoints have no assigned observation frequency.
linked <- final.dataframe$unit == "dB SPL" &
  !grepl("range_endpoint", final.dataframe$statistic) &
  !is.na(final.dataframe$stimulus_frequency_low_kHz) &
  !is.na(final.dataframe$stimulus_frequency_high_kHz)
point <- linked & final.dataframe$stimulus_frequency_low_kHz == final.dataframe$stimulus_frequency_high_kHz
interval <- linked & final.dataframe$stimulus_frequency_low_kHz < final.dataframe$stimulus_frequency_high_kHz
final.dataframe$threshold_frequency_Hz <- ifelse(point,
  final.dataframe$stimulus_frequency_low_kHz * 1000, NA_real_)
final.dataframe$threshold_frequency_low_Hz <- ifelse(interval,
  final.dataframe$stimulus_frequency_low_kHz * 1000, NA_real_)
final.dataframe$threshold_frequency_high_Hz <- ifelse(interval,
  final.dataframe$stimulus_frequency_high_kHz * 1000, NA_real_)
# Fresh exact-name registry lookup; no cached row number or encoded literal.
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package readxl is required.")
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
row <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
if (length(row) != 1L) stop("Registry must contain exactly one matching Item name.")
item_encoded <- as.character(filecodes$`Item encoded`[row])
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded) ||
    grepl("[/\\\\]", item_encoded)) stop("Invalid registry Item encoded; export withheld.")
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
# This prepared batch deliberately leaves shared publication unattempted by default.
if (identical(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"), "YES")) {
  if (!dir.exists(file.path(base, "__Public", "comparative-data")))
    stop("Canonical public directory is absent; do not create an alternative TSV.")
  if (file.exists(file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))))
    stop("An existing public TSV requires owner conflict review; no overwrite performed.")
  utils::write.table(final.dataframe,
              file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("Shared publication not attempted in this prepared batch; older upload approvals unaffected; R and live-code checks pending.")
