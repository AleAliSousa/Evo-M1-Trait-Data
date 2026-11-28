## Hansen_etal_2022_PET-parcellated-scale033_snapshot.R -- writes ONLY the frozen snapshot
## Hansen_etal_2022_PET-parcellated-scale033_snapshot.csv (constructed snapshot, see README).
##
## Hansen JY et al. (2022) Nat Neurosci 25:1569-1581, doi 10.1038/s41593-022-01186-3.
## The paper publishes NO region table: the data are voxelwise group-average PET maps. The
## authors' repository (netneurolab/hansen_receptors, commit f8b41da92a733f99368c1f39d4959731aa1316c1,
## frozen in github_hansen_receptors/ with download_manifest.csv) carries the digital-native
## tabulation: data/PET_parcellated/scale033/<tracer_file>.csv = one vector of 83 values per
## tracer map (Lausanne scale033 = 68 Desikan-Killiany cortical + 15 subcortical regions, order
## given by data/lausanne/region_info_scale033.xlsx). This script ASSEMBLES those 41 vectors
## into one region x tracer-file table. Values are carried as the verbatim text tokens of the
## source files (no numeric parsing, no re-formatting); region metadata columns are copied
## from region_info_scale033.xlsx as read. Nothing is cleaned here -- that is the job of
## Hansen_etal_2022_PET-parcellated-scale033.R.

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                             # this paper's folder
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = Hansen_etal_2022_PET-parcellated-scale033
base      <- local({                                                  # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

library(readxl)

## 1. SOURCE (frozen download of the authors' repository) ------------------
src_dir      <- file.path(folder, "github_hansen_receptors")
manifest     <- utils::read.csv(file.path(src_dir, "download_manifest.csv"), stringsAsFactors = FALSE)
region_xlsx  <- file.path(src_dir, "data", "lausanne", "region_info_scale033.xlsx")
tracer_dir   <- file.path(src_dir, "data", "PET_parcellated", "scale033")
tracer_files <- sort(list.files(tracer_dir, pattern = "\\.csv$", full.names = TRUE))
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))

if (length(tracer_files) != 41L)
  stop("Expected 41 tracer files in ", tracer_dir, ", found ", length(tracer_files), call. = FALSE)

## 1a. Integrity: every tracer CSV read here must match the sha256 recorded at download.
## The region xlsx is checked too, but a mismatch there only warns: OneDrive/SharePoint
## re-saves .xlsx files in place (adds customXml metadata parts; 12263 -> 19495 bytes), which
## changes the bytes but not the cells. Cell content was verified identical to the
## commit-pinned raw file on 2026-11-15 (see README, "Frozen source").
if (requireNamespace("digest", quietly = TRUE)) {
  for (f in c(tracer_files, region_xlsx)) {
    rel <- sub(paste0("^", normalizePath(src_dir), "/"), "", normalizePath(f))
    m   <- manifest[manifest$repo_path == rel, , drop = FALSE]
    if (nrow(m) != 1L) stop("Source file not in download_manifest.csv: ", rel, call. = FALSE)
    h <- digest::digest(f, algo = "sha256", file = TRUE)
    if (!identical(h, m$sha256)) {
      if (grepl("\\.xlsx$", rel)) warning("sha256 of ", rel, " differs from download_manifest.csv (expected for a OneDrive-resaved xlsx; cells verified identical 2026-11-15)")
      else stop("sha256 mismatch vs download_manifest.csv: ", rel, call. = FALSE)
    }
  }
  message("sha256 verified for ", length(tracer_files), " tracer files against download_manifest.csv")
} else {
  warning("Package 'digest' not available: source sha256 not verified against download_manifest.csv")
}

## 2. REGION METADATA (as read; column order and spellings kept) ------------
regions <- as.data.frame(readxl::read_excel(region_xlsx, .name_repair = "minimal"), check.names = FALSE)
names(regions)[names(regions) == ""] <- "row_index"           # unnamed first column = the authors' 0-based row index
if (nrow(regions) != 83L) stop("Expected 83 regions, found ", nrow(regions), call. = FALSE)
regions$scale <- NULL                                          # constant 'scale033' already in the item name; dropped from the snapshot

## 3. TRACER VECTORS -- verbatim text tokens, no numeric parsing --------------
## Source files are either one row of 83 comma-separated values or 83 lines of one value
## (three files: GABAa_FLUMAZENIL_c11, SERT_DASB_HC30, SERT_MADAM_c11). Both forms are
## tokenised on comma/newline; empty trailing tokens are dropped.
read_tokens <- function(f) {
  txt  <- paste(readLines(f, warn = FALSE), collapse = "\n")
  toks <- trimws(strsplit(txt, "[,\n]")[[1]])
  toks <- toks[nzchar(toks)]
  if (length(toks) != 83L) stop("Expected 83 values in ", basename(f), ", found ", length(toks), call. = FALSE)
  toks
}
vals <- lapply(tracer_files, read_tokens)
names(vals) <- tools::file_path_sans_ext(basename(tracer_files))
snap <- cbind(regions, as.data.frame(vals, check.names = FALSE, stringsAsFactors = FALSE))

## 4. WRITE THE FROZEN COPY (refuse to overwrite a differing one) -------------
if (file.exists(snapshot_csv)) {
  old <- utils::read.csv(snapshot_csv, colClasses = "character", check.names = FALSE)
  new <- as.data.frame(lapply(snap, as.character), check.names = FALSE, stringsAsFactors = FALSE)
  if (!identical(dim(old), dim(new)) || !identical(names(old), names(new)) ||
      !all(mapply(function(a, b) all(a == b), old, new)))
    stop("Existing ", basename(snapshot_csv), " differs from a fresh assembly -- not overwriting. ",
         "Delete it deliberately if the source tree changed.", call. = FALSE)
  message("Snapshot unchanged: ", basename(snapshot_csv))
} else {
  utils::write.csv(snap, snapshot_csv, row.names = FALSE, quote = TRUE)
  message("Wrote ", nrow(snap), " regions x ", length(vals), " tracer files -> ", basename(snapshot_csv))
}
