## Heffner_Heffner_1985_Figure6.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1985). Hearing in Mammals: The Least
## Weasel. J Mammal, 66, 745-755. doi:10.2307/1380801
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 6 (p. 753), "Relation
## between high-frequency and low-frequency hearing in 30 species of land
## mammals" -- 60-dB low-frequency limit (log2 axis, .01-10.24 kHz) against
## 60-dB high-frequency limit (log2 axis, 10-160 kHz). Each point is printed as
## its key number (centre of the number = point), two pairs (9 & 41, 13 & 14)
## share a filled dot indicated by arrows, and the least weasel is a
## silhouette. The key is the Fig. 5 legend (p. 751; Fig. 6's caption prints
## "See Fig. 4 for key" -- kept verbatim, see references table).
## Pixel coordinates (1-bit 1206 x 1750 scan) are in the snapshot; this script
## recomputes every value from them with the printed-tick calibration below.
##
## SECONDARY except the silhouette (this study's least weasel = both). No
## per-point sources are printed; candidate originals recovered from this
## paper's text/bibliography are in candidate_original_source and
## reference_tables/Heffner_Heffner_1985_Figure6_references.csv; independent
## repo values for comparison are in ..._Figure6_repo_trace.csv.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1985_Figure6"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
trace_csv    <- file.path(folder, "reference_tables", paste0(item_name, "_repo_trace.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv)
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
snap  <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
refs  <- read.csv(refs_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
trace <- read.csv(trace_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 31L, !anyDuplicated(snap$label_as_printed))
names(snap)[names(snap) == "legend_name_as_printed (Fig. 5 legend)"] <- "legend_name"

## 3. CALIBRATION (printed ticks) --------------------------------------
y_tick_px <- c(229, 303, 375, 448, 521, 593, 666.5, 740, 813.5, 887, 960.5)
y_tick_log2 <- 10:0          # 10.24 5.12 ... .02 .01 kHz = 0.01 * 2^k
x_tick_px <- c(343, 490.5, 636.5, 783, 930.5)
x_tick_log2 <- 0:4           # 10 20 40 80 160 kHz = 10 * 2^k
fy <- lm(y_tick_log2 ~ y_tick_px); fx <- lm(x_tick_log2 ~ x_tick_px)
stopifnot(max(abs(resid(fy))) < 0.02, max(abs(resid(fx))) < 0.01)
hi_re <- 10 * 2^unname(predict(fx, data.frame(x_tick_px = snap$point_x_px)))
lo_re <- 0.01 * 2^unname(predict(fy, data.frame(y_tick_px = snap$point_y_px)))
if (any(abs(hi_re / snap$high_frequency_limit_khz_digitised - 1) > 0.002) ||
    any(abs(lo_re / snap$low_frequency_limit_khz_digitised - 1) > 0.002))
  stop("Snapshot values do not reproduce from pixel coordinates.", call. = FALSE)

## 4. CANDIDATE SOURCES (recovered from this paper; joined by label) ----
fig_key <- refs$ref_key[grepl("^figure_source_ref_key", refs$cited_in_column)]
stopifnot(length(fig_key) == 1L)
cand <- refs[grepl("^candidate_original_source", refs$cited_in_column), ]
cand_long <- cand %>%
  mutate(label = str_match(cited_in_column, "traced for: (.*)\\)$")[, 2]) %>%
  separate_rows(label, sep = ", ") %>% select(label, ref_key)
stopifnot(!anyDuplicated(cand_long$label), all(cand_long$label %in% snap$label_as_printed))
tr_w <- trace %>%
  mutate(m = ifelse(grepl("high", measure), "high", "low"),
         txt = ifelse(n_candidates > 0, paste0(Source_item, ":", Study_key, " (", repo_value, ")"), "")) %>%
  select(label_as_printed, m, txt) %>% pivot_wider(names_from = m, values_from = txt,
                                                  names_prefix = "repo_trace_")

## 5. TIDY (one row per point x measure) ----------------------------------
final.dataframe <- snap %>%
  mutate(species_as_printed = legend_name,
         species = resolve(legend_name),
         population = case_when(grepl("\\(wild\\)", legend_name) ~ "wild",
                                grepl("\\(domestic\\)", legend_name) ~ "domestic", TRUE ~ "")) %>%
  left_join(cand_long, by = c("label_as_printed" = "label")) %>%
  left_join(tr_w, by = "label_as_printed") %>%
  transmute(label_as_printed, species_as_printed, species, population, marker,
            audible_freq_high_60dB_khz = high_frequency_limit_khz_digitised,
            audible_freq_low_60dB_khz  = low_frequency_limit_khz_digitised,
            value_origin = "digitised_from_figure",
            figure_source_ref_key = fig_key,
            candidate_original_source = replace_na(ref_key, ""),
            repo_trace_high, repo_trace_low,
            data_role = ifelse(label_as_printed == "silhouette", "both", "secondary")) %>%
  pivot_longer(c(audible_freq_high_60dB_khz, audible_freq_low_60dB_khz),
               names_to = "measure", values_to = "value_khz") %>%
  mutate(repo_trace = ifelse(measure == "audible_freq_high_60dB_khz", repo_trace_high, repo_trace_low)) %>%
  select(-repo_trace_high, -repo_trace_low) %>%
  relocate(measure, value_khz, .after = marker)

## 6. CROSS-CHECK vs numbers printed in this paper ------------------------
xc <- tibble::tribble(~label_as_printed, ~measure, ~printed, ~where,
  "silhouette", "audible_freq_high_60dB_khz", 60.5,  "Results p. 749",
  "silhouette", "audible_freq_low_60dB_khz",  0.051, "Results p. 748",
  "40",         "audible_freq_high_60dB_khz", 35,    "Discussion p. 752 (cattle 'hear up to 35 kHz')",
  "24",         "audible_freq_high_60dB_khz", 92,    "Discussion p. 752 (wild house mouse '92 kHz')")
xc <- xc %>% left_join(final.dataframe %>% select(label_as_printed, measure, value_khz),
                       by = c("label_as_printed", "measure")) %>%
  mutate(pct_diff = round(100 * (value_khz / printed - 1), 1))
print(as.data.frame(xc), row.names = FALSE)

## 7. WRITE CSV + PUBLIC TSV ------------------------------------------
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
