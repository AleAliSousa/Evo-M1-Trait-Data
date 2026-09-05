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
  # Skip rows with a BLANK accepted_name. HerculanoHouzel/species_key.csv carries several
  # (Cynomys sp., Dasyprocta prymnolopha) awaiting taxonomy review; letting them through blanks
  # the species label and the row is then silently dropped. Falling through to the printed name
  # keeps the datum. See APP_PLAN.md ("skip blank keys in the build, surface on Coverage").
  for (i in seq_len(nrow(k))) { v <- tolower(trimws(k$variant_name[i]))
    acc <- trimws(as.character(k$accepted_name[i]))
    if (nzchar(v) && !is.na(acc) && nzchar(acc) && acc != "NA" && is.null(variant[[v]]))
      variant[[v]] <- acc }
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
  # NA_character_, not NA: a short row (fewer fields than ci) returns the fallback, and a bare NA
  # is logical, which makes vapply(FUN.VALUE = character(1)) abort with
  # "values must be type 'character', but FUN(X[[1]]) result is type 'logical'".
  vals <- suppressWarnings(as.numeric(vapply(rows[-1], function(r) if (length(r)>=ci) gsub('"',"",r[ci]) else NA_character_, character(1))))
  vals <- vals[!is.na(vals)]; if (!length(vals)) next
  mi <- man_by_file[[fn]]; author <- if (!is.null(mi)) manifest$first_author[mi] else ""; year <- if (!is.null(mi)) as.character(manifest$year[mi]) else ""
  targets[[length(targets)+1L]] <- list(fn=fn, rows=rows, headers=headers, col=col, ci=ci, author=author, year=year)
  if (is.na(named_unit(col))) { k <- paste(tolower(author), norm(col)); gmax[[k]] <- max(gmax[[k]] %||% 0, max(vals)) }
}

# ---- measurement basis, from _keys/brain_size_basis.csv ---------------------
# Values are pooled only with values of the same basis: the sources are not all reporting the
# same quantity (weighed mass, mass excluding the olfactory bulbs, a compilation mixing masses
# with volumes converted at 1 cm3 = 1 g, a sum of sub-structures, a mass back-calculated from a
# volume or an endocranial volume). The build STOPS if a harvested row has no basis on record.
basis_key <- read.csv(file.path(repo, "_keys", "brain_size_basis.csv"),
                      stringsAsFactors = FALSE, check.names = FALSE)
FAMILY <- c(mass_measured           = "Brain_Mass_measured",
            mass_measured_specimen  = "Brain_Mass_measured",
            mass_measured_excl_ob   = "Brain_Mass_excl_olfactory_bulb",
            mass_or_volume_mixed    = "Brain_Mass_mass_or_volume",
            sum_of_parts_incl_ob    = "Brain_size_sum_of_structures",
            mass_from_volume_or_ecv = "Brain_Mass_from_volume_or_ecv")
grp_of <- function(paper, col) {
  i <- which(basis_key$paper == paper & basis_key$column == col)
  if (length(i)) basis_key$poolable_group[i[1]] else NA_character_
}
# the finer basis (mass_fresh / mass_fixed / mass_compilation_unspecified / ...). `poolable_group`
# says what may be pooled; `basis` says what the source actually reported, and both are carried.
basis_of <- function(paper, col) {
  i <- which(basis_key$paper == paper & basis_key$column == col)
  if (length(i)) basis_key$basis[i[1]] else NA_character_
}

# Round half away from zero at `d` decimals, IDENTICALLY to the .py: base R rounds the shortest
# printed decimal while Python rounds the stored double, so they disagree where a value sits on a
# tie. Format at d+6 dp with C printf (same libc in both), then round with exact integer arithmetic.
round_n <- function(x, d) vapply(x, function(v) {
  if (is.na(v)) return(NA_real_)
  s <- sprintf(paste0("%.", d + 6L, "f"), v)
  neg <- startsWith(s, "-"); s <- sub("^-", "", s)
  q <- strsplit(s, ".", fixed = TRUE)[[1]]
  n <- as.numeric(q[1]) * 10^(d + 6L) + as.numeric(q[2])
  r <- floor((n + 5 * 10^5) / 10^6) / 10^d
  if (neg) -r else r
}, numeric(1))
# Resolve (author, year) to a repo folder. Several authors have two folders for the same year
# (HerculanoHouzel__2015 vs HerculanoHouzel_etal_2015), so prefer the one that carries the column.
folders <- basename(list.dirs(repo, recursive = FALSE))
folders <- folders[!grepl("^[._]", folders)]
folder_of <- function(author, year, col) {
  h <- folders[startsWith(tolower(folders), tolower(author)) & grepl(year, folders, fixed = TRUE)]
  if (length(h) > 1) { k <- h[!is.na(vapply(h, grp_of, character(1), col = col))]
                       if (length(k)) return(k[1]) }
  if (length(h)) h[1] else ""
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
  paper <- folder_of(t$author, t$year, t$col)
  grp   <- grp_of(paper, t$col)
  if (is.na(grp))
    stop(sprintf("no measurement basis on record for %s / %s (paper folder '%s'). Add it to ASSIGN in _keys/build_brain_size_basis.py and re-run that builder.",
                 t$fn, t$col, paper), call. = FALSE)
  meas  <- FAMILY[[grp]]
  basis <- basis_of(paper, t$col)
  for (r in t$rows[-1]) {
    if (length(r) < t$ci) next
    v <- suppressWarnings(as.numeric(gsub('"',"",r[t$ci]))); if (is.na(v)) next
    sp <- resolve(get_sp(r)); if (!nzchar(sp) || tolower(sp) %in% c("na","none")) next
    uf[[length(uf)+1L]] <- data.frame(Species=sp, Measure="Brain_Mass", Units="g",
      # 10 significant digits: the mg->g conversion leaves float noise (3550 * 0.001 =
      # 3.5500000000000003) that R and Python would then write out differently.
      Value_g=as.numeric(sprintf("%.10g", v*FACTOR[[unit]])), raw_value=gsub('"',"",r[t$ci]), raw_unit=unit,
      Source=t$fn, first_author=t$author, Year=t$year, Team=team, role=role,
      paper=paper, column=t$col, poolable_group=grp, basis=basis, measure_emitted=meas,
      stringsAsFactors=FALSE)
  }
}
uf <- do.call(rbind, uf)

# pool -- WITHIN basis only, never across
long <- list(); dedupe <- list()
for (key in sort(unique(paste(uf$Species, uf$measure_emitted, sep = "\r")))) {
  parts <- strsplit(key, "\r", fixed = TRUE)[[1]]; sp <- parts[1]; meas <- parts[2]
  d <- uf[uf$Species == sp & uf$measure_emitted == meas, ]; tv <- tapply(d$Value_g, d$Team, mean)
  trole <- tapply(seq_len(nrow(d)), d$Team, function(ix) if (any(d$role[ix]=="primary")) "primary" else d$role[ix][1])
  prim <- tv[trole[names(tv)] == "primary"]; used <- if (length(prim)) prim else tv
  long[[length(long)+1L]] <- data.frame(Species=sp, measure_class="mass", Measure=meas, Units="g",
    Value=round_n(mean(used),4), Value_median=round_n(median(used),4), n_sources=nrow(d), n_teams=length(tv),
    n_teams_primary=length(prim), primary_used=length(prim)>0, Teams=paste(sort(names(tv), method="radix"),collapse="; "),
    roles=paste(sort(unique(d$role), method="radix"),collapse="; "),
    basis=paste(sort(unique(d$basis), method="radix"),collapse="; "),
    value_min=round_n(min(d$Value_g),4), value_max=round_n(max(d$Value_g),4), stringsAsFactors=FALSE)
  if (nrow(d) > 1) { spread <- max(d$Value_g)/min(d$Value_g)
    dedupe[[length(dedupe)+1L]] <- data.frame(Species=sp, Measure=meas, n_sources=nrow(d), n_teams=length(tv),
      pooled_g=round_n(mean(used),4), spread_max_over_min=round_n(spread,2),
      flag=if (is.finite(spread) && spread>2) "DISAGREEMENT>2x" else "",
      per_source=paste(sprintf("%s%s(%s,%s)=%.2f", d$first_author,d$Year,d$Team,d$role,d$Value_g),collapse=" | "), stringsAsFactors=FALSE) }
}
long <- do.call(rbind, long); dedupe <- do.call(rbind, dedupe); dedupe <- dedupe[order(-dedupe$n_sources),]
long <- long[order(long$Species, long$Measure), ]

# Cross-basis comparison: the one thing the split makes unreadable from the long table alone.
# One row per species carrying more than one basis, so a reader can see how far the bases
# disagree for the same animal without any of it having been pooled.
meas_order <- sort(unique(unname(FAMILY)))
cross <- list()
for (sp in sort(unique(long$Species))) {
  d <- long[long$Species == sp, ]
  if (nrow(d) < 2) next
  v <- setNames(as.list(rep("", length(meas_order))), meas_order)
  v[d$Measure] <- as.list(d$Value)
  sprd <- max(d$Value) / min(d$Value)
  cross[[length(cross)+1L]] <- data.frame(Species=sp, n_bases=nrow(d), as.data.frame(v, check.names=FALSE),
    ratio_max_over_min=round_n(sprd,3),
    flag=if (is.finite(sprd) && sprd > 2) "DISAGREEMENT>2x" else "", stringsAsFactors=FALSE)
}
cross <- do.call(rbind, cross)

write.csv(uf,   file.path(out,"brain_mass_unfiltered.csv"), row.names=FALSE)
write.csv(long, file.path(out,"brain_mass_long.csv"), row.names=FALSE)
write.csv(dedupe, file.path(out,"brain_mass_dedupe_report.csv"), row.names=FALSE)
write.csv(cross, file.path(out,"brain_size_basis_comparison.csv"), row.names=FALSE)
# wide: one column per basis, because they are different quantities
wide <- data.frame(Species=sort(unique(long$Species)), stringsAsFactors=FALSE)
for (m in meas_order) {
  ix <- match(wide$Species, long$Species[long$Measure == m])
  wide[[paste0(m, ".g")]] <- long$Value[long$Measure == m][ix]
}
write.csv(wide, file.path(out,"brain_mass_wide.csv"), row.names=FALSE, na="")
cat("pooled cells:", nrow(long), " species:", length(unique(long$Species)),
    " unfiltered rows:", nrow(uf), "\n")
for (m in meas_order) cat(sprintf("  %-32s %5d species\n", m, sum(long$Measure == m)))
