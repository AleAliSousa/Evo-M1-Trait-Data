## Heffner_Heffner_1985_Figure3.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1985). Hearing in Mammals: The Least
## Weasel. J Mammal, 66, 745-755. doi:10.2307/1380801
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 3 (p. 749), "Audiogram of
## the least weasel. A and B represent individual animals. The dots represent
## background noise levels". The page is a 1-bit CCITT scan (1206 x 1750 px);
## the snapshot rows were pixel-digitised from that embedded bitmap (see the
## README for the method). The snapshot stores the pixel coordinates, and this
## script RECOMPUTES every value from them with the printed-tick calibration
## below, stopping if any snapshot value disagrees (> 0.06 dB / > 0.5 %).
##
## PRIMARY: both animals are this study's own subjects. Values printed in the
## Results text (51 Hz and 60.5 kHz 60-dB limits, -8 dB at 2 kHz) are the
## separate item Heffner_Heffner_1985_ResultsText and take precedence; they
## are reproduced here only as a console cross-check.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1985_Figure3"
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
library(tidyverse)
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = c(x_tick_as_printed = "character"))
stopifnot(nrow(snap) == 59L, !anyDuplicated(snap$point_id))

## 3. CALIBRATION (printed ticks, pixel rows/columns of the tick marks) ----
y_tick_px <- c(221.5, 261.5, 303, 343, 383, 424.5, 464.5, 505.5, 544.5, 586.5, 625.5, 666.5)
y_tick_db <- seq(90, -20, by = -10)
x_tick_px <- c(331.5, 381.5, 432.5, 482.5, 533, 583, 633.5, 684, 733.5, 784.5, 835, 885.5, 935.5)
x_tick_log2khz <- -6:6        # printed .016 .031 .062 .125 .250 .500 1 2 4 8 16 32 64 (octave steps)
fy <- lm(y_tick_db ~ y_tick_px); fx <- lm(x_tick_log2khz ~ x_tick_px)
stopifnot(max(abs(resid(fy))) < 0.25, max(abs(resid(fx))) < 0.02)
db_re  <- round(unname(predict(fy, data.frame(y_tick_px = snap$y_px))), 1)
khz_re <- 2^unname(predict(fx, data.frame(x_tick_px = snap$x_px)))
if (any(abs(db_re - snap$threshold_db_spl_digitised) > 0.06) ||
    any(abs(khz_re / snap$frequency_khz_digitised - 1) > 0.005))
  stop("Snapshot values do not reproduce from pixel coordinates.", call. = FALSE)

## 4. CLEAN -----------------------------------------------------------
## tested frequencies (Methods p. 747: 16, 32, 63, 125, 250 Hz ... 64 kHz);
## the point between the 32 and 64 kHz ticks has no printed frequency.
nominal_khz <- c(".016" = 0.016, ".031" = 0.032, ".062" = 0.063, ".125" = 0.125,
                 ".250" = 0.25, ".500" = 0.5, "1" = 1, "2" = 2, "4" = 4, "8" = 8,
                 "16" = 16, "32" = 32, "64" = 64)
final.dataframe <- snap %>%
  mutate(species_as_printed = panel,
         species = resolve(panel),
         individual = recode(series, "mean (line)" = "mean", "background noise (dots)" = ""),
         measure = ifelse(series == "background noise (dots)",
                          "background_noise_level_db_spl", "absolute_threshold_db_spl"),
         frequency_khz_nominal = unname(nominal_khz[x_tick_as_printed]),
         frequency_khz = ifelse(is.na(frequency_khz_nominal),
                                round(frequency_khz_digitised, 1), frequency_khz_nominal),
         frequency_basis = ifelse(is.na(frequency_khz_nominal),
                                  "digitised (no printed tick)", "tested frequency at printed tick"),
         value_db_spl = threshold_db_spl_digitised,
         value_origin = "digitised_from_figure",
         data_role = "primary") %>%
  transmute(point_id, species_as_printed, species, series_as_printed = series, individual,
            measure, frequency_khz, frequency_basis, frequency_khz_digitised,
            value_db_spl, marker, value_origin, data_role)

## 5. CROSS-CHECK vs numbers printed in the Results text --------------
m <- final.dataframe %>% filter(individual == "mean") %>% arrange(frequency_khz_digitised)
lf <- log2(m$frequency_khz_digitised)
cross60 <- function(i) 2^(lf[i] + (60 - m$value_db_spl[i]) / (m$value_db_spl[i + 1] - m$value_db_spl[i]) * (lf[i + 1] - lf[i]))
lo <- which(m$value_db_spl[-nrow(m)] > 60 & m$value_db_spl[-1] <= 60)[1]
hi <- which(m$value_db_spl[-nrow(m)] < 60 & m$value_db_spl[-1] >= 60)[1]
print(data.frame(check = c("60-dB low limit (kHz)", "60-dB high limit (kHz)", "threshold at 2 kHz (dB)"),
                 printed = c(0.051, 60.5, -8),
                 from_digitised_mean = round(c(cross60(lo), cross60(hi), m$value_db_spl[m$frequency_khz == 2]), 3)),
      row.names = FALSE)

## 6. WRITE CSV + PUBLIC TSV ------------------------------------------
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
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
