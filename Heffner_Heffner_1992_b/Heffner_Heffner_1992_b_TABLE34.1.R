## Heffner_Heffner_1992_b_TABLE34.1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1992). Evolution of sound localization in
## mammals. In D. B. Webster, R. R. Fay, & A. N. Popper (Eds.), The evolutionary
## biology of hearing (pp. 691-715). Springer. doi:10.1007/978-1-4612-2784-7_43
##
## Table 34.1 (p. 692): head radius and the Kuhn (1977) model-calculated
## interaural time difference (ITD, at 90 and 10 deg azimuth) and frequency of
## phase ambiguity (at 90 and 30 deg azimuth) for 4 species. The values are
## CALCULATED by the authors, not measured. Note the two quantities use
## different second azimuths (10 deg for ITD, 30 deg for phase ambiguity) --
## exactly as printed and confirmed arithmetically (ITD10 = ITD90 x sin 10 deg).
##
## Snapshot transcribed by an AI assistant (2026-10-28) from a 250-dpi render
## of PDF p. 2 (the scanned text layer garbles the header as "~sec", "900",
## "100"); every value re-read on the image. Three printed header rows are
## kept in the snapshot, so it is read positionally (skip = 3).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1992_b_TABLE34.1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed names carry Greek/µ/’)
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

## 2. LOAD (positional; 3 printed header rows) ----------------------------
snap <- read.csv(snapshot_csv, header = FALSE, skip = 3, colClasses = "character",
                 encoding = "UTF-8", check.names = FALSE)
names(snap) <- c("animal", "radius_mm", "itd_90", "itd_10", "fpa_90", "fpa_30")
footnote <- snap$animal[nrow(snap)]
snap <- snap[nzchar(snap$radius_mm), ]          # drop the printed footnote row
stopifnot(nrow(snap) == 4L, grepl("Kuhn \\(1977\\)", footnote))
num <- function(x) as.numeric(gsub(",", "", x)) # strip thousands separator ("3,200")

## 3. TABLE CHECKS (HOWTO 7a) -------------------------------------------
## Kuhn (1977) low-frequency model: ITD proportional to sin(azimuth);
## phase becomes ambiguous where ITD = half a period, f = 1 / (2 ITD).
## Tolerances = half a unit of each printed last digit, propagated.
hu <- function(x) { d <- nchar(sub("^[^.]*\\.?", "", x)); 0.5 * 10^(-d) }
w <- snap
chk <- list()
for (i in seq_len(nrow(w))) {
  itd90 <- num(w$itd_90[i]); itd10 <- num(w$itd_10[i])
  f90 <- num(w$fpa_90[i]);   f30 <- num(w$fpa_30[i])
  ## (a) ITD10 vs ITD90 * sin(10 deg)
  o <- itd90 * sin(10 * pi / 180); tl <- hu(w$itd_10[i]) + hu(w$itd_90[i]) * sin(10 * pi / 180)
  chk[[length(chk) + 1]] <- data.frame(check_id = paste0("itd10_sine_", w$animal[i]),
    basis = "ITD 10 deg printed vs ITD 90 deg x sin(10 deg)", observed = round(o, 3), printed = itd10,
    difference = round(o - itd10, 3), tolerance = round(tl, 3),
    status = ifelse(abs(o - itd10) <= tl, "pass", "mismatch"),
    note = if (w$animal[i] == "Elephant") "3,200 read as exact to the unit; if it is rounded to 2 s.f. the tolerance is ~9 us" else "")
  ## (b) f90 vs 1 / (2 ITD90), kHz
  o <- 1e3 / (2 * itd90); tl <- o * hu(w$itd_90[i]) / itd90 + hu(w$fpa_90[i])
  chk[[length(chk) + 1]] <- data.frame(check_id = paste0("f90_halfperiod_", w$animal[i]),
    basis = "phase-ambiguity f 90 deg printed vs 1/(2 x ITD 90 deg)", observed = round(o, 4), printed = f90,
    difference = round(o - f90, 4), tolerance = round(tl, 4),
    status = ifelse(abs(o - f90) <= tl, "pass", "mismatch"), note = "")
  ## (c) f30 vs 2 x f90 (sin 90 / sin 30 = 2)
  o <- 2 * f90; tl <- 2 * hu(w$fpa_90[i]) + hu(w$fpa_30[i])
  chk[[length(chk) + 1]] <- data.frame(check_id = paste0("f30_double_", w$animal[i]),
    basis = "phase-ambiguity f 30 deg printed vs 2 x f 90 deg", observed = o, printed = f30,
    difference = round(o - f30, 4), tolerance = tl,
    status = ifelse(abs(o - f30) <= tl, "pass", "mismatch"), note = "")
}
table_checks <- do.call(rbind, chk)
print(table_checks[, c("check_id", "observed", "printed", "difference", "tolerance", "status")], row.names = FALSE)
if (any(table_checks$status == "mismatch"))
  warning("Table 34.1 checks not passed: ",
          paste(table_checks$check_id[table_checks$status == "mismatch"], collapse = ", "),
          " -- values kept as printed (see README / errata).", call. = FALSE)

## 4. RESHAPE (long: one row per animal x quantity x azimuth) -----------
final.dataframe <- bind_rows(
  tibble(animal_as_printed = snap$animal, quantity = "interaural_time_difference", azimuth_deg = 90,
         value = num(snap$itd_90), unit = "us", value_as_printed = snap$itd_90),
  tibble(animal_as_printed = snap$animal, quantity = "interaural_time_difference", azimuth_deg = 10,
         value = num(snap$itd_10), unit = "us", value_as_printed = snap$itd_10),
  tibble(animal_as_printed = snap$animal, quantity = "phase_ambiguity_frequency", azimuth_deg = 90,
         value = num(snap$fpa_90), unit = "kHz", value_as_printed = snap$fpa_90),
  tibble(animal_as_printed = snap$animal, quantity = "phase_ambiguity_frequency", azimuth_deg = 30,
         value = num(snap$fpa_30), unit = "kHz", value_as_printed = snap$fpa_30)
) %>%
  left_join(tibble(animal_as_printed = snap$animal, head_radius_mm = num(snap$radius_mm)),
            by = "animal_as_printed") %>%
  mutate(species = resolve(animal_as_printed),
         row_order = match(animal_as_printed, snap$animal)) %>%
  arrange(row_order, quantity, desc(azimuth_deg)) %>%
  transmute(animal_as_printed, species, head_radius_mm, quantity, azimuth_deg, value, unit,
            value_as_printed, value_origin = "calculated_by_authors",
            method_ref_key = "Kuhn (1977)", data_role = "primary")
stopifnot(nrow(final.dataframe) == 16L, !anyNA(final.dataframe$value), !anyNA(final.dataframe$species))

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
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
