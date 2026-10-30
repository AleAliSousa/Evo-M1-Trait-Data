## Iwaniuk_etal_2000_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Iwaniuk, A. N., Pellis, S. M., & Whishaw, I. Q. (2000). The relative importance of body
## size, phylogeny, locomotion, and diet in the evolution of forelimb dexterity in fissiped
## carnivores (Carnivora). Canadian Journal of Zoology, 78(7), 1110-1125. doi:10.1139/z00-023
##
## Table 1 (PDF pp. 1112-1113, rotated landscape pages): N, proximal/distal/total forepaw
## dexterity (own observations, primary), body mass (Nowak 1991 etc.), arboreality and diet
## scores with per-row references (secondary). Snapshot built from the PDF text layer by word
## coordinates (rotation-corrected column binning; the plain text stream is scrambled on
## p. 1112) and verified against 2.5x page renders on 2026-10-28 (AI assistant).
## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Iwaniuk_etal_2000_Table1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen snapshot, read positionally as text) -------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8", check.names = FALSE)

## 2b. SPECIES KEY (collection-scoped: _keys/General; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
lk <- stats::setNames(key$accepted_name, key$variant_name)
harmonise <- function(x) {
  out <- unname(lk[x]); miss <- !is.na(x) & nzchar(x) & is.na(out)
  if (any(miss)) stop("Printed name(s) missing from species_key: ",
                      paste(unique(x[miss]), collapse = "; "), call. = FALSE)
  out
}
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))

## 3. CLEAN -----------------------------------------------------------
## Snapshot layout (positional): row 1 = spanning header "Forepaw dexterity" (cols 4-6),
## row 2 = printed column headers, then "Family ..." group rows and 45 species rows,
## last two rows = table Note and the "*" footnote.
stopifnot(ncol(snap) == 10, nrow(snap) == 58)
family <- NA_character_; recs <- list()
for (i in 3:nrow(snap)) {
  r <- snap[i, ]
  if (startsWith(r[[1]], "Family ") && !nzchar(r[[3]])) { family <- sub("^Family ", "", r[[1]]); next }
  if (!nzchar(r[[3]])) next                                     # Note / footnote rows
  recs[[length(recs) + 1]] <- tibble(
    family = family, species_as_published = r[[1]], common_name = r[[2]],
    N = as.integer(r[[3]]),
    dexterity_proximal = as.integer(r[[4]]),                     # max 8
    dexterity_distal   = as.integer(r[[5]]),                     # max 13
    dexterity_total    = as.integer(r[[6]]),                     # max 21
    body_mass_g        = num(r[[7]]) * 1000,                     # BW (kg) x 1000 -> g
    arboreality        = as.integer(r[[8]]),
    diet_vertebrate_score = as.integer(sub("\\*$", "", r[[9]])),
    diet_estimated     = grepl("\\*$", r[[9]]),                     # "*" footnote
    references         = r[[10]],
    source_row = i)
}
final.dataframe <- bind_rows(recs)
stopifnot(nrow(final.dataframe) == 45)
## printed keys split on "; " and author-elided years expanded ("Rasa 1973, 1977" ->
## "Rasa 1973; Rasa 1977") so ref_keys joins 1:1 on reference_tables/..._references.csv$ref_key
expand_keys <- function(cell) {
  parts <- trimws(strsplit(cell, ";", fixed = TRUE)[[1]])
  out <- unlist(lapply(parts, function(p) {
    m <- regmatches(p, regexec("^(.+?) ((?:19|20)[0-9]{2}[a-z]?(?:, (?:19|20)[0-9]{2}[a-z]?)+)$", p, perl = TRUE))[[1]]
    if (length(m)) paste(m[2], strsplit(m[3], ", ", fixed = TRUE)[[1]]) else p
  }))
  paste(out, collapse = "; ")
}
final.dataframe <- final.dataframe %>%
  mutate(ref_keys = vapply(references, expand_keys, character(1)), .after = references) %>%
  mutate(Species = harmonise(species_as_published), .after = species_as_published) %>%
  mutate(body_mass_source = case_when(
           species_as_published == "Canis familiaris" ~ "average body mass of the three individuals observed (table Note)",
           species_as_published %in% c("Felis margarita", "Leopardus geoffroyi", "Prionailurus rubiginosa") ~
             "alternate sources (Guggisberg 1975 and Johnson and Franklin 1991) (table Note)",
           TRUE ~ "Nowak (1991) (table Note)"), .after = body_mass_g,
         data_role = "both")   # dexterity + N = primary (own filming); BW, Arb, Diet = secondary

## 3b. TABLE CHECKS (HOWTO 7a): Proximal + Distal = Total (integer scores, tolerance 0)
table_checks <- final.dataframe %>%
  transmute(check_id = paste0("total_", species_as_published),
            basis = "Proximal (8) + Distal (13) vs printed Total (21)",
            observed = dexterity_proximal + dexterity_distal, printed = dexterity_total,
            difference = observed - printed, tolerance = 0,
            status = ifelse(difference == 0, "pass", "mismatch"),
            note = "integer scores; values kept as printed")
if (any(table_checks$status == "mismatch"))
  warning("Table check mismatch(es): ", paste(table_checks$check_id[table_checks$status == "mismatch"], collapse = ", "), call. = FALSE)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write_csv(final.dataframe, final_csv, na = "")                       # readr: always UTF-8
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]

  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
if (exists("table_checks") && any(table_checks$status != "pass"))
  print(as.data.frame(table_checks[table_checks$status != "pass", c("check_id","observed","printed","difference","tolerance","status")]))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
