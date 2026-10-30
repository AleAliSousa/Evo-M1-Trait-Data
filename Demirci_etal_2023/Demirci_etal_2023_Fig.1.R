## Demirci, Hoffman & Holland 2023, NeuroImage 278:120283 — Fig. 1 (+ Table 1 subject context)
## doi:10.1016/j.neuroimage.2023.120283 · MRI cortical surface reconstructions, 12 primate species.
## Fig. 1 prints total surface area (SA) and cerebral volume (V) under each species' reconstructed
## cortical surface — read from the full-resolution figure (1-s2.0-S1053811923004342-gr1_lrg.jpg,
## in this folder). SA/V are WHOLE-CEREBRUM (both hemispheres): HALVE SA for the merge's
## per-hemisphere convention (Kaskan review sheet note, roadmap item 2). For multi-subject species
## (macaque n=31, chimp n=54, human n=501; Table 1) Fig. 1 prints one representative/average value.
## Snapshot frozen from the curator's transcription; all cleaning here (golden rule).

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))            # Demirci_etal_2023_Fig.1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

snap <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
fig1 <- as.data.frame(read_excel(snap, sheet = "Fig1"))
fig1 <- fig1[!is.na(fig1[[1]]) & !grepl("^Caption", fig1[[1]]), ]
t1   <- as.data.frame(read_excel(snap, sheet = "Table1"))
t1   <- t1[!is.na(t1[[1]]) & !grepl("^Table 1 note", t1[[1]]), ]

## Fig.1 prints "Colobus"; Table 1 prints "Black-white colobus" — join on a shared key.
key <- function(x) ifelse(grepl("colobus", tolower(x)), "colobus", tolower(trimws(x)))
m   <- match(key(fig1[[1]]), key(t1[["Common name"]]))
stopifnot(!anyNA(m))

sci <- t1[["Scientific name"]][m]
sci[sci == "Homo Sapiens"] <- "Homo sapiens"                    # capitalization as-printed fix
status <- c(PM = "postmortem", IV = "in vivo")[t1[["Subject status"]][m]]

note <- paste0("SA and V are whole-cerebrum (both hemispheres) totals from Fig. 1; halve SA for ",
               "the merge's per-hemisphere convention. For multi-subject species (macaque n=31, ",
               "chimp n=54, human n=501) Fig. 1 prints a single representative/average value.")

clean <- data.frame(
  Species     = sci,
  common_name = tolower(trimws(fig1[[1]])),
  size_group  = fig1[["Group"]],
  n           = as.numeric(t1[["N"]][m]),
  sex_MF      = as.character(t1[["Gender M:F"]][m]),
  age_years   = as.character(t1[["Age [years]"]][m]),
  subject_status  = unname(status),
  specimen_source = t1[["Source"]][m],
  total_surface_area_cm2 = as.numeric(fig1[["SA [cm2]"]]),
  cerebral_volume_cm3    = as.numeric(fig1[["V [cm3]"]]),
  note = note, source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " species rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
