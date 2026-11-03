# Holliday_etal_1967_TableIII.R ------------------------------------------------
#
# Holliday, Potter, Jarrah & Bearg (1967), Pediatric Research 1: 185-195. Table III
# "Relation of organ weight to body weight in 9 species (Data from BRODY [8])", p. 191.
# SECONDARY compilation: all values are Brody (1945), Bioenergetics and Growth. No metabolic
# rate is tabulated (organ weights only); the table is the weight basis used with Table II.
#
# Reads the frozen snapshot (Holliday_etal_1967_TableIII_snapshot.csv; species printed as
# columns, organs as rows) and:
#   - writes one analysis row per printed species (9 rows), organ weights in columns;
#   - keeps the printed species name (Dog, Guinea pig, Hog, Horse, Human, Monkey, Rat,
#     Sheep, Steer) and resolves it through _keys/General/species_key.csv;
#   - converts body weight kg -> g and brain weight g -> mg (project units); strips the
#     thousands commas of "20,340" / "13,700";
#   - ref_key = "[8]" (Brody) on every row (the caption cites it for the whole table);
#   - checks the printed totals and the printed ratio (table_checks, HOWTO 7a). Printed
#     arithmetic is not corrected: Hog total prints 3890 (the five organs add to 3870).
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
base  <- item_name
paper <- basename(folder)
locus <- sub(paste0("^", paper, "_"), "", item_name)

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## repo root (holds __ReadMe.xlsx) and the General species key for this paper folder
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"), colClasses = "character",
                na.strings = character(0), encoding = "UTF-8")
key <- key[key$source_publication == paper, ]
if (!nrow(key)) stop("no rows for ", paper, " in _keys/General/species_key.csv", call. = FALSE)
species_cols <- function(printed) {
  i <- match(printed, key$variant_name)
  if (anyNA(i)) stop("species not in key: ", paste(unique(printed[is.na(i)]), collapse = "; "), call. = FALSE)
  data.frame(species_as_published = printed, species_accepted = key$accepted_name[i],
             ncbi_taxid = key$ncbi_taxid[i], stringsAsFactors = FALSE)
}
## half unit of the last printed decimal of a printed number string
hu <- function(s) { s <- gsub("[^0-9.]", "", s); d <- ifelse(grepl("\\.", s), nchar(sub("^.*\\.", "", s)), 0L); 0.5 * 10^(-d) }

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
  tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
  message(item_name, ": table checks  pass=", tally[[1]], "  mismatch=", tally[[2]], "  not_evaluable=", tally[[3]])
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}
UMOL_PER_ML_O2 <- 44.64          # umol O2 per mL O2 (22.4 L/mol at STP: 1000/22.4)

code_src <- "10.1203/00006450-196705000-00005"

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(14L, 10L)), snap[2, 1] == "Organ", snap[4, 1] == "Brain", snap[8, 1] == "Lung", snap[10, 1] == "Total",
          snap[11, 2] == "Body weight (kg)", grepl("^Sum of total organ wt", snap[13, 1]))
cols <- 2:10
species <- gsub("\n", " ", snap[2, cols], fixed = TRUE)
nm <- function(x) suppressWarnings(as.numeric(gsub(",", "", x)))
sp <- species_cols(species)
final.dataframe <- data.frame(
  printed_column = cols, sp, ref_key = "[8]",
  brain_g_printed = snap[4, cols], heart_g_printed = snap[5, cols], kidneys_g_printed = snap[6, cols],
  liver_g_printed = snap[7, cols], lung_g_printed = snap[8, cols], total_organ_g_printed = snap[10, cols],
  body_weight_kg_printed = snap[12, cols], organ_pct_body_printed = snap[14, cols], stringsAsFactors = FALSE)
final.dataframe$brain_g   <- nm(final.dataframe$brain_g_printed)
final.dataframe$heart_g   <- nm(final.dataframe$heart_g_printed)
final.dataframe$kidneys_g <- nm(final.dataframe$kidneys_g_printed)
final.dataframe$liver_g   <- nm(final.dataframe$liver_g_printed)
final.dataframe$lung_g    <- nm(final.dataframe$lung_g_printed)
final.dataframe$total_organ_g <- nm(final.dataframe$total_organ_g_printed)
final.dataframe$body_weight_kg <- nm(final.dataframe$body_weight_kg_printed)
final.dataframe$organ_pct_body <- nm(final.dataframe$organ_pct_body_printed)
final.dataframe$body_mass_g <- final.dataframe$body_weight_kg * 1000
final.dataframe$brain_mass_mg <- final.dataframe$brain_g * 1000
final.dataframe$sum_5_organs_g_recomputed <- rowSums(final.dataframe[, c("brain_g", "heart_g", "kidneys_g", "liver_g", "lung_g")])
final.dataframe$organ_pct_body_recomputed <- round(100 * final.dataframe$total_organ_g / final.dataframe$body_mass_g, 3)
final.dataframe$unit_as_printed <- "organ weight g; body weight kg; ratio = sum of total organ wt / body weight x 100 (%)"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$sum_5_organs_g_recomputed != final.dataframe$total_organ_g &
                     abs(final.dataframe$sum_5_organs_g_recomputed - final.dataframe$total_organ_g) > 0.25] <- "printed total differs from the sum of the five printed organ weights (see table_checks / README)"
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 9L, !anyNA(final.dataframe[, c("brain_g", "lung_g", "total_organ_g", "body_weight_kg", "organ_pct_body")]))

## ---- table checks (HOWTO section 7a) ---------------------------------------------
## (a) the five organ weights add to the printed Total (half a unit of the last printed
## decimal per summed cell and of the total); (b) the printed ratio = 100 x printed Total /
## body weight, within one unit of its last printed decimal (HOWTO 7a).
d <- final.dataframe; pc <- c("brain_g_printed", "heart_g_printed", "kidneys_g_printed", "liver_g_printed", "lung_g_printed")
table_checks <- rbind(
  do.call(rbind, lapply(seq_len(nrow(d)), function(i)
    chk(paste0("total_", gsub(" ", "_", d$species_as_published[i])), paste0(d$species_as_published[i], ": sum of Brain..Lung vs printed Total (g)"),
        d$sum_5_organs_g_recomputed[i], d$total_organ_g[i], sum(sapply(unlist(d[i, pc]), hu)) + hu(d$total_organ_g_printed[i]),
        if (d$species_as_published[i] == "Hog") "printed 3890; the five organs (120 + 350 + 500 + 1600 + 1300) add to 3870" else NA_character_))),
  do.call(rbind, lapply(seq_len(nrow(d)), function(i)
    chk(paste0("ratio_", gsub(" ", "_", d$species_as_published[i])), paste0(d$species_as_published[i], ": 100 x printed Total / body weight vs printed ratio"),
        d$organ_pct_body_recomputed[i], d$organ_pct_body[i], 2 * hu(d$organ_pct_body_printed[i]))))
)
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not yet
## registered, the code is derived exactly as the registry formula builds it (DOI / col-C
## alternative code with "/" and ":" percent-encoded, "_", item locus); the registry
## stays the authority (rename the TSV if it differs after the owner pastes the row).
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(gsub(":", "%3A", gsub("/", "%2F", code_src, fixed = TRUE), fixed = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ", item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
