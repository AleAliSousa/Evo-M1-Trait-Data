# Rockel Table 3: frozen printed grid plus item-scoped methods context.
# Retain raw profile-count units; no surface, volume or shrinkage conversion.
.local_file <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    file.exists(x) && basename(x) == "Rockel_etal_1980_TABLE3.R"
}
.script <- NULL
.frames <- sys.frames()
if (length(.frames)) {
  for (.frame in rev(.frames)) {
    for (.key in c("ofile", "file")) {
      .candidate <- .frame[[.key]]
      if (.local_file(.candidate)) {
        .script <- .candidate
        break
      }
    }
    if (!is.null(.script)) break
  }
}
if (is.null(.script)) {
  .args <- commandArgs(trailingOnly = FALSE)
  .args <- .args[startsWith(.args, "--file=")]
  if (length(.args)) {
    .candidate <- sub("^--file=", "", .args[[1L]])
    if (.local_file(.candidate)) .script <- .candidate
  }
}
if (is.null(.script) && interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
  .candidate <- rstudioapi::getActiveDocumentContext()$path
  if (.local_file(.candidate)) .script <- .candidate
}
if (is.null(.script)) {
  .candidate <- file.path(getwd(), "Rockel_etal_1980_TABLE3.R")
  if (.local_file(.candidate)) .script <- .candidate
}
if (is.null(.script)) stop("Source or run the saved Rockel Table 3 reader.")
.script <- normalizePath(.script, winslash = "/", mustWork = TRUE)
folder <- dirname(.script)
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(.script))

.snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
  header = FALSE, colClasses = "character", check.names = FALSE,
  na.strings = character(), blank.lines.skip = FALSE, fileEncoding = "UTF-8")
.context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", check.names = FALSE, na.strings = character(), fileEncoding = "UTF-8")
if (nrow(.snapshot) != 9L || ncol(.snapshot) != 8L ||
    .snapshot[1L, 1L] != "TABLE 3. COMPARISON OF CELL COUNTS") stop("Unexpected frozen grid.")
.headers <- unlist(.snapshot[2L, 2:8], use.names = FALSE)
if (!identical(.headers, c("Motor", "Somato-sensory", "Frontal", "Temporal", "Parietal", "Visual", "Mean of means"))) {
  stop("Published column order differs.")
}
.labels <- .snapshot[3:7, 1L]
if (!identical(.labels, c("Mouse", "Rat", "Cat", "Monkey", "Man")) ||
    anyDuplicated(.context$Species_Rockel1980) ||
    !setequal(.context$Species_Rockel1980, .labels)) stop("Species/context join is not one-to-one.")
.context <- .context[match(.labels, .context$Species_Rockel1980), , drop = FALSE]
.numeric_context <- c("Biological_n", "Technical_samples_per_animal_per_area", "Traverses_per_technical_sample",
                      "Strip_width_um", "Section_thickness_um")
for (.code in .numeric_context) {
  .context[[.code]] <- as.numeric(.context[[.code]])
  if (anyNA(.context[[.code]])) stop("Invalid numeric sampling metadata.")
}
.context <- .context[, names(.context) != "Context_source_locus", drop = FALSE]
.rows <- vector("list", length(.labels) * length(.headers))
.k <- 0L
for (.i in seq_along(.labels)) {
  for (.j in seq_along(.headers)) {
    .k <- .k + 1L
    .raw <- .snapshot[.i + 2L, .j + 1L]
    .aggregate <- .j == length(.headers)
    .missing <- .raw == "—"
    if (.missing && !.aggregate) stop("Unexpected missing cortical-area count.")
    .mean <- .sd <- NA_real_
    if (!.missing) {
      if (!grepl("^[0-9]+\\.[0-9]+ ± [0-9]+\\.[0-9]+$", .raw)) stop("Invalid published mean/SD string.")
      .parts <- strsplit(.raw, " ± ", fixed = TRUE)[[1L]]
      .mean <- as.numeric(.parts[[1L]])
      .sd <- as.numeric(.parts[[2L]])
    }
    .type <- if (.missing) "missing_author_aggregate" else if (.aggregate) "printed_author_aggregate" else "species_area_summary"
    .dependency <- if (.aggregate) {
      "Dependent author mean of six area means; not a seventh area or additional animals; retain missing positions."
    } else if (.labels[[.i]] == "Monkey") {
      "Same six mean/SD pairs as Table 2 (Visual there labelled Striate); do not ingest Table 2 again; same cohort across areas."
    } else {
      "Same biological cohort across six areas; printed mean of means is dependent, not an additional observation."
    }
    .laterality <- if (.aggregate) {
      "Not an area measurement; constituent laterality not combined or multiplied."
    } else if (.labels[[.i]] == "Man" && .headers[[.j]] == "Visual") {
      "Both hemispheres sampled (posterior/middle calcarine sulcus); not a bilateral whole-structure total."
    } else "Unstated for this position; no hemisphere multiplication."
    .anatomy <- if (.aggregate) {
      "Author aggregate of six printed areas; no cortical-area assignment."
    } else if (.headers[[.j]] == "Visual") {
      "Area 17 in source methods/results; retain the Table 3 label Visual."
    } else if (.labels[[.i]] %in% c("Monkey", "Man")) {
      switch(.headers[[.j]], Motor = "Source context: motor area 4; no cross-species homology imposed.",
        `Somato-sensory` = "Source context: somatic sensory cortex; monkey results discuss areas 3b, 1 and 2; no new subarea rows.",
        Frontal = "Source context: probably area 9 (author qualifier retained).",
        Temporal = "Source context: area 22 of superior temporal gyrus.",
        Parietal = "Source context: area 7.")
    } else "Published area label retained; no imported primate Brodmann mapping."
    .visual_note <- if (.labels[[.i]] == "Man" && (.headers[[.j]] == "Visual" || .aggregate)) {
      .context$Human_visual_restaining_note[[.i]]
    } else ""
    .joined <- .context[.i, , drop = FALSE]
    .joined$Human_visual_restaining_note <- NULL
    .rows[[.k]] <- cbind(data.frame(
      Record_ID = paste0(item_name, "_r", .i, "_c", .j),
      Source_row_order = .i, Source_column_order = .j,
      Position_as_published = .headers[[.j]],
      Cortical_area_as_published = if (.aggregate) "" else .headers[[.j]],
      Record_type = .type,
      Observation_level = if (.aggregate) "dependent_author_aggregate_position" else "species_by_area_mean_of_technical_profile_counts",
      Value_as_published = .raw, Count_mean = .mean, Count_SD = .sd,
      Laterality = .laterality, Anatomy_note = .anatomy, Visual_restaining_note = .visual_note,
      Dependency_note = .dependency,
      Data_role = if (.missing) "info" else if (.aggregate) "derived_author_summary" else "primary",
      Primary_area_record = !.aggregate && !.missing,
      Merge_eligible = FALSE,
      Merge_hold = "HOLD: historical profile method; collection-specific taxonomy/anatomy and owner method-compatible route pending; not modern unbiased counts.",
      Source_locus = "Table 3, printed p.226; methods pp.221-223; discussion pp.230-232",
      Reference = item_name, stringsAsFactors = FALSE), .joined)
  }
}
final.dataframe <- do.call(rbind, .rows)
rownames(final.dataframe) <- NULL
if (nrow(final.dataframe) != 35L || sum(final.dataframe$Primary_area_record) != 30L ||
    sum(final.dataframe$Record_type == "printed_author_aggregate") != 3L ||
    sum(final.dataframe$Record_type == "missing_author_aggregate") != 2L) stop("Record partition differs.")

# Fresh exact-name lookup; no cached registry row position or guessed public stem.
if (!requireNamespace("readxl", quietly = TRUE)) stop("readxl is required for the current registry lookup.")
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
.matches <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
if (length(.matches) != 1L) stop("Expected one exact current Item name match.")
item_encoded <- as.character(filecodes$`Item encoded`[.matches])
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
    grepl("[\\/\\\\]", item_encoded) || endsWith(item_encoded, "_")) stop("Invalid registry Item encoded.")
.role <- as.character(filecodes$`Data role (primary/secondary/both)`[.matches])
if (is.na(.role) || .role != "primary") stop("Current registry source role needs owner review.")
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Shelf publication is opt-in after actual R execution and validation, never merge authorization.
if (identical(Sys.getenv("EVOM1_WRITE_PUBLIC_TSV"), "YES") &&
    identical(Sys.getenv("EVOM1_R_VALIDATED"), "YES")) {
  if (!dir.exists(file.path(base, "__Public", "comparative-data"))) stop("Canonical public output folder is absent.")
  utils::write.table(final.dataframe,
    file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
    sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message("Analysis CSV only. Public TSV withheld: actual R validation and explicit owner publication opt-in required.")
}
