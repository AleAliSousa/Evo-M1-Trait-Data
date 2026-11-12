# McLaughlin_etal_2014_Table1.R ------------------------------------------------
#
# McLaughlin, Sheridan, Winter, Fox, Zeanah & Nelson (2014), Biol Psychiatry
# 76: 629-638. doi:10.1016/j.biopsych.2013.08.016
# Table 1 "Sociodemographic and Developmental Characteristics Among Children
# Reared in Institutions and Community Control Subjects in the Bucharest Early
# Intervention Project (n = 80)", p. 630.
#
# Reads the frozen snapshot (McLaughlin_etal_2014_Table1_snapshot.xlsx, written
# by McLaughlin_etal_2014_Table1_snapshot.R) and does all the cleaning:
#   - one analysis row per printed variable x group (11 variables x 2 groups);
#   - splits each printed group n from its spanning header;
#   - parses M and the parenthesised SD; the Female row prints a count and a
#     percentage instead, parsed into count / percent;
#   - peels the "^a" significance mark and the chi-square label off the
#     Group Difference cells;
#   - re-checks the printed female percentages against count / group n
#     (table_checks, HOWTO section 7a).
# Units: as printed in the row label (Months, grams, cm). The three volume rows
# (Intracranial Volume, Cerebral Gray Matter, Cortical Gray Matter) print NO
# unit, and the paper's text states none either; they are carried as printed
# with unit_as_printed = "not printed" and NOT converted (README).
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

snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "Table1",
                             col_names = FALSE, col_types = "text",
                             .name_repair = "minimal", trim_ws = FALSE))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 7L, nrow(snap) == 16L)
stopifnot(identical(as.character(snap[3, 2:7]), c("M", "SD", "M", "SD", "F", "p Value")))

num <- function(x) {
  s <- gsub("[(),]", "", x); s <- gsub("\\^[a-z]", "", s); s <- trimws(s)
  s[s %in% c("", "NA")] <- NA_character_
  suppressWarnings(as.numeric(s))
}

## ---- group headers --------------------------------------------------------
grp_hdr <- c(EIG = snap[2, 2], NIG = snap[2, 4])
grp_n   <- as.integer(sub(".*\\(n = ([0-9]+)\\).*", "\\1", grp_hdr))
grp_lbl <- trimws(sub("\\s*\\(n = [0-9]+\\)", "", grp_hdr))
stopifnot(identical(grp_n, c(58L, 22L)))

## ---- data rows: rows 4-14, skipping the "Age (Months)" heading -------------
dat_rows <- 4:14
is_head  <- is.na(snap[dat_rows, 2]) & is.na(snap[dat_rows, 6])
section  <- rep(NA_character_, length(dat_rows))
cur <- NA_character_
for (i in seq_along(dat_rows)) {
  lab <- snap[dat_rows[i], 1]
  if (is_head[i]) { cur <- trimws(lab); next }
  section[i] <- if (grepl("^  ", lab)) cur else NA_character_
}
keep <- dat_rows[!is_head]; section <- section[!is_head]
stopifnot(length(keep) == 10L)

unit_of <- function(lab, sec) {
  u <- ifelse(grepl("\\(([^)]*)\\)$", lab), sub(".*\\(([^)]*)\\)$", "\\1", lab), NA_character_)
  u <- ifelse(is.na(u) & !is.na(sec), sub(".*\\(([^)]*)\\)$", "\\1", sec), u)
  u[is.na(u)] <- "not printed"
  u
}

rows <- list()
for (k in seq_along(keep)) {
  r <- keep[k]; lab <- snap[r, 1]
  stat_txt <- snap[r, 6]
  for (g in 1:2) {
    mcell <- snap[r, c(2, 4)[g]]; sdcell <- snap[r, c(3, 5)[g]]
    is_count <- grepl("^n = ", mcell)
    rows[[length(rows) + 1L]] <- data.frame(
      printed_row = r,
      section_as_published  = section[k],
      variable_as_published = trimws(lab),
      group_as_published    = grp_hdr[[g]],
      group_label           = grp_lbl[g],
      group_code            = names(grp_hdr)[g],
      is_control            = names(grp_hdr)[g] == "NIG",
      n_group               = grp_n[g],
      mean_printed          = if (is_count) NA_character_ else mcell,
      sd_printed            = sdcell,
      count_printed         = if (is_count) mcell else NA_character_,
      mean                  = if (is_count) NA_real_ else num(mcell),
      sd                    = num(sdcell),
      count                 = if (is_count) as.numeric(sub("^n = ([0-9]+).*", "\\1", mcell)) else NA_real_,
      percent               = if (is_count) as.numeric(sub(".*\\(([0-9.]+)%\\).*", "\\1", mcell)) else NA_real_,
      unit_as_printed       = if (is_count) "No. (%)" else unit_of(trimws(lab), section[k]),
      test_statistic_printed = stat_txt,
      test_statistic_type    = if (grepl("^chi", stat_txt)) "chi-square (df = 1)" else "F",
      test_statistic         = num(sub("^chi\\^2_1 = ", "", stat_txt)),
      p_value                = num(snap[r, 7]),
      footnote_marks         = ifelse(grepl("\\^a", stat_txt), "a", NA_character_),
      stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, rows)
final.dataframe$species_as_published <- "children"   # caption: "Children Reared in Institutions and Community Control Subjects"
final.dataframe$is_volume <- final.dataframe$variable_as_published %in%
  c("Intracranial Volume", "Cerebral Gray Matter", "Cortical Gray Matter")
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 20L, sum(final.dataframe$is_volume) == 6L)

## ---- table checks (HOWTO section 7a) ----------------------------------------
## The Female row prints a count and its percentage of the group n printed in
## the spanning header: percent = 100 x count / n, compared at the printed one
## decimal (tolerance 0.05 + a recomputation unit).
fem <- final.dataframe[!is.na(final.dataframe$count), ]
obs <- 100 * fem$count / fem$n_group
table_checks <- data.frame(
  check_id   = paste0("female_percent_", fem$group_code),
  basis      = paste0("Female, No. (%) row: 100 x count / group n (n from the printed header '",
                      fem$group_as_published, "')"),
  observed   = round(obs, 3),
  printed    = fem$percent,
  difference = round(obs - fem$percent, 3),
  tolerance  = 0.05,
  status     = ifelse(abs(obs - fem$percent) <= 0.05, "pass", "mismatch"),
  note       = "percent printed to one decimal; half a unit of the last printed decimal",
  stringsAsFactors = FALSE)
tc_n <- data.frame(check_id = "group_n_sum", basis = "EIG n + NIG n vs caption total n = 80",
                   observed = sum(grp_n),
                   printed = as.numeric(sub(".*\\(n = ([0-9]+)\\)$", "\\1", snap[1, 1])),
                   difference = NA_real_, tolerance = 0, status = NA_character_,
                   note = "exact", stringsAsFactors = FALSE)
tc_n$difference <- tc_n$observed - tc_n$printed
tc_n$status <- ifelse(tc_n$difference == 0, "pass", "mismatch")
table_checks <- rbind(table_checks, tc_n)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) warning(item_name, ": table check mismatch - see table_checks", call. = FALSE)

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
