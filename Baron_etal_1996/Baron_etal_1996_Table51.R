# Baron, Stephan & Frahm 1996, Table51: Pirlot's volume data for six species that Tables 10 and 32 do not cover, reprinted in the book as two stacked blocks. Secondary. Paleocortex and amygdala are pooled here, whereas Table 32 separates them.
# Frozen source: Baron_etal_1996_Table51_snapshot.csv, produced by the coordinate-based
# PDF transcription in Baron_etal_1996_extract_snapshots.R, which is checked on
# every run against the frozen Table 10 and Table 32 snapshots.

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
stopifnot(nrow(snapshot) == 6L, identical(snapshot$species_row, seq_len(6L)))

final.dataframe <- data.frame(
  species_row = snapshot$species_row,
  Species_Baron1996 = trimws(snapshot$species_printed),
  body_weight_g = as.numeric(snapshot$BoW_g),
  brain_weight_mg = as.numeric(snapshot$BrW_mg),
  medulla_oblongata_mm3 = as.numeric(snapshot$OBL),
  mesencephalon_mm3 = as.numeric(snapshot$MES),
  cerebellum_mm3 = as.numeric(snapshot$CER),
  diencephalon_mm3 = as.numeric(snapshot$DIE),
  telencephalon_mm3 = as.numeric(snapshot$TEL),
  main_olfactory_bulb_mm3 = as.numeric(snapshot$MOB),
  paleocortex_plus_amygdala_mm3 = as.numeric(snapshot$PAL_AMY),
  septum_mm3 = as.numeric(snapshot$SEP),
  striatum_mm3 = as.numeric(snapshot$STR),
  hippocampus_mm3 = as.numeric(snapshot$HIP),
  schizocortex_mm3 = as.numeric(snapshot$SCH),
  neocortex_mm3 = as.numeric(snapshot$NEO),
  source_pdf_page = snapshot$source_pdf_page,
  stringsAsFactors = FALSE
)

required <- c("species_row", "Species_Baron1996", "body_weight_g", "brain_weight_mg", "medulla_oblongata_mm3", "mesencephalon_mm3", "cerebellum_mm3", "diencephalon_mm3", "telencephalon_mm3", "main_olfactory_bulb_mm3", "paleocortex_plus_amygdala_mm3", "septum_mm3", "striatum_mm3", "hippocampus_mm3", "schizocortex_mm3", "neocortex_mm3")
if (any(!complete.cases(final.dataframe[required]))) {
  stop("Unexpected missing species or measurement in ", item_name)
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

