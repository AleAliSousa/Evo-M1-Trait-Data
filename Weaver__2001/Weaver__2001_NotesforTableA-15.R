## Weaver__2001 — Notes for Table A-15
## The dissertation prints, below Table A-15, a set of provenance notes stating
## where each variable / taxon group's values came from. This is metadata (data
## role = info/note), not measured data, so it is not merged. This script turns
## the verbatim notes (the frozen snapshot) into a small structured source-
## attribution table, keeping each note's text verbatim for traceability.

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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

## snapshot: line 1 is the title, lines 2..8 are the seven notes (verbatim)
lines <- readLines("Weaver__2001_NotesforTableA-15_snapshot.csv", warn = FALSE)
lines <- lines[nzchar(trimws(lines))]
note_text <- lines[-1]                      # drop "Notes for Table A-15"
stopifnot(length(note_text) == 7L)

## parsed classification of each note (position-matched to note_text above)
variable <- c(
  "Brain volume; Cerebellum volume",
  "Brain volume; Body mass",
  "Cerebellum volume",
  "Conversion formula (cranial capacity -> brain volume -> brain mass)",
  "Body mass",
  "Cerebellum volume; endocranial volume",
  "Body mass"
)
taxon_group <- c(
  "Old and New World monkeys and pongids (extant)",
  "Recent Homo sapiens",
  "Recent Homo sapiens",
  "Fossil hominids (all)",
  "Homo erectus; early and late archaic Homo sapiens; early modern Homo sapiens",
  "Fossil hominids",
  "Australopithecines; Homo habilis"
)
data_source <- c(
  "MRI",
  "Beals et al. 1984",
  "mean of Riedel et al. 1989; Rilling & Insel 1998; Semendeferi & Damasio 2000; Snyder et al. 1995",
  "Ruff et al. 1997",
  "Ruff et al. 1997",
  "3-D virtual scanned models (Weaver, this study)",
  "McHenry 1992b"
)

clean <- data.frame(
  note_id     = seq_along(note_text),
  variable    = variable,
  taxon_group = taxon_group,
  data_source = data_source,
  note_text   = note_text,
  source      = "Weaver__2001",
  stringsAsFactors = FALSE
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(clean, tsv_file, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_file)
}
