## Weibel et al. 2004 — Table A.1 (study-level VO2max estimates; companion of Table 1)
## doi:10.1016/j.resp.2004.01.006. 58 study-level rows (species × primary study, strain/sex in
## the printed common name). Internal consistency verified: body_mass_kg × per-kg VO2max =
## absolute VO2max for every row. Table A.1 is the PREFERRED source where Table 1's printed
## misalignment applies (see Weibel_etal_2004_Table1.R header). Names as published.

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
item_name <- tools::file_path_sans_ext(basename(.sp))            # Weibel_etal_2004_TableA.1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, "Weibel_etal_2004_Tables_snapshot.xlsx"),
                                sheet = "TableA1"))
stopifnot(nrow(raw) == 58)
clean <- data.frame(
  Species = raw$Species, common_name_as_printed = raw[[1]],
  n = as.numeric(raw$n), body_mass_kg = as.numeric(raw$`Mb (kg)`),
  vo2max_per_kg_ml_min_kg = as.numeric(raw$`VO2max/Mb (ml/min kg)`),
  vo2max_ml_min = as.numeric(raw$`VO2max (ml/min)`), reference = raw$Reference,
  note = "study-level estimate; strain/sex in common_name_as_printed",
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(all(abs(clean$body_mass_kg * clean$vo2max_per_kg_ml_min_kg - clean$vo2max_ml_min)
              <= pmax(0.02 * clean$vo2max_ml_min, 0.05)))
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(clean), " study-level rows written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
