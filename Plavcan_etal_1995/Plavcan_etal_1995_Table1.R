## Plavcan_etal_1995_Table1.R -- frozen hand-transcribed snapshot -> analysis CSV + public TSV
##
## Plavcan, J. M., van Schaik, C. P., & Kappeler, P. M. (1995). Competition, coalitions and canine size
##   in primates. Journal of Human Evolution, 28(3), 245-276. https://doi.org/10.1006/jhev.1995.1019
##
## Item: Table 1 "Behavioral classifications and residual maxillary canine crown height", journal
##   pp. 252-255 (PDF pages 8-11 of Plavcan_1995_article.pdf: a scan with no text layer).
## Frozen source: Plavcan_etal_1995_Table1_snapshot.csv, written once by
##   Plavcan_etal_1995_Table1_snapshot.R from its verbatim printed-layout block (116 printed
##   lines x 10 columns, UTF-8 with BOM, no header line). This script only reads it; all cleaning is here.
##
## Observation level: one analysis row = one species x sex. Each of the 94 printed species rows holds a
##   Males block (C, I, F and a residual) and a Females block; the authors "classified each sex of each
##   species" (p. 248), so the 94 x 2 = 188 rows keep the sexes apart. Never average the two sexes.
## Data role: both. Coalitions / intensity / frequency are the authors' classifications made from field
##   reports in the literature (secondary; the printed keys are in `references`, resolved in
##   reference_tables/Plavcan_etal_1995_Table1_references.csv). The residual canine crown heights come
##   from the authors' own museum measurements (Plavcan 1990; Kappeler 1992) expressed against an
##   isometric line (primary, but a relative size index, not a raw measurement).

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
folder    <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp))                    # Plavcan_etal_1995_Table1
paper     <- basename(folder)                                   # Plavcan_etal_1995 = species_key source_publication
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d
})
snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.csv"))

## ---- 1. Read the frozen snapshot by position (all character; blank cells stay "") ----
snapshot <- utils::read.csv(snapshot_file, header = FALSE, colClasses = "character",
                            na.strings = character(0), check.names = FALSE, strip.white = FALSE,
                            fileEncoding = "UTF-8-BOM")
if (ncol(snapshot) != 10L || nrow(snapshot) != 116L)
  stop("expected the frozen snapshot to be 116 x 10, got ", nrow(snapshot), " x ", ncol(snapshot), call. = FALSE)
names(snapshot) <- c("species", "m_C", "m_I", "m_F", "f_C", "f_I", "f_F", "res_m", "res_f", "references")
printed_header <- c("Species", "C\u1d47", "I", "F", "C", "I", "F", "Males", "Females", "References")
hdr <- which(snapshot$species == "Species")
if (length(hdr) != 4L || !all(apply(snapshot[hdr, ], 1, function(r) identical(unname(r), printed_header))))
  stop("unexpected column-header lines in ", basename(snapshot_file), call. = FALSE)

## ---- 2. Type every printed line; carry the page and the group heading down ----
DASH   <- "\u2014"                                               # printed dash = not classified / no value
SUP    <- c("\u1d43" = "a", "\u1d47" = "b", "\u1d9c" = "c", "\u1d48" = "d")   # superscript footnote marks
groups <- c("Catarrhines", "Platyrrhines", "Prosimians")
rest_blank <- rowSums(snapshot[, -1] != "") == 0L
is_caption <- grepl("^Table 1", snapshot$species) & rest_blank
is_header  <- snapshot$species == "Species" | (snapshot$species == "" & snapshot$m_C == "Males")
is_group   <- snapshot$species %in% groups & rest_blank
is_note    <- substr(snapshot$species, 1, 1) %in% names(SUP) & rest_blank
is_data    <- !(is_caption | is_header | is_group | is_note)
if (sum(is_caption) != 4L || sum(is_group) != 6L || sum(is_note) != 4L || sum(is_data) != 94L)
  stop("unexpected line structure in ", basename(snapshot_file), call. = FALSE)
snapshot_row <- seq_len(nrow(snapshot))
printed_page <- 251L + cumsum(is_caption)                        # p. 252, then three "Table 1 Continued" pages
gi    <- cummax(ifelse(is_group, snapshot_row, 0L))
group <- ifelse(gi > 0L, snapshot$species[pmax(gi, 1L)], NA_character_)
footnotes <- stats::setNames(substring(snapshot$species[is_note], 2),
                             unname(SUP[substr(snapshot$species[is_note], 1, 1)]))

## ---- 3. Species rows: printed name kept, footnote mark split off, cells parsed ----
d    <- snapshot[is_data, ]
last <- substring(d$species, nchar(d$species))
species_footnote     <- ifelse(last %in% names(SUP), unname(SUP[last]), "")
species_as_published <- ifelse(nzchar(species_footnote), substr(d$species, 1, nchar(d$species) - 1L), d$species)

cls <- function(x, allowed, col) {                               # Yes/No or High/Low; dash -> NA
  bad <- !(x %in% c(allowed, DASH))
  if (any(bad)) stop("unexpected entry in ", col, ": ", paste(unique(x[bad]), collapse = ", "), call. = FALSE)
  ifelse(x == DASH, NA_character_, x)
}
num <- function(x, col) {                                        # printed residual -> numeric
  y <- gsub("[[:space:]]", "", x)
  y <- gsub("\u2212", "-", y, fixed = TRUE)                      # printed minus sign
  y <- gsub("\u00b7", ".", y, fixed = TRUE)                      # printed middle-dot decimal
  y[x == DASH] <- NA_character_
  v <- suppressWarnings(as.numeric(y))
  bad <- is.na(v) & x != DASH
  if (any(bad)) stop("unparsed residual in ", col, ": ", paste(unique(x[bad]), collapse = ", "), call. = FALSE)
  v
}

## Accepted names: _keys/General/species_key.csv rows for this paper (printed name kept beside it).
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                       check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == paper, , drop = FALSE]
if (nrow(key) == 0L)
  stop("No rows for '", paper, "' in _keys/General/species_key.csv: append ",
       "_keys_General_new_rows_Plavcan_etal_1995.csv first.", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
Species <- unname(lk[tolower(species_as_published)])
if (anyNA(Species))
  stop("Unkeyed printed name: ", paste(unique(species_as_published[is.na(Species)]), collapse = ", "), call. = FALSE)

sex_block <- function(sex, co, int, fr, res, lab) {
  out <- data.frame(
    table_order = seq_len(nrow(d)), printed_page = printed_page[is_data], snapshot_row = snapshot_row[is_data],
    group = group[is_data], species_as_published = species_as_published, Species = Species,
    species_footnote = species_footnote, sex = sex,
    coalitions = cls(co, c("Yes", "No"), paste(lab, "C")),
    intensity  = cls(int, c("High", "Low"), paste(lab, "I")),
    frequency  = cls(fr, c("High", "Low"), paste(lab, "F")),
    residual_canine_crown_height = num(res, paste("Residuals", lab)), residual_as_printed = res,
    references = d$references, stringsAsFactors = FALSE)
  n_na <- is.na(out$coalitions) + is.na(out$intensity) + is.na(out$frequency)
  if (any(n_na %in% 1:2)) warning(lab, " block partly classified on rows ", paste(which(n_na %in% 1:2), collapse = ", "),
                                  " -- kept as printed", call. = FALSE)
  out$classified <- n_na == 0L
  out
}
long <- rbind(sex_block("male",   d$m_C, d$m_I, d$m_F, d$res_m, "Males"),
              sex_block("female", d$f_C, d$f_I, d$f_F, d$res_f, "Females"))
long <- long[order(long$table_order, long$sex != "male"), ]      # printed order; Males block before Females

## Combined class in the paper's Figure 3 notation (p. 264): C HI HF = coalitions present.
long$figure3_class <- ifelse(!long$classified, NA_character_,
                       ifelse(long$coalitions == "Yes", "C HI HF",
                              paste(ifelse(long$intensity == "High", "HI", "LI"),
                                    ifelse(long$frequency == "High", "HF", "LF"))))
## Footnotes c and d qualify the classification of coalitions in males.
long$classification_note <- ifelse(long$sex == "male" & nzchar(long$species_footnote),
                                   unname(footnotes[long$species_footnote]), "")
long$observation_level <- "species x sex"
long$source_locator <- sprintf("Table 1, p. %d, snapshot row %d, %s block", long$printed_page, long$snapshot_row,
                               ifelse(long$sex == "male", "Males", "Females"))
long$data_role <- "both"

final.dataframe <- long[, c("table_order", "printed_page", "snapshot_row", "group", "species_as_published", "Species",
                            "species_footnote", "sex", "coalitions", "intensity", "frequency", "classified",
                            "figure3_class", "residual_canine_crown_height", "residual_as_printed",
                            "classification_note", "references", "observation_level", "source_locator", "data_role")]
rownames(final.dataframe) <- NULL

## ---- 4. Table checks (build HOWTO sec. 7a): relations the paper states about Table 1 ----
## Results stay in `table_checks` (QA metadata; never written to the CSV/TSV). Values are never changed.
tc <- list()
add_check <- function(check_id, basis, observed, printed, tolerance, ok, note = "")
  tc[[length(tc) + 1L]] <<- data.frame(check_id = check_id, basis = basis, observed = observed,
    printed = printed, difference = observed - printed, tolerance = tolerance,
    status = ifelse(is.na(ok), "not_evaluable", ifelse(ok, "pass", "mismatch")), note = note,
    stringsAsFactors = FALSE)
M  <- final.dataframe[final.dataframe$sex == "male", ]
Fm <- final.dataframe[final.dataframe$sex == "female", ]          # same species order as M
has_res <- function(x) !is.na(x$residual_canine_crown_height)

## 4a. Number of species (Materials and methods, p. 249).
add_check("species_rows_94", "printed species rows vs 'Dental metric data were gathered for 94 species' (p. 249)",
          nrow(M), 94, 0, nrow(M) == 94)

## 4b. Table 2 sample sizes (p. 259): coalitions = one-way ANOVA of coalitionary vs high-intensity,
##     high-frequency species; intensity = two-way ANOVA of non-coalitionary species.
n_coal <- function(x) sum(has_res(x) & x$classified & (x$coalitions == "Yes" | (x$intensity == "High" & x$frequency == "High")))
n_int  <- function(x) sum(has_res(x) & x$classified & x$coalitions == "No")
t2 <- list(list("females", "coalitions", Fm, n_coal, 23), list("females", "intensity", Fm, n_int, 64),
           list("males", "coalitions", M, n_coal, 33), list("males", "intensity", M, n_int, 87))
for (t in t2) {
  obs <- t[[4]](t[[3]])
  add_check(sprintf("table2_%s_%s_n", t[[1]], t[[2]]),
            sprintf("%s rows with a residual counted as in Table 2 (p. 259), %s effect: %s", t[[1]], t[[2]],
                    if (t[[2]] == "coalitions") "C = Yes, or C = No with I = High and F = High" else "classified with C = No"),
            obs, t[[5]], 0, obs == t[[5]],
            if (obs != t[[5]]) "Table 2 does not say which species was left out or added; values kept as printed" else "")
}

## 4c. Dimorphism sample (p. 259: "dimorphism could only be compared for 68 species") and Figure 3
##     (p. 264): species per cell of the 5 x 5 matrix of female (rows) x male (columns) classes;
##     "Eleven of these cells are empty" (p. 263). Printed N per cell, row-wise A-Y; empty cell = 0.
both <- M$classified & Fm$classified & has_res(M) & has_res(Fm)
add_check("text_dimorphism_species_68", "species with both sexes classified and both residuals vs '68 species' (p. 259; also the Figure 3 total)",
          sum(both), 68, 0, sum(both) == 68,
          if (sum(both) != 68) "difference located in Figure 3 cells E, M and Y (see the fig3_cell checks)" else "")
cats   <- c("C HI HF", "LI LF", "LI HF", "HI LF", "HI HF")       # Figure 3 row and column order
fig3_n <- matrix(c(0, 0, 0, 1, 4,   1, 20, 0, 6, 0,   4, 0, 3, 6, 4,   0, 0, 2, 7, 0,   0, 0, 1, 4, 5),
                 nrow = 5, byrow = TRUE, dimnames = list(cats, cats))
cell   <- table(factor(Fm$figure3_class[both], levels = cats), factor(M$figure3_class[both], levels = cats))
add_check("fig3_empty_cells_11", "empty cells of the Figure 3 matrix vs 'Eleven of these cells are empty' (p. 263)",
          sum(cell == 0), 11, 0, sum(cell == 0) == 11)
cell_id <- matrix(LETTERS[1:25], nrow = 5, byrow = TRUE)
for (i in 1:5) for (j in 1:5) {
  members <- M$species_as_published[both & Fm$figure3_class == cats[i] & M$figure3_class == cats[j]]
  add_check(sprintf("fig3_cell_%s_n", cell_id[i, j]),
            sprintf("species in Figure 3 cell %s (females %s x males %s) vs printed N (p. 264)", cell_id[i, j], cats[i], cats[j]),
            as.numeric(cell[i, j]), fig3_n[i, j], 0, cell[i, j] == fig3_n[i, j],
            if (cell[i, j] != fig3_n[i, j]) paste0("Table 1 species: ", paste(members, collapse = "; ")) else "")
}

## 4d. Coalitions in males (p. 249; footnotes c and d): only the "male-bonded" Pan troglodytes, Ateles
##     and Brachyteles, plus Colobus badius (tentative), and these are classified high-intensity,
##     high-frequency "for the purposes of hypothesis testing".
mc    <- M$species_as_published[M$classified & M$coalitions == "Yes"]
named <- c("Colobus badius", "Pan troglodytes", "Ateles geoffroyi", "Ateles paniscus", "Brachyteles arachnoides")
add_check("males_coalitionary_named_in_text", "male rows with C = Yes vs the species named on p. 249 (Pan troglodytes, Ateles, Brachyteles; Colobus badius tentatively)",
          length(mc), length(named), 0, setequal(mc, named), paste(mc, collapse = "; "))
fn_ok <- (M$coalitions %in% "Yes") == (M$species_footnote %in% c("c", "d"))
add_check("males_coalition_footnotes", "rows where male C = Yes coincide with the species printed with footnote c or d",
          sum(fn_ok), nrow(M), 0, all(fn_ok))
for (s in c("males", "females")) {
  x  <- if (s == "males") M else Fm
  co <- x$classified & x$coalitions == "Yes"
  hh <- co & x$intensity == "High" & x$frequency == "High"
  add_check(sprintf("%s_coalitionary_high_high", s),
            sprintf("%s rows with C = Yes that are also I = High and F = High", s), sum(hh), sum(co), 0, all(hh == co),
            if (s == "males") "stated on p. 249" else "implied, not stated, for females: coalitionary species are compared with other high-intensity, high-frequency species (p. 248)")
}
table_checks <- do.call(rbind, tc)
if (any(table_checks$status == "mismatch"))
  warning(sum(table_checks$status == "mismatch"), " table check(s) did not pass -- values kept as printed; ",
          "see the README '## Table checks'", call. = FALSE)

## ---- 5. Write the analysis CSV (UTF-8 with BOM, as Püschel_etal_2026_S1Data.R, so Excel shows the text) ----
csv_path <- file.path(folder, paste0(item_name, ".csv"))
.csv_txt <- enc2utf8(paste0(paste(utils::capture.output(
  utils::write.csv(final.dataframe, stdout(), row.names = FALSE, na = "")), collapse = "\n"), "\n"))
.con <- file(csv_path, open = "wb")
writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), .con); writeBin(charToRaw(.csv_txt), .con); close(.con)

## ---- 6. Public TSV: Item encoded looked up in __ReadMe.xlsx by Item name ----
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_dir  <- file.path(base, "__Public", "comparative-data")
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.1006%2Fjhev.1995.1019_Table1
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name,
          " -- public TSV NOT written; paste the registry row first.", call. = FALSE)
} else if (!dir.exists(tsv_dir)) {
  warning("__Public/comparative-data not found under ", base, " -- public TSV NOT written.", call. = FALSE)
} else {
  tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}

## ---- 7. Validate (tool layer, when present) ----
loader <- file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R")
if (file.exists(loader)) {
  source(loader)
  checks <- validate_dataset_item(
    csv_file           = csv_path,
    tsv_file           = tsv_path,
    readme_file        = file.path(folder, paste0(item_name, ".README.md")),
    definitions_file   = file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")),
    frozen_source_file = snapshot_file,
    registry           = filecodes,
    item_name          = item_name,
    item_encoded       = if (is.na(tsv_path)) NULL else item_encoded)
  print(checks)
}
message(item_name, ": ", nrow(final.dataframe), " rows (", nrow(M), " species x 2 sexes); table checks: ",
        paste(names(table(table_checks$status)), table(table_checks$status), sep = " = ", collapse = ", "))
