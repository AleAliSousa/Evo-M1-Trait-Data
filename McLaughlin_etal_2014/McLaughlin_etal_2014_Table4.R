# McLaughlin_etal_2014_Table4.R ------------------------------------------------
#
# McLaughlin, Sheridan, Winter, Fox, Zeanah & Nelson (2014), Biol Psychiatry
# 76: 629-638. doi:10.1016/j.biopsych.2013.08.016
# Table 4 "Group Differences in the Volume of Subcortical Structures and the
# Cerebellum Among Children Reared in Institutions and Community Control
# Subjects in the Bucharest Early Intervention Project (n = 80)", p. 634.
#
# Reads the frozen snapshot (McLaughlin_etal_2014_Table4_snapshot.xlsx, written
# by McLaughlin_etal_2014_Table4_snapshot.R) and does all the cleaning:
#   - one analysis row per printed structure x group (8 structures x 2 groups),
#     printed structure labels kept verbatim, "Striatum" kept as the section
#     of the four indented rows;
#   - parses M, SD, F and the FDR-corrected p; the Nucleus accumbens F cell
#     prints "3.68S": F_printed keeps it verbatim and F is parsed as 3.68
#     (errata McLaughlin_etal_2014-E001).
# UNITS: none printed in the table, its caption or footnote, and the text
# states none (FreeSurfer 5.0 volumetric segmentation is all it says). Values
# are therefore carried exactly as printed, unit_as_printed = "not printed",
# and NOT converted. The magnitudes are consistent with FreeSurfer mm3 and with
# left + right sums, but that is an inference, not a printed fact (README);
# a user who accepts it can treat volume_mean as mm3 (bilateral) with no
# numeric change.
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

snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "Table4",
                             col_names = FALSE, col_types = "text",
                             .name_repair = "minimal", trim_ws = FALSE))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 7L, nrow(snap) == 13L)
stopifnot(identical(as.character(snap[3, 2:7]), c("M", "SD", "M", "SD", "F", "p Value")))

num <- function(x) {
  s <- gsub("[(),]", "", x); s <- gsub("\\^[a-z]", "", s); s <- trimws(s)
  s[s %in% c("", "NA")] <- NA_character_
  suppressWarnings(as.numeric(s))
}

grp_hdr <- c(EIG = snap[2, 2], NIG = snap[2, 4])
grp_n   <- as.integer(sub(".*\\(n = ([0-9]+)\\).*", "\\1", grp_hdr))
grp_lbl <- trimws(sub("\\s*\\(n = [0-9]+\\)", "", grp_hdr))
stopifnot(identical(grp_n, c(58L, 22L)))

dat_rows <- 4:12
is_head  <- is.na(snap[dat_rows, 2])
section  <- rep(NA_character_, length(dat_rows)); cur <- NA_character_
for (i in seq_along(dat_rows)) {
  lab <- snap[dat_rows[i], 1]
  if (is_head[i]) { cur <- trimws(lab); next }
  section[i] <- if (grepl("^  ", lab)) cur else NA_character_
}
keep <- dat_rows[!is_head]; section <- section[!is_head]
stopifnot(length(keep) == 8L, sum(!is.na(section)) == 4L)

## F cell: a trailing stray letter (printed "3.68S") is split off, not repaired.
F_printed <- snap[keep, 6]
F_extra   <- ifelse(grepl("[A-Za-z]$", F_printed), sub("^[0-9.]+", "", F_printed), NA_character_)

rows <- list()
for (k in seq_along(keep)) {
  r <- keep[k]
  for (g in 1:2) {
    rows[[length(rows) + 1L]] <- data.frame(
      printed_row            = r,
      section_as_published   = section[k],
      structure_as_published = trimws(snap[r, 1]),
      group_as_published     = grp_hdr[[g]],
      group_label            = grp_lbl[g],
      group_code             = names(grp_hdr)[g],
      is_control             = names(grp_hdr)[g] == "NIG",
      n_group                = grp_n[g],
      mean_printed           = snap[r, c(2, 4)[g]],
      sd_printed             = snap[r, c(3, 5)[g]],
      volume_mean            = num(snap[r, c(2, 4)[g]]),
      volume_sd              = num(snap[r, c(3, 5)[g]]),
      unit_as_printed        = "not printed",
      hemisphere_as_published = "not printed",
      F_printed              = F_printed[k],
      F                      = num(sub("[A-Za-z]+$", "", F_printed[k])),
      F_trailing_text        = F_extra[k],
      p_FDR                  = num(snap[r, 7]),
      stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, rows)
final.dataframe$adjustment_of_test <- "F: age, gender, total brain volume, repetition time; p FDR-corrected (footnote a)"
final.dataframe$species_as_published <- "children"   # caption: "Children Reared in Institutions and Community Control Subjects"
final.dataframe$note <- ifelse(!is.na(final.dataframe$F_trailing_text),
  "F printed '3.68S'; parsed as 3.68 (BH-FDR of F(1, ~74) = 3.68 reproduces the printed p .472). See errata McLaughlin_etal_2014-E001.",
  NA_character_)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 16L, !anyNA(final.dataframe$volume_mean), !anyNA(final.dataframe$volume_sd))
## No printed total or other self-checking relation in Table 4: no table_checks.

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
