# Hevner_WongRiley_1990_Text.R -----------------------------------------------------------
#
# Hevner & Wong-Riley (1990), Journal of Neuroscience 10(4): 1331-1340. CO
# densitometry values printed only in RESULTS "Densitometric analyses" (p. 1335
# right column and p. 1337 left column), not in Table 1: the puff/interpuff CO
# enrichment and the TTX light/dark ocular-dominance-column decline, each as a
# percentage, for CO histochemistry (activity) and CO immunohistochemistry (protein).
#
# Reads the constructed, frozen snapshot Hevner_WongRiley_1990_Text_snapshot.csv (one row
# per printed value, written by Hevner_WongRiley_1990_Text_snapshot.R) and:
#   - parses the printed percentage and signs it (+ = puffs darker than interpuffs,
#     - = light columns decreased relative to dark columns);
#   - assigns condition (control / TTX), cortical layer (RESULTS p. 1334 places the
#     puffs in layers 2 and 3; the p. 1337 passage names layer 4C), compartment
#     comparison and stain method;
#   - species_as_published and n_animals come from METHODS p. 1331 (7 normal Macaca
#     fascicularis; 3 TTX-treated: 2 M. radiata, 1 M. fascicularis) as metadata;
#     Species from _keys/General/species_key.csv (rows for this folder).
# value_status: every row is the authors' percentage restatement of a Table 1 ratio
# (1.32 -> 32 %, 1.19 -> 19 %, 0.80 -> -20 %, 0.79 -> -21 %); the cross-item check
# lives in internal_checks/Hevner_WongRiley_1990_Text_internal_check.R (HOWTO 7b).
# No value is typed in this script.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base  <- item_name

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))

root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[species_key$source_publication == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk <- setNames(species_key$accepted_name, tolower(species_key$variant_name))

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 4L, identical(tx$text_row, as.character(1:4)),
          all(tx$stain_method_as_printed %in% c("histochemically", "immunohistochemically")))

is_ttx <- grepl("^TTX-treated", tx$subjects_as_printed)
stopifnot(identical(is_ttx, c(FALSE, FALSE, TRUE, TRUE)))
decrease <- grepl("decreased", tx$units_printed)
stopifnot(identical(decrease, is_ttx))

final.dataframe <- data.frame(
  text_row            = as.integer(tx$text_row),
  page                = tx$page,
  location            = tx$location,
  passage_as_printed  = tx$passage_as_printed,
  subjects_as_printed = tx$subjects_as_printed,
  region_as_printed   = tx$region_as_printed,
  stain_method_as_printed = tx$stain_method_as_printed,
  stain_method        = unname(c(histochemically = "CO histochemistry",
                                 immunohistochemically = "CO immunohistochemistry")[tx$stain_method_as_printed]),
  stain_target        = ifelse(tx$stain_method_as_printed == "histochemically",
                               "CO enzymatic activity", "CO protein (anti-CO IgG, mainly subunit IV)"),
  condition           = ifelse(is_ttx, "TTX", "control"),
  cortical_layer      = ifelse(is_ttx, "layer 4C", "layers 2 and 3"),
  compartment_comparison = ifelse(is_ttx, "light column vs dark column", "puff vs interpuff"),
  significance_as_printed = tx$significance_as_printed,
  cited_ref           = ifelse(nzchar(tx$cited_ref), tx$cited_ref, NA_character_),
  value_printed       = tx$value_printed,
  units_printed       = tx$units_printed,
  stringsAsFactors = FALSE)
stopifnot(identical(final.dataframe$stain_method, rep(c("CO histochemistry", "CO immunohistochemistry"), 2)))
final.dataframe$value_numeric  <- num_of(final.dataframe$value_printed)
final.dataframe$measure        <- "CO_relOD_pct_difference"
final.dataframe$CO_relOD_pct_difference <- ifelse(decrease, -1, 1) * final.dataframe$value_numeric
final.dataframe$value_status   <- "restatement_of_Table1_ratio"
final.dataframe$n_readings     <- 25L           # Table 1 footnote / METHODS p. 1332: 25 regions of each type per section
final.dataframe$n_animals      <- ifelse(is_ttx, 3L, 7L)   # METHODS p. 1331
final.dataframe$species_as_published <- ifelse(is_ttx, "TTX-treated macaques (2 M. radiata, 1 M. fascicularis)",
                                               "Macaca fascicularis")
final.dataframe$Species <- unname(lk[tolower(final.dataframe$species_as_published)])
final.dataframe$data_role <- "primary"
final.dataframe$note <- ifelse(is_ttx,
  "Percent decrease of the TTX-eye (light) ocular dominance column relative to the untreated-eye (dark) column in layer 4C; pooled group of 3 TTX-treated animals of two species; equals 100 x (1 - Table 1 light-column relative OD).",
  "Percent CO enrichment of puffs over interpuffs in layers 2-3 of normal striate cortex (RESULTS p. 1334 places the puffs in layers 2 and 3); equals 100 x (Table 1 puff relative OD - 1).")
stopifnot(!anyNA(final.dataframe$Species), !anyNA(final.dataframe$value_numeric))

## ---- table checks -------------------------------------------------------------
## Every check for this item compares a printed percentage with a Table 1 ratio, i.e.
## needs the sibling snapshot: all four live in
## internal_checks/Hevner_WongRiley_1990_Text_internal_check.R (HOWTO 7b). None here.

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                               .name_repair = "minimal")
registry_row <- which(registry[["Item name"]] == item_name & !is.na(registry[["Item name"]]))
if (length(registry_row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][registry_row]
if (is.na(item_encoded) || !nzchar(item_encoded)) stop("Registered Item encoded is blank for ", item_name)
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV directory not found")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
message(item_name, ": public TSV ", item_encoded, ".tsv")
