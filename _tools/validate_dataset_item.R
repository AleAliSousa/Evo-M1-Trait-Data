validate_dataset_item <- function(
    csv_file,
    tsv_file,
    readme_file,
    definitions_file
) {
  
  checks <- data.frame(
    check = c(
      "csv",
      "tsv",
      "readme",
      "definitions"
    ),
    passed = c(
      file.exists(csv_file),
      file.exists(tsv_file),
      file.exists(readme_file),
      file.exists(definitions_file)
    )
  )
  
  checks$status <- ifelse(
    checks$passed,
    "PASS",
    "FAIL"
  )
  
  checks
}