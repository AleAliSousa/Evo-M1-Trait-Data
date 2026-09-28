## _keys/resolve_species.R -- the single species-identity resolver (SPECIES_NAMING.md v1, sec. 3c)
##
## Every merge does:   source(file.path(<repo>, "_keys/resolve_species.R"))
##                     r <- resolve_species(printed, source_publication = <paper folder name>)
## and gets a data.frame aligned to `printed` with
##   accepted_name   the identity anchor (a row of _keys/species_reference.csv), or the cleaned
##                   printed string when nothing matched (unresolved = TRUE)
##   species_basis   the spoke row's `basis` (verbatim | spelling | synonym:<authority> | reident |
##                   subspecies_assign | lump | split | hypothesis | our_judgment |
##                   unspecified_in_source), or 'hub' when only the hub matched, or 'unresolved'
##   reidentified    TRUE iff species_basis == 'reident' (sec. 7c-track)
##   match_level     'paper' (source_publication + variant_name) | 'variant' (variant_name only, unique
##                   across papers) | 'ambiguous' (variant_name only, >1 accepted_name across papers ->
##                   NOT applied; falls through to hub) | 'hub' | 'unresolved'
##   unresolved      logical
##
## Identity only (v1): no taxonomy argument. Base R + readr/dplyr; no network. All spokes
## `_keys/*/species_key.csv` (unified schema: variant_name, accepted_name, source_publication,
## collection, ncbi_taxid, basis, note) are bound once and cached in an environment.
## Normalisation before matching: trim, collapse whitespace (incl. NBSP), strip '*', '_' -> ' ',
## case-insensitive. Match order: (source_publication, variant_name) -> variant_name only (if unique)
## -> hub accepted_name -> cleaned printed string with unresolved = TRUE.

.resolve_species_env <- new.env(parent = emptyenv())

.rs_keys_dir <- function() {
  # the folder this file lives in (works under source(), Rscript, sys.source()); detected once while
  # this file is being source()d (the source() frame is only on the stack at that moment) and cached.
  if (!is.null(.resolve_species_env$keys_dir_default)) return(.resolve_species_env$keys_dir_default)
  d <- NA_character_
  for (fr in rev(sys.frames())) {                    # the source() frame carries `ofile`
    of <- tryCatch(get0("ofile", envir = fr, inherits = FALSE), error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && nzchar(of) &&
        file.exists(file.path(dirname(of), "species_reference.csv"))) { d <- dirname(normalizePath(of)); break }
  }
  if (is.na(d) || !file.exists(file.path(d, "species_reference.csv"))) {
    a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    start <- if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else normalizePath(getwd())
    p <- start
    while (dirname(p) != p && !file.exists(file.path(p, "_keys", "species_reference.csv"))) p <- dirname(p)
    if (file.exists(file.path(p, "_keys", "species_reference.csv"))) d <- file.path(p, "_keys")
  }
  if (is.na(d)) stop("resolve_species: cannot locate _keys/ (species_reference.csv) from ", getwd(), call. = FALSE)
  d
}
.resolve_species_env$keys_dir_default <- .rs_keys_dir()   # capture now, while source()'s frame is live

species_normalise <- function(x) {
  x <- as.character(x)
  # Declare the bytes UTF-8 (all repo TSVs/keys are UTF-8) so that strings read under a C locale
  # ("unknown" encoding) and readr-read keys (UTF-8) compare equal; invalid bytes become <xx>.
  x <- iconv(x, "UTF-8", "UTF-8", sub = "byte")
  x <- gsub(intToUtf8(0xa0), " ", x, fixed = TRUE)   # NBSP -> space
  x <- gsub("*", "", x, fixed = TRUE)
  x <- gsub("_", " ", x, fixed = TRUE)
  x <- gsub("[[:space:]]+", " ", x)
  trimws(x)
}
.rs_key <- function(x) tolower(species_normalise(x))

.rs_load <- function(keys_dir = .rs_keys_dir()) {
  e <- .resolve_species_env
  if (!is.null(e$variants) && identical(e$keys_dir, keys_dir)) return(invisible(e))
  files <- sort(list.files(keys_dir, pattern = "^species_key\\.csv$", recursive = TRUE, full.names = TRUE))
  files <- files[basename(dirname(files)) != "specimen_crosswalk"]
  need <- c("variant_name", "accepted_name", "source_publication", "collection", "basis")
  tabs <- lapply(files, function(f) {
    k <- readr::read_csv(f, col_types = readr::cols(.default = readr::col_character()),
                         show_col_types = FALSE, progress = FALSE, na = c("", "NA"))
    miss <- setdiff(need, names(k))
    if (length(miss)) stop("resolve_species: spoke ", f, " lacks column(s): ", paste(miss, collapse = ", "),
                           " (unified schema required, see _keys/SPECIES_NAMING.md sec. 3b)", call. = FALSE)
    k$spoke_file <- f
    k
  })
  v <- dplyr::bind_rows(tabs)
  v <- v[!is.na(v$variant_name) & nzchar(trimws(v$variant_name)) &
         !is.na(v$accepted_name) & nzchar(trimws(v$accepted_name)), , drop = FALSE]
  v$accepted_name <- trimws(v$accepted_name)
  v$variant_key <- .rs_key(v$variant_name)
  v$pub_key     <- .rs_key(v$source_publication)
  v$basis[is.na(v$basis) | !nzchar(v$basis)] <- "unspecified_in_source"
  dup <- duplicated(v[, c("pub_key", "variant_key")])
  if (any(dup)) {
    d <- v[dup, c("source_publication", "variant_name", "spoke_file")]
    warning("resolve_species: ", sum(dup), " duplicate (source_publication, variant_name) spoke row(s) ",
            "ignored (first wins), e.g. ", d$source_publication[1], " / ", d$variant_name[1], call. = FALSE)
    v <- v[!dup, , drop = FALSE]
  }
  # variant-only view: one accepted_name -> usable; several -> ambiguous (R4)
  vo <- dplyr::summarise(dplyr::group_by(v, variant_key),
                         n_accepted = dplyr::n_distinct(accepted_name),
                         accepted_name = accepted_name[1], basis = basis[1], .groups = "drop")
  hub <- readr::read_csv(file.path(keys_dir, "species_reference.csv"),
                         col_types = readr::cols(.default = readr::col_character()),
                         show_col_types = FALSE, progress = FALSE, na = c("", "NA"))
  hub <- hub[!is.na(hub$accepted_name) & nzchar(hub$accepted_name), , drop = FALSE]
  hub_key <- .rs_key(hub$accepted_name)
  e$variants <- v; e$variant_only <- vo; e$hub <- hub; e$hub_key <- hub_key; e$keys_dir <- keys_dir
  e$pair_key <- paste(v$pub_key, v$variant_key, sep = "\r")
  invisible(e)
}

#' Audit view of the bound spoke table (all _keys/*/species_key.csv rows, with normalised keys).
species_variant_table <- function(keys_dir = .rs_keys_dir()) {
  e <- .rs_load(keys_dir)
  as.data.frame(e$variants, stringsAsFactors = FALSE)
}

#' Resolve printed species names to the identity anchor.
#' @param printed character vector of names as printed in the source table
#' @param source_publication NULL, a single paper folder name, or a vector aligned to `printed`
#' @return data.frame aligned to `printed`: accepted_name, species_basis, reidentified, match_level, unresolved
resolve_species <- function(printed, source_publication = NULL, keys_dir = .rs_keys_dir()) {
  e <- .rs_load(keys_dir)
  n <- length(printed)
  cleaned <- species_normalise(printed)
  vkey <- tolower(cleaned)
  if (is.null(source_publication)) source_publication <- rep(NA_character_, n)
  if (length(source_publication) == 1L && n != 1L) source_publication <- rep(source_publication, n)
  if (length(source_publication) != n)
    stop("resolve_species: source_publication must be NULL, length 1, or length(printed)", call. = FALSE)
  pkey <- .rs_key(source_publication)
  out <- data.frame(accepted_name = cleaned, species_basis = "unresolved", reidentified = FALSE,
                    match_level = "unresolved", unresolved = TRUE, stringsAsFactors = FALSE)
  ok <- !is.na(printed) & nzchar(cleaned)
  # 1. (source_publication, variant_name)
  i <- match(paste(pkey, vkey, sep = "\r"), e$pair_key)
  hit <- ok & !is.na(pkey) & !is.na(i)
  out$accepted_name[hit] <- e$variants$accepted_name[i[hit]]
  out$species_basis[hit] <- e$variants$basis[i[hit]]
  out$match_level[hit]   <- "paper"
  # 2. variant_name only (unique across papers); ambiguous -> flagged, not applied
  j <- match(vkey, e$variant_only$variant_key)
  cand <- ok & !hit & !is.na(j)
  uniq <- cand & e$variant_only$n_accepted[j] == 1L
  out$accepted_name[uniq] <- e$variant_only$accepted_name[j[uniq]]
  out$species_basis[uniq] <- e$variant_only$basis[j[uniq]]
  out$match_level[uniq]   <- "variant"
  amb <- cand & !uniq
  out$match_level[amb] <- "ambiguous"
  hit <- hit | uniq
  # 3. hub accepted_name
  h <- match(vkey, e$hub_key)
  hh <- ok & !hit & !is.na(h)
  out$accepted_name[hh] <- e$hub$accepted_name[h[hh]]
  out$species_basis[hh] <- "hub"
  out$match_level[hh]   <- ifelse(out$match_level[hh] == "ambiguous", "hub", "hub")
  hit <- hit | hh
  # 4. fall back to the cleaned printed string (already in place)
  out$unresolved <- !hit
  out$reidentified <- out$species_basis == "reident"
  rownames(out) <- NULL
  out
}

#' Item name (registry "Item name", e.g. Stephan_etal_1981_TableI) -> paper folder name
#' (Stephan_etal_1981). Uses the repo's top-level folders (longest matching prefix); falls back to
#' stripping the trailing _<Table> token when no folder matches. Vectorised; NA in -> NA out.
paper_folder_of_item <- function(item, repo = dirname(.rs_keys_dir())) {
  e <- .resolve_species_env
  if (is.null(e$folders) || !identical(e$repo, repo)) {
    f <- basename(list.dirs(repo, recursive = FALSE))
    f <- f[!grepl("^[._]", f)]
    e$folders <- enc2utf8(f); e$repo <- repo
  }
  item <- enc2utf8(as.character(item))
  u <- unique(item[!is.na(item)])
  m <- vapply(u, function(it) {
    h <- e$folders[e$folders == it | startsWith(it, paste0(e$folders, "_"))]
    if (length(h)) h[which.max(nchar(h))] else sub("_[^_]*$", "", it)
  }, character(1), USE.NAMES = FALSE)
  m[match(item, u)]
}

#' Collapse per-row species columns onto an aggregated (e.g. species x variable) table.
#' `rows` must carry `species_printed`, `accepted_name`, `species_basis`, `reidentified` plus the
#' grouping columns in `by`. Returns one row per group with the distinct printed names and bases
#' "; "-joined, accepted_name (must be single per group) and reidentified = any().
species_columns_summary <- function(rows, by) {
  g <- dplyr::group_by(rows, dplyr::across(dplyr::all_of(by)))
  dplyr::summarise(g,
    species_printed = paste(sort(unique(species_printed)), collapse = "; "),
    accepted_name   = { a <- unique(accepted_name); if (length(a) == 1L) a else paste(sort(a), collapse = "; ") },
    species_basis   = paste(sort(unique(species_basis)), collapse = "; "),
    reidentified    = any(reidentified, na.rm = TRUE), .groups = "drop")
}

## ---- self-test (RESOLVE_SPECIES_SELFTEST=1 Rscript _keys/resolve_species.R) ----------------------
if (identical(Sys.getenv("RESOLVE_SPECIES_SELFTEST"), "1")) {
  cases <- list(
    # collection, printed, source_publication, expected accepted_name
    c("Stephan", "Alouatta spp.", "Baron_etal_1983", "Alouatta seniculus"),
    c("Stephan", "Gorilla gorilla", "Stephan_etal_1981", "Gorilla sp."),
    c("Stephan", "Avahi lan. occidentalis", "Frahm_etal_1984", "Avahi occidentalis"),
    c("Allman", "Ateles sp.", "Bush_Allman_2004_b", "Ateles geoffroyi"),
    c("Allman", "Callicebus sp.", "Bush_Allman_2004_a", "Callicebus sp."),
    c("Allman", "Ailurus fulgens", "Bush_Allman_2003", "Ailurus fulgens"),
    c("HerculanoHouzel", "Cynomys sp.", "HerculanoHouzel_etal_2015", "Cynomys sp."),
    c("HerculanoHouzel", "Amblysomus hottentotus", "HerculanoHouzel_etal_2015", "Amblysomus hottentotus"),
    c("HerculanoHouzel", "Homo sapiens sapiens", "Kazu_etal_2014", "Homo sapiens"),
    c("Ashwell", "Aotus trivirgata", "Ashwell__2020", "Aotus trivirgatus"),
    c("Ashwell", "Macropus agilis", "Ashwell__2020", "Notamacropus agilis"),
    c("Ashwell", "Acrobates pygmaeus", "Ashwell__2020", "Acrobates pygmaeus"),
    c("Hof", "Bowhead whale", "Raghanti_etal_2015", "Balaena mysticetus"),
    c("Hof", "Aotus trivirgatus", "Nimchinsky_etal_1999", "Aotus trivirgatus"),
    c("Hof", "Cebus apella", "Raghanti_etal_2015", "Cebus apella"),
    c("Lyamin", "Beluga", "Lyamin_etal_2008", "Delphinapterus leucas"),
    c("Lyamin", "Commerson's dolphin", "Lyamin_etal_2008", "Cephalorhynchus commersonii"),
    c("Lyamin", "Beluga", NA, "Delphinapterus leucas"),
    c("Sato", "Mus musculus", "Taniguchi_etal_2022", "Mus musculus"),
    c("Sato", "MUS MUSCULUS", "Taniguchi_etal_2022", "Mus musculus"),
    c("Sato", " Mus_musculus* ", "Taniguchi_etal_2022", "Mus musculus"),
    c("General", "Homo s.", "Armstrong__1979", "Homo sapiens"),
    c("General", "AMH", "Balzeau_etal_2012", "Homo sapiens"),
    c("General", "Neanderthal", "Kochiyama_etal_2018", "Homo neanderthalensis"),
    c("General", "Zaphod beeblebrox", "Nowhere__2099", "Zaphod beeblebrox")   # unresolved fallback
  )
  m <- do.call(rbind, cases)
  pub <- m[, 3]; pub[pub == "NA"] <- NA
  r <- resolve_species(m[, 2], pub)
  res <- data.frame(collection = m[, 1], printed = m[, 2], source_publication = m[, 3],
                    expected = m[, 4], got = r$accepted_name, basis = r$species_basis,
                    match_level = r$match_level, reidentified = r$reidentified, unresolved = r$unresolved,
                    pass = r$accepted_name == m[, 4], stringsAsFactors = FALSE)
  print(res, right = FALSE, row.names = FALSE)
  vt <- species_variant_table()
  cat(sprintf("\nspoke rows bound: %d | collections: %s | hub rows: %d\n", nrow(vt),
              paste(sort(unique(vt$collection)), collapse = ", "), nrow(.resolve_species_env$hub)))
  cat(sprintf("checks: %d/%d passed; unresolved fallback flagged: %s; reident flagged: %s\n",
              sum(res$pass), nrow(res), res$unresolved[nrow(res)], any(res$reidentified)))
  pf <- paper_folder_of_item(c("Stephan_etal_1981_TableI", "Bush_Allman_2004_a_Table2",
                               "Ashwell__2020_SupplementaryTable", "DosSantos_etal_2020_unpublished", NA))
  cat("paper_folder_of_item:", paste(pf, collapse = " | "), "\n")
  stopifnot(all(res$pass), res$unresolved[nrow(res)], any(res$reidentified),
            all(vt$accepted_name %in% .resolve_species_env$hub$accepted_name),
            identical(pf, c("Stephan_etal_1981", "Bush_Allman_2004_a", "Ashwell__2020", "DosSantos_etal_2020", NA)))
  cat("SELFTEST OK\n")
}
