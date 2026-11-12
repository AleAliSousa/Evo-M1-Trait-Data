# Andersen_etal_1992_Table4.R ---------------------------------------------------
#
# Andersen, Korbo & Pakkenberg (1992), J Comp Neurol 326: 549-560.
# TABLE 4 "Total Cell Number in Five Human Cerebella (10^6)" (p. 557, PDF page 9).
#
# Reads the frozen snapshot Andersen_etal_1992_Table4_snapshot.csv (hand transcription
# of the scanned page, printed layout) and does all the cleaning:
#   - splits every printed cell "value (dispersion)" into number + dispersion; the
#     dispersion is a CE (SEM/mean) on brain rows 1-5 and a CV (SD/mean) on the Mean
#     row (footnote 1);
#   - reshapes to one row per brain (or Mean) x printed cell-type column;
#   - adds the absolute count (printed unit 10^6 cells x 1e6);
#   - re-adds the printed Mean row and its CV from the five brains (table_checks);
#   - writes the analysis CSV and, once registered, the public TSV.
#
# No table value is typed in this script.

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
base <- item_name

suppressPackageStartupMessages(library(readxl))

## ---- read the frozen snapshot (positional; every cell as printed text) -------
snap <- as.matrix(read.csv(paste0(base, "_snapshot.csv"), header = FALSE,
                           colClasses = "character", na.strings = character(0),
                           check.names = FALSE, fileEncoding = "UTF-8"))
dimnames(snap) <- NULL

## ---- helpers -----------------------------------------------------------------
## "80,900 (0.12)" -> value 80900, paren 0.12. Thousands commas stripped; a dash
## or blank cell is missing (never zero).
na_tokens <- c("", "-", "\u2013", "\u2014", "NA", "n.a.", "__", "e")
cell_value <- function(x) {
  v <- trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x))
  out <- suppressWarnings(as.numeric(gsub(",", "", v)))
  out[v %in% na_tokens] <- NA_real_
  out
}
cell_value_string <- function(x) gsub(",", "", trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x)))
cell_paren <- function(x) {
  p <- ifelse(grepl("\\(", x), sub("^.*\\(([^)]*)\\).*$", "\\1", x), NA_character_)
  suppressWarnings(as.numeric(p))
}
## half a unit in the last significant printed digit ("34,000" -> 500; "0.042" -> 0.0005)
half_unit <- function(s) {
  s <- cell_value_string(s)
  ifelse(grepl("\\.", s), 0.5 * 10^-nchar(sub("^.*\\.", "", s)),
         0.5 * 10^(nchar(s) - nchar(sub("0+$", "", s))))
}
tc_row <- function(check_id, basis, observed, printed, tolerance, note = "") {
  d <- observed - printed
  data.frame(check_id = check_id, basis = basis, observed = observed, printed = printed,
             difference = d, tolerance = tolerance,
             status = ifelse(is.na(d), "not_evaluable",
                             ifelse(abs(d) <= tolerance + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
## sample CV (SD with n - 1, as SD/mean) and the change in it that rounding of the
## printed inputs can explain (first-order: sum |dCV/dx_i| * half-unit_i)
cv_fun <- function(x) sd(x) / mean(x)
cv_tol <- function(x, h, h_printed) {
  g <- vapply(seq_along(x), function(i) {
    e <- 1e-6 * max(abs(x[i]), 1); xp <- x; xp[i] <- xp[i] + e
    (cv_fun(xp) - cv_fun(x)) / e
  }, numeric(1))
  sum(abs(g) * h) + h_printed
}

stopifnot(ncol(snap) == 8L, nrow(snap) == 9L)
stopifnot(identical(snap[2, ], c("Brain No.", "Granule", "Purkinje", "Golgi/g", "Glial/g",
                                 "Glial/m", "Neurons/m", "Dentate nuclei")))
stopifnot(identical(snap[3:8, 1], c("1", "2", "3", "4", "5", "Mean")))

hdr   <- snap[2, 2:8]
body  <- snap[3:8, 2:8, drop = FALSE]
brain <- snap[3:8, 1]

## Reference space per printed column, from footnote 1: "/g and /m refers to cells in
## either granular or molecular layer. The granular layer is the reference volume for
## granule, Purkinje, Golgi/g, glial/g cells; and the molecular layer is the reference
## volume for glial/m and neurons/m." Dentate nuclei = neurons (large neurons only,
## Discussion p. 559), counted by optical fractionator.
ref_space <- c(Granule = "granular layer", Purkinje = "granular layer",
               `Golgi/g` = "granular layer", `Glial/g` = "granular layer",
               `Glial/m` = "molecular layer", `Neurons/m` = "molecular layer",
               `Dentate nuclei` = "dentate nuclei")
cell_class <- c(Granule = "neuron", Purkinje = "neuron", `Golgi/g` = "neuron",
                `Glial/g` = "glia", `Glial/m` = "glia", `Neurons/m` = "neuron",
                `Dentate nuclei` = "neuron")
structure_of <- ifelse(hdr == "Dentate nuclei", "dentate nuclei", "cerebellar cortex")

rows <- expand.grid(i = seq_along(brain), j = seq_along(hdr))
printed <- body[cbind(rows$i, rows$j)]
is_mean <- brain[rows$i] == "Mean"
n_in_mean <- apply(body, 2, function(x) sum(!is.na(cell_value(x[1:5]))))

final.dataframe <- data.frame(
  printed_row              = rows$i,
  brain_no_as_printed      = brain[rows$i],
  observation_level        = ifelse(is_mean, "group mean", "individual"),
  n_brains                 = ifelse(is_mean, n_in_mean[rows$j], 1L),
  species_as_published     = "human",
  structure                = structure_of[rows$j],
  cell_type_as_printed     = hdr[rows$j],
  cell_class               = unname(cell_class[hdr[rows$j]]),
  reference_space          = unname(ref_space[hdr[rows$j]]),
  value_as_printed         = printed,
  N_cells.1e6              = cell_value(printed),
  N_cells                  = cell_value(printed) * 1e6,   # printed unit 10^6 cells -> cells
  dispersion               = cell_paren(printed),
  dispersion_type          = ifelse(is_mean, "CV (SD/mean) between cerebella",
                                    "CE (SEM/mean) of the individual estimate"),
  stringsAsFactors = FALSE, check.names = FALSE
)
final.dataframe <- final.dataframe[order(final.dataframe$printed_row,
                                         match(final.dataframe$cell_type_as_printed, hdr)), ]
rownames(final.dataframe) <- NULL
final.dataframe$note <- ifelse(final.dataframe$value_as_printed == "\u2014",
  "Printed as a dash: no dentate estimate for brain 4; the Mean is over the other 4 brains.",
  NA_character_)

## ---- table checks (build HOWTO 7a) --------------------------------------------
## Mean row = mean of the brains printed above it; tolerance = half a unit of the
## last significant printed digit of the inputs (propagated to the mean) plus half a
## unit of the printed mean. Dash cells are left out (dentate: n = 4).
## CV of the Mean row = sample SD/mean of the same brains; tolerance = first-order
## propagation of the input half-units plus half a unit of the printed CV.
table_checks <- do.call(rbind, lapply(seq_along(hdr), function(j) {
  x_str <- body[1:5, j]; x <- cell_value(x_str); keep <- !is.na(x)
  m_str <- body[6, j]
  h <- half_unit(x_str[keep])
  rbind(
    tc_row(paste0("mean_", hdr[j]), paste0("Mean row vs mean of brains 1-5, column '", hdr[j], "'"),
           mean(x[keep]), cell_value(m_str), mean(h) + half_unit(m_str),
           if (any(!keep)) paste0("left out (dash): brain ", paste(which(!keep), collapse = ", ")) else ""),
    tc_row(paste0("cv_", hdr[j]), paste0("Mean-row CV vs sample SD/mean of brains 1-5, column '", hdr[j], "'"),
           cv_fun(x[keep]), cell_paren(m_str), cv_tol(x[keep], h, 0.005),
           "SD with n - 1")
  )
}))
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$observed[i], bad$printed[i], bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) --------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                         .name_repair = "minimal")
  reg_names <- registry[["Item name"]]
  item_encoded <- registry[["Item encoded"]][match(item_name, reg_names)]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "",
              fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
