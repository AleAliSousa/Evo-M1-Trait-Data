# Sheridan_etal_2022_TableS3.R -------------------------------------------------
#
# Sheridan, Mukerji, Wade, Humphreys, Garrisi, Goel, Patel, Fox, Zeanah, Nelson
# & McLaughlin (2022) Sci Adv 8(40): eabn4316. doi:10.1126/sciadv.abn4316
# Supplementary Materials Table S3: "Volume of total cortical grey and white
# matter as well as volume of six subcortical structures in cubic centimeters
# at the second (age 16 years) time point."
#
# Reads the frozen snapshot (Sheridan_etal_2022_TableS3_snapshot.csv, written by
# Sheridan_etal_2022_TableS3_snapshot.R) and does all the cleaning:
#   - one analysis row per printed structure x hemisphere x group
#     (2 whole-brain rows + 6 structures x 2 hemispheres = 14 printed rows,
#     x 3 groups = 42 printed cells), printed labels kept verbatim and the
#     structure label forward-filled onto the "Left" row;
#   - splits each cell "mean (dispersion)" into its printed lexemes and parses;
#   - converts cm3 (printed) to the project unit mm3: mm3 = cm3 x 1000;
#   - per HOWTO section 6 (hemispheres), adds one DERIVED row per structure x
#     group with hemisphere "Left+Right (computed)" = Left + Right mean
#     (value_status = "derived_sum"); no dispersion is given for it (the L/R
#     correlation is not reported). Rounding: each printed mean is to 0.1 cm3,
#     so the sum is uncertain by up to +/-0.1 cm3.
# The dispersion is printed in parentheses without being named in the caption
# (presumably SD; dispersion_type = "not stated").
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

snap <- as.matrix(read.csv(paste0(base, "_snapshot.csv"), header = FALSE, colClasses = "character",
                           na.strings = character(0), encoding = "UTF-8", check.names = FALSE))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 5L, nrow(snap) == 17L, snap[1, 1] == "Table S3.")

grp_hdr <- snap[2, 3:5]
grp_code <- sub("\\s*\\(.*$", "", grp_hdr)
grp_n <- as.integer(sub(".*n\\s*=\\s*([0-9]+)\\).*", "\\1", grp_hdr))
stopifnot(identical(grp_code, c("CAUG", "FCG", "NIG")), identical(grp_n, c(40L, 41L, 33L)))
grp_label <- c(CAUG = "care as usual group (prolonged institutional care)",
               FCG  = "foster care group (randomized to foster care)",
               NIG  = "never-institutionalized group (community controls)")   # main text, Participants

dat <- 3:16
structure <- snap[dat, 1]
for (i in seq_along(structure)) if (!nzchar(structure[i])) structure[i] <- structure[i - 1]
hemi <- snap[dat, 2]; hemi[!nzchar(hemi)] <- NA_character_

rows <- list()
for (k in seq_along(dat)) for (g in 1:3) {
  cell <- snap[dat[k], 2 + g]
  m <- regmatches(cell, regexec("^\\s*([0-9.]+)\\s*\\(([0-9.]+)\\)\\s*$", cell))[[1]]
  stopifnot(length(m) == 3L)
  rows[[length(rows) + 1L]] <- data.frame(
    printed_row = dat[k],
    structure_as_published  = structure[k],
    hemisphere_as_published = hemi[k],
    group_as_published = grp_hdr[g], group_code = grp_code[g], group_label = grp_label[[grp_code[g]]],
    is_control = grp_code[g] == "NIG", n_group = grp_n[g],
    cell_as_printed = cell, mean_printed = m[2], dispersion_printed = m[3],
    dispersion_type = "not stated (parenthetical; presumably SD)",
    unit_as_printed = "cubic centimeters",
    mean.cm3 = as.numeric(m[2]), dispersion.cm3 = as.numeric(m[3]),
    value_status = "printed", stringsAsFactors = FALSE)
}
printed_df <- do.call(rbind, rows)

## ---- derived Left+Right sums (HOWTO section 6) ------------------------------
lr <- printed_df[!is.na(printed_df$hemisphere_as_published), ]
key <- paste(lr$structure_as_published, lr$group_code)
sums <- do.call(rbind, lapply(split(lr, key), function(d) {
  stopifnot(nrow(d) == 2L, setequal(d$hemisphere_as_published, c("Right", "Left")))
  o <- d[1, ]
  o$printed_row <- NA_integer_; o$hemisphere_as_published <- "Left+Right (computed)"
  o$cell_as_printed <- NA_character_; o$mean_printed <- NA_character_; o$dispersion_printed <- NA_character_
  o$dispersion_type <- NA_character_
  o$mean.cm3 <- round(sum(d$mean.cm3), 1); o$dispersion.cm3 <- NA_real_
  o$value_status <- "derived_sum"
  o
}))
final.dataframe <- rbind(printed_df, sums)
ord <- order(match(final.dataframe$structure_as_published, unique(printed_df$structure_as_published)),
             match(final.dataframe$group_code, grp_code),
             is.na(final.dataframe$printed_row), final.dataframe$printed_row)
final.dataframe <- final.dataframe[ord, ]

## ---- project unit: volume mm3 = cm3 x 1000 ----------------------------------
final.dataframe$mean.mm3       <- final.dataframe$mean.cm3 * 1000
final.dataframe$dispersion.mm3 <- final.dataframe$dispersion.cm3 * 1000
final.dataframe$age_at_scan  <- "16-year time point (SM Table S1: mean age CAUG 200m, FCG 198m, NIG 201m)"
final.dataframe$species_as_published <- "children"   # main text: children in the Bucharest Early Intervention Project
final.dataframe$note <- ifelse(final.dataframe$value_status == "derived_sum",
  "Computed Left + Right of the two printed means (each to 0.1 cm3); not printed.", NA_character_)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 42L + 18L)
## Table S3 prints no total or other self-checking relation: no table_checks.

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name (never by row). The
## TSV is written ONLY when the item is registered; until the owner pastes the
## registry row, no TSV is written anywhere.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
