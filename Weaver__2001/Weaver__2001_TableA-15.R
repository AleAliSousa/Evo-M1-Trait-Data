## Weaver__2001 — Table A-15: Data for Raw and Derived Variables
## Weaver, A. G. H. (2001). The cerebellum and cognitive evolution in Pliocene
## and Pleistocene hominids. PhD dissertation, University of New Mexico. (UMI 3017523)
##
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful; ALL cleaning
## (parse n, unit conversion, group-code expansion) happens here.
##
## The source page is a scan; the snapshot was transcribed from a high-resolution
## render of the page and cross-checked by the identity NetBrain = BrMass - CBLM
## (holds for every row within rounding).
##
## Raw variables (Table 11-1): CBLM (cerebellum volume, cc), BoMass (body mass, kg),
## BrMass (brain mass, g). Derived (Table 11-2): NetBrain = BrMass - CBLM;
## CQ = cerebellar quotient (actual/predicted); EQ = encephalization quotient
## (Martin 1990). CQ/EQ are relative indices, kept for provenance and flagged.

options(scipen = 999)

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
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## positional read: row 1 = caption, row 2 = header, rows 3+ = data
raw <- read.csv("Weaver__2001_TableA-15_snapshot.csv", header = FALSE, skip = 2,
                colClasses = "character", check.names = FALSE,
                stringsAsFactors = FALSE, na.strings = c("", "NA"))
names(raw) <- c("Specimen", "Group", "CBLM_cc", "BoMass_kg",
                "BrMass_g", "NetBrain_g", "CQ", "EQ")

as_num <- function(x) suppressWarnings(as.numeric(x))

## sample size printed as "(n = 4)" for the extant taxon means; fossils are single
n_ind         <- as.integer(sub(".*\\(n\\s*=\\s*([0-9]+)\\).*", "\\1", raw$Specimen))
n_ind[!grepl("\\(n\\s*=", raw$Specimen)] <- NA_integer_
specimen_clean <- trimws(sub("\\s*\\(n\\s*=\\s*[0-9]+\\)\\s*", "", raw$Specimen))

## group-code expansion (grouping follows Weaver 2001; expanded from the printed code)
group_label <- c(
  "01-NW"  = "New World monkeys",       "02-OW"  = "Old World monkeys",
  "03-Hy"  = "Hylobates (gibbon)",      "04-Po"  = "Pongo (orangutan)",
  "05-Go"  = "Gorilla",                 "06-Bo"  = "Bonobo (Pan paniscus)",
  "07-PanS"= "Pan (chimpanzee)",        "08-Aust"= "Australopithecus",
  "09-HH"  = "Homo habilis",            "10-HE"  = "Homo erectus",
  "11-EAH" = "Early Archaic Homo sapiens",
  "12-LAH" = "Late Archaic Homo sapiens (Neanderthals)",
  "13-EMH" = "Early Modern Homo sapiens",
  "14-RH"  = "Recent Homo sapiens"
)

clean <- data.frame(
  Specimen         = specimen_clean,
  Specimen_printed = raw$Specimen,
  Group_code       = raw$Group,
  Group_label      = unname(group_label[raw$Group]),
  n                = n_ind,
  CBLM_cc          = as_num(raw$CBLM_cc),
  CBLM_Vol.mm3     = round(as_num(raw$CBLM_cc) * 1000),      # cc -> mm3
  BoMass_kg        = as_num(raw$BoMass_kg),
  Body_Mass.g      = round(as_num(raw$BoMass_kg) * 1000),    # kg -> g
  BrMass_g         = as_num(raw$BrMass_g),
  Brain_Mass.mg    = round(as_num(raw$BrMass_g) * 1000),     # g -> mg
  NetBrain_g       = as_num(raw$NetBrain_g),
  NetBrain_Mass.mg = round(as_num(raw$NetBrain_g) * 1000),   # g -> mg
  CQ               = as_num(raw$CQ),                         # cerebellar quotient (actual/predicted)
  EQ               = as_num(raw$EQ),                         # encephalization quotient (Martin 1990)
  source           = "Weaver__2001",
  stringsAsFactors = FALSE
)

stopifnot(nrow(clean) == 29L)
stopifnot(!any(is.na(clean$Group_label)))
## sanity: NetBrain should equal BrMass - CBLM (within rounding)
stopifnot(all(abs(clean$NetBrain_g - (clean$BrMass_g - clean$CBLM_cc)) < 0.05))

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(clean, tsv_file, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_file)
}
