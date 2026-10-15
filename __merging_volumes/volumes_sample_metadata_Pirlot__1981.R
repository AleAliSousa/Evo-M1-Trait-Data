# Metadata only: no traits, term maps, taxon keys, source admission or pooling.
# Source this file for the functions, or run:
# Rscript volumes_sample_metadata_Pirlot__1981.R /path/to/repo /new/path/check.csv

pirlot1981_sample_crosswalk <- function() {
  utils::read.table(text = "tableII_heading|tableI_label_expanded|tableI_specimen_number|collectionID|label_link_note
Marmosa murina|Marmosa (Marmosa) murina|9|J65067|Table II omits the printed subgenus; retain the full Table I label, not an epithet-only join.
Marmosa domina|Marmosa (m.) domina|10|P327|Table II omits the printed subgenus abbreviation (m.); no taxonomic expansion of that abbreviation is asserted.
Marmosa thylamys|Marmosa (Thylamys) sp.|11|J70092|Table II heading links to the Table I subgenus-qualified sp. label; this is not a newly asserted species binomial.
Metachirops|Metachirops (?) sp.|8|P326|Genus-only heading links to the explicitly uncertain Table I label; do not normalize it to Philander.
Philander|Philander opossum|6|J66076|Genus-only heading links to this exact Table I label and its unique S specimen, not to specimen 8.
Didelphis aurita|Didelphis m. aurita|2|P321|Table II shortens the printed subspecific label; the full Table I label remains unchanged.
Didelphis marsupialis|Didelphis m. marsupialis|1|P313|Table II shortens the printed subspecific label; the full Table I label remains unchanged.
Didelphis virginiana|Didelphis virginiana|5|J66075|Expand specimen 5's idem from the numbered Table I sequence; select S specimen 5, not W specimen 4.
Caluromys|Caluromys lanatus|14|J66070|Genus-only heading links to the exact Table I label; expand idem and select S specimen 14, not W specimens 12 or 13.
Perameles|Perameles nasuta|26|J65043|Genus-only heading links to this exact Table I label and its unique S specimen.
Isoodon|Isoodon obesulus|23|J64031|Genus-only heading links to this exact Table I label and its unique S specimen.
Antechinus|Antechinus flavipes (x)|15|J65047|Genus-only heading links to this exact Table I label; retain (x) and its unresolved adult-or-young qualifier.
Sminthopsis|Sminthopsis murina|17|J64017|Genus-only heading links to this exact Table I label; no murina epithet-only join with Marmosa.
Dasyurus|Dasyurus quoll|18|J65060|Genus-only heading links to this exact Table I label and its unique S specimen.
Sarcophilus|Sarcophilus harrisii|22|J65065|Genus-only heading links to the exact Table I label; expand idem and select S specimen 22, not W specimen 21.
Petaurus|Petaurus breviceps|30|J64020|Genus-only heading links to breviceps; Petaurus norfolcensis specimen 32 is W-only and is not pooled or relabelled.
Schoinobates|Schoinobates volans|33|J64037|Genus-only heading links to this exact Table I label and its unique S specimen.
Pseudocheirus|Pseudocheirus peregrinus|36|J64038|Genus-only heading links to the exact Table I label; expand idem and select S specimen 36, not W specimens 34 or 35.
Trichosurus|Trichosurus vulpecula|38|J64040|Genus-only heading links to the exact Table I label; expand idem and select S specimen 38, not W specimen 37.
Potorus|Potorous tridactylus|40|J65055|Retain the spelling distinction: Table II Potorus versus Table I Potorous tridactylus; this local link is not an accepted-name correction.
Macropus eugenii|Macropus eugenii|47|J64033|Exact Table II and expanded Table I label; select the unique S specimen, not W specimen 48.
Setonix|Setonix brachyurus|44|J67079|Genus-only heading links to the exact Table I label; expand idem and select S specimen 44, not W specimens 42, 43 or 45.
Thylogale|Thylogale billardieri|46|J65057|Genus-only heading links to this exact Table I label and its unique S specimen.
Macropus rufogriseus|Macropus rufogriseus|49|J65064|Exact Table II and expanded Table I label; the specimen is used once.
Macropus giganteus|Macropus giganteus|50|P309|Exact Table II and expanded Table I label; the specimen is used once.
Vombatus|Vombatus mitchelli (ursinus?)|39|J64011|Genus-only heading links to the printed uncertain Table I identification; no accepted species is assigned.
Lestoros|Lestoros inca|29|J70094|Genus-only heading links to this exact Table I label; the printed sex is unknown (?).
Caenolestes|Caenolestes obscurus|28|J69087|Genus-only heading links to this exact Table I label and its unique S specimen.",
    header = TRUE, sep = "|", quote = "", comment.char = "",
    stringsAsFactors = FALSE, check.names = FALSE)
}

pirlot1981_sample_metadata_from_cells <- function(tableI, tableII,
    tableI_snapshot_md5 = NA_character_, tableII_snapshot_md5 = NA_character_) {
  need <- function(ok, message) {
    if (!isTRUE(ok)) stop(paste0("Pirlot 1981 sampling metadata: ", message),
                          call. = FALSE)
  }
  exact <- function(x, y) identical(unname(as.character(x)), as.character(y))
  tableI <- as.matrix(tableI)
  tableII <- as.matrix(tableII)
  need(identical(dim(tableI), c(87L, 7L)) &&
         identical(dim(tableII), c(25L, 36L)),
       "unexpected snapshot ranges (require Sheet1 A1:G87 and A1:AJ25).")
  header <- c("Species", "Collection", "Sex", "Use", "Body-weight", "Brain-weight")
  need(exact(tableI[1L, 1L], "TABLE I") &&
         exact(tableI[56L, 1L], "TABLE I (suite)") &&
         exact(tableI[4L, 2:7], header) && exact(tableI[59L, 2:7], header) &&
         exact(tableI[5L, 6:7], c("gr", "mgr")) &&
         exact(tableI[60L, 6:7], c("gr", "mgr")),
       "Table I titles, headers or units changed.")
  need(exact(tableI[81L, 1L],
         "S = sectioned and used for component analysis as well as for encephalization estimate.") &&
         exact(tableI[82L, 1L],
         "W = weighed and used for encephalization estimate only. The Antechinus are marked with (x) :") &&
         grepl("cannot say whether they were adult or young", tableI[83L, 1L], fixed = TRUE) &&
         exact(tableI[87L, 1L],
         "My specimen was rather light but an adult female with 4 healthy young in the pouch."),
       "Table I sampling/age footnote evidence changed.")

  rows <- which(!is.na(tableI[, 1L]) & grepl("^\\([0-9]+\\)$", tableI[, 1L]))
  specimen_number <- as.integer(gsub("[()]", "", tableI[rows, 1L]))
  need(length(rows) == 50L && !anyDuplicated(specimen_number) &&
         setequal(specimen_number, seq_len(50L)),
       "Table I must contain each numbered specimen 1-50 exactly once.")
  specimens <- data.frame(
    number = specimen_number, snapshot_row = rows,
    label_as_printed = tableI[rows, 2L], collectionID = tableI[rows, 3L],
    sex = tableI[rows, 4L], use = tableI[rows, 5L],
    brain_weight_as_printed = tableI[rows, 7L], stringsAsFactors = FALSE)
  # idem follows the printed specimen sequence, never the incoming row order.
  specimens <- specimens[order(specimens$number), , drop = FALSE]
  rownames(specimens) <- NULL
  need(!anyNA(specimens) && all(nzchar(trimws(specimens$label_as_printed))) &&
         !anyDuplicated(specimens$collectionID) &&
         all(grepl("^[PJ][0-9]+$", specimens$collectionID)) &&
         sum(startsWith(specimens$collectionID, "P")) == 5L &&
         sum(startsWith(specimens$collectionID, "J")) == 45L &&
         all(specimens$sex %in% c("F", "M", "?")) &&
         all(specimens$use %in% c("S", "W")),
       "missing/invalid labels, unique collection IDs, collection counts, sex or S/W codes.")
  specimens$label_expanded <- specimens$label_as_printed
  idem <- grepl("^idem( ?\\(x\\))?$", specimens$label_as_printed)
  for (i in which(idem)) {
    need(i > 1L, "idem has no preceding numbered specimen.")
    specimens$label_expanded[i] <- specimens$label_expanded[i - 1L]
    if (grepl("\\(x\\)$", specimens$label_as_printed[i]) &&
        !grepl("\\(x\\)$", specimens$label_expanded[i]))
      specimens$label_expanded[i] <- paste(specimens$label_expanded[i], "(x)")
  }
  need(!any(grepl("^idem", specimens$label_expanded)) &&
         sum(specimens$use == "S") == 28L && sum(specimens$use == "W") == 22L,
       "idem expansion or the source's 28 S / 22 W specimen counts changed.")
  parenthetical <- grepl("^\\([0-9]+(\\.[0-9]+)?\\)$", specimens$brain_weight_as_printed)
  need(sum(parenthetical) == 1L && specimens$number[parenthetical] == 11L &&
         exact(specimens$brain_weight_as_printed[specimens$number == 11L], "(2200)"),
       "specimen 11's literal parenthetical brain-weight evidence changed.")

  crosswalk <- pirlot1981_sample_crosswalk()
  need(nrow(crosswalk) == 28L && !anyDuplicated(crosswalk$tableII_heading) &&
         !anyDuplicated(crosswalk$tableI_label_expanded) &&
         !anyDuplicated(crosswalk$tableI_specimen_number) &&
         !anyDuplicated(crosswalk$collectionID),
       "the literal item-local crosswalk is not one-to-one.")
  columns <- c(3:17, 21:31, 35:36)
  headings <- as.character(tableII[9L, columns])
  need(exact(tableII[1L, 1L], "TABLE II") &&
         exact(tableII[9L, c(1L, 19L, 33L)], rep("Volumes", 3L)) &&
         all(is.na(tableII[9L, c(2L, 18L, 20L, 32L, 34L)])) &&
         !anyNA(headings) && all(nzchar(headings)) &&
         !anyDuplicated(headings) && setequal(headings, crosswalk$tableII_heading),
       "Table II has duplicate, missing, unmatched or changed literal headings.")

  selected <- integer(nrow(crosswalk))
  S_N <- W_N <- integer(nrow(crosswalk))
  S_numbers <- W_numbers <- character(nrow(crosswalk))
  for (i in seq_len(nrow(crosswalk))) {
    same_label <- specimens$label_expanded == crosswalk$tableI_label_expanded[i]
    s <- which(same_label & specimens$use == "S")
    w <- which(same_label & specimens$use == "W")
    need(length(s) == 1L,
         paste0("heading '", crosswalk$tableII_heading[i],
                "' has zero or multiple S specimens for its exact Table I label."))
    need(specimens$number[s] == crosswalk$tableI_specimen_number[i] &&
           exact(specimens$collectionID[s], crosswalk$collectionID[i]),
         paste0("heading '", crosswalk$tableII_heading[i],
                "' does not match its explicit specimen number and collection ID."))
    selected[i] <- s
    S_N[i] <- length(s)
    W_N[i] <- length(w)
    S_numbers[i] <- paste(specimens$number[s], collapse = ";")
    W_numbers[i] <- paste(specimens$number[w], collapse = ";")
  }
  need(!anyDuplicated(selected) &&
         setequal(specimens$number[selected], specimens$number[specimens$use == "S"]),
       "the crosswalk reuses an S specimen or fails to cover all and only the 28 S specimens.")
  s <- specimens[selected, , drop = FALSE]
  II_columns <- columns[match(crosswalk$tableII_heading, headings)]
  excel_column <- function(j) {
    if (j <= 26L) LETTERS[j] else paste0(LETTERS[(j - 1L) %/% 26L], LETTERS[(j - 1L) %% 26L + 1L])
  }
  II_cell <- paste0("Sheet1!", vapply(II_columns, excel_column, character(1)), "9")
  I_cells <- paste0("Sheet1!A", s$snapshot_row, ":G", s$snapshot_row)
  I_page <- ifelse(s$number <= 36L, "230", "231")
  II_page <- ifelse(II_columns <= 17L, "234", ifelse(II_columns <= 31L, "235", "236"))
  P <- startsWith(s$collectionID, "P")
  taxon_note <- rep("No additional identity doubt flagged here; printed labels are not accepted-name keys.", nrow(s))
  taxon_note[s$number == 8L] <- "Table I p231 footnote disputes Metachirops/Philander identity; retain Metachirops (?) sp. without synonymization."
  taxon_note[s$number == 11L] <- "Table I identifies Marmosa (Thylamys) sp. only; Table II thylamys is not authority for a resolved species binomial."
  taxon_note[s$number == 39L] <- "Table I specimen 39 prints Vombatus mitchelli (ursinus?); accepted species remains unresolved."
  weight_note <- rep("Methods p232: weights supplied by collectors; no specimen-level direct-measurement verification is claimed here.", nrow(s))
  weight_note[s$number == 11L] <- "Table I retains (2200); Results p233 explicitly reports specimen 11 BrW as interpolated, not an unqualified measured weight."
  overlap_note <- rep("Cross-paper specimen independence has not been assessed by this sidecar.", nrow(s))
  overlap_note[s$number == 1L] <- "Existing Table I README reports P313 overlap with Pirlot_Nelson_1978_TABLE3; not independently source-confirmed here. Matching weights alone do not establish identity; review before cross-paper pooling."

  data.frame(
    Source = "Pirlot__1981_TABLEII", sample_source = "Pirlot__1981_TABLEI",
    tableII_heading = crosswalk$tableII_heading, tableII_heading_cell = II_cell,
    tableI_label_as_printed = s$label_as_printed,
    tableI_label_expanded = s$label_expanded,
    tableI_specimen_number = s$number, tableI_specimen_cell_range = I_cells,
    collectionID = s$collectionID,
    collection_origin = ifelse(P, "Pirlot; Universite de Montreal (Methods p232)",
                               "J. I. Johnson; Michigan State University (Methods p232)"),
    sex_as_printed = s$sex, use_as_printed = s$use,
    tableI_S_N = S_N, tableI_W_N = W_N,
    tableI_S_specimens = S_numbers, tableI_W_specimens = W_numbers,
    N_region = S_N, N_unit = "individual_brains",
    N_basis = "inferred_from_literal_TableII_to_TableI_crosswalk_and_unique_S_specimen",
    N_evidence = paste0("Table I p", I_page, " specimen (", s$number, "), ", I_cells,
      ", collection ", s$collectionID, " Use=S; exact expanded label has S=", S_N,
      " (", S_numbers, "), W=", W_N, " (", ifelse(nzchar(W_numbers), W_numbers, "none"),
      "); Table II p", II_page, " ", II_cell,
      "; S/W definition p231. N is inferred brain count, not a printed Table II n."),
    sample_id = paste0("Pirlot__1981::", s$collectionID),
    specimen_ids = paste0(ifelse(P, "Pirlot_Montreal::", "Johnson_MichiganState::"), s$collectionID),
    ids_complete = "yes", label_link_note = crosswalk$label_link_note,
    taxon_identity_uncertain = s$number %in% c(8L, 11L, 39L),
    taxon_identity_note = taxon_note,
    age_status = ifelse(s$number == 8L, "adult_source_footnote_p231",
      ifelse(s$number == 15L, "adult_or_young_unknown_source_footnote_p231",
             "not_reported_for_this_specimen")),
    brain_weight_parenthetical = parenthetical[selected],
    brain_weight_interpolation_reported = s$number == 11L,
    brain_weight_note = weight_note,
    cross_paper_overlap_status = ifelse(s$number == 1L,
      "reported_Pirlot_Nelson_1978_TABLE3_overlap_not_independently_verified", "not_assessed"),
    cross_paper_overlap_note = overlap_note,
    review_status = "AI_source_review_2026-10-14_pending_human_and_clean_R",
    data_role = "sampling_metadata_not_trait", merge_status = "metadata_only_not_admitted",
    tableI_snapshot_md5 = tableI_snapshot_md5,
    tableII_snapshot_md5 = tableII_snapshot_md5,
    stringsAsFactors = FALSE, check.names = FALSE)
}

pirlot1981_sample_metadata <- function(tableI_snapshot, tableII_snapshot) {
  if (!requireNamespace("readxl", quietly = TRUE))
    stop("Package 'readxl' is required; install it explicitly before running.", call. = FALSE)
  read_cells <- function(path, range) as.matrix(readxl::read_excel(
    path, sheet = "Sheet1", range = range, col_names = FALSE,
    col_types = "text", .name_repair = "minimal", trim_ws = FALSE))
  tableI <- read_cells(tableI_snapshot, "A1:G87")
  tableII <- read_cells(tableII_snapshot, "A1:AJ25")
  pirlot1981_sample_metadata_from_cells(tableI, tableII,
    unname(tools::md5sum(tableI_snapshot)), unname(tools::md5sum(tableII_snapshot)))
}

pirlot1981_write_sample_metadata <- function(repo_root, output_csv) {
  if (file.exists(output_csv))
    stop("Refusing to overwrite an existing output: ", output_csv, call. = FALSE)
  if (!dir.exists(dirname(output_csv)) || !grepl("\\.csv$", output_csv, ignore.case = TRUE))
    stop("Choose a new .csv file in an existing private directory.", call. = FALSE)
  p <- file.path(repo_root, "Pirlot__1981")
  samples <- pirlot1981_sample_metadata(
    file.path(p, "Pirlot__1981_TABLEI_snapshot.xlsx"),
    file.path(p, "Pirlot__1981_TABLEII_snapshot.xlsx"))
  utils::write.csv(samples, output_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  invisible(samples)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 2L)
    stop("Usage: Rscript volumes_sample_metadata_Pirlot__1981.R REPO_ROOT NEW_PRIVATE_CSV", call. = FALSE)
  samples <- pirlot1981_write_sample_metadata(args[1L], args[2L])
  message("Wrote ", nrow(samples), " metadata rows; no source data, keys or merge outputs changed.")
}
