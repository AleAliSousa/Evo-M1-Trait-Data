#!/usr/bin/env Rscript
# =============================================================================
# compare_pgls_across_trees.R -- does the choice of tree product change a result?
#
# Fits ONE model, log10(brain mass) ~ log10(body mass) with Pagel's lambda, on
# every tree product this folder builds, so the three ways of widening coverage
# can be judged by what they do to an answer and not argued in the abstract:
#
#   A  _keys/mammal_tree.nwk                 sequenced species only
#   B  _keys/mammal_trees_sample100.nwk      Upham et al.'s completed trees (their
#                                            imputation), 100 trees
#   C  _keys/mammal_tree_augmented.nwk       A + locally added branches
#      _keys/mammal_trees_augmented100.nwk   100 randomised versions of C
#
# and, for each of B and C, again with the non-sequenced tips dropped, and on the
# species the two have in common. The provenance tables say which tips those are.
#
# Data: one value per species from the merges, as the app serves them --
#   __merging_brain_mass/brain_mass_long.csv    Measure "Brain mass (measured or
#                                               estimated from volume)"
#   __merging_body_ecology/body_ecology_long.csv  Measure "Body_Mass"
# with _keys/species_display_aliases.csv applied, exactly as app.R does.
#
# Fitting uses phylolm::phylolm(model = "lambda"), which gives the same estimates
# as the app's nlme::gls + ape::corPagel (checked 2026-11: slope, lambda and
# log-likelihood agree to 5 decimals on tree A) in a fraction of a second, where
# gls needs ~30 s per fit at 1,600 species.
#
#   OUTPUT  __merging_trees/pgls_method_comparison.csv            one row per variant
#           __merging_trees/pgls_method_comparison_per_tree.csv   one row per fit
#
# To compare on another pair of variables, change the two `pick()` calls.
#
# Run from repo root, after the three tree builds:
#   Rscript __merging_trees/compare_pgls_across_trees.R
# Requires: ape, phylolm (CRAN).
# =============================================================================

suppressWarnings(suppressMessages({library(ape); library(phylolm)}))
.here <- local({
  a <- commandArgs(FALSE); f <- sub("^--file=", "", a[grep("^--file=", a)])
  if (length(f)) dirname(normalizePath(f)) else "__merging_trees"
})
source(file.path(.here, "resolve_tips.R"))
P <- evom1_paths()
out_file <- function(dir, name) {            # prefer a freshly built file
  f <- file.path(P$out, dir, name); if (file.exists(f)) f else file.path(P$repo, dir, name)
}

alias <- read_chr_csv(file.path(P$repo, "_keys", "species_display_aliases.csv"))
unalias <- function(sp) { m <- setNames(trimws(alias$canonical), trimws(alias$variant))
  hit <- m[sp]; ifelse(is.na(hit), sp, unname(hit)) }
pick <- function(file, measure) {
  x <- read.csv(file.path(P$repo, file), stringsAsFactors = FALSE, check.names = FALSE)
  x <- x[x$Measure == measure, c("Species", "Value")]
  x$Species <- unalias(trimws(gsub("[[:space:]_]+", " ", x$Species)))
  x$Value <- suppressWarnings(as.numeric(x$Value))
  x <- x[is.finite(x$Value) & x$Value > 0, ]
  aggregate(Value ~ Species, x, median)
}
y <- pick("__merging_brain_mass/brain_mass_long.csv", "Brain mass (measured or estimated from volume)")
x <- pick("__merging_body_ecology/body_ecology_long.csv", "Body_Mass")
d <- merge(setNames(y, c("Species", "y")), setNames(x, c("Species", "x")))
d$ly <- log10(d$y); d$lx <- log10(d$x); d$tip <- gsub(" ", "_", d$Species)
rownames(d) <- d$tip

A    <- read.tree(out_file("_keys", "mammal_tree.nwk"))
B    <- read.tree(out_file("_keys", "mammal_trees_sample100.nwk"))
Cdet <- read.tree(out_file("_keys", "mammal_tree_augmented.nwk"))
Crnd <- read.tree(out_file("_keys", "mammal_trees_augmented100.nwk"))

seq_tips <- intersect(d$tip, A$tip.label)
B_tips   <- intersect(d$tip, B[[1]]$tip.label)
C_tips   <- intersect(d$tip, Cdet$tip.label)
both     <- intersect(B_tips, C_tips)

fit <- function(tr, tips) {
  tr <- keep.tip(tr, tips); dd <- d[tr$tip.label, ]
  f <- phylolm(ly ~ lx, data = dd, phy = tr, model = "lambda", lower.bound = 0, upper.bound = 1)
  s <- summary(f)$coefficients
  c(n = length(tips), slope = unname(s["lx", "Estimate"]), se = unname(s["lx", "StdErr"]),
    intercept = unname(s["(Intercept)", "Estimate"]), lambda = unname(f$optpar))
}
many <- function(trs, tips) t(vapply(trs, function(t) fit(t, tips), numeric(5)))

specs <- list(
  list("A: DNA-only, sequenced species",                list(A), seq_tips),
  list("B: Upham completed trees, all tips",            B,       B_tips),
  list("B: Upham completed trees, sequenced tips only", B,       seq_tips),
  list("C: added branches, deterministic, all tips",    list(Cdet), C_tips),
  list("C: added branches, randomised, all tips",       Crnd,    C_tips),
  list("B: species in both B and C",                    B,       both),
  list("C: deterministic, species in both B and C",     list(Cdet), both),
  list("C: randomised, species in both B and C",        Crnd,    both))
res <- lapply(specs, function(s) many(s[[2]], s[[3]]))
names(res) <- vapply(specs, function(s) s[[1]], character(1))

summ <- do.call(rbind, lapply(seq_along(specs), function(i) { m <- res[[i]]
  data.frame(variant = specs[[i]][[1]], n_trees = nrow(m), n_species = m[1, "n"],
             n_not_sequenced = length(setdiff(specs[[i]][[3]], seq_tips)),
             slope_median = median(m[, "slope"]), slope_min = min(m[, "slope"]),
             slope_max = max(m[, "slope"]), slope_se_median = median(m[, "se"]),
             lambda_median = median(m[, "lambda"]), lambda_min = min(m[, "lambda"]),
             lambda_max = max(m[, "lambda"]), intercept_median = median(m[, "intercept"]),
             stringsAsFactors = FALSE) }))
ols <- lm(ly ~ lx, data = d[seq_tips, ])
summ <- rbind(summ, data.frame(
  variant = "OLS, sequenced species (no phylogeny)", n_trees = NA, n_species = nobs(ols),
  n_not_sequenced = 0, slope_median = unname(coef(ols)[2]), slope_min = NA, slope_max = NA,
  slope_se_median = summary(ols)$coefficients[2, 2], lambda_median = NA, lambda_min = NA,
  lambda_max = NA, intercept_median = unname(coef(ols)[1]), stringsAsFactors = FALSE))
rownames(summ) <- NULL

per_tree <- do.call(rbind, lapply(names(res), function(k)
  data.frame(variant = k, tree = seq_len(nrow(res[[k]])), res[[k]], row.names = NULL)))

write.csv(summ, file.path(P$out, "__merging_trees", "pgls_method_comparison.csv"), row.names = FALSE)
write.csv(per_tree, file.path(P$out, "__merging_trees", "pgls_method_comparison_per_tree.csv"),
          row.names = FALSE)
print(format(summ[, c("variant", "n_trees", "n_species", "n_not_sequenced", "slope_median",
                      "slope_min", "slope_max", "slope_se_median", "lambda_median")], digits = 4),
      row.names = FALSE)
