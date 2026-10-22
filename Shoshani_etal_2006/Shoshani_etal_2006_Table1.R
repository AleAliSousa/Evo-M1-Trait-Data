## Shoshani J, Kupsky WJ, Marchant GH (2006). Elephant brain. Part I: gross morphology, functions, comparative
## anatomy, and evolution. Brain Res Bull 70(2):124-157. Table 1 (brains and endocasts of proboscideans and other taxa).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV (if registered).
## One row per SPECIMEN / literature record (44 rows), not per species. Taxon labels exactly as printed.
##
## Input : Shoshani_etal_2006_Table1_snapshot.csv  (transcribed from PDF pp.3-4 = journal pp.125-126)
## Output: <script stem>.csv                 one row per sample no. (44)
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

options(scipen = 999)
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- sub("_Table[^_]*$", "", item_name)         # <Folder>_Table<N> -> <Folder>
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers; blanks stay blank) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, na.strings = character(0), colClasses = "character")
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

## strip superscript footnote tags "^f1" etc. from a cell; keep the rest as printed
untag <- function(x) trimws(gsub("\\^[A-Za-z]+[0-9]*", "", x))
tags  <- function(x) vapply(regmatches(x, gregexpr("\\^[A-Za-z]+[0-9]*", x)),
                            function(m) paste(sub("^\\^", "", m), collapse = ";"), "")
## first number in a cell that is a plain number (NA for 'No data', 'Brain', 'A or B' ranges etc.)
plain <- function(x) { x <- untag(x); ifelse(grepl("^[0-9.,]+$", x), num(x), NA_real_) }

bs  <- untag(snap[[9]]); cer <- untag(snap[[10]])
clean <- data.frame(
  sample_no            = as.integer(snap[[1]]),
  section              = substr(snap[[2]], 2, 2),                 # A-E, from the printed group headings
  taxon                = snap[[3]],                               # as printed
  specimen_or_source   = snap[[4]],
  captive_or_wild      = untag(snap[[5]]),                        # C, W, ?C, ?, etc.
  age_printed          = snap[[6]],                               # years, Ad., ?Ad., Yg., Calf
  sex                  = snap[[7]],
  body_mass_g_printed  = untag(snap[[8]]),
  body_mass_g          = plain(snap[[8]]),                        # g as printed (see README: sample 6 printed 1793.300)
  brain_mass_g_printed = bs,
  brain_mass_g         = plain(snap[[9]]),                        # brain WITH brain-stem and dura fragments (footnote g)
  cerebellum_mass_g    = ifelse(grepl("/", cer), num(sub("/.*", "", cer)), NA_real_),
  cerebellum_pct_of_brain = ifelse(grepl("/", cer), num(sub(".*/", "", cer)), NA_real_),
  dura_mater_g_printed = untag(snap[[11]]),
  dura_mater_g         = plain(snap[[11]]),
  EQ_printed           = untag(snap[[12]]),
  EQ                   = plain(snap[[12]]),                       # printed value; brackets/NA/j-note cells -> NA
  footnote_tags        = mapply(function(i) paste(c(tags(snap[[4]][i]), tags(snap[[5]][i]), tags(snap[[8]][i]), tags(snap[[9]][i]), tags(snap[[10]][i]), tags(snap[[11]][i]), tags(snap[[12]][i])), collapse = ";"), seq_len(nrow(snap))),
  source               = source_name,
  stringsAsFactors = FALSE
)
clean$footnote_tags <- gsub("^;|;$", "", gsub(";+", ";", clean$footnote_tags))
## bracketed EQ values ([18.5], [2.83], [0.2], [2.2], [2.18 or 1.75]) are the authors' literature/estimated EQs: kept in EQ_printed only
clean$EQ_bracketed <- grepl("^\\[", clean$EQ_printed)

## ---- table check: EQ = E / (0.12 * P^(2/3)) (footnote j) recomputed from printed body and brain mass ----
chk <- with(clean, ifelse(!is.na(body_mass_g) & !is.na(brain_mass_g) & !is.na(EQ), brain_mass_g / (0.12 * body_mass_g^(2/3)), NA))
ok <- !is.na(chk) & clean$sample_no != 6          # sample 6 prints body mass "1793.300" (g) = 1,793,300 g; see README
cat("EQ recomputed vs printed (", sum(ok), "rows, excluding sample 6): max abs diff =", round(max(abs(chk - clean$EQ)[ok]), 3), "\n")
cat("sample 6: printed EQ", clean$EQ[6], "; recomputed with body x1000:", round(clean$brain_mass_g[6] / (0.12 * (clean$body_mass_g[6] * 1000)^(2/3)), 2), "\n")

write.csv(clean, output_csv, row.names = FALSE)
cat(nrow(clean), "rows written to", output_csv, "\n")

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
