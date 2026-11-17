# Review-only migration inventory for rows in the ten-paper definition files.
# It reads current definitions and registered item CSVs; it changes neither.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __metadata/pilot/build_definition_row_types.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
folders <- c("ManyPrimates__2022", "Mink_etal_1981", "Boddy_etal_2012",
             "Falcone_etal_2019", "Buchsbaum_etal_1989", "Kaufman__2004",
             "Heffner_Heffner_2010_b", "Bahney_vonBartheld_2018",
             "Fobbs_etal_2011", "Kennedy_etal_1978")
read_chars <- function(path, nrows = -1L) {
  read.csv(path, colClasses = "character", na.strings = character(),
           check.names = FALSE, stringsAsFactors = FALSE, nrows = nrows)
}
if (!requireNamespace("readr", quietly = TRUE)) stop("Missing R package: readr")
read_definitions <- function(path) {
  x <- suppressWarnings(readr::read_csv(path,
    col_types = readr::cols(.default = readr::col_character()),
    na = character(), show_col_types = FALSE))
  list(data = as.data.frame(x, stringsAsFactors = FALSE),
       bad_rows = unique(readr::problems(x)$row))
}
files <- do.call(rbind, lapply(folders, function(folder)
  read_chars(file.path(root, folder, "pipeline_files.csv"))))
routes <- read_chars(file.path(here, "field_routes.csv"))
definitions <- files[files$content_role == "field_definitions" &
                       files$lifecycle_status == "active", , drop = FALSE]
if (nrow(definitions) != 25L || anyDuplicated(definitions$file_id))
  stop("Expected 25 unique active definition files")
item_files <- files[files$file_role == "item_csv" &
                      files$lifecycle_status == "active", , drop = FALSE]
if (anyDuplicated(item_files$item_id) || any(!nzchar(item_files$item_id)))
  stop("Registered local item CSV paths are not unique by item")
linked <- routes[routes$metadata_field == "item_definition", , drop = FALSE]
if (any(!definitions$file_id %in% linked$artifact_id))
  stop("A definition file lacks an item_definition field route")
item_cache <- lapply(item_files$path, function(path) {
  x <- read_chars(file.path(root, path))
  region_cols <- intersect(names(x),
    c("structure_as_published", "Region", "segment", "region_as_published"))
  list(columns = names(x),
       regions = unique(unlist(x[region_cols], use.names = FALSE)))
})
names(item_cache) <- item_files$item_id

classify <- function(code, role, item_ids) {
  code <- trimws(code)
  role <- trimws(role)
  item_ids <- intersect(item_ids, names(item_cache))
  matching_columns <- item_ids[vapply(item_ids, function(item)
    code %in% item_cache[[item]]$columns, logical(1L))]
  if (length(matching_columns))
    return(list(type = "field_definition", scope = "column",
                matched = matching_columns,
                reason = "Code exactly matches a linked registered item CSV column; legacy role is not a point-level decision"))
  if (grepl("^method(:|$)", code, ignore.case = TRUE) || role == "method")
    return(list(type = "method", scope = "unresolved", matched = character(),
                reason = "Explicit Method code or method role; applicability to item/column/row still needs review"))
  matching_regions <- item_ids[vapply(item_ids, function(item)
    nzchar(code) && code %in% item_cache[[item]]$regions, logical(1L))]
  if (length(matching_regions))
    return(list(type = "anatomy", scope = "printed_region",
                matched = matching_regions,
                reason = "Code exactly matches a printed region value in a linked registered item CSV"))
  if (tolower(code) %in% c("reference", "references", "citation", "citations"))
    return(list(type = "citation", scope = "unresolved", matched = character(),
                reason = "Citation label without an exact linked item CSV column; citation scope needs review"))
  if (tolower(code) %in% c("note", "notes", "source note"))
    return(list(type = "note", scope = "unresolved", matched = character(),
                reason = "Note label without an exact linked item CSV column; purpose and scope need review"))
  list(type = "unresolved", scope = "unresolved", matched = character(),
       reason = "No exact item-column, Method, printed-region, citation, or note rule matched")
}

records <- lapply(seq_len(nrow(definitions)), function(i) {
  file <- definitions[i, , drop = FALSE]
  parsed <- read_definitions(file.path(root, file$path))
  tab <- parsed$data
  required <- c("Code", "Definition", "Structure", "Measure", "Stat",
                "role", "taxon", "Reference", "Note", "Source Note")
  if (!identical(names(tab), required))
    stop("Unexpected definition header: ", file$path)
  item_ids <- unique(linked$item_id[linked$artifact_id == file$file_id])
  if (!length(item_ids) || any(!item_ids %in% names(item_cache)))
    stop("Definition route has no registered local item CSV: ", file$path)
  classified <- lapply(seq_len(nrow(tab)), function(j)
    classify(tab$Code[[j]], tab$role[[j]], item_ids))
  bad <- (seq_len(nrow(tab)) + 1L) %in% parsed$bad_rows
  if (any(bad)) {
    for (j in which(bad)) {
      classified[[j]] <- list(type = "unresolved", scope = "unresolved",
                              matched = character(),
                              reason = "Malformed source CSV record; parser found more fields than the ten-column header")
    }
  }
  data.frame(
    source_file_id = file$file_id,
    source_path = file$path,
    source_row = seq_len(nrow(tab)) + 1L,
    Code = tab$Code,
    legacy_role = tab$role,
    linked_item_ids = paste(item_ids, collapse = ";"),
    matching_item_ids = vapply(classified, function(x)
      paste(x$matched, collapse = ";"), character(1L)),
    proposed_record_type = vapply(classified, `[[`, character(1L), "type"),
    proposed_scope = vapply(classified, `[[`, character(1L), "scope"),
    classification_reason = vapply(classified, `[[`, character(1L), "reason"),
    parse_status = ifelse(bad, "invalid_record", "parsed"),
    classification_status = "machine_proposed",
    stringsAsFactors = FALSE
  )
})
out <- do.call(rbind, records)
rownames(out) <- NULL
if (nrow(out) != 501L || anyDuplicated(out[c("source_file_id", "source_row")]))
  stop("Expected 501 uniquely addressed definition records; got ", nrow(out),
       " rows and first duplicate index ",
       anyDuplicated(out[c("source_file_id", "source_row")]))
write.csv(out, file.path(here, "definition_row_types.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
counts <- table(out$proposed_record_type)
cat("Definition row migration inventory:", nrow(out), "records from",
    nrow(definitions), "files;",
    paste(paste(names(counts), as.integer(counts), sep = "="), collapse = ", "),
    "\n")
