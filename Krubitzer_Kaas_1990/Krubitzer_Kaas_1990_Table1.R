## Krubitzer & Kaas 1990, Vis Neurosci 5(2):165-204 — Table 1
## doi:10.1017/s0952523800000213 · Team Kaas.
## "Surface areas of cortical fields as a percentage of the total surface of neocortex" for eight
## visual fields (17, 18, DL, DM, DI, FST, MT, MST) + Total, per case, in FOUR primate species:
##   squirrel monkey (Saimiri sciureus), owl monkey (Aotus trivirgatus), marmoset (Callithrix jacchus),
##   galago (normalized provisionally to Galago senegalensis). Values are PROPORTIONS of neocortex,
##   NOT absolute areas (absolute field areas are only given as text ranges, not tabulated).
## Snapshot frozen from the printed table; all cleaning happens here (golden rule).

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))    # matches __ReadMe.xlsx
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

raw <- read.csv("Krubitzer_Kaas_1990_Table1_snapshot.csv", check.names = FALSE, stringsAsFactors = FALSE)

## keep per-CASE rows only; drop the printed Mean %/Std Dev summary rows (derived, recomputable)
is_case <- grepl("^[0-9]+$", trimws(raw[["Case number"]]))
d <- raw[is_case, ]

## common name -> binomial (all four are in _keys/species_reference.csv)
sp_map <- c("Squirrel monkey" = "Saimiri sciureus",
            "Owl monkey"      = "Aotus trivirgatus",
            "Marmoset"        = "Callithrix jacchus",
            "Galago"          = "Galago senegalensis")

clean <- data.frame(
  Species        = unname(sp_map[d[["Species group"]]]),
  species_as_published = d[["Species group"]],
  common_name    = tolower(d[["Species group"]]),
  case_number    = as.integer(d[["Case number"]]),
  pct_17         = as.numeric(d[["17"]]),   # area 17 (V-I)  as % of total neocortex surface
  pct_18         = as.numeric(d[["18"]]),   # area 18 (V-II)
  pct_DL         = as.numeric(d[["DL"]]),   # dorsolateral visual area
  pct_DM         = as.numeric(d[["DM"]]),   # dorsomedial visual area
  pct_DI         = as.numeric(d[["DI"]]),   # dorsointermediate visual area
  pct_FST        = as.numeric(d[["FST"]]),  # fundal superior temporal area
  pct_MT         = as.numeric(d[["MT"]]),   # middle temporal area
  pct_MST        = as.numeric(d[["MST"]]),  # medial superior temporal area
  pct_total_8fields = as.numeric(d[["Total"]]),  # sum of the eight visual fields (Total column as printed)
  measure        = "percent_of_total_neocortex_surface",
  source         = item_name,
  stringsAsFactors = FALSE
)
stopifnot(!any(is.na(clean$Species)))
clean$source_flags <- "neocortex_denominator"
clean$source_issue_note <- "Percentages use total neocortex surface as the denominator."
galago <- clean$species_as_published == "Galago"
clean$source_flags[galago] <- paste(clean$source_flags[galago], "species_inference_unverified", sep = "|")
clean$source_issue_note[galago] <- paste(
  clean$source_issue_note[galago],
  "The inspected paper labels these cases only as galago; Galago senegalensis is a curator inference pending primary-source verification."
)

## ---- local CSV ----
csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " cases written; galago binomial inference flagged")

## ---- public TSV: look up the DOI code from __ReadMe.xlsx ----
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
