## Jacob_etal_2021_FIGURE4.R — constructed frozen snapshot -> analysis CSV -> public TSV
##
## Source : Jacob et al. (2021) J. Comp. Neurol. 529(14):3375-3388,
##          doi 10.1002/cne.25197 — FIGURE 4 "Isotropic fractionation-based
##          cellular profiles in the raccoon hippocampus" (PDF p. 8).
##          The bar chart prints no numbers; every value in this item comes
##          verbatim from Results §3.1 text (PDF p. 7, group means "xc = ...",
##          ANOVA statistics) and the Figure 4 caption (post hoc p values, Ns).
##          Nothing is digitized from pixels.
## Frozen : Jacob_etal_2021_FIGURE4_snapshot.csv — a CONSTRUCTED snapshot
##          (see __HOWTO_make_a_snapshot.md, "When there is no table"), built
##          by Jacob_etal_2021_extract_snapshot.R from the PDF text layer:
##          printed strings kept verbatim (the text layer renders x-bar-c as
##          "xc" and holds a stray space in two panel-B means), one row per
##          group x panel, with a provenance column naming the sentence each
##          value comes from. This script READS it; it never regenerates it.
## n      : group Ns are not all printed at the figure. Panel (a): N = 7
##          solvers / N = 6 nonsolvers (caption); intermediate N = 5 follows
##          from ANOVA df F(2,15) => total 18. Panel (b): "One intermediate
##          solver could not be analyzed for NeuN staining" (text) => N = 4;
##          F(2,14) => total 17 = 6 + 4 + 7, consistent.
## Note   : caption prints post hoc p = .0706 / .1006; the running text rounds
##          the same tests to .071 / .101. Caption values are used.

## 0. PATHS (no setwd) --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or source from RStudio (save the file first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Jacob_etal_2021_FIGURE4"
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", paper_dir, call. = FALSE)
  d
})
snapshot_csv   <- file.path(paper_dir, paste0(item_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
if (!file.exists(snapshot_csv)) stop("Frozen snapshot not found: ", snapshot_csv, call. = FALSE)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl", call. = FALSE)

## 1. READ THE FROZEN SNAPSHOT ------------------------------------------------
## Constructed snapshot: row 1 provenance note, row 2 headers, rows 3-8 data.
raw <- read.csv(snapshot_csv, header = TRUE, skip = 1,
                stringsAsFactors = FALSE, fileEncoding = "UTF-8")

## 2. CLEAN --------------------------------------------------------------------
num_from <- function(x, pattern) as.numeric(sub(pattern, "\\1", x))
mean_count <- as.numeric(gsub("[^0-9]", "", raw$group_mean_as_printed))  # "xc = 35,237,500" -> 35237500
anova_F    <- num_from(raw$anova_as_printed, "^F\\(\\d+,\\d+\\) = ([0-9.]+),.*$")
anova_df_between <- as.integer(sub("^F\\((\\d+),\\d+\\).*$",  "\\1", raw$anova_as_printed))
anova_df_within  <- as.integer(sub("^F\\(\\d+,(\\d+)\\).*$",  "\\1", raw$anova_as_printed))
anova_p    <- num_from(raw$anova_as_printed, "^.*p = (\\.[0-9]+), .*$")
anova_partial_eta_sq <- num_from(raw$anova_as_printed, "^.*= ([0-9.]+)$")
posthoc_vs_solver_p  <- ifelse(nzchar(raw$posthoc_vs_high_solvers_as_printed),
                               num_from(raw$posthoc_vs_high_solvers_as_printed,
                                        "^p = (\\.[0-9]+).*$"), NA_real_)
## group labels: text prints "nonsolver group" / "intermediate group" /
## "high solvers"; harmonize to the tables' Nonsolver/Intermediate/Solver
solver_map  <- c("nonsolver group" = "Nonsolver", "intermediate group" = "Intermediate",
                 "high solvers"    = "Solver")
solver_type <- unname(solver_map[raw$group_as_printed])
if (anyNA(solver_type)) stop("Unmapped group label in snapshot", call. = FALSE)
## group Ns: printed (caption) + derived (ANOVA df, NeuN exclusion) — see header
n_group <- c(6L, 5L, 7L, 6L, 4L, 7L)
n_group_basis <- c("caption", "derived: F(2,15), total N = 18", "caption",
                   "caption", "derived: NeuN exclusion + F(2,14)", "caption")

final_df <- data.frame(
  species_as_published = "Procyon lotor",
  region               = "hippocampus",
  panel                = raw$panel,
  measure              = ifelse(raw$panel == "A", "total_nuclei", "nonneuronal_nuclei"),
  measure_as_printed   = raw$measure_as_printed,
  solver_type          = solver_type,
  n_group              = n_group,
  n_group_basis        = n_group_basis,
  group_mean_count     = mean_count,
  anova_F              = anova_F,
  anova_df_between     = anova_df_between,
  anova_df_within      = anova_df_within,
  anova_p              = anova_p,
  anova_partial_eta_sq = anova_partial_eta_sq,
  posthoc_vs_solver_p  = posthoc_vs_solver_p,
  source = "Jacob_etal_2021 FIGURE 4 (values from Results §3.1 text + caption)",
  stringsAsFactors = FALSE
)
stopifnot(nrow(final_df) == 6L,
          identical(final_df$group_mean_count[c(3, 6)], c(51472917, 43959439)),
          sum(final_df$n_group[final_df$panel == "A"]) == 2L + 15L + 1L,   # ANOVA df + 1
          sum(final_df$n_group[final_df$panel == "B"]) == 2L + 14L + 1L)

## 3. WRITE CSV + PUBLIC TSV ---------------------------------------------------
write.csv(final_df, final_csv, row.names = FALSE, na = "")
filecodes <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
hit <- which(filecodes[["Item name"]] == item_name)          # by name, never row number
if (length(hit) != 1L) stop("Registry rows matching '", item_name, "': ", length(hit), call. = FALSE)
item_encoded <- filecodes[["Item encoded"]][hit]
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("Bad Item encoded for ", item_name, ": '", item_encoded, "'", call. = FALSE)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(final_df, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", quote = FALSE, row.names = FALSE, na = "")
message("Built ", item_name, ": ", nrow(final_df), " rows -> CSV + ", item_encoded, ".tsv")
