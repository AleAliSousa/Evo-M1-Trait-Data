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

## ---- frozen source: digital-native PLOS supporting file, untouched ----
## Wagstyl_etal_2020_S2Data_snapshot.csv is a byte-identical copy-rename (md5 7af3d5dc6ec54bdbd88ad6e7f9cf44b3)
## of 12080526/pbio.3000678.s007.csv = the file PLOS serves as "S2 Data" (https://doi.org/10.1371/journal.pbio.3000678.s007).
## Content: 38 von Economo & Koskinas areas x {crown_min, ve_1..ve_6, ve_sum, bigbrain, area, bigbrain_layer_1..6}:
## von Economo & Koskinas laminar/total thicknesses beside the BigBrain laminar/total thicknesses of the
## coregistered area. NB the paper's Supporting-information caption for "S2 Data" describes the HCP MRI table
## instead (see README, Discrepancies). Read as character first so the published numerals survive verbatim.
raw <- readr::read_csv(paste0(item_name, "_snapshot.csv"), col_types = readr::cols(.default = readr::col_character()),
                       na = character(), show_col_types = FALSE)
names(raw)[1] <- "source_row_index"           ## unnamed pandas index column in the source (2..44 with gaps)
stopifnot(identical(names(raw), c("source_row_index", "area_name", "crown_min", paste0("ve_", 1:6), "ve_sum",
                                  "bigbrain", "area", paste0("bigbrain_layer_", 1:6))))
stopifnot(nrow(raw) == 38L, !anyDuplicated(raw$area_name))

## ---- species: the table never prints a species; the paper's text says "human" (Materials and methods) ----
raw$species_as_published <- "human"
key <- readr::read_csv(file.path(base, "_keys", "Stephan", "species_key.csv"), show_col_types = FALSE)
key_wg <- key[key$source_publication == "Wagstyl_etal_2020", ]
if (nrow(key_wg) == 0L)
  stop("No species_key.csv rows for source_publication == \"Wagstyl_etal_2020\" -- key rows are scoped to the paper folder name (_keys/SPECIES_NAMING.md sec 3b)", call. = FALSE)
lk <- setNames(key_wg$accepted_name, tolower(key_wg$variant_name))
raw$Species <- unname(lk[tolower(raw$species_as_published)])
stopifnot(!any(is.na(raw$Species)))

## ---- column dictionary for the long reshape (what each source column is; see README for the paper statements) ----
roman <- c("I", "II", "III", "IV", "V", "VI")
dict <- rbind(
  data.frame(source_column = "crown_min", dataset = "vonEconomo_Koskinas", layer = "total",
             measure = "cortical_thickness_crown_min", unit = "mm", stringsAsFactors = FALSE),
  data.frame(source_column = paste0("ve_", 1:6), dataset = "vonEconomo_Koskinas", layer = roman,
             measure = "layer_thickness", unit = "mm", stringsAsFactors = FALSE),
  data.frame(source_column = "ve_sum", dataset = "vonEconomo_Koskinas", layer = "I-VI",
             measure = "cortical_thickness_sum_of_layers", unit = "mm", stringsAsFactors = FALSE),
  data.frame(source_column = "bigbrain", dataset = "BigBrain", layer = "total",
             measure = "cortical_thickness", unit = "mm", stringsAsFactors = FALSE),
  data.frame(source_column = "area", dataset = "not stated", layer = NA_character_,
             measure = "region_area", unit = "not stated", stringsAsFactors = FALSE),
  data.frame(source_column = paste0("bigbrain_layer_", 1:6), dataset = "BigBrain", layer = roman,
             measure = "layer_thickness", unit = "mm", stringsAsFactors = FALSE)
)
stopifnot(all(dict$source_column %in% names(raw)))
specimen <- c(
  vonEconomo_Koskinas = "von Economo & Koskinas (1925) histological atlas (refs 8, 64), areas coregistered to the BigBrain surfaces; hemisphere not stated",
  BigBrain            = "BigBrain: one post-mortem human brain, male, aged 65 (Amunts et al. 2013); hemisphere not stated in the file (paper reports left and right separately)",
  `not stated`        = "not stated (Fig 3B legend: point size proportional to the area of the cortical region; correlations area-weighted)"
)

long <- do.call(rbind, lapply(seq_len(nrow(dict)), function(i) {
  cn <- dict$source_column[i]
  data.frame(
    Species               = raw$Species,
    species_as_published  = raw$species_as_published,
    source_row_index      = as.integer(raw$source_row_index),
    area_as_published     = raw$area_name,
    parcellation          = "von Economo & Koskinas (1925) cortical areas (surface-based parcellation, refs 8 and 64; allocortex excluded)",
    dataset               = dict$dataset[i],
    specimen_or_cohort    = unname(specimen[dict$dataset[i]]),
    layer                 = dict$layer[i],
    measure               = dict$measure[i],
    value                 = as.numeric(raw[[cn]]),
    unit                  = dict$unit[i],
    value_as_published    = raw[[cn]],
    source_column         = cn,
    stringsAsFactors = FALSE)
}))
long$source_file     <- "pbio.3000678.s007.csv (PLOS 'S2 Data'; frozen copy Wagstyl_etal_2020_S2Data_snapshot.csv)"
long$source_location <- "Supporting information S2 Data (https://doi.org/10.1371/journal.pbio.3000678.s007); underlying data of Fig 3B and Fig 4"
long$data_role       <- ifelse(long$dataset == "vonEconomo_Koskinas", "secondary", "primary")
stopifnot(nrow(long) == 38L * 16L, !any(is.na(long$value)))

final.dataframe <- long[, c("Species", "species_as_published", "specimen_or_cohort", "source_row_index",
                            "area_as_published", "parcellation", "dataset", "layer", "measure", "value", "unit",
                            "value_as_published", "source_column", "source_file", "source_location", "data_role")]

## ---- table checks (HOWTO sec 7a): the file prints a laminar sum column, ve_sum = ve_1 + ... + ve_6 ----
## Compared in whole units of the last printed decimal (hundredths); tolerance = half a unit per summed cell (6 x 0.005 = 0.03).
ve_layers <- sapply(paste0("ve_", 1:6), function(cn) as.numeric(raw[[cn]]))
obs_sum   <- rowSums(ve_layers)
prt_sum   <- as.numeric(raw$ve_sum)
diff_sum  <- round(obs_sum - prt_sum, 2)
table_checks <- data.frame(
  check_id   = paste0("ve_sum_", raw$area_name),
  basis      = "ve_sum compared with ve_1 + ve_2 + ve_3 + ve_4 + ve_5 + ve_6 (von Economo & Koskinas layer thicknesses, mm)",
  observed   = round(obs_sum, 2),
  printed    = prt_sum,
  difference = diff_sum,
  tolerance  = 0.03,
  status     = ifelse(abs(diff_sum) <= 0.03, "pass", "mismatch"),
  note       = "all six layer cells printed for every area; no blanks left out",
  stringsAsFactors = FALSE)
if (any(table_checks$status != "pass"))
  warning("ve_sum check: ", sum(table_checks$status != "pass"), " mismatch(es): ",
          paste(table_checks$check_id[table_checks$status != "pass"], collapse = ", "))
message("table_checks: ", sum(table_checks$status == "pass"), " pass, ", sum(table_checks$status != "pass"), " mismatch")

## Write the numeric column as the published numeral: readr/write.table shorten the 17-significant-digit
## numerals of this file (e.g. 2.4654903411865234 -> 2.465490341186523, a different double), whereas the
## published text is the exact decimal of the stored value. final.dataframe (in memory) keeps the numeric type.
out_write <- final.dataframe
out_write$value <- final.dataframe$value_as_published
stopifnot(identical(as.numeric(out_write$value), final.dataframe$value))
readr::write_csv(out_write, paste0(item_name, ".csv"), na = "")
message(item_name, ": ", nrow(final.dataframe), " rows written (", length(unique(final.dataframe$area_as_published)), " areas x 16 source columns)")

## ---- public TSV: look up Item encoded from __ReadMe.xlsx ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)]
} else NA_character_

if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  ## Registry row not pasted yet: derive the expected stem (paper DOI, URL-encoded, + Item number without
  ## spaces, = the formula __ReadMe.xlsx uses) so the public TSV exists; the registry remains the authority --
  ## after pasting the row and running _tools/file_list.R, confirm col K equals this stem or rename the TSV.
  doi_encoded  <- "10.1371%2Fjournal.pbio.3000678"
  item_encoded <- paste0(doi_encoded, "_", sub(paste0("^", basename(folder), "_"), "", item_name))
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx yet; using the expected stem '",
          item_encoded, "'. Paste ", item_name, "_registry_row.xlsx, run _tools/file_list.R and verify col K.")
}
if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  readr::write_tsv(out_write, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), na = "")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
