## Heffner_etal_1994_c_Figure7.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Heffner, R. S., Heffner, H. E., Kearns, D., Vogel, J., & Koay, G. (1994). Sound
## localization in chinchillas. I: Left/right discriminations. Hearing Research 80,
## 247-257. doi:10.1016/0378-5955(94)90116-3
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 7 (p. 254), left panel, plots
## sound-localization threshold (deg) against interaural distance (us) for 29 mammals on
## log-log axes. The page is a 200-ppi bilevel SCAN and in this figure the two-letter
## species CODES ARE THE PLOTTED SYMBOLS: a round dot appears only where a code had to be
## displaced. Values were pixel-digitised by Heffner_etal_1994_c_Figure7_extract.py, which
## wrote the frozen Heffner_etal_1994_c_Figure7_snapshot.csv.
##
## LOW CONFIDENCE, BY CONSTRUCTION. 13 of the 29 species sit on 8 printed dots (five of
## which are shared by two species each); the other 16 are located by the ink centroid of
## their printed code, which the figure may have displaced from its datum by up to about
## one character height -- the Sp (spiny mouse) code reads 11.2 deg here against the
## 19.0 deg this paper's own Table 1 prints. The abscissa ticks are not evenly log-spaced
## on this scan (single-log-fit residuals -10.9% to +10.5%), so the x values carry a
## calibration spread of that order. Prefer Heffner_etal_1994_c_Table1 and the other
## registered Heffner items wherever they cover the same species.
##
## SECONDARY: a Heffner-lab compilation. Per-code sources, where the Fig. 7 legend or the
## Table 1 Source column gives them, are in
## reference_tables/Heffner_etal_1994_c_Figure7_references.csv; five codes (D, H, M, Mk, W)
## are unresolved there and say so. The right panel (residuals after partialling out the
## width of the field of best vision) is derived and was not digitised.
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
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 1b. SPECIES KEY (collection-scoped: _keys/General, source_publication = folder name)
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder), "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ", paste(bad, collapse = "; "), call. = FALSE)
  out
}
resolve_basis <- function(x) key$basis[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
lg   <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_legend_codes.csv")),
                 stringsAsFactors = FALSE, encoding = "UTF-8")
refs <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_references.csv")),
                 stringsAsFactors = FALSE, encoding = "UTF-8")
t1   <- read.csv(file.path(folder, "Heffner_etal_1994_c_Table1_snapshot.csv"),
                 stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 29L, nrow(lg) == 29L, nrow(refs) == 29L,
          setequal(snap$species_code_as_printed, lg$species_code_as_published),
          setequal(snap$species_code_as_printed, refs$ref_key))

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  left_join(lg, by = c("species_code_as_printed" = "species_code_as_published")) %>%
  mutate(has_ref = species_code_as_printed %in% refs$ref_key[nzchar(refs$citation)]) %>%
  transmute(species_code_as_published = species_code_as_printed,
            code_printed_in_parentheses = printed_in_parentheses,
            common_name_in_legend,
            Species = resolve(species_code_as_printed),
            species_basis = resolve_basis(species_code_as_printed),
            interaural_distance_us,
            localization_threshold_deg,
            interaural_distance_us_globalfit,
            localization_threshold_deg_globalfit,
            calibration_spread_pct_x = round(100 * (interaural_distance_us_globalfit /
                                                      interaural_distance_us - 1), 1),
            calibration_spread_pct_y = round(100 * (localization_threshold_deg_globalfit /
                                                      localization_threshold_deg - 1), 1),
            position_basis,
            shares_marker_with,
            source_ref_key = ifelse(has_ref, species_code_as_printed, ""),
            value_origin = "digitised_from_figure",
            value_precision = ifelse(grepl("^printed dot", position_basis),
              "dot centre; x calibration spread up to ~11%, y up to ~2%",
              "printed code centroid: the code may be displaced from its datum by up to ~1 character (seen up to -41% in threshold); x calibration spread up to ~11%"),
            data_role = "secondary") %>%
  arrange(species_code_as_published)

## 4. TABLE CHECKS (HOWTO 7a) -- digitised thresholds vs this paper's own Table 1 -------
t1map <- c("Norway rat (domestic)" = "Rd", "Norway rat (wild)" = "Rw", "Chinchilla" = "Ch",
           "Spiny mouse" = "Sp", "Wood rat" = "Wr", "Grasshopper mouse" = "Gm",
           "Gerbil" = "Gr", "Kangaroo rat" = "K", "Groundhog" = "Gh",
           "Naked mole rat" = "N", "Blind mole rat" = "Mb")
t1 <- t1[t1$Species %in% names(t1map), ]
t1$code <- unname(t1map[t1$Species])
names(t1)[names(t1) == "Species"] <- "Table1_species"
cmp <- merge(t1, final.dataframe, by.x = "code", by.y = "species_code_as_published")
cmp$printed <- as.numeric(cmp$`Threshold (deg)`)
cmp$pct <- round(100 * (cmp$localization_threshold_deg / cmp$printed - 1), 1)
cmp$basis <- ifelse(grepl("^printed dot", cmp$position_basis), "dot", "code")
print(cmp[order(cmp$basis, cmp$code), c("code", "Table1_species", "printed",
                                        "localization_threshold_deg", "pct", "basis")],
      row.names = FALSE)
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "n_species",        "species digitised from the left panel", nrow(final.dataframe), 29, 0,
  "n_on_dots",        "species located on a printed dot", sum(grepl("^printed dot", final.dataframe$position_basis)), 13, 0,
  "Table1_dot_maxpct","largest |difference| vs Table 1 threshold, dot-anchored codes (%)",
                      max(abs(cmp$pct[cmp$basis == "dot"])), 0, 10,
  "Table1_code_maxpct","largest |difference| vs Table 1 threshold, code-anchored codes (%) -- EXPECTED to fail; it quantifies label displacement",
                      max(abs(cmp$pct[cmp$basis == "code"])), 0, 10) %>%
  mutate(difference = observed - printed,
         status = ifelse(abs(difference) <= tolerance, "pass", "mismatch"))

## WRITE CSV + PUBLIC TSV ---------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
if (exists("table_checks")) {
  print(as.data.frame(table_checks), row.names = FALSE)
  if (any(table_checks$status != "pass"))
    message("NOTE: ", sum(table_checks$status != "pass"), " table check(s) not 'pass' -- see README.")
}
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
