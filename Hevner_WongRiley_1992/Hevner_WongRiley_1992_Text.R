# Hevner_WongRiley_1992_Text.R --------------------------------------------------
#
# Hevner & Wong-Riley (1992) "Entorhinal cortex of the human, monkey, and rat:
# Metabolic map as revealed by cytochrome oxidase", J Comp Neurol 326: 451-469,
# doi 10.1002/cne.903260310. Values printed only in running text (ABSTRACT
# p. 451, MATERIALS AND METHODS p. 452, RESULTS pp. 453, 455, 459). The paper is
# qualitative: no table, no densitometry; all laminar CO statements are ordinal
# and live in Hevner_WongRiley_1992_OrdinalLaminar.
#
# Reads the constructed, frozen snapshot Hevner_WongRiley_1992_Text_snapshot.csv
# (one row per printed value lexeme, written by Hevner_WongRiley_1992_Text_snapshot.R)
# and does all the cleaning:
#   - value_printed parsed: number words -> digits (Seven 7, six 6, two 2, four 4,
#     three 3, Five 5, Two 2); a single value -> value_numeric; a printed range
#     "a-b" -> value_low / value_high (value_numeric NA) plus range_midpoint
#     (DERIVED, not printed);
#   - lengths harmonised to mm (value_mm / value_low_mm / value_high_mm) from µm;
#     masses stay g / kg (value_g derived for kg); times stay as printed;
#   - measure code per quantity (n, Body_Mass, Age, Length.mm (island diameter),
#     Count (islands / spots / fields), Thickness.mm (sections), method);
#   - value_status: method / demographic / new / restatement / nomenclature;
#     data_role primary throughout (the one cited count, 'seven fields' of
#     Amaral et al. 1987, is nomenclature and flagged in value_status);
#   - species_as_published keeps the printed wording; Species is the accepted
#     name from _keys/General/species_key.csv (rows for this folder); rows
#     printed for 'all species' get Species NA with a note.
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
stopifnot(nrow(tx) == 39L, identical(tx$text_row, as.character(1:39)))

## ---- species -------------------------------------------------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[trimws(species_key$source_publication) == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk    <- setNames(trimws(species_key$accepted_name), tolower(trimws(species_key$variant_name)))
lk_id <- setNames(trimws(species_key$ncbi_taxid),    tolower(trimws(species_key$variant_name)))
species_as_published <- tx$species_as_printed
is_all <- species_as_published == "all species"
Species    <- ifelse(is_all, NA_character_, unname(lk[tolower(species_as_published)]))
ncbi_taxid <- ifelse(is_all, NA_character_, unname(lk_id[tolower(species_as_published)]))
if (any(is.na(Species) & !is_all)) stop("Unkeyed printed name(s): ",
  paste(unique(species_as_published[is.na(Species) & !is_all]), collapse = ", "), call. = FALSE)

## ---- parse printed lexemes ---------------------------------------------------------
word_num <- c(seven = "7", six = "6", two = "2", four = "4", three = "3", five = "5")
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
to_mm <- c(`µm` = 1e-3, mm = 1)
unit_class <- ifelse(u %in% names(to_mm), "length",
              ifelse(u %in% c("g", "kg"), "mass",
              ifelse(u %in% c("hour", "hours", "days", "years"), "time",
              ifelse(u == "%", "percent",
              ifelse(u %in% c("ml", "ml/kg", "mg/kg"), "dose_or_volume",
              ifelse(u == "dilution factor (1:x)", "dilution", "count"))))))
f_mm <- ifelse(unit_class == "length", to_mm[u], NA_real_)
value_mm      <- value_numeric * f_mm
value_low_mm  <- value_low  * f_mm
value_high_mm <- value_high * f_mm
f_g <- ifelse(u == "kg", 1000, ifelse(u == "g", 1, NA_real_))
value_low_g  <- value_low  * f_g
value_high_g <- value_high * f_g

## ---- measure code from the quantity ------------------------------------------------
q <- tx$quantity
measure <- ifelse(grepl("^number of (animals|hemispheres|individuals|macaque species)", q), "n",
           ifelse(grepl("^body weight", q), "Body_Mass",
           ifelse(grepl("^age", q), "Age",
           ifelse(grepl("island diameter", q), "Length.mm",
           ifelse(grepl("^section thickness", q), "Thickness.mm",
           ifelse(grepl("^number of", q), "Count", "method"))))))

## ---- provenance -----------------------------------------------------------------------
r <- as.integer(tx$text_row)
value_status <- ifelse(tx$section == "MATERIALS AND METHODS" & measure %in% c("n", "Body_Mass", "Age"), "demographic",
                ifelse(tx$section == "MATERIALS AND METHODS", "method",
                ifelse(nzchar(tx$cited_ref), "nomenclature",
                ifelse(grepl("restatement", tx$stat_as_printed), "restatement", "new"))))
data_role <- "primary"

final.dataframe <- data.frame(
  text_row = r, page = tx$page, section = tx$section, location = tx$location,
  passage_as_printed = tx$passage_as_printed, quantity = q,
  species_as_printed = tx$species_as_printed, region_as_printed = tx$region_as_printed,
  layer_as_printed = tx$layer_as_printed, group_as_printed = tx$group_as_printed,
  value_printed = tx$value_printed, units_printed = u, stat_as_printed = tx$stat_as_printed,
  cited_ref = ifelse(nzchar(tx$cited_ref), tx$cited_ref, NA_character_),
  value_numeric, value_low, value_high, range_midpoint,
  unit_class, value_mm, value_low_mm, value_high_mm, value_low_g, value_high_g, measure,
  value_status, data_role,
  species_as_published, Species, ncbi_taxid,
  note = NA_character_, stringsAsFactors = FALSE)

final.dataframe$note[is_all] <- "Printed for the immunohistochemical procedure in general (all three species); no species assigned."
final.dataframe$note[r == 1L] <- "Printed with a tilde (approximately). Counted islands in Fig. 3B = 224 (text row 38); the abstract rounds."
final.dataframe$note[r %in% 25:26] <- "Printed as one range 'ages 3 days to 80 years' in different units; split into two rows."
final.dataframe$note[r %in% 30:31] <- "Printed as '1:1,000 to 1:4,000'; the value is the dilution factor."
final.dataframe$note[r == 33L] <- "Nomenclature of Amaral et al. (1987) adopted for monkey and human EC; not a measurement."
final.dataframe$note[r %in% 37:38] <- "Authors state these counts probably underestimate the actual numbers (EC surface not entirely exposed)."
final.dataframe$note[r == 35L] <- "Island diameter in tangential sections through layers I-II; 'mostly' within the range, a few smaller or larger."

## ---- table checks ------------------------------------------------------------------
chk <- function(id, basis, observed, printed, tol) {
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch"), stringsAsFactors = FALSE)
}
v <- function(k) final.dataframe$value_numeric[r == k]
table_checks <- rbind(
  chk("macaque_species_sum", "two M. fascicularis + two M. radiata + two M. mulatta vs six macaques (p. 452)", v(12) + v(13) + v(14), v(11), 0),
  chk("macaque_species_count", "three macaque species (p. 459) vs the three binomials printed in METHODS", 3, v(39), 0),
  chk("island_count_abstract_low", "abstract ~200-250 islands: counted 224 islands (p. 459) lies within the range", as.numeric(v(38) >= final.dataframe$value_low[r == 1L] & v(38) <= final.dataframe$value_high[r == 1L]), 1, 0),
  chk("hemispheres_ge_individuals", "six hemispheres from four individuals (p. 452): hemispheres >= individuals", as.numeric(v(23) >= v(24)), 1, 0)
)
tally <- table(factor(table_checks$status, c("pass", "mismatch")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]])
if (tally[["mismatch"]] > 0L) warning("table check mismatch; see internal_checks", call. = FALSE)
dir.create("internal_checks", showWarnings = FALSE)
write.csv(table_checks, file.path("internal_checks", paste0(base, "_table_checks.csv")),
          row.names = FALSE, na = "NA", fileEncoding = "UTF-8")

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
registry_row <- which(registry[["Item name"]] == item_name & !is.na(registry[["Item name"]]))
if (length(registry_row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][registry_row]
if (is.na(item_encoded) || !nzchar(item_encoded)) stop("Registered Item encoded is blank for ", item_name)
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV directory not found")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
message(item_name, ": public TSV ", item_encoded, ".tsv")
