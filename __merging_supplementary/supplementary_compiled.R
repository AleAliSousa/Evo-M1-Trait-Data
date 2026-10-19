# =============================================================================
# __merging_supplementary/supplementary_compiled.R
#
# Mapping-driven merge for built public tables that no other __merging_* consumes
# (found by __Cytosplore_export/scan_source_tables.py, 2026-10-15). One row of
# supplementary_sources.csv = one source column -> one app variable. The script
# never decides a mapping; it only executes the CSV, so every inclusion, label,
# unit, role and aggregation is reviewable in one place.
#
#   Rscript __merging_supplementary/supplementary_compiled.R
#
# Output: supplementary_long.csv in the std_merge schema that __ShinyApp/app.R
# reads (Species, measure_class, Measure, Units, Value, Value_median, n_sources,
# n_teams, n_teams_primary, primary_used, Teams, roles, value_min, value_max,
# species_printed, accepted_name, species_basis, reidentified) plus
# n_specimens, items, label_policy.  app.R label = "<Measure> (<Units>)".
#
# supplementary_sources.csv columns
#   item                registry Item name (public TSV located via __ReadMe.xlsx
#                       "Item encoded") -- or leave blank and give `path`
#   path                repo-relative file when the source is not a public TSV
#                       (PanTHERIA: the original txt is the frozen snapshot)
#   source_publication  paper folder, passed to resolve_species()
#   species_col         printed-name column
#   filter              optional R expression evaluated on the table's columns
#   value_col           column holding the value
#   transform           optional arithmetic on the numeric value ("*1000", "/12")
#   na_values           values to treat as missing (e.g. -999), ';'-separated
#   Measure, Units      app label parts
#   label_policy        shared   = the label already exists in another merge and
#                                  the quantity is identical; the app pools them
#                       distinct = new label
#   measure_class, domain, Structure, poolable_group, poolable_family
#                       -> written to _keys/variable_domain.csv by the key step below
#   role                primary | secondary | both   (paper's role for this column)
#   aggregate           first | mean | median | mode | any_Y   (per resolved species)
#   note                free text, copied to README table
#
# Species: resolve_species(printed, source_publication) -- the single house
# resolver. Unresolved printed names are KEPT under the cleaned printed string
# with species_basis = "unresolved" (the resolver's own convention; the
# body_ecology merge keeps Wilman's 5,403 species the same way) and are also
# listed in supplementary_unresolved_species.csv for key work.
# =============================================================================
suppressPackageStartupMessages({ library(readr); library(dplyr) })
if (!isTRUE(l10n_info()[["UTF-8"]])) try(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"), silent = TRUE)

here <- {
  f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(f)) dirname(normalizePath(sub("^--file=", "", f[1]))) else getwd()
}
repo <- normalizePath(file.path(here, ".."))
stopifnot(dir.exists(file.path(repo, "_keys")))
source(file.path(repo, "_keys", "resolve_species.R"))

map <- read.csv(file.path(here, "supplementary_sources.csv"), stringsAsFactors = FALSE,
                check.names = FALSE, encoding = "UTF-8", na.strings = character(0), colClasses = "character")
stopifnot(all(c("item", "species_col", "value_col", "Measure", "Units", "role", "aggregate") %in% names(map)))

# registry: item -> encoded public filename
reg <- suppressWarnings(readxl::read_excel(file.path(repo, "__ReadMe.xlsx"), sheet = 1))
enc_of <- setNames(as.character(reg[["Item encoded"]]), as.character(reg[["Item name"]]))

read_source <- function(m) {
  if (nzchar(m$path)) {
    p <- file.path(repo, m$path)
    if (!file.exists(p)) stop("missing source file: ", m$path)
    if (grepl("\\.txt$", p)) return(read.delim(p, stringsAsFactors = FALSE, check.names = FALSE,
                                               fileEncoding = "latin1", quote = "", comment.char = ""))
    if (grepl("\\.tsv$", p)) return(read.delim(p, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8"))
    return(read.csv(p, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8"))
  }
  enc <- enc_of[[m$item]]
  if (is.null(enc) || is.na(enc) || !nzchar(enc)) stop("item not in __ReadMe.xlsx: ", m$item)
  p <- file.path(repo, "__Public", "comparative-data", paste0(sub("\\.tsv$", "", enc), ".tsv"))
  if (!file.exists(p)) stop("public TSV missing for ", m$item, ": ", p)
  read.delim(p, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
}

num_or_text <- function(x) suppressWarnings(as.numeric(x))
agg_fun <- function(v, how) {
  v <- v[!is.na(v) & nzchar(as.character(v))]
  if (!length(v)) return(NA)
  vn <- num_or_text(v)
  if (how == "first") return(v[1])
  if (how == "mean")   return(if (all(!is.na(vn))) mean(vn) else v[1])
  if (how == "median") return(if (all(!is.na(vn))) median(vn) else v[1])
  if (how == "mode")   return(names(sort(table(v), decreasing = TRUE))[1])
  if (how == "any_Y")  return(if (any(v == "Y")) "Y" else "N")
  stop("unknown aggregate: ", how)
}

cache <- list(); out <- list(); unresolved <- list()
for (i in seq_len(nrow(map))) {
  m <- map[i, ]
  key <- if (nzchar(m$path)) m$path else m$item
  if (is.null(cache[[key]])) cache[[key]] <- read_source(m)
  d <- cache[[key]]
  for (c in c(m$species_col, m$value_col))
    if (!c %in% names(d)) stop(m$item, ": column not found: ", c, "\n  have: ", paste(names(d), collapse = ", "))
  if (nzchar(m$filter)) {
    keep <- eval(parse(text = m$filter), envir = d)
    d <- d[!is.na(keep) & keep, , drop = FALSE]
  }
  printed <- trimws(as.character(d[[m$species_col]]))
  val <- as.character(d[[m$value_col]])
  if (nzchar(m$na_values)) {
    nas <- trimws(strsplit(m$na_values, ";")[[1]])
    vn <- num_or_text(val)
    val[val %in% nas | (!is.na(vn) & vn %in% num_or_text(nas))] <- NA
  }
  val[val %in% c("", "NA", "na", "n/a", "N/A")] <- NA
  ok <- !is.na(val) & nzchar(printed) & !printed %in% c("NA", "")
  d2 <- data.frame(printed = printed[ok], val = val[ok], stringsAsFactors = FALSE)
  if (!nrow(d2)) { message("  (no values) ", m$item, " / ", m$value_col); next }
  if (nzchar(m$transform)) {
    vn <- num_or_text(d2$val)
    vt <- eval(parse(text = paste0("vn ", m$transform)))
    d2$val <- ifelse(is.na(vn), d2$val, as.character(vt))
  }
  rs <- resolve_species(d2$printed, source_publication = m$source_publication)
  d2$accepted <- rs$accepted_name; d2$basis <- rs$species_basis; d2$reident <- rs$reidentified
  d2$unres <- rs$unresolved
  if (any(d2$unres))
    unresolved[[length(unresolved) + 1]] <- data.frame(item = m$item, printed = unique(d2$printed[d2$unres]),
                                                       stringsAsFactors = FALSE)
  if (!nrow(d2)) next
  sp <- split(d2, d2$accepted)
  rows <- lapply(sp, function(g) {
    v <- agg_fun(g$val, m$aggregate); vn <- num_or_text(g$val)
    data.frame(
      Species = g$accepted[1], measure_class = m$measure_class, Measure = m$Measure, Units = m$Units,
      Value = as.character(v),
      Value_median = if (all(!is.na(vn))) median(vn) else NA_real_,
      n_specimens = nrow(g),
      value_min = if (all(!is.na(vn))) min(vn) else NA_real_,
      value_max = if (all(!is.na(vn))) max(vn) else NA_real_,
      item = m$item, team = m$source_publication, role = m$role,
      species_printed = paste(unique(g$printed), collapse = "; "),
      accepted_name = g$accepted[1],
      species_basis = paste(unique(g$basis), collapse = "; "),
      reidentified = any(g$reident), label_policy = m$label_policy,
      stringsAsFactors = FALSE)
  })
  out[[length(out) + 1]] <- do.call(rbind, rows)
  message(sprintf("  %-42s %-38s %4d species", m$item, m$Measure, length(rows)))
}
long1 <- do.call(rbind, out)

# pool across items that map to the same Species x Measure x Units (rare here)
pool <- long1 %>%
  group_by(Species, measure_class, Measure, Units) %>%
  summarise(
    Value = { vn <- suppressWarnings(as.numeric(Value))
              if (all(!is.na(vn))) as.character(mean(vn)) else Value[1] },
    Value_median = { vn <- suppressWarnings(as.numeric(Value)); if (all(!is.na(vn))) median(vn) else NA_real_ },
    n_sources = n_distinct(item), n_teams = n_distinct(team),
    n_teams_primary = n_distinct(team[role %in% c("primary", "both")]),
    primary_used = any(role %in% c("primary", "both")),
    Teams = paste(sort(unique(team)), collapse = "; "),
    roles = paste(sort(unique(role)), collapse = "; "),
    value_min = suppressWarnings(min(value_min, na.rm = TRUE)), value_max = suppressWarnings(max(value_max, na.rm = TRUE)),
    n_specimens = sum(n_specimens),
    items = paste(sort(unique(item)), collapse = "; "),
    label_policy = label_policy[1],
    species_printed = paste(unique(species_printed), collapse = "; "),
    accepted_name = accepted_name[1],
    species_basis = paste(unique(species_basis), collapse = "; "),
    reidentified = any(reidentified), .groups = "drop") %>%
  mutate(value_min = ifelse(is.finite(value_min), value_min, NA), value_max = ifelse(is.finite(value_max), value_max, NA)) %>%
  arrange(Measure, Species)

long <- pool[, c("Species", "measure_class", "Measure", "Units", "Value", "Value_median", "n_sources", "n_teams",
                 "n_teams_primary", "primary_used", "Teams", "roles", "value_min", "value_max",
                 "species_printed", "accepted_name", "species_basis", "reidentified",
                 "n_specimens", "items", "label_policy")]
write.csv(long, file.path(here, "supplementary_long.csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
unres <- if (length(unresolved)) do.call(rbind, unresolved) else data.frame(item = character(0), printed = character(0))
write.csv(unres, file.path(here, "supplementary_unresolved_species.csv"), row.names = FALSE, fileEncoding = "UTF-8")
message(sprintf("wrote supplementary_long.csv: %d rows, %d measures, %d species; %d unresolved printed names",
                nrow(long), n_distinct(long$Measure), n_distinct(long$Species), nrow(unres)))

# ---- key step: make sure every NEW label has a variable_domain.csv row ------
# (shared labels already have one; the app classifies by label.) Appends only.
vd_path <- file.path(repo, "_keys", "variable_domain.csv")
vd_raw <- readLines(vd_path, encoding = "UTF-8", warn = FALSE)
eol <- if (any(grepl("\r$", vd_raw))) "\r\n" else "\n"
vd_raw <- sub("\r$", "", vd_raw)
vd <- read.csv(text = paste(vd_raw, collapse = "\n"), stringsAsFactors = FALSE, check.names = FALSE)
labels_new <- unique(long[long$label_policy == "distinct", c("Measure", "Units", "measure_class")])
labels_new$label <- paste0(labels_new$Measure, " (", labels_new$Units, ")")
labels_new <- labels_new[!labels_new$label %in% vd$label, , drop = FALSE]
if (nrow(labels_new)) {
  mm <- map[match(paste(labels_new$Measure, labels_new$Units), paste(map$Measure, map$Units)), ]
  add <- data.frame(
    label = labels_new$label, dataset = "Supplementary sources", domain = mm$domain,
    measure_class = mm$measure_class, Structure = mm$Structure, canonical_structure = mm$Structure,
    Measure = labels_new$Measure, Unit = labels_new$Units, structure_qualifier = "",
    structure_source = ifelse(nzchar(mm$Structure), "__merging_supplementary/supplementary_sources.csv", ""),
    is_measurement = "True",
    note = paste0("__merging_supplementary: ", mm$item, " / ", mm$value_col, " (", mm$role, "). ", mm$note),
    poolable_group = mm$poolable_group, poolable_family = mm$poolable_family, stringsAsFactors = FALSE)
  for (col in setdiff(names(vd), names(add))) add[[col]] <- ""
  add <- add[, names(vd)]
  con <- file(vd_path, open = "wb")
  tmp <- tempfile(); write.csv(add, tmp, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  new_lines <- readLines(tmp, encoding = "UTF-8")[-1]
  writeLines(c(vd_raw, new_lines), con, sep = eol, useBytes = TRUE); close(con)
  message("appended ", nrow(add), " label rows to _keys/variable_domain.csv -> run _keys/build_variable_definitions.R")
} else message("variable_domain.csv already has every label")
