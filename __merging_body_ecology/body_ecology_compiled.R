# body_ecology_compiled.R  --  whole-organism (body & ecology) merge, house-style twin
# of build_body_ecology_merge.py. First measure class: BODY MASS.
# Harvest every source table's body-mass column -> resolve species -> grams ->
# team/role-aware pooling (primary preferred), with a dedupe/disagreement report.
# The Python builder is the tested artifact (R was unavailable in the build env);
# this script implements the identical pipeline.

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

## ---- repo root: self-locating (Rscript, source(), or RStudio) --------------
## Was: dirname(sys.frame(1)$ofile) -- errors under Rscript ("not that many
## frames on the stack") and used %||% before it was defined.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (!is.null(of) && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  NA_character_
})
repo <- local({
  d <- if (!is.na(.sp)) dirname(.sp) else normalizePath(getwd())
  while (dirname(d) != d && !dir.exists(file.path(d, "__Public"))) d <- dirname(d)
  if (dir.exists(file.path(d, "__Public"))) d
  else if (dir.exists("__Public")) "." else ".."   # legacy cwd fallback
})
pub  <- file.path(repo, "__Public", "comparative-data")
out  <- file.path(repo, "__merging_body_ecology")

norm  <- function(h) tolower(trimws(gsub('"', "", h)))
body_rx <- "(body.?mass|body.?weight|bodyweight|bo[wm]ass|bow_g|body_?wt)"
EXCLUDE <- c("source","ref","note","_sd"," sd","sem","dimorph","log","raw",
             "spinal","brain","assoc",": data","original")
SKIP <- c("10.1016%2Fj.jhevol.2008.08.004_Table7.tsv")   # body-mass dimorphism (ratio)
FACTOR <- c(g = 1, kg = 1000, mg = 0.001)

# ---- lookups ---------------------------------------------------------------
manifest <- read.csv(file.path(repo, "__ShinyApp", "data", "source_manifest.csv"),
                     stringsAsFactors = FALSE, check.names = FALSE)
xwalk <- read.csv(file.path(repo, "_keys", "team_grouping_crosswalk.csv"),
                  stringsAsFactors = FALSE, check.names = FALSE)
team_ay <- list()
for (i in seq_len(nrow(xwalk))) {
  it <- xwalk[[1]][i]; tm <- xwalk[[2]][i]
  m <- regmatches(it, regexec("([A-Za-z]+).*?_((?:19|20)[0-9]{2})", it))[[1]]
  if (length(m) == 3 && nzchar(tm)) team_ay[[paste(tolower(m[2]), m[3])]] <- tm
}
vc <- read.csv(file.path(repo, "_keys", "variable_catalog.csv"),
               stringsAsFactors = FALSE, check.names = FALSE)
role_ay <- list()
for (i in seq_len(nrow(vc))) {
  if (vc$measure_class[i] != "mass") next
  t <- tolower(paste(vc$Code[i], vc$Definition[i]))
  if (!grepl("body", t) || grepl("brain", t)) next
  m <- regmatches(vc$paper[i], regexec("([A-Za-z]+).*?((?:19|20)[0-9]{2})", vc$paper[i]))[[1]]
  if (length(m) == 3) { k <- paste(tolower(m[2]), m[3]); if (is.null(role_ay[[k]])) role_ay[[k]] <- vc$role[i] }
}
ref <- read.csv(file.path(repo, "_keys", "species_reference.csv"),
                stringsAsFactors = FALSE)$accepted_name
ref_l <- setNames(ref, tolower(ref))
variant <- list()
for (kf in list.files(file.path(repo, "_keys"), pattern = "species_key.csv",
                      recursive = TRUE, full.names = TRUE)) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (all(c("variant_name", "accepted_name") %in% names(k)))
    for (i in seq_len(nrow(k))) {
      v <- tolower(trimws(k$variant_name[i]))
      if (nzchar(v) && is.null(variant[[v]])) variant[[v]] <- k$accepted_name[i]
    }
}
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve  <- function(x) { c <- clean_sp(x); lc <- tolower(c)
  if (!is.na(ref_l[lc])) return(unname(ref_l[lc]))
  if (!is.null(variant[[lc]])) return(variant[[lc]]); c }

# ---- column pickers --------------------------------------------------------
pick_column <- function(headers) {
  cand <- headers[grepl(body_rx, norm(headers), perl = TRUE)]
  cand <- cand[!vapply(cand, function(h) any(vapply(EXCLUDE, function(e) grepl(e, norm(h), fixed = TRUE), logical(1))), logical(1))]
  cand <- cand[!grepl("^n[ _]", norm(cand)) & !grepl("sample_size", norm(cand))]
  if (!length(cand)) return(list(col = NA, unit = NA))
  if (any(grepl("(g)", norm(cand), fixed = TRUE))) cand <- cand[!grepl("(mg)", norm(cand), fixed = TRUE)]
  sp <- cand[grepl("species", norm(cand))]
  pick <- if (length(sp)) sp[1] else { c2 <- cand[!grepl("male|female", norm(cand))]; if (length(c2)) c2[1] else cand[1] }
  n <- norm(pick)
  unit <- if (grepl("kg", n)) "kg" else if (grepl("\\bmg\\b|\\(mg\\)|_mg", n)) "mg" else "g"
  list(col = pick, unit = unit)
}
binom <- "^[A-Z][a-z]+ [a-z][a-z-]+"
species_getter <- function(headers, sample) {          # sample: list of character vectors
  score <- function(i) { v <- vapply(sample, function(r) if (length(r) >= i) trimws(gsub('"', "", r[i])) else "", character(1))
    v <- v[nzchar(v)]; if (!length(v)) 0 else mean(grepl(binom, v)) }
  sc <- vapply(seq_along(headers), score, numeric(1)); best <- which.max(sc)
  if (length(best) && sc[best] >= 0.5) { i <- best; return(function(r) if (length(r) >= i) trimws(gsub('"', "", r[i])) else "") }
  g <- which(norm(headers) == "genus"); s <- which(norm(headers) %in% c("species", "species epithet"))
  if (length(g) && length(s)) { gi <- g[1]; si <- s[1]
    return(function(r) trimws(paste(gsub('"', "", r[gi]), gsub('"', "", r[si])))) }
  h <- which(norm(headers) %in% c("species","scientific","scientific name","taxon","binomial","genus species","species name","animal"))
  i <- if (length(h)) h[1] else 1
  function(r) if (length(r) >= i) trimws(gsub('"', "", r[i])) else ""
}

# ---- harvest ---------------------------------------------------------------
uf <- list()
for (path in list.files(pub, pattern = "\\.tsv$", full.names = TRUE)) {
  fn <- basename(path)
  lines <- readLines(path, warn = FALSE); if (!length(lines)) next
  rows <- strsplit(lines, "\t", fixed = TRUE)
  headers <- gsub('"', "", rows[[1]])
  if (!any(grepl(body_rx, norm(headers), perl = TRUE))) next
  if (fn %in% SKIP) next
  pc <- pick_column(headers); if (is.na(pc$col)) next
  ci <- match(pc$col, headers)
  mi <- match(fn, manifest$file)
  author <- if (!is.na(mi)) manifest$first_author[mi] else ""
  year   <- if (!is.na(mi)) as.character(manifest$year[mi]) else ""
  ay <- paste(tolower(author), year)
  team <- team_ay[[ay]] %||% (if (nzchar(author)) author else fn)
  role <- role_ay[[ay]] %||% "secondary"
  get_sp <- species_getter(headers, rows[2:min(length(rows), 60)])
  for (r in rows[-1]) {
    if (length(r) < ci) next
    raw <- trimws(gsub('"', "", r[ci])); val <- suppressWarnings(as.numeric(raw))
    if (is.na(val)) next
    sp <- resolve(get_sp(r)); if (!nzchar(sp) || tolower(sp) %in% c("na","none")) next
    uf[[length(uf) + 1L]] <- data.frame(Species = sp, Value_g = val * FACTOR[[pc$unit]],
      raw_value = raw, raw_unit = pc$unit, Source = fn, first_author = author,
      Year = year, Team = team, role = role, stringsAsFactors = FALSE)
  }
}
uf <- do.call(rbind, uf)

# ---- pool (team-dedupe -> primary-preferred mean/median) -------------------
long <- list(); dedupe <- list()
for (sp in sort(unique(uf$Species))) {
  d <- uf[uf$Species == sp, ]
  tv <- tapply(d$Value_g, d$Team, mean)
  trole <- tapply(seq_len(nrow(d)), d$Team, function(ix) if (any(d$role[ix] == "primary")) "primary" else d$role[ix][1])
  prim <- tv[trole[names(tv)] == "primary"]
  used <- if (length(prim)) prim else tv
  long[[length(long) + 1L]] <- data.frame(Species = sp, measure_class = "mass",
    Measure = "Body_Mass", Units = "g", Value = round(mean(used), 3),
    Value_median = round(median(used), 3), n_sources = nrow(d), n_teams = length(tv),
    n_teams_primary = length(prim), primary_used = length(prim) > 0,
    Teams = paste(sort(names(tv)), collapse = "; "),
    roles = paste(sort(unique(d$role)), collapse = "; "),
    value_min = round(min(d$Value_g), 3), value_max = round(max(d$Value_g), 3),
    stringsAsFactors = FALSE)
  if (nrow(d) > 1) {
    spread <- max(d$Value_g) / min(d$Value_g)
    dedupe[[length(dedupe) + 1L]] <- data.frame(Species = sp, n_sources = nrow(d),
      n_teams = length(tv), pooled_g = round(mean(used), 3),
      spread_max_over_min = round(spread, 2),
      flag = if (is.finite(spread) && spread > 2) "DISAGREEMENT>2x" else "",
      per_source = paste(sprintf("%s%s(%s,%s)=%d", d$first_author, d$Year, d$Team, d$role,
                                 round(d$Value_g)), collapse = " | "), stringsAsFactors = FALSE)
  }
}
long <- do.call(rbind, long); dedupe <- do.call(rbind, dedupe)
dedupe <- dedupe[order(-dedupe$n_sources), ]

write.csv(uf,   file.path(out, "body_ecology_unfiltered.csv"), row.names = FALSE)
write.csv(long, file.path(out, "body_ecology_long.csv"), row.names = FALSE)
write.csv(dedupe, file.path(out, "body_ecology_dedupe_report.csv"), row.names = FALSE)
write.csv(data.frame(Species = long$Species, Body_Mass.g = long$Value),
          file.path(out, "body_ecology_wide.csv"), row.names = FALSE)
cat("species pooled:", nrow(long), " unfiltered rows:", nrow(uf), "\n")
