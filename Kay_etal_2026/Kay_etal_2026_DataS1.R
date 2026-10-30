## Kay_etal_2026_DataS1.R -- born-digital snapshot -> analysis CSV + public TSV
##
## Kay, R. F., Organ, C. L., Morse, P. E., Allen, K. L., & Kirk, E. C. (2026).
## Fossil evidence favors a role for vision in the modular evolution of the
## primate neocortex. Science, 393(6811), 622-627. doi:10.1126/science.aee3541
##
## Frozen source: Kay_etal_2026_DataS1_snapshot.xlsx = the journal download
## science.aee3541_data-s1.xlsx (from science.aee3541_data_s1_to_s5.zip),
## copy-renamed with bytes untouched (sha256 4710f811...c783b).
## 104 genera (84 living, 20 fossil) x 13 measures, all natural logs.
## Data S1 notes row: "All measurements are in natural logs. Brain and
## neocortex volume data from ref. 8; Orbital data updated and supplemented
## from refs 24, 25, Volume of frontal and non-frontal gray matter from Bush
## and Allman (18)". Ref numbers resolve in the main-text bibliography
## (reference_tables/Kay_etal_2026_DataS1_references.csv).

## 0. PATHS --------------------------------------------------------
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kay_etal_2026_DataS1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
tsv_dir <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(readxl)

## 2. LOAD (positional; row 1 = printed headers) ----------------------
snap <- read_excel(paste0(item_name, "_snapshot.xlsx"), sheet = "Sheet1",
                   col_names = FALSE, col_types = "text", .name_repair = "minimal")
hdr   <- trimws(unname(unlist(snap[1, ])))
notes <- snap[[1]][grepl("^Notes:", snap[[1]])]
dat   <- snap[-1, ]
dat   <- dat[!is.na(dat[[2]]) & !grepl("^Notes:", dat[[1]]), ]   # drops blank + notes rows
stopifnot(nrow(dat) == 104, ncol(dat) == 16, length(notes) == 1,
          grepl("natural logs", notes, fixed = TRUE))

## 3. SPECIES (General key, scoped to this paper folder) --------------
publication <- basename(folder)                       # "Kay_etal_2026"
key   <- readr::read_csv(file.path(base, "_keys", "General", "species_key.csv"), show_col_types = FALSE,
                         col_types = readr::cols(.default = "c"))
key_p <- key[key$source_publication == publication, ]
if (nrow(key_p) == 0L)
  stop("No species_key.csv rows for source_publication == \"", publication, "\"", call. = FALSE)
Species <- key_p$accepted_name[match(tolower(dat[[1]]), tolower(key_p$variant_name))]
if (anyNA(Species)) stop("No species_key row for: ", paste(dat[[1]][is.na(Species)], collapse = "; "), call. = FALSE)

## 4. VARIABLE MAP -------------------------------------------------------
## Units are NOT printed in Data S1; inferred (see README / definitions):
## volumes mm3 (Stephan 1981 convention; Alouatta exp(Ln BrainVol) = 49 cm3),
## areas mm2 (main text gives optic-foramen area in mm2), lengths mm, and the
## two Bush & Allman gray-matter volumes cm3 (exp of 1.7-2.5 is only possible
## in cm3) -> x 1000 to the project unit mm3.
vmap <- data.frame(
  header   = hdr[4:16],
  variable = c("BrainVol", "EndocastVol", "NeocortexVol", "NeocortexSurfaceArea",
               "FrontalLobeSurfaceArea", "OPTSurfaceArea", "OlfactoryBulbVol",
               "OrbitDiameter", "OrbitArea", "OpticForamenArea", "ProsthionInionLength",
               "FrontalGrayMatterVol", "NonFrontalGrayMatterVol"),
  unit     = c("mm3", "mm3", "mm3", "mm2", "mm2", "mm2", "mm3", "mm", "mm2", "mm2", "mm", "mm3", "mm3"),
  to_project = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1000, 1000),
  source_keys = c("8", "", "8", "", "", "", "", "24; 25", "24; 25", "", "", "18", "18"),
  measure_role = c("secondary", "primary", "secondary", "primary", "primary", "primary",
                   "unattributed", "both", "both", "unattributed", "unattributed",
                   "secondary", "secondary"),
  stringsAsFactors = FALSE)
stopifnot(identical(vmap$header[1], "Ln BrainVol"), identical(vmap$header[13], "Ln Non-frontal gray matter"))

## 5. CLEAN: long format, "-" and blank cells omitted --------------------
final.dataframe <- do.call(rbind, lapply(seq_len(nrow(vmap)), function(i) {
  v    <- dat[[i + 3]]
  keep <- !is.na(v) & !(trimws(v) %in% c("-", "", "NA"))
  lnv  <- as.numeric(v[keep])
  data.frame(
    Species = Species[keep], genus_as_published = dat[[1]][keep],
    group_as_published = dat[[2]][keep], fossil_living = dat[[3]][keep],
    variable = vmap$variable[i], header_as_printed = vmap$header[i],
    ln_value_as_published = v[keep],
    ln_value = lnv,
    value_project_unit = signif(exp(lnv) * vmap$to_project[i], 6),
    project_unit = vmap$unit[i],
    unit_basis = ifelse(vmap$to_project[i] == 1, "inferred (not printed in Data S1)",
                        "inferred cm3 (not printed in Data S1); x1000 to mm3"),
    source_keys = vmap$source_keys[i],
    measure_role = vmap$measure_role[i],
    observation_level = "genus-level value as published (specimen/species composition in SM table S1, not in folder)",
    source_location = "Data S1 (science.aee3541_data-s1.xlsx), Sheet1",
    stringsAsFactors = FALSE, check.names = FALSE)
}))
if (anyNA(final.dataframe$ln_value)) stop("Unparsed numeric cell in Data S1", call. = FALSE)

## 6. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows written (", length(unique(final.dataframe$Species)), " genera)")
