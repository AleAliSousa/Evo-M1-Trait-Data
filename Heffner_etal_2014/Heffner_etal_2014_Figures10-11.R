## Heffner_etal_2014_Figures10-11.R -- constructed snapshot (digitised figures) -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna pacos):
## Audiogram, localization acuity, and use of binaural locus cues. J. Acoust. Soc. Am.
## 135, 778-788. doi:10.1121/1.4861344
##
## THE ITEM IS A PAIR OF FIGURES held as one registry item (Item number "Figures 10-11",
## title "Sound-localization acuity and functional interaural distance among species
## using one vs both binaural locus cues"). FIG. 10 (p. 786) is a LINEAR 0-35 deg scale
## of sound-localization threshold; FIG. 11 (p. 787) a LOGARITHMIC 40-4000 us scale of
## functional interaural distance. Both carry the same roster and the same left/right
## split (uses both cues vs only one cue), so the two are joined here into one row per
## species with both measures.
##
## The figures are raster images, so the leader-line positions were pixel-digitised from
## the embedded bitmaps by Heffner_etal_2014_Figures10-11_extract.py, which wrote the
## frozen Heffner_etal_2014_Figures10-11_snapshot.csv. The printed type style (roman /
## bold / italic) encodes which binaural cue each species uses and is read visually in
## reference_tables/Heffner_etal_2014_Figures10-11_label_typography.csv.
##
## SECONDARY. Neither caption keys a per-species source; the only citation either prints
## is Heffner and Heffner (1982) for the asterisked species
## (reference_tables/Heffner_etal_2014_Figures10-11_references.csv).
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
typo <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_label_typography.csv")),
                 stringsAsFactors = FALSE, encoding = "UTF-8")
refs <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_references.csv")),
                 stringsAsFactors = FALSE, encoding = "UTF-8")
f9   <- read.csv(file.path(folder, "Heffner_etal_2014_Figure9_snapshot.csv"),
                 comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 48L, nrow(typo) == 25L)

## 3. CLEAN: split multi-species labels, strip the footnote asterisk, go wide ----
long <- snap %>%
  mutate(lab = sub("^\\*", "", label_as_printed)) %>%
  mutate(sp = strsplit(lab, ",\\s*")) %>%
  tidyr::unnest_longer(sp) %>%
  mutate(sp = sub("^\\*", "", sp),
         shares_tick_with = vapply(seq_along(sp), function(i) {
           o <- setdiff(unlist(strsplit(lab[i], ",\\s*")), sp[i])
           o <- c(o, if (nzchar(shares_tick_with[i])) sub("^\\*", "", unlist(strsplit(shares_tick_with[i], "; "))))
           paste(unique(o), collapse = "; ") }, character(1)))
wide <- long %>%
  select(sp, figure, quantity, value, value_globalfit, cue_group, shares_tick_with) %>%
  pivot_wider(id_cols = sp, names_from = quantity,
              values_from = c(value, value_globalfit, cue_group, shares_tick_with))
stopifnot(identical(wide$cue_group_sound_localization_threshold_deg,
                    wide$cue_group_functional_interaural_distance_us))

final.dataframe <- wide %>%
  left_join(typo, by = c("sp" = "species_as_published")) %>%
  transmute(species_as_published = sp,
            Species = resolve(sp),
            species_basis = resolve_basis(sp),
            cue_group = cue_group_sound_localization_threshold_deg,
            binaural_cue_use = binaural_cue_use,
            printed_type_style = printed_type_style,
            footnote_asterisk = asterisked,
            sound_localization_threshold_deg = value_sound_localization_threshold_deg,
            sound_localization_threshold_deg_globalfit = value_globalfit_sound_localization_threshold_deg,
            functional_interaural_distance_us = value_functional_interaural_distance_us,
            functional_interaural_distance_us_globalfit = value_globalfit_functional_interaural_distance_us,
            shares_tick_Fig10 = shares_tick_with_sound_localization_threshold_deg,
            shares_tick_Fig11 = shares_tick_with_functional_interaural_distance_us,
            value_origin = "digitised_from_figure",
            value_precision = "Fig.10 +/- 0.04 deg (calibration) ; Fig.11 +/- 0.35% (calibration)",
            figure_source_ref_key = paste(refs$ref_key, collapse = "; "),
            data_role = "secondary") %>%
  arrange(desc(sound_localization_threshold_deg))
stopifnot(!anyNA(final.dataframe$binaural_cue_use))

## 4. TABLE CHECKS (HOWTO 7a) -----------------------------------------
## Fig. 10 vs Fig. 9 of the same paper: 19 species appear on both thresholds scales.
f9l <- f9 %>% mutate(sp = strsplit(label_as_printed, ",\\s*")) %>% tidyr::unnest_longer(sp)
cmp <- inner_join(final.dataframe, f9l, by = c("species_as_published" = "sp"))
d10v9 <- cmp$sound_localization_threshold_deg - cmp$localization_threshold_deg
gv <- function(s, col) final.dataframe[[col]][final.dataframe$species_as_published == s]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "alpaca_MAA_Fig10", "alpaca threshold (deg); Results III.B: 23 deg", gv("alpaca", "sound_localization_threshold_deg"), 23, 1.0,
  "Fig10_vs_Fig9_max", "largest |Fig.10 - Fig.9| threshold over the species on both scales (deg)",
                       max(abs(d10v9)), 0, 0.6,
  "Fig10_vs_Fig9_n",   "species common to Figs. 9 and 10", nrow(cmp), 21, 0,
  "Cp_interaural",     "short-tailed fruit bat interaural distance (us); Fig. 4 of Heffner et al. 2003 prints 47 us",
                       gv("short-tailed fruit bat", "functional_interaural_distance_us"), 47, 3,
  "Ph_interaural",     "greater spear-nosed bat interaural distance (us); Koay et al. 2002 / Fig. 4 of Heffner et al. 2003 print 108 us",
                       gv("greater spear-nosed bat", "functional_interaural_distance_us"), 108, 5,
  "Aj_interaural",     "Jamaican fruit bat interaural distance (us); Heffner et al. 2003 prints 96 us",
                       gv("Jamaican fruit bat", "functional_interaural_distance_us"), 96, 5,
  "n_species",         "species in the item", nrow(final.dataframe), 25, 0) %>%
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
