# Granatosky 2018 — Supplementary Table S1 → analysis CSV + public TSV
# Reformat: frozen snapshot -> summary locomotor indices, species harmonised.
# House pipeline: snapshot (frozen) -> clean here -> CSV + DOI-coded TSV.

library(readxl)
library(writexl)

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(repo)
folder <- "Granatosky__2018"
item_name <- "Granatosky__2018_TableS1"

# ---- species resolver (single source of truth = _keys) ----------------------
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) {
  c <- clean_sp(x)
  hit <- match(tolower(c), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a))
  c
}

# ---- read frozen snapshot ---------------------------------------------------
snap <- read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                   sheet = "TableS1_snapshot", .name_repair = "minimal")
snap <- as.data.frame(snap, check.names = FALSE)
snap <- snap[!is.na(snap$Species) & nzchar(trimws(snap$Species)), ]

df <- data.frame(
  species_sci               = vapply(snap$Species, resolve, character(1)),
  Species                   = trimws(snap$Species),
  Order                     = snap$Order,
  Family                    = snap$Family,
  Captive_or_wild           = snap[["Captive or wild"]],
  Arboreal_terrestrial      = snap[["Arboreal versus terrestrial"]],
  Body_Mass.g               = suppressWarnings(as.numeric(snap[["Body mass (g)"]])),
  Intermembral_index        = suppressWarnings(as.numeric(snap[["Intermembral index"]])),
  Locomotor_diversity_index = suppressWarnings(as.numeric(snap[["Locomotor diversity index"]])),
  Citation                  = snap$Citation,
  stringsAsFactors = FALSE, check.names = FALSE
)

# ---- write analysis CSV + DOI-coded public TSV ------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- read_excel("__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) {
  item_encoded <- "10.1111%2Fjzo.12608_TableS1"     # fallback until registry row added
  warning("Item not yet in __ReadMe.xlsx; using known encoded name.")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

cat("Granatosky TableS1:", nrow(df), "species written\n")
