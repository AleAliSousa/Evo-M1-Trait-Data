# Wegiel_etal_2014_Table2.R ----------------------------------------------------
#
# Wegiel J, Flory M, Kuchna I, Nowicki K, Ma SY, Imaki H, Wegiel J, Cohen IL,
# London E, Wisniewski T, Brown WT (2014). Stereological study of the neuronal
# number and volume of 38 brain subdivisions of subjects diagnosed with autism
# reveals significant alterations restricted to the striatum, amygdala and
# cerebellum. Acta Neuropathol Commun 2:141. doi:10.1186/s40478-014-0141-7
#
# Table 2 "Mean volume (±SE) of 14 brain structures and 24 cytoarchitectonic
# subdivisions in one brain hemisphere of autistic and control subjects*" (p. 9).
#
# Reads the frozen snapshot (Wegiel_etal_2014_Table2_snapshot.xlsx, written by
# Wegiel_etal_2014_Table2_snapshot.R from the PDF text layer) and:
#   - splits each printed "mean ± SE" cell into mean and SE; strips thousands
#     commas; keeps the printed cell verbatim alongside;
#   - reshapes to one row per printed region x printed group (Autism, Control);
#     the HEALTHY CONTROL group is "Control" (is_healthy_control = 1);
#   - keeps the printed region label verbatim and adds the stripped label and
#     its printed parent structure;
#   - reads the shrinkage percentages (autism 47 %, control 45 %) from the
#     printed footnote, and re-runs the table's own relations into
#     `table_checks`: corrected = absolute / (1 - shrinkage), and the printed
#     structure totals = sum of their printed subdivisions;
#   - writes the analysis CSV, and the public TSV only once the item is
#     registered in __ReadMe.xlsx.
# UNITS: volumes are printed in mm3, already the project unit -> no conversion.
# HEMISPHERE: values are for ONE hemisphere (side not stated in this paper); they
# are NOT doubled here. Any whole-brain use must decide that explicitly.
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
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))   # keep printed '±' etc. as UTF-8 under Rscript

snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "Table2", col_names = FALSE,
                             col_types = "text", .name_repair = "minimal"))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 6L, nrow(snap) == 43L)
stopifnot(identical(as.character(snap[3, 2:6]), c("Autism", "Control", "p <", "Autism", "Control")))

dat  <- snap[4:41, , drop = FALSE]        # the 38 printed body rows
foot <- snap[42:43, 1]                    # the two printed footnote lines
stopifnot(nrow(dat) == 38L, all(!is.na(dat[, 1])))

## ---- cell helpers -------------------------------------------------------------
num_of <- function(x) {
  s <- trimws(gsub(",", "", x, fixed = TRUE))
  s[s %in% c("", "NA", "-", "\u2013", "\u2014", "n.a.")] <- NA_character_
  suppressWarnings(as.numeric(s))
}
mean_of <- function(x) num_of(sub("\\s*\u00b1.*$", "", x))
se_of   <- function(x) num_of(ifelse(grepl("\u00b1", x), sub("^.*\u00b1\\s*", "", x), NA_character_))

## ---- printed structure / subdivision hierarchy -------------------------------
label   <- dat[, 1]
is_sub  <- grepl("^- ", label)
parent  <- rep(NA_character_, length(label)); cur <- NA_character_
for (i in seq_along(label)) { if (!is_sub[i]) cur <- label[i] else parent[i] <- cur }
structure <- sub("^- ", "", label)

## ---- shrinkage percentages from the printed footnote --------------------------
m <- regmatches(foot[2], regexec("autism, ([0-9]+)%; control, ([0-9]+)%", foot[2]))[[1]]
stopifnot(length(m) == 3L)
shrink <- c(Autism = as.numeric(m[2]), Control = as.numeric(m[3]))   # percent

## ---- cerebellar rows: n differs from the cohort n (Results, p. 8) -------------
is_cerebellar <- structure == "Cerebellum" | parent %in% "Cerebellum"

## ---- reshape: one row per printed region x printed group ----------------------
groups <- snap[3, 2:3]                                   # "Autism", "Control"
col_abs <- c(Autism = 2L, Control = 3L); col_cor <- c(Autism = 5L, Control = 6L)
final.dataframe <- do.call(rbind, lapply(groups, function(g) {
  data.frame(
    printed_row                  = seq_len(nrow(dat)),
    Species                      = "Homo sapiens",
    species_as_published         = "Homo sapiens",
    structure_as_published       = label,
    structure                    = structure,
    parent_structure_as_published = ifelse(is.na(parent), NA_character_, parent),
    level                        = ifelse(is_sub, "subdivision", "structure"),
    group_as_published           = g,
    is_healthy_control           = as.integer(g == "Control"),
    hemisphere                   = "one hemisphere (side not stated)",
    n_subjects_cohort            = 14L,
    printed_volume_absolute      = dat[, col_abs[[g]]],
    volume_absolute.mm3          = mean_of(dat[, col_abs[[g]]]),
    volume_absolute_SE.mm3       = se_of(dat[, col_abs[[g]]]),
    printed_volume_corrected     = dat[, col_cor[[g]]],
    volume_shrinkage_corrected.mm3 = num_of(dat[, col_cor[[g]]]),
    shrinkage_pct_applied        = shrink[[g]],
    p_printed                    = dat[, 4],
    p_less_than                  = num_of(dat[, 4]),
    note                         = ifelse(is_cerebellar & g == "Autism",
      "Cerebellar row: two autism brains excluded from cerebellar estimates and a further 60-year-old case with cerebellar hypoplasia excluded from statistical analysis (Results, p. 8); n for this group not printed.",
      NA_character_),
    stringsAsFactors = FALSE, check.names = FALSE)
}))
final.dataframe <- final.dataframe[order(final.dataframe$printed_row, final.dataframe$is_healthy_control), ]
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 76L, !anyNA(final.dataframe$volume_absolute.mm3),
          !anyNA(final.dataframe$volume_shrinkage_corrected.mm3))

## ---- table checks (build HOWTO section 7a) --------------------------------------
## (1) footnote: corrected = absolute / (1 - shrinkage). Tolerance = half a unit of
##     the printed absolute, propagated (0.5 / (1 - s)), plus half a unit of the
##     printed corrected value.
fd <- final.dataframe
s  <- fd$shrinkage_pct_applied / 100
obs <- fd$volume_absolute.mm3 / (1 - s)
chk_shrink <- data.frame(
  check_id   = paste0("shrinkage_", fd$printed_row, "_", fd$group_as_published),
  basis      = paste0("'", fd$structure_as_published, "' ", fd$group_as_published,
                      ": printed absolute / (1 - ", fd$shrinkage_pct_applied, "%) vs printed corrected"),
  observed   = round(obs, 2), printed = fd$volume_shrinkage_corrected.mm3,
  difference = round(obs - fd$volume_shrinkage_corrected.mm3, 2),
  tolerance  = round(0.5 / (1 - s) + 0.5, 2), stringsAsFactors = FALSE)
## (2) printed structure total = sum of its printed subdivisions, in each of the
##     four value columns. Tolerance = half a unit per printed cell involved; in
##     the two corrected columns each cell was computed from a ROUNDED absolute
##     value, so each cell also carries that half unit propagated, 0.5 / (1 - s).
##     Not additive and therefore left out: "- Dentate nucleus" (part of
##     "- Cerebellar nuclei"), and "- Molecular layer" / "- Granule cell layer",
##     which are checked against "- Cerebellar cortex (calculated)" instead.
sum_sets <- list()
for (p in unique(na.omit(parent))) {
  kids <- which(parent %in% p)
  if (p == "Cerebellum") {
    sum_sets[["Cerebellum"]] <- list(total = which(label == "Cerebellum"),
      parts = which(label %in% c("- Cerebellar cortex (calculated)", "- Cerebellar white matter", "- Cerebellar nuclei")))
    sum_sets[["Cerebellar cortex (calculated)"]] <- list(total = which(label == "- Cerebellar cortex (calculated)"),
      parts = which(label %in% c("- Molecular layer", "- Granule cell layer")))
  } else sum_sets[[p]] <- list(total = which(label == p), parts = kids)
}
col_set <- c(abs_Autism = 2L, abs_Control = 3L, corrected_Autism = 5L, corrected_Control = 6L)
chk_sum <- do.call(rbind, lapply(names(sum_sets), function(nm) do.call(rbind, lapply(names(col_set), function(cn) {
  st <- sum_sets[[nm]]; v <- mean_of(dat[, col_set[[cn]]])
  data.frame(check_id = paste0("sum_", gsub("[^A-Za-z]+", "_", nm), "_", cn),
             basis = paste0("'", nm, "' ", cn, " = sum of printed ",
                            paste(sub("^- ", "", label[st$parts]), collapse = " + ")),
             observed = sum(v[st$parts]), printed = v[st$total],
             difference = sum(v[st$parts]) - v[st$total],
             tolerance = round((0.5 + if (grepl("^corrected", cn))
                                 0.5 / (1 - shrink[[sub("^.*_", "", cn)]] / 100) else 0) *
                               (length(st$parts) + 1L), 2), stringsAsFactors = FALSE)
}))))
table_checks <- rbind(chk_shrink, chk_sum)
table_checks$status <- ifelse(abs(table_checks$difference) <= table_checks$tolerance + 1e-9, "pass", "mismatch")
table_checks$note <- ifelse(grepl("^shrinkage", table_checks$check_id),
  "relation from the printed footnote 'Volume (mm3) corrected for shrinkage: autism, 47%; control, 45%'",
  ifelse(grepl("_corrected_", table_checks$check_id),
         "per printed cell incl. the total: half a unit + half a unit of the rounded absolute propagated, 0.5/(1 - s)",
         "half a unit per summed printed cell, including the printed total"))
table_checks$note[table_checks$check_id == "shrinkage_38_Autism"] <-
  "See errata Wegiel_etal_2014-E001: printed 511, expected 460 from the printed absolute 244 (also given in the Results text, p. 7)."
table_checks$note[table_checks$check_id == "shrinkage_4_Control"] <-
  "See errata Wegiel_etal_2014-E002: printed 1,096; 602/0.55 = 1,094.5 and the corrected subdivisions sum to 1,094."
rownames(table_checks) <- NULL
bad <- table_checks[table_checks$status != "pass", ]
if (nrow(bad)) warning(item_name, ": ", nrow(bad), " table check(s) did not pass: ",
                       paste(bad$check_id, collapse = ", "), " (printed values kept; see errata)")
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
