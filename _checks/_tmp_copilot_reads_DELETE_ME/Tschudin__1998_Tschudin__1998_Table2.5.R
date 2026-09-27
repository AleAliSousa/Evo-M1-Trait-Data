# Tschudin__1998_Table2.5.R
#
# Turn the journal-faithful snapshot of Tschudin (1998) Table 2.5 --
# "Odontocete neuroanatomical volumes and ratios from MRI" -- into a lean,
# analysis-ready CSV (one row per specimen). Output comes from the snapshot
# only.
#
# The printed table gives, per MRI-scanned specimen: total brain volume,
# neocortex volume, posterior fossa volume (= brainstem + cerebellum),
# brainstem volume, cerebellum volume (all cm3), and a neocortex ratio
# (neocortex volume / posterior fossa volume).
#
# Input  : Tschudin__1998_Table2.5_snapshot.csv
# Outputs: Tschudin__1998_Table2.5.csv                one row per specimen (44 rows)
#          <ID>_Table2.5.tsv in __Public/comparative-data/  (registry key)

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # = "Tschudin__1998_Table2.5"
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot_path <- file.path(folder, paste0(item_name, "_snapshot.csv"))
out_path      <- file.path(folder, paste0(item_name, ".csv"))

## ---- species lookup: abbreviation -> binomial + common name (printed
## appendix table of abbreviations, dissertation p. 84) ----
species_map <- tribble(
  ~prefix, ~species_sci,               ~common_name,
  "BOT",   "Tursiops truncatus",       "bottlenose dolphin",
  "COM",   "Delphinus delphis",        "common dolphin",
  "HUM",   "Sousa chinensis",          "Indo-Pacific humpback dolphin",
  "SPO",   "Stenella attenuata",       "spotted dolphin",
  "STR",   "Stenella coeruleoalba",    "striped dolphin",
  "FRA",   "Lagenodelphis hosei",      "Fraser's dolphin",
  "RIS",   "Grampus griseus",          "Risso's dolphin",
  "DWA",   "Kogia simus",              "dwarf sperm whale"
)

## ---- read the frozen snapshot (skip title line + blank; stop before the
## trailing note paragraph) ----
## Locate the block by content rather than fixed skip/n_max: `skip = 2` read the
## printed header row as data, which made every volume column text ("non-numeric
## argument to binary operator" in the checks) and pushed the last subject (DWA 1)
## past n_max. The data block is the header line through the next blank line.
lines <- readLines(snapshot_path, warn = FALSE, encoding = "UTF-8")
hdr_i <- grep("^Subject,", lines)
if (length(hdr_i) != 1L) stop("Expected one 'Subject,...' header line in ", basename(snapshot_path), call. = FALSE)
blank <- which(!nzchar(trimws(lines)) & seq_along(lines) > hdr_i)
end_i <- if (length(blank)) blank[1] - 1L else length(lines)
raw <- read_csv(I(paste(lines[(hdr_i + 1L):end_i], collapse = "\n")), col_names = FALSE,
                na = c("", "-"), show_col_types = FALSE,
                col_types = cols(X1 = col_character(), .default = col_double()))
names(raw) <- c("Subject", "TBV", "NCV", "PFV", "BSV", "CBV", "Ratio")
stopifnot(nrow(raw) == 44L)   # 44 printed subject rows (incl. the two "HUM 7" rows)

## ---- keep the printed subject labels verbatim, including the duplicate
## "HUM 7" (the source prints two distinct rows under the same label with
## different values -- not a transcription artefact; see README). Flag it
## via `note` rather than silently renumbering the label. ----
raw <- raw %>% mutate(row_order = row_number()) %>% group_by(Subject) %>%
  mutate(dup = row_number()) %>% ungroup() %>% arrange(row_order)

result <- raw %>%
  mutate(prefix = str_extract(Subject, "^[A-Z]+")) %>%
  left_join(species_map, by = "prefix") %>%
  transmute(
    subject_id = Subject,
    species_sci = species_sci,
    common_name = common_name,
    total_brain_volume_cm3 = TBV,
    neocortex_volume_cm3 = NCV,
    posterior_fossa_volume_cm3 = PFV,
    brainstem_volume_cm3 = BSV,
    cerebellum_volume_cm3 = CBV,
    neocortex_ratio = Ratio,
    note = case_when(
      Subject == "HUM 7" & dup > 1 ~ "Printed as a second, distinct 'HUM 7' row in the source table (duplicate subject label as printed; kept verbatim, not renumbered)",
      Subject == "HUM 2"           ~ "Brainstem and cerebellum volume printed as '-' (not reported) in the source",
      Subject == "HUM 5"           ~ "Source prints total brain volume 1230.40 cm3, 0.40 cm3 above neocortex + posterior fossa (949.00 + 281.00 = 1230.00) -- as printed (p. 59), kept, not corrected",
      Subject == "BOT 9"           ~ "Source prints posterior fossa volume 10.00 cm3 higher than brainstem+cerebellum sum (296.34 vs. 286.34) -- a genuine inconsistency in the published table, verified against the page image and kept as printed, not corrected",
      TRUE ~ NA_character_
    )
  )

## ---- checks: total = neocortex + posterior fossa; posterior fossa =
## brainstem + cerebellum; neocortex ratio = neocortex / posterior fossa.
## Tolerance is generous (rounding in a hand-tabulated 1998 print table) --
## BOT 9 is a genuine printed inconsistency (posterior fossa is 10.00 cm3
## higher than brainstem+cerebellum) and is deliberately NOT within the
## tighter tolerance; see README, not corrected here. ----
chk <- result %>%
  mutate(
    sum_diff = abs((neocortex_volume_cm3 + posterior_fossa_volume_cm3) - total_brain_volume_cm3),
    ratio_diff = abs((neocortex_volume_cm3 / posterior_fossa_volume_cm3) - neocortex_ratio)
  )
## HUM 5 added 2026-09-27: its printed total (1230.40) is 0.40 cm3 above 949.00 + 281.00;
## the dissertation's own Table 2.5 (p. 59) prints exactly these values. This was never
## reached before because the read step failed first (header row read as data).
stopifnot(all(chk$sum_diff < 0.1 | chk$subject_id %in% c("BOT 9", "HUM 5")))
stopifnot(all(chk$ratio_diff < 0.03))

write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## ---- public TSV: look up the DOI/CorpusID code from __ReadMe.xlsx ----
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
