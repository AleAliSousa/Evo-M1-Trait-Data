library(shiny)
library(tidyverse)
library(ggtree)
library(ggrepel)

if (!file.exists("opsin_explorer_data.RData")) {
  stop("Run setup_data.R first.")
}

load("opsin_explorer_data.RData")

# -----------------------------
# USER INTERFACE
# -----------------------------

ui <- fluidPage(
  
  titlePanel(
    div(
      h1(
        "Mammalian Opsin Phylogeny Explorer",
        style = "margin-bottom: 5px;"
      ),
      p(
        "Interactive exploration of recorded opsin diversity and spectral sensitivity",
        style = "font-size: 16px; color: #666666; margin-top: 0;"
      )
    )
  ),
  
  div(
    style = "
      background-color: #f7f7f7;
      padding: 20px 24px;
      margin-bottom: 20px;
      border-radius: 8px;
      border-left: 5px solid #555555;
    ",
    
    h3(
      "Exploring recorded visual-pigment diversity across the mammalian phylogeny",
      style = "margin-top: 0;"
    ),
    
    p(
      "This interactive explorer maps visual opsin records from the Visual Physiology Opsin Database (VPOD v1.3) onto a representative mammalian phylogeny. "
    ),
    
    p(
      strong("What is being measured?"),
      " Point colour represents the range of recorded peak sensitivities (λmax) for each species, while point size represents the number of distinct VPOD-labelled opsin-family categories recorded for that species."
    ),
    
    p(
      strong("How should the results be interpreted?"),
      " These measures describe the diversity of opsin records currently represented in VPOD. They should not be interpreted as a direct measure of functional colour vision or chromatic perception, because gene or opsin-family records do not necessarily indicate expression, functional photoreceptor complement, or behavioural colour discrimination."
    ),
    
    p(
      strong("Explore the tree:"),
      " select a primary species and a comparison species using the controls, or click directly on species in the phylogeny."
    )
    
  ),
  
  sidebarLayout(
    
    sidebarPanel(
      width = 3,
      style = "
    background-color: #f7f7f7;
    border-radius: 10px;
    padding: 20px;
    border: 1px solid #e5e5e5;
  ",
      
      h4("Explore the phylogeny"),
      
      selectInput(
        "species",
        "Primary species",
        choices = mammal_vpod_data$display_name,
        selected = mammal_vpod_data$display_name[1]
      ),
      
      actionButton(
        "reset",
        "Reset selection",
        class = "btn-primary"
      ),
      
      hr(),
      
      h4("Compare species"),
      
      selectInput(
        "species_2",
        "Comparison species",
        choices = mammal_vpod_data$display_name,
        selected = mammal_vpod_data$display_name[2]
      ),
      
      p(
        style = "font-size: 12px; color: #777777;",
        "You can also click species directly on the phylogeny. The first click sets the primary species; the second sets the comparison."
      )
      
    ),
    
    mainPanel(
      width = 9,
      
      h3(
        "Explore the mammalian phylogeny",
        style = "
    font-weight: 600;
    margin-top: 10px;
    margin-bottom: 8px;
  "
      ),
      
      div(
        style = "
    background-color: #fafafa;
    padding: 12px 16px;
    margin-bottom: 12px;
    border-radius: 6px;
    border: 1px solid #e2e2e2;
  ",
        
        p(
          style = "margin-bottom: 6px;",
          strong("How to explore: ")
        ),
        
        p(
          style = "margin-bottom: 0;",
          "Choose a primary and comparison species using the controls, ",
          "or click directly on the phylogeny. The first click sets the primary ",
          "species; the second click sets the comparison species."
        )
      ),
      
      div(
        style = "
    margin-top: 10px;
    margin-bottom: 10px;
    padding: 10px 15px;
    background-color: #fafafa;
    border-radius: 6px;
    border: 1px solid #dddddd;
  ",
        
        strong("Phylogeny key"),
        
        br(),
        
        span("● Colour = recorded λmax spectral range"),
        
        br(),
        
        span("● Marker size = number of VPOD-labelled opsin families"),
        
        br(),
        
        span("● First click = primary species | Second click = comparison species")
        
      ),
      
      plotOutput(
        outputId = "phylogeny",
        height = "600px",
        click = "phylogeny_click"
      ),
      div(
        style = "
    background-color: #f7f7f7;
    padding: 12px 16px;
    margin-top: 10px;
    margin-bottom: 15px;
    border-radius: 6px;
    border: 1px solid #dddddd;
  ",
        
        strong("Current selection"),
        
        p(
          style = "margin-top: 8px; margin-bottom: 4px;",
          strong("Primary: "),
          textOutput("selected_primary", inline = TRUE)
        ),
        
        p(
          style = "margin-bottom: 0;",
          strong("Comparison: "),
          textOutput("selected_comparison", inline = TRUE)
        )
      ),
      
      hr(),
      
      h4("Recorded spectral range across the mammalian phylogeny"),
      
      p(
        "Tip colour represents the range between the minimum and maximum recorded ",
        "λmax values for each species in VPOD v1.3."
      ),
      
      plotOutput(
        outputId = "spectral_phylogeny",
        height = "600px"
      ),
      
      hr(),
      
      h3("Phylogenetic signal"),
      
      p(
        "Phylogenetic signal was examined to explore whether closely related ",
        "mammals tended to have more similar values for the two measures."
      ),
      
      div(
        style = "
          background-color: #fafafa;
          padding: 15px 18px;
          margin-top: 10px;
          margin-bottom: 15px;
          border-radius: 6px;
          border: 1px solid #dddddd;
        ",
        
        strong("Opsin-family diversity"),
        
        p(
          "Pagel's λ was approximately 0 (p = 1), providing little evidence ",
          "of detectable phylogenetic signal in the number of VPOD-labelled ",
          "opsin-family categories across the 32 mammals included in the tree."
        ),
        
        strong("Recorded spectral range"),
        
        p(
          "Pagel's λ was 0.832 (p = 0.059), suggesting relatively strong ",
          "estimated phylogenetic structure in recorded spectral range, ",
          "although this did not reach conventional statistical significance."
        ),
        
        p(
          em(
            "These analyses are exploratory. The mammalian dataset contains ",
            "32 species with exact tree matches, and phylogenetic signal does ",
            "not establish causation."
          )
        )
        
      ),
      
      hr(),
      
      h3(
        "Selected species",
        style = "
    font-weight: 600;
    margin-top: 25px;
    margin-bottom: 12px;
  "
      ),
      
      tableOutput(
        outputId = "species_info"
      ),
      
      hr(),
      
      h3(
        "Species comparison",
        style = "
    font-weight: 600;
    margin-top: 25px;
    margin-bottom: 12px;
  "
      ),
      
      tableOutput(
        outputId = "species_comparison"
      ),
      
      hr(),
      
      h3(
        "Opsin diversity across vertebrates",
        style = "font-weight: 600; margin-top: 25px; margin-bottom: 12px;"
      ),
      
      p(
        "This exploratory analysis examines whether species with more ",
        "VPOD-labelled opsin-family categories also show a broader range ",
        "of recorded peak sensitivities (λmax). Each point represents one ",
        "vertebrate species in the curated dataset."
      ),
      
      plotOutput(
        outputId = "opsin_diversity_plot",
        height = "450px"
      ),
      
      hr(),
      
      h3("λmax comparison"),
      
      plotOutput(
        outputId = "lambda_comparison",
        height = "350px"
      ),
      
      hr(),
      
      h3("Recorded opsins"),
      
      tableOutput(
        outputId = "opsin_records"
      ),
      
      hr(),
      
      h3("Recorded λmax profile"),
      
      plotOutput(
        outputId = "lambda_plot",
        height = "300px"
      ),
      
      hr(),
      
      h3("Data, methods & limitations"),
      
      div(
        style = "
          background-color: #fafafa;
          padding: 18px 20px;
          margin-top: 10px;
          margin-bottom: 20px;
          border-radius: 6px;
          border: 1px solid #dddddd;
        ",
        
        h4("Data source"),
        
        p(
          "Opsin records are derived from the Visual Physiology Opsin Database (VPOD) v1.3. ",
          "The analysis uses the curated vertebrate metadata table and focuses on recorded ",
          "peak spectral sensitivities (λmax) and VPOD-labelled opsin-family categories."
        ),
        
        h4("Data preparation"),
        
        p(
          "The VPOD records were cleaned to remove ancestral, pigment and other non-species ",
          "entries, as well as several ambiguous or incompatible species records. Species names ",
          "with identifiable taxonomic or spelling inconsistencies were standardised where possible."
        ),
        
        p(
          "Species-level measures were then calculated for each species, including the number ",
          "of distinct VPOD-labelled opsin-family categories, the minimum and maximum recorded ",
          "λmax values, and the resulting recorded spectral range."
        ),
        
        h4("Phylogenetic analysis"),
        
        p(
          "A representative mammalian phylogeny was obtained using the rtrees package. ",
          "The analysis included 32 mammalian species for which an exact species match to the ",
          "selected phylogeny was available."
        ),
        
        p(
          "Phylogenetic signal was explored using Pagel's λ for opsin-family diversity and ",
          "recorded spectral range. These analyses assess whether closely related species ",
          "show greater similarity in a trait than would be expected without phylogenetic ",
          "structure."
        ),
        
        h4("Important limitations"),
        
        p(
          strong("Recorded opsin diversity is not equivalent to functional colour vision. "),
          "The presence of an opsin-family record does not necessarily indicate gene expression, ",
          "functional photoreceptor complement, or behavioural colour discrimination."
        ),
        
        p(
          strong("Sampling may influence the observed patterns. "),
          "Species with more records in VPOD may have a greater opportunity to show multiple ",
          "opsin-family categories or a wider recorded λmax range."
        ),
        
        p(
          strong("Species are not evolutionarily independent. "),
          "Phylogenetic relationships can influence trait similarity between species, which is ",
          "why evolutionary context is considered alongside the observed associations."
        ),
        
        p(
          strong("Analyses are exploratory rather than causal. "),
          "The relationships shown in this explorer describe associations within the available ",
          "VPOD records and should not be interpreted as evidence that opsin-family diversity ",
          "causes differences in spectral sensitivity."
        )
        
      )
      
    )
  )
)

# -----------------------------
# SERVER
# -----------------------------

server <- function(input, output, session) {
  
  waiting_for_comparison <- reactiveVal(FALSE)
  
  primary_species <- reactive({
    mammal_vpod_data %>%
      filter(display_name == input$species) %>%
      pull(Species)
  })
  
  comparison_species_r <- reactive({
    mammal_vpod_data %>%
      filter(display_name == input$species_2) %>%
      pull(Species)
  })
  
  observeEvent(input$reset, {
    
    waiting_for_comparison(FALSE)
    
    updateSelectInput(
      session,
      "species",
      selected = sort(mammal_vpod_data$display_name)[1]
    )
    
  })
  
  observeEvent(input$phylogeny_click, {
    
    click <- input$phylogeny_click
    
    # Get the actual y positions of the tree tips
    tree_data <- ggtree(mammal_tree_vpod)$data %>%
      filter(isTip)
    
    # Convert the Shiny click position to the tree's y scale
    clicked_y <- 1 + click$y * (max(tree_data$y) - min(tree_data$y))
    
    # Find the tip closest to where the user clicked
    nearest_tip <- tree_data %>%
      slice_min(
        abs(y - clicked_y),
        n = 1
      )
    
    clicked_species <- nearest_tip$label
    
    # Convert to the display name used by the dropdowns
    clicked_display_name <- mammal_vpod_data %>%
      filter(Species == clicked_species) %>%
      pull(display_name)
    
    if (length(clicked_display_name) == 1) {
      
      if (!waiting_for_comparison()) {
        
        # First click = primary species
        updateSelectInput(
          session,
          "species",
          selected = clicked_display_name
        )
        
        waiting_for_comparison(TRUE)
        
      } else {
        
        # Subsequent click = comparison species
        updateSelectInput(
          session,
          "species_2",
          selected = clicked_display_name
        )
        
      }
      
    }
    
  })
  
  # -----------------------------
  # CURRENT SELECTION
  # -----------------------------
  
  output$selected_primary <- renderText({
    req(input$species)
    input$species
  })
  
  output$selected_comparison <- renderText({
    req(input$species_2)
    input$species_2
  })
  
  # Dynamic tree key
  
  # -----------------------------
  # PHYLOGENETIC TREE
  # -----------------------------
  
  output$phylogeny <- renderPlot({
    
    selected_species <- primary_species()
    
    comparison_species <- comparison_species_r()
    
    # Create the base phylogeny
    p <- ggtree(
      mammal_tree_vpod,
      branch.length = "none",
      size = 0.6
    )
    
    # Add species-level data
    p <- p %<+% mammal_vpod_data
    
    # Add species names
    p <- p +
      geom_tiplab(
        aes(label = gsub("_", " ", label)),
        size = 3,
        fontface = "italic",
        offset = 1
      ) +
      xlim(
        NA,
        max(p$data$x, na.rm = TRUE) + 8
      )
    
    # Show opsin-family diversity using colour and marker size
    p <- p +
      geom_point2(
        aes(
          subset = isTip,
          color = family_label_diversity,
          size = family_label_diversity
        ),
        alpha = 0.75
      ) +
      scale_color_viridis_c(
        name = "Opsin-family\ndiversity"
      ) +
      scale_size_continuous(
        range = c(2.5, 5),
        name = "Opsin-family\ndiversity"
      )
    
    # Highlight the primary species
    p <- p +
      geom_point2(
        aes(
          subset = isTip & label == selected_species
        ),
        size = 7,
        shape = 21,
        fill = "white",
        color = "black",
        stroke = 2
      )
    
    # Highlight the comparison species
    p <- p +
      geom_point2(
        aes(
          subset = isTip & label == comparison_species
        ),
        size = 6,
        shape = 21,
        fill = "white",
        color = "black",
        stroke = 1.5
      )
    
    # Improve legend placement
    p +
      theme(
        legend.position = "bottom",
        legend.box = "horizontal",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9)
      )
  })
  
  # -----------------------------
  # SPECTRAL RANGE ON PHYLOGENY
  # -----------------------------
  
  output$spectral_phylogeny <- renderPlot({
    
    selected_species <- primary_species()
    
    comparison_species <- comparison_species_r()
    
    # Create the base phylogeny
    p <- ggtree(
      mammal_tree_vpod,
      branch.length = "none",
      size = 0.6
    )
    
    # Add species-level data
    p <- p %<+% mammal_vpod_data
    
    # Add species names
    p <- p +
      geom_tiplab(
        aes(label = gsub("_", " ", label)),
        size = 3,
        fontface = "italic",
        offset = 1
      ) +
      xlim(
        NA,
        max(p$data$x, na.rm = TRUE) + 8
      )
    
    # Show recorded spectral range using colour and marker size
    p <- p +
      geom_point2(
        aes(
          subset = isTip,
          color = spectral_range,
          size = spectral_range
        ),
        alpha = 0.75
      ) +
      scale_color_viridis_c(
        name = "Recorded λmax\nrange (nm)"
      ) +
      scale_size_continuous(
        range = c(2.5, 5),
        name = "Recorded λmax\nrange (nm)"
      )
    
    # Highlight the primary species
    p <- p +
      geom_point2(
        aes(
          subset = isTip & label == selected_species
        ),
        size = 7,
        shape = 21,
        fill = "white",
        color = "black",
        stroke = 2
      )
    
    # Highlight the comparison species
    p <- p +
      geom_point2(
        aes(
          subset = isTip & label == comparison_species
        ),
        size = 6,
        shape = 21,
        fill = "white",
        color = "black",
        stroke = 1.5
      )
    
    # Improve legend placement
    p +
      theme(
        legend.position = "bottom",
        legend.box = "horizontal",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9)
      )
  })
  
  # -----------------------------
  # SPECIES SUMMARY
  # -----------------------------
  
  output$species_info <- renderTable({
    
    selected_species <- primary_species()
    
    req(length(selected_species) == 1)
    
    selected_data <- species_data %>%
      filter(Species == selected_species)
    
    req(nrow(selected_data) == 1)
    
    data.frame(
      Measure = c(
        "Species",
        "Taxonomic class",
        "VPOD opsin records",
        "VPOD-labelled opsin families",
        "Minimum recorded λmax",
        "Maximum recorded λmax",
        "Recorded spectral range"
      ),
      
      Value = c(
        gsub("_", " ", selected_data$Species),
        selected_data$Class,
        as.character(selected_data$n_opsin_records),
        as.character(selected_data$family_label_diversity),
        paste0(selected_data$min_lambda, " nm"),
        paste0(selected_data$max_lambda, " nm"),
        paste0(selected_data$spectral_range, " nm")
      ),
      
      stringsAsFactors = FALSE
    )
    
  }, striped = TRUE, bordered = FALSE, spacing = "s")
  
  # -----------------------------
  # SPECIES COMPARISON
  # -----------------------------
  
  output$species_comparison <- renderTable({
    
    species_one <- mammal_vpod_data %>%
      filter(display_name == input$species) %>%
      pull(Species)
    
    species_two <- mammal_vpod_data %>%
      filter(display_name == input$species_2) %>%
      pull(Species)
    
    req(length(species_one) == 1)
    req(length(species_two) == 1)
    
    data_one <- species_data %>%
      filter(Species == species_one)
    
    data_two <- species_data %>%
      filter(Species == species_two)
    
    req(nrow(data_one) == 1)
    req(nrow(data_two) == 1)
    
    data.frame(
      Measure = c(
        "VPOD opsin records",
        "VPOD-labelled opsin families",
        "Minimum recorded λmax",
        "Maximum recorded λmax",
        "Recorded spectral range"
      ),
      
      `Primary species` = c(
        data_one$n_opsin_records,
        data_one$family_label_diversity,
        paste0(data_one$min_lambda, " nm"),
        paste0(data_one$max_lambda, " nm"),
        paste0(data_one$spectral_range, " nm")
      ),
      
      `Comparison species` = c(
        data_two$n_opsin_records,
        data_two$family_label_diversity,
        paste0(data_two$min_lambda, " nm"),
        paste0(data_two$max_lambda, " nm"),
        paste0(data_two$spectral_range, " nm")
      ),
      
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    
  }, striped = TRUE, bordered = FALSE, spacing = "s")
  
  # -----------------------------
  # OPSIN DIVERSITY ANALYSIS
  # -----------------------------
  
  output$opsin_diversity_plot <- renderPlot({
    
    # Extract statistics
    pearson_r <- round(
      pearson_test$estimate,
      2
    )
    
    spearman_rho <- round(
      spearman_test$estimate,
      2
    )
    
    p_value <- format.pval(
      pearson_test$p.value,
      digits = 3,
      eps = 0.001
    )
    
    model_r2 <- round(
      summary(opsin_model)$r.squared,
      2
    )
    
    family_coefficient <- round(
      coef(opsin_model)["family_label_diversity"],
      2
    )
    
    family_p <- format.pval(
      summary(opsin_model)$coefficients[
        "family_label_diversity",
        "Pr(>|t|)"
      ],
      digits = 3,
      eps = 0.001
    )
    
    # Plot
    ggplot(
      species_data,
      aes(
        x = family_label_diversity,
        y = spectral_range
      )
    ) +
      
      geom_point(
        alpha = 0.75,
        size = 3
      ) +
      
      geom_smooth(
        method = "lm",
        se = TRUE
      ) +
      
      ggrepel::geom_text_repel(
        aes(label = gsub("_", " ", Species)),
        size = 3,
        max.overlaps = 15
      ) +
      
      labs(
        title = "Opsin-family diversity and recorded spectral range",
        subtitle = paste0(
          "Pearson's r = ",
          pearson_r,
          " | Spearman's ρ = ",
          spearman_rho,
          " | p ",
          p_value,
          "\n",
          "Adjusted coefficient = ",
          family_coefficient,
          " nm | p ",
          family_p,
          " | R² = ",
          model_r2
        ),
        x = "VPOD-labelled opsin-family diversity",
        y = "Recorded λmax range (nm)"
      ) +
      
      theme_minimal(base_size = 13) +
      
      annotate(
        "text",
        x = Inf,
        y = -Inf,
        label = "Exploratory associations; not causal. Species share evolutionary history.",
        hjust = 1.05,
        vjust = -0.5,
        size = 3.2
      )
    
  })
  
  # -----------------------------
  # λmax COMPARISON
  # -----------------------------
  
  output$lambda_comparison <- renderPlot({
    
    species_one <- primary_species()
    
    species_two <- comparison_species_r()
    
    req(length(species_one) == 1)
    req(length(species_two) == 1)
    
    comparison_data <- opsins_tree %>%
      filter(Species %in% c(species_one, species_two)) %>%
      left_join(
        mammal_vpod_data %>%
          select(Species, display_name),
        by = "Species"
      )
    
    range_data <- species_data %>%
      filter(Species %in% c(species_one, species_two)) %>%
      left_join(
        mammal_vpod_data %>%
          select(Species, display_name),
        by = "Species"
      )
    
    ggplot(
      comparison_data,
      aes(
        x = Lambda_Max,
        y = display_name
      )
    ) +
      
      geom_errorbarh(
        data = range_data,
        aes(
          xmin = min_lambda,
          xmax = max_lambda,
          y = display_name
        ),
        height = 0.15,
        linewidth = 1.5,
        inherit.aes = FALSE
      ) +
      
      geom_point(
        aes(color = Opsin_Family),
        size = 4,
        position = position_jitter(
          height = 0.12,
          width = 0
        )
      ) +
      
      scale_x_continuous(
        limits = c(300, 600),
        breaks = seq(300, 600, 50)
      ) +
      
      labs(
        title = "Recorded λmax comparison",
        subtitle = "Points show individual VPOD records; lines show each species' recorded range",
        x = "Peak sensitivity (λmax, nm)",
        y = "Species",
        color = "Opsin family"
      ) +
      
      theme_minimal(base_size = 13) +
      
      theme(
        legend.position = "bottom",
        plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(size = 10)
      )
    
  })
  
  # -----------------------------
  # INDIVIDUAL OPSIN RECORDS
  # -----------------------------
  
  output$opsin_records <- renderTable({
    
    selected_species <- primary_species()
    
    req(length(selected_species) == 1)
    
    opsins_tree %>%
      filter(Species == selected_species) %>%
      select(
        `VPOD record` = Seq_Id,
        `Opsin family` = Opsin_Family,
        `λmax (nm)` = Lambda_Max
      ) %>%
      arrange(`λmax (nm)`)
    
  }, striped = TRUE, bordered = FALSE, spacing = "s")
  
  # -----------------------------
  # λmax SPECTRUM
  # -----------------------------
  
  output$lambda_plot <- renderPlot({
    
    selected_species <- primary_species()
    
    selected_display_name <- input$species
    
    req(length(selected_species) == 1)
    req(length(selected_display_name) == 1)
    
    selected_data <- opsins_tree %>%
      filter(Species == selected_species)
    
    req(nrow(selected_data) > 0)
    
    # Create wavelength background
    wavelength_background <- data.frame(
      xmin = seq(300, 599, 1),
      xmax = seq(301, 600, 1),
      ymin = -Inf,
      ymax = Inf
    )
    
    ggplot(
      selected_data,
      aes(
        x = Lambda_Max,
        y = Opsin_Family
      )
    ) +
      
      # Visible-spectrum background
      geom_rect(
        data = wavelength_background,
        aes(
          xmin = xmin,
          xmax = xmax,
          ymin = ymin,
          ymax = ymax,
          fill = xmin
        ),
        alpha = 0.14,
        inherit.aes = FALSE
      ) +
      
      scale_fill_gradientn(
        colours = c(
          "purple",
          "blue",
          "cyan",
          "green",
          "yellow",
          "orange",
          "red"
        ),
        values = scales::rescale(
          c(300, 400, 450, 500, 550, 580, 600)
        ),
        guide = "none"
      ) +
      
      geom_point(
        aes(color = Opsin_Family),
        size = 4,
        position = position_jitter(
          height = 0.12,
          width = 0
        )
      ) +
      
      # Wavelength scale
      scale_x_continuous(
        limits = c(300, 600),
        breaks = c(300, 350, 400, 450, 500, 550, 600)
      ) +
      
      labs(
        title = paste(
          "Recorded λmax spectrum:",
          selected_display_name
        ),
        subtitle = "Recorded peak sensitivities across the wavelength range",
        x = "Peak sensitivity, λmax (nm)",
        y = "Opsin family",
        color = "Opsin family"
      ) +
      
      theme_minimal(base_size = 13) +
      
      theme(
        plot.title = element_text(
          face = "bold",
          size = 15
        ),
        plot.subtitle = element_text(
          size = 10
        ),
        axis.title = element_text(
          face = "bold"
        ),
        legend.position = "bottom",
        panel.grid.minor = element_blank()
      )
    
  })
  
}

# -----------------------------
# RUN APP
# -----------------------------

shinyApp(ui = ui, server = server)