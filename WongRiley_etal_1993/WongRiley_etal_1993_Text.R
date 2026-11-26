# WongRiley_etal_1993_Text.R --------------------------------------------------
#
# Wong-Riley, Hevner, Cutlan, Earnest, Egan, Frost & Nguyen (1993), Visual
# Neuroscience 10: 41-58. Values printed only in running text (METHODS p. 42,
# RESULTS pp. 42-49, DISCUSSION p. 56). The paper prints no table and no
# densitometric plot; laminar cytochrome-oxidase (CO) activity is quantified
# ONLY as percent optical-density differences between IVcα and IVcβ (newborn,
# 4-month, adult); all other laminar CO statements are ordinal (see README).
#
# Reads the constructed, frozen snapshot WongRiley_etal_1993_Text_snapshot.csv
# (one row per printed value lexeme, written by WongRiley_etal_1993_Text_snapshot.R)
# and does all the cleaning:
#   - value_printed parsed: a single value -> value_numeric; a printed range
#     "a-b" -> value_low / value_high (value_numeric NA) plus range_midpoint
#     (DERIVED, not printed); "two" -> 2;
#   - lengths harmonised to mm (value_mm / value_low_mm / value_high_mm) from
#     printed µm, mm, cm; densities stay puffs/mm2; percentages stay %;
#   - measure code per quantity (Thickness.mm, Length.mm, Density.puffs_per_mm2,
#     CO_OD.pct_difference, Age, n, method);
#   - CO rows: lower_layer / reference_layer and the derived ratio
#     OD_ratio_lower_over_reference = 1 - pct/100 (low/high for the range);
#   - value_status: method / demographic / new / restatement / cited /
#     unpublished_own; data_role secondary for cited values (other papers'
#     numbers quoted for comparison), primary otherwise;
#   - species_as_published keeps the paper's wording (human / man / macaque
#     monkey / macaque / monkey / squirrel monkey); Species is the accepted name
#     from _keys/General/species_key.csv (rows for this folder);
#   - adult_flag marks the adult human V1/V2 rows (the project's interest).
# No printed value is typed in this script.

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

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 84L, identical(tx$text_row, as.character(1:84)))

## ---- species: printed name kept, accepted binomial from the collection key ----------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[species_key$source_publication == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk    <- setNames(species_key$accepted_name, tolower(species_key$variant_name))
lk_id <- setNames(species_key$ncbi_taxid,    tolower(species_key$variant_name))

## ---- parse printed lexemes ---------------------------------------------------------
word_num <- c(two = "2")
lex <- tx$value_printed
lex <- ifelse(tolower(lex) %in% names(word_num), word_num[tolower(lex)], lex)
is_range <- grepl("^[0-9.]+-[0-9.]+$", lex)
num_of <- function(x) suppressWarnings(as.numeric(x))
value_numeric <- ifelse(is_range, NA_real_, num_of(lex))
value_low     <- ifelse(is_range, num_of(sub("-.*$", "", lex)), NA_real_)
value_high    <- ifelse(is_range, num_of(sub("^.*-", "", lex)), NA_real_)
stopifnot(all(is_range | !is.na(value_numeric)))      # every lexeme parsed
range_midpoint <- ifelse(is_range, (value_low + value_high) / 2, NA_real_)

## ---- units ---------------------------------------------------------------------------
u <- tx$units_printed
to_mm <- c(`µm` = 1e-3, mm = 1, cm = 10)
unit_class <- ifelse(u %in% names(to_mm), "length",
              ifelse(u == "puffs/mm2", "density",
              ifelse(u == "% lower", "percent",
              ifelse(u %in% c("h", "years", "years of age", "weeks gestation", "days", "months", "weeks before birth"), "time",
              ifelse(u %in% c("adults", "newborns", "readings", "measurements"), "count",
              ifelse(u == "P value", "probability", "other"))))))
f_mm <- ifelse(unit_class == "length", to_mm[u], NA_real_)
value_mm      <- value_numeric * f_mm
value_low_mm  <- value_low  * f_mm
value_high_mm <- value_high * f_mm

## ---- measure code from the quantity ------------------------------------------------
q <- tx$quantity
measure <- ifelse(grepl("^CO optical density difference", q), "CO_OD.pct_difference",
           ifelse(grepl("thickness|laminar width", q), "Thickness.mm",
           ifelse(grepl("puff density", q), "Density.puffs_per_mm2",
           ifelse(grepl("diameter|width|height|dimension|spacing|extent|distance", q), "Length.mm",
           ifelse(q == "age" | grepl("^age at which", q), "Age",
           ifelse(q == "number of brains", "n", "method"))))))

## ---- provenance -----------------------------------------------------------------------
r <- as.integer(tx$text_row)
restates <- c(`74` = 49L, `75` = 50L, `78` = 55L, `79` = 57L, `83` = 52L)
value_status <- ifelse(r %in% 1:8, "method",
                ifelse(r %in% c(9:14, 28, 29), "demographic",
                ifelse(r %in% as.integer(names(restates)), "restatement",
                ifelse(r == 81L, "unpublished_own",
                ifelse(nzchar(tx$cited_ref) | r %in% c(76L, 77L), "cited", "new")))))
restates_text_row <- unname(restates[as.character(r)])
data_role <- ifelse(value_status == "cited", "secondary", "primary")

## species as the sentence names them: the parenthetical of region_as_printed, else "human"
sp_paren <- sub("^.*\\(([^)]*)\\)\\s*$", "\\1", tx$region_as_printed)
species_as_published <- ifelse(grepl("\\(", tx$region_as_printed) &
                                 tolower(sp_paren) %in% names(lk), sp_paren, "human")
Species    <- unname(lk[tolower(species_as_published)])
ncbi_taxid <- unname(lk_id[tolower(species_as_published)])
stopifnot(!anyNA(Species))

## n behind this paper's own values (METHODS p. 42): 24 adults, 1 fetus, 2 newborns,
## 1 infant at 24 days, 1 infant at 4 months
n_of_group <- c(adult = 24L, `fourth postnatal month` = 1L, `postnatal day 24` = 1L,
                `at birth` = 2L, `26 weeks of gestation` = 1L)
n <- ifelse(value_status %in% c("new", "restatement") & species_as_published %in% c("human", "man"),
            unname(n_of_group[tx$age_group_as_printed]), NA_integer_)

## CO optical-density rows: which sublayer is lower, relative to which, and the ratio
is_co <- measure == "CO_OD.pct_difference"
lower_layer     <- ifelse(is_co, trimws(sub(" vs .*$", "", tx$layer_as_printed)), NA_character_)
reference_layer <- ifelse(is_co, trimws(sub("^.* vs ", "", tx$layer_as_printed)), NA_character_)
OD_ratio_lower_over_reference      <- ifelse(is_co, 1 - value_numeric / 100, NA_real_)
OD_ratio_lower_over_reference_low  <- ifelse(is_co, 1 - value_high / 100, NA_real_)   # largest % -> lowest ratio
OD_ratio_lower_over_reference_high <- ifelse(is_co, 1 - value_low  / 100, NA_real_)

adult_flag <- tx$age_group_as_printed == "adult" & Species == "Homo sapiens"

final.dataframe <- data.frame(
  text_row = r, page = tx$page, section = tx$section, location = tx$location,
  passage_as_printed = tx$passage_as_printed, quantity = q,
  region_as_printed = tx$region_as_printed, layer_as_printed = tx$layer_as_printed,
  age_group_as_printed = tx$age_group_as_printed,
  value_printed = tx$value_printed, units_printed = u,
  stat_as_printed = tx$stat_as_printed, significance_as_printed = tx$significance_as_printed,
  cited_ref = ifelse(nzchar(tx$cited_ref), tx$cited_ref, NA_character_),
  value_numeric, value_low, value_high, range_midpoint,
  unit_class, value_mm, value_low_mm, value_high_mm, measure,
  lower_layer, reference_layer, OD_ratio_lower_over_reference,
  OD_ratio_lower_over_reference_low, OD_ratio_lower_over_reference_high,
  value_status, restates_text_row, data_role, n,
  species_as_published, Species, ncbi_taxid, adult_flag,
  note = NA_character_, stringsAsFactors = FALSE)

final.dataframe$note[r == 21L] <- "Legibility: the render shows a stray mark between '1.' and '4' ('1.'4-1.7'); read as 1.4-1.7 mm."
final.dataframe$note[r == 61L] <- "n = 24 adults analysed (METHODS); whether every one of the 24 was densitometered is not stated. 'every case' P < 0.01 is per-case; 5-14% is the across-case range, not a mean ± dispersion."
final.dataframe$note[r %in% c(27L, 37L)] <- "Group of the age stage (newborn n = 2; 4-month n = 1); no dispersion printed."
final.dataframe$note[r %in% c(76L, 77L)] <- "Macaque value stated without a printed citation (authors' own earlier macaque work implied); treated as cited/secondary."
final.dataframe$note[r == 81L] <- "Authors' own unpublished macaque datum; not this paper's human data."
final.dataframe$note[r == 30L] <- "Cited macaque developmental timing; restated on p. 56 as '3.5 weeks before birth in the macaque' (not re-rowed)."
final.dataframe$note[!is.na(restates_text_row)] <-
  paste0("Discussion restatement of text row ", restates_text_row[!is.na(restates_text_row)], " (unit changed where printed).")
final.dataframe$note[r %in% 17:19] <- "Nissl cytoarchitecture of the fetal cortical plate (zones of Sauer et al., 1983); not a CO value."

## ---- table checks ------------------------------------------------------------------
chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
v  <- function(k) final.dataframe$value_numeric[r == k]
lo <- function(k) final.dataframe$value_low[r == k]
hi <- function(k) final.dataframe$value_high[r == k]
mmv <- function(k) final.dataframe$value_mm[r == k]
within <- function(id, basis, x, a, b) chk(id, basis, as.numeric(x >= a & x <= b), 1, 0,
                                           sprintf("%g within [%g, %g]", x, a, b))
table_checks <- rbind(
  chk("adult_laminar_sum_low",  "p. 44-45 adult: I 0.2 + II/III low + IVb low + IVcα low + IVcβ low + V low + VI low vs printed total 2.1 (IVa not measurable)",
      v(45) + lo(46) + lo(58) + lo(59) + lo(60) + lo(62) + lo(63), lo(44), 0.1),
  chk("adult_laminar_sum_high", "p. 44-45 adult: I 0.2 + II/III high + IVb high + IVcα high + IVcβ high + V high + VI high vs printed total 2.5",
      v(45) + hi(46) + hi(58) + hi(59) + hi(60) + hi(62) + hi(63), hi(44), 0.1),
  chk("fourmonth_IVc_sublayers", "p. 44 4-month: IVcα 0.21 + IVcβ 0.29 vs printed IVc 0.51", v(39) + v(38), v(36), 0.01),
  chk("restatement_320",  "p. 56 row 74 vs p. 45 row 49 (µm)", v(74), v(49), 0),
  chk("restatement_450",  "p. 56 row 75 vs p. 45 row 50 (µm)", v(75), v(50), 0),
  chk("restatement_650",  "p. 56 row 78 (µm) vs p. 45 row 55 (mm), compared in mm", mmv(78), mmv(55), 0),
  chk("restatement_800",  "p. 56 row 79 (µm) vs p. 45 row 57 (mm), compared in mm", mmv(79), mmv(57), 0),
  chk("restatement_2to3_low",  "p. 56 row 83 low vs p. 45 row 52 low",  lo(83), lo(52), 0),
  chk("restatement_2to3_high", "p. 56 row 83 high vs p. 45 row 52 high", hi(83), hi(52), 0),
  within("mean_puff_diameter_in_range", "p. 45: mean 340 within 300-380", v(48), lo(47), hi(47)),
  within("mean_puff_density_in_range",  "p. 45: mean 2.35 within 2.0-3.0", v(53), lo(52), hi(52)),
  within("mean_spacing_rows_in_range",  "p. 45: mean 0.65 within 0.5-0.8", v(55), lo(54), hi(54)),
  within("mean_spacing_between_in_range","p. 45: mean 0.8 within 0.65-1.05", v(57), lo(56), hi(56))
)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}
dir.create("internal_checks", showWarnings = FALSE)
write.csv(table_checks, file.path("internal_checks", paste0(base, "_table_checks.csv")),
          row.names = FALSE, na = "NA", fileEncoding = "UTF-8")

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                               .name_repair = "minimal")
registry_row <- which(registry[["Item name"]] == item_name & !is.na(registry[["Item name"]]))
if (length(registry_row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][registry_row]
if (is.na(item_encoded) || !nzchar(item_encoded)) stop("Registered Item encoded is blank for ", item_name)
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV directory not found")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, quote = TRUE, na = "", qmethod = "double",
            fileEncoding = "UTF-8")
message(item_name, ": public TSV ", item_encoded, ".tsv")
