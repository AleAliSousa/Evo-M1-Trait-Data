# Gilboe_Betz_1973_TABLE2.R ------------------------------------------------
#
# Gilboe, D. D., & Betz, A. L. (1973). Oxygen uptake in the isolated canine brain. American Journal of Physiology, 224(3), 588-595.
# DOI 10.1152/ajplegacy.1973.224.3.588. Item TABLE2.
#
# Reads the frozen snapshot Gilboe_Betz_1973_TABLE2_snapshot.csv (written by
# Gilboe_Betz_1973_extract_snapshot.R) and reshapes it to one analysis row per printed
# value cell: mean / dispersion / n / footnote marks split into their own fields,
# the printed species, anesthesia and preparation attached, CMRO2 / CMRgl / CBF also
# given in the merge's standard units. The cell map below names snapshot rows and
# columns and the variable each holds; no table value is typed in this script.
# Table checks (build HOWTO s.7a) are left in `table_checks`.
# ---------------------------------------------------------------------------

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
paper <- basename(folder)
locus <- sub(paste0("^", paper, "_"), "", item_name)

doi <- "10.1152/ajplegacy.1973.224.3.588"

## ---- read the frozen snapshot (written by <paper>_extract_snapshot.R) ----------
read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
snap <- read_snapshot(paste0(base, "_snapshot.csv"))

## ---- cell helpers --------------------------------------------------------------
## A printed cell can carry a mean, "\u00b1 dispersion", a parenthesised number (n or a
## remark key, per item), trailing footnote marks (^a,b or * / **) and a second
## printed line. Each part is peeled off into its own field; nothing is repaired.
one_line   <- function(x) trimws(gsub("\\s*\n\\s*", " ", x))
marks_of   <- function(x) {
  m <- ifelse(grepl("\\^[a-z](,[a-z])*\\s*$", x), sub("^.*\\^([a-z](,[a-z])*)\\s*$", "\\1", x),
       ifelse(grepl("\\*+\\s*$", x), sub("^.*?(\\*+)\\s*$", "\\1", x), NA_character_))
  gsub(",", "; ", m, fixed = TRUE)
}
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)\\s*$", "", x))
paren_of    <- function(x) ifelse(grepl("\\(([0-9]+)\\)", x), gsub("^.*\\(([0-9]+)\\).*$", "\\1", x), NA_character_)
strip_paren <- function(x) trimws(gsub("\\s*\\([0-9]+\\)", "", x))
mean_lex    <- function(x) trimws(sub("\\s*\u00b1.*$", "", x))
disp_lex    <- function(x) ifelse(grepl("\u00b1", x), trimws(sub("^.*\u00b1\\s*", "", x)), NA_character_)
num         <- function(x) suppressWarnings(as.numeric(gsub(",", "", x)))
parse_cell  <- function(cell) {
  s <- one_line(cell)
  marks <- marks_of(s); s <- strip_marks(s)
  par <- paren_of(s);   s <- strip_paren(s)
  marks2 <- marks_of(s); s <- strip_marks(s)        # a mark printed before "(n)"
  marks <- ifelse(is.na(marks), marks2, marks)
  m <- mean_lex(s); d <- disp_lex(s)
  d_marks <- marks_of(ifelse(is.na(d), "", d)); if (!is.na(d)) d <- strip_marks(d)
  if (is.na(marks) && !is.na(d_marks)) marks <- d_marks
  list(value_printed = m, dispersion_printed = d, paren = par, marks = marks)
}
snake <- function(x) { x <- tolower(gsub("[^A-Za-z0-9]+", "_", x)); gsub("^_+|_+$", "", x) }

## Half a unit in the last printed decimal place ("3.39" -> 0.005, "76" -> 0.5).
hu <- function(lex) { s <- gsub("[^0-9.]", "", lex)
  d <- ifelse(grepl("\\.", s), nchar(sub("^[^.]*\\.", "", s)), 0); 0.5 * 10^(-d) }
## Half a unit in the last SIGNIFICANT digit (integer trailing zeros not significant: "660" -> 5).
hu_sig <- function(lex) { s <- gsub("[^0-9.]", "", lex)
  ifelse(grepl("\\.", s), hu(lex), { z <- nchar(s) - nchar(sub("0+$", "", s)); 0.5 * 10^z }) }
cell_num <- function(r, c) num(parse_cell(snap[r, c])$value_printed)
cell_lex <- function(r, c) parse_cell(snap[r, c])$value_printed
table_checks <- data.frame(check_id = character(), basis = character(), observed = numeric(),
                           printed = numeric(), difference = numeric(), tolerance = numeric(),
                           status = character(), note = character(), stringsAsFactors = FALSE)
add_check <- function(id, basis, observed, printed, tolerance, note = NA_character_, status = NULL) {
  if (is.null(status)) status <- if (is.na(observed) || is.na(printed)) "not_evaluable" else
    if (abs(observed - printed) <= tolerance + 1e-9) "pass" else "mismatch"
  table_checks[nrow(table_checks) + 1L, ] <<- list(id, basis, observed, printed,
    observed - printed, tolerance, status, note)
}

## ---- unit standardisation (the merge's factors) -----------------------------------
## CMRO2: ml O2 -> umol x 44.64 (as __merging_cerebral_metabolic_rate, O2_UMOL_PER_ML).
## CMRgl: mg glucose -> umol x 1000/180.16 (glucose molar mass 180.16 g/mol).
## CBF: ml/100 g/min is already the project unit.
O2_UMOL_PER_ML <- 44.64
GLC_UMOL_PER_MG <- 1000 / 180.16
std_of <- function(variable, value) {
  if (grepl("^CMRO2", variable)) return(list(value * O2_UMOL_PER_ML, "umol/100g/min", "ml O2 x 44.64"))
  if (grepl("^CMRgl", variable)) return(list(value * GLC_UMOL_PER_MG, "umol/100g/min", "mg glucose x 1000/180.16"))
  if (grepl("^CBF", variable))   return(list(value, "mL/100g/min", "none (already mL/100g/min)"))
  list(NA_real_, NA_character_, NA_character_)
}

## Byte-exact UTF-8 writer (write.csv in a non-UTF-8 session locale would escape
## characters such as en dashes as <U+2013>): character fields quoted, quotes doubled.
write_utf8_table <- function(df, file, sep, na) {
  cols <- lapply(df, function(x) {
    if (is.character(x)) { out <- paste0('"', gsub('"', '""', enc2utf8(x), fixed = TRUE), '"'); out[is.na(x)] <- na; out }
    else { out <- as.character(x); out[is.na(x)] <- na; out } })
  lines <- c(paste0('"', names(df), '"', collapse = sep), do.call(paste, c(cols, sep = sep)))
  con <- file(file, open = "wb"); writeLines(lines, con, useBytes = TRUE); close(con)
}

## ---- cell map ----------------------------------------------------------------
data_rows  <- c(3, 4, 5)
group_rows <- integer(0)
paren_meaning <- "n"   # what a parenthesised number in a cell is
cols <- data.frame(
  col = c(2, 3, 4),
  column_as_printed = c("Halothane", "P", "Sodium Pentobarbital"),
  variable = c("", "P_value_text", ""),
  units_printed = c("", "", ""),
  col_arm = c("halothane", "halothane vs sodium pentobarbital", "sodium pentobarbital"),
  dispersion_type = c("SE", "none", "SE"), stringsAsFactors = FALSE)
## row-variable table: the printed row names the variable
row_vars <- data.frame(row = c(3, 4, 5), variable = c("CMRO2_ml_100g_min", "CO2_efflux_ml_100g_min", "cerebral_RQ"),
                       units_printed = c("ml/100 g per min", "ml/100 g per min", "ratio"), stringsAsFactors = FALSE)
cell_map <- merge(data.frame(row = data_rows), cols, by = NULL)
cell_map <- cell_map[order(cell_map$row, cell_map$col), ]; rownames(cell_map) <- NULL
is_p <- cell_map$variable == "P_value_text"
cell_map$variable[!is_p]      <- row_vars$variable[match(cell_map$row[!is_p], row_vars$row)]
cell_map$units_printed[!is_p] <- row_vars$units_printed[match(cell_map$row[!is_p], row_vars$row)]
cell_map$variable[is_p] <- paste0("P_value_", row_vars$variable[match(cell_map$row[is_p], row_vars$row)])
## row-level fields, read from the snapshot
lab <- sapply(data_rows, function(r) one_line(snap[r, 1]))
grp <- sapply(data_rows, function(r) { g <- group_rows[group_rows < r]; if (length(g)) one_line(snap[max(g), 1]) else NA_character_ })
ix <- match(cell_map$row, data_rows)
cell_map$row_label <- lab[ix]; cell_map$group <- grp[ix]
cell_map$condition <- NA_character_
cell_map$attr_condition <- NA_character_
cell_map$attr_reflex <- NA_character_
cell_map$attr_remarks <- NA_character_
cell_map$n_printed <- NA_character_
cell_map$n_meaning <- "number of determinations (parentheses), not animals; 25 brains per group"
cell_map$species <- "adult mongrel dogs (canine)"
cell_map$anesthesia <- with(cell_map, ifelse(col_arm == "sodium pentobarbital", "morphine sulfate 60 mg 30 min before sodium pentobarbital 25 mg/kg (supplemented as required); phenoxybenzamine 1.0 mg/kg", ifelse(col_arm == "halothane", "halothane induction and maintenance throughout isolation (evaporates from the perfusion blood in the oxygenator); phenoxybenzamine 1.0 mg/kg", "comparison of the two anesthetic groups")))
cell_map$preparation <- "isolated canine brain (left within the cranium), perfused at 37 C from a disc oxygenator with blood from compatible donors (dextran-diluted, Hct ~25%); adult mongrel dogs 15-20 kg"
cell_map$arm_id <- snake(apply(cell_map[, c("group", "row_label", "condition", "col_arm")], 1,
                              function(z) paste(z[!is.na(z) & nzchar(z)], collapse = " ")))
cell_map$note <- NA_character_
expected_values <- 9L   # non-blank mapped cells (+ bracketed second values)

## ---- reshape: one analysis row per printed value cell ---------------------------
stopifnot(all(cell_map$row %in% seq_len(nrow(snap))), all(cell_map$col %in% seq_len(ncol(snap))))
rows_out <- list()
for (k in seq_len(nrow(cell_map))) {
  r <- cell_map$row[k]; c <- cell_map$col[k]
  raw <- snap[r, c]
  if (!nzchar(trimws(raw))) next                                 # printed blank: no value
  parts <- strsplit(raw, "\n", fixed = TRUE)[[1]]
  ## a line opening with "[" is a second, separately printed value (Gilboe TABLE 1)
  starts <- c(1L, which(grepl("^\\s*\\[", parts)))
  starts <- unique(starts[starts <= length(parts)])
  chunks <- lapply(seq_along(starts), function(j) {
    e <- if (j < length(starts)) starts[j + 1L] - 1L else length(parts)
    paste(parts[starts[j]:e], collapse = "\n") })
  for (j in seq_along(chunks)) {
    ch <- chunks[[j]]; bracketed <- grepl("^\\s*\\[", ch)
    p <- parse_cell(gsub("^\\s*\\[|\\]\\s*$", "", ch))
    v <- num(p$value_printed); d <- num(p$dispersion_printed)
    st <- std_of(cell_map$variable[k], v)
    rows_out[[length(rows_out) + 1L]] <- data.frame(
      item_name = item_name, printed_row = r, printed_col = c,
      group_as_printed = cell_map$group[k], row_label_as_printed = cell_map$row_label[k],
      condition_as_printed = cell_map$condition[k],
      column_as_printed = cell_map$column_as_printed[k],
      arm_id = cell_map$arm_id[k], variable = cell_map$variable[k],
      value_printed = p$value_printed, value = v,
      dispersion_printed = p$dispersion_printed, dispersion = d,
      dispersion_type = ifelse(is.na(p$dispersion_printed), NA_character_, cell_map$dispersion_type[k]),
      n_printed = if (identical(paren_meaning, "n")) p$paren else cell_map$n_printed[k],
      n = num(if (identical(paren_meaning, "n")) p$paren else cell_map$n_printed[k]),
      n_meaning = cell_map$n_meaning[k],
      footnote_marks = p$marks,
      remark_keys = if (identical(paren_meaning, "remark")) p$paren else NA_character_,
      units_printed = cell_map$units_printed[k],
      value_std = st[[1]], units_std = st[[2]], conversion = st[[3]],
      species_as_published = cell_map$species[k], anesthesia = cell_map$anesthesia[k],
      preparation = cell_map$preparation[k],
      condition_of_animal_as_printed = cell_map$attr_condition[k],
      corneal_reflex_as_printed = cell_map$attr_reflex[k],
      remarks_as_printed = cell_map$attr_remarks[k],
      bracketed_other_study = bracketed,
      note = cell_map$note[k], stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, rows_out)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == expected_values)

## ---- table checks (build HOWTO s.7a) ---------------------------------------

## RQ = CO2 efflux / O2 uptake. The printed RQ may be a mean of ratios, so the
## ratio of the printed means is allowed the rounding of all three cells only.
for (cc in c(2L, 4L)) { o <- cell_num(3, cc); c2 <- cell_num(4, cc)
  add_check(paste0("RQ_col", cc), paste0("RQ = CO2 efflux / O2 uptake [", snap[2, cc], "]"), c2 / o, cell_num(5, cc),
            (c2 / o) * (hu(cell_lex(4, cc)) / c2 + hu(cell_lex(3, cc)) / o) + hu(cell_lex(5, cc)),
            "ratio of means; the printed RQ may be a mean of per-determination ratios") }


tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$basis[i], bad$observed[i], bad$printed[i], bad$difference[i],
                    bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write_utf8_table(final.dataframe, paste0(base, ".csv"), sep = ",", na = "NA")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived exactly as the registry formula would build
## it (DOI with "/" percent-encoded, "_", item locus) and the README says the item
## awaits registration; the registry stays the authority.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(gsub("/", "%2F", doi, fixed = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ",
          item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write_utf8_table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", na = "")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")

