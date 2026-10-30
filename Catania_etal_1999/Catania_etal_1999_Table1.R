## Catania et al. (1999), Journal of Comparative Neurology 410:55-72 — Table 1.
## Printed area values are frozen verbatim in the snapshot; all reshaping occurs here.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript or open and Source in RStudio.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({ d <- folder; while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d); if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })

raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), check.names = FALSE,
                stringsAsFactors = FALSE, na.strings = c("", "—"))
case_cols <- names(raw)[-1]
case_info <- data.frame(
  source_column = case_cols,
  Species = c(rep("Sorex cinereus", 3), rep("Blarina brevicauda", 3), "Cryptotis parva"),
  species_as_published = c(rep("Sorex cinereus", 3), rep("Blarina brevicauda", 3), "Cryptopus parva"),
  common_name = c(rep("masked shrew", 3), rep("northern short-tailed shrew", 3), "least shrew"),
  case_id = c("1", "2A", "2B", "97-81", "97-82", "97-43", "97-44"),
  stringsAsFactors = FALSE
)
structure_map <- c(
  "Total neocortex" = "total neocortex",
  "Total sensory cortex (S1+S2+A1+V1)" = "total sensory cortex (S1+S2+A1+V1)",
  "A1" = "A1", "V1" = "V1",
  "Total somatosensory cortex (S1+S2)" = "total somatosensory cortex (S1+S2)",
  "Vibrissae and rhinarium (S1+S2)" = "vibrissae and rhinarium representation (S1+S2)",
  "Trunk and limbs (S1+S2)" = "trunk and limbs representation (S1+S2)",
  "Mouth" = "mouth representation"
)
parse_area <- function(x) suppressWarnings(as.numeric(sub("^\\s*([0-9.]+).*$", "\\1", x)))
parse_pct <- function(x) suppressWarnings(as.numeric(sub("^.*\\(([0-9.]+)\\).*$", "\\1", x)))

rows <- list(); k <- 0L
for (j in seq_along(case_cols)) for (i in seq_len(nrow(raw))) {
  x <- raw[[case_cols[j]]][i]
  if (is.na(x) || !nzchar(x)) next
  k <- k + 1L
  rows[[k]] <- data.frame(
    Species = case_info$Species[j], species_as_published = case_info$species_as_published[j],
    common_name = case_info$common_name[j],
    case_id = case_info$case_id[j], structure = unname(structure_map[raw[[1]][i]]),
    area_mm2 = parse_area(x), pct_neocortex = parse_pct(x),
    unit = "mm2", where_in_paper = "Table 1",
    measurement_basis = "flattened cortex; fixed in 2% paraformaldehyde; borders from chemoarchitecture with electrophysiology where available",
    source = item_name, stringsAsFactors = FALSE
  )
}
clean <- do.call(rbind, rows)
stopifnot(nrow(clean) == 47L, !anyNA(clean[c("Species", "structure", "area_mm2", "pct_neocortex")]))
append_flag <- function(x, flag) ifelse(!nzchar(x), flag, paste(x, flag, sep = "|"))
append_note <- function(x, note) ifelse(!nzchar(x), note, paste(x, note, sep = " "))
clean$source_flags <- "fixed_tissue_no_shrinkage_correction_stated|single_hemisphere_case"
clean$source_issue_note <- "Measurements were made after fixation in 2% paraformaldehyde; no shrinkage correction is stated. Each case is one hemisphere."

bad_sum <- clean$case_id == "2A"
clean$source_flags[bad_sum] <- append_flag(clean$source_flags[bad_sum], "sensory_total_component_mismatch")
clean$source_issue_note[bad_sum] <- append_note(
  clean$source_issue_note[bad_sum],
  "The printed total sensory cortex is 5.0 mm2, but A1 + V1 + S1/S2 is 0.44 + 0.76 + 3.5 = 4.70 mm2."
)
taxon_typo <- clean$case_id == "97-44"
clean$source_flags[taxon_typo] <- append_flag(clean$source_flags[taxon_typo], "source_taxon_typo")
clean$source_issue_note[taxon_typo] <- append_note(
  clean$source_issue_note[taxon_typo],
  "Table 1 prints Cryptopus parva; Species is normalized to Cryptotis parva while species_as_published preserves the typo."
)

wide <- split(clean, clean$case_id)
table_checks <- do.call(rbind, lapply(names(wide), function(id) {
  z <- wide[[id]]
  val <- function(s) z$area_mm2[z$structure == s]
  observed <- val("total sensory cortex (S1+S2+A1+V1)")
  expected <- val("A1") + val("V1") + val("total somatosensory cortex (S1+S2)")
  data.frame(check_id = paste0("sensory_sum_", id), observed = observed, expected = expected,
             tolerance = 0.2, pass = abs(observed - expected) <= 0.2,
             note = "Printed components agree within source rounding", stringsAsFactors = FALSE)
}))
stopifnot(identical(table_checks$check_id[!table_checks$pass], "sensory_sum_2A"))

write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
if (!is.na(base)) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  if (!is.na(enc) && nzchar(enc)) write.table(clean, file.path(base, "__Public", "comparative-data", paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Registry row pending for ", item_name, "; public TSV skipped.")
}
message(item_name, ": ", nrow(clean), " rows written; case 2A arithmetic mismatch and source taxon typo flagged")
