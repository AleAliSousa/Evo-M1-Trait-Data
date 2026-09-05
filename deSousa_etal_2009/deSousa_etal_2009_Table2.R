.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

x <- readr::read_csv("deSousa_etal_2009_Table2_snapshot.csv", show_col_types = FALSE)
x$source_location <- "Table 2, RMA regressions of V1, V2, and VP GLI values on brain and visual system variables"
x$data_role <- "primary"
readr::write_csv(x, "deSousa_etal_2009_Table2.csv", na = "")
message(item_name, ": ", nrow(x), " rows written")

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)]
} else NA_character_
if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "'; TSV skipped. Paste registry row first.")
} else if (dir.exists(path.expand(tsv_dir))) {
  write.table(x, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote TSV")
}
