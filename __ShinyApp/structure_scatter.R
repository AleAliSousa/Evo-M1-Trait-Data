# Within-species structure comparisons. Join only exact normalized structures;
# do not map a subregion onto its parent or manufacture pairs across sources.
structure_pairs <- function(rows, species, xkey, ykey, xseries = character(), yseries = character()) {
  profile <- function(key, selection) {
    p <- sr_profile(rows, species, key)
    if (!nrow(p)) return(p)
    p$Series <- paste(p$Variable, p$Dataset, sep = " @ ")
    if (length(selection)) p <- p[p$Series %in% selection, , drop = FALSE]
    p$Join <- gsub("[^a-z0-9]", "", tolower(p$Structure))
    p$Join[p$Join == "brain"] <- "wholebrain"
    p
  }
  x <- profile(xkey, xseries); y <- profile(ykey, yseries)
  empty <- function(ambiguous = 0L, unmatched = 0L) list(data = data.frame(), ambiguous = ambiguous, unmatched = unmatched)
  if (!nrow(x) || !nrow(y)) return(empty())
  key <- function(p) paste(p$Species, p$Join, sep = "\r")
  kx <- key(x); ky <- key(y)
  repeated <- function(k) unique(k[duplicated(k) | duplicated(k, fromLast = TRUE)])
  ambiguous <- union(repeated(kx), repeated(ky))
  unmatched <- length(setdiff(union(kx, ky), intersect(kx, ky)))
  x <- x[!kx %in% ambiguous, , drop = FALSE]
  y <- y[!ky %in% ambiguous, , drop = FALSE]
  cols <- c("Species", "Join", "Structure", "Variable", "Dataset", "Value", "Unit", "Sources")
  d <- merge(x[cols], y[cols], by = c("Species", "Join"), suffixes = c("_X", "_Y"))
  d$Structure <- d$Structure_X
  d$Join <- d$Structure_X <- d$Structure_Y <- NULL
  list(data = d, ambiguous = length(ambiguous), unmatched = unmatched)
}

structure_plot_data <- function(d, logscale) {
  if (!nrow(d)) return(d)
  keep <- is.finite(d$Value_X) & is.finite(d$Value_Y)
  if (isTRUE(logscale)) keep <- keep & d$Value_X > 0 & d$Value_Y > 0
  d <- d[keep, , drop = FALSE]
  d$X <- if (isTRUE(logscale)) log10(d$Value_X) else d$Value_X
  d$Y <- if (isTRUE(logscale)) log10(d$Value_Y) else d$Value_Y
  d
}

structure_fit_stats <- function(d) {
  if (!nrow(d)) return(data.frame())
  do.call(rbind, lapply(split(d, d$Species), function(p) {
    ok <- nrow(p) >= 3L && length(unique(p$X)) > 1L && length(unique(p$Y)) > 1L
    f <- if (ok) stats::lm(Y ~ X, p) else NULL
    tt <- if (ok) summary(f)$coefficients else NULL
    data.frame(Species = p$Species[1], Structures = nrow(p),
      Slope = if (ok) unname(coef(f)[2]) else NA_real_,
      Intercept = if (ok) unname(coef(f)[1]) else NA_real_,
      SE = if (ok) tt[2, 2] else NA_real_, p = if (ok) tt[2, 4] else NA_real_,
      R_squared = if (ok) summary(f)$r.squared else NA_real_,
      Status = if (ok) "OLS within species" else "Need at least 3 structures and variation on both axes")
  }))
}
