# Build a registered, born-digital source table without changing its frozen workbook.
build_recent_source <- function(folder, item_name, snapshot, sheet = 1, skip = 0,
                                transform, description, source_note) {
  base <- dirname(folder)
  registry <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 col_types = "text")
  hit <- match(item_name, registry$`Item name`)
  stopifnot(length(hit) == 1L, !is.na(hit))
  item_encoded <- registry$`Item encoded`[hit]
  stopifnot(length(item_encoded) == 1L, !is.na(item_encoded), nzchar(item_encoded),
            !grepl("_$", item_encoded))
  raw <- readxl::read_excel(file.path(folder, snapshot), sheet = sheet, skip = skip,
                            col_types = "text", .name_repair = "minimal")
  final.dataframe <- transform(as.data.frame(raw, check.names = FALSE))
  stopifnot(is.data.frame(final.dataframe), nrow(final.dataframe) > 0L,
            !anyDuplicated(names(final.dataframe)))
  out_csv <- file.path(folder, paste0(item_name, ".csv"))
  out_tsv <- file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.csv(final.dataframe, out_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  utils::write.table(final.dataframe, out_tsv, sep = "\t", row.names = FALSE,
                     na = "", quote = TRUE, qmethod = "double", fileEncoding = "UTF-8")
  defs <- data.frame(Code = names(final.dataframe), Definition = unname(description[names(final.dataframe)]),
                     Structure = "", Measure = "", Stat = "", role = "info", taxon = "Mammalia",
                     Reference = item_name, Note = "", `Source Note` = source_note,
                     check.names = FALSE)
  defs$Definition[is.na(defs$Definition)] <- names(final.dataframe)[is.na(defs$Definition)]
  defs$role[names(final.dataframe) %in% c("body_mass_g", "min_freq_khz", "max_freq_khz",
                                            "retinal_area_mm2", "nasotemporal_extent_mm",
                                            "peak_cone_density_cells_mm2", "VO2max")] <- "both"
  dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
  utils::write.csv(defs, file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")),
                   row.names = FALSE, na = "", fileEncoding = "UTF-8")
  readme <- c(paste0("# ", item_name), "", paste0("Frozen source: `", snapshot, "` (copy of the supplied source workbook)."),
              paste0("Source: ", source_note), "", paste0("Rows: ", nrow(final.dataframe), "; columns: ", ncol(final.dataframe), "."),
              "The item R script reads the frozen workbook and writes the local analysis CSV and registry-coded public TSV.",
              "Original taxon labels and source references are retained; data role is given per row.", "", description[["_note"]])
  writeLines(readme[!is.na(readme)], file.path(folder, paste0(item_name, ".README.md")), useBytes = TRUE)
  message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
  invisible(final.dataframe)
}
