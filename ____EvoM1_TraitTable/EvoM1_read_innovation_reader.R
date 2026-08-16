#!/usr/bin/env Rscript
# Reader, Hager & Laland 2011 behavioural-flexibility data -> innovation_reader.xlsx
#
# The source folder already freezes the Dryad CSV and publishes the canonical TSV. This reader
# deliberately carries raw report counts plus the paper's reduced-count sensitivity variables and
# research-effort denominators. It does not invent an effort-corrected score. In the behaviour
# merge, the report-count variables have explicit names so they cannot be pooled with Heldstab's
# categorical Tool_use / Extractive_foraging variables.

suppressWarnings(suppressMessages({library(readxl); library(writexl)}))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  stop("Run with Rscript file.R, or open the saved script in RStudio.", call. = FALSE)
})
tt_dir <- dirname(.sp)
root <- normalizePath(file.path(tt_dir, ".."))
item_name <- "Reader_etal_2011_Data"

filecodes <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded) || !nzchar(item_encoded))
  item_encoded <- "10.1098%2Frstb.2010.0342_Data"

src <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
d <- read.delim(src, stringsAsFactors = FALSE, check.names = FALSE)
required <- c(
  "Species_Reader2011", "species_sci", "Innovation", "Tool_use",
  "Extractive_foraging", "Social_learning", "Innovation_reduced", "Tool_use_reduced",
  "Extractive_foraging_reduced", "Journal_search_article_count",
  "Zoological_record_article_count"
)
missing <- setdiff(required, names(d))
if (length(missing)) stop("Reader TSV is missing: ", paste(missing, collapse = ", "))

out <- data.frame(
  species_sci = d$species_sci,
  Species = d$Species_Reader2011,
  Innovation = d$Innovation,
  Tool_use = d$Tool_use,
  Extractive_foraging = d$Extractive_foraging,
  Social_learning = d$Social_learning,
  Innovation_reduced = d$Innovation_reduced,
  Tool_use_reduced = d$Tool_use_reduced,
  Extractive_foraging_reduced = d$Extractive_foraging_reduced,
  Journal_search_article_count = d$Journal_search_article_count,
  Zoological_record_article_count = d$Zoological_record_article_count,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

dest <- file.path(tt_dir, "innovation_reader.xlsx")
write_xlsx(out, dest)
cat(sprintf("innovation_reader.xlsx: %d species x %d fields\n", nrow(out), ncol(out)))
