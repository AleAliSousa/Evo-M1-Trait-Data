## Ashwell K (2020), Zoology 142:125753.  "Quantitative analysis of the cerebellum
## in monotremes, marsupials and placental mammals."  Supplementary table:
## cerebellar (and related) volumes / surface areas per species.
## Snapshot -> clean.  Golden rule: the snapshot is frozen/faithful; cleaning happens here.
##
## NO AVERAGING HERE (changed 2026-08-19).  The printed table is per-SPECIMEN for two
## monotremes -- Ornithorhynchus anatinus 1/2/3 and Tachyglossus aculeatus 1/2/3, each block
## followed by Ashwell's own "<common name> mean" and "<common name> SD" rows.  This script
## used to strip the trailing specimen number and collapse those six rows to two species
## means.  That is the wrong place for it: pooling belongs to ../__merging_volumes, which
## needs the individual brains to know N and to weight the species value.  The six specimen
## rows are therefore kept as six rows, and Ashwell's printed mean/SD rows are moved out of
## the data table into a reconciliation file (they are a QA anchor, not observations).
## Every other species is one printed row; Ashwell does not say whether that row is one brain
## or an undocumented mean, so `n_specimen_rows` counts PRINTED ROWS, not animals -- do not
## read it as a published N.

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
options(scipen = 999)

suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(stringr); library(tidyr)
})

raw <- read_excel("Ashwell__2020_SupplementaryTable_snapshot.xlsx", col_types = "text")

# The snapshot keeps the printed column headers (units, spaces). Rename to the
# snake_case codes used in Ashwell__2020_definitions.csv and the merge term map.
clean_names <- c(
  "group", "species", "common_name", "brain_volume_mm3", "total_cb_volume_mm3",
  "vermis_excl_cb10_mm3", "hemisphere_excl_fl_mm3", "flocculo_nodular_cb_cx_mm3",
  "ratio_hemisph_vermis", "total_cb_cx_volume_mm3", "cb_white_matter_mm3",
  "pn_rttg_volume_mm3", "deep_cb_nu_volume_mm3", "cb_ext_surface_esa_mm2",
  "cb_pial_surface_psa_mm2", "foliation_index")
stopifnot(ncol(raw) == length(clean_names))
names(raw) <- clean_names

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))
numeric_cols <- clean_names[4:16]

# Trailing all-blank spreadsheet row.
raw <- raw %>% filter(!is.na(species), nzchar(str_squish(species)))
n_in <- nrow(raw)

## ---- split the printed summary rows away from the observations ----------------------------
## Ashwell labels them on the COMMON name, not the binomial ("Platypus mean", "Short-beaked
## echidna SD"), which is why they are matched on a trailing mean/SD and rejoined via
## common_name rather than species.
is_summary <- str_detect(raw$species, regex("\\s+(mean|SD)$"))
printed    <- raw[is_summary, ] %>%
  mutate(stat = str_extract(species, "(mean|SD)$"), across(all_of(numeric_cols), num))
dat        <- raw[!is_summary, ]

## ---- observations: keep every printed specimen row ---------------------------------------
clean <- dat %>%
  mutate(
    species_as_published = str_squish(species),
    specimen_number      = suppressWarnings(
                             as.integer(str_match(species_as_published, "\\s(\\d+)$")[, 2])),
    species              = str_squish(str_replace(species_as_published, "\\s+\\d+$", "")),
    row_type             = if_else(is.na(specimen_number), "species", "specimen"),
    across(all_of(numeric_cols), num)) %>%
  group_by(species) %>% mutate(n_specimen_rows = n()) %>% ungroup() %>%
  mutate(source = "Ashwell__2020") %>%
  relocate(group, species, common_name, species_as_published, specimen_number,
           row_type, n_specimen_rows) %>%
  arrange(group, species, specimen_number)

# Guard: the collapse this script used to do must not creep back in, and the specimen blocks
# must survive intact.
stopifnot(
  nrow(clean) == n_in - nrow(printed),
  !anyDuplicated(paste(clean$species, clean$specimen_number)),
  sum(clean$row_type == "specimen") == 6L,
  all(c("Ornithorhynchus anatinus", "Tachyglossus aculeatus") %in%
        clean$species[clean$n_specimen_rows == 3L]))

message("Ashwell: ", n_in, " snapshot rows -> ", nrow(clean), " observation rows across ",
        dplyr::n_distinct(clean$species), " species (",
        sum(clean$row_type == "specimen"), " per-specimen rows kept; ",
        nrow(printed), " printed mean/SD rows moved to the reconciliation file)")
write.csv(clean, "Ashwell__2020_SupplementaryTable.csv", row.names = FALSE)

## ---- reconciliation: Ashwell's printed mean/SD vs the specimen rows -----------------------
## Not data: a check that the specimen rows we keep are the ones his published summary was
## built from, so the merge can reproduce his species value. Ratios and the foliation index
## are means OF RATIOS here (that is how he printed them), not ratios of the means.
recomputed <- clean %>%
  filter(n_specimen_rows > 1L) %>%
  group_by(common_name, species) %>%
  summarise(n_specimens = dplyr::n(),
            across(all_of(numeric_cols),
                   list(mean = ~ mean(.x, na.rm = TRUE), SD = ~ sd(.x, na.rm = TRUE))),
            .groups = "drop") %>%
  pivot_longer(-c(common_name, species, n_specimens),
               names_to = c("variable", "stat"), names_pattern = "^(.*)_(mean|SD)$",
               values_to = "recomputed") %>%
  mutate(recomputed = ifelse(is.nan(recomputed), NA_real_, recomputed))

# Ashwell prints 3 significant figures. "Does the printed summary equal our recomputation?"
# is therefore a question about signif(), not about equality.
n_sig <- function(x) {
  s <- sub("^-", "", format(x, scientific = FALSE, trim = TRUE))
  s <- sub("\\.", "", s)                 # digits only
  s <- sub("^0+", "", s)                 # leading zeros are not significant
  pmax(1L, nchar(sub("0+$", "", s)))
}

reconciliation <- printed %>%
  select(common_name, stat, all_of(numeric_cols)) %>%
  pivot_longer(all_of(numeric_cols), names_to = "variable", values_to = "printed") %>%
  full_join(recomputed, by = c("common_name", "variable", "stat")) %>%
  mutate(pct_diff = ifelse(is.na(printed) | is.na(recomputed) | recomputed == 0,
                           NA_real_, 100 * (printed - recomputed) / recomputed),
         agrees_at_printed_precision = !is.na(printed) & !is.na(recomputed) &
           abs(printed - signif(recomputed, n_sig(printed))) < 1e-9) %>%
  select(species, common_name, variable, stat, n_specimens, printed, recomputed,
         pct_diff, agrees_at_printed_precision) %>%
  arrange(species, variable, stat)
write.csv(reconciliation, "Ashwell__2020_published_mean_reconciliation.csv", row.names = FALSE)

bad <- reconciliation %>% filter(!is.na(pct_diff), abs(pct_diff) > 1)
message("Reconciliation: ", nrow(reconciliation), " printed-vs-recomputed comparisons; ",
        nrow(bad), " differ by >1% ",
        if (nrow(bad)) paste0("(", paste(unique(bad$variable), collapse = ", "), ")") else "")

## ---- also write the DOI-coded TSV to __Public/comparative-data/ (consumed by __merging_volumes; skipped if shared repo absent) ----
tsv_dir <- file.path(base, "__Public/comparative-data")
enc <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(enc) || !nzchar(enc)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file = file.path(tsv_dir, paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
}
