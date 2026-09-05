# Medina-González 2026 — Supplementary File 1 (source list for joint-angle/excursion extraction
# by species) -> analysis CSV + public TSV + reference_tables copy.
# Frozen source (digital-native, no derived snapshot): the untouched Wiley online-article download
# "jez70069-sup-0001-supplementary_file_1.xlsx".
#
# Registered in __ReadMe.xlsx as its own item (Item name = MedinaGonzález__2026_SupplementaryFile1,
# Data role = both) -- built as a full table like Files 2/3, even though its main value is
# provenance documentation (per-row source citations), because the registry now expects a public
# TSV for it. 182 rows / 77 species, but its row order does NOT align with Supplementary Files
# 2/3, and its blank "Source name" cells do not reduce to a clean per-species or
# per-contiguous-block fill (113 contiguous species-runs vs 77 species, 46 runs with no source at
# all) -- kept EXACTLY as printed, no forward-fill, no inferred grouping (never silently corrected).

invisible(suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8")))  # non-ASCII paths need a UTF-8 CTYPE locale
library(readxl)

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(repo)
folder    <- list.files(".", pattern = "^MedinaGonz.*lez__2026$")[1]
item_name <- "MedinaGonzález__2026_SupplementaryFile1"
src_file  <- file.path(folder, "jez70069-sup-0001-supplementary_file_1.xlsx")

raw <- as.data.frame(read_excel(src_file, sheet = "Hoja1", skip = 1, .name_repair = "minimal"),
                     stringsAsFactors = FALSE, check.names = FALSE)
raw <- raw[!is.na(raw$Specie) & nzchar(trimws(raw$Specie)), ]

df <- data.frame(
  Row_ID      = seq_len(nrow(raw)),
  Order       = raw$Order,
  Specie      = raw$Specie,
  Source_name = raw$"Source name",   # NA/blank kept exactly as printed -- see header note
  stringsAsFactors = FALSE, check.names = FALSE
)

stopifnot(nrow(df) == 182)

# ---- write analysis CSV + DOI-coded public TSV ------------------------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- read_excel("__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (length(item_encoded) == 0 || is.na(item_encoded)) {
  item_encoded <- "10.1002%2Fjez.70069_SupplementaryFile1"  # fallback matching __ReadMe.xlsx row 258
  warning("Item not yet resolved from __ReadMe.xlsx cache; using known encoded name.")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

# ---- also keep an internal reference_tables copy (used by the paper README / other builds) ----
out_dir <- file.path(folder, "reference_tables")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
write.csv(df, file.path(out_dir, "MedinaGonzález__2026_references.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("MedinaGonzález__2026_SupplementaryFile1:", nrow(df), "rows,",
    sum(!is.na(df$Source_name)), "with a source cited, written\n")
