# Wegiel_etal_2014_Table3.R ----------------------------------------------------
#
# Wegiel J, Flory M, Kuchna I, Nowicki K, Ma SY, Imaki H, Wegiel J, Cohen IL,
# London E, Wisniewski T, Brown WT (2014). Acta Neuropathol Commun 2:141.
# doi:10.1186/s40478-014-0141-7
#
# Table 3 "Total number of neurons per region and neuronal numerical density in
# 15 structures and 16 cytoarchitectonic subdivisions in examined brain
# hemisphere of individuals with autism and control subjects*" (p. 10).
#
# Reads the frozen snapshot (Wegiel_etal_2014_Table3_snapshot.xlsx, written by
# Wegiel_etal_2014_Table3_snapshot.R from the PDF text layer) and:
#   - strips thousands commas; keeps the printed cells verbatim alongside;
#   - peels the printed dagger footnote mark off the p cell into its own column;
#   - reshapes to one row per printed region x printed group (Autism, Control);
#     the HEALTHY CONTROL group is "Control" (is_healthy_control = 1);
#   - keeps the printed region label verbatim and adds the stripped label and
#     its printed parent structure; the Cerebellum row counts Purkinje cells
#     only (cell_type);
#   - re-runs the one additive relation the table carries into `table_checks`:
#     printed structure total neurons = sum of its printed subdivisions;
#   - writes the analysis CSV, and the public TSV only once the item is
#     registered in __ReadMe.xlsx.
# UNITS: neuron number = count per region in ONE hemisphere (side not stated);
# numerical density = neurons per mm3 of PROCESSED tissue (as printed, N/mm3).
# No unit conversion is needed. Values are NOT doubled to whole-brain here.
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
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))   # keep printed '†' etc. as UTF-8 under Rscript

snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "Table3", col_names = FALSE,
                             col_types = "text", .name_repair = "minimal"))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 7L, nrow(snap) == 36L)
stopifnot(identical(as.character(snap[3, 2:7]), c("Autism", "Control", "p <", "Autism", "Control", "p <")))

dat  <- snap[4:34, , drop = FALSE]        # the 31 printed body rows
foot <- snap[35:36, 1]                    # the * and the dagger footnotes
stopifnot(nrow(dat) == 31L, all(!is.na(dat[, 1])), grepl("^\u2020", foot[2]))

## ---- cell helpers -------------------------------------------------------------
num_of <- function(x) {
  s <- trimws(gsub(",", "", x, fixed = TRUE))
  s[s %in% c("", "NA", "-", "\u2013", "\u2014", "n.a.")] <- NA_character_
  suppressWarnings(as.numeric(s))
}
mark_of <- function(x) ifelse(grepl("\u2020", x), "\u2020", NA_character_)
p_of    <- function(x) num_of(ifelse(grepl("^ns", x), NA_character_, x))

## ---- printed structure / subdivision hierarchy -------------------------------
label  <- dat[, 1]
is_sub <- grepl("^- ", label)
parent <- rep(NA_character_, length(label)); cur <- NA_character_
for (i in seq_along(label)) { if (!is_sub[i]) cur <- label[i] else parent[i] <- cur }
structure <- sub("^- ", "", label)
cell_type <- ifelse(grepl("Purkinje cells", label), "Purkinje cells", "neurons")
is_cerebellar <- label %in% c("Cerebellum (Purkinje cells)", "Dentate nucleus")

dagger_note <- paste0("Printed p cell carries footnote \u2020: ", sub("^\u2020", "", foot[2]))

## ---- reshape: one row per printed region x printed group ----------------------
groups <- snap[3, 2:3]                                   # "Autism", "Control"
col_n <- c(Autism = 2L, Control = 3L); col_d <- c(Autism = 5L, Control = 6L)
final.dataframe <- do.call(rbind, lapply(groups, function(g) {
  nt <- ifelse(is_cerebellar & g == "Autism",
    "Cerebellar row: two autism brains excluded from cerebellar estimates and a further 60-year-old case with cerebellar hypoplasia excluded from statistical analysis (Results, p. 8); n for this group not printed.",
    NA_character_)
  nt <- ifelse(!is.na(mark_of(dat[, 4])), ifelse(is.na(nt), dagger_note, paste(nt, dagger_note, sep = " | ")), nt)
  data.frame(
    printed_row                   = seq_len(nrow(dat)),
    Species                       = "Homo sapiens",
    species_as_published          = "Homo sapiens",
    structure_as_published        = label,
    structure                     = structure,
    parent_structure_as_published = parent,
    level                         = ifelse(is_sub, "subdivision", "structure"),
    cell_type                     = cell_type,
    group_as_published            = g,
    is_healthy_control            = as.integer(g == "Control"),
    hemisphere                    = "one hemisphere (side not stated)",
    n_subjects_cohort             = 14L,
    printed_neuron_number         = dat[, col_n[[g]]],
    neuron_number.count           = num_of(dat[, col_n[[g]]]),
    p_printed_neuron_number       = dat[, 4],
    p_less_than_neuron_number     = p_of(sub("\u2020.*$", "", dat[, 4])),
    footnote_mark_p_neuron_number = mark_of(dat[, 4]),
    printed_neuron_density        = dat[, col_d[[g]]],
    neuron_density.N_per_mm3      = num_of(dat[, col_d[[g]]]),
    p_printed_neuron_density      = dat[, 7],
    p_less_than_neuron_density    = p_of(dat[, 7]),
    note                          = nt,
    stringsAsFactors = FALSE, check.names = FALSE)
}))
final.dataframe <- final.dataframe[order(final.dataframe$printed_row, final.dataframe$is_healthy_control), ]
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 62L, !anyNA(final.dataframe$neuron_number.count),
          !anyNA(final.dataframe$neuron_density.N_per_mm3))

## ---- table checks (build HOWTO section 7a) --------------------------------------
## Printed structure total neurons = sum of its printed subdivisions (Autism and
## Control). Counts are printed to the unit, so the tolerance is half a unit per
## printed cell involved. Densities are not additive and are not summed.
chk <- list()
for (p in unique(na.omit(parent))) for (g in groups) {
  v <- num_of(dat[, col_n[[g]]]); kids <- which(parent %in% p); tot <- which(label == p)
  chk[[length(chk) + 1L]] <- data.frame(
    check_id = paste0("sum_", gsub("[^A-Za-z]+", "_", p), "_neurons_", g),
    basis = paste0("'", p, "' ", g, " total neurons = sum of printed ",
                   paste(sub("^- ", "", label[kids]), collapse = " + ")),
    observed = sum(v[kids]), printed = v[tot], difference = sum(v[kids]) - v[tot],
    tolerance = 0.5 * (length(kids) + 1L), stringsAsFactors = FALSE)
}
table_checks <- do.call(rbind, chk)
table_checks$status <- ifelse(abs(table_checks$difference) <= table_checks$tolerance + 1e-9, "pass", "mismatch")
table_checks$note <- "half a unit per printed cell, including the printed total"
rownames(table_checks) <- NULL
bad <- table_checks[table_checks$status != "pass", ]
if (nrow(bad)) warning(item_name, ": ", nrow(bad), " table check(s) did not pass: ",
                       paste(bad$check_id, collapse = ", "), " (printed values kept)")
message(item_name, ": table checks ", sum(table_checks$status == "pass"), " pass, ",
        sum(table_checks$status == "mismatch"), " mismatch, of ", nrow(table_checks))

options(scipen = 999)   # write p = 0.0001 as printed, not 1e-04
## ---- write the analysis CSV ------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) --------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) && !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
