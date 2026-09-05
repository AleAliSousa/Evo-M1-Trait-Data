# Medina-González 2026 — Supplementary File 2 (Locomotor Habit Classification and Justification)
# -> analysis CSV + public TSV.
# Frozen source (digital-native, no derived snapshot; §0a invariant 1): the untouched Wiley
# online-article download "jez70069-sup-0002-supplementary_file_2.xlsx", obtained from
# https://onlinelibrary.wiley.com/doi/10.1002/jez.70069.
#
# Granularity: PER-RECORD (182 rows / 77 species), aligned 1:1 by row position with Supplementary
# File 3 (N == ID; verified order/species/habit match exactly). The Locomotor_habit column
# duplicates the one in the Data table; this table's value-add is the per-record Justification.

invisible(suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8")))  # non-ASCII paths need a UTF-8 CTYPE locale
library(readxl)

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(repo)
folder    <- list.files(".", pattern = "^MedinaGonz.*lez__2026$")[1]
item_name <- "MedinaGonzález__2026_SupplementaryFile2"
src_file  <- file.path(folder, "jez70069-sup-0002-supplementary_file_2.xlsx")

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

raw <- as.data.frame(read_excel(src_file, sheet = "Sheet1", skip = 1, .name_repair = "minimal"),
                     stringsAsFactors = FALSE, check.names = FALSE)
raw <- raw[!is.na(raw$Specie) & nzchar(trimws(raw$Specie)), ]

df <- data.frame(
  Record_ID       = as.integer(raw$"N°"),
  species_sci     = vapply(raw$Specie, resolve, character(1)),
  Species         = clean_sp(raw$Specie),
  Order           = raw$Order,
  Locomotor_habit = trimws(raw[[grep("^Locomotor habit", names(raw), value = TRUE)[1]]]),
  Justification   = trimws(raw$Justification),
  stringsAsFactors = FALSE, check.names = FALSE
)

stopifnot(nrow(df) == 182)

write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- read_excel("__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (length(item_encoded) == 0 || is.na(item_encoded)) {
  item_encoded <- "10.1002%2Fjez.70069_SupplementaryFile2"  # fallback until registry row is pasted
  warning("Item not yet in __ReadMe.xlsx (new row pending owner paste); using proposed encoded name.")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

cat("MedinaGonzález__2026_SupplementaryFile2:", nrow(df), "records /", length(unique(df$Species)), "species written\n")
