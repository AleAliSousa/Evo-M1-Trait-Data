## Van Essen & Drury 1997, J Neurosci 17(18):7079-7102 -- surface-area values printed in the Results text
## doi:10.1523/JNEUROSCI.17-18-07079.1997 · surface-based atlas of the Visible Man (one adult male cadaver).
## Frozen source: VanEssen_Drury_1997_Text_snapshot.csv, the curator's transcription of every area
##   value in the Results text (owner update 9 Nov 2026; checked 09112026 AdS). This script only reads it.
## Rows (13): Visible Man V1 and estimated visual cortex (left/right); macaque case 79-0 neocortex and
##   buried cortex (reconstruction from Drury et al. 1996a); buried, frontal and occipital shares,
##   macaque vs Visible Man; the two human V1 ranges the authors cite (Stensaas et al. 1974;
##   Filiminoff 1932) -- citations only, not case-level data.
## Text checks: the printed percentages are recomputed from the hemisphere totals in Table 1 of the
##   same paper (frozen VanEssen_Drury_1997_Table1_snapshot.xlsx), and the snapshot's mm2 columns
##   from its cm2 columns. Values are never changed; results are left in `table_checks`.
## Table 1 itself is the separate item VanEssen_Drury_1997_Table1.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)      # source("…/file.R")
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, source() it, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))            # VanEssen_Drury_1997_Text
publication <- sub("_Text$", "", item_name)                      # VanEssen_Drury_1997
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

## ---- 1. Read the frozen snapshot (all values as printed; blanks stay blank) ----
snap <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), stringsAsFactors = FALSE,
                 na.strings = "", check.names = FALSE, encoding = "UTF-8")
expected <- c("Species", "common_name", "specimen", "structure", "hemisphere", "method",
              "range_min_cm2_as_printed", "range_max_cm2_as_printed", "range_min_mm2", "range_max_mm2",
              "area_cm2", "pct_neocortex", "where_in_paper", "data_role", "source_note", "cited_primary")
if (!identical(names(snap), expected))
  stop("Snapshot columns changed; update this reader. Found: ", paste(names(snap), collapse = ", "), call. = FALSE)
message(item_name, ": snapshot has ", nrow(snap), " rows")

num <- function(x) suppressWarnings(as.numeric(x))

## ---- 2. Analysis table: printed values kept; mm2 recomputed from cm2 (x 100) ----
final.dataframe <- data.frame(
  Species        = snap$Species,
  common_name    = snap$common_name,
  specimen       = snap$specimen,
  structure      = snap$structure,
  hemisphere     = snap$hemisphere,
  method         = snap$method,
  area_cm2       = num(snap$area_cm2),
  area_mm2       = num(snap$area_cm2) * 100,
  range_min_cm2  = num(snap$range_min_cm2_as_printed),
  range_max_cm2  = num(snap$range_max_cm2_as_printed),
  range_min_mm2  = num(snap$range_min_cm2_as_printed) * 100,
  range_max_mm2  = num(snap$range_max_cm2_as_printed) * 100,
  pct_neocortex  = num(snap$pct_neocortex),
  where_in_paper = snap$where_in_paper,
  data_role      = snap$data_role,
  cited_primary  = snap$cited_primary,
  source_note    = snap$source_note,
  source         = item_name,
  stringsAsFactors = FALSE, check.names = FALSE
)

## ---- 3. Row flags (what a merge must know before using a row) ----
append_flag <- function(x, flag) ifelse(is.na(x) | !nzchar(x), flag, paste(x, flag, sep = "|"))
append_note <- function(x, note) ifelse(is.na(x) | !nzchar(x), note, paste(x, note, sep = " "))
final.dataframe$source_flags <- ""
final.dataframe$source_issue_note <- ""
fd <- final.dataframe
cited  <- !is.na(fd$cited_primary) & nzchar(fd$cited_primary)
vman   <- fd$Species == "Homo sapiens" & !cited
mac    <- fd$Species == "Macaca sp."
v1_vm  <- vman & fd$structure == "V1"
mac72  <- mac & fd$structure == "cerebral neocortex"

fd$source_flags[vman] <- append_flag(fd$source_flags[vman], "single_atlas_individual")
fd$source_issue_note[vman] <- append_note(fd$source_issue_note[vman],
  "Visible Man values come from one adult male cadaver digital atlas and do not estimate population variance.")
fd$source_flags[v1_vm] <- append_flag(fd$source_flags[v1_vm], "secondary_value")
fd$source_issue_note[v1_vm] <- append_note(fd$source_issue_note[v1_vm],
  "Average-sized V1 from Rademacher et al. (1993, 20 hemispheres) mapped onto this atlas.")
fd$source_flags[cited] <- append_flag(fd$source_flags[cited], "secondary_citation_range|not_case_level")
fd$source_issue_note[cited] <- append_note(fd$source_issue_note[cited],
  "Range quoted from the cited primary paper; reference provenance only, do not pool with case-level V1 areas.")
fd$source_flags[mac] <- append_flag(fd$source_flags[mac], "secondary_reconstruction|single_case|species_unspecified")
fd$source_issue_note[mac] <- append_note(fd$source_issue_note[mac], paste0(
  "Case 79-0 is the right hemisphere reconstructed in Drury et al. (1996a), a commercially acquired ",
  "macaque brain of unknown species (Carolina Biological, Burlington, NC)."))
fd$source_flags[mac72] <- append_flag(fd$source_flags[mac72], "denominator_includes_non_neocortex")
fd$source_issue_note[mac72] <- append_note(fd$source_issue_note[mac72], paste0(
  "72 cm2 is the whole case 79-0 reconstruction: Drury et al. (1996a) give 72 cm2 in the text and, in ",
  "Table 2, 7,205 mm2 total cerebral cortex of which neocortex is 6,878 mm2 (hippocampal formation ",
  "included); see Drury_etal_1996_Table2. Felleman & Van Essen's 99.4 cm2 is a different hemisphere ",
  "(case 80-G, planimetric flat map). Do not pool without reconciling specimen and denominator."))
final.dataframe <- fd

## ---- 4. Text checks against Table 1 of the same paper (never change values) ----
t1  <- as.data.frame(read_excel(file.path(folder, paste0(publication, "_Table1_snapshot.xlsx")), sheet = "Table1"))
t1  <- t1[!is.na(t1$Region) & !grepl("^Footnote", t1$Region), ]
lead_num <- function(x) as.numeric(sub("^\\s*([0-9.]+).*$", "\\1", x))
in_par   <- function(x) as.numeric(sub("^.*\\(([0-9.]+)\\).*$", "\\1", x))
t1_area <- function(region, side) lead_num(t1[t1$Region == region, if (side == "left") 2 else 3])
t1_pct  <- function(region, side) in_par(t1[t1$Region == region, if (side == "left") 2 else 3])
tot <- c(left = t1_area("Total neocortex", "left"), right = t1_area("Total neocortex", "right"))
pick <- function(sp, st, hemi) which(fd$Species == sp & fd$structure == st & fd$hemisphere %in% hemi)
chk <- list()
add_pct_check <- function(id, row, total, basis) {
  obs <- round(100 * fd$area_cm2[row] / total, 2)
  dec <- if (grepl("\\.", format(fd$pct_neocortex[row]))) 0.05 else 0.5      # half a printed unit
  tol <- round(dec + 100 * 0.5 / total, 2)                                    # + integer rounding of the area
  chk[[length(chk) + 1]] <<- data.frame(check_id = id, basis = basis, observed = obs,
    printed = fd$pct_neocortex[row], difference = round(obs - fd$pct_neocortex[row], 2), tolerance = tol,
    status = if (abs(obs - fd$pct_neocortex[row]) <= tol) "pass" else "mismatch",
    note = "100 x area / Table 1 total neocortex of that hemisphere", stringsAsFactors = FALSE)
}
for (h in c("right", "left")) {
  add_pct_check(paste0("V1_pct_", h), pick("Homo sapiens", "V1", h), tot[[h]],
                paste0("V1 ", h, " area / Table 1 ", h, " total"))
  add_pct_check(paste0("visual_cortex_pct_", h), pick("Homo sapiens", "estimated visual cortex", h), tot[[h]],
                paste0("estimated visual cortex ", h, " / Table 1 ", h, " total"))
}
r72 <- which(mac72)
obs <- round(100 * fd$area_cm2[r72] / tot[["right"]], 2)
chk[[length(chk) + 1]] <- data.frame(check_id = "macaque_total_9pct_of_VisibleMan",
  basis = "text: macaque 72 cm2 is 'only 9% of that for the Visible Man' (right hemisphere, Table 1)",
  observed = obs, printed = 9, difference = round(obs - 9, 2), tolerance = 0.5,
  status = if (abs(obs - 9) <= 0.5) "pass" else "mismatch", note = "printed 9% is an integer", stringsAsFactors = FALSE)
for (st in c("buried neocortex", "frontal lobe", "occipital lobe")) {
  reg <- c("buried neocortex" = "Total sulcal", "frontal lobe" = "Frontal", "occipital lobe" = "Occipital")[[st]]
  r <- pick("Homo sapiens", st, c("average", NA))
  r <- r[is.na(fd$cited_primary[r])]
  lo <- min(t1_pct(reg, "left"), t1_pct(reg, "right")); hi <- max(t1_pct(reg, "left"), t1_pct(reg, "right"))
  p  <- fd$pct_neocortex[r]
  chk[[length(chk) + 1]] <- data.frame(check_id = paste0("VisibleMan_", gsub(" ", "_", st), "_pct_within_Table1"),
    basis = paste0("text Visible Man ", st, " % vs Table 1 '", reg, "' % (left ", t1_pct(reg, "left"),
                   ", right ", t1_pct(reg, "right"), ")"),
    observed = (lo + hi) / 2, printed = p, difference = (lo + hi) / 2 - p, tolerance = (hi - lo) / 2,
    status = if (p >= lo && p <= hi) "pass" else "mismatch",
    note = "pass = the text value lies within the two hemispheres' printed percentages", stringsAsFactors = FALSE)
}
for (r in which(cited)) for (end in c("min", "max")) {
  printed_mm2 <- num(snap[[paste0("range_", end, "_mm2")]][r])
  obs <- fd[[paste0("range_", end, "_mm2")]][r]
  chk[[length(chk) + 1]] <- data.frame(check_id = paste0("mm2_", end, "_", gsub("[^A-Za-z0-9]+", "", fd$cited_primary[r])),
    basis = "snapshot mm2 column vs printed cm2 x 100", observed = obs, printed = printed_mm2,
    difference = obs - printed_mm2, tolerance = 0, status = if (isTRUE(obs == printed_mm2)) "pass" else "mismatch",
    note = "conversion written by the curator in the snapshot", stringsAsFactors = FALSE)
}
table_checks <- do.call(rbind, chk)
bad <- table_checks[table_checks$status != "pass", ]
if (nrow(bad)) warning(item_name, ": ", nrow(bad), " text check(s) did not pass: ", paste(bad$check_id, collapse = ", "))
message(item_name, ": text checks ", sum(table_checks$status == "pass"), " pass / ", nrow(table_checks))

## ---- 5. Write the analysis CSV and the public TSV ----
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(final.dataframe), " rows written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(path.expand(tsv_dir))) {
    write.table(final.dataframe, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  } else warning("Item encoded not found for ", item_name, "; public TSV not written.")
}
