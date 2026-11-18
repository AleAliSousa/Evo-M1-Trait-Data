# Local canonical-data checks for the combined analysis workspace.
# Rscript _checks/shiny_usability.R
source("_checks/shiny_species_regression.R")

test_that("source links distinguish exact items from publication candidates", {
  exact <- app$source_items(c("Gamba_etal_2015_TableI"))
  expect_equal(nrow(exact), 1L)
  expect_equal(exact$Match, "Exact source item")
  expect_true(grepl("TableI.tsv$", exact$file))
  publication <- app$source_items("Gamba_etal_2015")
  expect_gt(nrow(publication), 1L)
  expect_true(all(grepl("only", publication$Match)))
  expect_equal(nrow(app$source_items("not-a-known-source")), 0L)
  mace <- app$source_items("Mace1981")
  expect_gt(nrow(mace), 0L)
  expect_true(all(grepl("only", mace$Match)))
  expect_true(all(c("item_name", "publication", "role", "upstream_source") %in% names(app$manifest)))
  x <- app$compiled[app$compiled$Dataset == "Cerebral metabolic rate", ]
  expect_true(all(nzchar(x$Source_details)))
  x <- app$compiled[app$compiled$Dataset == "Additional published datasets", ]
  expect_true(all(nzchar(x$Items)))
})

test_that("fossil navigation uses documented classification without changing identity", {
  sp <- c("Australopithecus afarensis", "Australopithecus africanus", "Australopithecus sediba", "Paranthropus boisei", "A. afarensis")
  x <- app$species_index[match(sp, app$species_index$Species), ]
  expect_equal(x$Species, sp)
  expect_true(all(x$Order == "Primates"))
  expect_true(all(nzchar(x$Order_basis)))
  expect_match(x$Order_basis[1], "Curated genus")
  expect_match(x$Order_basis[5], "name key")
})

test_that("plot, audit and data table share species scope and keep provenance", {
  shiny::testServer(app$server, {
    session$setInputs(r_y = "Neocortex_Vol.mm3", r_x = "Brain mass (measured or estimated from volume) (g)",
      r_control = "none", r_log = TRUE, r_method = "OLS", r_clade = "All", r_cohort = "",
      c_model_vars = TRUE, c_measonly = TRUE, c_source = "", r_drop_discord = FALSE)
    expect_no_error(output$r_warnings) # zero covariates must be a valid default
    expect_null(r_fit()$err)
    expect_no_error(output$r_plot)
    expect_no_error(output$r_summary)
    exported <- read.csv(output$r_download, check.names = FALSE,
                         colClasses = c(Discordant_sources = "character"))
    expect_equal(exported[names(r_ok()$species)], r_ok()$species, ignore_attr = TRUE)
    for (v in r_terms()[c("y", "x")]) {
      expect_true(all(nzchar(exported[[paste0(v, "_References")]])))
      expect_true(any(nzchar(exported[[paste0(v, "_Reference_URLs")]])))
    }
    expect_equal(exported$Order[exported$Species == "Rhinopoma microphyllum"], "Chiroptera")
    expect_no_error(output$r_species)
    expect_setequal(unique(c_filtered()$Variable), c(r_terms()$x, r_terms()$y))
    expect_true(all(c("Items", "Teams", "Source_details", "Definition") %in% names(c_display())))
    expect_true(all(c("References", "Reference_URLs") %in% names(c_display())))
    session$setInputs(r_clade = "Primates")
    expect_true(all(app$tax_order[c_filtered()$Species] == "Primates"))
    session$setInputs(r_species_filter = c("Homo sapiens", "Pan troglodytes"))
    expect_setequal(unique(c_filtered()$Species), c("Homo sapiens", "Pan troglodytes"))
    expect_no_error(output$r_plot) # small samples still get a scatter, without a fit
    session$setInputs(c_model_vars = FALSE, c_source = "Stephan")
    d <- c_filtered()
    expect_gt(nrow(d), 0L)
    expect_true(all(grepl("Stephan", paste(d$Source, d$Teams, d$Items), fixed = TRUE)))
    session$setInputs(c_source = "", r_species_filter = character(), r_drop_discord = TRUE)
    expect_true(all(!nzchar(r_data()$Discordant_sources)))
    expect_equal(sum(r_audit()$Status == "Included"), r_ok()$n)
    expect_no_error(show_measurement_sources(c_display()[1, ]))
    # Switching table scope cannot alter fitted coefficients or sample size.
    before <- r_ok()
    session$setInputs(c_model_vars = TRUE, c_variable = "not-a-variable")
    expect_equal(r_ok()$coef, before$coef)
    expect_equal(nrow(c_filtered()), 0L)
  })
})

test_that("structure joins respect units, exact anatomy and duplicate series", {
  labels <- c("A_volume", "B_volume", "C_volume", "A_cells", "B_cells", "C_cells")
  meta <- data.frame(label = labels, domain = "brain structure & size",
    measure_class = rep(c("structure_volume", "neuron_number"), each = 3),
    Structure = rep(c("A", "B", "C"), 2), Measure = rep(c("volume", "cells"), each = 3),
    Unit = rep(c("mL", "count"), each = 3))
  data <- data.frame(Species = "Test one", Dataset = "Paper", Variable = labels,
    Source = "Original item", Value_num = c(1, 2, 3, 2, 4, 7))
  m <- app$sr_label_meta(labels, data$Dataset, meta)
  rows <- app$sr_structure_rows(data, m)
  keys <- unique(m$cmp_key)
  p <- app$structure_pairs(rows, "Test one", keys[1], keys[2])
  expect_equal(nrow(p$data), 3L)
  expect_equal(p$data$Value_X, c(1000, 2000, 3000))
  expect_true(all(p$data$Sources_X == "Original item"))
  d <- app$structure_plot_data(p$data, FALSE)
  stats <- app$structure_fit_stats(d)
  expect_equal(stats$Slope, 0.0025, tolerance = 1e-12)
  expect_equal(stats$R_squared, 75 / 76, tolerance = 1e-12)
  # Multiple source series for A must not create a Cartesian product.
  duplicate <- rows[1, ]; duplicate$Dataset <- "Other paper"
  p <- app$structure_pairs(rbind(rows, duplicate), "Test one", keys[1], keys[2])
  expect_equal(p$ambiguous, 1L)
  expect_equal(nrow(p$data), 2L)
  p <- app$structure_pairs(rbind(rows, duplicate), "Test one", keys[1], keys[2],
    xseries = paste(labels[1:3], "Paper", sep = " @ "))
  expect_equal(nrow(p$data), 3L)
  p$data$Value_X[1] <- 0
  expect_equal(nrow(app$structure_plot_data(p$data, TRUE)), 2L)
  expect_equal(nrow(app$structure_plot_data(p$data, FALSE)), 3L)
  # A substructure cannot inherit its parent structure's paired value.
  changed <- rows; changed$structure[1] <- changed$display[1] <- "A_subregion"
  expect_equal(nrow(app$structure_pairs(changed, "Test one", keys[1], keys[2])$data), 2L)
  expect_equal(nrow(app$structure_pairs(rows, "Absent species", keys[1], keys[2])$data), 0L)
})

test_that("structure scatter server produces real paired measurements and exports", {
  shiny::testServer(app$server, {
    session$setInputs(bs_species = "Homo sapiens", bs_xkey = "volume|volume||",
      bs_ykey = "neuron_number|count||", bs_scatter_log = TRUE, bs_scatter_label = TRUE,
      bs_scatter_facet = TRUE)
    expect_gt(nrow(bs_pairs()$data), 0L)
    expect_no_error(output$bs_scatter)
    expect_no_error(output$bs_scatter_note)
    expect_no_error(output$bs_scatter_stats)
    csv <- read.csv(output$bs_scatter_download)
    expect_equal(nrow(csv), nrow(bs_scatter_data()))
    expect_true(all(c("Sources_X", "Sources_Y", "Variable_X", "Variable_Y") %in% names(csv)))
    session$setInputs(bs_compare = "Macaca mulatta")
    expect_true(all(bs_scatter_data()$Species %in% c("Homo sapiens", "Macaca mulatta")))
  })
})
