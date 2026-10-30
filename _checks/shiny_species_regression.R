# Run from the repo root: Rscript _checks/shiny_species_regression.R
# Uses local canonical data only; does not rebuild or change any data files.
library(testthat)
Sys.setenv(EVOM1_SOURCE = "local")
repo <- normalizePath(getwd())
setwd(file.path(repo, "__ShinyApp"))
app <- new.env(parent = globalenv())
lines <- readLines("app.R")
eval(parse(text = lines[seq_len(grep("^shinyApp\\(", lines) - 1L)]), app)

test_that("taxonomy fallback is explicit and never resolves conflicting genera", {
  tx <- data.frame(Species = c("A one", "B one", "B two"), Order = c("First", "First", "Second"))
  x <- app$build_species_index(c("A one", "A two", "B three", "C one"), tx)
  expect_equal(x$Order, c("First", "First", "Unknown", "Unknown"))
  expect_match(x$Order_basis[2], "Inferred")
})

test_that("coverage counts zeros and categories, not blank values or duplicates", {
  a <- "Body_Mass (g)"
  b <- "Activity_pattern (category)"
  expect_true(all(c(a, b) %in% app$meas_labels))
  d <- data.frame(Species = c("A one", "A one", "B two", "B two", "C three", "C three"),
                  Variable = c(a, a, a, b, a, b), Value = c("0", "0", "", "Diurnal", NA, " "))
  t <- app$trait_coverage(d, c("A one", "B two", "C three"))
  expect_equal(t$Species_with_data, c(1L, 1L))
  expect_equal(t$Selected_species, c(3L, 3L))
  expect_equal(nrow(app$trait_coverage(d, c("A one", "B two"), shared = TRUE)), 0L)
  m <- app$trait_value_matrix(d, c("A one", "B two"), c(a, b))
  expect_equal(m[["A one"]], c("0", NA))
  expect_equal(m[["B two"]], c(NA, "Diurnal"))
})

test_that("all Ctenomys records remain available under Rodentia", {
  sp <- grep("^Ctenomys ", app$sp_choices, value = TRUE)
  expect_gte(length(sp), 60L)
  expect_true(all(app$tax_order[sp] == "Rodentia"))
  t <- app$trait_coverage(app$compiled, sp)
  expect_gte(nrow(t), 41L)
  expect_true(all(t$Species_with_data <= length(sp)))
  shared <- app$trait_coverage(app$compiled, sp, shared = TRUE)
  expect_true(all(shared$Species_with_data == length(sp)))
  cat(sprintf("Ctenomys: %d species, %d traits, %d shared traits\n", length(sp), nrow(t), nrow(shared)))
})

test_that("OLS adjustment agrees with lm and handles degenerate samples", {
  set.seed(12)
  w <- data.frame(Species = paste("Test", 1:40), Order = "Test",
                  x = rnorm(40), size = rnorm(40))
  w$y <- 2 + 0.7 * w$x + 1.6 * w$size + rnorm(40, sd = 0.3)
  f <- app$reg_fit(w, "y", "x", "size", FALSE, "OLS")
  expected <- lm(y ~ x + size, w)
  expect_null(f$err)
  expect_equal(f$coef$Estimate, unname(coef(expected)), tolerance = 1e-10)
  expect_equal(unname(coef(lm(ry ~ rx, f$av))[2]), f$slope, tolerance = 1e-10)
  plain <- app$reg_fit(f$species, "y", "x", character(), FALSE, "OLS")
  expect_equal(plain$n, f$n)
  w$size <- w$x
  expect_match(app$reg_fit(w, "y", "x", "size", FALSE, "OLS")$err, "collinear")
  w$size <- 1
  expect_match(app$reg_fit(w, "y", "x", "size", FALSE, "OLS")$err, "No variation")
  expect_match(app$reg_fit(w[1:3, ], "y", "x", character(), FALSE, "OLS")$err, "Only 3")
})

test_that("sample audit agrees with log and tree exclusions", {
  w <- data.frame(Species = c("A one", "B two", "C three", "D four"), Order = "Test",
                  y = c(1, 2, 3, 4), x = c(2, NA, 0, 5), size = c(3, 4, 5, Inf))
  a <- app$regression_audit(w, c("y", "x", "size"), TRUE, "OLS")
  expect_equal(a$Status, c("Included", "Missing / non-finite measurement", "Non-positive under log10", "Missing / non-finite measurement"))
  expect_equal(a$Missing_variables, c("", "x", "", "size"))
  expect_equal(app$regression_audit(w, c("y", "x", "size"), FALSE, "OLS")$Status[3], "Included")
  a <- app$regression_audit(w, c("y", "x", "size"), TRUE, "Brownian", list(tip.label = "Other_species"))
  expect_equal(a$Status[1], "No matching tree tip")
})

test_that("server selectors, species subsets and model comparison work together", {
  shiny::testServer(app$server, {
    session$setInputs(e_order = "Rodentia", e_genus = "Ctenomys", e_coverage = "any",
                      r_y = "Neocortex_Vol.mm3", r_x = "Brain_Mass_mass_or_volume (g)",
                      r_control = "body", r_body = "Body_Mass (g)", r_log = TRUE,
                      r_method = "OLS", r_clade = "All", r_cohort = "")
    expect_gte(length(e_selected()), 60L)
    expect_gte(nrow(e_traits()), 41L)
    session$setInputs(e_species = c("Ctenomys talarum", "Ctenomys australis"), e_coverage = "all")
    expect_equal(length(e_selected()), 2L)
    expect_true(all(e_traits()$Species_with_data == 2L))
    expect_setequal(unique(e_values()$Species), e_selected())
    expect_no_error(output$e_traits)
    expect_no_error(output$e_matrix)
    exported <- read.csv(output$e_coverage_download)
    expect_equal(unique(exported$Selected_species_names), paste(e_selected(), collapse = "; "))
    expect_setequal(unique(read.csv(output$e_download)$Species), e_selected())
    session$setInputs(e_domain = "not a domain")
    expect_equal(nrow(e_traits()), 0L)
    expect_no_error(output$e_traits)
    session$setInputs(e_domain = character(), e_species = "Ctenomys talarum")
    expect_no_error(output$e_traits)
    session$setInputs(e_order = "Primates")
    expect_length(e_selected(), 0L) # stale genus/species cannot leak across orders
    session$setInputs(e_order = "", e_genus = character(), e_species = character())
    expect_length(e_selected(), 0L)
    f <- r_ok()
    expect_equal(sum(r_audit()$Status == "Included"), f$n)
    expect_equal(r_unadjusted()$n, f$n)
    expect_no_error(output$r_adjustment)
    expect_equal(sum(read.csv(output$r_audit_download)$Status == "Included"), f$n)
    session$setInputs(r_species_filter = c("Ctenomys talarum", "Ctenomys australis"))
    expect_setequal(r_scope(), c("Ctenomys talarum", "Ctenomys australis"))
    expect_match(r_fit()$err, "Only")
    session$setInputs(r_clade = "Primates")
    expect_length(r_scope(), 0L)
    expect_equal(nrow(r_audit()), 0L)
    expect_match(r_fit()$err, "Only 0")
  })
})

test_that("PGLS uses the same eligible species for the unadjusted comparison", {
  skip_if_not(app$have_phylo_pkgs)
  old_tree <- app$tree; old_ready <- app$tree_ready
  on.exit({ app$tree <- old_tree; app$tree_ready <- old_ready }, add = TRUE)
  set.seed(5)
  app$tree <- ape::rtree(18)
  app$tree$tip.label <- paste0("Test_species", 1:18)
  app$tree_ready <- TRUE
  w <- data.frame(Species = gsub("_", " ", app$tree$tip.label), Order = "Test",
                  x = runif(18, 1, 10), size = runif(18, 1, 10))
  w$y <- 1 + 0.5 * w$x + w$size + rnorm(18)
  for (method in c("Brownian", "Pagel")) {
    f <- app$reg_fit(w, "y", "x", "size", FALSE, method)
    expect_null(f$err)
    expect_equal(f$n, 18L)
    simple <- app$reg_fit(f$species, "y", "x", character(), FALSE, method)
    expect_null(simple$err)
    expect_setequal(simple$species$Species, f$species$Species)
  }
})
