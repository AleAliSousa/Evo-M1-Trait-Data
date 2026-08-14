# compare_to_reference.R -- diff an external species x trait table against the merge, and say
# WHERE each disagreeing value came from.
#
# The hard part of comparing a hand-assembled table against volumes_wide_select.csv is not the
# diff, it is the ALIGNMENT: species carry pre-modern or genus-level labels, columns carry printed
# rather than standardized names, and some columns are in different units. Point a generic differ
# at the two files raw and you get "no rows in common", or worse, a handful of accidental matches.
# So the mapping lives in two hand-editable CSVs and the diff is the easy last step:
#
#   compare_to_reference_columns.csv   ref_column, merge_variable, note
#                                      blank merge_variable = ignore this column
#   compare_to_reference_species.csv   reference_name, accepted_name, note
#
# Every disagreeing cell is then annotated from volumes_resolution_audit_select.csv with the source
# the merge used, its year, and the candidates it beat -- so "why is this number different?" is
# answered in the same row.
#
# Outputs
#   compare_to_reference_cells_select.csv    every compared cell: ref value, merged value, status
#   compare_to_reference_report_select.md    summary by column, with the likely-unit-mismatch flags
#   compare_to_reference_diff_select.html    colour-coded table (only if the `daff` package is installed)
#
# Nothing here writes to the merge. Safe to run any time.

library(tidyverse)

## ---- options ---------------------------------------------------------------------------------
reference_csv <- "~/Library/CloudStorage/Dropbox/COLLABORATIVE/Do expensive brain regions increase less in humans/analyses_metabol_rate_structure/data_raw/Stephan_primates.csv"
reference_name <- "Stephan_primates.csv"
merge_suffix   <- "_select"          # which merge to compare against: "" (canonical) or "_select"
# Where the merge output lives. Default "" = this script's own folder, i.e. the __merging_volumes
# copy that volumes_compiled_select.R actually writes. Set it only if you deliberately want to
# compare against a copy somewhere else — and note that copies of volumes_wide_select.csv kept
# alongside an analysis go stale silently, which is why the script prints the absolute path and
# modification time of the file it used.
merge_dir      <- ""
species_col    <- "Species"          # key column in the reference
tol_rel        <- 1e-6               # relative tolerance for "same value"
# A mismatch whose merge/reference ratio is close to one of these is almost certainly a unit or
# laterality convention difference rather than a disagreement about the measurement. Flagged, not
# silenced, so you can decide.
suspect_ratios <- c(`x1000 (cm3 vs mm3)` = 1000, `/1000 (mm3 vs cm3)` = 0.001,
                    `x2 (one side vs both)` = 2,  `/2 (both vs one side)` = 0.5)
suspect_tol    <- 0.02               # within 2% of a suspect ratio

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or Source in RStudio.", call. = FALSE)
})
setwd(dirname(.sp))
out_csv <- function(stem) paste0(stem, merge_suffix, ".csv")
mdir    <- if (nzchar(merge_dir)) path.expand(merge_dir) else dirname(.sp)
mpath   <- function(stem) file.path(mdir, out_csv(stem))

reference_csv <- path.expand(reference_csv)
if (!file.exists(reference_csv))
  stop("reference_csv not found: ", reference_csv, call. = FALSE)
if (!file.exists(mpath("volumes_wide")))
  stop("merge output not found: ", mpath("volumes_wide"),
       " — run volumes_compiled_select.R first, or set merge_dir.", call. = FALSE)
# State exactly which two files were compared. A stale copy of volumes_wide_select.csv sitting next
# to an analysis is indistinguishable from a fresh one until you look at the date.
message("reference : ", reference_csv, "  (", format(file.mtime(reference_csv), "%Y-%m-%d %H:%M"), ")")
message("merge     : ", normalizePath(mpath("volumes_wide")),
        "  (", format(file.mtime(mpath("volumes_wide")), "%Y-%m-%d %H:%M"), ")")

## ---- read ------------------------------------------------------------------------------------
ref   <- read.csv(reference_csv, stringsAsFactors = FALSE, check.names = FALSE)
wide  <- read.csv(mpath("volumes_wide"), stringsAsFactors = FALSE, check.names = FALSE)
audit <- tryCatch(read.csv(mpath("volumes_resolution_audit"), stringsAsFactors = FALSE),
                  error = function(e) NULL)
if (is.null(audit))
  message("No ", mpath("volumes_resolution_audit"), " -- differences will not be traced to a source.")

cmap <- read.csv("compare_to_reference_columns.csv", stringsAsFactors = FALSE) %>%
  filter(!is.na(merge_variable), nzchar(trimws(merge_variable)))
smap <- tryCatch(read.csv("compare_to_reference_species.csv", stringsAsFactors = FALSE),
                 error = function(e) data.frame(reference_name = character(), accepted_name = character()))

missing_cols <- setdiff(cmap$merge_variable, names(wide))
if (length(missing_cols))
  warning("compare_to_reference_columns.csv maps ", length(missing_cols), " column(s) the merge does ",
          "not have (they will be reported as `only_in_reference`): ",
          paste(head(missing_cols, 8), collapse = "; "))

## ---- align species ---------------------------------------------------------------------------
fix <- setNames(smap$accepted_name, smap$reference_name)
ref$.sp <- trimws(gsub("_", " ", as.character(ref[[species_col]])))
ref$.sp <- ifelse(!is.na(fix[ref$.sp]), unname(fix[ref$.sp]), ref$.sp)
matched <- ref$.sp %in% wide$Species
if (any(!matched))
  message("Species in the reference with no row in the merge (", sum(!matched), "): ",
          paste(unique(ref$.sp[!matched]), collapse = "; "),
          " -- add them to compare_to_reference_species.csv if it is a naming difference.")

## ---- compare cell by cell --------------------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
w_i <- match(ref$.sp, wide$Species)
cells <- list()
for (k in seq_len(nrow(cmap))) {
  rc <- cmap$ref_column[k]; mc <- cmap$merge_variable[k]
  if (!rc %in% names(ref)) next
  a <- num(ref[[rc]])
  b <- if (mc %in% names(wide)) num(wide[[mc]])[w_i] else rep(NA_real_, nrow(ref))
  keep <- matched & !(is.na(a) & is.na(b))
  if (!any(keep)) next
  cells[[length(cells) + 1L]] <- tibble(
    Species = ref$.sp[keep], ref_column = rc, Variable = mc,
    reference = a[keep], merged = b[keep],
    status = case_when(is.na(b[keep]) ~ "only_in_reference",
                       is.na(a[keep]) ~ "only_in_merge",
                       abs(a[keep] - b[keep]) <= tol_rel * pmax(1, abs(a[keep]), abs(b[keep])) ~ "match",
                       TRUE ~ "DIFFERS"),
    ratio = ifelse(!is.na(a[keep]) & !is.na(b[keep]) & a[keep] != 0, b[keep] / a[keep], NA_real_))
}
cells <- bind_rows(cells)
if (!nrow(cells)) stop("Nothing comparable — check compare_to_reference_columns.csv.", call. = FALSE)

# label the mismatches that look like a unit / laterality convention rather than a disagreement
cells$likely <- NA_character_
for (nm in names(suspect_ratios)) {
  r <- suspect_ratios[[nm]]
  hit <- cells$status == "DIFFERS" & !is.na(cells$ratio) &
         abs(cells$ratio / r - 1) <= suspect_tol
  cells$likely[hit] <- nm
}

## ---- trace every disagreement to its source ---------------------------------------------------
if (!is.null(audit)) {
  used <- audit %>% filter(status == "USED") %>%
    transmute(Species, Variable, merge_source = Source, merge_year = Year)
  lost <- audit %>% filter(status != "USED") %>%
    group_by(Species, Variable) %>%
    summarise(beat = paste0(Source, " (", Year, ") = ", Value, collapse = " | "), .groups = "drop")
  cells <- cells %>% left_join(used, by = c("Species", "Variable")) %>%
    left_join(lost, by = c("Species", "Variable"))
} else {
  cells$merge_source <- NA_character_; cells$merge_year <- NA_integer_; cells$beat <- NA_character_
}
cells <- cells %>% arrange(factor(status, levels = c("DIFFERS","only_in_reference","only_in_merge","match")),
                           Variable, Species)
write_csv(cells, out_csv("compare_to_reference_cells"))

## ---- report ------------------------------------------------------------------------------------
tally <- cells %>% count(status)
bycol <- cells %>% filter(status == "DIFFERS") %>%
  group_by(Variable) %>%
  summarise(n = n(), median_ratio = round(median(ratio, na.rm = TRUE), 4),
            likely = paste(sort(unique(na.omit(likely))), collapse = "; "),
            sources = paste(sort(unique(na.omit(merge_source))), collapse = "; "),
            .groups = "drop") %>% arrange(desc(n))
esc <- function(x) gsub("\\|", "\\\\|", ifelse(is.na(x), "", as.character(x)))
tbl <- function(d) if (!nrow(d)) "_none_" else c(
  paste0("| ", paste(names(d), collapse = " | "), " |"),
  paste0("|", paste(rep("---", ncol(d)), collapse = "|"), "|"),
  unname(apply(mutate(d, across(everything(), as.character)), 1,
               function(r) paste0("| ", paste(esc(r), collapse = " | "), " |"))))

L <- c(paste0("<!-- GENERATED by compare_to_reference.R on ", format(Sys.time(), "%Y-%m-%d %H:%M"), " -->"), "",
  paste0("# `", reference_name, "` vs `", out_csv("volumes_wide"), "`"), "",
  paste0("Species compared: **", n_distinct(cells$Species), "** | columns mapped: **",
         n_distinct(cells$Variable), "** | cells: **", nrow(cells), "**"), "",
  tbl(tally), "",
  "Mapping lives in `compare_to_reference_columns.csv` and `compare_to_reference_species.csv` —",
  "a wrong row there shows up here as a spurious difference, so check the mapping before the data.", "",
  "## Columns that disagree", "",
  "`median_ratio` is merged / reference. A ratio near 1000, 0.001, 2 or 0.5 is flagged in `likely`:",
  "that is a unit or one-side/both-sides convention difference, not a disagreement about the value.", "",
  tbl(bycol), "",
  "## Every disagreeing cell", "",
  paste0("Full detail, with the source the merge used and what it beat, in `",
         out_csv("compare_to_reference_cells"), "`."), "")
diffs <- cells %>% filter(status == "DIFFERS", is.na(likely)) %>%
  transmute(Species, Variable, reference, merged, ratio = round(ratio, 3),
            used = paste0(merge_source, " (", merge_year, ")"), beat = substr(beat, 1, 80))
L <- c(L, "### Genuine disagreements (unit-convention mismatches excluded)", "", tbl(diffs), "")
writeLines(L, paste0("compare_to_reference_report", merge_suffix, ".md"), useBytes = TRUE)

## ---- optional visual --------------------------------------------------------------------------
## daff renders a real diff table (changed cells highlighted). install.packages("daff") to enable.
if (requireNamespace("daff", quietly = TRUE)) {
  keep_v <- unique(cells$Variable[cells$Variable %in% names(wide)])
  a <- cells %>% filter(status != "only_in_merge") %>%
         select(Species, Variable, reference) %>% pivot_wider(names_from = Variable, values_from = reference)
  b <- cells %>% filter(status != "only_in_reference") %>%
         select(Species, Variable, merged) %>% pivot_wider(names_from = Variable, values_from = merged)
  common <- intersect(names(a), names(b))
  daff::render_diff(daff::diff_data(as.data.frame(a[, common]), as.data.frame(b[, common])),
                    file = paste0("compare_to_reference_diff", merge_suffix, ".html"), view = FALSE)
  message("daff diff -> compare_to_reference_diff", merge_suffix, ".html")
} else {
  message("Install the `daff` package for a colour-coded HTML diff (install.packages(\"daff\")).")
}

message(sprintf("[compare] %d cells | match %d | DIFFERS %d (%d of them a likely unit convention) | ref-only %d | merge-only %d",
        nrow(cells), sum(cells$status == "match"), sum(cells$status == "DIFFERS"),
        sum(cells$status == "DIFFERS" & !is.na(cells$likely)),
        sum(cells$status == "only_in_reference"), sum(cells$status == "only_in_merge")))
