## Kochiyama_etal_2018 — Fossil specimens (compiled from the main-paper TEXT)
## Snapshot -> clean CSV (+ DOI-encoded TSV). Golden rule: the snapshot is
## frozen/faithful; ALL cleaning happens here.
##
## Key transformation requested: parse the printed specimen date range (p.1),
## e.g. "~50,000-70,000 years old", into date_min_yBP / date_max_yBP and compute
## the AVERAGE (midpoint) date_mean_yBP. Single-value dates ("~35,000 years old")
## give min = max = mean; "no dating information" gives NA. Also expands the taxon
## code, converts volumes cc -> mm3, and carries the NT-H.sapiens divergence
## (p.1, ref 19) and the date-citation reference numbers (pp.7-8).

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## row 1 = caption, row 2 = header, rows 3-10 = the 8 specimens
raw <- read.csv("Kochiyama_etal_2018_FossilSpecimensText_snapshot.csv", skip = 1,
                check.names = FALSE, colClasses = "character",
                stringsAsFactors = FALSE, na.strings = c())

## ---- parse the printed date range -> min / max / mean (years before present) --
parse_dates <- function(s) {
  if (is.na(s) || grepl("no dating", s, ignore.case = TRUE)) return(c(NA_real_, NA_real_))
  toks <- regmatches(s, gregexpr("[0-9][0-9,]*", s))[[1]]
  nums <- suppressWarnings(as.numeric(gsub(",", "", toks)))
  nums <- nums[!is.na(nums)]
  if (length(nums) == 0) return(c(NA_real_, NA_real_))
  if (length(nums) == 1) return(c(nums, nums))
  c(min(nums), max(nums))
}
dr <- t(vapply(raw$Date_printed_p1, parse_dates, numeric(2)))
date_min <- dr[, 1]; date_max <- dr[, 2]
date_mean <- (date_min + date_max) / 2                    # the requested average
date_note <- ifelse(is.na(date_min), "no dating information",
              ifelse(date_min == date_max, "point estimate", "range midpoint"))

## ---- taxon expansion (from the printed "Taxon_as_used") -----------------------
is_nt      <- grepl("^NT", raw$Taxon_as_used)
taxon_code <- ifelse(is_nt, "NT", "EH")
taxon_group <- ifelse(is_nt, "Neanderthal", "early Homo sapiens")
species    <- ifelse(is_nt, "Homo neanderthalensis", "Homo sapiens")

as_num <- function(x) suppressWarnings(as.numeric(x))
cer <- as_num(raw$Cerebral_cc_p2); cbl <- as_num(raw$Cerebellar_cc_p2)

clean <- data.frame(
  Specimen                   = raw$Specimen,
  Taxon_code                 = taxon_code,
  Taxon_group                = taxon_group,
  Species                    = species,
  date_min_yBP               = date_min,
  date_max_yBP               = date_max,
  date_mean_yBP              = date_mean,
  date_note                  = date_note,
  species_divergence_min_yBP = 600000L,       # NT-H. sapiens split (p.1, ref 19)
  species_divergence_max_yBP = 800000L,
  species_divergence_ref     = "19",
  `Cerebrum_Vol.cc`          = cer,
  `Cerebrum_Vol.mm3`         = cer * 1000,     # cc -> mm3
  `Cerebellum_Vol.cc`        = cbl,
  `Cerebellum_Vol.mm3`       = cbl * 1000,
  Cerebellum_Cerebrum_ratio  = round(cbl / cer, 4),
  date_refs_Kochiyama        = gsub("\\s*,\\s*", ";", trimws(ifelse(is.na(raw$Date_refs), "", raw$Date_refs))),
  source                     = "Kochiyama_etal_2018",
  check.names = FALSE, stringsAsFactors = FALSE
)
stopifnot(nrow(clean) == 8L)

## ---- write local CSV ----------------------------------------------------------
write.csv(clean, paste0(item_name, ".csv"), row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows; date_mean_yBP computed from the printed ranges")

## ---- write public TSV ---------------------------------------------------------
## Not yet in __ReadMe.xlsx; fall back to the proposed encoded name so a TSV is
## still produced (matches the file already in __Public/comparative-data).
tsv_dir <- file.path(base, "__Public", "comparative-data")
enc <- NA_character_
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- try(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"), silent = TRUE)
  if (!inherits(fc, "try-error"))
    enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
}
if (is.na(enc) || !nzchar(enc))
  enc <- "10.1038%2Fs41598-018-24331-0_FossilSpecimensText"   # proposed (add a registry row)
if (dir.exists(path.expand(tsv_dir))) {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
} else {
  warning("Shared __Public folder not found; TSV skipped.")
}
