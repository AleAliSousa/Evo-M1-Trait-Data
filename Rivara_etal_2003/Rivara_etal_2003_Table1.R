# Prepared reader; NOT executed in the preparation environment (R is absent).
# Counts retain cells, soma size retains µm³; never double left-hemisphere values.
expected_basename <- "Rivara_etal_2003_Table1.R"
candidates <- character()
for (frame in rev(sys.frames())) {
  for (field in c("ofile", "file")) {
    candidate <- frame[[field]]
    if (is.character(candidate) && length(candidate) == 1L &&
        !is.na(candidate) && basename(candidate) == expected_basename &&
        file.exists(candidate)) candidates <- c(candidates, candidate)
  }
}
if (!length(candidates)) {
  args <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", args[grepl("^--file=", args)])
  candidates <- candidates[basename(candidates) == expected_basename & file.exists(candidates)]
}
if (!length(candidates)) stop("Cannot locate this script by source/sys.source frame or own --file basename.")
base <- normalizePath(candidates[[1L]], winslash = "/", mustWork = TRUE)
folder <- dirname(base)
item_name <- tools::file_path_sans_ext(basename(base))

frozen <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                          header = FALSE, colClasses = "character", na.strings = NULL,
                          check.names = FALSE, fileEncoding = "UTF-8", blank.lines.skip = FALSE)
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
                           colClasses = "character", na.strings = NULL, check.names = FALSE,
                           fileEncoding = "UTF-8")
measurement_map <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_measurement_map.csv")),
                                   colClasses = "character", na.strings = NULL, check.names = FALSE,
                                   fileEncoding = "UTF-8")
stopifnot(nrow(context) == 1L, context$Ref == item_name, ncol(frozen) == 8L,
          !anyDuplicated(measurement_map$Code))
stopifnot(identical(unname(unlist(frozen[which(frozen[[1L]] == "Cases")[[1L]], ])),
                    c("Cases", "Betz cells", "CE", "Pyramidal cells", "CE", "Total", "CE", "Betz %")))
volume_header <- unname(unlist(frozen[which(frozen[[1L]] == "Cases")[[2L]], ]))
stopifnot(identical(volume_header, c("Cases", "Betz cells", "Pyramidal cells", "Betz/pyramidal cells", "", "", "", "")))

blocks <- list()
for (label in unique(measurement_map$block_label)) {
  start <- which(frozen[[1L]] == label)
  stopifnot(length(start) == 1L)
  following <- which(seq_len(nrow(frozen)) > start & frozen[[1L]] == "Cases")
  end <- if (length(following)) min(following) - 1L else nrow(frozen)
  section <- frozen[seq.int(start + 1L, end), , drop = FALSE]
  section <- section[section[[1L]] %in% c(LETTERS[1:6], "Mean", "SD", "CV"), , drop = FALSE]
  stopifnot(identical(section[[1L]], c(LETTERS[1:6], "Mean", "SD", "CV")))
  blocks[[label]] <- section
}
num <- function(x) {
  result <- rep(NA_real_, length(x))
  keep <- nzchar(x)
  result[keep] <- as.numeric(gsub(",", "", x[keep], fixed = TRUE))
  if (anyNA(result[keep])) stop("Non-numeric published measurement encountered.")
  result
}
measures <- function(labels) {
  result <- data.frame(row.names = seq_along(labels))
  for (i in seq_len(nrow(measurement_map))) {
    block <- blocks[[measurement_map$block_label[[i]]]]
    column <- as.integer(measurement_map$source_column[[i]])
    result[[measurement_map$Code[[i]]]] <- num(block[match(labels, block[[1L]]), column])
  }
  result
}
final.dataframe <- data.frame(
  Ref = rep(item_name, 6L), case_id = LETTERS[1:6],
  species_as_published = context$species_as_published, source_year = context$source_year,
  hemisphere = context$hemisphere, region = context$region, layer = context$layer,
  observation_level = "individual left hemisphere; case-level stereologic estimates",
  data_role = "primary",
  published_derived_measures = paste(measurement_map$Code[measurement_map$published_derived == "TRUE"], collapse = "; "),
  summary_key = context$summary_key, source_uncertainty = context$source_uncertainty,
  merge_gate = context$merge_gate, stringsAsFactors = FALSE, check.names = FALSE
)
final.dataframe <- cbind(final.dataframe, measures(final.dataframe$case_id))
published.summary <- data.frame(
  Ref = rep(item_name, 3L), summary_key = context$summary_key,
  summary_statistic = c("Mean", "SD", "CV"),
  observation_level = "published across-six-case summary; not an independent patient",
  data_role = "secondary", source_year = context$source_year,
  source_uncertainty = context$source_uncertainty,
  merge_gate = "HOLD_PUBLISHED_SUMMARY_REFERENCE_ONLY",
  stringsAsFactors = FALSE, check.names = FALSE
)
published.summary <- cbind(published.summary, measures(published.summary$summary_statistic))
stopifnot(nrow(final.dataframe) == 6L, nrow(published.summary) == 3L)
ce_codes <- measurement_map$Code[grepl("_CE$", measurement_map$Code)]
stopifnot(all(!is.na(as.matrix(final.dataframe[ce_codes]))),
          all(is.na(as.matrix(published.summary[ce_codes]))))
# Published percentages, ratios and summary statistics are preserved, not repaired.
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")
utils::write.csv(published.summary,
                 file.path(folder, "reference_tables", paste0(item_name, "_published_summary.csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

# A clean local R run and scientific review must precede the owner-controlled gate.
public_allowed <- identical(Sys.getenv("EVOM1_RIVARA_R_GATE"), "OWNER_VERIFIED_R_BUILD_AND_VALIDATION")
root <- dirname(folder)
item_encoded <- NULL
filecodes <- NULL
if (file.exists(file.path(root, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  required <- c("Item name", "Item number", "Item encoded")
  if (all(required %in% names(filecodes))) {
    match_rows <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
    if (length(match_rows) == 1L) {
      row <- match_rows[[1L]]
      number <- gsub("[[:space:]]", "", as.character(filecodes$`Item number`[[row]]))
      code <- as.character(filecodes$`Item encoded`[[row]])
      if (!is.na(number) && number == "Table1" && !is.na(code) && nzchar(code) &&
          !grepl("_$|[/\\\\]", code) && !code %in% c("notfound", "NA")) item_encoded <- code
    }
  }
}
if (is.null(item_encoded)) {
  message("PUBLIC_TSV_WITHHELD: OWNERREGISTRY_UPDATE_REQUIRED; corrected fresh Item name/number/code unavailable. No fallback code.")
} else if (!public_allowed) {
  message("PUBLIC_TSV_WITHHELD: owner R/scientific release gate pending; local CSVs only.")
} else {
  # Public target is repository-level, never nested inside the paper or staging.
  public_folder <- file.path(root, "__Public", "comparative-data")
  if (!dir.exists(public_folder)) stop("Authoritative repository __Public/comparative-data directory is not mounted; no fallback export.")
  utils::write.table(final.dataframe, file.path(public_folder, paste0(item_encoded, ".tsv")),
                     sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message("Owner-gated public case CSV export completed; summary reference is not a public trait TSV.")
}
