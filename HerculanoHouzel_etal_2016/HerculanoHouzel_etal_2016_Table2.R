.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

x_source <- read.csv("HerculanoHouzel_etal_2016_Table2_snapshot.csv",
                     skip = 1, nrows = 14, check.names = FALSE,
                     colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(x_source) == 14L)
source_number <- function(v) {
  v <- sub(" \\(.*$", "", v)
  as.numeric(gsub(" × 10\\^", "e", v))
}
source_status <- function(v) {
  ifelse(is.na(v) | !nzchar(v), NA_character_,
         ifelse(grepl("pred|\\(3\\)", v), "predicted", "observed"))
}
x <- tibble::tibble(
  species_as_printed = x_source$Species,
  N_CX = source_number(x_source$N_CX),
  N_CX_status = source_status(x_source$N_CX),
  N_M1 = source_number(x_source$N_M1),
  N_M1_status = source_status(x_source$N_M1),
  N_SC = source_number(x_source$N_SC),
  N_SC_status = source_status(x_source$N_SC),
  N_M1_per_N_SC = as.numeric(x_source$`N_M1/N_SC`),
  source_location = "Table 2, p. 451",
  data_role = ifelse(is.na(x_source$N_SC) | !nzchar(x_source$N_SC),
                     "not_available",
                     ifelse(grepl("pred", x_source$N_SC), "derived", "secondary"))
)
readr::write_csv(x, "HerculanoHouzel_etal_2016_Table2.csv", na = "")
message(item_name, ": ", nrow(x), " rows written")

## ---- public TSV: look up Item encoded from __ReadMe.xlsx ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(x, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
