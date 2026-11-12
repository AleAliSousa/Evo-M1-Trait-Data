# Salvesen_etal_2015_text.R ----------------------------------------------------
#
# Salvesen et al. (2015) Neurobiol Dis 74:104-113. doi:10.1016/j.nbd.2014.11.008
# Regional volumes printed ONLY in the Results text (journal p. 110, PDF p. 7,
# subsections Putamen / Caudate nucleus / Globus pallidus / Subthalamic nucleus /
# Red nucleus). No table carries them.
#
# Reads the constructed, frozen snapshot Salvesen_etal_2015_text_snapshot.csv (written
# by Salvesen_etal_2015_text_snapshot.R from the text layer; one row per region x
# group, with the source sentence verbatim). Cleaning:
#   - mean and range parsed to numbers; unit converted to the project unit mm3
#     (cm3 x 1000; mm3 x 1);
#   - group phrase standardised to the Table 4 labels ("control subjects"/"control
#     brains" -> Controls; "MSA brains" -> MSA), printed phrase kept;
#   - region name mapped to the Table 4 area code via Table 4's own footnote, and n per
#     group taken from the frozen Table 1 snapshot.
# No value is typed in this script. SN volume is not reported anywhere in the paper.

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
paper <- sub("_text$", "", item_name)
snap <- read.csv(paste0(base, "_snapshot.csv"), stringsAsFactors = FALSE, encoding = "UTF-8",
                 colClasses = "character")
stopifnot(nrow(snap) == 10L)

t4 <- read_snap(paste0(paper, "_Table4_snapshot.xlsx"), "Table4")
foot <- t4[49, 1]
pairs <- regmatches(foot, gregexpr("\\b([A-Z]{2,3}) = ([a-z ]+?)(?=,|\\.$)", foot, perl = TRUE))[[1]]
abbr <- setNames(sub(" = .*$", "", pairs), sub("^[A-Z]+ = ", "", pairs))      # name -> code
t1 <- read_snap(paste0(paper, "_Table1_snapshot.xlsx"), "Table1")
span <- t1[3, ]; for (j in 2:7) if (!nzchar(span[j])) span[j] <- span[j - 1]

grp <- ifelse(grepl("^control", snap$group_as_printed), "Controls",
       ifelse(snap$group_as_printed == "MSA brains", "MSA", NA))
stopifnot(!anyNA(grp))
n_of <- function(region, g) {
  j <- which(grepl(region, tolower(span), fixed = TRUE) & sub("\\^a$", "", t1[4, ]) == g)
  stopifnot(length(j) == 1L); as.integer(sub("^n = ", "", t1[5, j])) }
to_mm3 <- c("cm\u00b3" = 1000, "mm\u00b3" = 1)              # cm3 x 1000 = mm3
fac <- unname(to_mm3[snap$mean_unit_as_printed]); stopifnot(!anyNA(fac))
rg  <- strsplit(sub(" [cm]m\u00b3$", "", snap$range_as_printed), "\u2013")
stopifnot(all(sub("^.* ", "", snap$range_as_printed) == snap$mean_unit_as_printed))
mean_num <- as.numeric(sub("^=", "", snap$mean_as_printed))

final.dataframe <- data.frame(
  text_row = as.integer(snap$text_row),
  journal_page = as.integer(snap$journal_page),
  results_subsection = snap$results_subsection,
  region_as_printed = snap$region_as_printed,
  area_code_Table4 = unname(abbr[snap$region_as_printed]),
  group_as_printed = snap$group_as_printed,
  Group = grp,
  is_healthy_control = as.integer(grp == "Controls"),
  n_subjects = mapply(n_of, snap$region_as_printed, grp, USE.NAMES = FALSE),
  volume_as_printed = paste(snap$mean_as_printed, snap$mean_unit_as_printed),
  range_as_printed = snap$range_as_printed,
  volume_mean.mm3 = mean_num * fac,
  volume_min.mm3 = as.numeric(sapply(rg, `[`, 1)) * fac,
  volume_max.mm3 = as.numeric(sapply(rg, `[`, 2)) * fac,
  p_value_MSA_vs_Controls = as.numeric(snap$p_value_as_printed),
  comparison_text_as_printed = snap$comparison_text_as_printed,
  tissue_basis = paste0(snap$qualifier_as_printed, "; Cavalieri volume uncorrected for shrinkage (Methods p. 105)"),
  hemisphere_basis = "bilateral (inferred: not stated beside the volumes; Table 4 bilateral N / Nv reproduces them)",
  species_as_published = "human",
  Species = "Homo sapiens",
  note = NA_character_,
  stringsAsFactors = FALSE)
pu <- final.dataframe$region_as_printed == "putamen" & final.dataframe$Group == "Controls"
final.dataframe$note[pu] <- "Printed '=4.9 cm3' (stray '=' kept in volume_as_printed)."
stopifnot(!anyNA(final.dataframe$volume_mean.mm3), !anyNA(final.dataframe$area_code_Table4))

## consistency message (not a printed relation, so not a table check): volume implied
## by Table 4 bilateral neuron number / neuron density (ratio of group means).
d4 <- which(t4[, 1] == "Density/mm\u00b3"); n4 <- which(t4[, 1] == "Total cell numbers")
mant <- function(x) as.numeric(sub(" \u00d7 10.*$", "", x))
for (r in which(final.dataframe$Group == "Controls")) {
  code <- final.dataframe$area_code_Table4[r]
  iN <- n4 + which(t4[(n4 + 1):(n4 + 6), 2] == code); iV <- d4 + which(t4[(d4 + 1):(d4 + 6), 2] == code)
  implied <- mant(t4[iN, 3]) * 1e6 / (mant(t4[iV, 3]) * 1e3)
  message(sprintf("%s: %s controls volume %.1f mm3 printed vs %.1f mm3 implied by Table 4 neurons N/Nv",
                  item_name, code, final.dataframe$volume_mean.mm3[r], implied))
}

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
