## build_dataset_item.R — run a dataset item's build script and validate output.
##
## Loaded via load_dataset_builder.R (do not source this file directly; it
## depends on validate_dataset_item() already being in scope).
##
## Key behaviours:
##   * __ReadMe.xlsx is resolved by walking up from item_dir to the repo root
##     (same sentinel-file walk used by run_all_scripts_v2.R), so cwd does not
##     matter.
##   * The builder is selected by its exact item name, never by taking the
##     first R file. Snapshot makers and other items' scripts cannot be run.
##   * Public TSVs are looked up in __Public/comparative-data/ (their canonical
##     location), not inside the paper folder.
##   * Table checks: if the build script checks the table against its own printed
##     totals (HOWTO §7a) it leaves a `table_checks` data.frame; that is attached to
##     the report as attr(report, "table_checks") and printed. It never changes data
##     or the invariant statuses. No `table_checks` = not assessed (most tables).

build_dataset_item <- function(
    item_dir,
    item_name,
    registry_file  = NULL,   ## NULL → resolve via repo-root walk
    dry_run        = TRUE,
    create_backup  = TRUE,
    run_comparison = TRUE,
    verbose        = TRUE
) {

  if (!requireNamespace("readxl", quietly = TRUE))
    stop("Package 'readxl' required.")

  item_dir <- normalizePath(item_dir, mustWork = TRUE)

  ## ---- resolve __ReadMe.xlsx via repo-root walk ----------------------------
  if (is.null(registry_file)) {
    d <- item_dir
    while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx")))
      d <- dirname(d)
    if (!file.exists(file.path(d, "__ReadMe.xlsx")))
      stop(
        "__ReadMe.xlsx not found walking up from item_dir: ", item_dir, "\n",
        "Supply registry_file= explicitly if the repo root is elsewhere."
      )
    root_dir      <- d
    registry_file <- file.path(d, "__ReadMe.xlsx")
  } else {
    registry_file <- normalizePath(registry_file, mustWork = TRUE)
    root_dir      <- dirname(registry_file)
  }

  ## ---- load registry and look up item by name (never by row number) --------
  registry <- readxl::read_excel(registry_file, sheet = "Sheet1")

  row <- registry[which(!is.na(registry[["Item name"]]) &
                        registry[["Item name"]] == item_name), , drop = FALSE]

  if (nrow(row) == 0L)
    stop(
      "Item '", item_name, "' not found in registry: ", registry_file
    )
  if (nrow(row) != 1L)
    stop("Item '", item_name, "' has multiple registry rows; resolve the ambiguity.")

  item_encoded <- row[["Item encoded"]][[1L]]

  if (verbose) {
    cat("\n")
    cat("Item:    ", item_name,    "\n")
    cat("Encoded: ", item_encoded, "\n")
    cat("Root:    ", root_dir,     "\n")
    cat("Dry run: ", dry_run,      "\n\n")
  }

  ## ---- resolve the requested item's files; never pick an arbitrary first ----
  files <- list.files(item_dir, recursive = TRUE, full.names = TRUE)
  exactly_one <- function(paths, description, required = TRUE) {
    if (length(paths) > 1L)
      stop("Ambiguous ", description, " for '", item_name, "': ",
           paste(paths, collapse = "; "), call. = FALSE)
    if (!length(paths)) {
      if (required) stop("No ", description, " found for '", item_name, "'.", call. = FALSE)
      return(NA_character_)
    }
    paths[[1L]]
  }
  build_script <- exactly_one(files[basename(files) == paste0(item_name, ".R")],
                              "item builder")

  # A source may be a named, born-digital file rather than <item>_snapshot.*.
  # Honor an explicit registry filename only when it unambiguously names one
  # existing file. Multiple source files need an explicit multi-source model.
  override_col <- "Snapshot filename (only if not <Item name>_snapshot)"
  override <- if (override_col %in% names(row)) as.character(row[[override_col]][[1L]]) else NA_character_
  if (!is.na(override) && nzchar(trimws(override))) {
    declared <- trimws(override)
    # A real filename may itself contain parentheses or semicolons. Match it
    # exactly first, then try removing a trailing explanatory parenthetical.
    candidate <- files[basename(files) == basename(declared)]
    if (!length(candidate)) {
      filename <- sub("[[:space:]]+\\(.*\\)[[:space:]]*$", "", declared)
      candidate <- files[basename(files) == basename(filename)]
    }
    if (!length(candidate) && length(strsplit(declared, ";", fixed = TRUE)[[1L]]) > 1L)
      stop("Multiple declared snapshot/source files for '", item_name,
           "' require explicit review.", call. = FALSE)
  } else {
    snapshot_names <- paste0(item_name, "_snapshot.",
                             c("csv", "xlsx", "xls", "tsv", "txt", "doc", "docx", "nex"))
    candidate <- files[basename(files) %in% snapshot_names]
  }
  snapshot_file <- exactly_one(candidate, "snapshot/source")
  # Check for an existing duplicate before running, and resolve the output again
  # after the builder writes it. Its expected name may include dots.
  exactly_one(files[basename(files) == paste0(item_name, ".csv")],
              "analysis CSV", required = FALSE)

  if (dry_run) {
    cat("DRY RUN — would run:\n  ", build_script, "\n")
    return(invisible(NULL))
  }

  ## ---- execute build script ------------------------------------------------
  build_env <- new.env(parent = baseenv())
  sys.source(build_script, envir = build_env)

  ## ---- table checks reported by the build script (HOWTO §7a) -----------------
  table_checks <- NULL
  if (exists("table_checks", envir = build_env, inherits = FALSE)) {
    table_checks <- get("table_checks", envir = build_env, inherits = FALSE)
    need <- c("check_id", "basis", "observed", "printed", "difference",
              "tolerance", "status", "note")
    if (!is.data.frame(table_checks) || !all(need %in% names(table_checks)) ||
        !all(table_checks$status %in% c("pass", "mismatch", "not_evaluable")))
      stop("`table_checks` from ", basename(build_script),
           " must be a data.frame with columns ", paste(need, collapse = ", "),
           " and status pass / mismatch / not_evaluable (build HOWTO section 7a).", call. = FALSE)
  }

  ## ---- gather output files for validation ----------------------------------

  files <- list.files(item_dir, recursive = TRUE, full.names = TRUE)
  csv_file <- exactly_one(files[basename(files) == paste0(item_name, ".csv")],
                          "analysis CSV")

  ## public TSV lives in __Public/comparative-data/, not inside the paper folder
  public_dir <- file.path(root_dir, "__Public", "comparative-data")
  tsv_expected <- paste0(item_encoded, ".tsv")
  tsv_file <- file.path(public_dir, tsv_expected)

  readme_files <- list.files(
    item_dir,
    recursive = TRUE, pattern = "README\\.md$", full.names = TRUE, ignore.case = TRUE
  )
  folder_name <- basename(item_dir)
  item_readme_names <- tolower(paste0(item_name, c(".README.md", "_README.md")))
  paper_readme_names <- tolower(c(paste0(folder_name, c(".README.md", "_README.md")), "README.md"))
  item_readmes <- readme_files[tolower(basename(readme_files)) %in% item_readme_names]
  paper_readmes <- readme_files[tolower(basename(readme_files)) %in% paper_readme_names]
  readme_file <- if (length(item_readmes)) {
    exactly_one(item_readmes, "item README")
  } else {
    exactly_one(paper_readmes, "paper README", required = FALSE)
  }

  definitions_files <- list.files(
    file.path(item_dir, "reference_tables"),
    recursive = TRUE, pattern = "_definitions\\.csv$", full.names = TRUE
  )
  # A single unrelated item's file is not a paper-wide dictionary. Match only
  # the requested item or the explicitly paper-named shared dictionary.
  item_definitions <- definitions_files[basename(definitions_files) == paste0(item_name, "_definitions.csv")]
  paper_definitions <- definitions_files[basename(definitions_files) == paste0(folder_name, "_definitions.csv")]
  definitions_file <- if (length(item_definitions)) {
    exactly_one(item_definitions, "item definitions")
  } else {
    exactly_one(paper_definitions, "paper definitions", required = FALSE)
  }

  ## ---- validate (all 7 invariants) -----------------------------------------
  report <- validate_dataset_item(

    csv_file         = csv_file,
    tsv_file         = if (file.exists(tsv_file)) tsv_file else NA_character_,
    readme_file      = readme_file,
    definitions_file = definitions_file,

    frozen_source_file = snapshot_file,
    registry           = registry,
    item_name          = item_name,
    item_encoded       = item_encoded
  )

  attr(report, "table_checks") <- table_checks

  if (verbose) {
    print(report)
    if (is.null(table_checks)) {
      cat("\nTable checks: none reported by", basename(build_script), "(not assessed).\n")
    } else {
      cat("\nTable checks (", basename(build_script[1L]), "): ",
          paste(names(table(table_checks$status)), table(table_checks$status),
                sep = " = ", collapse = ", "), "\n", sep = "")
      print(table_checks[table_checks$status != "pass",
                         c("check_id", "observed", "printed", "difference", "status")],
            row.names = FALSE)
    }
  }

  return(report)
}
