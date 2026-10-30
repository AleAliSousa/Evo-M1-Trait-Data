# Wimberly et al. 2021 — mammal walking-gait dataset -> analysis CSV + public TSV
# Reformat: frozen snapshot -> focal gait traits, species harmonised.
# House pipeline: snapshot (frozen) -> clean here -> CSV + DOI-coded TSV.
# Item token = "MammalGait" (registry strips spaces/underscores from Item number "Mammal Gait").
# Mirrors Granatosky__2018_TableS1.R.

library(readxl)

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(repo)
folder    <- "Wimberly_etal_2021"
item_name <- "Wimberly_etal_2021_MammalGait"

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
                   sheet = "MammalGait_snapshot", .name_repair = "minimal")
snap <- as.data.frame(snap, check.names = FALSE)
snap <- snap[!is.na(snap$Species_printed) & nzchar(trimws(snap$Species_printed)), ]

numify <- function(v) suppressWarnings(as.numeric(v))
fp <- trimws(as.character(snap$Foot_Posture)); fp[fp == ""] <- NA

df <- data.frame(
  species_sci        = vapply(snap$Species_printed, resolve, character(1)),
  Species            = clean_sp(snap$Species_printed),
  Order              = snap$Order,
  Habitat            = snap$Habitat,
  Duty_Factor        = numify(snap$Duty_Factor),
  Phase              = numify(snap$Phase),
  Gait               = snap$Gait,
  Foot_Posture       = fp,
  Hindlimb_Length.mm = numify(snap[["Hindlimb_Length_.mm."]]),
  Body_Mass.g        = numify(snap[["Body_Mass_.g."]]),
  stringsAsFactors = FALSE, check.names = FALSE
)

# ---- write analysis CSV + DOI-coded public TSV ------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- read_excel("__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) {
  item_encoded <- "10.1098%2Frspb.2021.0937_MammalGait"  # fallback until registry recalculated
  warning("Item not yet in __ReadMe.xlsx cache; using known encoded name.")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

cat("Wimberly MammalGait:", nrow(df), "species written\n")
