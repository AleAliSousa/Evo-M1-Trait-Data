# brain_mass_compiled.R  --  whole-brain mass merge, house twin of
# build_brain_mass_merge.py. Harvest every source table's whole-brain-mass column
# -> resolve species -> grams -> team/role-aware pooling (primary preferred),
# with a dedupe/disagreement report. Python builder is the tested artifact.

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

## ---- repo root: self-locating (Rscript, source(), or RStudio) --------------
## Was: repo <- if (dir.exists("__Public")) "." else ".." -- cwd-dependent, so
## Rscript from any other directory failed on ../__ShinyApp/data/source_manifest.csv.
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
out  <- file.path(repo, "__merging_brain_mass")

norm  <- function(h) tolower(trimws(gsub('"', "", h)))
brain_rx <- "brain.{0,3}(mass|weight|wt)"
EXCLUDE <- c("neonat","fetal","cerebel","cortex","cortic","olfact","rest of brain","diencephal",
             "mesencephal","pons","medulla","hemisphere","white","grey","gray","region",
             "residual","resid","net","ratio","source","ref","note","_sd"," sd",": data","%","index","relative")
FACTOR <- c(g = 1, kg = 1000, mg = 0.001)

read_csv <- function(p) read.csv(p, stringsAsFactors = FALSE, check.names = FALSE)
manifest <- read_csv(file.path(repo, "__ShinyApp", "data", "source_manifest.csv"))
man_by_file <- setNames(seq_len(nrow(manifest)), manifest$file)
xwalk <- read_csv(file.path(repo, "_keys", "team_grouping_crosswalk.csv"))
team_ay <- list()
for (i in seq_len(nrow(xwalk))) {
  m <- regmatches(xwalk[[1]][i], regexec("([A-Za-z]+).*?_((?:19|20)[0-9]{2})", xwalk[[1]][i]))[[1]]
  if (length(m) == 3 && nzchar(xwalk[[2]][i])) team_ay[[paste(tolower(m[2]), m[3])]] <- xwalk[[2]][i]
}
vc <- read_csv(file.path(repo, "_keys", "variable_catalog.csv")); role_ay <- list()
for (i in seq_len(nrow(vc))) {
  if (vc$measure_class[i] != "mass") next
  t <- tolower(paste(vc$Code[i], vc$Definition[i])); if (!grepl("brain", t) || grepl("body", t)) next
  m <- regmatches(vc$paper[i], regexec("([A-Za-z]+).*?((?:19|20)[0-9]{2})", vc$paper[i]))[[1]]
  if (length(m) == 3) { k <- paste(tolower(m[2]), m[3]); if (is.null(role_ay[[k]])) role_ay[[k]] <- vc$role[i] }
}
ref <- read_csv(file.path(repo, "_keys", "species_reference.csv"))$accepted_name
ref_l <- setNames(ref, tolower(ref)); variant <- list()
for (kf in list.files(file.path(repo, "_keys"), "species_key.csv", recursive = TRUE, full.names = TRUE)) {
  k <- read_csv(kf); if (!all(c("variant_name","accepted_name") %in% names(k))) next
  for (i in seq_len(nrow(k))) { v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(variant[[v]])) variant[[v]] <- k$accepted_name[i] }
}
resolve <- function(x) { c <- trimws(gsub("\\s+"," ",gsub("_"," ",gsub("\\*","",x)))); lc <- tolower(c)
  if (!is.na(ref_l[lc])) return(unname(ref_l[lc])); if (!is.null(variant[[lc]])) return(variant[[lc]]); c }

pick_column <- function(headers) {
  cand <- headers[grepl(brain_rx, norm(headers), perl = TRUE)]
  cand <- cand[!vapply(cand, function(h) any(vapply(EXCLUDE, function(e) grepl(e, norm(h), fixed=TRUE), logical(1))), logical(1))]
  cand <- cand[!grepl("^n[ _]", norm(cand)) & !grepl("sample_size", norm(cand))]
  if (!length(cand)) return(NA_character_)
  if (any(grepl("whole", norm(cand)))) cand <- cand[grepl("whole", norm(cand))]
  cand[1]
}
named_unit <- function(colname) { n <- norm(colname)
  if (grepl("kg", n)) return("kg"); if (grepl("\\bmg\\b|\\(mg\\)|_mg", n)) return("mg")
  if (grepl("\\(g\\)|_g$|, g|cm3|\\bg\\b", n)) return("g"); NA_character_ }
binom <- "^[A-Z][a-z]+ [a-z][a-z-]+"
species_getter <- function(headers, sample) {
  val <- function(r,i) if (length(r) >= i) trimws(gsub('"',"",r[i])) else ""
  score <- function(i) { v <- vapply(sample, val, character(1), i=i); v <- v[nzchar(v)]; if(!length(v)) 0 else mean(grepl(binom,v)) }
  sc <- vapply(seq_along(headers), score, numeric(1)); b <- which.max(sc)
  if (length(b) && sc[b] >= 0.5) { i<-b; return(function(r) val(r,i)) }
  g <- which(norm(headers)=="genus"); s <- which(norm(headers) %in% c("species","species epithet"))
  if (length(g) && length(s)) { gi<-g[1]; si<-s[1]; return(function(r) trimws(paste(val(r,gi),val(r,si)))) }
  h <- which(norm(headers) %in% c("species","scientific","scientific name","taxon","binomial","genus species","species name","animal"))
  i <- if (length(h)) h[1] else 1; function(r) val(r,i)
}

# pass 1: locate column + global unit-less max per (author, col)
files <- list.files(pub, "\\.tsv$", full.names = TRUE); targets <- list(); gmax <- list()
for (path in files) {
  fn <- basename(path); lines <- readLines(path, warn = FALSE); if (!length(lines)) next
  rows <- strsplit(lines, "\t", fixed = TRUE); headers <- gsub('"',"",rows[[1]])
  if (!any(grepl(brain_rx, norm(headers), perl = TRUE))) next
  col <- pick_column(headers); if (is.na(col)) next
  ci <- match(col, headers)
  vals <- suppressWarnings(as.numeric(vapply(rows[-1], function(r) if (length(r)>=ci) gsub('"',"",r[ci]) else NA, character(1))))
  vals <- vals[!is.na(vals)]; if (!length(vals)) next
  mi <- man_by_file[[fn]]; author <- if (!is.null(mi)) manifest$first_author[mi] else ""; year <- if (!is.null(mi)) as.character(manifest$year[mi]) else ""
  targets[[length(targets)+1L]] <- list(fn=fn, rows=rows, headers=headers, col=col, ci=ci, author=author, year=year)
  if (is.na(named_unit(col))) { k <- paste(tolower(author), norm(col)); gmax[[k]] <- max(gmax[[k]] %||% 0, max(vals)) }
}

# pass 2: harvest
uf <- list()
for (t in targets) {
  gm <- gmax[[paste(tolower(t$author), norm(t$col))]] %||% 0
  unit <- named_unit(t$col); if (is.na(unit)) unit <- if (gm > 20000) "mg" else "g"
  ay <- paste(tolower(t$author), t$year)
  team <- team_ay[[ay]] %||% (if (nzchar(t$author)) t$author else t$fn)
  role <- role_ay[[ay]] %||% "secondary"
  get_sp <- species_getter(t$headers, t$rows[2:min(length(t$rows),60)])
  for (r in t$rows[-1]) {
    if (length(r) < t$ci) next
    v <- suppressWarnings(as.numeric(gsub('"',"",r[t$ci]))); if (is.na(v)) next
    sp <- resolve(get_sp(r)); if (!nzchar(sp) || tolower(sp) %in% c("na","none")) next
    uf[[length(uf)+1L]] <- data.frame(Species=sp, Measure="Brain_Mass", Units="g",
      Value_g=v*FACTOR[[unit]], raw_value=gsub('"',"",r[t$ci]), raw_unit=unit,
      Source=t$fn, first_author=t$author, Year=t$year, Team=team, role=role, stringsAsFactors=FALSE)
  }
}
uf <- do.call(rbind, uf)

# pool
long <- list(); dedupe <- list()
for (sp in sort(unique(uf$Species))) {
  d <- uf[uf$Species == sp, ]; tv <- tapply(d$Value_g, d$Team, mean)
  trole <- tapply(seq_len(nrow(d)), d$Team, function(ix) if (any(d$role[ix]=="primary")) "primary" else d$role[ix][1])
  prim <- tv[trole[names(tv)] == "primary"]; used <- if (length(prim)) prim else tv
  long[[length(long)+1L]] <- data.frame(Species=sp, measure_class="mass", Measure="Brain_Mass", Units="g",
    Value=round(mean(used),4), Value_median=round(median(used),4), n_sources=nrow(d), n_teams=length(tv),
    n_teams_primary=length(prim), primary_used=length(prim)>0, Teams=paste(sort(names(tv)),collapse="; "),
    roles=paste(sort(unique(d$role)),collapse="; "), value_min=round(min(d$Value_g),4), value_max=round(max(d$Value_g),4), stringsAsFactors=FALSE)
  if (nrow(d) > 1) { spread <- max(d$Value_g)/min(d$Value_g)
    dedupe[[length(dedupe)+1L]] <- data.frame(Species=sp, n_sources=nrow(d), n_teams=length(tv),
      pooled_g=round(mean(used),4), spread_max_over_min=round(spread,2),
      flag=if (is.finite(spread) && spread>2) "DISAGREEMENT>2x" else "",
      per_source=paste(sprintf("%s%s(%s,%s)=%s", d$first_author,d$Year,d$Team,d$role,round(d$Value_g,2)),collapse=" | "), stringsAsFactors=FALSE) }
}
long <- do.call(rbind, long); dedupe <- do.call(rbind, dedupe); dedupe <- dedupe[order(-dedupe$n_sources),]
write.csv(uf,   file.path(out,"brain_mass_unfiltered.csv"), row.names=FALSE)
write.csv(long, file.path(out,"brain_mass_long.csv"), row.names=FALSE)
write.csv(dedupe, file.path(out,"brain_mass_dedupe_report.csv"), row.names=FALSE)
write.csv(data.frame(Species=long$Species, Brain_Mass.g=long$Value), file.path(out,"brain_mass_wide.csv"), row.names=FALSE)
cat("species pooled:", nrow(long), " unfiltered rows:", nrow(uf), "\n")
