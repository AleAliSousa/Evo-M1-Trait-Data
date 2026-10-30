## Crile G, Quiring DP (1940). A record of the body weight and certain organ and gland weights of
## 3690 animals. Ohio J Sci 40(5):219-259. Main table, ALL MAMMAL sections (journal pp. 227-233, 238-243, 245-259).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Non-mammal sections (invertebrates, amphibia, birds, fishes, reptiles; pp. 221-226, 233-237, 244) are not transcribed.
## Rows are the authors' per-lot records (n animals per row), NOT species means; the same species recurs by age/sex/locality.
##
## Input : Crile_Quiring_1940_Table1_snapshot.csv  (hand transcription from the PDF)
## Output: <script stem>.csv                 one row per printed data row
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

options(scipen = 999)
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
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- "Crile_Quiring_1940"
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA"), encoding = "UTF-8", colClasses = "character")

## footnote/caption rows printed across the table ("Data from Journal of Agricultural Research ...",
## "*Data furnished by the Bureau Animal Industry ...") carry no values: dropped from the clean CSV
is_note <- is.na(snap[["No. of Animals"] ]) & is.na(snap$Brain) & is.na(snap[["Body Weight in Kilograms"]]) & is.na(snap$Heart)
notes <- snap[is_note, ]
snap  <- snap[!is_note, ]

## numeric parse; "6 est." / "750 est." keep the number and are flagged; thousands commas ("10,120.") removed
estf <- function(x) grepl("est", x, ignore.case = TRUE)
num  <- function(x) suppressWarnings(as.numeric(sub("\\s*est\\.?$", "", gsub(",", "", trimws(as.character(x))))))

## ---- split "Common name / Scientific name"; fill dittos (curly quotes) from the row above ----
nm   <- trimws(snap[["Common and Scientific Name"]])
is_d <- grepl("^\u201c", nm)
common <- character(nrow(snap)); sci <- character(nrow(snap))
for (i in seq_len(nrow(snap))) {
  if (is_d[i]) {
    rest <- trimws(gsub("\u201c", "", nm[i]))
    prev <- common[i - 1]
    common[i] <- if (!nzchar(rest)) prev else if (startsWith(rest, "(")) paste(prev, rest) else paste(strsplit(prev, " ")[[1]][1], rest)
    sci[i] <- sci[i - 1]
  } else {
    p <- strsplit(nm[i], " / ", fixed = TRUE)[[1]]
    common[i] <- p[1]
    sci[i] <- if (length(p) > 1) p[2] else NA_character_
    ## continuation across a page/block break: scientific name not reprinted for the same common name
    if (is.na(sci[i]) && i > 1 && common[i] == common[i - 1]) sci[i] <- sci[i - 1]
  }
}
## the scientific name as printed includes the authority in brackets, e.g. "Ateles geoffroyi (Kuhl)": kept as printed.
## Rows with no scientific name printed (domestic breeds, human groups, some dog/cow/horse rows) stay NA.

rem <- trimws(snap$Remarks)
age <- ifelse(grepl("Infant", rem), "Infant", ifelse(grepl("Juvenile", rem), "Juvenile",
       ifelse(grepl("Adult", rem), "Adult", NA)))

## ---- clean (body weight kg; organ weights as printed, presumably g: header gives units only for body weight) ----
clean <- data.frame(
  section            = trimws(snap$Section),
  catalogue_number   = trimws(snap[["Catalogue Number"]]),
  n_animals          = num(sub("\\*$", "", snap[["No. of Animals"]])),
  n_animals_footnote = grepl("\\*$", snap[["No. of Animals"]]),
  sex                = trimws(snap$Sex),
  common_name        = common,
  species            = sci,
  body_weight_kg     = num(snap[["Body Weight in Kilograms"]]),
  brain_g            = num(snap$Brain),
  thyroid_g          = num(snap$Thyroid),
  adrenal_g          = num(snap$Adrenal),
  heart_g            = num(snap$Heart),
  liver_g            = num(snap$Liver),
  eyes_g             = num(snap$Eyes),
  kidney_g           = num(snap$Kidney),
  lung_g             = num(snap$Lung),
  spleen_g           = num(snap$Spleen),
  stomach_intestines_g = num(snap[["Stomach and Intestines"]]),
  est_flag           = estf(snap[["Body Weight in Kilograms"]]) | estf(snap$Brain) | estf(snap$Thyroid) | estf(snap$Adrenal),
  age_class          = age,
  remarks            = rem,
  journal_page       = snap[["Journal page"]],
  row_flag           = NA_character_,
  source             = source_name,
  stringsAsFactors = FALSE
)

## ---- flags and exact-duplicate handling ----
valcols <- c("n_animals","sex","body_weight_kg","brain_g","thyroid_g","adrenal_g","heart_g","liver_g","eyes_g","kidney_g","lung_g","spleen_g","stomach_intestines_g")
nval <- rowSums(!is.na(clean[, valcols[-(1:2)]]))
key  <- do.call(paste, c(clean[, valcols], sep = "|"))
dup_of <- rep(NA_integer_, nrow(clean))
for (i in seq_len(nrow(clean))) if (nval[i] >= 3) {
  j <- which(key[seq_len(i - 1)] == key[i])
  if (length(j)) dup_of[i] <- j[1]
}
clean$row_exact_duplicate <- !is.na(dup_of)
clean$row_flag[!is.na(dup_of)] <- paste0("identical in every value to snapshot row ", dup_of[!is.na(dup_of)] + 0L)
clean$snapshot_row <- seq_len(nrow(clean))
dups_dropped <- clean[!is.na(dup_of), c("snapshot_row","journal_page","common_name","n_animals","brain_g")]
dups_dropped$identical_to_snapshot_row <- dup_of[!is.na(dup_of)]   # snapshot data-row numbers (header = row 0, note rows not counted)
if (nrow(dups_dropped)) { message("Exact duplicates (kept, flagged):"); print(dups_dropped) }
write.csv(dups_dropped, paste0(item_name, "_exact_duplicates.csv"), row.names = FALSE)
## owner ruling 2026-10-21: exact duplicates are KEPT in the clean CSV (flagged in row_flag / row_exact_duplicate); reduce downstream by choice

## printed repeats that are NOT identical in every value are kept and flagged (see README)
setflag <- function(cond, msg) clean$row_flag[cond & is.na(clean$row_flag)] <<- msg
setflag(clean$catalogue_number %in% "93A" & clean$common_name == "Vervet",
        "near-repeat of the Monkey, Grey cat. 93A row (p. 239; body 1.22 vs 1.225, adrenal .22 vs .220) but printed under Vervet")
setflag(clean$common_name == "Spider, Black" & clean$brain_g %in% c(108.8, 118.4),
        "near-repeat of the Monkey, Night row printed above it (brain 109 / 118 vs 108.8 / 118.4) but printed under Spider, Black")
## values that look odd but were re-read against the render and match the print
setflag(clean$common_name == "Cheetah" & clean$brain_g %in% 2.449, "brain 2.449 as printed (implausibly small for a cheetah; possibly 244.9)")
setflag(clean$common_name == "Bear, American", "adrenal 25.0 vs heart 6.0 as printed (column order suspicious); body and brain blank")
setflag(clean$catalogue_number %in% "153A", "eyes 344 as printed (probably 3.44)")
setflag(clean$common_name == "Lemming, Brown" & clean$kidney_g %in% 44.04, "kidney 44.04 as printed (probably .4404)")
setflag(clean$common_name == "Hyena, Spotted", "lung 6809 and stomach 6804 as printed")
setflag(clean$common_name == "Monkey, Night" & is.na(clean$catalogue_number) & clean$n_animals == 1, NA_character_)

## ---- safe species assignments for rows with no printed scientific name (owner ruling 2026-10-21) ----
## The printed `species` stays exactly as printed (blank where none). `species_assigned` fills ONLY blanks, from
## reference_tables/Crile_Quiring_1940_Table1_species_assignments.csv (common name -> species, basis, confidence,
## domestic flag). Not assigned: Mule (hybrid). Domestic taxa are flagged so the domestication-pooling decision stays downstream.
asg <- read.csv("reference_tables/Crile_Quiring_1940_Table1_species_assignments.csv", stringsAsFactors = FALSE)
blank <- is.na(clean$species) | !nzchar(trimws(clean$species))
mi <- match(clean$common_name, asg$common_name)
use <- blank & !is.na(mi)
clean$species_assigned            <- ifelse(use, asg$species_assigned[mi], NA)
clean$species_assigned_basis      <- ifelse(use, asg$basis[mi], NA)
clean$species_assigned_confidence <- ifelse(use, asg$confidence[mi], NA)
clean$species_assigned_domestic   <- ifelse(use, asg$domestic[mi], NA)

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
