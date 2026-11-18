## Focused regression test; all synthetic files are created in tempdir().
## Run from the repository root: Rscript _tools/dataset_builder/test_build_dataset_item.R
stopifnot(requireNamespace("readxl", quietly = TRUE),
          requireNamespace("openxlsx", quietly = TRUE))
source("_tools/dataset_builder/build_dataset_item.R")

root <- tempfile("dataset-builder-test-")
dir.create(root)
tryCatch({
  item_dir <- file.path(root, "Paper")
  dir.create(item_dir)
  dir.create(file.path(item_dir, "reference_tables"))
  dir.create(file.path(root, "__Public"))
  dir.create(file.path(root, "__Public", "comparative-data"))
  registry <- data.frame(
    `Item name` = c("Paper_TableA", "Paper_TableB", "Paper_Digital", "Paper_Annotated",
                    "Paper_Paren", "Paper_Semicolon", "Paper_Multiple", "Paper_Text"),
    `Item encoded` = c("source_TableA", "source_TableB", "source_Digital", "source_Annotated",
                       "source_Paren", "source_Semicolon", "source_Multiple", "source_Text"),
    `Snapshot filename (only if not <Item name>_snapshot)` = c(
      "", "", "journal_original.xlsx", "journal_original.xlsx (Dataset S1; sheet A)",
      "journal (original).xlsx", "journal;original.xlsx", "journal_original.xlsx; other.csv", ""),
    check.names = FALSE
  )
  openxlsx::write.xlsx(list(Sheet1 = registry), file.path(root, "__ReadMe.xlsx"))
  path <- function(x) file.path(item_dir, x)
  writeLines("published source A", path("Paper_TableA_snapshot.csv"))
  writeLines("published source B", path("Paper_TableB_snapshot.csv"))
  writeLines("digital source", path("journal_original.xlsx"))
  writeLines("digital source with parentheses", path("journal (original).xlsx"))
  writeLines("digital source with semicolon", path("journal;original.xlsx"))
  writeLines("plain text snapshot", path("Paper_Text_snapshot.txt"))
  writeLines("data A", path("Paper_TableA.csv"))
  writeLines("data B", path("Paper_TableB.csv"))
  writeLines("digital data", path("Paper_Digital.csv"))
  for (item in c("Annotated", "Paren", "Semicolon", "Multiple", "Text"))
    writeLines("data", path(paste0("Paper_", item, ".csv")))
  writeLines("notes", path("Paper.README.md"))
  shared_def <- path("reference_tables/Paper_definitions.csv")
  writeLines("Code,Definition", shared_def)
  for (stem in c("source_TableA", "source_TableB", "source_Digital", "source_Annotated",
                 "source_Paren", "source_Semicolon", "source_Multiple", "source_Text"))
    writeLines("tsv", file.path(root, "__Public", "comparative-data", paste0(stem, ".tsv")))
  marker <- path("builder-ran")
  correct_builder <- sprintf("writeLines('item builder', %s)", encodeString(marker, quote = '"'))
  writeLines(correct_builder, path("Paper_TableB.R"))
  writeLines(correct_builder, path("Paper_Digital.R"))
  for (item in c("Annotated", "Paren", "Semicolon", "Multiple", "Text"))
    writeLines(correct_builder, path(paste0("Paper_", item, ".R")))
  writeLines("stop('wrong builder selected')", path("Paper_TableA.R"))
  writeLines("stop('snapshot maker must not run')", path("Paper_TableB_snapshot.R"))

  # Capture the validation inputs to check what was actually selected.
  observed <- NULL
  validate_dataset_item <- function(...) {
    observed <<- list(...)
    data.frame(check = "fixture", passed = TRUE, status = "PASS")
  }
  run <- function(item, dry_run = FALSE) build_dataset_item(
    item_dir, item, registry_file = file.path(root, "__ReadMe.xlsx"),
    dry_run = dry_run, create_backup = FALSE, run_comparison = FALSE, verbose = FALSE
  )
  error_contains <- function(expr, expected) {
    result <- tryCatch({force(expr); ""}, error = function(e) conditionMessage(e))
    stopifnot(grepl(expected, result, fixed = TRUE))
  }

  run("Paper_TableB")
  stopifnot(file.exists(marker), basename(observed$csv_file) == "Paper_TableB.csv",
            basename(observed$frozen_source_file) == "Paper_TableB_snapshot.csv",
            basename(observed$definitions_file) == basename(shared_def))

  # An explicit original-format source can stand in for a snapshot.
  run("Paper_Digital")
  stopifnot(basename(observed$frozen_source_file) == "journal_original.xlsx")
  run("Paper_Annotated")
  stopifnot(basename(observed$frozen_source_file) == "journal_original.xlsx")
  run("Paper_Paren")
  stopifnot(basename(observed$frozen_source_file) == "journal (original).xlsx")
  run("Paper_Semicolon")
  stopifnot(basename(observed$frozen_source_file) == "journal;original.xlsx")
  run("Paper_Text")
  stopifnot(basename(observed$frozen_source_file) == "Paper_Text_snapshot.txt")
  unlink(marker)
  error_contains(run("Paper_Multiple"), "Multiple declared snapshot/source files")
  stopifnot(!file.exists(marker))

  # Duplicate workbook items cannot be silently resolved by taking the first.
  workbook <- file.path(root, "__ReadMe.xlsx")
  openxlsx::write.xlsx(list(Sheet1 = rbind(registry, registry[2, ])), workbook)
  error_contains(run("Paper_TableB"), "multiple registry rows")
  stopifnot(!file.exists(marker))
  openxlsx::write.xlsx(list(Sheet1 = registry), workbook)

  # Prefer a matching item dictionary over an unrelated shared dictionary.
  specific_def <- path("reference_tables/Paper_TableB_definitions.csv")
  writeLines("Code,Definition", specific_def)
  run("Paper_TableB")
  stopifnot(basename(observed$definitions_file) == basename(specific_def))
  unlink(specific_def)

  # Item README wins over a shared README and mixed-case names are accepted.
  specific_readme <- path("Paper_TableB.ReadMe.md")
  writeLines("item notes", specific_readme)
  run("Paper_TableB")
  stopifnot(basename(observed$readme_file) == basename(specific_readme))
  unlink(specific_readme)

  # An unrelated item's sole definitions or README is not a shared resource.
  unlink(shared_def)
  writeLines("Code,Definition", path("reference_tables/Paper_TableA_definitions.csv"))
  unlink(path("Paper.README.md"))
  writeLines("other item", path("Paper_TableA.README.md"))
  run("Paper_TableB")
  stopifnot(is.na(observed$definitions_file), is.na(observed$readme_file))

  # Ambiguous or missing builders and sources must fail before any script runs.
  dir.create(path("scripts"))
  file.copy(path("Paper_TableB.R"), path("scripts/Paper_TableB.R"))
  unlink(marker)
  error_contains(run("Paper_TableB"), "Ambiguous item builder")
  stopifnot(!file.exists(marker))
  unlink(path("scripts/Paper_TableB.R"))
  file.rename(path("Paper_TableB.R"), path("Paper_TableB.R.disabled"))
  error_contains(run("Paper_TableB"), "No item builder found")
  stopifnot(!file.exists(marker))
  file.rename(path("Paper_TableB.R.disabled"), path("Paper_TableB.R"))
  file.rename(path("Paper_TableB_snapshot.csv"), path("Paper_TableB_snapshot.csv.disabled"))
  error_contains(run("Paper_TableB"), "No snapshot/source found")
  stopifnot(!file.exists(marker))
  file.rename(path("Paper_TableB_snapshot.csv.disabled"), path("Paper_TableB_snapshot.csv"))
  dir.create(path("snapshots"))
  file.copy(path("Paper_TableB_snapshot.csv"), path("snapshots/Paper_TableB_snapshot.csv"))
  error_contains(run("Paper_TableB"), "Ambiguous snapshot/source")
  stopifnot(!file.exists(marker))
  unlink(path("snapshots/Paper_TableB_snapshot.csv"))
  dir.create(path("outputs"))
  file.copy(path("Paper_TableB.csv"), path("outputs/Paper_TableB.csv"))
  error_contains(run("Paper_TableB"), "Ambiguous analysis CSV")
  stopifnot(!file.exists(marker))

  cat("dataset item builder: targeted selection and fail-closed checks passed\n")
}, finally = unlink(root, recursive = TRUE))
