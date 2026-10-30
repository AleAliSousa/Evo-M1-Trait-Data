## =============================================================================
## Jones et al. (2009), PanTHERIA 1.0 -- internal consistency of the two
## published taxonomy versions (WR05 vs WR93) for binomials present in both
## =============================================================================
##
## A report about the publication: values are compared cell by cell for every
## binomial spelled identically in PanTHERIA_1-0_WR05_Aug2008.txt and
## PanTHERIA_1-0_WR93_Aug2008.txt. Nothing is changed anywhere.
##
## Columns compared (matched by POSITION; the WR93 file spells three headers
## differently): the 30 source variables (cols 6-35) and the 4 EXT variables
## (cols 37-40) are the requested set; the 15 spatial derived variables
## (cols 41-55) are compared too and labelled column_group = "spatial" so
## they can be filtered out. The References lists (col 36) are compared
## separately, as sets of tokens.
##
## Outputs (reference_tables/)
##   Jones_etal_2009_WR05_vs_WR93_consistency.csv
##        one row per differing cell: MSW_Binomial, variable, column_group,
##        value_WR05, value_WR93, presence (both_present / only_WR05_present /
##        only_WR93_present), numeric_difference_type
##   Jones_etal_2009_WR05_vs_WR93_consistency_references.csv
##        one row per shared binomial whose References lists differ
##   Jones_etal_2009_WR05_vs_WR93_consistency_summary.csv
##        the printed summary counts, one row per count
## Every input problem is a stop() (evom1-refs-conventions C5).
## =============================================================================

options(scipen = 999, stringsAsFactors = FALSE)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); setwd(folder)
out_dir <- file.path(folder, "reference_tables")
if(!dir.exists(out_dir)) dir.create(out_dir)
for(p in c("readr", "dplyr")) if(!requireNamespace(p, quietly=TRUE)) stop("Install package: ", p, call.=FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr) })

f05 <- file.path(folder, "PanTHERIA_1-0_WR05_Aug2008.txt")
f93 <- file.path(folder, "PanTHERIA_1-0_WR93_Aug2008.txt")
read_pan <- function(f, n_expected) {
  if(!file.exists(f)) stop("Missing input: ", f, call.=FALSE)
  d <- read.delim(f, sep="\t", quote="", check.names=FALSE, stringsAsFactors=FALSE,
                  na.strings=NULL, comment.char="", colClasses="character")
  if(nrow(d) != n_expected || ncol(d) != 55L)
    stop(basename(f), ": expected ", n_expected, " x 55, got ", nrow(d), " x ", ncol(d), call.=FALSE)
  d
}
d05 <- read_pan(f05, 5416L)
d93 <- read_pan(f93, 4629L)

## headers are position-matched; only the known WR93 spelling variants may differ
h05 <- names(d05); h93 <- names(d93)
known_diff <- c(1:5, 20, 44, 47)
if(any(h05[-known_diff] != h93[-known_diff]))
  stop("Unexpected header difference between WR05 and WR93 at column(s): ",
       paste(setdiff(which(h05 != h93), known_diff), collapse=", "), call.=FALSE)
if(h05[36] != "References") stop("Column 36 is not References.", call.=FALSE)
if(anyDuplicated(d05$MSW05_Binomial) || anyDuplicated(d93$MSW93_Binomial)) stop("Duplicate binomial within a file.", call.=FALSE)

shared <- intersect(d05$MSW05_Binomial, d93$MSW93_Binomial)
if(!length(shared)) stop("No shared binomials.", call.=FALSE)
a <- d05[match(shared, d05$MSW05_Binomial), ]
b <- d93[match(shared, d93$MSW93_Binomial), ]

var_cols <- setdiff(6:55, 36)
column_group <- ifelse(var_cols <= 35, "source", ifelse(var_cols <= 40, "EXT", "spatial"))
names(column_group) <- h05[var_cols]
is_missing <- function(x) grepl("^-999(\\.0+)?$", x)
num <- function(x) suppressWarnings(as.numeric(x))

rows <- vector("list", length(var_cols))
n_compared <- 0L
for(k in seq_along(var_cols)) {
  j <- var_cols[k]; v05 <- a[[j]]; v93 <- b[[j]]
  n_compared <- n_compared + length(v05)
  m05 <- is_missing(v05); m93 <- is_missing(v93)
  same_str <- v05 == v93
  n05 <- num(v05); n93 <- num(v93)
  if(any(is.na(n05) & !m05) || any(is.na(n93) & !m93)) stop("Non-numeric value in column ", h05[j], call.=FALSE)
  same_num <- (!is.na(n05) & !is.na(n93) & n05 == n93) | (m05 & m93)
  diff <- !same_num
  if(!any(diff)) next
  presence <- ifelse(!m05 & !m93, "both_present", ifelse(m05, "only_WR93_present", "only_WR05_present"))
  rel <- rep(NA_character_, length(v05))
  bp <- diff & !m05 & !m93
  r <- n05[bp] / n93[bp]
  rel[bp] <- ifelse(abs(r - 1) < 1e-6, "equal", ifelse(r %in% c(10, 100, 1000, 0.1, 0.01, 0.001), "power_of_ten",
                ifelse(abs(r - 1) <= 0.01, "within_1pct", "other")))
  rows[[k]] <- tibble(MSW_Binomial = shared[diff], variable = h05[j], column_group = column_group[[h05[j]]],
                      value_WR05 = v05[diff], value_WR93 = v93[diff], presence = presence[diff],
                      numeric_difference_type = rel[diff], same_string = same_str[diff])
}
diffs <- bind_rows(rows)
if(nrow(diffs) && any(diffs$same_string)) stop("Internal error: string-identical cell flagged as differing.", call.=FALSE)
diffs$same_string <- NULL
## cells identical numerically but formatted differently (e.g. "1" vs "1.00") are counted, not listed
n_format_only <- 0L; n_format_only_sentinel <- 0L
for(j in var_cols) {
  v05 <- a[[j]]; v93 <- b[[j]]
  n_format_only_sentinel <- n_format_only_sentinel + sum(v05 != v93 & is_missing(v05) & is_missing(v93))
  n_format_only <- n_format_only + sum(v05 != v93 & !is_missing(v05) & !is_missing(v93) &
                                      !is.na(num(v05)) & !is.na(num(v93)) & num(v05) == num(v93))
}

## References lists (as sets of printed tokens)
tok <- function(v) if(v == "-999") character(0) else trimws(strsplit(v, ";", fixed=TRUE)[[1]])
ref_cmp <- bind_rows(lapply(seq_along(shared), function(i) {
  t05 <- tok(a$References[i]); t93 <- tok(b$References[i])
  if(setequal(t05, t93)) return(NULL)
  tibble(MSW_Binomial = shared[i], References_WR05 = a$References[i], References_WR93 = b$References[i],
         n_refs_WR05 = length(t05), n_refs_WR93 = length(t93),
         only_WR05 = paste(setdiff(t05, t93), collapse=";"), only_WR93 = paste(setdiff(t93, t05), collapse=";"),
         n_only_WR05 = length(setdiff(t05, t93)), n_only_WR93 = length(setdiff(t93, t05)))
}))
if(!nrow(ref_cmp)) ref_cmp <- tibble(MSW_Binomial=character(), References_WR05=character(), References_WR93=character(),
                                     n_refs_WR05=integer(), n_refs_WR93=integer(), only_WR05=character(), only_WR93=character(),
                                     n_only_WR05=integer(), n_only_WR93=integer())

## ---- summary --------------------------------------------------------------------
req <- diffs %>% filter(column_group != "spatial")
S <- function(label, value) tibble(count = label, value = as.character(value))
summary_tbl <- bind_rows(
  S("binomials_WR05", nrow(d05)), S("binomials_WR93", nrow(d93)), S("binomials_in_both", length(shared)),
  S("binomials_only_WR05", nrow(d05) - length(shared)), S("binomials_only_WR93", nrow(d93) - length(shared)),
  S("columns_compared_source_and_EXT", sum(column_group != "spatial")), S("columns_compared_spatial", sum(column_group == "spatial")),
  S("cells_compared_source_and_EXT", length(shared) * sum(column_group != "spatial")),
  S("cells_identical_source_and_EXT", length(shared) * sum(column_group != "spatial") - nrow(req)),
  S("cells_differing_both_non_999_source_and_EXT", sum(req$presence == "both_present")),
  S("cells_one_side_999_source_and_EXT", sum(req$presence != "both_present")),
  S("cells_only_WR05_present_source_and_EXT", sum(req$presence == "only_WR05_present")),
  S("cells_only_WR93_present_source_and_EXT", sum(req$presence == "only_WR93_present")),
  S("cells_differing_source_cols_6_35", sum(req$column_group == "source")),
  S("cells_differing_EXT_cols_37_40", sum(req$column_group == "EXT")),
  S("cells_differing_both_non_999_within_1pct", sum(req$numeric_difference_type %in% "within_1pct")),
  S("cells_differing_both_non_999_power_of_ten", sum(req$numeric_difference_type %in% "power_of_ten")),
  S("cells_compared_spatial", length(shared) * sum(column_group == "spatial")),
  S("cells_differing_spatial", sum(diffs$column_group == "spatial")),
  S("cells_differing_spatial_both_non_999", sum(diffs$column_group == "spatial" & diffs$presence == "both_present")),
  S("cells_sentinel_formatted_differently_-999_vs_-999.00_all_cols", n_format_only_sentinel),
  S("cells_numerically_equal_but_formatted_differently_all_cols", n_format_only),
  S("shared_binomials_with_differing_References_lists", nrow(ref_cmp)),
  S("shared_binomials_with_References_only_in_WR05", sum(ref_cmp$n_only_WR05 > 0)),
  S("shared_binomials_with_References_only_in_WR93", sum(ref_cmp$n_only_WR93 > 0)),
  S("shared_binomials_with_identical_References_lists", length(shared) - nrow(ref_cmp))
)
if(as.integer(summary_tbl$value[summary_tbl$count == "cells_compared_source_and_EXT"]) !=
   as.integer(summary_tbl$value[summary_tbl$count == "cells_identical_source_and_EXT"]) + nrow(req))
  stop("Cell accounting does not add up.", call.=FALSE)

write_out <- function(x, name) {
  f <- file.path(out_dir, name); write_csv(x, f, na = "")
  back <- read_csv(f, show_col_types=FALSE, na=character(), progress=FALSE, col_types=cols(.default=col_character()))
  if(nrow(back) != nrow(x) || !identical(names(back), names(x))) stop("Read-back mismatch for ", name, call.=FALSE)
}
write_out(diffs %>% arrange(column_group, variable, MSW_Binomial), "Jones_etal_2009_WR05_vs_WR93_consistency.csv")
write_out(ref_cmp, "Jones_etal_2009_WR05_vs_WR93_consistency_references.csv")
write_out(summary_tbl, "Jones_etal_2009_WR05_vs_WR93_consistency_summary.csv")

cat("== Jones_etal_2009_WR05_vs_WR93_consistency ==\n")
for(i in seq_len(nrow(summary_tbl))) cat(sprintf("%-62s %s\n", summary_tbl$count[i], summary_tbl$value[i]))
cat("differing cells by variable (source + EXT, top 10):\n")
print(as.data.frame(req %>% count(variable, presence) %>% arrange(desc(n)) %>% head(10)), row.names=FALSE)
cat("Wrote 3 files to", out_dir, "\n")
