# =============================================================================
# __Finder/app.R — Evo-M1-Trait-Data Finder (APP_PLAN.md Part B)
#
# Built so far: Tab 4 "Coverage & gaps". Tabs 1-3 (Find data, Find by species,
# Browse folders) follow APP_PLAN B.5 and are not built yet.
#
#   shiny::runApp("__Finder")
#   Rscript _tools/build_coverage_index.R      # rebuild data/coverage_*.csv
#
# Reads only data/ (the derived index). Every status traces to a row in
# data/coverage_records.csv, which carries the source, the crosswalk link from
# _keys/anatomy_crosswalk.csv and the reason the status was assigned.
# =============================================================================

suppressPackageStartupMessages({
  library(shiny); library(bslib); library(DT)
  library(dplyr); library(tidyr); library(readr); library(stringr)
})

data_dir <- "data"
rec <- read_csv(file.path(data_dir, "coverage_records.csv"), show_col_types = FALSE, guess_max = 1e5) |>
  mutate(across(where(is.character), ~ replace_na(.x, "")))
co  <- read_csv(file.path(data_dir, "coverage_cooccurrence.csv"), show_col_types = FALSE)
tg  <- read_csv(file.path(data_dir, "coverage_targets.csv"), show_col_types = FALSE) |>
  mutate(across(everything(), ~ replace_na(as.character(.x), "")))

ST  <- c("harmonized", "not_harmonized", "planned", "not_found")
EMO <- c(harmonized = "\u2705", not_harmonized = "\U0001F7E1", planned = "\U0001F535", not_found = "\u26AA")
LAB <- c(harmonized = "Available & harmonized", not_harmonized = "Available, not harmonized",
         planned = "Planned", not_found = "Not found")
best <- function(s) { s <- s[s %in% ST]; if (!length(s)) "not_found" else ST[min(match(s, ST))] }

CORE    <- c("Homo sapiens", "Mus musculus", "Macaca mulatta", "Callithrix jacchus")
PROJECT <- c("M1", "V1", "EC", "MEC", "LEC")
CLASSES <- c("Regional size", "Cell measurements", "Metabolism", "Cytoarchitecture")
MEAS_ORDER <- c("Surface area", "Volume", "Thickness", "Mass",
                "Total cell count", "Neuron count", "Non-neuronal cell count", "Microglia count",
                "Cell density", "Neuron density", "Non-neuronal density", "Microglia density",
                "Non-neuronal / neuron ratio",
                "Glucose utilization (CMRglc)", "Oxygen consumption (CMRO2)", "Blood flow (CBF)",
                "Total glucose utilization", "Total O2 consumption", "GLI")
ord_meas <- function(m) c(intersect(MEAS_ORDER, m), sort(setdiff(m, MEAS_ORDER)))

broader_groups <- rec |> filter(scope == "broader") |> distinct(region_group) |> pull() |> sort()
all_species    <- sort(unique(rec$species[rec$status != "not_found"]))

legend_ui <- tags$div(class = "small",
  lapply(ST, function(s) tags$div(EMO[[s]], " ", LAB[[s]])),
  tags$div(class = "text-muted mt-2",
    "Proxy links (containing or overlapping regions, section blocks, PET/autoradiography ROIs) ",
    "are hidden unless switched on. Different boundary bases are listed separately, never pooled."))

detail_cols <- c("status", "reason", "domain", "term", "relation", "link_class", "boundary_basis",
                 "source_role", "source", "n_values", "units", "link_basis", "link_note",
                 "dataset_source", "build_script")

# ---- UI --------------------------------------------------------------------
ui <- page_navbar(
  title = "Evo-M1-Trait-Data Finder",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  nav_panel("Coverage & gaps",
    navset_card_tab(
      nav_panel("Project core",
        layout_sidebar(
          sidebar = sidebar(width = 270,
            radioButtons("p_concept", "Structure", PROJECT, inline = TRUE),
            radioButtons("p_species", "Species", c("Core four" = "core", "All in this project" = "all")),
            checkboxGroupInput("p_class", "Measurement class", CLASSES, CLASSES),
            checkboxInput("p_proxy", "Include proxy links", FALSE),
            hr(), legend_ui),
          DTOutput("p_matrix"),
          uiOutput("p_detail_title"), DTOutput("p_detail"))),
      nav_panel("Broader comparison",
        layout_sidebar(
          sidebar = sidebar(width = 270,
            selectizeInput("b_species", "Species", c("All species (any)" = "__all__", all_species),
                           selected = "Homo sapiens"),
            checkboxGroupInput("b_group", "Region group", broader_groups, broader_groups),
            checkboxGroupInput("b_class", "Measurement class", CLASSES, CLASSES),
            checkboxInput("b_proxy", "Include proxy links", FALSE),
            helpText("With one species selected, each cell is that species' best status. ",
                     "With all species, the number is how many species have data."),
            hr(), legend_ui),
          DTOutput("b_matrix"),
          uiOutput("b_detail_title"), DTOutput("b_detail"),
          h6(class = "mt-4", "Co-occurrence: domains with direct data for the same species"),
          DTOutput("b_cooc"))),
      nav_panel("Records", DTOutput("all_records")),
      nav_panel("Targets", p(class = "text-muted mt-2",
        "From _keys/coverage_targets.csv. planned = a named paper or dataset; wanted = a gap with no source named yet."),
        DTOutput("targets"))
    )
  ),
  nav_spacer(),
  nav_item(tags$span(class = "navbar-text small", "Find data / Find by species / Browse folders: not built yet"))
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {

  # Project core ---------------------------------------------------------------
  p_rec <- reactive({
    d <- rec |> filter(concept == input$p_concept, measurement_class %in% input$p_class)
    if (!input$p_proxy) d <- d |> filter(link_class != "proxy")
    d
  })
  p_species <- reactive({
    sp <- unique(rec$species[rec$concept == input$p_concept & rec$status != "not_found"])
    if (input$p_species == "core") CORE else c(CORE, sort(setdiff(sp, CORE)))
  })
  p_cols <- reactive({
    m <- rec |> filter(concept %in% PROJECT, measurement_class %in% input$p_class) |> pull(measurement)
    ord_meas(unique(m))
  })
  p_mat <- reactive({
    cells <- p_rec() |> group_by(species, measurement) |> summarise(s = best(status), .groups = "drop")
    expand_grid(species = p_species(), measurement = p_cols()) |>
      left_join(cells, by = c("species", "measurement")) |>
      mutate(s = EMO[coalesce(s, "not_found")]) |>
      pivot_wider(names_from = measurement, values_from = s) |>
      mutate(species = factor(species, p_species())) |> arrange(species) |>
      mutate(species = as.character(species))
  })
  output$p_matrix <- renderDT(datatable(p_mat(), rownames = FALSE, escape = FALSE,
    selection = list(mode = "single", target = "cell"),
    options = list(dom = "t", paging = FALSE, ordering = FALSE, scrollX = TRUE,
                   columnDefs = list(list(className = "dt-center", targets = "_all")))))

  p_sel <- reactive({
    cs <- input$p_matrix_cells_selected
    if (is.null(cs) || !length(cs) || cs[1, 2] == 0) return(NULL)
    list(species = p_mat()$species[cs[1, 1]], measurement = names(p_mat())[cs[1, 2] + 1])
  })
  output$p_detail_title <- renderUI({
    s <- p_sel(); if (is.null(s)) return(p(class = "text-muted mt-3", "Click a cell to see why it has its status."))
    h6(class = "mt-3", paste(input$p_concept, "\u2022", s$species, "\u2022", s$measurement))
  })
  output$p_detail <- renderDT({
    s <- p_sel(); req(s)
    d <- rec |> filter(concept == input$p_concept, species == s$species, measurement == s$measurement)
    if (!nrow(d)) d <- tibble(status = "not_found", reason = "no record, including proxies")
    datatable(d |> select(any_of(detail_cols)) |>
                mutate(status = paste(EMO[status], LAB[status])),
              rownames = FALSE, options = list(dom = "t", paging = FALSE, scrollX = TRUE))
  })

  # Broader comparison ---------------------------------------------------------
  b_rec <- reactive({
    d <- rec |> filter(scope == "broader", region_group %in% input$b_group,
                       measurement_class %in% input$b_class, status != "not_found")
    if (!input$b_proxy) d <- d |> filter(link_class != "proxy")
    if (input$b_species != "__all__") d <- d |> filter(species == input$b_species)
    d
  })
  b_mat <- reactive({
    d <- b_rec()
    concepts <- rec |> filter(scope == "broader", region_group %in% input$b_group) |>
      distinct(region_group, concept) |> arrange(region_group, concept)
    cols <- ord_meas(unique(rec$measurement[rec$scope == "broader" & rec$measurement_class %in% input$b_class]))
    cells <- d |> group_by(concept, measurement) |>
      summarise(s = best(status),
                n = n_distinct(species[status %in% c("harmonized", "not_harmonized")]), .groups = "drop") |>
      mutate(lab = if (input$b_species == "__all__") paste(EMO[s], ifelse(n > 0, n, "")) else EMO[s])
    expand_grid(concepts, measurement = cols) |>
      left_join(cells, by = c("concept", "measurement")) |>
      mutate(lab = coalesce(lab, EMO[["not_found"]])) |>
      select(region_group, concept, measurement, lab) |>
      pivot_wider(names_from = measurement, values_from = lab)
  })
  output$b_matrix <- renderDT(datatable(b_mat(), rownames = FALSE, escape = FALSE,
    selection = list(mode = "single", target = "cell"),
    options = list(dom = "t", paging = FALSE, ordering = FALSE, scrollX = TRUE, scrollY = "55vh",
                   columnDefs = list(list(className = "dt-center", targets = "_all")))))

  b_sel <- reactive({
    cs <- input$b_matrix_cells_selected
    if (is.null(cs) || !length(cs) || cs[1, 2] <= 1) return(NULL)
    list(concept = b_mat()$concept[cs[1, 1]], measurement = names(b_mat())[cs[1, 2] + 1])
  })
  output$b_detail_title <- renderUI({
    s <- b_sel(); if (is.null(s)) return(p(class = "text-muted mt-3", "Click a cell to list the records behind it."))
    h6(class = "mt-3", paste(s$concept, "\u2022", s$measurement))
  })
  output$b_detail <- renderDT({
    s <- b_sel(); req(s)
    d <- rec |> filter(scope == "broader", concept == s$concept, measurement == s$measurement)
    if (input$b_species != "__all__") d <- d |> filter(species == input$b_species)
    datatable(d |> select(species, any_of(detail_cols)) |> mutate(status = paste(EMO[status], LAB[status])),
              rownames = FALSE, filter = "top", options = list(pageLength = 15, scrollX = TRUE))
  })
  output$b_cooc <- renderDT({
    d <- co |> filter(scope == "broader", region_group %in% input$b_group)
    if (input$b_species != "__all__") d <- d |> filter(species == input$b_species)
    datatable(d, rownames = FALSE, filter = "top", options = list(pageLength = 15, scrollX = TRUE))
  })

  # Records and targets ---------------------------------------------------------
  output$all_records <- renderDT(datatable(
    rec |> mutate(status = paste(EMO[status], LAB[status])) |>
      select(scope, concept, species, measurement_class, measurement, status, reason, domain, term,
             link_class, boundary_basis, source_role, source, link_basis),
    rownames = FALSE, filter = "top", options = list(pageLength = 25, scrollX = TRUE)))
  output$targets <- renderDT(datatable(tg, rownames = FALSE, filter = "top",
    options = list(pageLength = 25, scrollX = TRUE)))
}

shinyApp(ui, server)
