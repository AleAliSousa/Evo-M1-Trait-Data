## Bush EC, Allman JM (2004). Three-dimensional structure and evolution of primate primary visual cortex. Anat Rec A 281A(1):1088-1094.
## TABLE2
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream.
##
## Input : Bush_Allman_2004_b_TABLE2_snapshot.csv
## Output: Bush_Allman_2004_b_TABLE2.csv
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)

options(scipen = 999)

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
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snap <- read.csv("Bush_Allman_2004_b_TABLE2_snapshot.csv", check.names = FALSE,
                 stringsAsFactors = FALSE, na.strings = c("", "NA", "n.a.", "-", "--"))

stopifnot(nrow(snap) == 3L)
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

clean <- data.frame(
  species                                   = trimws(snap$species),
  LGN_magnocellular_neuron_count            = num(snap$magnocellular_count),
  LGN_magnocellular_coefficient_of_error    = num(snap$magnocellular_coefficient_of_error),
  LGN_parvocellular_neuron_count            = num(snap$parvocellular_count),
  LGN_parvocellular_coefficient_of_error    = num(snap$parvocellular_coefficient_of_error),
  source                                    = "Bush_Allman_2004_b",
  stringsAsFactors = FALSE
)

stopifnot(nrow(clean) == 3L, !anyDuplicated(clean$species), all(nzchar(clean$species)))

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE, na = "NA")
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

if (is.na(base)) {
  warning("Repository root containing __ReadMe.xlsx not found; TSV skipped.")
} else {
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(tsv_dir)) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    tsv_file <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
    write.table(clean, tsv_file, sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
    message("Wrote ", tsv_file)
  }
}
