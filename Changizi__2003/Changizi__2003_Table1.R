## Changizi 2003, J Theor Biol 220:157-168 — Table 1
## doi:10.1006/jtbi.2003.3125 · "Relationship between number of muscles, behavioral repertoire
## size, and encephalization in mammals." Ethobehavior (ethogram) counts, encephalization index
## (Changizi 2001b), and muscle-type counts for mammalian orders + representative species.
## Two row types: order rows (order-level mean behavior count, enceph. index, muscle count +
## anatomy citation) and species rows (ethogram size + primary citation, species enceph. index).
## Names AS PRINTED incl. 'Blarina brevicaudo' (=brevicauda), 'Calithrix jacchus' (=Callithrix),
## truncated 'Meriones unguicul.' / 'Peromyscus manicul.' / 'Dolichotis patagon', and
## supra-specific 'Leporidae (family)' / 'Sciuridae (four species)'.
## SECONDARY-leaning: behavior + muscle counts are compiled from per-row primary citations.
## Snapshot transcribed from the folder PDF, verified against page images (journal p.160).

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
item_name <- tools::file_path_sans_ext(basename(.sp))               # Changizi__2003_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "Table1"))
stopifnot(nrow(raw) == 35)
blank <- function(x) ifelse(!is.na(x) & nzchar(trimws(x)), trimws(x), NA_character_)
clean <- data.frame(
  row_type = raw$`Row type`, order = raw$Order,
  Species = blank(raw$`Species latin (as printed)`),
  common_name = blank(raw$`Species common`),
  n_ethobehavior_types = as.numeric(raw$`No. of Behavior types`),
  behavior_citation = blank(raw$`Behavior citation`),
  encephalization_index = as.numeric(raw$`Index of enceph.`),
  n_muscle_types = as.numeric(raw$`No. of Muscle types`),
  muscle_citation = blank(raw$`Muscle citation`),
  note = paste0("species names as printed (some truncated/supra-specific); order rows = ",
                "order-level means; per-row primary citations retained"),
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(sum(clean$row_type == "order") == 12, sum(clean$row_type == "species") == 23)
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
