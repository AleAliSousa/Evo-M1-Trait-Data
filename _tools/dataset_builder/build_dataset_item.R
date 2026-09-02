## build_dataset_item.R — run a dataset item's build script and validate output.
##
## Loaded via load_dataset_builder.R (do not source this file directly; it
## depends on validate_dataset_item() already being in scope).
##
## Key behaviours:
##   * __ReadMe.xlsx is resolved by walking up from item_dir to the repo root
##     (same sentinel-file walk used by run_all_scripts_v2.R), so cwd does not
##     matter.
##   * Build-script picker excludes both *compare* and *_extract_snapshot.R*
##     files — extract-snapshot scripts are frozen-source helpers, not item
##     builders, and should never run here.
##   * Public TSVs are looked up in __Public/comparative-data/ (their canonical
##     location), not inside the paper folder.

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

  row <- registry[registry[["Item name"]] == item_name, , drop = FALSE]

  if (nrow(row) == 0L)
    stop(
      "Item '", item_name, "' not found in registry: ", registry_file
    )

  item_encoded <- row[["Item encoded"]][[1L]]

  if (verbose) {
    cat("\n")
    cat("Item:    ", item_name,    "\n")
    cat("Encoded: ", item_encoded, "\n")
    cat("Root:    ", root_dir,     "\n")
    cat("Dry run: ", dry_run,      "\n\n")
  }

  ## ---- find build script (exclude compare and extract_snapshot) ------------
  files <- list.files(item_dir, recursive = TRUE, full.names = TRUE)

  build_script <- files[
    grepl("\\.R$", files, ignore.case = TRUE) &
      !grepl("compare",              files, ignore.case = TRUE) &
      !grepl("_extract_snapshot\\.R$", files, ignore.case = TRUE)
  ]

  if (length(build_script) == 0L) {
    warning("No build script found in: ", item_dir)
    return(invisible(NULL))
  }

  if (dry_run) {
    cat("DRY RUN — would run:\n  ", build_script[1L], "\n")
    return(invisible(NULL))
  }

  ## ---- execute build script ------------------------------------------------
  build_env <- new.env(parent = baseenv())
  sys.source(build_script[1L], envir = build_env)

  ## ---- gather output files for validation ----------------------------------

  ## analysis CSV (non-snapshot)
  csv_files <- list.files(
    item_dir,
    recursive = TRUE, pattern = "\\.csv$", full.names = TRUE
  )
  csv_files <- csv_files[!grepl("_snapshot\\.csv$", csv_files, ignore.case = TRUE)]

  ## frozen source (snapshot CSV)
  snapshot_files <- list.files(
    item_dir,
    recursive = TRUE, pattern = "_snapshot\\.csv$", full.names = TRUE
  )

  ## public TSV lives in __Public/comparative-data/, not inside the paper folder
  public_dir <- file.path(root_dir, "__Public", "comparative-data")
  tsv_expected <- paste0(item_encoded, ".tsv")
  tsv_file <- file.path(public_dir, tsv_expected)

  readme_files <- list.files(
    item_dir,
    recursive = TRUE, pattern = "README\\.md$", full.names = TRUE
  )

  definitions_files <- list.files(
    file.path(item_dir, "reference_tables"),
    recursive = TRUE, pattern = "_definitions\\.csv$", full.names = TRUE
  )

  ## ---- validate (all 7 invariants) -----------------------------------------
  report <- validate_dataset_item(

    csv_file         = csv_files[1L],
    tsv_file         = if (file.exists(tsv_file)) tsv_file else NA_character_,
    readme_file      = readme_files[1L],
    definitions_file = definitions_files[1L],

    frozen_source_file = snapshot_files[1L],
    registry           = registry,
    item_name          = item_name,
    item_encoded       = item_encoded
  )

  if (verbose)
    print(report)

  return(report)
}
