# Run from repo root: Rscript _checks/body_ecology_species_parsing.R
# Exercises the actual importer helpers without rebuilding the merge.
library(testthat)
env <- new.env(parent = globalenv())
helpers <- c("norm", "cell", "binom", "check_species_names", "species_col")
for (expr in parse("__merging_body_ecology/body_ecology_compiled.R")) {
  if (is.call(expr) && identical(expr[[1]], as.name("<-")) &&
      is.symbol(expr[[2]]) && as.character(expr[[2]]) %in% helpers) eval(expr, env)
}
test_that("genus assembly distinguishes full names, epithets, and missing names", {
  rows <- list(c("Aotus", "Aotus_azarae"), c("Aotus", "azarae"),
               c("Aotus", "Aotus azarae"), c("Aotus", "NA"),
               c("Bison", "bison"), c("Gorilla", "gorilla_gorilla"))
  f <- env$species_col(c("Genus", "Species"), rows)
  expect_equal(f(rows), c("Aotus_azarae", "Aotus azarae", "Aotus azarae", NA,
                          "Bison bison", "Gorilla gorilla_gorilla"))
  expect_error(env$check_species_names("Aotus Aotus azarae"), "Repeated genus")
  expect_no_error(env$check_species_names(c("Bison bison", "Gorilla gorilla gorilla")))
})
test_that("the Galan-Acedo source's full Species field is retained", {
  path <- "__Public/comparative-data/10.1038%2Fs41597-019-0059-9_BodyMass.tsv"
  rows <- strsplit(readLines(path, warn = FALSE), "\t", fixed = TRUE)
  headers <- rows[[1]]; rows <- rows[-1]
  actual <- env$species_col(headers, head(rows, 59))(rows)
  expected <- env$cell(rows, match("Species", headers))
  expect_identical(actual, expected)
  expect_true("Aotus_azarae" %in% actual)
  expect_no_error(env$check_species_names(gsub("_", " ", actual, fixed = TRUE)))
})
test_that("compiled outputs contain no repeated genus and agree on species labels", {
  long <- read.csv("__merging_body_ecology/body_ecology_long.csv")
  wide <- read.csv("__merging_body_ecology/body_ecology_wide.csv")
  raw <- read.csv("__merging_body_ecology/body_ecology_unfiltered.csv")
  expect_no_error(env$check_species_names(long$Species))
  expect_no_error(env$check_species_names(raw$Species))
  expect_setequal(unique(long$Species), wide$Species)
  expect_setequal(unique(raw$Species), wide$Species)
  expect_equal(long$Species, long$accepted_name)
})
