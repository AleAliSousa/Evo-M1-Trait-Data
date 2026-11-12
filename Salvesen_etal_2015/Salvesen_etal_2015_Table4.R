# Salvesen_etal_2015_Table4.R --------------------------------------------------
#
# Salvesen L, Ullerup BH, Sunay FB, Brudek T, Lokkegaard A, Agander TK, Winge K,
# Pakkenberg B (2015). Changes in total cell numbers of the basal ganglia in patients
# with multiple system atrophy - a stereological study. Neurobiol Dis 74:104-113.
# doi:10.1016/j.nbd.2014.11.008
# Table 4 "Numerical estimations of the different cell types in the basal ganglia and
# red nucleus of patients with MSA and control subjects." (journal p. 108, PDF p. 5)
#
# Reads the frozen snapshot (Salvesen_etal_2015_Table4_snapshot.xlsx, written by
# Salvesen_etal_2015_Table4_snapshot.R) and does all the cleaning:
#   - one analysis row per printed row x group (Controls / MSA): 42 x 2 = 84 rows;
#   - forward-fills the printed cell-type label and section ("Total cell numbers",
#     "Density/mm3"); expands the area abbreviations from the table's own footnote;
#   - parses "188.4 x 10^6" into the printed mantissa and the absolute value
#     (project units: cells, or cells per mm3 of paraffin-embedded tissue);
#   - splits the p-value cell into qualifier ("<"), number and test (footnote: * Student's
#     t-test, ** Mann-Whitney U); signs the printed percent change from its arrow;
#   - takes n per group from the sibling frozen snapshot of Table 1 (the column
#     spanner lists which nuclei each n applies to);
#   - re-checks every printed percent change against the printed means (table_checks).
# No table value is typed in this script.
#
# Disease paper: Group "Controls" = neurologically healthy controls; "MSA" = multiple
# system atrophy. Both are kept, exactly as printed.

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
snap <- read_snap(paste0(base, "_snapshot.xlsx"), "Table4")
stopifnot(nrow(snap) == 50L, ncol(snap) == 8L)
stopifnot(identical(snap[3, ], c("", "Area", "Controls", "CV", "MSA", "CV", "p-values", "Percent change")))

## ---- printed structure -------------------------------------------------------
is_data <- snap[, 2] %in% c("SN", "PU", "CN", "GP", "STN", "RN")
stopifnot(sum(is_data) == 42L)
section <- cell_type <- rep(NA_character_, nrow(snap))
cur_s <- cur_c <- NA_character_
for (i in seq_len(nrow(snap))) {
  if (snap[i, 1] %in% c("Total cell numbers", "Density/mm\u00b3")) { cur_s <- snap[i, 1]; cur_c <- NA }
  if (is_data[i] && nzchar(snap[i, 1])) cur_c <- snap[i, 1]
  section[i] <- cur_s; cell_type[i] <- cur_c
}
## area names from the table's own footnote ("CN = caudate nucleus, ...")
foot <- snap[49, 1]
pairs <- regmatches(foot, gregexpr("\\b([A-Z]{2,3}) = ([a-z ]+?)(?=,|\\.$)", foot, perl = TRUE))[[1]]
abbr <- setNames(sub("^[A-Z]+ = ", "", pairs), sub(" = .*$", "", pairs))
stopifnot(all(c("SN", "PU", "CN", "GP", "STN", "RN") %in% names(abbr)))

## ---- n per group, from the frozen Table 1 snapshot ----------------------------
t1 <- read_snap(paste0(paper, "_Table1_snapshot.xlsx"), "Table1")
span <- t1[3, ]; for (j in 2:7) if (!nzchar(span[j])) span[j] <- span[j - 1]
n_of <- function(area, grp) {
  full <- abbr[[area]]
  j <- which(grepl(full, tolower(span), fixed = TRUE) & sub("\\^a$", "", t1[4, ]) == grp)
  stopifnot(length(j) == 1L)
  as.integer(sub("^n = ", "", t1[5, j]))
}

## ---- cell parsers ------------------------------------------------------------
X <- "\u00d7"
mant <- function(x) as.numeric(sub(paste0(" ", X, " 10.*$"), "", x))
mult <- function(x) ifelse(grepl("10\u2076$", x), 1e6, ifelse(grepl("10\u00b3$", x), 1e3, NA))
p_q  <- function(x) ifelse(startsWith(x, "<"), "<", "")
p_num <- function(x) as.numeric(gsub("[<*]", "", x))
p_test <- function(x) ifelse(grepl("\\*\\*$", x), "Mann-Whitney U test",
                       ifelse(grepl("\\*$", x), "Student's t-test", NA_character_))
pct <- function(x) ifelse(nzchar(x), as.numeric(sub("%.*$", "", x)) *
                            ifelse(grepl("\u2193", x), -1, 1), NA_real_)

d <- which(is_data)
mk <- function(grp, vcol, cvcol) {
  v <- snap[d, vcol]
  measure <- ifelse(section[d] == "Total cell numbers", "total_number", "numerical_density")
  data.frame(
    printed_row = d,
    section_as_printed = section[d],
    cell_type_as_printed = cell_type[d],
    area_as_printed = snap[d, 2],
    area_name_from_footnote = unname(abbr[snap[d, 2]]),
    measure = measure,
    Group = grp,
    is_healthy_control = as.integer(grp == "Controls"),
    n_subjects = mapply(n_of, snap[d, 2], grp, USE.NAMES = FALSE),
    value_as_printed = v,
    value_mantissa = mant(v),
    value_multiplier = mult(v),
    # project units: absolute cell number (cells) or cells per mm3; = mantissa x multiplier
    value = mant(v) * mult(v),
    unit = ifelse(measure == "total_number", "cells", "cells per mm3"),
    CV = as.numeric(snap[d, cvcol]),
    p_value_as_printed = snap[d, 7],
    p_value_qualifier = p_q(snap[d, 7]),
    p_value = p_num(snap[d, 7]),
    p_value_test = p_test(snap[d, 7]),
    percent_change_as_printed = snap[d, 8],
    percent_change_MSA_vs_Controls = pct(snap[d, 8]),
    hemisphere_basis = "bilateral (one hemisphere counted, x2)",
    tissue_basis = "paraffin-embedded; reference volume uncorrected for shrinkage",
    species_as_published = "human",
    Species = "Homo sapiens",
    note = NA_character_,
    stringsAsFactors = FALSE)
}
final.dataframe <- rbind(mk("Controls", 3, 4), mk("MSA", 5, 6))
final.dataframe <- final.dataframe[order(final.dataframe$printed_row, final.dataframe$Group != "Controls"), ]
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 84L, !anyNA(final.dataframe$value), !anyNA(final.dataframe$CV))

## per-row notes: the paper's own precision caveat (Statistics, p. 108)
mg <- final.dataframe$cell_type_as_printed == "Microglia"
final.dataframe$note[mg] <- "Authors: CE for microglia exceeded half the CV (suboptimal precision); evaluate with this limitation (Statistics, p. 108)."
rn_a <- final.dataframe$cell_type_as_printed == "Astrocytes" & final.dataframe$area_as_printed == "RN" &
        final.dataframe$Group == "MSA"
final.dataframe$note[rn_a] <- "Authors: CE for astrocytes in the red nucleus of MSA patients exceeded half the CV (suboptimal precision) (Statistics, p. 108)."
sn <- final.dataframe$area_as_printed == "SN"
final.dataframe$note[sn] <- "Substantia nigra: pigmented neurons only (Introduction, p. 105); no glia counted in SN."

## ---- table checks (HOWTO 7a): printed percent change vs printed means ---------
## percent change = 100 x (MSA - Controls) / Controls. The printed means are rounded,
## so the check allows the full interval the rounded cells can produce (each mean
## +/- half a unit in its last printed decimal), plus half a unit of the printed
## whole-number percentage. Rows with no printed percent are not checked.
half_unit <- function(txt) { s <- sub(paste0(" ", X, ".*$"), "", txt)
  dec <- ifelse(grepl("\\.", s), nchar(sub("^[^.]*\\.", "", s)), 0); 0.5 * 10^(-dec) }
pr <- d[nzchar(snap[d, 8])]
C <- mant(snap[pr, 3]); M <- mant(snap[pr, 5]); hc <- half_unit(snap[pr, 3]); hm <- half_unit(snap[pr, 5])
obs <- 100 * (M - C) / C
lo  <- 100 * ((M - hm) - (C + hc)) / (C + hc)
hi  <- 100 * ((M + hm) - (C - hc)) / (C - hc)
prt <- pct(snap[pr, 8])
table_checks <- data.frame(
  check_id   = paste0("percent_change_row", pr, "_", gsub("[^A-Za-z]", "", cell_type[pr]), "_", snap[pr, 2],
                      ifelse(section[pr] == "Total cell numbers", "_N", "_Nv")),
  basis      = paste0("Table 4 row ", pr, " (", section[pr], ", ", cell_type[pr], ", ", snap[pr, 2],
                      "): 100 x (MSA - Controls)/Controls vs printed Percent change"),
  observed   = round(obs, 2), printed = prt, difference = round(obs - prt, 2),
  tolerance  = round(pmax(obs - lo, hi - obs) + 0.5, 2),
  status     = ifelse(prt >= lo - 0.5 & prt <= hi + 0.5, "pass", "mismatch"),
  note       = paste0("admissible interval from rounded means: [", round(lo, 1), ", ", round(hi, 1), "]%"),
  stringsAsFactors = FALSE)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
for (i in which(table_checks$status == "mismatch"))
  warning(sprintf("%s: observed %.2f vs printed %.0f (%s)", table_checks$check_id[i],
                  table_checks$observed[i], table_checks$printed[i], table_checks$note[i]), call. = FALSE)

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
