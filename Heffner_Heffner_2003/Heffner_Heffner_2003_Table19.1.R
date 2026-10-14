# Printed Table 19.1 is a secondary compilation, never a primary merge input.
base <- local({
  for (fr in rev(sys.frames())) {
    if (!is.null(fr$ofile) && grepl("_Table19\\.1\\.R$", fr$ofile))
      return(normalizePath(fr$ofile, mustWork = TRUE))
  }
  argv <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(argv) == 1L)
    return(normalizePath(sub("^--file=", "", argv), mustWork = TRUE))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path, mustWork = TRUE))
  stop("Run with Rscript, source(), or from the active RStudio script.")
})
folder <- dirname(base)
item_name <- tools::file_path_sans_ext(basename(base))
base <- dirname(folder)

snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     header = FALSE, colClasses = "character", check.names = FALSE,
                     na.strings = NULL, fileEncoding = "UTF-8", stringsAsFactors = FALSE)
stopifnot(ncol(snapshot) == 4L,
          identical(unname(as.character(snapshot[2L, ])),
                    c("Species", "Midline acuity", "Binaural phase cue", "Binaural intensity cue")))
data <- snapshot[grepl("^[0-9]+(\\.[0-9]+)?\u00b0(\\*\\*)?$", snapshot[[2L]]), , drop = FALSE]
stopifnot(nrow(data) == 37L, !anyDuplicated(data[[1L]]))
notes <- snapshot[[1L]][grepl("^(Dashes indicate|\\* )|^\\*\\* ", snapshot[[1L]])]
stopifnot(length(notes) == 3L)
cue <- function(x) {
  stopifnot(all(x %in% c("yes", "yes*", "no", "\u2014")))
  ifelse(x == "\u2014", NA_integer_, as.integer(sub("\\*$", "", x) == "yes"))
}

# Angular degrees are retained; stripping the degree mark is not a unit conversion.
final.dataframe <- data.frame(
  source_row = seq_len(nrow(data)),
  Species_HeffnerHeffner2003 = data[[1L]],
  Midline_acuity_as_published = data[[2L]],
  Midline_acuity_deg = as.numeric(sub("\u00b0(\\*\\*)?$", "", data[[2L]])),
  Binaural_phase_cue_as_published = data[[3L]],
  Binaural_phase_cue_usable = cue(data[[3L]]),
  Binaural_intensity_cue_as_published = data[[4L]],
  Binaural_intensity_cue_usable = cue(data[[4L]]),
  intensity_upper_octaves_caveat_flag = as.integer(grepl("\\*$", data[[4L]])),
  click_stimulus_flag = as.integer(grepl("\\*\\*$", data[[2L]])),
  localization_stimulus = ifelse(grepl("\\*\\*$", data[[2L]]), "clicks", "broadband noise"),
  intensity_note = ifelse(grepl("\\*$", data[[4L]]), notes[grepl("^\\* ", notes)], ""),
  localization_note = ifelse(grepl("\\*\\*$", data[[2L]]), notes[grepl("^\\*\\* ", notes)], ""),
  data_role = "secondary",
  observation_level = "published common-name taxon summary",
  Reference = item_name,
  check.names = FALSE, stringsAsFactors = FALSE
)
stopifnot(!anyNA(final.dataframe$Midline_acuity_deg))
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

if ("--analysis-only" %in% commandArgs(TRUE)) {
  message("Analysis CSV built only; registration, public TSV, and full validation are pending.")
} else {
  if (!requireNamespace("readxl", quietly = TRUE))
    stop("Analysis CSV built. Install readxl to read the registry; no public TSV was written.")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  registered <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
  if (length(registered) == 0L) {
    warning("UNREGISTERED: analysis CSV built; owner must paste the proposed row and run file_list.R. No public TSV name is authorised.")
  } else {
    stopifnot(length(registered) == 1L)
    item_encoded <- filecodes[["Item encoded"]][registered]
    if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded) ||
        grepl("[/\\\\]", item_encoded))
      stop("Registry Item encoded is missing or malformed; public TSV withheld.")
    if (filecodes[["Data role (primary/secondary/both)"]][registered] != "secondary")
      stop("This compilation must be registered with Data role = secondary.")
    if (!dir.exists(file.path(base, "__Public", "comparative-data")))
      stop("Public comparative-data folder is not mounted; no substitute TSV filename is permitted.")
    write.table(final.dataframe,
                file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
    message("CSV and registry-authorised public TSV built. Run build_dataset_item() validation; do not merge this secondary compilation as primary.")
  }
}
