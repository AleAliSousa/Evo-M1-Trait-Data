source("validate_dataset_item.R")

build_dataset_item <- function(
    item_dir,
    item_name,
    registry_file =
      "__ReadMe.xlsx",
    dry_run = TRUE,
    create_backup = TRUE,
    run_comparison = TRUE,
    verbose = TRUE
) {
  
  if (!requireNamespace("readxl", quietly = TRUE))
    stop("Package 'readxl' required.")
  
  registry <- readxl::read_excel(
    registry_file,
    sheet = "Sheet1"
  )
  
  row <- registry[
    registry$`Item name` == item_name,
  ]
  
  if (nrow(row) == 0)
    stop("Item not found in registry.")
  
  item_encoded <- row$`Item encoded`[[1]]
  
  if(verbose) {
    
    cat("\n")
    cat("Item:", item_name, "\n")
    cat("Encoded:", item_encoded, "\n")
    cat("Dry run:", dry_run, "\n\n")
  }
  
  files <- list.files(
    item_dir,
    recursive = TRUE,
    full.names = TRUE
  )
  
  build_script <- files[
    grepl("\\.R$", files) &
      !grepl("compare", files)
  ]
  
  if(length(build_script) == 0) {
    
    warning(
      "No build script found."
    )
    
    return(invisible(NULL))
  }
  
  if(dry_run) {
    
    cat(
      "DRY RUN\n",
      "Would run:\n",
      build_script[1],
      "\n"
    )
    
    return(invisible(NULL))
  }
  
  build_env <- new.env()
  
  sys.source(
    build_script[1],
    envir = build_env
  )
  
  csv_files <- list.files(
    item_dir,
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE
  )
  
  tsv_expected <- paste0(
    item_encoded,
    ".tsv"
  )
  
  tsv_files <- list.files(
    item_dir,
    recursive = TRUE,
    pattern = "\\.tsv$",
    full.names = TRUE
  )
  
  readme_files <- list.files(
    item_dir,
    recursive = TRUE,
    pattern = "README\\.md$",
    full.names = TRUE
  )
  
  definitions_files <- list.files(
    file.path(
      item_dir,
      "reference_tables"
    ),
    recursive = TRUE,
    pattern =
      "_definitions\\.csv$",
    full.names = TRUE
  )
  
  report <- validate_dataset_item(
    
    csv_file = csv_files[1],
    
    tsv_file =
      tsv_files[
        basename(tsv_files)
        == tsv_expected
      ][1],
    
    readme_file =
      readme_files[1],
    
    definitions_file =
      definitions_files[1]
  )
  
  if(verbose)
    print(report)
  
  return(report)
}