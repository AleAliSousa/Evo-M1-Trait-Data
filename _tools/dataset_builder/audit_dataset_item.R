## audit_dataset_item.R — pre-build audit against the 4-file convention.
##
## Checks (per paper folder):
##   snapshot   — exactly one *_snapshot.csv (frozen source)
##   csv        — at least one analysis CSV (non-snapshot *.csv)
##   readme     — at least one *.README.md or README.md
##   definitions— at least one reference_tables/*_definitions.csv
##   orphan_tsv — no *.tsv files inside the paper folder
##                (public TSVs belong in __Public/comparative-data/, not here)
##
## Returns a named list:
##   $convention  data.frame — one row per check, columns: check / found / status
##   $files       data.frame — all files found, flagged as orphan_tsv where applicable

audit_dataset_item <- function(
    item_dir,
    verbose = TRUE
) {

  if (!dir.exists(item_dir))
    stop("item_dir does not exist: ", item_dir)

  all_files <- list.files(
    item_dir,
    recursive  = TRUE,
    full.names = TRUE
  )

  rel <- sub(
    paste0("^", normalizePath(item_dir, mustWork = FALSE), "/?"),
    "",
    normalizePath(all_files, mustWork = FALSE)
  )

  ## ---- classify files -------------------------------------------------------
  is_snapshot    <- grepl("_snapshot\\.csv$",   rel, ignore.case = TRUE)
  is_csv         <- grepl("\\.csv$",            rel, ignore.case = TRUE) & !is_snapshot
  is_readme      <- grepl("(^|/)README\\.md$",  rel, ignore.case = TRUE) |
                    grepl("\\.README\\.md$",     rel, ignore.case = TRUE)
  is_definitions <- grepl(
    "^reference_tables/.*_definitions\\.csv$",  rel, ignore.case = TRUE
  )
  is_tsv         <- grepl("\\.tsv$",            rel, ignore.case = TRUE)

  ## ---- 4-file convention checks ---------------------------------------------
  convention <- data.frame(
    check = c(
      "snapshot",
      "csv",
      "readme",
      "definitions",
      "orphan_tsv"
    ),
    found = c(
      sum(is_snapshot),
      sum(is_csv),
      sum(is_readme),
      sum(is_definitions),
      sum(is_tsv)          ## want 0
    ),
    stringsAsFactors = FALSE
  )

  convention$status <- c(
    ifelse(convention$found[1] >= 1L, "PASS", "MISSING"),   # snapshot
    ifelse(convention$found[2] >= 1L, "PASS", "MISSING"),   # csv
    ifelse(convention$found[3] >= 1L, "PASS", "MISSING"),   # readme
    ifelse(convention$found[4] >= 1L, "PASS", "MISSING"),   # definitions
    ifelse(convention$found[5] == 0L, "PASS", "ORPHAN_TSV") # orphan_tsv
  )

  ## ---- file-level frame (with orphan flag) ----------------------------------
  files_df <- data.frame(
    relative_path = rel,
    full_path     = all_files,
    orphan_tsv    = is_tsv,
    stringsAsFactors = FALSE
  )

  report <- list(
    convention = convention,
    files      = files_df
  )

  if (verbose) {
    cat("\n--- audit:", basename(item_dir), "---\n")
    print(convention)
    if (any(is_tsv)) {
      cat("\nOrphan TSV(s) found — move to __Public/comparative-data/:\n")
      cat(paste0("  ", rel[is_tsv]), sep = "\n")
      cat("\n")
    }
  }

  invisible(report)
}
