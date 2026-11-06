#!/usr/bin/env Rscript
## =============================================================================
## cell_counts_histology_compiled.R
##
## Compiles the comparative HISTOLOGY cell-count dataset: densities, totals and
## ratios of cells counted in tissue sections, one row per printed statistic, LONG
## (species x region x layer x cell class x marker x measure x statistic).
##
## Counting method decides the merge (owner decision, 4 Nov 2026; review RV-2026-005):
##   * this merge            - cells counted in sections: design-based stereology first;
##                             model-based profile counts are kept but off by default
##   * the isotropic-fractionator merge (__merging_cell_counts_isotropic_fractionator) - homogenate counts
## Values are never pooled across methods here. Every app label carries its method
## tag ("[stereology]"), so the app cannot average a stereology density with anything
## else. Pooling, where an expert-reviewed rule allows it, belongs to a separate opt-in
## product (_keys/cell_count_methods/pooling_rules.csv, rule PR00).
##
## WHAT COMES IN is decided by _keys/cell_count_methods/source_methods.csv, not here.
## Each row with target_merge == "cell_counts_histology" names an item, an R filter on
## that item's public TSV (blank = the rows no more specific row of the same item
## claims), the counting method and the treatment:
##   include, include_flagged, include_own_label -> loaded, merge_default TRUE
##   off_by_default                              -> loaded, merge_default FALSE
##   not_merged, exclude, queued, route_elsewhere -> not loaded
## A routed item is compiled once it also has a term map in
## standardized_term_by_reference/. Routed items without one are listed in
## cell_counts_histology_qa_pending.csv - the to-do list for this merge.
##
## Inputs : __ReadMe.xlsx (Item encoded, DOI, Team), __Public/comparative-data/*.tsv,
##          _keys/cell_count_methods/source_methods.csv and methods.csv,
##          standardized_term_by_reference/*_standardized_terms.csv, measures.csv,
##          cell_classes.csv, regions.csv, region_crosswalk.csv, method_tags.csv,
##          value_flags.csv, _keys/resolve_species.R
## Outputs: cell_counts_histology_long.csv              the dataset (read by the app)
##          cell_counts_histology_label_definitions.csv definitions of the app labels
##          cell_counts_histology_coverage.csv          species x quantity x sources
##          cell_counts_histology_qa_pending.csv        routed here, no term map yet
##          cell_counts_histology_qa_routing.csv        TSV rows per item and treatment
##          cell_counts_histology_qa_overlaps.csv       same quantity from >1 source
##          cell_counts_histology_qa_species.csv        species the resolver left unresolved
##          _keys/variable_domain.csv rows for dataset "Cell counts (histology)"
##          (replaced on every run; every other row is left byte for byte)
##
## Run:  Rscript __merging_cell_counts_histology/cell_counts_histology_compiled.R
## then  Rscript _keys/build_variable_definitions.R  and  Update_ShinyApp.
##
## Written 2026-11-04 by an AI assistant (Microsoft Copilot) for Alexandra de Sousa.
## R NOT RUN when written: the first outputs came from a Python mirror of this script;
## run it and compare (see README__merging.md).
## =============================================================================
suppressPackageStartupMessages({ library(readr); library(readxl) })
if (!isTRUE(l10n_info()[["UTF-8"]])) try(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"), silent = TRUE)

## ---- 0. where am I -----------------------------------------------------------------------
ME <- "cell_counts_histology_compiled.R"
here <- local({
  f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(f) && basename(sub("^--file=", "", f[1])) == ME)
    return(dirname(normalizePath(sub("^--file=", "", f[1]))))
  for (k in rev(seq_along(sys.frames()))) {            # source()d, e.g. from RStudio
    of <- tryCatch(sys.frames()[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == ME && file.exists(of))
      return(dirname(normalizePath(of)))
  }
  if (file.exists(file.path(getwd(), ME))) return(normalizePath(getwd()))
  normalizePath(file.path(getwd(), "__merging_cell_counts_histology"), mustWork = TRUE)
})
base <- normalizePath(file.path(here, ".."))
if (!dir.exists(file.path(base, "_keys"))) stop("repository root not found above ", here, call. = FALSE)
tsvdir  <- file.path(base, "__Public", "comparative-data")
TARGET  <- "cell_counts_histology"
DATASET <- "Cell counts (histology)"
ROLES   <- c("Species", "species_printed", "row_key", "statistic", "n", "region_printed",
             "measure_printed", "value_printed", "unit_printed", "specimen_id", "hemisphere",
             "sex", "age", "note", "DROP")
STATS   <- c("mean", "sd", "se", "median", "min", "max", "value")
LOADED  <- c(include = TRUE, include_flagged = TRUE, include_own_label = TRUE, off_by_default = FALSE)
SKIPPED <- c("not_merged", "exclude", "queued", "route_elsewhere")

## ---- 1. helpers and inputs ---------------------------------------------------------------
txt <- function(x) { x <- as.character(x); x[is.na(x)] <- ""; trimws(x) }
rd  <- function(p) {
  if (!file.exists(p)) stop("missing input: ", p, call. = FALSE)
  x <- read.csv(p, colClasses = "character", na.strings = character(0), check.names = FALSE,
                encoding = "UTF-8", stringsAsFactors = FALSE)
  x[] <- lapply(x, txt)
  x
}
need <- function(df, cols, what) {
  miss <- setdiff(cols, names(df))
  if (length(miss)) stop(what, " lacks column(s): ", paste(miss, collapse = ", "), call. = FALSE)
}
fail_rows <- function(bad, what) if (length(bad))
  stop(what, " (term-map rows ", paste(bad, collapse = ", "), ")", call. = FALSE)
rkey <- function(region, layer) paste(region, layer, sep = "\r")
## an R filter from a key file, evaluated on the TSV's columns (all read as text)
eval_filter <- function(d, expr, what) {
  hit <- tryCatch(eval(parse(text = expr), envir = d, enclos = baseenv()),
                  error = function(e) stop(what, ": filter `", expr, "` failed: ",
                                           conditionMessage(e), call. = FALSE))
  hit <- as.logical(hit)
  if (length(hit) == 1L) hit <- rep(hit, nrow(d))
  if (length(hit) != nrow(d))
    stop(what, ": filter `", expr, "` must give one TRUE/FALSE per TSV row", call. = FALSE)
  hit[is.na(hit)] <- FALSE
  hit
}
## character NA -> written as an empty field; "" would otherwise be written as a quoted ""
blank_to_na <- function(df) {
  chr <- vapply(df, is.character, TRUE)
  df[chr] <- lapply(df[chr], function(v) { v[!is.na(v) & !nzchar(v)] <- NA_character_; v })
  df
}
put_csv <- function(df, name) readr::write_csv(blank_to_na(df), file.path(here, name), na = "")
sort_by <- function(df, cols) {
  if (!nrow(df)) return(df)
  df <- df[do.call(order, c(unname(as.list(df[cols])), method = "radix")), , drop = FALSE]
  rownames(df) <- NULL
  df
}

mk   <- file.path(base, "_keys", "cell_count_methods")
sm   <- rd(file.path(mk, "source_methods.csv"))
mth  <- rd(file.path(mk, "methods.csv"))
meas <- rd(file.path(here, "measures.csv"))
cls  <- rd(file.path(here, "cell_classes.csv"))
rgn  <- rd(file.path(here, "regions.csv"))
rxw  <- rd(file.path(here, "region_crosswalk.csv"))
tags <- rd(file.path(here, "method_tags.csv"))
vfl  <- rd(file.path(here, "value_flags.csv"))
tm_files <- sort(list.files(file.path(here, "standardized_term_by_reference"),
                            pattern = "_standardized_terms\\.csv$", full.names = TRUE), method = "radix")
if (!length(tm_files)) stop("no term maps in standardized_term_by_reference/", call. = FALSE)
tm_all <- do.call(rbind, lapply(tm_files, rd))

need(sm,   c("item_name", "filter", "method_id", "target_merge", "treatment", "data_role", "flag",
             "status", "review_id"), "_keys/cell_count_methods/source_methods.csv")
need(mth,  c("method_id", "family", "method_label"), "_keys/cell_count_methods/methods.csv")
need(meas, c("measure", "label_suffix", "unit", "definition_template"), "measures.csv")
need(cls,  c("cell_class", "cells_phrase"), "cell_classes.csv")
need(rgn,  c("region", "layer", "layer_code", "Structure", "structure_qualifier", "definition"), "regions.csv")
need(rxw,  c("Reference", "region_printed", "region", "layer"), "region_crosswalk.csv")
need(tags, c("family", "method_tag", "slug"), "method_tags.csv")
need(vfl,  c("source", "filter", "flag_type", "note"), "value_flags.csv")
need(tm_all, c("Reference", "term_type", "Original_Term", "Standardized_Term", "statistic", "cell_class",
               "marker", "region", "layer", "unit", "note"), "term maps")

## vocabulary checks on the term maps (a typo stops here, not in the app)
st <- tm_all$Standardized_Term
is_col <- tm_all$term_type == "column"
is_val <- tm_all$term_type == "row_value" | (is_col & st %in% meas$measure)
fail_rows(which(!tm_all$term_type %in% c("column", "row_value")), "term_type must be column or row_value")
fail_rows(which(is_col & !st %in% c(ROLES, meas$measure)), "column Standardized_Term is not a role or a measure in measures.csv")
fail_rows(which(!is_col & !st %in% meas$measure), "row_value Standardized_Term is not a measure in measures.csv")
fail_rows(which(is_col & (st == "statistic" | st %in% meas$measure) & !tm_all$statistic %in% STATS),
          paste0("statistic must be one of ", paste(STATS, collapse = ", ")))
fail_rows(which(is_val & !tm_all$cell_class %in% cls$cell_class), "cell_class not in cell_classes.csv")
fail_rows(which(is_val & tm_all$unit != meas$unit[match(st, meas$measure)]), "unit differs from the measure's unit in measures.csv")
fail_rows(which(is_val & nzchar(tm_all$region) & !rkey(tm_all$region, tm_all$layer) %in% rkey(rgn$region, rgn$layer)),
          "region/layer pair not in regions.csv")
if (nrow(rxw) && !all(rkey(rxw$region, rxw$layer) %in% rkey(rgn$region, rgn$layer)))
  stop("region_crosswalk.csv maps to a region/layer pair that is not in regions.csv", call. = FALSE)
bad <- setdiff(unique(sm$treatment[sm$target_merge == TARGET]), c(names(LOADED), SKIPPED))
if (length(bad)) stop("unknown treatment(s) in source_methods.csv: ", paste(bad, collapse = ", "), call. = FALSE)

## registry: the public TSV of an item, its DOI and team
reg <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
reg_val <- function(item, col) if (!col %in% names(reg)) "" else
  txt(reg[[col]][match(item, txt(reg[["Item name"]]))])
tsv_of <- function(item) {
  e <- reg_val(item, "Item encoded")
  if (!nzchar(e)) stop(item, ": no 'Item encoded' in __ReadMe.xlsx", call. = FALSE)
  if (grepl("\\s", e)) stop(item, ": 'Item encoded' contains a space ('", e, "'); fix column A of __ReadMe.xlsx",
                            call. = FALSE)
  f <- file.path(tsvdir, paste0(e, ".tsv"))
  if (!file.exists(f)) stop(item, ": public TSV not on disk -> ", f, call. = FALSE)
  f
}

## ---- 2. one item -> long rows --------------------------------------------------------------
compile_item <- function(item) {
  d  <- as.data.frame(readr::read_tsv(tsv_of(item), col_types = readr::cols(.default = "c"),
                                      na = c("", "NA"), progress = FALSE), stringsAsFactors = FALSE)
  nr <- nrow(d)
  rows_sm <- sm[sm$item_name == item, , drop = FALSE]

  ## which source_methods row claims each TSV row: specific filters first; one blank
  ## filter per item takes whatever the specific ones left
  who <- rep(NA_integer_, nr)
  for (k in which(nzchar(rows_sm$filter))) {
    hit <- eval_filter(d, rows_sm$filter[k], paste0(item, " (source_methods.csv)"))
    if (any(hit & !is.na(who)))
      stop(item, ": ", sum(hit & !is.na(who)), " TSV row(s) match more than one filter in source_methods.csv",
           call. = FALSE)
    who[hit] <- k
  }
  blank <- which(!nzchar(rows_sm$filter))
  if (length(blank) > 1L) stop(item, ": more than one source_methods.csv row with a blank filter", call. = FALSE)
  if (length(blank) == 1L) who[is.na(who)] <- blank
  claimed <- !is.na(who)
  f_of <- function(col) { v <- rep("", nr); v[claimed] <- rows_sm[[col]][who[claimed]]; v }
  tgt <- f_of("target_merge"); trt <- f_of("treatment"); mid <- f_of("method_id")
  routing <- unique(data.frame(item_name = item, method_id = mid, target_merge = tgt, treatment = trt,
                               stringsAsFactors = FALSE))
  routing$tsv_rows <- vapply(seq_len(nrow(routing)), function(i)
    sum(mid == routing$method_id[i] & tgt == routing$target_merge[i] & trt == routing$treatment[i]), 0L)
  ld <- which(tgt == TARGET & trt %in% names(LOADED))
  if (!length(ld)) { message(item, ": no TSV rows routed to this merge"); return(list(long = NULL, routing = routing)) }

  ## term map: every TSV column must be named, even if only to DROP it
  tm   <- tm_all[tm_all$Reference == item, , drop = FALSE]
  tcol <- tm[tm$term_type == "column", , drop = FALSE]
  miss <- setdiff(names(d), tcol$Original_Term)
  if (length(miss)) stop(item, ": TSV column(s) without a term-map row: ", paste(miss, collapse = ", "), call. = FALSE)
  gone <- setdiff(tcol$Original_Term, names(d))
  if (length(gone)) stop(item, ": term-map column(s) not in the TSV: ", paste(gone, collapse = ", "), call. = FALSE)
  col_of <- function(role) tcol$Original_Term[tcol$Standardized_Term == role]
  one <- function(role) {
    o <- col_of(role)
    if (length(o) > 1L) stop(item, ": more than one TSV column mapped to ", role, call. = FALSE)
    if (length(o)) txt(d[[o]]) else rep("", nr)
  }
  key <- data.frame(Species_col = one("Species"), species_printed = one("species_printed"),
                    region_printed = one("region_printed"), measure_printed = one("measure_printed"),
                    value_printed = one("value_printed"), unit_printed = one("unit_printed"),
                    specimen_id = one("specimen_id"), hemisphere = one("hemisphere"),
                    sex = one("sex"), age = one("age"), n = one("n"), stringsAsFactors = FALSE)
  n_basis <- if (length(col_of("n"))) tcol$unit[tcol$Standardized_Term == "n"][1] else ""
  nc <- col_of("note")
  key$source_note <- if (!length(nc)) rep("", nr) else vapply(seq_len(nr), function(i) {
    v <- txt(unlist(d[i, nc, drop = TRUE], use.names = FALSE)); k <- nzchar(v)
    paste(paste0(nc[k], "=", v[k]), collapse = "; ")
  }, "")

  ## value-level curation flags (source values are kept; a discrepancy is noted, never balanced)
  vnote <- rep("", nr)
  vf <- vfl[vfl$source == item, , drop = FALSE]
  for (k in seq_len(nrow(vf))) {
    hit <- eval_filter(d, vf$filter[k], paste0(item, " (value_flags.csv)"))
    if (!any(hit)) stop(item, ": a value_flags.csv filter matches no TSV row: ", vf$filter[k], call. = FALSE)
    add <- paste0(vf$flag_type[k], ": ", vf$note[k])
    vnote[hit] <- ifelse(nzchar(vnote[hit]), paste(vnote[hit], add, sep = " | "), add)
  }

  ## values. Long-shaped table: a row_key column names each row's measure (row_value terms)
  ## and statistic columns hold the numbers. Wide table: each measure column holds one
  ## statistic of one measure.
  rk <- col_of("row_key")
  if (length(rk) > 1L) stop(item, ": more than one column mapped to row_key", call. = FALSE)
  if (length(rk) == 1L) {
    tv <- tm[tm$term_type == "row_value", , drop = FALSE]
    kv <- txt(d[[rk]])
    unm <- unique(kv[ld][!kv[ld] %in% tv$Original_Term])
    if (length(unm)) stop(item, ": rows routed here whose ", rk, " has no row_value term: ",
                          paste(unm, collapse = ", "), call. = FALSE)
    sc <- tcol[tcol$Standardized_Term == "statistic", , drop = FALSE]
    if (!nrow(sc)) stop(item, ": a table with a row_key needs a column mapped to statistic", call. = FALSE)
    m <- tv[match(kv[ld], tv$Original_Term), , drop = FALSE]
    vals <- do.call(rbind, lapply(seq_len(nrow(sc)), function(j) data.frame(
      .row = ld, statistic = sc$statistic[j], value_text = txt(d[[sc$Original_Term[j]]][ld]),
      measure = m$Standardized_Term, cell_class = m$cell_class, marker = m$marker, region = m$region,
      layer = m$layer, unit = m$unit, term_note = m$note, stringsAsFactors = FALSE)))
  } else {
    vc <- tcol[tcol$Standardized_Term %in% meas$measure, , drop = FALSE]
    if (!nrow(vc)) stop(item, ": the term map has neither a row_key nor measure columns", call. = FALSE)
    vals <- do.call(rbind, lapply(seq_len(nrow(vc)), function(j) data.frame(
      .row = ld, statistic = vc$statistic[j], value_text = txt(d[[vc$Original_Term[j]]][ld]),
      measure = vc$Standardized_Term[j], cell_class = vc$cell_class[j], marker = vc$marker[j],
      region = vc$region[j], layer = vc$layer[j], unit = vc$unit[j], term_note = vc$note[j],
      stringsAsFactors = FALSE)))
  }
  vals <- vals[nzchar(vals$value_text), , drop = FALSE]
  if (!nrow(vals)) return(list(long = NULL, routing = routing))

  ## region not fixed by the term map: printed region through region_crosswalk.csv
  nb <- which(!nzchar(vals$region))
  if (length(nb)) {
    xw <- rxw[rxw$Reference == item, , drop = FALSE]
    rp <- key$region_printed[vals$.row[nb]]
    j  <- match(rp, xw$region_printed)
    if (anyNA(j)) stop(item, ": region not set in the term map and not in region_crosswalk.csv: ",
                       paste(unique(rp[is.na(j)]), collapse = ", "), call. = FALSE)
    vals$region[nb] <- xw$region[j]; vals$layer[nb] <- xw$layer[j]
  }

  r <- vals$.row; s <- who[r]
  out <- data.frame(
    source = item, doi = reg_val(item, "DOI (or Alt)"), team = reg_val(item, "Team"),
    Species_col = key$Species_col[r], species_printed = key$species_printed[r],
    observation_level = if (length(col_of("specimen_id"))) "individual" else "species summary",
    specimen_id = key$specimen_id[r], region = vals$region, region_printed = key$region_printed[r],
    layer = vals$layer, cell_class = vals$cell_class, marker = vals$marker, measure = vals$measure,
    measure_printed = key$measure_printed[r], statistic = vals$statistic, value_text = vals$value_text,
    value_printed = key$value_printed[r], unit = vals$unit, unit_printed = key$unit_printed[r],
    n = key$n[r], n_basis = n_basis,
    hemisphere = ifelse(nzchar(key$hemisphere[r]), key$hemisphere[r], "not reported"),
    sex = key$sex[r], age = key$age[r],
    method_id = rows_sm$method_id[s], treatment = rows_sm$treatment[s],
    classification_status = rows_sm$status[s], review_id = rows_sm$review_id[s],
    method_flag = rows_sm$flag[s], data_role = rows_sm$data_role[s],
    source_note = key$source_note[r], term_note = vals$term_note, curation_note = vnote[r],
    stringsAsFactors = FALSE)
  list(long = out, routing = routing)
}

## ---- 3. compile every routed + mapped item ---------------------------------------------------
routed <- unique(sm$item_name[sm$target_merge == TARGET & sm$treatment %in% names(LOADED)])
mapped <- unique(tm_all$Reference)
skip   <- setdiff(mapped, routed)
if (length(skip)) message("term map(s) for items no longer routed here (skipped): ", paste(skip, collapse = ", "))
todo   <- sort(intersect(routed, mapped), method = "radix")
res    <- lapply(todo, compile_item)
long   <- do.call(rbind, lapply(res, `[[`, "long"))
routing <- do.call(rbind, lapply(res, `[[`, "routing"))
if (is.null(long) || !nrow(long)) stop("nothing compiled", call. = FALSE)

## numbers stay as printed (thousands separators removed); nothing is converted or rounded
long$value <- gsub(",", "", long$value_text, fixed = TRUE)
bad <- is.na(suppressWarnings(as.numeric(long$value)))
if (any(bad)) stop("non-numeric value(s): ", paste(unique(paste0(long$source[bad], " '", long$value_text[bad], "'")),
                                                   collapse = "; "), call. = FALSE)

## method fields, from the method key
mi <- match(long$method_id, mth$method_id)
if (anyNA(mi)) stop("method_id not in methods.csv: ", paste(unique(long$method_id[is.na(mi)]), collapse = ", "), call. = FALSE)
long$method_family <- mth$family[mi]
long$method_label  <- mth$method_label[mi]
ti <- match(long$method_family, tags$family)
if (anyNA(ti)) stop("method family without a row in method_tags.csv: ",
                    paste(unique(long$method_family[is.na(ti)]), collapse = ", "), call. = FALSE)
long$method_tag    <- tags$method_tag[ti]
long$merge_default <- unname(LOADED[long$treatment])

## app label: <region>_<layer code>_<cell class>[_<marker>]_<measure> [<method tag>]
ri <- match(rkey(long$region, long$layer), rkey(rgn$region, rgn$layer))
if (anyNA(ri)) stop("region/layer pair(s) not in regions.csv: ",
                    paste(unique(paste(long$region, long$layer)[is.na(ri)]), collapse = ", "), call. = FALSE)
long$Structure <- rgn$Structure[ri]
lc <- rgn$layer_code[ri]
sx <- meas$label_suffix[match(long$measure, meas$measure)]
long$variable_label <- paste0(long$region, ifelse(nzchar(lc), paste0("_", lc), ""), "_", long$cell_class,
                              ifelse(nzchar(long$marker), paste0("_", long$marker), ""), "_", sx,
                              " [", long$method_tag, "]")

## species: the house resolver, keyed by paper folder
source(file.path(base, "_keys", "resolve_species.R"))
printed <- ifelse(nzchar(long$species_printed), long$species_printed, long$Species_col)
rs <- resolve_species(printed, source_publication = paper_folder_of_item(long$source, base))
long$accepted_name <- rs$accepted_name
long$species_basis <- rs$species_basis
long$reidentified  <- rs$reidentified
long$Species       <- ifelse(rs$unresolved & nzchar(long$Species_col), long$Species_col, rs$accepted_name)
long$taxon_level   <- ifelse(grepl(" sp\\.?$", long$Species) | !grepl(" ", long$Species, fixed = TRUE),
                             "genus", "species")

## ---- 4. outputs ------------------------------------------------------------------------------
cols <- c("source", "doi", "team", "Species", "species_printed", "taxon_level", "observation_level",
          "specimen_id", "region", "region_printed", "layer", "Structure", "cell_class", "marker",
          "measure", "measure_printed", "statistic", "value", "value_text", "value_printed", "unit",
          "unit_printed", "n", "n_basis", "hemisphere", "sex", "age", "method_id", "method_family",
          "method_label", "method_tag", "variable_label", "treatment", "merge_default",
          "classification_status", "review_id", "method_flag", "data_role", "source_note", "term_note",
          "curation_note", "accepted_name", "species_basis", "reidentified")
long <- sort_by(long, c("source", "Species", "region", "layer", "cell_class", "marker", "measure", "statistic"))[, cols]
put_csv(long, "cell_counts_histology_long.csv")

## coverage: which quantities exist for which species, from how many sources (app-visible rows)
central <- long[long$merge_default & long$statistic %in% c("mean", "value"), , drop = FALSE]
cov_keys <- c("Species", "taxon_level", "region", "layer", "Structure", "cell_class", "marker", "measure",
              "unit", "method_tag")
gk <- if (nrow(central)) do.call(paste, c(unname(as.list(central[cov_keys])), sep = "\r")) else character(0)
ug <- unique(gk)
coverage <- if (!length(ug)) {
  cbind(central[0, cov_keys], data.frame(n_sources = integer(0), sources = character(0), n_values = integer(0)))
} else do.call(rbind, lapply(ug, function(g) {
  s <- central[gk == g, , drop = FALSE]
  src <- sort(unique(s$source), method = "radix")
  cbind(s[1, cov_keys, drop = FALSE],
        data.frame(n_sources = length(src), sources = paste(src, collapse = " | "), n_values = nrow(s),
                   stringsAsFactors = FALSE))
}))
coverage <- sort_by(coverage, c("measure", "cell_class", "marker", "region", "layer", "method_tag", "Species"))
put_csv(coverage, "cell_counts_histology_coverage.csv")

## QA (a): routed here but no term map yet - the to-do list
pend <- sm[sm$target_merge == TARGET & sm$treatment %in% names(LOADED) & !sm$item_name %in% mapped,
           c("item_name", "filter", "method_id", "treatment", "status", "flag"), drop = FALSE]
pend$item_encoded <- vapply(pend$item_name, function(i) reg_val(i, "Item encoded"), "", USE.NAMES = FALSE)
pend$public_tsv_on_disk <- nzchar(pend$item_encoded) &
  file.exists(file.path(tsvdir, paste0(pend$item_encoded, ".tsv")))
put_csv(sort_by(pend, c("item_name", "method_id")), "cell_counts_histology_qa_pending.csv")
## QA (b): how each compiled item's TSV rows were routed (all targets, so nothing goes missing)
routing$target_merge[!nzchar(routing$method_id)] <- "(no source_methods.csv row)"
put_csv(sort_by(routing[, c("item_name", "target_merge", "treatment", "method_id", "tsv_rows")],
                c("item_name", "target_merge", "treatment", "method_id")), "cell_counts_histology_qa_routing.csv")
## QA (c): the same quantity for the same species from more than one source
multi <- ug[vapply(ug, function(g) length(unique(central$source[gk == g])) > 1L, TRUE)]
qa_overlap <- central[gk %in% multi, c(cov_keys, "source", "team", "method_id", "value", "n", "data_role"), drop = FALSE]
put_csv(sort_by(qa_overlap, c("measure", "cell_class", "marker", "region", "layer", "Species", "source")),
        "cell_counts_histology_qa_overlaps.csv")
## QA (d): species the resolver could not place
qa_sp <- unique(long[long$species_basis == "unresolved", c("source", "species_printed", "Species"), drop = FALSE])
put_csv(sort_by(qa_sp, c("source", "species_printed")), "cell_counts_histology_qa_species.csv")

## ---- 5. label definitions and the variable_domain rows -------------------------------------------
app <- long[long$merge_default & long$statistic %in% c("mean", "estimate", "value", "category") &
              long$taxon_level == "species", , drop = FALSE]
app$Measure <- paste0(app$cell_class, ifelse(nzchar(app$marker), paste0("_", app$marker), ""), "_", app$measure)
app$slug    <- tags$slug[match(app$method_family, tags$family)]
labs <- sort(unique(app$variable_label), method = "radix")
def_cols <- c("label", "Code", "Definition", "Structure", "Measure", "Unit", "Stat", "role", "taxon",
              "Reference", "measure_class", "structure_qualifier", "poolable_group", "poolable_family")
no_defs <- as.data.frame(setNames(rep(list(character(0)), length(def_cols)), def_cols), stringsAsFactors = FALSE)
defs <- do.call(rbind, c(list(no_defs), lapply(labs, function(L) {
  s <- app[app$variable_label == L, , drop = FALSE]; f <- s[1, ]
  if (length(unique(s$unit)) > 1L) stop("label ", L, " carries more than one unit", call. = FALSE)
  cells <- cls$cells_phrase[match(f$cell_class, cls$cell_class)]
  if (nzchar(f$marker)) cells <- paste0(f$marker, "-immunoreactive ", cells)
  ri    <- match(rkey(f$region, f$layer), rkey(rgn$region, rgn$layer))
  notes <- unique(s$term_note[nzchar(s$term_note)])
  srcs  <- sort(unique(s$source), method = "radix")
  defn  <- paste0(gsub("{cells}", cells, meas$definition_template[match(f$measure, meas$measure)], fixed = TRUE),
                  ". ", rgn$definition[ri], ". Counting method: ",
                  paste(sort(unique(s$method_label), method = "radix"), collapse = "; "), ".",
                  if (length(notes)) paste0(" Note: ", paste(notes, collapse = " | "), ".") else "")
  data.frame(label = paste0(L, " (", f$unit, ")"), Code = L, Definition = defn, Structure = f$Structure,
             Measure = f$Measure, Unit = f$unit,
             Stat = paste(sort(unique(s$statistic), method = "radix"), collapse = "; "),
             role = paste(sort(unique(s$data_role), method = "radix"), collapse = "; "),
             taxon = paste(sort(unique(s$Species), method = "radix"), collapse = "; "),
             Reference = paste(srcs, collapse = "; "),
             measure_class = paste0(f$cell_class, "_", f$measure),
             structure_qualifier = rgn$structure_qualifier[ri],
             poolable_group = paste0(f$Measure, "__", f$slug), poolable_family = f$Measure,
             stringsAsFactors = FALSE)
})))
ld_out <- data.frame(Code = defs$Code, Definition = defs$Definition, Structure = defs$Structure,
                     Measure = defs$Measure, Stat = defs$Stat, role = defs$role, taxon = defs$taxon,
                     Reference = defs$Reference, Note = "",
                     "Source Note" = paste0("composed by cell_counts_histology_compiled.R from measures.csv, ",
                                            "cell_classes.csv, regions.csv and _keys/cell_count_methods/methods.csv"),
                     stringsAsFactors = FALSE, check.names = FALSE)
put_csv(ld_out, "cell_counts_histology_label_definitions.csv")

vd_path <- file.path(base, "_keys", "variable_domain.csv")
raw <- readLines(vd_path, encoding = "UTF-8", warn = FALSE)
eol <- if (any(grepl("\r$", raw))) "\r\n" else "\n"
raw <- sub("\r$", "", raw)
while (length(raw) > 1L && !nzchar(raw[length(raw)])) raw <- raw[-length(raw)]
vd <- read.csv(text = paste(raw, collapse = "\n"), colClasses = "character", na.strings = character(0),
               check.names = FALSE, encoding = "UTF-8", stringsAsFactors = FALSE)
if (nrow(vd) != length(raw) - 1L)
  stop("_keys/variable_domain.csv has a record spread over several lines; update its '", DATASET,
       "' rows by hand", call. = FALSE)
clash <- intersect(defs$label, vd$label[vd$dataset != DATASET])
if (length(clash)) stop("label(s) already in variable_domain.csv under another dataset: ",
                        paste(clash, collapse = ", "), call. = FALSE)
add <- data.frame(label = defs$label, dataset = DATASET, domain = "cellular composition",
                  measure_class = defs$measure_class, Structure = defs$Structure,
                  canonical_structure = defs$Structure, Measure = defs$Measure, Unit = defs$Unit,
                  structure_qualifier = defs$structure_qualifier,
                  structure_source = "__merging_cell_counts_histology/regions.csv", is_measurement = "TRUE",
                  note = paste0(defs$Definition, " Source: ", defs$Reference, "."),
                  poolable_group = defs$poolable_group, poolable_family = defs$poolable_family,
                  stringsAsFactors = FALSE)
for (col in setdiff(names(vd), names(add))) add[[col]] <- ""
add <- blank_to_na(add[, names(vd)])
new_lines <- strsplit(readr::format_csv(add, col_names = FALSE, na = ""), "\n", fixed = TRUE)[[1]]
keep <- c(TRUE, vd$dataset != DATASET)
con <- file(vd_path, open = "wb")
writeLines(c(raw[keep], new_lines), con, sep = eol, useBytes = TRUE)
close(con)

message("cell_counts_histology: ", nrow(long), " rows from ", length(unique(long$source)), " item(s); ",
        length(unique(long$Species)), " species; ", length(labs), " app label(s) (dataset '", DATASET, "'); ",
        nrow(pend), " routed item row(s) still without a term map (cell_counts_histology_qa_pending.csv); ",
        length(multi), " overlap group(s); ", nrow(qa_sp), " unresolved species. variable_domain.csv: ",
        sum(!keep), " old row(s) replaced by ", length(new_lines), ". Next: Rscript _keys/build_variable_definitions.R")
