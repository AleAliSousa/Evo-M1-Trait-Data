
## Qiu et al. (2022) recoverable population records -- frozen author S5 workbook -> analysis CSV
##
## Source: Qiu, J., Olivier, C., Jaeggi, A. V., et al. (2022). The evolution of marsupial social
##   organization. Proc R Soc B 289:20221589. https://doi.org/10.1098/rspb.2022.1589
## Frozen source: Qiu_etal_2022_Populations_snapshot.xlsx = the author's S5 workbook, byte-identical
##   to the copy inside source/Model_S5_author_archive.zip (frozen by
##   _checks/social_variables/build_population_censuses.py; this script owns the analysis layer).
##
## The archive is a recoverable SUBSET (141 records, 65 printed species) of the inaccessible full
## Dryad table (149 populations reported); population locations are absent from it. SECONDARY
## classifications, adults only. The single SG record contradicts the publication's statement that
## SG did not occur, so it is kept here and held from the merge (merge_eligible = FALSE).

options(scipen = 999)

## ---- 0. Paths: self-locating, so it runs from any working directory ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir <- dirname(.sp)
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
folder    <- basename(item_dir)              # species_key source_publication for this paper
item_name <- sub("\\.R$", "", basename(.sp))
csv_path  <- file.path(item_dir, paste0(item_name, ".csv"))
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## ---- species guard: every printed name must resolve through this paper's key rows ----
source(file.path(root, "_keys", "resolve_species.R"))
check_species <- function(printed) {
  key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                         check.names = FALSE, encoding = "UTF-8")
  if (sum(trimws(key$source_publication) == folder) == 0L)
    stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
  rs <- resolve_species(printed, source_publication = folder)
  if (any(rs$unresolved))
    stop("printed names that do not resolve: ", paste(unique(printed[rs$unresolved]), collapse = ", "), call. = FALSE)
  invisible(rs)
}

## ---- read every sheet of the frozen workbook ----
snap_xlsx <- file.path(item_dir, paste0(folder, "_Populations_snapshot.xlsx"))
raw <- do.call(rbind, lapply(readxl::excel_sheets(snap_xlsx), function(sh) {
  s <- as.data.frame(readxl::read_excel(snap_xlsx, sheet = sh, col_names = FALSE,
                                        .name_repair = "minimal"), stringsAsFactors = FALSE)
  v <- as.character(s[[1]])
  keep <- !is.na(v) & grepl("_", v, fixed = TRUE) & v != "Genus_species"
  if (!any(keep)) return(NULL)
  data.frame(source_sheet = sh, source_row = which(keep),      # the sheet's own row numbers
             Species_printed = v[keep],
             social_state_printed = trimws(as.character(s[[3]][keep])),
             supporting_references = as.character(s[[6]][keep]),
             stringsAsFactors = FALSE)
}))
if (nrow(raw) != 141L || length(unique(raw$Species_printed)) != 65L)
  stop("expected 141 records over 65 printed species, got ", nrow(raw), " / ",
       length(unique(raw$Species_printed)), call. = FALSE)

## ---- printed state codes (the workbook's own abbreviations) ----
codes <- c(S = "Solitary", P = "Pair-living", G = "Stable group", VG = "Variable group",
           SP = "Solitary + pair", PG = "Pair + group", SPG = "Solitary + pair + group",
           SG = "Solitary + group")
if (!all(raw$social_state_printed %in% names(codes)))
  stop("unknown state code(s): ",
       paste(unique(raw$social_state_printed[!raw$social_state_printed %in% names(codes)]), collapse = ", "),
       call. = FALSE)

printed_species <- gsub("_", " ", trimws(raw$Species_printed))
check_species(printed_species)

sg <- raw$social_state_printed == "SG"
final.dataframe <- data.frame(
  Species               = printed_species,
  population_id         = paste0("Qiu2022_", raw$source_sheet, "_row", raw$source_row),
  population            = "Not provided in S5 analysis workbook; recover from full Dryad table",
  social_state          = unname(codes[raw$social_state_printed]),
  supporting_references = raw$supporting_references,
  source_sheet          = raw$source_sheet,
  role                  = "secondary",
  primary_paper_verified = FALSE,
  age_scope             = "adults only; juveniles excluded",
  merge_eligible        = !sg,
  quality_flag          = paste0("Incomplete archive: 141 records versus 149 reported; preserve ",
                                 "excluded-from-model rows; not all unique populations reverified",
                                 ifelse(sg, "; SG contradicts published statement that SG did not occur: held from merge", "")),
  stringsAsFactors = FALSE)

## ---- write the analysis CSV ----
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- public TSV: Item encoded from the live __ReadMe.xlsx, by Item name ----
## Unregistered items are built anyway: the CSV is written and the TSV waits for a registry row
## (an "NA.tsv" would be worse than none).
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  message("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- CSV written, public TSV skipped.")
} else {
  tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message(item_name, " -> ", tsv_path)
}
message(item_name, ": ", nrow(final.dataframe), " rows written to ", basename(csv_path))
