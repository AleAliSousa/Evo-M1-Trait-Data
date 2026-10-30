## Kochiyama_etal_2018 — Figure 3 legend
## Modern-human (MH) mean +/- s.d. volume (cc) of the 13 parcellated brain regions,
## as printed in the Figure 3 legend. Snapshot -> clean CSV (+ DOI-encoded TSV).
## MH relative-volume s.d. = CV = sd/mean is the quantity used elsewhere to recover
## the NT/EH relative volumes (see Kochiyama_etal_2018_reconcile_relative_volumes.R).

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
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)

structure_map <- c("Fr SM"="FrontalLobe","Fr I"="FrontalLobe","Fr O"="FrontalLobe",
  "Sm"="SensorimotorCortex","Pa SI"="ParietalLobe","Pa TP"="ParietalLobe",
  "Te SM"="TemporalLobe","Te I"="TemporalLobe","Oc SM"="OccipitalLobe",
  "Oc I"="OccipitalLobe","Ce V"="Cerebellum","Ce A"="Cerebellum","Ce P"="Cerebellum")

raw <- read.csv("Kochiyama_etal_2018_Figure3legend_snapshot.csv", header = FALSE,
                colClasses = "character", check.names = FALSE, na.strings = c("", "NA"))
raw <- raw[raw[[1]] %in% names(structure_map), , drop = FALSE]   # keep the 13 region rows
as_num <- function(x) suppressWarnings(as.numeric(x))
m <- as_num(raw[[2]]); s <- as_num(raw[[3]])

clean <- data.frame(
  Region_code = raw[[1]], Structure = unname(structure_map[raw[[1]]]),
  Species = "Homo sapiens", Group = "MH", n_MH = 1185L,
  MH_mean_Vol.cc = m, MH_sd_Vol.cc = s,
  MH_mean_Vol.mm3 = round(m * 1000), MH_sd_Vol.mm3 = round(s * 1000),
  MH_CV = round(s / m, 5), source = "Kochiyama_etal_2018", stringsAsFactors = FALSE)
stopifnot(nrow(clean) == 13L)
write.csv(clean, paste0(item_name, ".csv"), row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows")

tsv_dir <- file.path(base, "__Public", "comparative-data")
enc <- if (!is.na(base)) { fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)] } else NA_character_
if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
  write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
