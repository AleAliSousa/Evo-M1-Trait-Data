# =============================================================================
# __compiled/datapoints.R  --  the one route: item columns -> data points -> species values
#
# Sourced by __compiled/build_compiled.R. No merge folder is read.
#
#   1. The map, __compiled/item_columns.csv: one row per included source column. It names the
#      registered item (or a repo path for a table that is not registered), the species column,
#      the value column, the trait label and unit, and optionally specimen and n columns. A
#      table whose species column is the item builder's identification (the table prints common
#      names, say) names the column with the name as printed in printed_col; both are kept. A
#      column or an R expression over the table's columns may be given for species_col,
#      value_col and n_col; a value computed by an expression is marked in `derived`.
#      `label` may contain {column} placeholders, filled from the row (e.g. the area name).
#   2. Data points: one row per mapped source cell that holds a value -- as printed, never
#      averaged here. Written beside the table as datapoints.csv.gz (the provenance table).
#   3. Rules, applied to every data point in the same order (owner's rules):
#        taxon        resolve_species() (the house resolver; unresolved names are kept under
#                     the cleaned printed name, species_basis "unresolved"); a subspecies keeps its
#                     printed name for the subspecies rule of build_compiled.R
#        species value  within a report (one item), its points for a species and trait are
#                     averaged (specimens, rows); across reports the value is the plain mean of
#                     the independent reports (owner, 25 November 2026: "mean of independent
#                     reports"). N_sources = number of reports.
#      The same-data, same-specimen and not-served rules join here as traits move onto this
#      route; until then every point's status is "served".
#   The rows returned carry the table's columns; build_compiled.R treats them like any other
#   rows (species display aliases, Hemispheres, subspecies rule, population verdict, keys).
# =============================================================================

## Numbers are written with 15 significant digits (the precision of a stored number), one at a time:
## a single data point is served as printed, a mean is not rounded.
dp_fmt <- function(x) vapply(x, function(v)
  if (is.na(v)) NA_character_ else format(v, scientific = FALSE, trim = TRUE, digits = 15), character(1))

dp_read_map <- function(repo) {
  m <- read.csv(file.path(repo, "__compiled", "item_columns.csv"), colClasses = "character",
                check.names = FALSE, na.strings = character(0), encoding = "UTF-8")
  need <- c("item", "path", "source_publication", "team", "dataset", "species_col", "printed_col", "filter",
            "value_col", "label", "unit", "role", "specimen_col", "n_col", "derived", "note")
  miss <- setdiff(need, names(m))
  if (length(miss)) stop("__compiled/item_columns.csv lacks column(s): ", paste(miss, collapse = ", "), call. = FALSE)
  m
}

dp_read_source <- function(repo, m, enc_of) {
  rd_tsv <- function(p) read.delim(p, colClasses = "character", check.names = FALSE,
                                   na.strings = character(0), encoding = "UTF-8")
  if (nzchar(m$path)) {
    p <- file.path(repo, m$path)
    if (!file.exists(p)) stop("item_columns.csv: missing source file ", m$path, call. = FALSE)
    if (grepl("\\.tsv$", p)) return(rd_tsv(p))
    return(read.csv(p, colClasses = "character", check.names = FALSE, na.strings = character(0), encoding = "UTF-8"))
  }
  enc <- unname(enc_of[m$item])
  if (length(enc) != 1L || is.na(enc) || !nzchar(enc))
    stop("item_columns.csv: item not in __ReadMe.xlsx: ", m$item, call. = FALSE)
  p <- file.path(repo, "__Public", "comparative-data", paste0(sub("\\.tsv$", "", enc), ".tsv"))
  if (!file.exists(p)) stop("item_columns.csv: public TSV missing for ", m$item, ": ", p, call. = FALSE)
  rd_tsv(p)
}

## A column name, else an R expression over the table's columns (typed: numbers as numbers).
dp_eval <- function(spec, d, typed, what, item) {
  if (spec %in% names(d)) return(d[[spec]])
  tryCatch(eval(parse(text = spec), envir = typed), error = function(e)
    stop(item, ": ", what, " is neither a column nor a valid expression: ", spec, "\n  ",
         conditionMessage(e), call. = FALSE))
}

dp_points <- function(repo) {
  map <- dp_read_map(repo)
  reg <- suppressWarnings(readxl::read_excel(file.path(repo, "__ReadMe.xlsx"), sheet = 1))
  enc_of <- setNames(as.character(reg[["Item encoded"]]), as.character(reg[["Item name"]]))
  cache <- list(); out <- vector("list", nrow(map))
  for (i in seq_len(nrow(map))) {
    m <- map[i, ]
    key <- if (nzchar(m$path)) m$path else m$item
    if (is.null(cache[[key]])) cache[[key]] <- dp_read_source(repo, m, enc_of)
    d <- cache[[key]]
    typed <- utils::type.convert(d, as.is = TRUE, na.strings = c("", "NA"))
    row <- seq_len(nrow(d))
    if (nzchar(m$filter)) {
      keep <- dp_eval(m$filter, d, typed, "filter", m$item); keep <- !is.na(keep) & keep
      d <- d[keep, , drop = FALSE]; typed <- typed[keep, , drop = FALSE]; row <- row[keep]
    }
    sp <- trimws(as.character(dp_eval(m$species_col, d, typed, "species_col", m$item)))
    pr <- if (nzchar(m$printed_col)) trimws(as.character(dp_eval(m$printed_col, d, typed, "printed_col", m$item))) else sp
    v  <- dp_eval(m$value_col, d, typed, "value_col", m$item)
    vtxt <- trimws(as.character(v)); vtxt[is.na(v) | is.nan(suppressWarnings(as.numeric(v)))] <- NA
    vtxt[vtxt %in% c("", "NA", "NaN", "na", "n/a", "N/A")] <- NA
    n <- if (nzchar(m$n_col)) as.character(dp_eval(m$n_col, d, typed, "n_col", m$item)) else rep(NA_character_, nrow(d))
    spec <- if (nzchar(m$specimen_col)) as.character(dp_eval(m$specimen_col, d, typed, "specimen_col", m$item)) else rep("", nrow(d))
    labs <- rep(m$label, nrow(d))
    for (ph in regmatches(m$label, gregexpr("\\{[^}]+\\}", m$label))[[1]]) {
      col <- substr(ph, 2, nchar(ph) - 1)
      if (!col %in% names(d)) stop(m$item, ": label placeholder names no column: ", ph, call. = FALSE)
      labs <- mapply(function(l, x) sub(ph, x, l, fixed = TRUE), labs, trimws(d[[col]]), USE.NAMES = FALSE)
    }
    ok <- !is.na(vtxt) & nzchar(sp) & !sp %in% c("NA", "")
    if (!any(ok)) { message("  (no values) ", m$item, " / ", m$value_col); next }
    out[[i]] <- data.frame(
      item = m$item, team = m$team, dataset = m$dataset, source_publication = m$source_publication,
      source_row = row[ok], value_col = m$value_col, trait = labs[ok], unit = m$unit,
      species_printed = pr[ok], species_named = sp[ok], value_printed = vtxt[ok],
      value = suppressWarnings(as.numeric(vtxt[ok])), n = n[ok], specimen = spec[ok],
      role = m$role, derived = m$derived, stringsAsFactors = FALSE)
  }
  p <- do.call(rbind, out)
  if (is.null(p) || !nrow(p)) stop("item_columns.csv produced no data points", call. = FALSE)
  rs <- resolve_species(p$species_named, source_publication = p$source_publication)
  ## A subspecies keeps its printed name here, so that the subspecies rule of build_compiled.R
  ## (_keys/species_pooling.csv; owner, step 5) files it under its species and fills the Subspecies
  ## column, as for every other row of the table. The resolver alone would drop the subspecies.
  sub <- rs$species_basis == "subspecies_assign"
  p$species <- ifelse(sub, species_normalise(p$species_named), rs$accepted_name); p$species_basis <- rs$species_basis
  p$point_id <- paste(p$item, p$source_row, p$trait, sep = " # ")
  if (anyDuplicated(p$point_id)) stop("duplicate data point id: ", p$point_id[anyDuplicated(p$point_id)], call. = FALSE)
  p$status <- "served"
  p[, c("point_id", "item", "source_publication", "team", "dataset", "source_row", "value_col", "trait", "unit",
        "species_printed", "species_named", "species", "species_basis", "value_printed", "value", "n", "specimen",
        "role", "derived", "status")]
}

## One row per species and trait, in the table's columns.
dp_species_values <- function(p) {
  s <- p[p$status == "served", , drop = FALSE]
  if (anyNA(s$value)) stop("a served data point has a value that is not a number: ",
                           s$point_id[is.na(s$value)][1], call. = FALSE)
  rep_key <- paste(s$species, s$trait, s$item, sep = "\r")
  r <- data.frame(species = tapply(s$species, rep_key, `[`, 1), trait = tapply(s$trait, rep_key, `[`, 1),
                  item = tapply(s$item, rep_key, `[`, 1), team = tapply(s$team, rep_key, `[`, 1),
                  dataset = tapply(s$dataset, rep_key, `[`, 1), unit = tapply(s$unit, rep_key, `[`, 1),
                  role = tapply(s$role, rep_key, function(x) paste(sort(unique(x)), collapse = "; ")),
                  value = tapply(s$value, rep_key, mean), n_points = as.integer(tapply(s$value, rep_key, length)),
                  vmin = tapply(s$value, rep_key, min), vmax = tapply(s$value, rep_key, max),
                  stringsAsFactors = FALSE)
  key <- paste(r$species, r$trait, sep = "\r")
  g <- split(r, key)
  rows <- lapply(g, function(x) {
    if (length(unique(x$dataset)) != 1L || length(unique(x$unit)) != 1L)
      stop("trait ", x$trait[1], " has more than one dataset or unit in item_columns.csv", call. = FALSE)
    np <- sum(x$n_points); k <- nrow(x); v <- mean(x$value)
    det <- if (np == 1L) sprintf("1 data point (%s)", x$role)
           else sprintf("%d data points in %d report%s; range %s to %s (%s)", np, k, if (k > 1) "s" else "",
                        dp_fmt(min(x$vmin)), dp_fmt(max(x$vmax)), paste(sort(unique(x$role)), collapse = "; "))
    items <- paste(sort(unique(x$item)), collapse = "; ")
    data.frame(Species = x$species[1], Dataset = x$dataset[1], Variable = x$trait[1],
               Value = dp_fmt(v), Value_num = suppressWarnings(as.numeric(dp_fmt(v))),
               Source = items, Items = items, Source_details = det,
               Teams = paste(sort(unique(x$team)), collapse = "; "), N_sources = k,
               Variable_raw = x$trait[1], Unit = x$unit[1], Unit_raw = x$unit[1], stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows); rownames(out) <- NULL
  out$N_sources <- as.integer(out$N_sources)
  out[order(out$Species, out$Variable, method = "radix"), ]
}

dp_write_points <- function(p, out_dir) {
  f <- file.path(out_dir, "datapoints.csv.gz"); tmp <- paste0(f, ".tmp")
  q <- p; q$value <- dp_fmt(q$value)
  con <- gzfile(tmp, open = "wb", compression = 9)
  utils::write.csv(q[order(q$item, q$source_row, q$trait, method = "radix"), ], con, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  close(con)
  if (!file.rename(tmp, f)) stop("Could not move ", f, " into place", call. = FALSE)
  invisible(f)
}
