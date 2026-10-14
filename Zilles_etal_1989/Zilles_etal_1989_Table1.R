## Frozen publication snapshot -> analysis CSV -> registry-authoritative public TSV.
options(scipen = 999)
.sp <- local({
  for (fr in rev(sys.frames())) {
    p <- fr$ofile; if (is.null(p)) p <- fr$file
    if (is.character(p) && length(p) == 1L && grepl("\\.R$", p) && file.exists(p)) return(normalizePath(p))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1L])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run the saved item script with Rscript, source(), or RStudio Source.")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- folder
while (dirname(base) != base && !file.exists(file.path(base, "__ReadMe.xlsx"))) base <- dirname(base)
num <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
raw <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), skip = 2L, check.names = FALSE, colClasses = "character", na.strings = "", stringsAsFactors = FALSE)
left <- raw[, 1:6, drop = FALSE]; right <- raw[, 7:12, drop = FALSE]
names(left) <- names(right) <- c("Species", "S", "E", "NEO", "GIR", "GIL")
left$panel <- "left"; right$panel <- "right"
left$printed_row <- seq_len(nrow(left)); right$printed_row <- seq_len(nrow(right))
raw <- rbind(left, right)
raw <- raw[!is.na(raw$Species) & !is.na(raw$GIR) & grepl("^[0-9]", raw$GIR), , drop = FALSE]
## Project conversion: brain g -> mg; neopallium cm3 -> mm3. GI is a ratio, never doubled.
final.dataframe <- data.frame(species_as_published = raw$Species, source_panel = raw$panel, source_panel_row = raw$printed_row, Body_Mass.g = num(raw$S), Brain_Mass.mg = num(raw$E) * 1000, Neopallium_Vol.mm3 = num(raw$NEO) * 1000, Gyrification_index_R = num(raw$GIR), Gyrification_index_L = num(raw$GIL), gyrification_data_role = "primary", size_data_role = "secondary_or_unspecified", size_ref_key = "20", source = item_name, stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(nrow(final.dataframe) == 56L, all(final.dataframe$Gyrification_index_R >= 1), all(is.na(final.dataframe$Gyrification_index_L) | final.dataframe$Gyrification_index_L >= 1))

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "NA")
item_encoded <- NA_character_
if (requireNamespace("readxl", quietly = TRUE) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  i <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
  if (length(i) == 1L) item_encoded <- filecodes[["Item encoded"]][i]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) && !grepl("_$", item_encoded)) {
  out <- file.path(base, "__Public", "comparative-data")
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe, file.path(out, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
} else warning("Analysis CSV built; public TSV withheld until owner registration and Item encoded recalculation. No proposed identifier is treated as registry authority.")
message(item_name, ": ", nrow(final.dataframe), " analysis rows")
