# Local integration: label classification, plotting data and source provenance.
library(testthat)
Sys.setenv(EVOM1_SOURCE = "local")
repo <- normalizePath(getwd())
setwd(file.path(repo, "__ShinyApp"))
app <- new.env(parent = globalenv())
lines <- readLines("app.R")
eval(parse(text = lines[seq_len(grep("^shinyApp\\(", lines) - 1L)]), app)

test_that("both combined traits are classified, plot-ready and paired", {
  labs <- c("Brain mass (all usable sources) (g)", "Brain volume (all usable sources) (mL)")
  expect_true(all(labs %in% app$numeric_labels))
  m <- app$compiled[app$compiled$Variable == labs[1], ]
  v <- app$compiled[app$compiled$Variable == labs[2], ]
  expect_gt(nrow(m), 3000)
  expect_setequal(m$Species, v$Species)
  expect_equal(anyDuplicated(m$Species), 0L)
  expect_equal(anyDuplicated(v$Species), 0L)
  expect_true(all(is.finite(m$Value_num) & m$Value_num > 0))
  expect_equal(m$Value_num, v$Value_num[match(m$Species, v$Species)] * 1.036, tolerance = 1e-8)
  expect_true(all(nzchar(m$Items)))
  expect_true(all(grepl("unknown sample size", m$Source)))
  expect_true(all(grepl("1.036", m$Source_details)))
  expect_true("Brain mass (measured or estimated from volume) (g)" %in% app$numeric_labels)
})

test_that("both representations work as regression predictors", {
  shiny::testServer(app$server, {
    session$setInputs(r_y = "Neocortex_Vol.mm3", r_x = "Brain mass (all usable sources) (g)",
      r_control = "none", r_log = TRUE, r_method = "OLS", r_clade = "All", r_cohort = "")
    mass_fit <- r_ok()
    expect_gt(mass_fit$n, 100)
    expect_no_error(output$r_plot)
    session$setInputs(r_x = "Brain volume (all usable sources) (mL)")
    expect_equal(r_ok()$n, mass_fit$n)
    expect_setequal(r_ok()$species$Species, mass_fit$species$Species)
    expect_no_error(output$r_plot)
  })
})
