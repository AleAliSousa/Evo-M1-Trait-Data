## Preuss_etal_1999_Fig2.R -- constructed snapshot (figure legend) -> analysis CSV + public TSV
##
## Preuss, T. M., Qi, H., & Kaas, J. H. (1999). Distinctive compartmental organization of human
##   primary visual cortex. Proceedings of the National Academy of Sciences of the United States of
##   America, 96(20), 11601-11606. https://doi.org/10.1073/pnas.96.20.11601
##
## Item: Fig. 2 legend (p. 11603): cytochrome oxidase staining of area V1 in Saimiri, Ateles, Macaca, Pongo, Pan and Homo (panels A-F)
##
## Frozen source -- CONSTRUCTED SNAPSHOT (snapshot HOWTO, "When there is no table"):
##   Preuss_etal_1999_Fig2_snapshot.csv holds one row per printed statement or diagram element (6 rows).
##   Transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF text layer and, for
##   diagram labels, from page images; human check pending (__ReadMe.xlsx, column AJ).
##   printed_wording is the short verbatim phrase at the locus; taxon, feature and state_as_read
##   are our reading of it and are what the human check confirms. This script only reads the
##   snapshot: it holds no data values, only the coding vocabulary below.
##
## Observation level: qualitative states per taxon, pooled over the individuals examined (n from
##   Methods); group statements ("apes and humans", "monkeys") are expanded in the snapshot to
##   the taxa examined, one row each. 
## Data role: primary.

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
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))

folder    <- basename(item_dir)                         # "Preuss_etal_1999" = species_key source_publication
item_name <- sub("\\.R$", "", basename(.sp))            # "Preuss_etal_1999_Fig2"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
pdf_file  <- file.path(item_dir, "preuss_etal_1999.pdf")             # used only to check the quoted wording
data_role <- "primary"

## ---- 1. Read the frozen snapshot (all character; blanks stay blank) ----
snap <- utils::read.csv(frozen, colClasses = "character", na.strings = character(0),
                        check.names = FALSE, fileEncoding = "UTF-8-BOM")
snap_cols <- c("row", "row_type", "locus", "page", "panel", "taxon_as_printed", "taxon_in_methods",
               "marker", "layer", "feature", "state_as_read", "value_low", "value_high", "unit",
               "n_as_printed", "applies_to", "printed_wording", "evidence", "note")
if (!identical(names(snap), snap_cols)) stop("unexpected snapshot columns in ", basename(frozen), call. = FALSE)
if (nrow(snap) != 6L) stop("expected 6 snapshot rows, got ", nrow(snap), call. = FALSE)
if (!identical(snap$row, as.character(seq_len(nrow(snap))))) stop("snapshot rows must be numbered 1..n", call. = FALSE)
snap[] <- lapply(snap, function(x) trimws(gsub("[[:space:]]+", " ", x)))

## ---- 2. Coding vocabulary (checked, never extended silently) ----
row_types <- c("statement", "terminal_label", "clade_label", "annotation", "letter_key", "photo_mark")
states <- c("present", "absent", "uncertain", "reduced", "present (some cases)", "value",
            "dense irregular territories", "uniform, moderate density", "label-sparse band",
            "layer 4B", "layer 6", "strong", "weak", "weakest", "most robust",
            "sparse", "increased", "dense in mesh bands", "dense in interstitial zones")
marks <- c("no mark", "filled arrow", "open arrow", "asterisk")
bad <- with(snap, !row_type %in% row_types |
              (row_type %in% c("statement", "annotation") & !state_as_read %in% states) |
              (row_type == "terminal_label" & !grepl("^(label|label with \\?|[a-e]+)$", state_as_read)) |
              (row_type == "clade_label" & state_as_read != "label") |
              (row_type == "letter_key" & !grepl("^[a-e]$", state_as_read)) |
              (row_type == "photo_mark" & !state_as_read %in% marks) |
              (state_as_read == "value" & (!nzchar(value_low) | !nzchar(unit))))
if (any(bad)) stop("unexpected row_type / state_as_read in snapshot row(s) ", paste(snap$row[bad], collapse = ", "), call. = FALSE)

## Feature label (snapshot) -> trait code (analysis CSV); same dictionary in every Preuss V1 item.
features <- c(
  `CO-dense band in layer 4A` = "L4A_CO_dense_band",
  `CO staining band in layer 4B (darker than in monkeys)` = "L4B_CO_band",
  `dense NPNF staining in layer 3` = "L3_NPNF_dense",
  `NPNF vertically oriented elements in light layer 4A` = "L4A_NPNF_vertical_elements",
  `NPNF bands bridging layers 4B and 3 across layer 4A` = "L4A_NPNF_bridging_bands",
  `NPNF mesh-like layer 4A` = "L4A_NPNF_mesh",
  `NPNF bands encapsulating light pockets in layer 4A` = "L4A_NPNF_encapsulating_bands",
  `pale-zone size in the NPNF mesh of layer 4A` = "L4A_pale_zone_diameter",
  `mesh-like pattern extending into deep layer 3` = "L3deep_mesh_extension",
  `MAP 2 mesh-like layer 4A` = "L4A_MAP2_mesh",
  `mesh-like layer 4A in tangential section` = "L4A_mesh_tangential",
  `mesh-like layer 4A` = "L4A_mesh",
  `honeycomb organization of layer 4A` = "L4A_honeycomb",
  `direct LGN (P-layer) input to layer 4A` = "L4A_direct_LGN_input",
  `pyramidal-cell clusters punctuating layer 4A` = "L4A_pyramidal_clusters",
  `indirect M-LGN input to layer 4B` = "L4B_indirect_M_input",
  `dense MAP 2 and NPNF in layer 4B and related parts of 4A` = "L4B_MAP2_NPNF_dense",
  `Cat-301 well-stratified V1 with a dark middle band` = "V1_Cat301_stratified",
  `Cat-301 mesh-like layer 4A` = "L4A_Cat301_mesh",
  `laminar position of the Cat-301 mesh` = "L4A_Cat301_mesh_laminar_position",
  `Cat-301 labels mainly nonpyramidal neurons in layer 4` = "L4_Cat301_nonpyramidal",
  `Cat-301+ soma diameter in layer 4A` = "L4A_Cat301_soma_diameter",
  `Cat-301+ soma diameter in layer 4A (scattered larger neurons)` = "L4A_Cat301_large_soma_diameter",
  `Cat-301 light-territory (capsule) diameter in layer 4A` = "L4A_Cat301_capsule_diameter",
  `most densely Cat-301-stained layer` = "V1_Cat301_densest_layer",
  `Cat-301 immunoreactivity strength (relative)` = "V1_Cat301_staining_strength",
  `NPNF and Cat-301 in the same compartments of layer 4A` = "L4A_Cat301_NPNF_same_compartments",
  `double-labelled neuronal elements in layer 4A (Cat-301 + NPNF)` = "L4A_Cat301_NPNF_double_labelled",
  `calbindin pattern in layer 4A` = "L4A_CB_pattern",
  `calbindin+ soma diameter in dense zones of layer 4A` = "L4A_CB_soma_diameter",
  `calbindin immunoreactivity strength (relative)` = "V1_CB_staining_strength",
  `calbindin-dense zones complementary to NPNF` = "L4A_CB_NPNF_complementary",
  `calbindin-dense zones complementary to Cat-301` = "L4A_CB_Cat301_complementary",
  `double-stained elements in layer 4A (calbindin + NPNF or Cat-301)` = "L4A_CB_double_labelled",
  `calbindin level in layer 4A` = "L4A_CB_level",
  `NPNF expression pattern in layer 4A` = "L4A_NPNF_pattern",
  `Cat-301 expression pattern in layer 4A` = "L4A_Cat301_pattern"
)
uses <- snap$row_type %in% c("statement", "annotation", "letter_key")
if (any(!snap$feature[uses] %in% names(features)))
  stop("feature without a trait code: ", paste(unique(snap$feature[uses][!snap$feature[uses] %in% names(features)]), collapse = "; "), call. = FALSE)

## ---- 3. Species: printed names kept; accepted names via the General collection key ----
## Rows for the authors' own material carry the name printed in Methods (taxon_in_methods, e.g.
## "Pan troglodytes"; "Macaca" where Methods pool several macaque species); diagram rows carry the
## genus label printed on the tree. Clade or group labels have no accepted species.
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), colClasses = "character",
                       check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == folder, , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(trimws(key$accepted_name), tolower(trimws(key$variant_name)))
groups <- c("macaques and other monkeys", "New World monkeys", "Old World monkeys", "hominoids",
            "Ancestral organization")
resolve <- function(printed, methods) {
  nm <- ifelse(nzchar(methods), methods, printed)
  sp <- unname(lk[tolower(nm)])
  sp[nm %in% groups] <- NA_character_
  miss <- is.na(sp) & !(nm %in% groups)
  if (any(miss)) stop("Unkeyed printed name(s): ", paste(unique(nm[miss]), collapse = ", "), call. = FALSE)
  list(name = nm, Species = sp)
}
level_of <- function(sp) ifelse(is.na(sp), "clade or group", ifelse(grepl(" sp\\.$", sp), "genus", "species"))
na_if_blank <- function(x) ifelse(nzchar(x), x, NA_character_)
locator <- function(d) paste0(d$locus, ", p. ", d$page, ifelse(nzchar(d$panel), paste0(", panel ", d$panel), ""))

out_row <- function(d, Species, name, state, basis, level, row_type = d$row_type, wording = d$printed_wording,
                    loc = locator(d), note = d$note, printed = d$taxon_as_printed, methods = d$taxon_in_methods) {
  data.frame(row = as.integer(d$row), row_type = row_type, taxon_as_printed = na_if_blank(printed),
             taxon_in_methods = na_if_blank(methods), species_as_published = na_if_blank(name), Species = Species,
             taxon_level = level_of(Species), cortical_area = "V1", layer = na_if_blank(d$layer),
             marker = na_if_blank(d$marker), feature = d$feature, trait = unname(features[d$feature]),
             state = state, value_low = suppressWarnings(as.numeric(d$value_low)),
             value_high = suppressWarnings(as.numeric(d$value_high)), unit = na_if_blank(d$unit),
             n_individuals = suppressWarnings(as.integer(d$n_as_printed)), state_basis = basis,
             printed_wording = na_if_blank(wording), source_locator = loc, observation_level = level,
             data_role = data_role, note = na_if_blank(note), source = item_name, stringsAsFactors = FALSE)
}

## ---- 4. Analysis rows ----
terms   <- snap[snap$row_type == "terminal_label", , drop = FALSE]
letters_key <- snap[snap$row_type == "letter_key", , drop = FALSE]
ann     <- snap[snap$row_type == "annotation", , drop = FALSE]
letter_mode <- nrow(letters_key) > 0L
targets_of <- function(a) strsplit(a, "; ", fixed = TRUE)[[1]]

rows <- list()
for (i in seq_len(nrow(snap))) {
  d <- snap[i, ]
  if (d$row_type == "statement") {
    r <- resolve(d$taxon_as_printed, d$taxon_in_methods)
    rows[[length(rows) + 1L]] <- out_row(d, r$Species, r$name,
      state = if (d$state_as_read == "value") NA_character_ else d$state_as_read,
      basis = paste0("stated (", d$evidence, ")"),
      level = if (is.na(r$Species)) "clade or group statement" else "taxon (pooled over the individuals examined)")
  } else if (d$row_type == "annotation" && d$applies_to == "root") {
    rows[[length(rows) + 1L]] <- out_row(d, NA_character_, "anthropoid ancestor", state = d$state_as_read,
      basis = "reconstructed ancestral state (diagram annotation)", level = "ancestral node (reconstruction)",
      row_type = "annotation")
  } else if (d$row_type == "annotation" && !(letter_mode && d$feature %in% letters_key$feature)) {
    for (t in targets_of(d$applies_to)) {
      tr <- terms[terms$taxon_as_printed == t, , drop = FALSE]
      if (nrow(tr) != 1L) stop("annotation row ", d$row, ": no single terminal label '", t, "'", call. = FALSE)
      r <- resolve(t, "")
      q <- tr$state_as_read == "label with ?"
      rows[[length(rows) + 1L]] <- out_row(d, r$Species, r$name,
        state = if (q) "uncertain" else d$state_as_read,
        basis = if (q) "uncertain: '?' printed under the tree label" else "inferred: change mapped to the branch (diagram annotation)",
        level = "terminal taxon (reconstruction)", row_type = "derived", printed = t, methods = "",
        note = paste0("annotation '", d$taxon_as_printed, "'", if (nzchar(d$note)) paste0("; ", d$note) else "",
                      if (nzchar(tr$note)) paste0("; label: ", tr$note) else ""))
    }
  }
}

## Letter-coded reconstruction (Fig. 11 type): a genus gets a state for a character only where its
## printed letter code includes that character's letter; the state comes from the most specific
## annotation covering the genus (fewest genera under the arrow; the root box covers all).
if (letter_mode) {
  n_targets <- function(a) if (a == "root") Inf else length(targets_of(a))
  for (j in seq_len(nrow(terms))) {
    t <- terms[j, ]
    r <- resolve(t$taxon_as_printed, "")
    for (k in seq_len(nrow(letters_key))) {
      lkr <- letters_key[k, ]
      cand <- ann[ann$feature == lkr$feature &
                    (ann$applies_to == "root" | vapply(ann$applies_to, function(a) t$taxon_as_printed %in% targets_of(a), NA)), , drop = FALSE]
      if (nrow(cand) == 0L) stop("no annotation covers ", t$taxon_as_printed, " for '", lkr$feature, "'", call. = FALSE)
      a <- cand[which.min(vapply(cand$applies_to, n_targets, 0)), ]
      has <- grepl(lkr$state_as_read, t$state_as_read, fixed = TRUE)
      d <- t; d$feature <- lkr$feature; d$marker <- lkr$marker; d$layer <- lkr$layer
      rows[[length(rows) + 1L]] <- out_row(d, r$Species, r$name,
        state = if (has) a$state_as_read else NA_character_,
        basis = if (has) "inferred: letter code printed + most specific annotation (reconstruction)" else "no data published (letter not in the printed code)",
        level = "terminal taxon (reconstruction)", row_type = "derived",
        wording = if (has) a$printed_wording else NA_character_,
        loc = paste0(locator(t), "; ", if (has) locator(a) else locator(lkr)),
        note = paste0("letter code '", t$state_as_read, "' (", lkr$state_as_read, " = ", lkr$feature, ")",
                      if (has) paste0("; annotation '", a$taxon_as_printed, "'") else "",
                      if (nzchar(t$note)) paste0("; ", t$note) else ""),
        methods = "")
    }
  }
}
final.dataframe <- do.call(rbind, rows)
rownames(final.dataframe) <- NULL
if (nrow(final.dataframe) != 6L) stop("expected 6 analysis rows, got ", nrow(final.dataframe), call. = FALSE)

## ---- 5. Checks: diagram marks vs annotations, and quoted wording vs the PDF text layer ----
tc <- list()
pm <- snap[snap$row_type == "photo_mark", , drop = FALSE]
if (nrow(pm)) {
  mark_feature <- c(CO = "CO-dense band in layer 4A", CB = "calbindin level in layer 4A",
                    NPNF = "NPNF expression pattern in layer 4A", `Cat-301` = "Cat-301 expression pattern in layer 4A")
  covers <- function(f, t, single) any(ann$feature == f & ann$applies_to != "root" &
    vapply(ann$applies_to, function(a) t %in% targets_of(a) && (length(targets_of(a)) == 1L) == single, NA))
  for (i in seq_len(nrow(pm))) {
    p <- pm[i, ]
    ok <- switch(p$state_as_read,
      "filled arrow" = covers(mark_feature[[p$marker]], p$taxon_as_printed, FALSE),
      "open arrow"   = covers(mark_feature[[p$marker]], p$taxon_as_printed, TRUE),
      "asterisk"     = any(snap$row_type == "statement" & snap$feature == "dense NPNF staining in layer 3" & snap$state_as_read == "increased"),
      "no mark"      = !covers(mark_feature[[p$marker]], p$taxon_as_printed, TRUE))
    tc[[length(tc) + 1L]] <- data.frame(check = "photomicrograph mark matches an annotation box", row = p$row,
      detail = paste(p$taxon_as_printed, p$marker, p$state_as_read), status = if (ok) "pass" else "mismatch")
  }
}
norm <- function(x) gsub("[^a-z0-9]", "", tolower(x), perl = TRUE)
colsplit <- function(p) {                       # two-column page -> left column then right column
  L <- strsplit(p, "\n", fixed = TRUE)[[1]]
  w <- max(c(0L, nchar(L)))
  if (w < 40L) return(p)
  ne <- L[nzchar(trimws(L))]
  pos <- seq.int(floor(w * 0.33), floor(w * 0.67) - 1L)
  score <- vapply(pos, function(k) sum(nchar(ne) <= k | substr(ne, k + 1L, k + 1L) == " "), 0)
  k <- pos[which.max(score)]
  paste(c(substr(L, 1L, k), substr(L, k + 1L, w)), collapse = "\n")
}
txt_rows <- snap$evidence != "figure image" & nzchar(snap$printed_wording)
if (file.exists(pdf_file) && requireNamespace("pdftools", quietly = TRUE)) {
  pg  <- pdftools::pdf_text(pdf_file)
  hay <- norm(c(pg, vapply(pg, colsplit, "")))
  found <- vapply(snap$printed_wording, function(w) any(grepl(norm(w), hay, fixed = TRUE)), NA)
  qstat <- ifelse(!txt_rows, "not evaluable (diagram text is not in the PDF text layer)", ifelse(found, "pass", "not found"))
} else {
  qstat <- ifelse(txt_rows, "not evaluated (PDF or pdftools missing)", "not evaluable (diagram text is not in the PDF text layer)")
}
tc[[length(tc) + 1L]] <- data.frame(check = "printed_wording found in the PDF text layer", row = snap$row,
                                    detail = snap$printed_wording, status = qstat)
table_checks <- do.call(rbind, tc)
if (any(table_checks$status %in% c("mismatch", "not found")))
  warning(sum(table_checks$status %in% c("mismatch", "not found")), " check(s) did not pass -- snapshot kept as transcribed; ",
          "see the README '## Checks'", call. = FALSE)

## ---- 6. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- 7. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.1073%2Fpnas.96.20.11601_Fig2
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written; check the registry row.", call. = FALSE)
} else {
  tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}

## ---- 8. Validate ----
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = if (is.na(tsv_path)) NULL else item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows; ", length(unique(stats::na.omit(final.dataframe$Species))),
        " accepted taxa; checks: ", paste(names(table(table_checks$status)), table(table_checks$status), sep = " = ", collapse = ", "))
