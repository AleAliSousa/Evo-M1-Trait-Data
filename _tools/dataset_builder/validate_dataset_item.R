## validate_dataset_item.R — check the 7 hard invariants for one dataset item.
##
## Invariants (README §Hard invariants):
##   1. analysis CSV exists
##   2. public TSV exists
##   3. README exists
##   4. definitions file exists
##   5. frozen source (snapshot data file) exists
##   6. registry row found by Item name (never row number)
##   7. TSV file name == paste0(item_encoded, ".tsv")  +  trailing-_ guard

validate_dataset_item <- function(
    csv_file,
    tsv_file,
    readme_file,
    definitions_file,
    frozen_source_file = NULL,   ## *_snapshot.(csv|xlsx|xls|tsv) path
    registry          = NULL,    ## data.frame already read from __ReadMe.xlsx
    item_name         = NULL,    ## character — looked up by name, never row number
    item_encoded      = NULL     ## character — expected TSV stem; also guards trailing _
) {

  ## ---- helpers --------------------------------------------------------------
  .exists <- function(x) !is.null(x) && length(x) == 1L && !is.na(x) && nzchar(x) && file.exists(x)
  .scalar <- function(x) !is.null(x) && length(x) == 1L && !is.na(x) && nzchar(x)

  ## ---- invariant 5: frozen source exists ------------------------------------
  check_frozen <- if (.scalar(frozen_source_file)) {
    .exists(frozen_source_file)
  } else {
    NA   ## not supplied — skip
  }

  ## ---- invariant 6: registry row found by Item name -------------------------
  check_registry_row <- if (!is.null(registry) && .scalar(item_name)) {
    nrow(registry[registry[["Item name"]] == item_name, , drop = FALSE]) > 0L
  } else {
    NA
  }

  ## ---- invariant 7a: TSV name == item_encoded + ".tsv" ----------------------
  check_tsv_name <- if (.scalar(item_encoded) && .scalar(tsv_file)) {
    basename(tsv_file) == paste0(item_encoded, ".tsv")
  } else {
    NA
  }

  ## ---- invariant 7b: trailing-_ guard (empty col-D failure mode) ------------
  ## Item encoded values ending with "_" indicate a missing or blank source
  ## column in __ReadMe.xlsx; the resulting TSV name would be malformed.
  check_no_trailing_underscore <- if (.scalar(item_encoded)) {
    !grepl("_$", item_encoded)
  } else {
    NA
  }

  ## ---- assemble report ------------------------------------------------------
  all_checks <- c(
    "csv"                   = .exists(csv_file),
    "tsv"                   = .exists(tsv_file),
    "readme"                = .exists(readme_file),
    "definitions"           = .exists(definitions_file),
    "frozen_source"         = check_frozen,
    "registry_row"          = check_registry_row,
    "tsv_name_match"        = check_tsv_name,
    "no_trailing_underscore"= check_no_trailing_underscore
  )

  checks <- data.frame(
    check  = names(all_checks),
    passed = unname(all_checks),
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  ## NA = skipped (optional arg not supplied)
  checks$status <- ifelse(
    is.na(checks$passed), "SKIP",
    ifelse(checks$passed,  "PASS", "FAIL")
  )

  checks
}
