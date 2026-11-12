# Salvesen_etal_2015_Table1.R --------------------------------------------------
#
# Salvesen et al. (2015) Neurobiol Dis 74:104-113. doi:10.1016/j.nbd.2014.11.008
# Table 1 "Demographic and autopsy-related data." (journal p. 105, PDF p. 2)
#
# Reads the frozen snapshot (Salvesen_etal_2015_Table1_snapshot.xlsx, written by
# Salvesen_etal_2015_Table1_snapshot.R). One analysis row per printed column
# (3 assessment sets x 2 groups = 6 rows): mean and [range] split into numbers,
# "a/b" counts split (male/female; left/right hemisphere), "NA" kept as missing.
# Checks n = male + female and n = left + right (table_checks).
# No table value is typed in this script.
#
# Disease paper: "Controls" = neurologically healthy controls; "MSA" = multiple system
# atrophy. The stereology (Table 4) uses the first two column pairs; the qRT-PCR pair
# (n = 14 / 10) is a different tissue-sample set.

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
stopifnot(nrow(snap) == 13L, ncol(snap) == 7L)
labs <- c("Age (years)", "Male/female", "PMI (hours)", "Hemisphere (left/right)", "Hemisphere weight (g)")
stopifnot(identical(snap[6:10, 1], labs))
span <- snap[3, ]; for (j in 2:7) if (!nzchar(span[j])) span[j] <- span[j - 1]

mean_of <- function(x) suppressWarnings(ifelse(x == "NA", NA_real_, as.numeric(sub(" \\[.*$", "", x))))
rng <- function(x, k) suppressWarnings(ifelse(x == "NA", NA_real_,
  as.numeric(sapply(strsplit(sub("^.*\\[(.*)\\]$", "\\1", x), "\u2013"), `[`, k))))
part <- function(x, k) suppressWarnings(ifelse(x == "NA", NA_integer_, as.integer(sapply(strsplit(x, "/"), `[`, k))))

j <- 2:7
grp <- sub("\\^a$", "", snap[4, j])
final.dataframe <- data.frame(
  printed_column = j,
  assessment_set_as_printed = gsub("\n", "; ", span[j]),
  group_as_printed = snap[4, j],
  Group = grp,
  is_healthy_control = as.integer(grp == "Controls"),
  footnote_mark = ifelse(grepl("\\^a$", snap[4, j]), "a", NA_character_),
  n_subjects = as.integer(sub("^n = ", "", snap[5, j])),
  age_as_printed = snap[6, j],
  age_mean.years = mean_of(snap[6, j]), age_min.years = rng(snap[6, j], 1), age_max.years = rng(snap[6, j], 2),
  n_male = part(snap[7, j], 1), n_female = part(snap[7, j], 2),
  pmi_as_printed = snap[8, j],
  pmi_mean.h = mean_of(snap[8, j]), pmi_min.h = rng(snap[8, j], 1), pmi_max.h = rng(snap[8, j], 2),
  n_left_hemisphere = part(snap[9, j], 1), n_right_hemisphere = part(snap[9, j], 2),
  hemisphere_weight_as_printed = snap[10, j],
  # fixed hemisphere weight, g as printed (g is the project unit for body mass; kept as g here)
  hemisphere_weight_mean.g = mean_of(snap[10, j]),
  hemisphere_weight_min.g = rng(snap[10, j], 1), hemisphere_weight_max.g = rng(snap[10, j], 2),
  species_as_published = "human",
  Species = "Homo sapiens",
  stringsAsFactors = FALSE)
final.dataframe$note <- ifelse(!is.na(final.dataframe$footnote_mark),
  "Footnote a: some samples were omitted from different assessments due to technical artifacts or lack of tissue.",
  NA_character_)
final.dataframe$note[final.dataframe$printed_column %in% 6:7] <- "qRT-PCR tissue-sample set (cell-marker mRNA), not the stereology set; hemisphere data printed NA."

## ---- table checks (HOWTO 7a): counts add up to n ------------------------------
ck <- function(id, what, a, b) {
  obs <- a + b
  data.frame(check_id = paste0(id, "_col", j), basis = paste0("Table 1 column ", j, " (", snap[4, j], "): ", what),
             observed = obs, printed = final.dataframe$n_subjects, difference = obs - final.dataframe$n_subjects,
             tolerance = 0, status = ifelse(is.na(obs), "not_evaluable", ifelse(obs == final.dataframe$n_subjects, "pass", "mismatch")),
             note = ifelse(is.na(obs), "cell printed NA", NA_character_), stringsAsFactors = FALSE)
}
table_checks <- rbind(ck("sex_sum", "male + female = n", final.dataframe$n_male, final.dataframe$n_female),
                      ck("hemisphere_sum", "left + right = n", final.dataframe$n_left_hemisphere, final.dataframe$n_right_hemisphere))
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
for (i in which(table_checks$status == "mismatch")) warning(table_checks$check_id[i], ": ", table_checks$basis[i], call. = FALSE)

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
