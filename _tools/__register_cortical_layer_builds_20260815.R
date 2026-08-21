# Register three already-built cortical-layer sources that the generated public
# file-list audit identified as uncatalogued. Writes source/descriptive fields;
# _tools/file_list.R owns E:M formulas and the generated list sheet.

suppressPackageStartupMessages(library(openxlsx))

script <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
root <- normalizePath(file.path(dirname(script), ".."))
path <- file.path(root, "__ReadMe.xlsx")
source(file.path(root, "_helpers", "openxlsx_compat.R"))
openxlsx_input <- openxlsx_compatible_copy(path)
wb <- loadWorkbook(openxlsx_input)
sheet <- "Sheet1"
headers <- read.xlsx(wb, sheet = sheet, rows = 1, colNames = FALSE,
                     skipEmptyCols = FALSE, skipEmptyRows = FALSE)
headers <- as.character(headers[1, ])
normalize_header <- function(x) tolower(gsub("[^[:alnum:]]", "", x))
find_col <- function(label) {
  out <- match(normalize_header(label), normalize_header(headers))
  if (is.na(out)) stop("Registry column not found: ", label)
  out
}

rows <- list(
  `299` = list(
    `Citation (APA 7th-Annotated)` = "Jacobs, B., Lee, L., Schall, M., Raghanti, M. A., Lewandowski, A. H., Kottwitz, J. J., Roberts, J. F., Hof, P. R., & Sherwood, C. C. (2016). Neocortical neuronal morphology in the newborn giraffe (Giraffa camelopardalis tippelskirchi) and African elephant (Loxodonta africana). Journal of Comparative Neurology, 524, 257–287. https://doi.org/10.1002/cne.23841",
    `Item number` = "Table 1",
    `Item full original title` = "Neocortical neuronal morphology in the newborn giraffe (Giraffa camelopardalis tippelskirchi) and African elephant (Loxodonta africana)",
    `Note about item` = "BUILT: 35 long rows; one newborn specimen per species across M1/V1 and other cortical regions. Age and printed layer absences remain explicit.",
    `Progress stage` = "FINISHED",
    Snapshot = "Jacobs_etal_2016_Table1_snapshot.csv",
    `Adjustment made` = "Printed dashes retained as layer_status=absent; accepted project species kept separately from printed labels.",
    `Data readable file, can use this` = "Jacobs_etal_2016_Table1.csv",
    `Source Type` = "Journal article",
    `Source format` = "PDF table",
    `Source URL direct access` = "https://www.coloradocollege.edu/dotAsset/f0f0cd15-dac1-4695-9a39-6f7eba5810f5.pdf",
    `Sample type` = "single-specimen summaries",
    Subcategory = "cortical layers",
    `Main Trait(s)` = "cortical-layer thickness",
    `Taxon group` = "Giraffidae; Elephantidae",
    `Data role (primary/secondary/both)` = "primary",
    `Measure type` = "absolute cortical-layer thickness"
  ),
  `300` = list(
    `Citation (APA 7th-Annotated)` = "Johnson, C. B., Schall, M., Tennison, M. E., Garcia, M. E., Shea-Shumsky, N. B., Raghanti, M. A., Lewandowski, A. H., Bertelsen, M. F., Waller, L. C., Walsh, T., Roberts, J. F., Hof, P. R., Sherwood, C. C., Manger, P. R., & Jacobs, B. (2016). Neocortical neuronal morphology in the Siberian tiger (Panthera tigris altaica) and the clouded leopard (Neofelis nebulosa). Journal of Comparative Neurology, 524, 3641–3665. https://doi.org/10.1002/cne.24022",
    `Item number` = "Table 1",
    `Item full original title` = "Neocortical neuronal morphology in the Siberian tiger (Panthera tigris altaica) and the clouded leopard (Neofelis nebulosa)",
    `Note about item` = "BUILT: 42 long rows across prefrontal, M1, and V1; one tiger and a two-clouded-leopard species summary.",
    `Progress stage` = "FINISHED",
    Snapshot = "Johnson_etal_2016_Table1_snapshot.csv",
    `Adjustment made` = "Printed dashes retained as layer_status=absent; individual versus species-summary status remains explicit.",
    `Data readable file, can use this` = "Johnson_etal_2016_Table1.csv",
    `Source Type` = "Journal article",
    `Source format` = "PDF table",
    `Source URL direct access` = "https://www.coloradocollege.edu/dotAsset/17493d76-5085-4a01-a757-d992278a9eaf.pdf",
    `Sample type` = "single-specimen and species summaries",
    Subcategory = "cortical layers",
    `Main Trait(s)` = "cortical-layer thickness",
    `Taxon group` = "Felidae",
    `Data role (primary/secondary/both)` = "primary",
    `Measure type` = "absolute cortical-layer thickness"
  ),
  `301` = list(
    `Citation (APA 7th-Annotated)` = "Peruffo, A., Corain, L., Bombardi, C., Centelleghe, C., Grisan, E., Graic, J.-M., Bontempi, P., Grandis, A., & Cozzi, B. (2019). The motor cortex of the sheep: Laminar organization, projections and diffusion tensor imaging of the intracranial pyramidal and extrapyramidal tracts. Brain Structure and Function, 224, 1933–1946. https://doi.org/10.1007/s00429-019-01885-x",
    `Item number` = "Table 2",
    `Item full original title` = "The motor cortex of the sheep: Laminar organization, projections and diffusion tensor imaging of the intracranial pyramidal and extrapyramidal tracts",
    `Note about item` = "BUILT: six adult sheep plus the printed mean; absolute and proportional M1 layer thickness. merge_default uses the mean to prevent double counting.",
    `Progress stage` = "FINISHED",
    Snapshot = "Peruffo_etal_2019_Table2_snapshot.csv",
    `Adjustment made` = "Printed percentages divided by 100; text-supported layer-IV absence remains nonnumeric and explicit.",
    `Data readable file, can use this` = "Peruffo_etal_2019_Table2.csv",
    `Source Type` = "Journal article",
    `Source format` = "PDF table",
    `Source URL direct access` = "https://link.springer.com/content/pdf/10.1007/s00429-019-01885-x.pdf",
    `Sample type` = "individuals plus printed species mean",
    Subcategory = "cortical layers",
    `Main Trait(s)` = "M1 cortical-layer thickness",
    `Taxon group` = "Ovis aries",
    `Data role (primary/secondary/both)` = "primary",
    `Measure type` = "absolute and proportional cortical-layer thickness"
  )
)

for (row_name in names(rows)) {
  row <- as.integer(row_name)
  for (field in names(rows[[row_name]])) {
    writeData(wb, sheet = sheet, x = rows[[row_name]][[field]],
              startRow = row, startCol = find_col(field), colNames = FALSE)
  }
}
saveWorkbook(wb, path, overwrite = TRUE)
message("Registered cortical-layer builds on rows 299–301; run file_list.R to fill E:M")
