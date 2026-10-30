# Part I.C diagnostic — audit mapped vs available volume structures.
# For every reference that has BOTH a *_definitions.csv and a
# standardized_term_by_reference/*_standardized_terms.csv, compare the volume
# columns defined in the paper against those actually mapped into the merge.
# Output: _audit_missing_structures.csv (one row per defined volume column).
#
# Run via the external runner from the repo root, or directly with the working
# directory set to __merging_volumes.

library(tidyverse)

## ---- paths: self-contained (Rscript or RStudio); discovers the repo root ----
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
folder <- dirname(.sp)                                    # this script's folder (__merging_volumes)
base   <- local({                                         # repo root (anchored on __ReadMe.xlsx)
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Project root not found (no __ReadMe.xlsx above this script); this whole-repo audit needs the full project.", call. = FALSE)
setwd(folder)
repo <- base                                              # project root (discovered, not hardcoded)
termdir <- file.path(repo, "__merging_volumes", "standardized_term_by_reference")

# All definitions files in the repo (skip the cellcount archive).
def_files <- list.files(repo, pattern = "_definitions\\.csv$", recursive = TRUE,
                        full.names = TRUE)
def_files <- def_files[!grepl("__Archive_merging_cellcounts", def_files)]

# Read every definitions file, keep only volume-bearing rows (Measure ~ Volume).
read_defs <- function(f) {
  d <- tryCatch(read.csv(f, stringsAsFactors = FALSE, check.names = FALSE),
                error = function(e) NULL)
  if (is.null(d) || !all(c("Code", "Measure") %in% names(d))) return(NULL)
  d$def_file <- sub("^[\\\\/]+", "", sub(repo, "", f, fixed = TRUE))
  d
}
defs_all <- map(def_files, read_defs) %>% compact() %>% bind_rows()
is_vol <- function(m) grepl("^vol", tolower(trimws(m)))

# Map each merged term-map file to a paper folder, then to its definitions file(s).
term_files <- list.files(termdir, pattern = "_standardized_terms\\.csv$", full.names = TRUE)
top_dirs <- list.dirs(repo, recursive = FALSE, full.names = FALSE)

audit <- list()
for (tf in term_files) {
  item <- sub("_standardized_terms\\.csv$", "", basename(tf))
  tm <- read.csv(tf, stringsAsFactors = FALSE, check.names = FALSE)
  ref <- unique(tm$Reference)[1]
  # paper folder = longest top-level dir that is a prefix of the item
  cand <- top_dirs[map_lgl(top_dirs, ~ startsWith(item, .x))]
  folder <- if (length(cand)) cand[which.max(nchar(cand))] else NA_character_
  # definitions rows belonging to this folder
  dfolder <- defs_all %>% filter(grepl(paste0("^", folder, "[\\\\/]"), def_file))
  # prefer a table-specific definitions file when the item carries a table token
  tok <- str_extract(item, "(?i)(table\\s?\\d+|sup\\w*table\\d*|table\\d+-\\d+)")
  if (!is.na(tok)) {
    norm <- function(x) tolower(gsub("[^a-z0-9]", "", x))
    spec <- dfolder %>% filter(grepl(norm(tok), norm(def_file), fixed = TRUE))
    if (nrow(spec)) dfolder <- spec
  }
  vol <- dfolder %>% filter(is_vol(Measure)) %>% distinct(Code, .keep_all = TRUE)
  if (!nrow(vol)) {
    audit[[item]] <- tibble(item = item, reference = ref, folder = folder,
                            def_file = if (nrow(dfolder)) dfolder$def_file[1] else NA,
                            code = NA, structure = NA, measure = NA,
                            mapped = NA, standardized_term = NA,
                            note = "no volume rows found in definitions")
    next
  }
  mapped_terms <- setNames(tm$Standardized_Term, tm$Original_Term)
  audit[[item]] <- tibble(
    item = item, reference = ref, folder = folder,
    def_file = vol$def_file,
    code = vol$Code, structure = vol$Structure, measure = vol$Measure,
    mapped = vol$Code %in% tm$Original_Term,
    standardized_term = unname(mapped_terms[vol$Code]),
    note = "")
}
audit <- bind_rows(audit) %>% arrange(item, desc(mapped), code)

# Classify each unmapped volume code to separate real missing structures from
# noise (summary stats, non-brain residuals, laterality variants of a mapped col).
classify <- function(df) {
  mapped_codes <- df$code[df$mapped %in% TRUE]
  mapped_structs <- tolower(df$structure[df$mapped %in% TRUE])
  cat <- rep(NA_character_, nrow(df))
  for (i in seq_len(nrow(df))) {
    if (isTRUE(df$mapped[i])) { cat[i] <- "mapped"; next }
    if (is.na(df$code[i]))    { cat[i] <- NA;       next }
    code <- df$code[i]; meas <- tolower(df$measure[i]); st <- df$structure[i]
    sl <- tolower(ifelse(is.na(st), "", st))
    if (grepl("sem|sd|stderr|percent|_pct|_cv", tolower(code)) ||
        grepl("sem|sd|percent|error", meas) ||
        grepl("mening|hypophys|nerves|residual|rest|other", sl)) {
      cat[i] <- "stat_or_nonbrain"; next
    }
    # laterality variant of an already-mapped structure?
    if (!is.na(st) && tolower(st) %in% mapped_structs) {
      cat[i] <- "laterality_variant_of_mapped"; next
    }
    cat[i] <- "candidate_missing"
  }
  df$category <- cat
  df
}
audit <- audit %>% group_by(item) %>% group_modify(~classify(.x)) %>% ungroup()

out <- file.path(repo, "__merging_volumes", "_audit_missing_structures.csv")
write_csv(audit, out)

# Console summary
summ <- audit %>% filter(!is.na(code)) %>% group_by(item) %>%
  summarise(n_vol = n(), n_mapped = sum(category == "mapped"),
            candidate_missing = sum(category == "candidate_missing"),
            lat_variant = sum(category == "laterality_variant_of_mapped"),
            stat_nonbrain = sum(category == "stat_or_nonbrain"),
            candidates = paste(code[category == "candidate_missing"], collapse = "; "),
            .groups = "drop") %>%
  arrange(desc(candidate_missing))
cat("\n=== AUDIT SUMMARY (papers with candidate missing structures first) ===\n")
print(summ, n = Inf, width = Inf)
cat("\nWrote", out, "\n")
