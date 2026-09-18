## Manger PR (2006). An examination of cetacean brain structure with a novel
## hypothesis correlating thermogenesis to the evolution of a big brain.
## Biol Rev 81(3):293-338. Table 1, pp. 296-297.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Why the snapshot was rebuilt (2026-09-17). The July snapshot held only the 34
## extant species and turned the printed section, suborder and family headings
## into repeated columns, so it could not be read side by side with the page.
## The snapshot is now the whole printed table: 108 rows, 18 of them the printed
## heading rows, in printed order, with the printed column order and the printed
## thousands spacing. The headings are unnested here, in the build, which is
## where reshaping belongs.
##
## Scope. The printed table covers four sections - Eocene Archaeoceti, Oligocene,
## Miocene and extant cetaceans. Only the extant section becomes rows here. The
## fossil sections are a different observation level: one row per specimen rather
## than per species, many of them "indet. indet." or open nomenclature, and no
## water temperature. They are in the frozen snapshot so nothing is lost, and
## they would make a separate item with its own definitions.
##
## Input : Manger__2006_Table1_snapshot.csv
## Output: <script stem>.csv   one row per extant species (34)
##         <Item encoded>.tsv in __Public/comparative-data/
##
## SECONDARY DATA. Every brain and body mass in this table is taken from another
## paper - the Source column keys into the caption's list of ten references, and
## the caption says so. Set Data role = secondary in __ReadMe.xlsx and keep this
## item out of the merges; the primaries are in
## reference_tables/Manger__2006_Table1_references.csv.

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
folder       <- dirname(.sp)
item_name    <- tools::file_path_sans_ext(basename(.sp))
source_name  <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv   <- paste0(item_name, ".csv")
base         <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8")
snap[is.na(snap)] <- ""
stopifnot(ncol(snap) == 6L, nrow(snap) == 108L, names(snap)[1] == "Species")

## ---- unnest the printed heading rows ----
## A heading row is one with a label and no values. Three ranks appear:
## the four period sections, "Suborder X", and everything else is a family.
sections <- c("Eocene Archaeoceti", "Oligocene cetaceans",
              "Miocene cetaceans", "Extant cetaceans")
lab     <- trimws(snap[[1]])
is_head <- !nzchar(trimws(snap[[2]]))
stopifnot(sum(is_head) == 18L, all(sections %in% lab[is_head]))

section <- suborder <- family <- rep(NA_character_, nrow(snap))
cs <- csub <- cfam <- NA_character_
for (i in seq_len(nrow(snap))) {
  if (is_head[i]) {
    if (lab[i] %in% sections)              { cs <- lab[i]; csub <- NA_character_; cfam <- NA_character_ }
    else if (grepl("^Suborder ", lab[i]))  { csub <- sub("^Suborder ", "", lab[i]); cfam <- NA_character_ }
    else                                    cfam <- lab[i]
  }
  section[i] <- cs; suborder[i] <- csub; family[i] <- cfam
}

keep <- which(!is_head & section == "Extant cetaceans")
stopifnot(length(keep) == 34L, !anyNA(family[keep]), !anyNA(suborder[keep]))

## ---- values ----
## The printed table separates thousands with a space ("1 578 330"), uses an en
## dash for ranges ("9-17") and a Unicode minus for sub-zero temperatures.
num <- function(x) suppressWarnings(as.numeric(gsub("[   ]", "", trimws(x))))
split_range <- function(x, which) {
  x <- gsub("−", "-", trimws(x))                  # Unicode minus -> ASCII
  out <- rep(NA_real_, length(x))
  has <- nzchar(x)
  parts <- regmatches(x[has], regexpr("^(-?[0-9]+)[–-](-?[0-9]+)$", x[has]))
  stopifnot(length(parts) == sum(has))                  # every non-blank is a range
  m <- regmatches(x[has], regexec("^(-?[0-9]+)[–-](-?[0-9]+)$", x[has]))
  out[has] <- as.numeric(vapply(m, `[`, character(1), which + 1L))
  out
}

brain_g <- num(snap[[2]][keep])
body_g  <- num(snap[[3]][keep])
stopifnot(!anyNA(brain_g), !anyNA(body_g))

clean <- data.frame(
  species_as_published                  = lab[keep],
  suborder                              = suborder[keep],
  family                                = family[keep],
  brain_mass_mg                         = as.integer(round(brain_g * 1000)),  # project unit
  brain_mass_g_as_published             = brain_g,
  body_mass_g                           = body_g,                             # already the project unit
  encephalisation_quotient_as_published = num(snap[[4]][keep]),
  water_temp_min_c                      = split_range(snap[[5]][keep], 1),
  water_temp_max_c                      = split_range(snap[[5]][keep], 2),
  source_ref_key                        = as.integer(num(snap[[6]][keep])),
  source                                = source_name,
  stringsAsFactors = FALSE
)

stopifnot(all(clean$source_ref_key %in% 1:10))          # the caption's key runs 1-10
stopifnot(all(is.na(clean$water_temp_min_c) == is.na(clean$water_temp_max_c)))
stopifnot(all(clean$water_temp_min_c <= clean$water_temp_max_c, na.rm = TRUE))
stopifnot(sum(clean$suborder == "Odontocete") == 29L,
          sum(clean$suborder == "Mysticete")  == 5L)

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
