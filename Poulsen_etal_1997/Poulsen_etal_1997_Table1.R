# Poulsen_etal_1997_Table1.R -------------------------------------------------
#
# Poulsen, Smith, Ostergaard, Danielsen, Gee, Hansen, Astrup & Gjedde (1997),
# J Neurosci Methods 77: 199-209. doi:10.1016/S0165-0270(97)00127-1
# Table 1 "Physiological variables: average (standard deviation in brackets
# (n = 7))", p. 203.
#
# Reads the frozen snapshot Poulsen_etal_1997_Table1_snapshot.csv (written by
# Poulsen_etal_1997_Table1_snapshot.R) and does all the cleaning:
#   - checks the printed caption and the eight printed headers;
#   - splits each printed "mean (SD)" cell into a mean and an SD column whose
#     names carry the printed unit;
#   - adds species / cohort context from the Methods (single-species paper:
#     the table prints no species).
# Observation level: ONE cohort of 7 anaesthetised, ventilated pigs; the row
# is a cohort mean, not a species mean.
# Units: kept as printed (mM, kPa, mmHg, min^-1, °C). No project-unit
# conversion applies (HOWTO section 6 covers volumes and masses only).
# No table value is typed in this script.

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

snap <- as.matrix(read.csv(paste0(base, "_snapshot.csv"), header = FALSE, colClasses = "character",
                           na.strings = character(0), check.names = FALSE, encoding = "UTF-8"))
dimnames(snap) <- NULL
stopifnot(identical(dim(snap), c(5L, 8L)))
stopifnot(snap[1, 1] == "Table 1",
          grepl("standard deviation in brackets \\(n = 7\\)", snap[2, 1]))
stopifnot(identical(snap[3, ], c("Hgb (mM)", "pH", "MABP (mmHg)", "HR (min^-1)", "PaO2 (kPa)",
                                 "O2 (mM)", "Tp (°C)", "Pglc (mM)")))

## ---- cell helpers: "5.6 (0.6)" -> mean 5.6, SD 0.6 -----------------------------
mean_of <- function(x) suppressWarnings(as.numeric(sub("^\\s*([-0-9.]+)\\s*\\(.*$", "\\1", x)))
sd_of   <- function(x) suppressWarnings(as.numeric(sub("^.*\\(\\s*([0-9.]+)\\s*\\)\\s*$", "\\1", x)))
n_printed <- as.integer(sub("^.*\\(n = ([0-9]+)\\).*$", "\\1", snap[2, 1]))

v <- snap[4, ]
stopifnot(all(grepl("^[0-9.]+ \\([0-9.]+\\)$", v)))

final.dataframe <- data.frame(
  printed_row            = 4L,
  species_as_published   = "pig",
  breed_as_published     = "Danish Yorkshire land race",
  cohort                 = "all animals: young, normal, anaesthetised (midazolam + ketamine + pancuronium), ventilated (30% O2), 12 h fasted",
  n                      = n_printed,
  dispersion_type        = "SD",
  Hgb.mM                 = mean_of(v[1]), Hgb_SD.mM          = sd_of(v[1]),
  pH                     = mean_of(v[2]), pH_SD              = sd_of(v[2]),
  MABP.mmHg              = mean_of(v[3]), MABP_SD.mmHg       = sd_of(v[3]),
  HR.per_min             = mean_of(v[4]), HR_SD.per_min      = sd_of(v[4]),
  PaO2.kPa               = mean_of(v[5]), PaO2_SD.kPa        = sd_of(v[5]),
  O2_arterial.mM         = mean_of(v[6]), O2_arterial_SD.mM  = sd_of(v[6]),
  Tp.degC                = mean_of(v[7]), Tp_SD.degC         = sd_of(v[7]),
  Pglc.mM                = mean_of(v[8]), Pglc_SD.mM         = sd_of(v[8]),
  note = paste("Single cohort; species is not printed in the table (title: 'in the pig';",
               "Methods p. 200: 'Seven young pigs of the Danish Yorkshire land race, with a",
               "mean weight of 40 ± 2 kg'). Arterial O2 is calculated, not measured (Eq. 5, p. 201)."),
  stringsAsFactors = FALSE
)
stopifnot(!anyNA(final.dataframe[, grep("\\.|^pH", names(final.dataframe))]))

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " row x ", ncol(final.dataframe),
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
