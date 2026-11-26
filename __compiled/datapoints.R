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
#      `value_type` is "number" (default) or "text" (a category, served as words).
#   2. Data points: one row per mapped source cell that holds a value -- as printed, never
#      averaged here. Written beside the table as datapoints.csv.gz (the provenance table).
#   3. Rules, applied to every data point in the same order (owner's rules):
#        taxon        resolve_species() (the house resolver; unresolved names are kept under
#                     the cleaned printed name, species_basis "unresolved"); a subspecies keeps its
#                     printed name for the subspecies rule of build_compiled.R (filed under its
#                     species by default; owner, 26 November 2026). species_accepted (in
#                     datapoints.csv.gz) is the name the table files the point under. Then the
#                     served name (build_compiled.R: aliases, one name per NCBI taxon) replaces
#                     the resolver's, kept as species_resolved.
#        species value  within a report (one item), its points for a species and trait are
#                     pooled first (numbers: the mean over source rows of the row means; text: its
#                     distinct values); across reports a number is the plain mean of the independent
#                     reports (owner, 25 November 2026: "mean of independent reports"; arithmetic
#                     mean everywhere, 26 November 2026). A text trait (value_type "text" in the map,
#                     e.g. diet or activity categories) is served as words: reports that agree give
#                     one value; reports that differ give all their values, sorted, "a; b", and
#                     Source_details says "the reports differ" ("the values differ" when the
#                     values come from one report) (owner, 26 November 2026).
#                     N_sources = number of reports.
#        roles        primary / secondary / both, per data point: from the map (a literal, or an
#                     expression over the row) or from __compiled/point_decisions.csv
#        same data    (owner, 24-25 November 2026) a copy counts once:
#                     - a relay (secondary point that cites a work) whose cited work has a report
#                       here for the species and trait: the same value (within 0.5 %, or equal to one
#                       of its specimens) is "same_data"; a different value is
#                       "differs_from_cited_source" and is not served (as step 14);
#                     - relays of a work that has no report here form one report on its behalf
#                       when they agree; when they differ, each relaying item is its own report,
#                       named "<work> via <item> (relays differ)" (owner, 26 November 2026);
#                     - a secondary point with no cited work equal to another report (or one of its
#                       specimens) is "same_data"; one that differs from every other report is
#                       "differs_from_other_reports" and is not served (owner, 25 November 2026);
#                       with no report here, compilations that agree form one report, and
#                       compilations that differ each count, named "<item> (source not given;
#                       compilations differ)" (owner, 26 November 2026: their mean, marked).
#                     Text values are the same when their words are (case and spacing aside).
#        not served   point decisions with serve = no (reason and evidence in the file)
#      A report's value is the mean over its source rows of the row means (the hemispheres of one
#      specimen row are averaged first).
#   The rows returned carry the table's columns; build_compiled.R treats them like any other
#   rows (species display aliases, Hemispheres, subspecies rule, population verdict, keys).
# =============================================================================

## Numbers are written with 15 significant digits (the precision of a stored number), one at a time:
## a single data point is served as printed, a mean is not rounded.
dp_fmt <- function(x) vapply(x, function(v)
  if (is.na(v)) NA_character_ else format(v, scientific = FALSE, trim = TRUE, digits = 15), character(1))


DP_ROLES <- c("primary", "secondary", "both")
## Owner, 25 November 2026: a value of a compilation that names no source and differs from every other
## report of the species is not served.
DP_SERVE_UNCITED_DIFFERING <- FALSE
dp_close <- function(a, b) abs(a - b) <= 0.005 * pmax(abs(a), abs(b)) + 1e-12   # same value: within 0.5 %

dp_read_decisions <- function(repo) {
  f <- file.path(repo, "__compiled", "point_decisions.csv")
  if (!file.exists(f)) return(data.frame())
  d <- read.csv(f, colClasses = "character", check.names = FALSE, na.strings = character(0), encoding = "UTF-8")
  need <- c("item", "species_printed", "value_col", "value_printed", "role", "cites", "serve", "reason", "evidence", "decided_by", "date")
  miss <- setdiff(need, names(d))
  if (length(miss)) stop("__compiled/point_decisions.csv lacks column(s): ", paste(miss, collapse = ", "), call. = FALSE)
  d
}

## Per-point decisions, then the same-data rule for every species and trait.
## Owner's rules (24-26 November 2026). Within one report (one item) the points of a species are pooled
## first: numbers by the mean over source rows of the row means, text by its distinct values. Then:
##   - a relay whose cited work has a report here: same value (within 0.5 %, or equal to one of its rows) is
##     "same_data"; a different value is "differs_from_cited_source", not served;
##   - relays of a work with no report here: if the relaying items agree, one report on the work's behalf;
##     if they differ, each relaying item is its own report, named "<work> via <item> (relays differ)";
##   - a point with no stated source equal to a report here is "same_data"; one that differs from every
##     report is "differs_from_other_reports", not served; with no report here, the items that give such
##     values form one report if they agree, else each item is its own report, named
##     "<item> (source not given; compilations differ)" (owner, 26 November 2026: their mean, marked).
## Text values agree when they are the same words (case and spacing aside).
dp_rules <- function(p, dec) {
  for (i in seq_len(nrow(dec))) {
    x <- dec[i, ]
    sel <- p$item == x$item & p$species_printed == x$species_printed & p$value_col == x$value_col &
           (!nzchar(x$value_printed) | p$value_printed == x$value_printed)
    if (!any(sel)) stop("__compiled/point_decisions.csv row ", i + 1L, " (", x$item, ", ", x$species_printed,
                        ") matches no data point", call. = FALSE)
    if (nzchar(x$role)) p$role[sel] <- x$role
    if (nzchar(x$cites)) p$cites[sel] <- x$cites
    if (tolower(x$serve) %in% c("no", "false")) p$status[sel] <- paste0("not_served: ", x$reason)
  }
  norm <- function(v) tolower(gsub("[[:space:]]+", " ", trimws(v)))
  key <- paste(p$species, p$trait, sep = "\r")
  ## A species and trait served by one item, with no relay and one kind of role, needs no comparison:
  ## its points are one report (the item; "(source not given)" for a compilation). Done for all such
  ## keys at once; the loop below handles the rest.
  sv <- p$status == "served"; prim0 <- p$role %in% c("primary", "both"); rel0 <- !prim0 & nzchar(p$cites)
  ks <- key[sv]
  one_item <- tapply(p$item[sv], ks, function(v) length(unique(v)) == 1L)
  no_rel   <- tapply(rel0[sv], ks, function(v) !any(v))
  one_kind <- tapply(prim0[sv], ks, function(v) all(v) || !any(v))
  easy <- names(one_item)[one_item & no_rel & one_kind]
  e <- sv & key %in% easy
  p$report[e] <- ifelse(prim0[e], p$item[e], paste(p$item[e], "(source not given)"))
  groups <- split(seq_len(nrow(p)), key)
  groups <- groups[!names(groups) %in% easy]
  for (k in names(groups)) {
    ix <- groups[[k]]; ix <- ix[p$status[ix] == "served"]; if (!length(ix)) next
    q <- p[ix, ]; text <- identical(q$value_type[1], "text")
    same <- function(v, w) if (text) any(norm(v) == norm(w)) else any(dp_close(v, w))
    ## the value(s) a set of points of one item gives: text -> distinct values; numbers -> the report
    ## mean followed by its row means (a copy may equal the mean or one of the rows)
    ival <- function(j) if (text) sort(unique(norm(q$value_printed[j]))) else {
      rv <- tapply(q$value[j], q$source_row[j], mean); c(mean(rv), unname(rv)) }
    agree <- function(vals) if (text) length(unique(vapply(vals, paste, "", collapse = "\r"))) == 1L else
      all(dp_close(vapply(vals, `[`, 0, 1), vals[[1]][1]))
    prim <- q$role %in% c("primary", "both"); rel <- !prim & nzchar(q$cites); unc <- !prim & !nzchar(q$cites)
    reps <- list()
    for (it in unique(q$item[prim])) {
      j <- which(prim & q$item == it)
      reps[[it]] <- list(vals = ival(j), origin = c(it, q$source_publication[j[1]]))
      p$report[ix[j]] <- it
    }
    for (cw in unique(q$cites[rel])) {
      j <- which(rel & q$cites == cw)
      hit <- Filter(function(nm) cw %in% reps[[nm]]$origin, names(reps))
      if (length(hit)) {
        for (jj in j) if (same(if (text) q$value_printed[jj] else q$value[jj], reps[[hit[1]]]$vals)) {
                        p$status[ix[jj]] <- "same_data"; p$same_as[ix[jj]] <- hit[1] }
                      else p$status[ix[jj]] <- "differs_from_cited_source"
      } else {
        its <- unique(q$item[j]); iv <- lapply(its, function(it) ival(j[q$item[j] == it]))
        if (agree(iv)) {
          reps[[cw]] <- list(vals = unique(unlist(iv)), origin = cw); p$report[ix[j]] <- cw
        } else for (n in seq_along(its)) {
          nm <- paste0(cw, " via ", its[n], " (relays differ)"); jn <- j[q$item[j] == its[n]]
          reps[[nm]] <- list(vals = iv[[n]], origin = c(nm, cw)); p$report[ix[jn]] <- nm
        }
      }
    }
    left <- integer(0)
    for (jj in which(unc)) {
      hit <- Filter(function(nm) same(if (text) q$value_printed[jj] else q$value[jj], reps[[nm]]$vals), names(reps))
      if (length(hit)) { p$status[ix[jj]] <- "same_data"; p$same_as[ix[jj]] <- paste(hit, collapse = "; ") }
      else left <- c(left, jj)
    }
    if (length(left)) {
      if (length(reps) && !DP_SERVE_UNCITED_DIFFERING) { p$status[ix[left]] <- "differs_from_other_reports"; next }
      if (length(reps)) { p$report[ix[left]] <- paste(q$item[left], "(source not given)"); next }
      its <- sort(unique(q$item[left])); iv <- lapply(its, function(it) ival(left[q$item[left] == it]))
      if (agree(iv)) p$report[ix[left]] <- paste(paste(its, collapse = " + "), "(source not given)")
      else for (n in seq_along(its)) {
        jn <- left[q$item[left] == its[n]]
        p$report[ix[jn]] <- paste(its[n], "(source not given; compilations differ)")
      }
    }
  }
  p
}

dp_read_map <- function(repo) {
  m <- read.csv(file.path(repo, "__compiled", "item_columns.csv"), colClasses = "character",
                check.names = FALSE, na.strings = character(0), encoding = "UTF-8")
  need <- c("item", "path", "source_publication", "team", "dataset", "species_col", "printed_col", "filter",
            "value_col", "label", "unit", "role", "cites", "hemisphere", "specimen_col", "n_col", "derived", "note")
  miss <- setdiff(need, names(m))
  if (length(miss)) stop("__compiled/item_columns.csv lacks column(s): ", paste(miss, collapse = ", "), call. = FALSE)
  ## value_type: "number" (default) or "text" (categories, served as words; owner, 26 November 2026)
  if (!"value_type" %in% names(m)) m$value_type <- ""
  m$value_type[!nzchar(m$value_type)] <- "number"
  if (any(!m$value_type %in% c("number", "text")))
    stop("__compiled/item_columns.csv: value_type must be number or text: ", paste(unique(m$value_type[!m$value_type %in% c("number", "text")]), collapse = ", "), call. = FALSE)
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

dp_points <- function(repo, rename = identity) {
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
    role <- if (m$role %in% DP_ROLES) rep(m$role, nrow(d)) else as.character(dp_eval(m$role, d, typed, "role", m$item))
    if (any(!role %in% DP_ROLES)) stop(m$item, ": role must be primary, secondary or both: ", paste(unique(role[!role %in% DP_ROLES]), collapse = ", "), call. = FALSE)
    cites <- if (!nzchar(m$cites)) rep("", nrow(d)) else if (m$cites %in% names(d) || grepl("[(\\[]", m$cites))
      as.character(dp_eval(m$cites, d, typed, "cites", m$item)) else rep(m$cites, nrow(d))
    cites[is.na(cites)] <- ""
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
      value = if (m$value_type == "text") NA_real_ else suppressWarnings(as.numeric(vtxt[ok])), n = n[ok], specimen = spec[ok], hemisphere = m$hemisphere,
      role = role[ok], cites = cites[ok], derived = m$derived, value_type = m$value_type, stringsAsFactors = FALSE)
  }
  p <- do.call(rbind, out)
  if (is.null(p) || !nrow(p)) stop("item_columns.csv produced no data points", call. = FALSE)
  rs <- resolve_species(p$species_named, source_publication = p$source_publication)
  ## A subspecies keeps its printed name here, so that the subspecies rule of build_compiled.R
  ## (_keys/species_pooling.csv; owner, step 5) files it under its species and fills the Subspecies
  ## column, as for every other row of the table. The resolver alone would drop the subspecies.
  sub <- rs$species_basis == "subspecies_assign"
  p$species <- ifelse(sub, species_normalise(p$species_named), rs$accepted_name); p$species_basis <- rs$species_basis
  p$species_accepted <- rs$accepted_name   # the species a subspecies is filed under (build_compiled.R)
  ## The name each species is served under (build_compiled.R: the aliases, then one name per NCBI
  ## taxon), applied before the rules, so reports of one species under two names are compared as one
  ## species. species_resolved keeps the resolver's name.
  p$species_resolved <- p$species
  p$species <- rename(p$species); p$species_accepted <- rename(p$species_accepted)
  p$point_id <- paste(p$item, p$source_row, p$trait, sep = " # ")
  p$point_id <- ifelse(nzchar(p$hemisphere), paste(p$point_id, p$hemisphere, sep = " # "), p$point_id)
  if (anyDuplicated(p$point_id)) stop("duplicate data point id: ", p$point_id[anyDuplicated(p$point_id)], call. = FALSE)
  p$status <- "served"; p$report <- ""; p$same_as <- ""
  p <- dp_rules(p, dp_read_decisions(repo))
  p[, c("point_id", "item", "source_publication", "team", "dataset", "source_row", "value_col", "trait", "unit",
        "species_printed", "species_named", "species_resolved", "species", "species_basis", "species_accepted", "value_printed", "value",
        "value_type", "n", "specimen", "hemisphere", "role", "cites", "derived", "status", "report", "same_as")]
}

## One row per species and trait, in the table's columns: the mean of the reports (numbers); for text,
## the one value the reports agree on, or every distinct value, listed (owner, 26 November 2026).
dp_species_values <- function(p) {
  s <- p[p$status == "served", , drop = FALSE]
  num <- s$value_type != "text"
  if (anyNA(s$value[num])) stop("a served data point has a value that is not a number: ",
                                s$point_id[num & is.na(s$value)][1], call. = FALSE)
  key <- paste(s$species, s$trait, sep = "\r")
  ## a species and trait with one data point is served as that point (most rows; done at once)
  one <- !(duplicated(key) | duplicated(key, fromLast = TRUE)); a <- s[one, , drop = FALSE]; at <- a$value_type == "text"
  fast <- data.frame(Species = a$species, Dataset = a$dataset, Variable = a$trait,
                     Value = ifelse(at, trimws(a$value_printed), dp_fmt(a$value)),
                     Value_num = ifelse(at, NA_real_, suppressWarnings(as.numeric(dp_fmt(a$value)))),
                     Source = a$item, Items = a$item,
                     Source_details = paste0("1 data point (", a$role, ")", ifelse(nzchar(a$derived), paste0("; derived: ", a$derived), "")),
                     Teams = a$team, N_sources = rep(1L, nrow(a)),
                     Variable_raw = a$trait, Unit = a$unit, Unit_raw = a$unit, stringsAsFactors = FALSE)
  s <- s[!one, , drop = FALSE]; key <- key[!one]
  rows <- lapply(split(s, key), function(x) {
    if (length(unique(x$dataset)) != 1L || length(unique(x$unit)) != 1L || length(unique(x$value_type)) != 1L)
      stop("trait ", x$trait[1], " has more than one dataset, unit or value type in item_columns.csv", call. = FALSE)
    np <- nrow(x); roles <- paste(sort(unique(x$role)), collapse = "; ")
    if (x$value_type[1] == "text") {
      tv <- trimws(x$value_printed); lv <- tolower(gsub("[[:space:]]+", " ", tv))
      words <- tv[!duplicated(lv)]; words <- words[order(tolower(words), method = "radix")]
      k <- length(unique(x$report)); v_chr <- paste(words, collapse = "; "); v_num <- NA_real_
      det <- if (np == 1L) sprintf("1 data point (%s)", roles)
             else sprintf("%d data points in %d report%s%s (%s)%s", np, k, if (k > 1) "s" else "",
                          if (k > 1) paste0(" (", paste(sort(unique(x$report)), collapse = "; "), ")") else "",
                          roles, if (length(words) < 2) "" else if (k > 1) "; the reports differ" else "; the values differ")
    } else {
      rv <- vapply(split(x, x$report), function(r) mean(tapply(r$value, paste(r$item, r$source_row), mean)), numeric(1))
      k <- length(rv); v <- mean(rv); v_chr <- dp_fmt(v); v_num <- suppressWarnings(as.numeric(dp_fmt(v)))
      det <- if (np == 1L) sprintf("1 data point (%s)", roles)
             else sprintf("%d data points in %d report%s%s; range %s to %s (%s)", np, k, if (k > 1) "s" else "",
                          if (k > 1) paste0(" (", paste(sort(names(rv)), collapse = "; "), ")") else "",
                          dp_fmt(min(x$value)), dp_fmt(max(x$value)), roles)
    }
    der <- unique(x$derived[nzchar(x$derived)])
    if (length(der)) det <- paste0(det, "; derived: ", paste(der, collapse = "; "))
    items <- paste(sort(unique(x$item)), collapse = "; ")
    data.frame(Species = x$species[1], Dataset = x$dataset[1], Variable = x$trait[1],
               Value = v_chr, Value_num = v_num, Source = items, Items = items, Source_details = det,
               Teams = paste(sort(unique(x$team)), collapse = "; "), N_sources = k,
               Variable_raw = x$trait[1], Unit = x$unit[1], Unit_raw = x$unit[1], stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, c(list(fast), rows)); rownames(out) <- NULL
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
