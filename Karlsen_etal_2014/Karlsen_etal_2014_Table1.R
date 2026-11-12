# Karlsen_etal_2014_Table1.R ---------------------------------------------------
#
# Karlsen AS, Korbo S, Uylings HBM, Pakkenberg B (2014). Neuroscience 279:253-259.
# doi:10.1016/j.neuroscience.2014.08.046
# Table 1 "Clinical details of the individual subjects" (journal p. 254, PDF p. 2)
#
# Reads the frozen snapshot (Karlsen_etal_2014_Table1_snapshot.xlsx, written by
# Karlsen_etal_2014_Table1_snapshot.R). One analysis row per printed row: 10 subjects
# (row_type = "individual") plus the 2 printed "Mean" rows (row_type = "printed_mean").
# Footnote marks split from Cause of death; PMD "hh:mm" converted to decimal hours;
# printed "-" = not available. Re-computes each printed Mean from the individuals
# (table_checks). No table value is typed in this script.
#
# Disease paper: "Controls" = neurologically healthy female controls; "DS" = Down
# syndrome. All subjects are female (Methods p. 254: "four females with DS" and
# "six female controls").

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
paper <- sub("_Table4$", "", item_name)

suppressPackageStartupMessages(library(readxl))

read_snap <- function(file, sheet) {
  m <- as.matrix(read_excel(file, sheet = sheet, col_names = FALSE, col_types = "text",
                            .name_repair = "minimal"))
  m[is.na(m)] <- ""; dimnames(m) <- NULL; m
}
snap <- read_snap(paste0(base, "_snapshot.xlsx"), "Table1")
stopifnot(nrow(snap) == 18L, ncol(snap) == 8L)
stopifnot(identical(snap[2, 2:7], c("Age (years)", "Height (cm)", "Hemisphere (g)", "Country",
                                    "Cause of death", "PMD (h)^*")))
rows <- which(grepl("^[0-9.]+$", snap[, 2]))
stopifnot(length(rows) == 12L)
grp <- rep(NA_character_, nrow(snap)); cur <- NA_character_
for (i in seq_len(nrow(snap))) { if (snap[i, 1] %in% c("Controls", "DS")) cur <- snap[i, 1]; grp[i] <- cur }
num <- function(x) suppressWarnings(as.numeric(ifelse(x %in% c("-", ""), NA, x)))
pmd_h <- function(x) ifelse(nzchar(x), suppressWarnings(as.numeric(sub(":.*$", "", x)) + as.numeric(sub("^.*:", "", x)) / 60), NA_real_)
is_mean <- snap[rows, 1] == "Mean"
subj <- ave(seq_along(rows), grp[rows], FUN = seq_along); subj[is_mean] <- NA
final.dataframe <- data.frame(
  printed_row = rows,
  Group = grp[rows],
  is_healthy_control = as.integer(grp[rows] == "Controls"),
  row_type = ifelse(is_mean, "printed_mean", "individual"),
  subject_in_group = subj,
  sex = "female",
  age.years = num(snap[rows, 2]),
  height_as_printed = snap[rows, 3],
  height.cm = num(snap[rows, 3]),
  # fixed hemisphere weight, g as printed
  hemisphere_weight.g = num(snap[rows, 4]),
  country_as_printed = snap[rows, 5],
  cause_of_death_as_printed = sub("\\^\\*+$", "", snap[rows, 6]),
  cause_of_death_footnote = ifelse(grepl("\\^\\*", snap[rows, 6]), sub("^.*\\^", "", snap[rows, 6]), NA_character_),
  PMD_as_printed = snap[rows, 7],
  PMD.h = pmd_h(snap[rows, 7]),
  braak_score = num(snap[rows, 8]),
  species_as_published = "human",
  Species = "Homo sapiens",
  note = NA_character_,
  stringsAsFactors = FALSE)
final.dataframe$note[is_mean] <- "Printed group mean row, not a subject; filter row_type == 'individual' for subject-level use."
ds_mean <- final.dataframe$Group == "DS" & is_mean
final.dataframe$note[ds_mean] <- paste(final.dataframe$note[ds_mean],
  "Height and Hemisphere means do not match the printed DS individuals; they equal the DS Mean row of Karlsen & Pakkenberg 2011 Table 1 (errata Karlsen_etal_2014-E001, -E002).")
ds_pmd <- final.dataframe$Group == "DS" & !is_mean & final.dataframe$subject_in_group %in% 2:4
final.dataframe$note[ds_pmd] <- "PMD differs from the same DS brain in Karlsen & Pakkenberg 2011 Table 1 (the DS PMD column appears shifted by one row); see errata Karlsen_etal_2014-E003 to -E005."
stopifnot(sum(final.dataframe$row_type == "individual") == 10L)

## ---- table checks (HOWTO 7a): each printed Mean vs the individuals ------------
## Dashes are not zeros: "-" heights are left out of the mean. Tolerance = half a
## unit in the printed Mean's last decimal.
hu <- function(txt) { dec <- ifelse(grepl("\\.", txt), nchar(sub("^[^.]*\\.", "", txt)), 0); 0.5 * 10^(-dec) }
what <- c(NA, "age", "height", "hemisphere")
chk <- list()
for (g in c("Controls", "DS")) {
  ind  <- rows[grp[rows] == g & snap[rows, 1] != "Mean"]
  mrow <- rows[grp[rows] == g & snap[rows, 1] == "Mean"]
  for (k in 2:4) {
    v <- num(snap[ind, k]); obs <- mean(v, na.rm = TRUE); prt <- as.numeric(snap[mrow, k]); tol <- hu(snap[mrow, k])
    chk[[length(chk) + 1]] <- data.frame(
      check_id = paste0("mean_", g, "_", what[k]),
      basis = paste0("Table 1 ", g, ": mean of the printed individual '", snap[2, k], "' values vs the printed Mean"),
      observed = round(obs, 3), printed = prt, difference = round(obs - prt, 3), tolerance = tol,
      status = ifelse(abs(obs - prt) <= tol + 1e-9, "pass", "mismatch"),
      note = if (any(is.na(v))) paste0(sum(is.na(v)), " cell(s) printed '-' left out (n = ", sum(!is.na(v)), ")") else NA_character_,
      stringsAsFactors = FALSE)
  }
}
table_checks <- do.call(rbind, chk)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
for (i in which(table_checks$status == "mismatch"))
  warning(sprintf("%s: observed %.3f vs printed %.1f", table_checks$check_id[i], table_checks$observed[i],
                  table_checks$printed[i]), call. = FALSE)

## ---- outputs ----------------------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) ---------------------------
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
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t",
              row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
