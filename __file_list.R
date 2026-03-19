library(openxlsx)

# Paths
root_dir <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/"
readme_xlsx <- file.path(root_dir, "__ReadMe.xlsx")
file_dir <- file.path(root_dir, "__Public", "comparative-data")

# Build FileList data
file_list_df <- data.frame(
  Files = list.files(file_dir),
  stringsAsFactors = FALSE
)

# Load existing workbook
wb <- loadWorkbook(readme_xlsx)

# If FileList already exists, remove it
if ("FileList" %in% names(wb)) {
  removeWorksheet(wb, "FileList")
}

# Add fresh FileList sheet
addWorksheet(wb, "FileList")
writeData(wb, sheet = "FileList", x = file_list_df)

# Save without destroying other sheets
saveWorkbook(wb, readme_xlsx, overwrite = TRUE)