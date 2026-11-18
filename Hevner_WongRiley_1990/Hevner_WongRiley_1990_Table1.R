# Hevner_WongRiley_1990_Table1.R ---------------------------------------------------------
#
# Hevner & Wong-Riley (1990), Journal of Neuroscience 10(4): 1331-1340. Table 1
# "Optical densitometry of CO histochemical and immunohistochemical staining in
# normal and experimental striate cortex", p. 1337.
#
# Reads the frozen snapshot (Hevner_WongRiley_1990_Table1_snapshot.csv, written by
# Hevner_WongRiley_1990_Table1_snapshot.R) and does all the cleaning:
#   - one analysis row per printed cell (4 regions x 2 stain methods = 8), in
#     printed order; the printed section heading carried down and split into the
#     condition (control / TTX) and the cortical layer it names;
#   - stain methods: CO histochemistry (reads CO enzymatic activity) and CO
#     immunohistochemistry (reads CO protein amount) from the two printed columns;
#   - values are RELATIVE optical densities (mean ± SD, from the spanning header),
#     normalised within each section to the interpuff (normal) or dark-column (TTX)
#     reading = 1.00 (footnote); the reference cells are flagged;
#   - n_readings = 25 per region (footnote); n_animals per group and the species
#     come from METHODS p. 1331 (7 normal Macaca fascicularis; 3 TTX-treated:
#     2 M. radiata, 1 M. fascicularis) and are typed here as metadata, not values;
#   - species_as_published keeps the paper's wording; Species is the accepted
#     binomial (or the genus-level anchor for the pooled TTX group) from
#     _keys/General/species_key.csv (rows for this folder).
#   No units to convert: relative optical density is dimensionless.
# No table value is typed in this script.
#
# NOTE for laminar use: Table 1 does NOT give a between-layer CO profile. Each
# section is normalised to its own reference compartment (interpuff = 1.00 within
# layers 2-3; dark column = 1.00 within layer 4C), so values are comparable only
# WITHIN a section row-pair, never across the two layer blocks.

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
base  <- item_name

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## ---- cell helpers: a printed cell "1.32 ± 0.04" is split into its printed mean lexeme ----
## and printed dispersion lexeme; the numbers are parsed from those lexemes. Nothing is
## repaired. Table 1 prints no footnote glyphs on cells.
mean_lexeme <- function(x) trimws(sub("\\s*±.*$", "", x))
disp_lexeme <- function(x) ifelse(grepl("±", x), trimws(sub("^.*±\\s*", "", x)), NA_character_)
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))

## ---- species: printed name kept, accepted name from the collection key --------------
## (HOWTO section 5; the key is the single source of truth).
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[species_key$source_publication == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk <- setNames(species_key$accepted_name, tolower(species_key$variant_name))

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
  tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
  message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
          "  not_evaluable=", tally[["not_evaluable"]])
  if (tally[["mismatch"]] > 0L) {
    bad <- table_checks[table_checks$status == "mismatch", ]
    for (i in seq_len(nrow(bad)))
      warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                      bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                      bad$difference[i], bad$tolerance[i]), call. = FALSE)
  }
  invisible(tally)
}

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(10L, 3L)),
          grepl("^Table 1\\. Optical densitometry", snap[1, 1]),
          grepl("^Relative optical density \\(mean ± SD\\)$", snap[2, 2]),
          snap[3, 2] == "Histochemistry", gsub("\n", "", snap[3, 3], fixed = TRUE) == "Immunohisto-chemistry",
          grepl("^All sections were cut tangential", snap[10, 1]))

## section headings (printed) and the rows under them
section_rows <- which(snap[, 2] == "" & snap[, 3] == "" & seq_len(nrow(snap)) %in% 4:9)
stopifnot(identical(section_rows, c(4L, 7L)))
section <- rep(NA_character_, nrow(snap))
for (i in 4:9) section[i] <- if (i %in% section_rows) snap[i, 1] else section[i - 1]
rows <- which(grepl("^[0-9.]+ ± [0-9.]+$", snap[, 2]))
stopifnot(identical(rows, c(5L, 6L, 8L, 9L)))

## the two printed value columns = the two stain methods
hdr <- gsub("-\n", "", snap[3, 2:3], fixed = TRUE)          # join the printed line-break hyphen
arms <- data.frame(col = 2:3, column = snap[3, 2:3], stain_method = paste("CO", tolower(hdr)),
                   stain_target = c("CO enzymatic activity", "CO protein (anti-CO IgG, mainly subunit IV)"),
                   stringsAsFactors = FALSE)
stopifnot(identical(arms$stain_method, c("CO histochemistry", "CO immunohistochemistry")))

## section heading -> condition, layer, species wording (METHODS p. 1331)
sect_info <- data.frame(
  section = snap[section_rows, 1],
  condition = c("control", "TTX"),
  stringsAsFactors = FALSE)
sect_info$cortical_layer_as_published <- sub("^.*\\b(layer .*)$", "\\1", sect_info$section)
sect_info$treatment_as_published <- trimws(sub("\\blayer .*$", "", sect_info$section))
sect_info$n_animals <- c(7L, 3L)       # METHODS p. 1331: "Seven normal ... and 3 TTX-treated"
sect_info$species_as_published <- c("Macaca fascicularis",
                                    "TTX-treated macaques (2 M. radiata, 1 M. fascicularis)")
stopifnot(identical(sect_info$cortical_layer_as_published, c("layer 2 and 3", "layer 4C")))

final.dataframe <- do.call(rbind, lapply(seq_len(nrow(arms)), function(k) {
  cell <- snap[rows, arms$col[k]]
  si <- sect_info[match(section[rows], sect_info$section), ]
  data.frame(printed_row = rows, region_order = seq_along(rows),
             section_as_published = section[rows],
             region_as_published = snap[rows, 1],
             condition = si$condition,
             treatment_as_published = si$treatment_as_published,
             cortical_layer_as_published = si$cortical_layer_as_published,
             compartment = tolower(snap[rows, 1]),
             group_as_published = snap[2, 2],
             column_as_published = gsub("\n", "", arms$column[k], fixed = TRUE),
             stain_method = arms$stain_method[k], stain_target = arms$stain_target[k],
             cell_as_printed = cell, mean_printed = mean_lexeme(cell),
             dispersion_printed = disp_lexeme(cell), dispersion_type = "SD",
             n_readings = 25L, n_animals = si$n_animals,
             species_as_published = si$species_as_published,
             stringsAsFactors = FALSE)
}))
final.dataframe$value_numeric      <- num_of(final.dataframe$mean_printed)
final.dataframe$dispersion_numeric <- num_of(final.dataframe$dispersion_printed)
final.dataframe$CO_relOD           <- final.dataframe$value_numeric
final.dataframe$normalisation_reference <- final.dataframe$compartment %in% c("interpuff", "dark column")
final.dataframe$Species <- unname(lk[tolower(final.dataframe$species_as_published)])
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$normalisation_reference] <-
  "Normalisation reference: readings in each section were normalised so this compartment = 1.00 (footnote); the printed SD is the spread of the normalised reference readings."
final.dataframe$note[final.dataframe$condition == "TTX"] <- ifelse(
  final.dataframe$normalisation_reference[final.dataframe$condition == "TTX"],
  "Dark column = ocular dominance column driven by the untreated eye (high CO). Pooled group of 3 TTX-treated animals of two species (METHODS p. 1331); monocular intravitreal TTX, left eye, twice a week for 3 or 4 weeks. Normalisation reference (= 1.00).",
  "Light column = ocular dominance column driven by the TTX-treated eye (low CO). Pooled group of 3 TTX-treated animals of two species (METHODS p. 1331); monocular intravitreal TTX, left eye, twice a week for 3 or 4 weeks.")
final.dataframe <- final.dataframe[order(final.dataframe$region_order, match(final.dataframe$stain_method, arms$stain_method)), ]
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 8L, !anyNA(final.dataframe$Species),
          !anyNA(final.dataframe$value_numeric), !anyNA(final.dataframe$dispersion_numeric))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## The footnote states the normalisation: interpuff (normal) and dark-column (TTX)
## densities = 1.00 in each stained section; the table must print 1.00 in those four cells.
## The percentage restatements in RESULTS (32%, 19%, 20%, 21%) need the sibling Text
## snapshot and live in internal_checks/Hevner_WongRiley_1990_Text_internal_check.R (7b).
ref <- final.dataframe[final.dataframe$normalisation_reference, ]
table_checks <- do.call(rbind, lapply(seq_len(nrow(ref)), function(i)
  chk(paste0("reference_", gsub(" ", "_", ref$compartment[i]), "_", sub("^CO ", "", ref$stain_method[i])),
      "footnote: readings normalised to yield interpuff / dark-column densities of 1.00",
      ref$value_numeric[i], 1.00, 0)))
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                               .name_repair = "minimal")
registry_row <- which(registry[["Item name"]] == item_name & !is.na(registry[["Item name"]]))
if (length(registry_row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][registry_row]
if (is.na(item_encoded) || !nzchar(item_encoded)) stop("Registered Item encoded is blank for ", item_name)
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV directory not found")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
message(item_name, ": public TSV ", item_encoded, ".tsv")
