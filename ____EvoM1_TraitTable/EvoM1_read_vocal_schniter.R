# EvoM1: vocal repertoire size (Schniter & Penaherrera-Aguirre 2026)
#        -> vocal_repertoire_schniter.xlsx
# Number of vocalization types per primate species. Two columns:
#   vocal_repertoire_size_MS2005  (original McComb & Semple 2005 values)
#   vocal_repertoire_size_updated (contemporary update; per-species reference)
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
## Registry Item name. Column F of __ReadMe.xlsx now strips hyphens from the second
## author, so the name is PenaherreraAguirre (was "Schniter_Penaherrera-Aguirre_2026_data").
item_name   <- "Schniter_PenaherreraAguirre_2026_data"
MS_REF <- "McComb, K., & Semple, S. (2005). Coevolution of vocal communication and sociality in primates. Biology Letters, 1(4), 381-385."

# species resolver (single source of truth = _keys)
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) { c <- clean_sp(x)
  h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }

filecodes    <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
## Without this guard an unmatched name read __Public/comparative-data/NA.tsv -- an
## unrelated stale table -- and failed later with "differing number of rows: 0, 1".
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded))
  stop("No 'Item encoded' in __ReadMe.xlsx for Item name '", item_name, "'", call. = FALSE)
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

need <- c("Species", "vocal_repertoire_size_MS2005", "vocal_repertoire_size_updated",
          "repertoire_update_reference")
if (!all(need %in% names(d)) || !nrow(d))
  stop(item_encoded, ".tsv is not the Schniter & Penaherrera-Aguirre table (missing: ",
       paste(setdiff(need, names(d)), collapse = ", "), ")", call. = FALSE)

upd_src <- ifelse(is.na(d$repertoire_update_reference) |
                    !nzchar(trimws(d$repertoire_update_reference)),
                  MS_REF, d$repertoire_update_reference)

out <- data.frame(
  species_sci                          = vapply(d$Species, resolve, character(1)),
  Species                              = trimws(d$Species),
  vocal_repertoire_size_MS2005         = d$vocal_repertoire_size_MS2005,
  vocal_repertoire_size_MS2005_Source  = MS_REF,
  vocal_repertoire_size_updated        = d$vocal_repertoire_size_updated,
  vocal_repertoire_size_updated_Source = upd_src,
  stringsAsFactors = FALSE, check.names = FALSE
)
write_xlsx(out, paste0(folder_path, "vocal_repertoire_schniter.xlsx"))
cat("vocal_repertoire_schniter.xlsx:", nrow(out), "rows\n")
