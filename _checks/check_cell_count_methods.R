## check_cell_count_methods.R -- passive check of _keys/cell_count_methods/
##
## Reads the four method tables and reports problems; never edits them. Fails (exit status 1) when:
##   - a required column is missing, or an id is blank or duplicated;
##   - a value is outside the controlled vocabulary (family, treatment, rule, status, target merge);
##   - a source row names a method_id that is not in methods.csv;
##   - an accepted row lacks decided_by or a review_id, or cites a review that is not an accepted
##     row of expert_reviews.csv; a date is not YYYY-MM-DD;
##   - an exclude or off_by_default row has no reason or no evidence.
## Warns (does not fail) when an item_name is not in __ReadMe.xlsx Sheet1 (needs readxl; skipped
## without it) -- items can be pending registration.
## Report: _checks/check_cell_count_methods_report.csv (one row per finding; empty = clean).
## Update procedure for experts: _keys/cell_count_methods/README.md.

.script_path <- local({
  argv <- commandArgs(FALSE)
  f <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f)) return(normalizePath(f))
  sf <- tryCatch(normalizePath(sys.frames()[[1]]$ofile), error = function(e) NULL)
  if (!is.null(sf) && nzchar(sf)) return(sf)
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  normalizePath(getwd())
})
root <- local({
  d <- if (file.exists(.script_path)) dirname(.script_path) else normalizePath(getwd())
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("Repository root (folder with __ReadMe.xlsx) not found.")
  d
})
key_dir <- file.path(root, "_keys", "cell_count_methods")
out_csv <- file.path(root, "_checks", "check_cell_count_methods_report.csv")

read_key <- function(name) {
  p <- file.path(key_dir, name)
  if (!file.exists(p)) stop("Missing key file: ", p)
  utils::read.csv(p, colClasses = "character", na.strings = character(0),
                  check.names = FALSE, fileEncoding = "UTF-8")
}
methods <- read_key("methods.csv")
sources <- read_key("source_methods.csv")
rules   <- read_key("pooling_rules.csv")
reviews <- read_key("expert_reviews.csv")

findings <- data.frame(severity = character(), file = character(), row = integer(),
                       id = character(), message = character(), stringsAsFactors = FALSE)
add <- function(sev, file, row, id, msg)
  findings[nrow(findings) + 1L, ] <<- list(sev, file, as.integer(row), id, msg)

need_cols <- function(df, file, cols) {
  miss <- setdiff(cols, names(df))
  if (length(miss)) add("error", file, NA, "", paste("missing columns:", paste(miss, collapse = ", ")))
  !length(miss)
}
VOC <- list(
  family = c("histology_design_based", "histology_model_based", "histology_unverified", "histology_2d",
             "homogenate", "dna", "tracer", "compilation", "not_a_count"),
  treatment = c("include", "include_flagged", "include_own_label", "off_by_default", "not_merged",
                "exclude", "queued", "route_elsewhere"),
  target = c("cell_counts_isotropic_fractionator", "cell_counts_histology", "cell_morphology",
             "supplementary", "volumes", "none"),
  rule = c("pool", "pool_flagged", "derive_flagged", "never"),
  status = c("proposed", "accepted", "retired"),
  review_status = c("proposed", "accepted", "rejected", "superseded"))
is_date <- function(x) grepl("^\\d{4}-\\d{2}-\\d{2}$", x) & !is.na(as.Date(x, optional = TRUE))

ok_m <- need_cols(methods, "methods.csv", c("method_id", "family", "default_treatment", "status", "decided_by", "decided_date", "review_id"))
ok_s <- need_cols(sources, "source_methods.csv", c("item_name", "filter", "method_id", "target_merge", "treatment", "reason", "evidence", "status", "decided_by", "decided_date", "review_id"))
ok_r <- need_cols(rules, "pooling_rules.csv", c("rule_id", "rule", "status", "decided_by", "decided_date", "review_id"))
ok_v <- need_cols(reviews, "expert_reviews.csv", c("review_id", "date", "status", "decided_by", "decided_date"))
if (!(ok_m && ok_s && ok_r && ok_v)) {
  utils::write.csv(findings, out_csv, row.names = FALSE)
  stop("Required columns missing; see ", out_csv)
}

## reviews
dup <- duplicated(reviews$review_id) | !nzchar(reviews$review_id)
for (i in which(dup)) add("error", "expert_reviews.csv", i + 1L, reviews$review_id[i], "blank or duplicated review_id")
for (i in seq_len(nrow(reviews))) {
  if (!reviews$status[i] %in% VOC$review_status) add("error", "expert_reviews.csv", i + 1L, reviews$review_id[i], paste("status not in vocabulary:", reviews$status[i]))
  if (!is_date(reviews$date[i])) add("error", "expert_reviews.csv", i + 1L, reviews$review_id[i], "date is not YYYY-MM-DD")
  if (reviews$status[i] %in% c("accepted", "rejected", "superseded")) {
    if (!nzchar(reviews$decided_by[i])) add("error", "expert_reviews.csv", i + 1L, reviews$review_id[i], "decided review lacks decided_by")
    if (!is_date(reviews$decided_date[i])) add("error", "expert_reviews.csv", i + 1L, reviews$review_id[i], "decided review lacks a YYYY-MM-DD decided_date")
  }
}
accepted_reviews <- reviews$review_id[reviews$status == "accepted"]

check_decision <- function(df, file, id_of) {
  for (i in seq_len(nrow(df))) {
    id <- id_of(i)
    if (!df$status[i] %in% VOC$status) add("error", file, i + 1L, id, paste("status not in vocabulary:", df$status[i]))
    if (nzchar(df$decided_date[i]) && !is_date(df$decided_date[i])) add("error", file, i + 1L, id, "decided_date is not YYYY-MM-DD")
    if (df$status[i] == "accepted") {
      if (!nzchar(df$decided_by[i])) add("error", file, i + 1L, id, "accepted row lacks decided_by")
      rv <- trimws(strsplit(df$review_id[i], ";", fixed = TRUE)[[1]])
      if (!length(rv) || !all(nzchar(rv))) add("error", file, i + 1L, id, "accepted row lacks a review_id")
      else if (!all(rv %in% accepted_reviews)) add("error", file, i + 1L, id, paste("review_id not an accepted review:", paste(setdiff(rv, accepted_reviews), collapse = ", ")))
    }
  }
}

## methods
dup <- duplicated(methods$method_id) | !nzchar(methods$method_id)
for (i in which(dup)) add("error", "methods.csv", i + 1L, methods$method_id[i], "blank or duplicated method_id")
for (i in seq_len(nrow(methods))) {
  if (!methods$family[i] %in% VOC$family) add("error", "methods.csv", i + 1L, methods$method_id[i], paste("family not in vocabulary:", methods$family[i]))
  if (!methods$default_treatment[i] %in% VOC$treatment) add("error", "methods.csv", i + 1L, methods$method_id[i], paste("default_treatment not in vocabulary:", methods$default_treatment[i]))
}
check_decision(methods, "methods.csv", function(i) methods$method_id[i])

## sources
key <- paste(sources$item_name, sources$filter, sep = " | ")
dup <- duplicated(key) | !nzchar(sources$item_name)
for (i in which(dup)) add("error", "source_methods.csv", i + 1L, key[i], "blank item_name or duplicated item_name + filter")
for (i in seq_len(nrow(sources))) {
  id <- key[i]
  if (!sources$method_id[i] %in% methods$method_id) add("error", "source_methods.csv", i + 1L, id, paste("method_id not in methods.csv:", sources$method_id[i]))
  if (!sources$target_merge[i] %in% VOC$target) add("error", "source_methods.csv", i + 1L, id, paste("target_merge not in vocabulary:", sources$target_merge[i]))
  if (!sources$treatment[i] %in% VOC$treatment) add("error", "source_methods.csv", i + 1L, id, paste("treatment not in vocabulary:", sources$treatment[i]))
  if (sources$treatment[i] %in% c("exclude", "off_by_default") &&
      (!nzchar(sources$reason[i]) || !nzchar(sources$evidence[i])))
    add("error", "source_methods.csv", i + 1L, id, "exclude/off_by_default row needs a reason and evidence")
}
check_decision(sources, "source_methods.csv", function(i) key[i])

## rules
dup <- duplicated(rules$rule_id) | !nzchar(rules$rule_id)
for (i in which(dup)) add("error", "pooling_rules.csv", i + 1L, rules$rule_id[i], "blank or duplicated rule_id")
for (i in seq_len(nrow(rules)))
  if (!rules$rule[i] %in% VOC$rule) add("error", "pooling_rules.csv", i + 1L, rules$rule_id[i], paste("rule not in vocabulary:", rules$rule[i]))
check_decision(rules, "pooling_rules.csv", function(i) rules$rule_id[i])

## item names against the registry (warning only)
reg <- file.path(root, "__ReadMe.xlsx")
if (requireNamespace("readxl", quietly = TRUE)) {
  items <- tryCatch(readxl::read_excel(reg, sheet = "Sheet1")$`Item name`, error = function(e) NULL)
  if (!is.null(items)) {
    unknown <- setdiff(unique(sources$item_name), items)
    for (u in unknown) add("warning", "source_methods.csv", match(u, sources$item_name) + 1L, u, "item_name not found in __ReadMe.xlsx Sheet1")
  }
} else add("note", "", NA, "", "readxl not installed: registry item-name check skipped")

utils::write.csv(findings, out_csv, row.names = FALSE)
n_err <- sum(findings$severity == "error")
message(sprintf("cell-count methods: %d methods, %d source rows, %d rules, %d reviews; %d errors, %d warnings. Report: %s",
                nrow(methods), nrow(sources), nrow(rules), nrow(reviews), n_err,
                sum(findings$severity == "warning"), out_csv))
if (n_err > 0) {
  print(findings[findings$severity == "error", ], row.names = FALSE)
  quit(status = 1)
}
