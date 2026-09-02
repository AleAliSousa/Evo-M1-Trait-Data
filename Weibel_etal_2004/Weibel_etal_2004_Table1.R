## Weibel, Bacigalupe, Schmitt & Hoppeler 2004, Respir Physiol Neurobiol 140:115-132 — Table 1
## doi:10.1016/j.resp.2004.01.006 · "Allometric scaling of maximal metabolic rate in mammals..."
## Species-level pooled VO2max + body mass, 34 mammal species. Companion item
## Weibel_etal_2004_TableA.1 holds the study-level estimates (same snapshot workbook).
## ⚠ PUBLISHED VALUE DISCREPANCY (verified against the page image, as printed): Table 1's VO2max
## column is misaligned by one species for the chipmunk→guinea-pig block (T1 chipmunk 14.58 =
## A.1 mole rat; T1 rat 54.44 = A.1 mongoose; T1 mongoose 32.59 = A.1 guinea pig). Values kept
## AS PRINTED with the note column flagging the 5 affected rows — prefer Table A.1.
## Names as published: 'Equus caballlus' (sic), 'Helogale pervula' (sic), 'Agouti paca'.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))              # Weibel_etal_2004_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, "Weibel_etal_2004_Tables_snapshot.xlsx"),
                                sheet = "Table1"))
stopifnot(nrow(raw) == 34)
flag <- c("Tamias striatus", "Spalax ehrenbergi", "Rattus norvegicus",
          "Helogale pervula", "Cavia porcellus")
disc <- paste0("PUBLISHED VALUE DISCREPANCY: Table 1 VO2max inconsistent with Table A.1 for this ",
               "species (pattern = one-row shift: T1 chipmunk 14.58 = A.1 mole rat; T1 rat 54.44 ",
               "= A.1 mongoose; T1 mongoose 32.59 = A.1 guinea pig); verified against page image ",
               "- as printed. Prefer Table A.1 study-level values.")
clean <- data.frame(
  Species = raw$Species, common_name = raw$`Common name`,
  n = as.numeric(raw$n), body_mass_kg = as.numeric(raw$`Mb (kg)`),
  vo2max_ml_min = as.numeric(raw$`VO2max (ml/min)`), references = raw$References,
  note = ifelse(raw$Species %in% flag, disc,
                "species-level pooled values; see Table A.1 for study-level estimates"),
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(clean), " species rows written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
