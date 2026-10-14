# Frozen published view -> analysis CSV. R execution is NOT certified here.
self_candidates <- character()
for (frame in rev(sys.frames())) {
  for (key in c("ofile", "file")) {
    value <- frame[[key]]
    if (is.character(value) && length(value) == 1L) self_candidates <- c(self_candidates, value)
  }
}
self_candidates <- self_candidates[grepl("_TABLE2\\.R$", basename(self_candidates))]
if (!length(self_candidates)) {
  argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(argument)) self_candidates <- sub("^--file=", "", argument)
}
if (!length(self_candidates) || !grepl("_TABLE2\\.R$", basename(self_candidates[1L])))
  stop("Cannot identify the exact saved item reader from source frames or --file.")
self <- normalizePath(self_candidates[1L], winslash = "/", mustWork = TRUE)
folder <- dirname(self)
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(self))
item_encoded <- NA_character_
frozen <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
  colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
if (anyDuplicated(context$cortical_area) || any(context$Reference != item_name) ||
    length(unique(context$source_doi)) != 1L || unique(context$source_doi) != "10.1002/ar.a.20217" ||
    any(context$species_as_published != "Papio ursinus")) stop("Item context identity failure.")
attach_context <- function(data) {
  index <- match(data$cortical_area, context$cortical_area)
  if (anyNA(index)) stop("Missing area context.")
  selected <- context[index, setdiff(names(context), "cortical_area"), drop = FALSE]
  selected$body_mass_g <- as.numeric(selected$body_mass_kg_as_published) * 1000
  selected$body_mass_kg_as_published <- NULL
  for (key in intersect(c("source_page", "n_animals", "section_thickness_um", "area_multiplier",
                          "n_dendrites_selected", "n_bin_contributors"), names(selected)))
    selected[[key]] <- as.numeric(selected[[key]])
  for (key in intersect(c("merge_eligible", "n_bin_contributors_known"), names(selected)))
    selected[[key]] <- as.logical(selected[[key]])
  rownames(selected) <- NULL
  cbind(data, selected)
}
parse_cell <- function(value) {
  bold <- grepl("**", value, fixed = TRUE)
  peak <- grepl("ᵃ", value, fixed = TRUE)
  clean <- trimws(gsub("ᵃ", "", gsub("**", "", value, fixed = TRUE), fixed = TRUE))
  if (clean %in% c("", "–", "—", "-")) return(list(mean = NA_real_, sem = NA_real_, mean_text = "", sem_text = "", status = if (clean == "") "blank" else "dash", bold = bold, peak = peak))
  parts <- trimws(strsplit(clean, "±", fixed = TRUE)[[1L]])
  if (length(parts) > 2L || any(!grepl("^[0-9]+([.][0-9]+)?$", parts))) stop("Unrecognised printed numeric cell.")
  list(mean = as.numeric(parts[1L]), sem = if (length(parts) == 2L) as.numeric(parts[2L]) else NA_real_,
       mean_text = parts[1L], sem_text = if (length(parts) == 2L) parts[2L] else "",
       status = if (length(parts) == 2L) "mean_sem" else if (parts[1L] == "0") "bare_zero" else "bare_number", bold = bold, peak = peak)
}
data <- frozen[3:7, , drop = FALSE]
if (!identical(data[[1L]], context$cortical_area)) stop("Printed area order differs from context.")
if (length(unique(context$n_cells_source_item)) != 1L ||
    any(context$n_cells_source_column != "n")) stop("Ambiguous sample-size dependency.")
dependency_name <- unique(context$n_cells_source_item)
dependency <- utils::read.csv(file.path(folder, paste0(dependency_name, "_snapshot.csv")), header = FALSE,
  colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
if (!grepl("TABLE 1. Basal dendritic", dependency[1L, 1L], fixed = TRUE) ||
    dependency[2L, 2L] != "n") stop("Sample-size dependency is not the published Table 1.")
rows <- vector("list", nrow(data) * (ncol(data) - 1L))
i <- 0L
for (a in seq_len(nrow(data))) for (column in 2:ncol(data)) {
  i <- i + 1L
  parsed <- parse_cell(data[a, column])
  sample_index <- match(data[a, 1L], dependency[3:7, 1L])
  if (is.na(sample_index)) stop("Missing Table 1 cell sample size.")
  radius <- as.numeric(sub(" μm$", "", frozen[2L, column]))
  rows[[i]] <- data.frame(cortical_area = data[a, 1L], radius_um = radius,
    n_cells = as.integer(dependency[sample_index + 2L, 2L]),
    value_as_printed = data[a, column], mean_as_printed = parsed$mean_text,
    sem_as_printed = parsed$sem_text, sholl_intersections_mean = parsed$mean,
    sholl_intersections_sem = parsed$sem, value_status = parsed$status,
    source_bold_mean = parsed$bold, source_peak_footnote_a = parsed$peak, stringsAsFactors = FALSE)
}
final.dataframe <- attach_context(do.call(rbind, rows))
if (anyNA(final.dataframe$n_animals) || any(final.dataframe$n_animals != 1L)) stop("Animal sample context invalid.")
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
# Re-read the actual registry on each invocation; never use a cached row number or guessed encoded name.
registered <- FALSE
publication_allowed <- FALSE
if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("readxl is required for the current registry lookup.")
  filecodes <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"), stringsAsFactors = FALSE)
  required <- c("Item name", "Item encoded", "Publication name", "DOI (or Alt)", "Item number", "Citation (APA 7th-Annotated)", "Flags active (skips)")
  if (!all(required %in% names(filecodes))) stop("Registry headers do not match the required named schema.")
  matches <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
  if (length(matches) > 1L) stop("Duplicate exact registry item name.")
  if (length(matches) == 1L) {
    registered <- TRUE
    row <- filecodes[matches, , drop = FALSE]
    citation <- row$`Citation (APA 7th-Annotated)`
    if (is.na(row$`Publication name`) || row$`Publication name` != basename(folder) ||
        is.na(row$`DOI (or Alt)`) || utils::URLdecode(row$`DOI (or Alt)`) != unique(context$source_doi) ||
        is.na(row$`Item number`) || gsub("[[:space:]]", "", row$`Item number`) != sub("^.*_", "", item_name) ||
        is.na(citation) || !grepl("chacma baboon", citation, ignore.case = TRUE) ||
        !grepl("Papio ursinus", citation, fixed = TRUE) || !grepl(unique(context$source_doi), citation, fixed = TRUE))
      stop("Current registry disagrees with verified baboon article identity; CSV remains analysis-only.")
    item_encoded <- row$`Item encoded`
    if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded) || grepl("[/\\]", item_encoded))
      stop("Current registry has no safe exact encoded item stem.")
    skip <- row$`Flags active (skips)`
    publication_allowed <- !(!is.na(skip) && nzchar(trimws(skip))) &&
      isTRUE(getOption("evom1.publish", FALSE)) && isTRUE(getOption("evom1.elston_owner_release", FALSE))
  }
}

if (publication_allowed) {
  dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
    sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message(if (registered) "Analysis CSV only: publication gate is closed; no public TSV written." else
    "Analysis CSV only: exact registration absent; no encoded name guessed and no public TSV written.")
}
