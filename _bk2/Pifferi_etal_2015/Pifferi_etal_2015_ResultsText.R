# Pifferi_etal_2015_ResultsText.R --------------------------------------------
#
# Pifferi et al. (2015), J Lipid Res 56: 1511-1518. doi:10.1194/jlr.M058933
# RESULTS, "Brain glucose uptake and metabolism", p. 1515: regional and
# whole-brain CMRglu (µmol/min/100 g) and SUVmax (g/ml) of male grey mouse
# lemurs (Microcebus murinus) after 12 months on a control (olive oil) or an
# n-3 LCPUFA (tuna/fish oil) supplemented diet. The values are printed only
# in running text (Fig. 3 / Fig. 4 plot the same data).
#
# Reads the constructed, frozen snapshot Pifferi_etal_2015_ResultsText_snapshot.csv
# (written from the PDF text layer by Pifferi_etal_2015_extract_snapshot.R)
# and does all the cleaning:
#   - splits each printed "mean ± SEM" lexeme into a mean and a dispersion;
#   - reshapes to ONE ROW PER REGION x DIET GROUP, keeping the printed group
#     label ("control", "n-3") and the printed region label;
#   - flags the control group (olive oil) with is_control = 1.
# Observation level: diet-group means of n = 6 male animals (Methods p. 1512:
# "n = 6/group"; Fig. 3/4 legends: "n = 6 in each dietary group"). Pool or
# select groups explicitly before any species-level use; the HEALTHY CONTROL
# is group "control" (olive oil).
# Units: CMRglu kept as printed, µmol/min/100 g (per 100 g tissue mass: the
# __merging_cerebral_metabolic_rate standard µmol/100 g/min, same quantity,
# no conversion needed); SUVmax in g/ml as printed. No value is typed here.

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
base <- item_name

suppressPackageStartupMessages(library(readxl))

tx <- read.csv(paste0(base, "_snapshot.csv"), colClasses = "character", na.strings = character(0),
               check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(tx) == 16L, identical(tx$text_row, as.character(1:16)),
          all(tx$groups_as_printed == "control vs. n-3"),
          identical(unique(tx$units_as_printed), c("g/ml", "\u00b5mol/min/100 g")))
regions <- tx$region_as_printed[1:8]
stopifnot(identical(tx$region_as_printed[9:16], regions))

## ---- lexeme helpers: "13.9 ± 3.6" -> 13.9 / 3.6 -----------------------------------
## A lexeme that does not have the form "<number> ± <number>" yields NA for the
## dispersion and keeps its mean only if the leading token is a number; it is
## never repaired here (see errata Pifferi_etal_2015-E001).
is_pm   <- function(x) grepl("^[0-9.]+ \u00b1 [0-9.]+$", x)
mean_of <- function(x) suppressWarnings(as.numeric(sub("^([0-9.]+).*$", "\\1", x)))
disp_of <- function(x) ifelse(is_pm(x), suppressWarnings(as.numeric(sub("^.*\u00b1 ", "", x))), NA_real_)

canonical <- c("whole brain" = "Whole_brain", "hippocampus" = "Hippocampus", "thalamus" = "Thalamus",
               "cerebellum" = "Cerebellum", "caudate nucleus" = "Caudate_nucleus",
               "temporal lobe" = "Temporal_cortex", "occipital lobe" = "Occipital_cortex",
               "frontal lobe" = "Frontal_cortex")   # PROPOSAL for the merge's region map; not applied
stopifnot(all(regions %in% names(canonical)))

suv <- tx[tx$units_as_printed == "g/ml", ]
cmr <- tx[tx$units_as_printed == "\u00b5mol/min/100 g", ]

one_group <- function(g) {
  col <- if (g == "control") "control_printed" else "n3_printed"
  data.frame(
    region_order              = seq_along(regions),
    region_as_printed         = regions,
    region_canonical_proposed = unname(canonical[regions]),
    group_as_printed          = g,
    is_control                = as.integer(g == "control"),
    diet                      = if (g == "control") "olive oil (isoenergetic control supplement, <1% n-3 PUFA as alpha-linolenic acid)" else "tuna oil rich in n-3 LCPUFA (EPA + DHA)",
    species_as_published      = "Microcebus murinus",
    common_name_as_published  = "gray mouse lemur",
    sex                       = "male",
    n                         = 6L,
    dispersion_type           = "SEM",
    CMRglu.umol_min_100g      = mean_of(cmr[[col]]),
    CMRglu_SEM.umol_min_100g  = disp_of(cmr[[col]]),
    CMRglu_printed            = cmr[[col]],
    CMRglu_text_row           = as.integer(cmr$text_row),
    SUVmax.g_ml               = mean_of(suv[[col]]),
    SUVmax_SEM.g_ml           = disp_of(suv[[col]]),
    SUVmax_printed            = suv[[col]],
    SUVmax_text_row           = as.integer(suv$text_row),
    note                      = NA_character_,
    stringsAsFactors = FALSE)
}
final.dataframe <- rbind(one_group("control"), one_group("n-3"))

bad_lex <- which(!is_pm(final.dataframe$SUVmax_printed))
stopifnot(identical(final.dataframe$region_as_printed[bad_lex], "caudate nucleus"),
          identical(final.dataframe$group_as_printed[bad_lex], "n-3"),
          all(is_pm(final.dataframe$CMRglu_printed)))
final.dataframe$note[bad_lex] <- paste(
  "SUVmax printed '4.83 versus 0.68' (the '±' is printed as a second 'versus'); mean kept,",
  "SEM left NA here. Errata Pifferi_etal_2015-E001 proposes 0.68.")
final.dataframe$note[final.dataframe$region_as_printed == "cerebellum"] <-
  "Whole-cerebellum VOI (manual MRI segmentation); not cerebellar cortex alone."
final.dataframe$note[final.dataframe$region_as_printed == "whole brain"] <-
  "Whole-brain VOI; brain mass/volume not reported."
stopifnot(sum(is.na(final.dataframe[, c("CMRglu.umol_min_100g", "CMRglu_SEM.umol_min_100g",
                                        "SUVmax.g_ml")])) == 0L)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV (only once registered) ---------------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
