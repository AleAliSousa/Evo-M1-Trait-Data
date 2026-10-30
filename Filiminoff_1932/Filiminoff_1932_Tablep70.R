## Filiminoff_1932_Tablep70.R -- snapshot -> analysis CSV + public TSV
##
## Filimonoff, I. N. (1932) [folder spelling: Filiminoff]. Über die Variabilität
## der Großhirnrindenstruktur. Mitteilung II. Regio occipitalis beim erwachsenen
## Menschen. Journal für Psychologie und Neurologie 44:1-96.
##
## Source is a 98-page scan with an unusable OCR layer. The unnumbered table under
## "IV. 1. Die Flächenausdehnung der Regio occipitalis und ihrer Hauptfelder"
## (printed p. 70 = PDF page 71) was hand-transcribed from 500-dpi page renders into
## Filiminoff_1932_Tablep70_snapshot.xlsx (printed layout, German headings).
## Case age / group / hemisphere come from the protocol headers (pp. 35-70) via
## reference_tables/Filiminoff_1932_Tablep70_cases.csv.
##
## Units: printed mm2 (one hemisphere, NOT shrinkage-corrected) -> area_cm2 = mm2 / 100.
## The author's shrinkage coefficient 1.2 (p. 71) is applied only in the separate
## column area_cm2_shrinkage_corrected.

## 0. PATHS --------------------------------------------------------
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Filiminoff_1932_Tablep70"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_xlsx <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
cases_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_cases.csv"))
final_csv     <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir       <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))   # snapshot cells carry mm², ⁰/₀, —; C locale escapes them

## 2. LOAD ----------------------------------------------------------
## rows 1-2 = section + table headings, row 3 = printed column header, rows 4-16 = 13 hemispheres
snap <- read_excel(snapshot_xlsx, sheet = "Seite70", range = "A4:H16",
                   col_names = c("row_label", "R_occ", "A17", "A17_pct", "A18", "A18_pct", "A19", "A19_pct"),
                   col_types = "text")
hdr  <- unlist(suppressMessages(read_excel(snapshot_xlsx, sheet = "Seite70", range = "A3:H3",
                                           col_names = FALSE, col_types = "text")))
stopifnot(nrow(snap) == 13, identical(unname(hdr[!is.na(hdr)]), c("R. occ.", "Area 17", "Area 18", "Area 19")))
cases <- read.csv(cases_csv, stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
stopifnot(setequal(cases$table_row_label, snap$row_label))

## species: table prints none; title prints "beim erwachsenen Menschen"
key <- read_csv(file.path(base, "_keys", "General", "species_key.csv"), show_col_types = FALSE)
key_f <- key[key$source_publication == "Filiminoff_1932", ]
if (nrow(key_f) == 0L)
  stop("No species_key.csv rows for source_publication == \"Filiminoff_1932\" (_keys/General)", call. = FALSE)
species_as_published <- "Menschen"
Species <- key_f$accepted_name[match(tolower(species_as_published), tolower(key_f$variant_name))]
if (is.na(Species)) stop("No species_key row for: ", species_as_published, call. = FALSE)

## 3. CLEAN -----------------------------------------------------------
num <- function(v) {                        # "10444 mm2" / "= 24,2 %" / dash -> numeric (dash -> NA)
  m <- regmatches(v, regexpr("[0-9]+(,[0-9]+)?", v))
  out <- rep(NA_real_, length(v))
  out[grepl("[0-9]", v)] <- as.numeric(sub(",", ".", m, fixed = TRUE))
  out
}
long <- bind_rows(
  tibble(table_row = 1:13, row_label = snap$row_label, structure_as_printed = "R. occ.",
         area_as_printed = snap$R_occ, pct_as_printed = NA_character_),
  tibble(table_row = 1:13, row_label = snap$row_label, structure_as_printed = "Area 17",
         area_as_printed = snap$A17, pct_as_printed = snap$A17_pct),
  tibble(table_row = 1:13, row_label = snap$row_label, structure_as_printed = "Area 18",
         area_as_printed = snap$A18, pct_as_printed = snap$A18_pct),
  tibble(table_row = 1:13, row_label = snap$row_label, structure_as_printed = "Area 19",
         area_as_printed = snap$A19, pct_as_printed = snap$A19_pct)) %>%
  arrange(table_row)

structure_map <- c("R. occ." = "Regio_occipitalis", "Area 17" = "Area_striata",
                   "Area 18" = "Area_18", "Area 19" = "Area_19")

final.dataframe <- long %>%
  left_join(cases, by = c("row_label" = "table_row_label")) %>%
  transmute(
    Species, species_as_published,
    hemisphere_label_as_printed = row_label,
    brain_code, protocol_number = as.integer(protocol_number), hemisphere,
    group_as_printed, sex_inferred, age_years = as.numeric(age_years_as_printed),
    brain_weight_g = num(brain_weight_as_printed),
    structure_as_printed, structure = unname(structure_map[structure_as_printed]),
    area_as_printed,
    area_mm2 = num(area_as_printed),
    area_cm2 = area_mm2 / 100,
    area_cm2_shrinkage_corrected = round(area_mm2 * 1.2 / 100, 2),
    pct_of_regio_occipitalis_as_printed = pct_as_printed,
    pct_of_regio_occipitalis = num(pct_as_printed),
    source_location = "unnumbered table IV.1, printed p. 70 (PDF p. 71); case headers pp. 35-70",
    data_role = "primary")
stopifnot(nrow(final.dataframe) == 52, !anyNA(final.dataframe$structure),
          sum(!is.na(final.dataframe$area_mm2)) == 46)

## 3b. TABLE CHECKS (QA metadata; not written to CSV/TSV) -------------
w <- final.dataframe %>% select(hemisphere_label_as_printed, structure, area_mm2, pct_of_regio_occipitalis) %>%
  pivot_wider(names_from = structure, values_from = c(area_mm2, pct_of_regio_occipitalis))
sum_chk <- tibble(
  check_id = paste0("sum_17_18_19_eq_Rocc_", w$hemisphere_label_as_printed),
  basis    = "Area 17 + Area 18 + Area 19 vs printed R. occ. (mm2)",
  observed = w$area_mm2_Area_striata + w$area_mm2_Area_18 + w$area_mm2_Area_19,
  printed  = w$area_mm2_Regio_occipitalis) %>%
  mutate(difference = observed - printed, tolerance = 0,
         status = ifelse(is.na(difference), "not_evaluable", ifelse(abs(difference) <= tolerance, "pass", "mismatch")),
         note = ifelse(is.na(difference), "dash cells (Ar 1: only Area 17 printed)", ""))
pct_chk <- map_dfr(c("Area_striata", "Area_18", "Area_19"), function(s) tibble(
  check_id = paste0("pct_", s, "_", w$hemisphere_label_as_printed),
  basis    = paste0("100 x ", s, " / R. occ. vs printed percent"),
  observed = round(100 * w[[paste0("area_mm2_", s)]] / w$area_mm2_Regio_occipitalis, 2),
  printed  = w[[paste0("pct_of_regio_occipitalis_", s)]])) %>%
  mutate(difference = round(observed - printed, 2), tolerance = 0.06,
         status = ifelse(is.na(difference), "not_evaluable", ifelse(abs(difference) <= tolerance, "pass", "mismatch")),
         note = "printed to 0.1 %; tolerance = half-unit + float slack")
a <- final.dataframe
mean_of <- function(s) mean(a$area_mm2[a$structure == s], na.rm = TRUE)
txt_chk <- tibble(
  check_id = c("mean_Rocc_text_p71", "mean_A17_text_p71", "mean_A18_text_p71", "mean_A19_text_p71",
               "min_A17_text_p71", "max_A17_text_p71"),
  basis = c("mean R. occ. (11 hemispheres) vs text 10490 mm2", "mean Area 17 (13) vs text 2613 mm2",
            "mean Area 18 (11) vs text 3948 mm2", "mean Area 19 (11) vs text 3890 mm2",
            "min Area 17 vs text 2208 mm2 (Ar 18 sin)", "max Area 17 vs text 2877 mm2 (A kit 1 d)"),
  observed = round(c(mean_of("Regio_occipitalis"), mean_of("Area_striata"), mean_of("Area_18"), mean_of("Area_19"),
                     min(a$area_mm2[a$structure == "Area_striata"]), max(a$area_mm2[a$structure == "Area_striata"]))),
  printed = c(10490, 2613, 3948, 3890, 2208, 2877)) %>%
  mutate(difference = observed - printed, tolerance = 0,
         status = ifelse(abs(difference) <= tolerance, "pass", "mismatch"), note = "")
ve_chk <- tibble(
  check_id = "VanEssen_Drury_1997_cited_range_22_29_cm2",
  basis = "Area 17 range rounded to whole cm2 vs 22-29 cm2 cited by Van Essen & Drury 1997 (one hemisphere)",
  observed = NA_real_, printed = NA_real_, difference = NA_real_, tolerance = 0.5,
  status = ifelse(round(min(a$area_cm2[a$structure == "Area_striata"])) == 22 &&
                  round(max(a$area_cm2[a$structure == "Area_striata"])) == 29, "pass", "mismatch"),
  note = sprintf("uncorrected range %.2f-%.2f cm2; shrinkage-corrected %.2f-%.2f cm2 does not match the cited range",
                 min(a$area_cm2[a$structure == "Area_striata"]), max(a$area_cm2[a$structure == "Area_striata"]),
                 min(a$area_cm2_shrinkage_corrected[a$structure == "Area_striata"]),
                 max(a$area_cm2_shrinkage_corrected[a$structure == "Area_striata"])))
table_checks <- bind_rows(sum_chk, pct_chk, txt_chk, ve_chk)
bad <- table_checks %>% filter(status == "mismatch")
if (nrow(bad)) warning("Table checks not passing (values kept as printed): ",
                       paste(bad$check_id, collapse = "; "), call. = FALSE)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded)) {
    ## registry row not pasted yet: derive with the Sheet1 col-I/K formula from this item's registry_row.xlsx
    rr <- read_excel(file.path(folder, paste0(item_name, "_registry_row.xlsx")), sheet = "Registry_row", col_types = "text")
    enc <- function(x) gsub(">", "%3E", gsub("<", "%3C", gsub(":", "%3A", gsub("/", "%2F", x, fixed = TRUE), fixed = TRUE), fixed = TRUE), fixed = TRUE)
    item_encoded <- paste0(enc(rr[[3]][1]), "_", gsub("[ _\u00a0]", "", rr[[4]][1]))
    warning("No registry row for ", item_name, " -- Item encoded derived from registry_row.xlsx: ",
            item_encoded, call. = FALSE)
  }
  if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
    stop("No usable 'Item encoded' for ", item_name, " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
