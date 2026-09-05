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

## ---- read frozen snapshot (printed Table I, Panel A, brain rows only; p. 43) ----
x <- readr::read_csv("Latimer__1942_Table1_brain_snapshot.csv", show_col_types = FALSE)

## ---- species harmonisation via the Stephan-collection key (Latimer1942 token) ----
key <- readr::read_csv(file.path(base, "_keys", "Stephan", "species_key.csv"), show_col_types = FALSE)
key_lat <- key[key$source_publication == "Latimer1942", ]
lk <- setNames(key_lat$accepted_name, tolower(key_lat$variant_name))
x$Species <- lk[tolower(x$species_as_published)]
stopifnot(!any(is.na(x$Species)))

## ---- project units: brain weight -> mg (house rule: brain weight mg = g * 1000) ----
x$weight_mean_mg    <- x$weight_mean_g * 1000
x$weight_se_mg       <- x$weight_se_g * 1000

x$source_location <- "Table I panel A, p. 43"
x$data_role       <- "primary"

out <- x[, c("Species", "species_as_published", "sex", "n", "structure_as_published",
             "weight_mean_mg", "weight_se_mg", "weight_cv_pct", "weight_cv_se_pct",
             "source_location", "data_role")]

readr::write_csv(out, "Latimer__1942_Table1_brain.csv", na = "")
message(item_name, ": ", nrow(out), " rows written")

## ---- public TSV: look up Item encoded from __ReadMe.xlsx ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)]
} else NA_character_

if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx yet; TSV skipped. ",
          "Paste the registry row (Latimer__1942_Table1_brain_registry_row.xlsx) first.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(out, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
