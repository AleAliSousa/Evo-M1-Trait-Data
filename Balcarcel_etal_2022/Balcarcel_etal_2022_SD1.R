## ============================================================================
## Balcarcel_etal_2022_SD1.R
##
## Balcarcel AM, Geiger M, Clauss M, Sanchez-Villagra MR (2022). The
## mammalian brain under domestication: Discovering patterns after a
## century of old and new analyses. Journal of Experimental Zoology
## Part B 338: 460-483. doi:10.1002/jez.b.23105
##
## Item: Supplementary Data 1 (SD1, "Main data") -- the authors' own
## cranial measurements of 253 museum specimens of South American
## camelids, pigs and goats (wild and domestic forms): braincase
## length / width / height, foramen magnum breadth and full skull
## length (all mm), with the endocranial volume of each specimen
## estimated from the braincase dimensions.
##
## Frozen source (digital-native, no snapshot): the untouched
## publisher download, jezb23105-sup-0001-sd1_data_for_cams_pigs_
## goats.xlsx, kept verbatim in this folder under its original name.
## A digital-native file needs no snapshot when the registry lists it
## and the build script reads it directly: __ReadMe.xlsx records this
## filename in the item's "Snapshot filename" field. Nothing was
## re-saved or converted. This script reads ONLY that file.
## (SD2 and SD3, also in this folder, are the paper's methods and
## calculations documents; SD3 states the endocranial-volume model
## checked below.)
##
## Data role: PRIMARY -- the linear measurements are the authors' own
## measurements of the specimens (measurement landmarks as defined in
## Balcarcel et al. 2021, per SD2). The log10(EV) column is the
## authors' estimate from those measurements (Finarelli 2011
## all-artiodactyl model, per SD3); it is an estimate, not a measured
## volume.
##
## Cleaning done here (and nowhere else): skip the sheet's title and
## blank rows; name the unheaded museum-name column; species_sci is
## the printed Genus + species combined (printed names kept verbatim,
## including "Sus domesticus" and "Capra aegagrus hircus" as printed);
## "log10(EV)" is renamed log10_EV. Values are not rounded or
## otherwise changed.
##
## Outputs:
##   Balcarcel_etal_2022_SD1.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Balcarcel_etal_2022_SD1.R"   # this file's own name
  argv <- commandArgs(trailingOnly = FALSE)
  f    <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f) && basename(f) == me) return(normalizePath(f))
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == me &&
        file.exists(of)) return(normalizePath(of))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me) return(normalizePath(p))
  }
  ## last resort: sys.source() (build_dataset_item) sets no ofile frame --
  ## find this file by name under the working directory (the repo root)
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) == 1L) return(normalizePath(hits))
  stop("Cannot locate this script; run it with Rscript or from RStudio.")
})
folder    <- dirname(script_path)
base      <- sub("\\.R$", "", basename(script_path))
item_name <- base

## ---- repo root (walk up to __ReadMe.xlsx) ----------------------------------
repo_root <- folder
while (!file.exists(file.path(repo_root, "__ReadMe.xlsx")) &&
       dirname(repo_root) != repo_root)
  repo_root <- dirname(repo_root)
if (!file.exists(file.path(repo_root, "__ReadMe.xlsx")))
  stop("__ReadMe.xlsx not found walking up from ", folder)

## ---- Item encoded, looked up by Item name (never by row number) ------------
registry     <- readxl::read_excel(file.path(repo_root, "__ReadMe.xlsx"),
                                   sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name,
                                                 registry[["Item name"]])]
if (is.na(item_encoded)) stop("Item not found in registry: ", item_name)

## ---- read the frozen source file (publisher workbook, sheet "Sheet 1") -----
## skip = 2 drops the title row and the blank row; the third row of the
## sheet is the header. Its museum-name column is unheaded in the file.
snap <- readxl::read_excel(
  file.path(folder, "jezb23105-sup-0001-sd1_data_for_cams_pigs_goats.xlsx"),
  sheet = "Sheet 1", skip = 2)
stopifnot(nrow(snap) == 253L, ncol(snap) == 12L)
## the publisher file stores the measurements as text; type them here
for (v in c("BCL", "BCW", "BCH", "FM", "FL", "log10(EV)"))
  snap[[v]] <- as.numeric(snap[[v]])
stopifnot(!anyNA(snap[["BCL"]]), !anyNA(snap[["log10(EV)"]]))

## ---- clean: analysis column names; printed names and values kept -----------
final.dataframe <- data.frame(
  ID              = snap[["ID"]],
  Museum          = snap[["Museum"]],
  Museum_full_name = snap[[3]],
  Genus           = snap[["Genus"]],
  species         = snap[["species"]],
  species_sci     = paste(snap[["Genus"]], snap[["species"]]),
  W_D             = snap[["W_D"]],
  BCL             = snap[["BCL"]],
  BCW             = snap[["BCW"]],
  BCH             = snap[["BCH"]],
  FM              = snap[["FM"]],
  FL              = snap[["FL"]],
  log10_EV        = snap[["log10(EV)"]],
  stringsAsFactors = FALSE
)

## ---- table check (build HOWTO SS7a): the printed log10(EV) is the ---------
## Finarelli (2011) all-artiodactyl model of SD3, applied to the printed
## braincase dimensions: ln(EV) = -6.1834 - 0.384 ln(BCH) + 1.3182 ln(BCL)
## + 1.4892 ln(BCW), reported as log10. The printed dimensions are rounded,
## so the recomputation is allowed 5e-4 in log10 (the largest difference
## on the frozen file is 2.3e-4). A mismatch is reported, never fixed.
ev_ln <- -6.1834 - 0.384 * log(final.dataframe[["BCH"]]) +
  1.3182 * log(final.dataframe[["BCL"]]) +
  1.4892 * log(final.dataframe[["BCW"]])
table_checks <- data.frame(
  check_id = "log10_EV_finarelli2011_model",
  basis    = "SD3: ln(EV) = -6.1834 - 0.384 ln(BCH) + 1.3182 ln(BCL) + 1.4892 ln(BCW), converted to log10",
  observed = ev_ln / log(10),
  printed  = final.dataframe[["log10_EV"]],
  stringsAsFactors = FALSE
)
table_checks$difference <- abs(table_checks$observed - table_checks$printed)
table_checks$tolerance  <- 5e-4
table_checks$status     <- ifelse(table_checks$difference <=
                                  table_checks$tolerance,
                                  "pass", "mismatch")
table_checks$note       <- ""
if (any(table_checks$status != "pass"))
  warning("log10(EV) check mismatch on ",
          sum(table_checks$status != "pass"),
          " specimen(s) -- values kept as published; see the item ReadMe.")
message("Table checks: ", sum(table_checks$status == "pass"), " of ",
        nrow(table_checks), " pass (max difference ",
        format(max(table_checks$difference), digits = 2), " in log10).")

## ---- write the analysis CSV and the public TSV ------------------------------
## House file format: CRLF line endings, minimal quoting -- the format
## of the committed Evo-M1 CSV/TSV files.
write_house <- function(df, path, sep) {
  ## minimal quoting, decided per field (a field is quoted only when it
  ## contains the separator, a double quote or a newline; embedded
  ## quotes are doubled) -- the format of the committed Evo-M1 files
  fmt <- function(v) {
    v <- as.character(v)
    v[is.na(v)] <- ""
    needs <- grepl(sep, v, fixed = TRUE) | grepl('"', v, fixed = TRUE) |
             grepl("[\r\n]", v)
    v[needs] <- paste0('"', gsub('"', '""', v[needs], fixed = TRUE), '"')
    v
  }
  lines <- do.call(paste, c(lapply(df, fmt), sep = sep))
  con <- file(path, open = "wb")
  writeLines(c(paste(names(df), collapse = sep), lines), con, sep = "\r\n")
  close(con)
}
write_house(final.dataframe, file.path(folder, paste0(item_name, ".csv")), ",")
tsv_dir <- file.path(repo_root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write_house(final.dataframe,
              file.path(tsv_dir, paste0(item_encoded, ".tsv")), "\t")
} else {
  warning("__Public/comparative-data not found under the repo root; ",
          "public TSV not written.")
}
