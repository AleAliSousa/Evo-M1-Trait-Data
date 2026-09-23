#!/usr/bin/env Rscript
# =============================================================================
# build_collection_resolution.R
#
# Builds _keys/collection_resolution.csv: one row per distinct raw `collection`
# string ever seen in _keys/specimen_crosswalk/specimen_crosswalk.csv, resolved
# into a clean collection_group and a separated collection_qualifier.
#
# Why this exists: the raw `collection` column conflates three different
# things in one free-text string --
#   1. the actual holding collection (Zilles, Welker, Huber-Crosby, ...)
#   2. the institute that HOSTS several collections (Hirnforschung hosts
#      Stephan/Zilles/Semendeferi -- it is not itself a fourth collection)
#   3. the source colony an animal came FROM, which is not who holds its
#      brain now (Yerkes is where the animal lived, not a holding collection;
#      "Zilles (ex Yerkes)" is the Zilles collection, sourced from Yerkes)
# _keys/collection_registry.csv already documents the grouping evidence and
# the parse rules (semicolon-separated components; a trailing parenthetical
# is a qualifier, not part of the name; a "from <institution>" component is a
# supplying-colony qualifier). This script applies those rules mechanically
# and writes the result so consumers (the app, other builds) get clean labels
# without re-deriving them, and so the resolution can never drift from the
# registry the way a hand-copied needle list once did (see kernel.py history
# in the specimen-taxon-tracking skill).
#
# Inputs : _keys/collection_registry.csv,
#          _keys/specimen_crosswalk/specimen_crosswalk.csv (collection column only)
# Output : _keys/collection_resolution.csv
#   columns: collection (raw string, join key), n_specimens (row count in
#   specimen_crosswalk.csv), collection_group, collection_qualifier,
#   resolution_status ("resolved" or "UNGROUPED" -- never silently blank)
#
# Consumers join on `collection` (case-sensitive exact string) to attach
# collection_group/collection_qualifier without touching specimen_crosswalk.csv's
# own locked column contract (see SCHEMA.md) -- this is an additive lookup,
# not a schema change.
#
# Run from anywhere:  Rscript _keys/build_collection_resolution.R
# Re-run whenever collection_registry.csv changes, or specimen_crosswalk.csv
# gains a new raw collection string (the build's own UNGROUPED report at the
# end tells you when that's happened).
# =============================================================================

args     <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
keys_dir <- if (length(file_arg)) dirname(normalizePath(file_arg)) else getwd()
repo     <- normalizePath(file.path(keys_dir, ".."))
message("repo: ", repo)

trim <- function(x) trimws(as.character(x))
rd   <- function(p) read.csv(p, stringsAsFactors = FALSE, check.names = FALSE,
                              colClasses = "character", encoding = "UTF-8")

registry_path   <- file.path(keys_dir, "collection_registry.csv")
crosswalk_path  <- file.path(keys_dir, "specimen_crosswalk", "specimen_crosswalk.csv")
registry_raw    <- rd(registry_path)
crosswalk       <- rd(crosswalk_path)

# ---- 1. registry lookup: collection_string -> collection_group -------------
# Skip the '<parse rule>' documentation rows and the 'FOSSIL_<SITE>' template
# row; those describe HOW to parse a compound string, they are not literal
# entries to match against.
reg <- registry_raw[!(registry_raw$collection_group == "<parse rule>" |
                       startsWith(registry_raw$collection_group, "FOSSIL_<")), ]
registry_lookup <- setNames(trim(reg$collection_group), tolower(trim(reg$collection_string)))
registry_get <- function(key) {
  v <- registry_lookup[match(key, names(registry_lookup))]
  if (is.na(v)) "" else unname(v)
}

# ---- 2. fossil-site slugging: site name before the first comma, ASCII-folded
fossil_group <- function(text) {
  m <- regmatches(text, regexpr("\\(([^()]*)\\)", text))
  inside <- if (nzchar(m)) sub("^\\(|\\)$", "", m) else text
  site <- trim(strsplit(inside, ",", fixed = TRUE)[[1]][1])
  slug <- iconv(site, "UTF-8", "ASCII//TRANSLIT", sub = "")
  slug <- toupper(gsub("[^A-Za-z0-9]+", "_", slug))
  slug <- gsub("^_+|_+$", "", slug)
  paste0("FOSSIL_", slug)
}

# ---- 3. parenthesis-aware semicolon split -----------------------------------
paren_aware_split <- function(text, sep = ";") {
  chars <- strsplit(text, "")[[1]]
  depth <- 0L; cur <- ""; parts <- character(0)
  for (ch in chars) {
    if (ch == "(") { depth <- depth + 1L; cur <- paste0(cur, ch) }
    else if (ch == ")") { depth <- depth - 1L; cur <- paste0(cur, ch) }
    else if (ch == sep && depth == 0L) { parts <- c(parts, cur); cur <- "" }
    else cur <- paste0(cur, ch)
  }
  parts <- c(parts, cur)
  parts <- trim(parts)
  parts[nzchar(parts)]
}

strip_trailing_paren <- function(text) {
  m <- regmatches(text, regexec("^(.*\\S)\\s*\\(([^()]*)\\)\\s*$", text))[[1]]
  if (length(m) == 3) list(base = trim(m[2]), qualifier = trim(m[3]))
  else list(base = text, qualifier = "")
}

# Only genuinely blank/placeholder tokens with no registry row of their own.
# "unknown" and "not stated" are NOT here -- both have explicit UNKNOWN rows
# in collection_registry.csv and must resolve through that lookup like any
# other string, not be silently skipped.
NA_VALUES <- c("na", "nan", "n/a", "?", "-", "")

# ---- 4. resolve one raw collection string -----------------------------------
resolve_group <- function(text, depth = 0L) {
  text <- trim(text)
  low <- tolower(text)
  if (!nzchar(text) || low %in% NA_VALUES) return("")
  if (startsWith(low, "fossil")) return(fossil_group(text))
  hit <- registry_get(low)
  if (nzchar(hit)) return(hit)

  if (depth == 0L) {
    parts <- paren_aware_split(text)
    if (length(parts) > 1) {
      groups <- character(0)
      for (p in parts) {
        if (startsWith(tolower(p), "from ")) next
        g <- resolve_group(p, depth = 1L)
        if (nzchar(g) && !startsWith(g, "UNGROUPED:") && !(g %in% groups)) groups <- c(groups, g)
      }
      if (length(groups)) return(paste(groups, collapse = ";"))
    }
  }

  split_paren <- strip_trailing_paren(text)
  if (split_paren$base != text) {
    g <- resolve_group(split_paren$base, depth = 1L)
    if (nzchar(g)) return(g)
  }

  for (k in names(registry_lookup)) {
    if (grepl(k, low, fixed = TRUE) || (nchar(low) > 3 && grepl(low, k, fixed = TRUE))) {
      return(unname(registry_lookup[[k]]))
    }
  }
  if (grepl("yerkes", low, fixed = TRUE) || grepl("emory", low, fixed = TRUE)) return("SOURCE_NOT_HOLDER")
  paste0("UNGROUPED:", text)
}

resolve_qualifier <- function(text) {
  text <- trim(text)
  low <- tolower(text)
  if (!nzchar(text) || low %in% NA_VALUES || startsWith(low, "fossil")) return("")
  quals <- character(0)
  parts <- paren_aware_split(text)
  if (length(parts) > 1) {
    for (p in parts) {
      if (startsWith(tolower(p), "from ")) {
        quals <- c(quals, p)
      } else {
        sp <- strip_trailing_paren(p)
        if (nzchar(sp$qualifier)) quals <- c(quals, sp$qualifier)
      }
    }
  } else {
    sp <- strip_trailing_paren(text)
    if (nzchar(sp$qualifier)) quals <- c(quals, sp$qualifier)
  }
  paste(quals, collapse = "; ")
}

# ---- 5. materialize one row per distinct raw collection string -------------
counts <- table(crosswalk$collection)
distinct_vals <- names(counts)

# NOT counts[distinct_vals]: indexing a table/named vector by the literal
# empty-string name "" returns NA in R (a name-lookup quirk), which silently
# corrupted the blank-collection row's count. match() doesn't have that quirk.
out <- data.frame(
  collection = distinct_vals,
  n_specimens = as.integer(unname(counts))[match(distinct_vals, names(counts))],
  stringsAsFactors = FALSE
)
out$collection_group     <- vapply(out$collection, resolve_group, character(1))
out$collection_qualifier <- vapply(out$collection, resolve_qualifier, character(1))
out$resolution_status <- ifelse(
  !nzchar(out$collection_group) | startsWith(out$collection_group, "UNGROUPED:"),
  "UNGROUPED", "resolved"
)
out <- out[order(-out$n_specimens), ]

# UTF-8-safe write: build the CSV text ourselves and write raw bytes, bypassing
# the session locale (matches build_variable_definitions.R's convention).
csv_field <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  needs <- grepl('[",\n\r]', x)
  x[needs] <- paste0('"', gsub('"', '""', x[needs]), '"')
  x
}
lines <- c(
  paste(csv_field(names(out)), collapse = ","),
  do.call(paste, c(lapply(out, csv_field), sep = ",")))
out_path <- file.path(keys_dir, "collection_resolution.csv")
con <- file(out_path, open = "wb")
writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), con)
close(con)

n_ungrouped <- sum(out$resolution_status == "UNGROUPED" & nzchar(out$collection))
message(
  "distinct raw collection strings: ", nrow(out), " (", sum(out$n_specimens), " specimen rows)\n",
  "resolved: ", sum(out$resolution_status == "resolved"), " | UNGROUPED: ", n_ungrouped
)
if (n_ungrouped > 0) {
  ug <- out[out$resolution_status == "UNGROUPED" & nzchar(out$collection), ]
  message("UNGROUPED (add a row to _keys/collection_registry.csv, then re-run):")
  message(paste(" -", ug$collection, sprintf("(%d specimens)", ug$n_specimens), collapse = "\n"))
}
message("DONE -> _keys/collection_resolution.csv")
