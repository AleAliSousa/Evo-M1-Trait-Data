# One-time registry update for the 2026-08-15 remaining-dataset build pass.
# This script edits descriptive/status columns only. It never writes E:M, and it
# never edits AUTO_Public_TSV_FileList (owned by file_list.R).

suppressPackageStartupMessages(library(openxlsx))

root <- normalizePath(file.path(dirname(normalizePath(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))), ".."))
path <- file.path(root, "__ReadMe.xlsx")
source(file.path(root, "_helpers", "openxlsx_compat.R"))
openxlsx_input <- openxlsx_compatible_copy(path)
wb <- loadWorkbook(openxlsx_input)
sheet <- "Sheet1"
registry <- read.xlsx(wb, sheet = sheet, colNames = TRUE, check.names = FALSE)
normalize_header <- function(x) tolower(gsub("[^[:alnum:]]", "", x))
find_col <- function(label) {
  out <- match(normalize_header(label), normalize_header(names(registry)))
  if (is.na(out)) stop("Registry column not found: ", label)
  out
}
item_col <- find_col("Item name")

updates <- list(
  Baron_etal_1996_Table10 = list(
    `Note about item` = "BUILT 2026-08-15: 272 species; five fundamental brain-part volumes.",
    `Progress stage` = "FINISHED",
    Snapshot = "Baron_etal_1996_Table10_snapshot.csv",
    `Adjustment made` = "Source values preserved; seven blank n values retained as missing.",
    `Data readable file, can use this` = "Baron_etal_1996_Table10.csv",
    `Data role (primary/secondary/both)` = "primary"
  ),
  Baron_etal_1996_Table32 = list(
    `Note about item` = "BUILT 2026-08-15: 272 species; telencephalic component volumes. Two source-level component-sum conflicts are retained and reported.",
    `Progress stage` = "FINISHED",
    Snapshot = "Baron_etal_1996_Table32_snapshot.csv",
    `Adjustment made` = "Source values preserved; two Table 32 versus Table 10 component-sum conflicts flagged, not corrected.",
    `Data readable file, can use this` = "Baron_etal_1996_Table32.csv",
    `Data role (primary/secondary/both)` = "primary"
  ),
  `Ebinger__1974_Tables3-4` = list(
    `Note about item` = "BUILT 2026-08-15: primary regional measurements for 10 individual wild/domestic sheep.",
    `Progress stage` = "FINISHED",
    Snapshot = "Ebinger__1974_Tables3-4_snapshot.csv",
    `Adjustment made` = "Brain mass converted g to mg; OCR J2879 corrected to the rendered 12879; 260/260 cells otherwise match the export.",
    `Data readable file, can use this` = "Ebinger__1974_Tables3-4.csv",
    `Data role (primary/secondary/both)` = "primary"
  ),
  `MedinaGonzalez__2026_Data` = list(
    `Note about item` = "HOLD: Zenodo 10.5281/zenodo.15425733 is published but restricted; exact source files, headers, and redistribution license cannot yet be checked.",
    `Progress stage` = "NOT STARTED",
    `Data role (primary/secondary/both)` = "both"
  ),
  Navarrete_etal_2016_Data = list(
    `Note about item` = "BUILT 2026-08-15: 167 species. Technical/non-technical subtype counts depend on Reader records; do not add them to Reader totals. The deposit has no effort denominator.",
    `Progress stage` = "FINISHED",
    Snapshot = "none - digital-native (ESMNavarreteReaderStreetWhalenLaland_dataset.csv; MD5 74eefe75e9e0bb2abcb84010e6317b87)",
    `Adjustment made` = "Stable field names; source 'rate (nr)' fields labelled as integer counts; no effort-normalized value invented.",
    `Data readable file, can use this` = "Navarrete_etal_2016_Data.csv",
    `Data role (primary/secondary/both)` = "both"
  ),
  Nguyen_etal_2019_Table2 = list(
    `Note about item` = "BUILT 2026-08-15: 49 felid species-region-neuron-type rows; keep region and neuron type explicit.",
    `Progress stage` = "FINISHED",
    Snapshot = "Nguyen_etal_2019_Table2_snapshot.csv",
    `Adjustment made` = "Printed mean ± SEM cells split; original names retained; Motor and Visual mapped separately to M1 and V1.",
    `Data readable file, can use this` = "Nguyen_etal_2019_Table2.csv",
    `Data role (primary/secondary/both)` = "primary"
  ),
  Olkowicz_etal_2016_DatasetS1 = list(
    `Note about item` = "BUILT 2026-08-15: 28 avian species and all 75 numeric source measurements. Public shelf dataset only; excluded from mammal merges.",
    `Progress stage` = "FINISHED",
    Snapshot = "none - digital-native (pnas.1517131113.sd01.source.zip; contained XLSX MD5 0b0454f3d3da43e405fb5d444f9a0e4f)",
    `Adjustment made` = "Stable field names and Class=Aves added; source spelling/capitalization preserved; no bird taxonomy resolution attempted.",
    `Data readable file, can use this` = "Olkowicz_etal_2016_DatasetS1.csv",
    `Data role (primary/secondary/both)` = "primary"
  ),
  `Schleifenbaum__1973_Tables1-2` = list(
    `Note about item` = "BUILT 2026-08-15: age/sex/body/brain data and absolute brain-region volumes for 33 canids.",
    `Progress stage` = "FINISHED",
    Snapshot = "Schleifenbaum__1973_Table1_snapshot.csv + Schleifenbaum__1973_Table2_snapshot.csv",
    `Adjustment made` = "Printed dashes retained as missing and sectioned-subset status kept explicit; derived relative Table 3 not duplicated.",
    `Data readable file, can use this` = "Schleifenbaum__1973_Tables1-2.csv",
    `Data role (primary/secondary/both)` = "primary"
  )
)

for (item in names(updates)) {
  row <- match(item, registry[[item_col]])
  if (is.na(row)) stop("Registry item not found: ", item)
  excel_row <- row + 1L
  for (field in names(updates[[item]])) {
    col <- find_col(field)
    writeData(wb, sheet = sheet, x = updates[[item]][[field]],
              startRow = excel_row, startCol = col, colNames = FALSE)
  }
}

saveWorkbook(wb, path, overwrite = TRUE)
message("Updated descriptive/status fields for ", length(updates), " registry items")
