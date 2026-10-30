## Clancy B, Darlington RB, Finlay BL (2001). Translating developmental time across mammalian species.
## Neuroscience 105(1):7-17. Table 1 (journal pp. 10-11): predicted (model) and empirical timing of 95 neural
## events in 9 species, in post-conception (PC) days.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream.
##
## Input : Clancy_etal_2001_Table1_snapshot.csv  (transcribed from PDF pp.4-5; 95 events x 9 species, wide)
## Output: <script stem>.csv   LONG: one row per event x species (855 rows; 362 with an empirical date)
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
source_name <- sub("_Table[^_]*$", "", item_name)         # Clancy_etal_2001_Table1 -> Clancy_etal_2001
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", na.strings = c("", "NA"))
num <- function(x) suppressWarnings(as.numeric(trimws(x)))

## first data row of the snapshot is the species score row (printed under the species names)
sp_score_row <- snap[1, ]
ev <- snap[-1, ]
stopifnot(nrow(ev) == 95)
species <- c("hamster", "mouse", "rat", "rabbit", "sp. mouse", "ferret", "cat", "macaque", "human")

out <- list()
for (k in seq_along(species)) {
  j <- 3 + (k - 1) * 3                                   # model, empir., empir. ref
  stopifnot(startsWith(names(snap)[j], species[k]))
  out[[k]] <- data.frame(
    species                    = species[k],              # as printed (sp. mouse = spiny mouse per Table 2 header)
    neural_event               = trimws(ev[[1]]),
    event_score                = num(ev[[2]]),
    species_score              = num(sp_score_row[[j]]),
    predicted_PC_days          = num(ev[[j]]),
    observed_PC_days           = num(ev[[j + 1]]),
    observed_source_refs       = ev[[j + 2]],             # letters a-m, see definitions / README
    stringsAsFactors = FALSE)
}
clean <- do.call(rbind, out)
## event_structure / event_type parsed from the printed event name (no wording changed)
et <- sub(".*[ -](peak|start|end)$", "\\1", clean$neural_event)
et[!grepl("[ -](peak|start|end)$", clean$neural_event)] <-
  ifelse(grepl("appears$", clean$neural_event[!grepl("[ -](peak|start|end)$", clean$neural_event)]), "appears", "other")
clean$event_type <- et
clean$event_structure <- trimws(sub("\\s*-\\s*(peak|start|end)$", "", clean$neural_event))
clean$source <- source_name
clean <- clean[, c("species", "neural_event", "event_structure", "event_type", "event_score", "species_score",
                   "predicted_PC_days", "observed_PC_days", "observed_source_refs", "source")]
stopifnot(nrow(clean) == 855, sum(!is.na(clean$observed_PC_days)) == 362)   # paper: 95 x 9 matrix, 362 empirical dates

write.csv(clean, output_csv, row.names = FALSE)

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
