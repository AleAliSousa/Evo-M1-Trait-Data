# Andersen_etal_1992_Table7.R ---------------------------------------------------
#
# Andersen, Korbo & Pakkenberg (1992), J Comp Neurol 326: 549-560.
# TABLE 7 "The Mean and Overall Densities in Four Different Regions in the Human
# Cerebellum (10^3 mm^-3)" (p. 559, PDF page 11).
#
# Reads the frozen snapshot Andersen_etal_1992_Table7_snapshot.csv (hand transcription
# of the scanned page; region heading rows kept, one snapshot row per printed row) and:
#   - forward-fills the region heading onto its brain rows 1-5 and Mean;
#   - reshapes to one row per region x brain (1-5, Mean, Overall) x cell type;
#   - splits "value (CV)" (CV printed on Mean and Overall rows only);
#   - adds the density per mm^3 (printed unit 10^3 mm^-3 x 1000);
#   - re-adds each region's Mean and CV from its five brains (table_checks);
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

stopifnot(ncol(snap) == 7L, nrow(snap) == 32L)
hdr <- snap[2, 2:7]
stopifnot(identical(hdr, c("Granule", "Purkinje", "Golgi in granular layer",
                           "Glial in granular layer", "Glial in molecular layer",
                           "Neurons in molecular layer")))
lab <- snap[3:31, 1]
is_heading <- apply(snap[3:31, 2:7, drop = FALSE], 1, function(r) all(!nzchar(r)))
region <- character(length(lab)); cur <- ""
for (i in seq_along(lab)) { if (is_heading[i]) cur <- lab[i]; region[i] <- cur }
region[lab == "Overall"] <- "Overall"
stopifnot(identical(lab[is_heading], c("Pars anterior", "Pars posterior", "Vermis",
                                       "Flocculonodular lobe")))

ref_space <- c(rep("granular layer", 4), rep("molecular layer", 2))   # footnote 1
class_of  <- c("neuron", "neuron", "neuron", "glia", "glia", "neuron")
dr <- which(!is_heading)                     # data rows within 3:31
g  <- expand.grid(j = seq_along(hdr), k = seq_along(dr))
srow <- dr[g$k] + 2L                         # row in the snapshot matrix
printed <- snap[cbind(srow, g$j + 1L)]
obs <- ifelse(lab[dr[g$k]] == "Mean", "group mean",
       ifelse(lab[dr[g$k]] == "Overall", "overall (total number / total reference volume)",
              "individual"))
final.dataframe <- data.frame(
  printed_row             = srow - 2L,       # row within the printed table body, headings counted
  region_as_printed       = region[dr[g$k]],
  brain_no_as_printed     = lab[dr[g$k]],
  observation_level       = obs,
  n_brains                = ifelse(obs == "individual", 1L, 5L),
  species_as_published    = "human",
  cell_type_as_printed    = hdr[g$j],
  cell_class              = class_of[g$j],
  reference_space         = ref_space[g$j],
  value_as_printed        = printed,
  density.1e3_per_mm3     = cell_value(printed),
  density.per_mm3         = cell_value(printed) * 1000,  # printed unit 10^3 mm^-3 -> mm^-3
  CV                      = cell_paren(printed),
  stringsAsFactors = FALSE, check.names = FALSE
)
rownames(final.dataframe) <- NULL

## ---- table checks (build HOWTO 7a) --------------------------------------------
## For each region x cell type: Mean = mean of brains 1-5 (tolerance: mean of the
## inputs' half-units + half a unit of the printed mean) and Mean-row CV = sample
## SD/mean of brains 1-5 (tolerance: first-order propagation of the input half-units
## + 0.005). The Overall row is a ratio of totals over a reference volume the paper
## does not print, so it is not checkable from the table.
regs <- lab[is_heading]
table_checks <- do.call(rbind, lapply(regs, function(r) {
  rr <- which(region == r & !is_heading) + 2L          # 5 brains + Mean
  stopifnot(identical(snap[rr, 1], c("1", "2", "3", "4", "5", "Mean")))
  do.call(rbind, lapply(seq_along(hdr), function(j) {
    x_str <- snap[rr[1:5], j + 1L]; x <- cell_value(x_str); m_str <- snap[rr[6], j + 1L]
    h <- half_unit(x_str); id <- paste0(gsub(" ", "_", r), "__", gsub(" ", "_", hdr[j]))
    rbind(tc_row(paste0("mean_", id), paste0(r, " Mean vs mean of brains 1-5, column '", hdr[j], "'"),
                 mean(x), cell_value(m_str), mean(h) + half_unit(m_str)),
          tc_row(paste0("cv_", id), paste0(r, " Mean-row CV vs sample SD/mean of brains 1-5, column '", hdr[j], "'"),
                 cv_fun(x), cell_paren(m_str), cv_tol(x, h, 0.005), "SD with n - 1"))
  }))
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
