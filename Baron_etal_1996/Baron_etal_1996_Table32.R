# Baron, Stephan & Frahm 1996, Table 32: telencephalic component volumes.
# Frozen source: Baron_etal_1996_Table32_snapshot.csv.  Table 10's printed
# species string is carried as the stable within-book name; Table 32's printed
# abbreviation survives alongside it.

suppressPackageStartupMessages(library(readxl))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
root_dir <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot <- read.csv(file.path(paper_dir, paste0(item_name, "_snapshot.csv")),
                     check.names = FALSE, stringsAsFactors = FALSE)
table10 <- read.csv(file.path(paper_dir, "Baron_etal_1996_Table10_snapshot.csv"),
                    check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(snapshot) == 272L, nrow(table10) == 272L,
          identical(snapshot$species_row, table10$species_row))

final.dataframe <- data.frame(
  species_row = snapshot$species_row,
  Species_Baron1996 = trimws(table10$species_printed),
  Species_printed_Table32 = trimws(snapshot$species_printed),
  main_olfactory_bulb_mm3 = as.numeric(snapshot$MOB),
  paleocortex_mm3 = as.numeric(snapshot$PAL),
  striatum_mm3 = as.numeric(snapshot$STR),
  septum_mm3 = as.numeric(snapshot$SEP),
  amygdala_mm3 = as.numeric(snapshot$AMY),
  hippocampus_mm3 = as.numeric(snapshot$HIP),
  schizocortex_mm3 = as.numeric(snapshot$SCH),
  neocortex_mm3 = as.numeric(snapshot$NEO),
  source_pdf_page = snapshot$source_pdf_page,
  stringsAsFactors = FALSE
)

measure_columns <- setdiff(names(final.dataframe),
                           c("species_row", "Species_Baron1996", "Species_printed_Table32",
                             "source_pdf_page"))
if (any(!complete.cases(final.dataframe[c("species_row", "Species_Baron1996", measure_columns)]))) {
  stop("Unexpected missing species or volume in Table 32")
}

local_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, local_csv, row.names = FALSE, na = "")

registry <- read_excel(file.path(root_dir, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  stop("No cached Item encoded value for ", item_name, " in __ReadMe.xlsx")
}
public_tsv <- file.path(root_dir, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, public_tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "")
message("Wrote ", local_csv, " and ", public_tsv, " (", nrow(final.dataframe), " rows)")
