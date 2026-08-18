# EvoM1: corticospinal / corticomotoneuronal termination extent (Bortoff & Strick 1993)
#   -> corticospinal_terminations.xlsx
# PRIMARY: the authors' own WGA-HRP anterograde tract tracing from M1 in two New-World
# primates. Only the ordinal 0-2 grade is curatorial:
#   0 absent/virtually absent from ventral horn or lamina IX
#   1 sparse or highly restricted   2 dense and extensive
# CM_monosynaptic is carried but is all-NA by design - the paper is explicit (Discussion
# pp. 5110-5111) that light microscopy settles neither presence nor absence. The authors'
# softer reading stays in CM_connection_inference (likely / against), so an inference is
# never promoted to a fact. Consumed by __merging_behaviour as measure class motor_pathway,
# team Bortoff_Strick. Heffner & Masterton's dexterity scale is a SEPARATE behaviour
# variable and is never used as a substitute for this anatomical grade.
#
# SPECIES NAMES - deliberately NOT re-resolved here. Unlike the sibling readers this one
# carries `species_sci` straight through from the public TSV, because the printed name
# "Cebus apella" is PAPER-SCOPED: species_key.csv holds three different decisions for that
# same variant (MacLeod2003 -> Cebus apella, Reader2011 and Bortoff1993 -> Sapajus apella).
# A flat, unscoped `setNames(key$accepted_name, key$variant_name)` lookup takes the first
# match and would silently return MacLeod's Cebus apella, breaking the join with the merge.
# The token-scoped resolution happens once, in Bortoff_Strick_1993_Table1.R; the check below
# just asserts that the TSV still agrees with the Bortoff1993 key rows.
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Bortoff_Strick_1993_Table1"
TOKEN       <- "Bortoff1993"

filecodes    <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

# paper-scoped guard: the TSV's species_sci must equal the Bortoff1993 key decision
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
key <- key[trimws(key$source_publication) == TOKEN, ]
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
expected <- unname(km[tolower(trimws(d$Species_printed))])
if (any(is.na(expected)) || !all(expected == d$species_sci))
  stop("species_sci in the TSV disagrees with the ", TOKEN,
       " rows of species_key.csv - re-run Bortoff_Strick_1993_Table1.R")

out <- data.frame(
  species_sci             = d$species_sci,
  Species                 = d$species_sci,
  Species_printed         = trimws(d$Species_printed),
  CST_termination_grade   = d$CST_termination_grade,
  CM_monosynaptic         = d$CM_monosynaptic,
  CM_connection_inference = d$CM_connection_inference,
  Source                  = d$Source,
  DOI                     = d$DOI,
  Source_location         = d$Source_location,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(all(out$CST_termination_grade %in% 0:2))
write_xlsx(out, paste0(folder_path, "corticospinal_terminations.xlsx"))
cat("corticospinal_terminations.xlsx:", nrow(out), "rows; grades",
    paste(sort(unique(out$CST_termination_grade)), collapse = ", "), "\n")
