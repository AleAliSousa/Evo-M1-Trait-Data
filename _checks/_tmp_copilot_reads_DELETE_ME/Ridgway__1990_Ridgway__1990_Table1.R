# Ridgway__1990_Table1.R
#
# Turn the journal-faithful snapshot of Ridgway (1990) Table 1 -- "Brain and
# Body Size of Adult Bottlenose Dolphins" -- into a lean, analysis-ready long
# CSV (one row per individual specimen, plus the printed per-group Mean/S.D.
# summary rows kept as their own flagged rows). Output comes from the
# snapshot only.
#
# Source table reports, for adult Tursiops truncatus grouped into three
# geographic categories (E. North Atlantic and Mediterranean; E. North
# Pacific; W. North Atlantic coastal, incl. Gulf of Mexico):
#   BdL  = body length, cm
#   BdW  = body weight, kg
#   BrnW = brain weight, kg
#   Sex, Source (literature citation per animal)
# plus a printed Mean and S.D. row per geographic category.
#
# Input  : Ridgway__1990_Table1_snapshot.csv
# Outputs: Ridgway__1990_Table1.csv                one row per individual
#          + one Mean/S.D. row pair per category (35 rows total)
#          <DOI>_Table1.tsv in __Public/comparative-data/  (registry key)

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # = "Ridgway__1990_Table1"
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot_path <- file.path(folder, paste0(item_name, "_snapshot.csv"))
out_path      <- file.path(folder, paste0(item_name, ".csv"))

## ---- read the frozen snapshot (skip title line + footnote block) ----
## The snapshot preserves the printed layout: a title line, a blank line, the
## header row, one row per animal (category printed only on the first row of
## each group, as in the source), a Mean row and an S.D. row per group, a
## blank line, then the lettered footnote. Read only the data block.
raw <- read_csv(snapshot_path, skip = 2, n_max = 33, show_col_types = FALSE,
                 col_names = c("Category", "Sex", "BdL_cm", "BdW_kg", "BrnW_kg", "Source"))

## ---- carry the category label down through its group (printed once per group) ----
raw <- raw %>%
  mutate(Category = if_else(Category == "" | is.na(Category), NA_character_, Category)) %>%
  tidyr::fill(Category, .direction = "down")

## ---- split individuals vs. the printed Mean/S.D. summary rows ----
is_summary <- raw$Sex %in% c("Mean", "S.D.")

individuals <- raw %>%
  filter(!is_summary) %>%
  transmute(
    species = "Tursiops truncatus", species_sci = "Tursiops truncatus",
    geographic_category = Category, row_type = "individual",
    sex = na_if(Sex, ""), body_length_cm = BdL_cm, body_weight_kg = BdW_kg,
    brain_weight_kg = BrnW_kg, n = NA_integer_, source = Source
  )

## group n = number of individual rows already tallied per category, used on
## the Mean/S.D. rows (printed table gives no explicit n; count them instead)
n_by_group <- individuals %>% count(geographic_category, name = "n_group")

summary_rows <- raw %>%
  filter(is_summary) %>%
  left_join(n_by_group, by = c("Category" = "geographic_category")) %>%
  transmute(
    species = "Tursiops truncatus", species_sci = "Tursiops truncatus",
    geographic_category = Category,
    row_type = if_else(Sex == "Mean", "group_mean", "group_sd"),
    sex = NA_character_, body_length_cm = BdL_cm, body_weight_kg = BdW_kg,
    brain_weight_kg = BrnW_kg, n = n_group, source = NA_character_
  )

result <- bind_rows(individuals, summary_rows)

## ---- checks: group means recompute within rounding of the printed values ----
recomputed <- individuals %>%
  group_by(geographic_category) %>%
  summarise(mean_BdW = round(mean(body_weight_kg), 0),
            mean_BrnW = round(mean(brain_weight_kg), 3), .groups = "drop")
printed_means <- summary_rows %>% filter(row_type == "group_mean") %>%
  select(geographic_category, body_weight_kg, brain_weight_kg)
chk <- recomputed %>% left_join(printed_means, by = "geographic_category")
stopifnot(all(abs(chk$mean_BdW - chk$body_weight_kg) <= 1))
stopifnot(all(abs(chk$mean_BrnW - chk$brain_weight_kg) <= 0.01))

write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## ---- public TSV: look up the DOI code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir <- file.path(base, "__Public/comparative-data/")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes    <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
  if (!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(path.expand(tsv_dir))) {
    write.table(result, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
  } else {
    warning("No 'Item encoded' for '", item_name, "' or __Public not mounted; TSV skipped.")
  }
} else {
  warning("__ReadMe.xlsx not found from this folder; TSV skipped.")
}
