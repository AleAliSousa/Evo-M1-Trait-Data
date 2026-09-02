# =============================================================================
# Evo-M1-Trait-Data explorer  -- public Shiny app
# Two views:
#   1. Compiled database  : harmonized long tables (brain structure, cell counts,
#                            behaviour, ecology, and folding), searchable / plottable.
#   2. Source tables      : the per-publication TSVs in __Public/comparative-data,
#                            each linked to its DOI / PubMed / ISBN source.
#
# Self-contained: all data lives in ./data and is bundled on deploy.
# Deploy with:  rsconnect::deployApp("__ShinyApp")   (see DEPLOY.md)
# =============================================================================

library(shiny)
library(bslib)
library(DT)
library(ggplot2)

# ---- Data source ------------------------------------------------------------
# Primary source is the public GitHub repo (single source of truth); a small
# local copy in ./data acts as a fallback if GitHub is briefly unreachable.
# Override the branch/base with the EVOM1_GH_BASE env var if needed.

GH_BASE <- Sys.getenv(
  "EVOM1_GH_BASE",
  "https://raw.githubusercontent.com/AleAliSousa/Evo-M1-Trait-Data/main/"
)
data_dir <- "data"
options(timeout = max(60, getOption("timeout")))  # allow slow raw.github reads

# percent-encode a filename for use in a URL path (handles the %2F, <, >, ;,
# ( ) etc. that appear literally in the DOI-encoded source-table filenames)
pct <- function(s) {
  bytes <- charToRaw(enc2utf8(s))
  out <- vapply(bytes, function(b) {
    ch <- rawToChar(b)
    if (grepl("[A-Za-z0-9._~-]", ch)) ch
    else sprintf("%%%02X", as.integer(b))
  }, character(1))
  paste0(out, collapse = "")
}

# Read a file, trying GitHub first, then the local fallback copy.
# `reader` is given a URL string (GitHub) or a path (local) and manages its
# own connection (read.csv/read.delim open and close the URL themselves).
read_gh <- function(gh_rel, local, reader, required = TRUE) {
  res <- tryCatch(reader(paste0(GH_BASE, gh_rel)), error = function(e) NULL)
  if (!is.null(res)) return(res)
  if (file.exists(local)) {
    message("GitHub fetch failed for ", gh_rel, " — using local fallback.")
    return(tryCatch(reader(local), error = function(e) NULL))
  }
  if (required) stop("Could not load ", gh_rel, " from GitHub or local fallback.")
  NULL
}

read_csv_gh   <- function(gh_rel, local) read_gh(gh_rel, local,
  function(x) read.csv(x, stringsAsFactors = FALSE, check.names = FALSE))
read_delim_gh <- function(gh_rel, local, required = TRUE) read_gh(gh_rel, local,
  function(x) read.delim(x, stringsAsFactors = FALSE, check.names = FALSE),
  required = required)

# GitHub locations: compiled tables from their canonical repo paths; the two
# derived tables from the committed build output under __ShinyApp/data.
GH <- list(
  volumes    = "__merging_volumes/volumes_long.csv",
  cellcounts = "__merging_cellcounts/cellcounts_long.csv",
  traits     = "__ShinyApp/data/evom1_traits_long.csv",
  body       = "__merging_body_ecology/body_ecology_long.csv",
  brain_mass = "__merging_brain_mass/brain_mass_long.csv",
  behaviour  = "__merging_behaviour/behaviour_long.csv",
  cerebellar = "__merging_cerebellar_folding/cerebellar_folding_long.csv",
  manifest   = "__ShinyApp/data/source_manifest.csv"
)
SRC_DIR <- "__Public/comparative-data/"  # source tables (fetched on demand)

# ---- Size consolidation: authoritative body/brain-mass merges ---------------
# Body mass and brain mass each have a dedicated merge (single source of truth):
# __merging_body_ecology and __merging_brain_mass. The app surfaces them from
# those merges. The raw per-table columns (Body_Mass.g in volumes, Brain_weight_g
# in the trait table, ...) are SUPERSEDED — relabelled to the canonical variable
# and kept only as a fallback for the few species a merge does not cover.
# See _keys/variable_canonical.csv (action = supersede / superseded_by).
canon <- tryCatch(
  read_csv_gh("_keys/variable_canonical.csv",
              file.path(data_dir, "variable_canonical.csv")),
  error = function(e) NULL)

# Species display aliases: unify synonym labels (e.g. Callithrix pygmaea ->
# Cebuella pygmaea) across ALL datasets so a species lines up regardless of the
# taxonomy a source used. See _keys/species_display_aliases.csv.
aliases <- tryCatch(
  read_csv_gh("_keys/species_display_aliases.csv",
              file.path(data_dir, "species_display_aliases.csv")),
  error = function(e) NULL)
unalias <- function(sp) {
  if (is.null(aliases) || !nrow(aliases)) return(sp)
  m <- setNames(aliases$canonical, aliases$variant)
  hit <- m[sp]; ifelse(is.na(hit), sp, unname(hit))
}

# ---- Load & harmonize compiled data (once, at startup) ----------------------

load_compiled <- function() {
  # Value is kept as text (so categorical traits like Diet are shown as-is);
  # Value_num is the numeric parse used for plotting.
  std <- function(gh_rel, local, dataset, source_col, n_col = NULL) {
    d <- read_csv_gh(gh_rel, local)
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = d$Variable,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = d[[source_col]],
      N_sources = if (!is.null(n_col)) suppressWarnings(as.integer(d[[n_col]])) else NA_integer_,
      Variable_raw = d$Variable, Unit = NA_character_, Unit_raw = NA_character_,
      stringsAsFactors = FALSE)
  }
  # A merge long file has Measure/Units/Value/n_sources/Teams (no Variable/Source).
  std_merge <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    lab <- paste0(d$Measure, " (", d$Units, ")")
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = paste0("EvoM1 ", tolower(d$Measure), " merge (", d$n_sources, " sources)"),
      N_sources = suppressWarnings(as.integer(d$n_sources)),
      Variable_raw = lab, Unit = d$Units, Unit_raw = d$Units,
      stringsAsFactors = FALSE)
  }

  base <- rbind(
    std(GH$volumes,    file.path(data_dir, "volumes_long.csv"),
        "Brain-structure volumes", "Teams", "n_teams"),
    std(GH$cellcounts, file.path(data_dir, "cellcounts_long.csv"),
        "Cell counts", "Source"),
    std(GH$traits,     file.path(data_dir, "evom1_traits_long.csv"),
        "EvoM1 traits", "Source")
  )
  merges <- rbind(
    std_merge(GH$body,       file.path(data_dir, "body_ecology_long.csv"), "Body & ecology"),
    std_merge(GH$brain_mass, file.path(data_dir, "brain_mass_long.csv"),   "Brain mass"),
    std_merge(GH$behaviour,  file.path(data_dir, "behaviour_long.csv"),    "Behaviour"),
    std_merge(GH$cerebellar, file.path(data_dir, "cerebellar_folding_long.csv"),
              "Cerebellar folding")
  )

  # unify species labels everywhere so synonyms line up
  base$Species   <- unalias(base$Species)
  merges$Species <- unalias(merges$Species)

  # supersede raw body/brain-mass columns with the merges (merge-first + fallback)
  if (!is.null(canon) && nrow(canon)) {
    sup <- canon[!is.na(canon$action) & canon$action == "supersede", ]
    cov <- split(merges$Species, merges$Variable)   # species each merge covers
    keep <- rep(TRUE, nrow(base))
    for (i in seq_len(nrow(sup))) {
      lab <- paste0(sup$canonical_variable[i], " (", sup$canonical_unit[i], ")")
      f   <- suppressWarnings(as.numeric(sup$to_canonical_factor[i])); if (is.na(f)) f <- 1
      sel <- base$Variable_raw == sup$raw_variable[i]
      if (!any(sel)) next
      conv <- base$Value_num[sel] * f
      base$Variable[sel]  <- lab
      base$Unit[sel]      <- sup$canonical_unit[i]; base$Unit_raw[sel] <- sup$raw_unit[i]
      base$Value_num[sel] <- conv
      base$Value[sel]     <- ifelse(is.na(conv), base$Value[sel],
                                    formatC(conv, format = "g", digits = 8))
      keep[sel] <- !(base$Species[sel] %in% cov[[lab]])   # drop where merge covers it
    }
    base <- base[keep, ]
  }

  out <- rbind(base, merges)
  out <- out[!is.na(out$Value) & nzchar(out$Value), ]
  out[order(out$Species, out$Variable), ]
}

compiled <- load_compiled()

manifest <- read_csv_gh(GH$manifest, file.path(data_dir, "source_manifest.csv"))
manifest <- manifest[order(manifest$identifier, manifest$table_label), ]
# Friendly label for the source-table picker: citation + table label
manifest$picker <- paste0(manifest$citation_short,
                          ifelse(nzchar(manifest$table_label),
                                 paste0("  —  ", manifest$table_label), ""))

# Species taxonomy (Order/Family) for the plot clade filter/colour. Taxonomy is
# not a measurement, so it lives here, not among the variables.
taxonomy <- tryCatch(
  read_csv_gh("_keys/species_taxonomy.csv",
              file.path(data_dir, "species_taxonomy.csv")),
  error = function(e) NULL)
tax_order <- if (!is.null(taxonomy)) {
  setNames(taxonomy$Order, taxonomy$Species)
} else {
  setNames(character(0), character(0))
}
clade_choices <- c("All", if (!is.null(taxonomy))
  sort(unique(taxonomy$Order[nzchar(taxonomy$Order)])))

sp_choices  <- sort(unique(compiled$Species))

# ---- Variable organisation + glossary --------------------------------------
# The `Dataset` column above says which MERGE a value came from — useful
# provenance, but a poor way to find a trait: life-history measures sit in two
# datasets, and "EvoM1 traits" is a single bucket holding gyrification, sleep,
# torpor, interlaminar astrocytes and corticospinal fibre counts together.
# So organisation is driven by two authored keys instead:
#   variable_definitions.csv  label -> domain, measure_class, Structure, Measure,
#                             Unit, definition (built by
#                             _keys/build_variable_definitions.R)
#   glossary.csv              term -> expansion/definition, with `common` marking
#                             everyday terms that need no tooltip
# Both are read from GitHub with the usual local fallback. If they are missing the
# app degrades to the old flat behaviour rather than failing.
vardef <- tryCatch(
  read_csv_gh("_keys/variable_definitions.csv",
              file.path(data_dir, "variable_definitions.csv")),
  error = function(e) NULL)
glossary <- tryCatch(
  read_csv_gh("_keys/glossary.csv", file.path(data_dir, "glossary.csv")),
  error = function(e) NULL)

have_org <- !is.null(vardef) && nrow(vardef) && all(c("label", "domain") %in% names(vardef))

# label -> attribute lookups
vd_get <- function(col) {
  if (!have_org || !col %in% names(vardef)) return(setNames(character(0), character(0)))
  setNames(trimws(as.character(vardef[[col]])), vardef$label)
}
lab_domain <- vd_get("domain");        lab_class  <- vd_get("measure_class")
lab_def    <- vd_get("definition");    lab_struct <- vd_get("Structure")
lab_meas   <- vd_get("Measure");       lab_unit   <- vd_get("Unit")
lab_terms  <- vd_get("glossary_terms")
lab_defsrc <- vd_get("definition_source")
lab_ismeas <- vd_get("is_measurement")

look <- function(map, k) {
  if (!length(map)) return("")
  v <- unname(map[k]); v[is.na(v)] <- ""; v
}

# Variables actually present in the data, ordered by domain then class then name
present <- sort(unique(compiled$Variable))
var_domain <- look(lab_domain, present)
var_domain[!nzchar(var_domain)] <- "Unclassified"
var_class  <- look(lab_class, present)

# QC flags and provenance strings are not measurements; keep them out of the
# variable pickers (they remain in the table and the download).
is_meas <- look(lab_ismeas, present)
meas_ok <- !(toupper(is_meas) == "FALSE")

domain_order <- c("brain structure & size", "cellular composition",
                  "cortical & cerebellar folding", "body size", "metabolism",
                  "life history", "diet & ecology", "behaviour & cognition",
                  "sensorimotor & motor pathways", "hand & limb morphology",
                  "sleep & torpor", "dataset metadata", "Unclassified")
dom_present  <- unique(var_domain)
domain_levels <- c(intersect(domain_order, dom_present),
                   setdiff(sort(dom_present), domain_order))

# grouped choices for selectize: Domain > Measure class > label
grouped_choices <- function(labels) {
  d <- look(lab_domain, labels); d[!nzchar(d)] <- "Unclassified"
  cl <- look(lab_class, labels); cl[!nzchar(cl)] <- "other"
  grp <- paste0(d, "  >  ", cl)   # ASCII: the app may be served from a C locale
  o <- order(match(d, domain_levels), cl, labels)
  split(labels[o], factor(grp[o], levels = unique(grp[o])))
}

# All variables, and only the measurement ones, as grouped picker choices
var_choices      <- grouped_choices(present)
var_choices_meas <- grouped_choices(present[meas_ok])

# ---- Abbreviation expansion -------------------------------------------------
# A label's tooltip is its definition plus the expansion of every non-common
# glossary term it contains, so `Amygdala_O.n` explains `O.n` and
# `ILA Subpial Ventral` explains ILA. Terms flagged common = TRUE (g, mm, %)
# are deliberately skipped — the user asked for the ones nobody would know.
g_term <- if (!is.null(glossary)) trimws(as.character(glossary$term)) else character(0)
g_exp  <- if (length(g_term)) setNames(trimws(as.character(glossary$expansion)), g_term) else character(0)
g_def  <- if (length(g_term)) setNames(trimws(as.character(glossary$definition)), g_term) else character(0)
g_common <- if (length(g_term))
  setNames(toupper(trimws(as.character(glossary$common))) == "TRUE", g_term) else logical(0)
g_uncommon <- g_term[!g_common[g_term] %in% TRUE]

# Terms for a label: prefer the precomputed glossary_terms column, else detect.
terms_for <- function(lab) {
  pre <- look(lab_terms, lab)
  if (nzchar(pre)) return(strsplit(pre, "|", fixed = TRUE)[[1]])
  if (!length(g_uncommon)) return(character(0))
  parts <- strsplit(gsub("[()]", " ", lab), "[^A-Za-z0-9]+")[[1]]
  tt <- g_uncommon[order(nchar(g_uncommon), decreasing = TRUE)]
  hit <- character(0)
  for (t in tt) {
    suf <- nchar(lab) > nchar(t) &&
      substring(lab, nchar(lab) - nchar(t) + 1) == t &&
      substring(lab, nchar(lab) - nchar(t), nchar(lab) - nchar(t)) %in% c("_", " ")
    if (suf || t %in% parts)
      if (!any(grepl(t, hit, fixed = TRUE) & hit != t)) hit <- c(hit, t)
  }
  hit
}

# Plain-text tooltip for a variable label.
tip_for <- function(lab) {
  bits <- character(0)
  d <- look(lab_def, lab); if (nzchar(d)) bits <- c(bits, d)
  tms <- terms_for(lab)
  tms <- tms[nzchar(tms) & tms %in% names(g_exp)]
  # Drop a term the definition already conveys, so `Body_Mass (g)` does not
  # append "Mass = mass (unit as printed)" beneath a definition that opens
  # "Whole-animal body mass in grams". Compared on the expansion's content words
  # (a bare-substring test misses it, since the definition says "body mass" and
  # the expansion says "mass (unit as printed)").
  if (length(tms) && nzchar(d)) {
    dl <- tolower(d)
    keep <- vapply(tms, function(t) {
      e <- tolower(unname(g_exp[t]))
      if (!nzchar(e)) return(TRUE)
      if (grepl(e, dl, fixed = TRUE)) return(FALSE)
      w <- strsplit(gsub("[^a-z0-9 ]", " ", e), " +")[[1]]
      w <- w[nchar(w) > 2 & !w %in% c("the", "and", "per", "unit", "printed", "number", "index")]
      if (!length(w)) return(TRUE)
      covered <- all(vapply(w, function(x) grepl(x, dl, fixed = TRUE), logical(1)))
      !covered            # keep the term only if the definition misses part of it
    }, logical(1))
    tms <- tms[keep]
  }
  if (length(tms)) {
    ex <- vapply(tms, function(t) {
      e <- unname(g_exp[t]); if (is.na(e) || !nzchar(e)) t else paste0(t, " = ", e)
    }, character(1))
    bits <- c(bits, paste(ex, collapse = "; "))
  }
  u <- look(lab_unit, lab); if (nzchar(u)) bits <- c(bits, paste0("Unit: ", u))
  paste(bits, collapse = "\n")
}

# Pre-render every tooltip once (384 labels — cheap, and avoids doing it per row)
tips <- setNames(vapply(present, tip_for, character(1)), present)

# Wrap a label in a <span title="..."> so the browser shows the tooltip. Escaped
# because definitions contain quotes and angle-bracket-free but quoted source text.
esc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE); x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub('"', "&quot;", x, fixed = TRUE)
}
label_html <- function(labs) {
  tp <- unname(tips[labs]); tp[is.na(tp)] <- ""
  has <- nzchar(tp)
  out <- esc(labs)
  # A raw newline inside an HTML attribute is collapsed to a space by the parser;
  # &#10; survives and gives the browser tooltip real line breaks.
  attr_txt <- gsub("\n", "&#10;", esc(tp[has]), fixed = TRUE)
  out[has] <- paste0("<span class='evom1-term' title=\"", attr_txt, "\">",
                     esc(labs[has]), "</span>")
  out
}

# ---- Phylogeny (for PGLS phylogenetic regression) ---------------------------
# Drop a mammal tree at _keys/mammal_tree.<nwk|tre|nex> (e.g. an Upham et al.
# 2019 / VertLife mammal tree). Tips "Genus_species[_Family_Order]" are matched
# to species by their binomial. Feature stays dormant (with a hint) until the
# tree + the ape/nlme packages are present. See PHYLO_SETUP.md.
have_phylo_pkgs <- requireNamespace("ape", quietly = TRUE) &&
                   requireNamespace("nlme", quietly = TRUE)

read_tree_any <- function(src) {
  txt <- tryCatch(readLines(src, warn = FALSE), error = function(e) NULL)
  if (is.null(txt) || !length(txt)) return(NULL)
  tr <- if (any(grepl("#NEXUS", txt, ignore.case = TRUE))) {
    tf <- tempfile(fileext = ".nex"); writeLines(txt, tf)
    tryCatch(ape::read.nexus(tf), error = function(e) NULL)
  } else {
    tryCatch(ape::read.tree(text = paste(txt, collapse = "\n")), error = function(e) NULL)
  }
  if (inherits(tr, "multiPhylo")) tr <- tr[[1]]
  tr
}
load_tree <- function() {
  if (!have_phylo_pkgs) return(NULL)
  exts <- c("nwk", "tre", "newick", "nex", "tree")
  for (e in exts) {                      # local fallback first (fast)
    loc <- file.path(data_dir, paste0("mammal_tree.", e))
    if (file.exists(loc)) { tr <- read_tree_any(loc); if (!is.null(tr)) return(tr) }
  }
  for (e in exts) {                      # then GitHub
    tr <- read_tree_any(paste0(GH_BASE, "_keys/mammal_tree.", e))
    if (!is.null(tr)) return(tr)
  }
  NULL
}
tree <- load_tree()
# tree tip -> binomial ("Genus_species_Family_Order" -> "Genus species")
tip_binom <- function(tips) {
  vapply(strsplit(gsub("_", " ", tips), " +"), function(z)
    paste(z[1:2], collapse = " "), character(1))
}
tree_ready <- !is.null(tree)

# Fit PGLS for the current plot data (w: Species + x/y numeric columns).
pgls_fit <- function(w, xv, yv, logscale, model) {
  if (!have_phylo_pkgs)
    return(list(err = "Phylogenetic packages (ape, nlme) are not installed on the server."))
  if (!tree_ready)
    return(list(err = "No mammal tree found. Add _keys/mammal_tree.nwk (see PHYLO_SETUP.md)."))
  bin <- tip_binom(tree$tip.label)
  m <- match(tolower(w$Species), tolower(bin))
  w$tip <- tree$tip.label[m]
  w <- w[!is.na(w$tip) & !duplicated(w$tip), , drop = FALSE]
  X <- w[[xv]]; Y <- w[[yv]]
  if (isTRUE(logscale)) { X <- suppressWarnings(log10(X)); Y <- suppressWarnings(log10(Y)) }
  d <- data.frame(x = X, y = Y, tip = w$tip, stringsAsFactors = FALSE)
  d <- d[is.finite(d$x) & is.finite(d$y), , drop = FALSE]
  if (nrow(d) < 4)
    return(list(err = paste0("Only ", nrow(d), " species match the tree; need ≥ 4 for PGLS.")))
  phy <- ape::keep.tip(tree, d$tip)
  d <- d[match(phy$tip.label, d$tip), , drop = FALSE]   # align row order to tips
  rownames(d) <- d$tip
  cs <- if (model == "Brownian") ape::corBrownian(1, phy, form = ~tip)
        else ape::corPagel(1, phy, form = ~tip, fixed = FALSE)
  fit <- tryCatch(nlme::gls(y ~ x, data = d, correlation = cs, method = "ML"),
                  error = function(e) NULL)
  if (is.null(fit)) return(list(err = "PGLS did not converge for these variables."))
  tt <- summary(fit)$tTable
  lam <- if (model == "Brownian") 1 else
    tryCatch(as.numeric(coef(fit$modelStruct$corStruct, unconstrained = FALSE))[1],
             error = function(e) NA_real_)
  list(intercept = tt[1, 1], slope = tt[2, 1], p = tt[2, 4],
       lambda = lam, n = nrow(d), model = model, logscale = logscale)
}

# ---- UI ---------------------------------------------------------------------

ui <- page_navbar(
  title = "Evo-M1 Comparative Brain-Trait Data",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  fillable = FALSE,

  # Dotted underline marks a variable name that carries a definition tooltip, so
  # a reader can see which labels are hoverable instead of guessing.
  header = tags$head(tags$style(HTML("
    .evom1-term { border-bottom: 1px dotted #7b8a8b; cursor: help; }
    .selectize-dropdown .optgroup-header {
      font-weight: 600; color: #2c3e50; background: #ecf0f1;
    }
  "))),

  # ---------------------------------------------------------------- Compiled --
  nav_panel(
    title = "Compiled database",
    layout_sidebar(
      sidebar = sidebar(
        width = 340,
        helpText("Harmonized cross-species measurements. Narrow by what the ",
                 "measurement IS (domain, then measure class), then download or ",
                 "plot the current selection. Hover any variable name for its ",
                 "definition and the expansion of any abbreviation it contains."),
        selectizeInput("c_domain", "Domain (blank = all)",
                       choices = domain_levels, multiple = TRUE,
                       options = list(placeholder = "e.g. cellular composition")),
        selectizeInput("c_class", "Measure class (blank = all in domain)",
                       choices = NULL, multiple = TRUE,
                       options = list(placeholder = "narrows within the domain")),
        selectizeInput("c_species", "Species (blank = all)",
                       choices = NULL, multiple = TRUE,
                       options = list(placeholder = "Type to search species...",
                                      maxOptions = 2000)),
        selectizeInput("c_variable", "Variable (blank = all)",
                       choices = NULL, multiple = TRUE,
                       options = list(placeholder = "Type to search variables...",
                                      maxOptions = 2000)),
        checkboxInput("c_measonly", "Measurements only (hide QC / provenance flags)",
                      value = TRUE),
        hr(),
        helpText(class = "text-muted small",
                 "Provenance filters \u2014 which compiled table a value came from."),
        selectInput("c_dataset", "Source dataset",
                    choices = sort(unique(compiled$Dataset)),
                    selected = sort(unique(compiled$Dataset)),
                    multiple = TRUE),
        textInput("c_source", "Source contains", placeholder = "e.g. Stephan"),
        downloadButton("c_download", "Download current table (CSV)",
                       class = "btn-primary btn-sm")
      ),
      navset_card_tab(
        nav_panel(
          "Table",
          uiOutput("c_count"),
          DTOutput("c_table")
        ),
        nav_panel(
          "Plot (X vs Y)",
          layout_columns(
            col_widths = c(6, 6),
            selectizeInput("p_x", "X variable", choices = NULL),
            selectizeInput("p_y", "Y variable", choices = NULL)
          ),
          layout_columns(
            col_widths = c(4, 4, 4),
            selectInput("p_clade", "Clade (taxonomic order)",
                        choices = clade_choices, selected = "All"),
            checkboxInput("p_colour", "Colour by order", value = TRUE),
            checkboxInput("p_log", "Log₁₀ both axes", value = TRUE)
          ),
          layout_columns(
            col_widths = c(4, 8),
            checkboxInput("p_pgls",
                          "Phylogenetic regression (PGLS)", value = FALSE),
            selectInput("p_model", "Phylogenetic model",
                        choices = c("Pagel's lambda" = "Pagel",
                                    "Brownian motion" = "Brownian"),
                        selected = "Pagel")
          ),
          uiOutput("p_axis_defs"),
          uiOutput("p_pgls_note"),
          helpText("Each point is a species with values for both variables ",
                   "(mean if several sources). Filter or colour by taxonomic ",
                   "order; enable PGLS to fit a phylogenetically-corrected ",
                   "regression (orange = OLS, black = PGLS)."),
          plotOutput("p_plot", height = "540px")
        )
      )
    )
  ),

  # ------------------------------------------------------------ Source tables --
  nav_panel(
    title = "Source tables",
    navset_card_tab(
      # ---- browse the catalogue
      nav_panel(
        "Catalogue",
        p(class = "text-muted",
          "One row per published table extracted for this project. ",
          "Click a row's link to open its source; use the ",
          strong("Open a table"), " tab to view the data."),
        DTOutput("m_table")
      ),
      # ---- open one table
      nav_panel(
        "Open a table",
        layout_sidebar(
          sidebar = sidebar(
            width = 360,
            selectInput("s_type", "Source type",
                        choices = c("All", sort(unique(manifest$id_type))),
                        selected = "All"),
            selectizeInput("s_pick", "Table",
                           choices = NULL,
                           options = list(placeholder = "Type to search tables...")),
            uiOutput("s_meta"),
            downloadButton("s_download", "Download this table (TSV)",
                           class = "btn-primary btn-sm")
          ),
          uiOutput("s_readme"),
          DTOutput("s_table")
        )
      )
    )
  ),

  # ----------------------------------------------------------------- Glossary --
  nav_panel(
    title = "Glossary",
    navset_card_tab(
      nav_panel(
        "Abbreviations",
        p(class = "text-muted",
          "Every abbreviation used in a variable name, with the source that ",
          "establishes it. Terms marked ", strong("everyday"),
          " are common enough that the app does not show a tooltip for them; ",
          "all others are expanded on hover wherever they appear."),
        DTOutput("g_table")
      ),
      nav_panel(
        "Variables",
        p(class = "text-muted",
          "Every variable in the compiled database, its concept domain, and its ",
          "definition. ", strong("Source"), " definitions are quoted from the ",
          "originating publication's definitions file; ", strong("composed"),
          " ones are built from the structure and measure-code glossaries, ",
          "because the label itself is a composition (e.g. ",
          tags$code("Amygdala_O.n"), " = Amygdala + number of other cells)."),
        DTOutput("v_table")
      )
    )
  ),

  # -------------------------------------------------------------------- About --
  nav_panel(
    title = "About",
    div(
      class = "container", style = "max-width: 820px;",
      h3("Evo-M1 Comparative Brain-Trait Data"),
      p("An interface to search and download comparative brain-trait data ",
        "compiled for the Evo-M1 project."),
      h5("Compiled database"),
      p("Measurements from many primary sources, harmonized to common species ",
        "names and structure terms. ", strong(format(nrow(compiled), big.mark = ",")),
        " values across ", strong(length(sp_choices)), " species and ",
        strong(length(present)), " variables."),
      p("Variables are organised by ", strong("what they measure"),
        " — ", strong(length(domain_levels)), " concept domains, each split into ",
        "measure classes — rather than by which compiled table they came from. ",
        "The source dataset is still available as a provenance filter. Anatomical ",
        "and behavioural traits relating to body and ecology therefore sit with ",
        "their own kind (body size, life history, diet & ecology, metabolism, ",
        "behaviour & cognition) instead of being pooled into one trait bucket."),
      h5("Abbreviations"),
      p("Variable names are compositional and many carry paper-specific ",
        "abbreviations — ", tags$code("ILA"), " for interlaminar astrocytes, ",
        tags$code("O.n"), " for the number of non-neuronal cells. Hovering a ",
        "variable name anywhere in the app shows its definition and expands any ",
        "abbreviation it contains, and the ", strong("Glossary"), " tab lists ",
        "every term with the publication that establishes it. Everyday units are ",
        "deliberately left untooltipped."),
      h5("Source tables"),
      p(strong(nrow(manifest)), " published tables, each shown with its full ",
        "citation and linked to its original DOI, PubMed ID, ISBN, or ",
        "dissertation record."),
      hr(),
      h5("License & attribution"),
      p("This compilation is released under a ",
        tags$a(href = "https://creativecommons.org/licenses/by/4.0/",
               target = "_blank", "Creative Commons Attribution 4.0 (CC BY 4.0)"),
        " license. You are free to share and adapt the data for any purpose, ",
        "provided you give appropriate credit."),
      p(strong("How to cite: "),
        "de Sousa, A. et al. Evo-M1 Comparative Brain-Trait Data (",
        format(Sys.Date(), "%Y"), "). Compiled dataset."),
      p(class = "text-muted small",
        "Important: the compiled tables aggregate work by many original authors. ",
        "When using individual values, please also cite the corresponding ",
        "primary source(s) listed in the Source tables tab and in each value's ",
        "Source column. Every effort has been made to attribute data correctly; ",
        "please report any errors so they can be corrected.")
    )
  ),

  nav_spacer(),
  nav_item(tags$span(class = "text-muted small",
                     paste0(format(nrow(compiled), big.mark = ","), " compiled values")))
)

# ---- Server -----------------------------------------------------------------

server <- function(input, output, session) {

  # server-side choices (fast for large lists)
  updateSelectizeInput(session, "c_species", choices = sp_choices, server = TRUE)
  updateSelectizeInput(session, "c_variable", choices = var_choices, server = TRUE)
  # Plot axes offer measurements only — a QC flag on an axis is never wanted.
  updateSelectizeInput(session, "p_x", choices = var_choices_meas, server = TRUE,
                       selected = "Body_Mass (g)")
  updateSelectizeInput(session, "p_y", choices = var_choices_meas, server = TRUE,
                       selected = "Neocortex_Vol.mm3")

  # Measure-class choices cascade from the chosen domain(s).
  observeEvent(input$c_domain, ignoreNULL = FALSE, {
    labs <- present
    if (length(input$c_domain)) labs <- labs[var_domain %in% input$c_domain]
    cl <- sort(unique(look(lab_class, labs)))
    cl <- cl[nzchar(cl)]
    updateSelectizeInput(session, "c_class", choices = cl,
                         selected = intersect(input$c_class, cl), server = TRUE)
  })

  # The variable picker follows the domain / class / measurement-only filters, so
  # it only ever offers variables the current selection can actually show.
  observe({
    labs <- present
    keep <- rep(TRUE, length(labs))
    if (length(input$c_domain)) keep <- keep & var_domain %in% input$c_domain
    if (length(input$c_class))  keep <- keep & var_class  %in% input$c_class
    if (isTRUE(input$c_measonly)) keep <- keep & meas_ok
    labs <- labs[keep]
    updateSelectizeInput(session, "c_variable", choices = grouped_choices(labs),
                         selected = intersect(input$c_variable, labs), server = TRUE)
  })

  # ---- Compiled: filtered data
  c_filtered <- reactive({
    d <- compiled
    # concept filters first (domain -> measure class -> variable)
    if (length(input$c_domain))
      d <- d[look(lab_domain, d$Variable) %in% input$c_domain, ]
    if (length(input$c_class))
      d <- d[look(lab_class, d$Variable) %in% input$c_class, ]
    if (isTRUE(input$c_measonly))
      d <- d[!(toupper(look(lab_ismeas, d$Variable)) == "FALSE"), ]
    if (length(input$c_variable)) d <- d[d$Variable %in% input$c_variable, ]
    if (length(input$c_species))  d <- d[d$Species  %in% input$c_species, ]
    # provenance filters
    if (length(input$c_dataset)) d <- d[d$Dataset %in% input$c_dataset, ]
    if (nzchar(input$c_source))
      d <- d[grepl(input$c_source, d$Source, ignore.case = TRUE), ]
    d
  })

  output$c_count <- renderUI({
    n <- nrow(c_filtered())
    div(class = "mb-2 text-muted",
        paste0(format(n, big.mark = ","), " row",
               if (n == 1) "" else "s", " selected"))
  })

  # Columns shown / downloaded. Domain and Measure class are carried alongside the
  # variable so the download is self-describing; the internal numeric-parse column
  # stays hidden. A Definition column is included because the whole point of the
  # keys is that a downloaded table should not need the app to be readable.
  c_display <- reactive({
    d <- c_filtered()
    out <- data.frame(
      Species  = d$Species,
      Domain   = look(lab_domain, d$Variable),
      Class    = look(lab_class,  d$Variable),
      Variable = d$Variable,
      Value    = d$Value,
      Unit     = look(lab_unit, d$Variable),
      Source   = d$Source,
      N_sources = d$N_sources,
      Dataset  = d$Dataset,
      stringsAsFactors = FALSE)
    out$Domain[!nzchar(out$Domain)] <- "Unclassified"
    out
  })

  output$c_table <- renderDT({
    d <- c_display()
    show <- d
    show$Variable <- label_html(d$Variable)   # hover = definition + abbreviations
    datatable(show,
              rownames = FALSE, filter = "top", escape = FALSE,
              options = list(pageLength = 25, scrollX = TRUE,
                             order = list(list(0, "asc"))))
  })

  # The download carries the definition text too, so the CSV stands alone.
  output$c_download <- downloadHandler(
    filename = function() paste0("evom1_compiled_", Sys.Date(), ".csv"),
    content  = function(file) {
      d <- c_display()
      d$Definition <- look(lab_def, d$Variable)
      write.csv(d, file, row.names = FALSE)
    }
  )

  # ---- Compiled: plot
  p_data <- reactive({
    req(input$p_x, input$p_y)
    d  <- compiled[compiled$Variable %in% c(input$p_x, input$p_y) &
                     !is.na(compiled$Value_num), ]
    if (nrow(d) == 0) return(NULL)
    ag <- aggregate(Value_num ~ Species + Variable, data = d, FUN = mean)
    names(ag)[names(ag) == "Value_num"] <- "Value"
    w  <- reshape(ag, idvar = "Species", timevar = "Variable", direction = "wide")
    names(w) <- sub("^Value\\.", "", names(w))
    keep <- c("Species", input$p_x, input$p_y)
    keep <- keep[keep %in% names(w)]
    if (length(keep) < 3) return(NULL)
    w <- w[, keep]
    w <- w[stats::complete.cases(w), ]
    # attach taxonomic order; filter to the chosen clade
    w$Order <- unname(tax_order[w$Species]); w$Order[is.na(w$Order)] <- "Unknown"
    if (!is.null(input$p_clade) && input$p_clade != "All")
      w <- w[w$Order == input$p_clade, ]
    w
  })

  # phylogenetic regression result for the current plot (NULL unless enabled)
  p_pgls <- reactive({
    if (!isTRUE(input$p_pgls)) return(NULL)
    w <- p_data(); if (is.null(w) || !nrow(w)) return(NULL)
    pgls_fit(w, input$p_x, input$p_y, input$p_log, input$p_model)
  })

  # What the two plotted variables actually mean — shown inline, because on a
  # scatter plot the axis names are the only labels a reader gets.
  output$p_axis_defs <- renderUI({
    req(input$p_x, input$p_y)
    row1 <- function(tag, lab) {
      d <- look(lab_def, lab); u <- look(lab_unit, lab)
      dm <- look(lab_domain, lab)
      if (!nzchar(d)) return(NULL)
      tags$div(
        tags$strong(paste0(tag, ": ")), tags$code(lab),
        if (nzchar(dm)) tags$span(class = "text-muted small", paste0("  [", dm, "]")),
        tags$br(),
        tags$span(class = "small", d),
        if (nzchar(u)) tags$span(class = "text-muted small", paste0("  (unit: ", u, ")")))
    }
    a <- row1("X", input$p_x); b <- row1("Y", input$p_y)
    if (is.null(a) && is.null(b)) return(NULL)
    div(class = "alert alert-light border py-2 px-2 mb-2", a,
        if (!is.null(a) && !is.null(b)) tags$hr(class = "my-1"), b)
  })

  output$p_pgls_note <- renderUI({
    if (!isTRUE(input$p_pgls)) return(NULL)
    res <- p_pgls()
    if (is.null(res)) return(NULL)
    if (!is.null(res$err))
      return(div(class = "alert alert-warning py-1 px-2 small mb-1", res$err))
    div(class = "alert alert-light border py-1 px-2 small mb-1",
        sprintf("PGLS (%s): slope = %.3g, p = %.3g%s, n = %d species%s",
                if (res$model == "Brownian") "Brownian" else "Pagel's λ",
                res$slope, res$p,
                if (res$model == "Brownian") "" else sprintf(", λ = %.2f", res$lambda),
                res$n, if (res$logscale) " (log₁₀–log₁₀)" else ""))
  })

  output$p_plot <- renderPlot({
    w <- p_data()
    validate(need(!is.null(w) && nrow(w) > 0,
                  "No species have values for both selected variables."))
    x <- input$p_x; y <- input$p_y
    colour_by <- isTRUE(input$p_colour) && length(unique(w$Order)) > 1
    g <- ggplot(w, aes(x = .data[[x]], y = .data[[y]]))
    if (colour_by) {
      g <- g + geom_point(aes(colour = Order), alpha = 0.8, size = 2.4) +
        labs(colour = "Order")
    } else {
      g <- g + geom_point(alpha = 0.75, size = 2.4, colour = "#2c7fb8")
    }
    g <- g + labs(x = x, y = y,
                  subtitle = paste(nrow(w), "species with both measurements")) +
      theme_minimal(base_size = 14)
    if (isTRUE(input$p_log)) {
      g <- g + scale_x_log10() + scale_y_log10() +
        geom_smooth(method = "lm", se = FALSE, linewidth = 0.6,
                    colour = "#d95f0e")
    } else {
      g <- g + geom_smooth(method = "lm", se = FALSE, linewidth = 0.6,
                           colour = "#d95f0e")
    }
    # PGLS line (black) on top, drawn in the same (log or linear) space
    res <- p_pgls()
    if (!is.null(res) && is.null(res$err))
      g <- g + geom_abline(intercept = res$intercept, slope = res$slope,
                           colour = "black", linewidth = 0.8)
    g
  })

  # ---- Glossary: abbreviations
  output$g_table <- renderDT({
    validate(need(!is.null(glossary) && nrow(glossary),
                  "Glossary not available (_keys/glossary.csv could not be loaded)."))
    g <- glossary
    tab <- data.frame(
      Term       = g$term,
      Expansion  = g$expansion,
      Definition = g$definition,
      Kind       = g$kind,
      `Applies to` = if ("applies_to" %in% names(g)) g$applies_to else "",
      Everyday   = ifelse(toupper(trimws(as.character(g$common))) == "TRUE",
                          "yes", ""),
      Source     = if ("source" %in% names(g)) g$source else "",
      check.names = FALSE, stringsAsFactors = FALSE)
    datatable(tab, rownames = FALSE, filter = "top",
              options = list(pageLength = 40, scrollX = TRUE,
                             order = list(list(3, "asc"), list(0, "asc"))))
  })

  # ---- Glossary: variables
  output$v_table <- renderDT({
    validate(need(have_org,
                  "Variable definitions not available (_keys/variable_definitions.csv)."))
    v <- vardef[vardef$label %in% present, , drop = FALSE]
    kind <- if ("definition_kind" %in% names(v)) v$definition_kind else ""
    tab <- data.frame(
      Variable   = v$label,
      Domain     = v$domain,
      Class      = if ("measure_class" %in% names(v)) v$measure_class else "",
      Definition = if ("definition" %in% names(v)) v$definition else "",
      Basis      = ifelse(grepl("^source", kind), "source", "composed"),
      Source     = if ("definition_source" %in% names(v)) v$definition_source else "",
      stringsAsFactors = FALSE)
    datatable(tab, rownames = FALSE, filter = "top",
              options = list(pageLength = 40, scrollX = TRUE,
                             order = list(list(1, "asc"), list(0, "asc")),
                             columnDefs = list(list(width = "34%", targets = 3))))
  })

  # ---- Source tables: catalogue
  output$m_table <- renderDT({
    m <- manifest
    # Link uses the DOI/PMID/ISBN as its visible text; falls back to identifier.
    link <- ifelse(nzchar(m$url),
                   paste0("<a href='", m$url, "' target='_blank'>",
                          m$identifier, "</a>"),
                   m$identifier)
    tab <- data.frame(
      Citation = m$citation,
      Table    = m$table_label,
      Rows     = m$n_rows,
      Cols     = m$n_cols,
      Link     = link,
      stringsAsFactors = FALSE
    )
    datatable(tab, rownames = FALSE, filter = "top", escape = FALSE,
              options = list(pageLength = 25,
                             columnDefs = list(list(width = "48%", targets = 0))))
  })

  # ---- Source tables: picker filtered by type
  s_manifest <- reactive({
    m <- manifest
    if (!is.null(input$s_type) && input$s_type != "All")
      m <- m[m$id_type == input$s_type, ]
    m
  })

  observeEvent(s_manifest(), {
    m <- s_manifest()
    choices <- stats::setNames(m$file, m$picker)
    updateSelectizeInput(session, "s_pick", choices = choices, server = TRUE)
  })

  s_row <- reactive({
    req(input$s_pick)
    manifest[manifest$file == input$s_pick, , drop = FALSE][1, ]
  })

  # Source tables are fetched from GitHub on demand (with a local fallback if a
  # bundled copy happens to exist, e.g. during local development).
  s_data <- reactive({
    req(input$s_pick)
    d <- read_delim_gh(paste0(SRC_DIR, pct(input$s_pick)),
                       file.path(data_dir, "source-tables", input$s_pick),
                       required = FALSE)
    validate(need(!is.null(d),
                  "Could not load this table from GitHub. Check your connection and try again."))
    d
  })

  output$s_meta <- renderUI({
    r <- s_row()
    tagList(
      hr(),
      tags$dl(
        tags$dt("Citation"),   tags$dd(if (nzchar(r$citation)) r$citation else r$identifier),
        if (nzchar(r$table_label)) tagList(tags$dt("Table"), tags$dd(r$table_label)),
        tags$dt("Size"), tags$dd(paste0(r$n_rows, " rows × ", r$n_cols, " cols"))
      ),
      if (nzchar(r$url))
        tags$a(href = r$url, target = "_blank", class = "btn btn-outline-secondary btn-sm",
               paste0("Open ", r$identifier, " ↗"))
    )
  })

  output$s_readme <- renderUI({
    r <- s_row()
    if (is.null(r) || !nzchar(r$readme)) return(NULL)
    txt <- tryCatch(
      paste(readLines(url(paste0(GH_BASE, SRC_DIR, pct(r$readme))), warn = FALSE),
            collapse = "\n"),
      error = function(e) {
        p <- file.path(data_dir, "source-tables", r$readme)
        if (file.exists(p)) paste(readLines(p, warn = FALSE), collapse = "\n") else NULL
      })
    if (is.null(txt) || !nzchar(txt)) return(NULL)
    div(class = "alert alert-light border small", style = "white-space: pre-wrap;",
        strong("Source note:"), tags$br(), txt)
  })

  output$s_table <- renderDT({
    datatable(s_data(), rownames = FALSE, filter = "top",
              options = list(pageLength = 25, scrollX = TRUE))
  })

  output$s_download <- downloadHandler(
    filename = function() req(input$s_pick),
    content  = function(file)
      write.table(s_data(), file, sep = "\t", row.names = FALSE, quote = TRUE)
  )
}

shinyApp(ui, server)
