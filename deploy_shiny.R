# =============================================================================
# Deploy the Evo-M1 Shiny app from ANY R working directory — no setwd() needed.
#
# Usage (either one):
#   • In R / RStudio:  source("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/deploy_shiny.R")
#   • In a terminal:   Rscript "/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/deploy_shiny.R"
#
# It uses ABSOLUTE paths, so the "appDir '__ShinyApp' does not exist" error
# (caused by R's working directory not being the repo root) cannot happen.
#
# ONE-TIME SETUP (once ever): install.packages(c("readxl","rsconnect")); then
# rsconnect::setAccountInfo(name="...", token="...", secret="...")  # from shinyapps.io
# =============================================================================

# --- Find the repo root: auto-detect from this script's own location, and if
#     that isn't possible, fall back to the hard-coded absolute path below. -----
.repo <- tryCatch({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)          # Rscript path
  if (length(a)) {
    normalizePath(dirname(sub("^--file=", "", a[1])))
  } else if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    normalizePath(dirname(rstudioapi::getSourceEditorContext()$path))  # RStudio Source
  } else stop("no path")
}, error = function(e)
  "/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data")

app_dir <- file.path(.repo, "__ShinyApp")
message("Repo root: ", .repo)
stopifnot(dir.exists(app_dir))

# --- 1. Rebuild the derived data. Run as a subprocess so build_data.R resolves
#        its own paths correctly regardless of the working directory. ----------
message("==> Rebuilding derived data (build_data.R) …")
if (system2("Rscript", shQuote(file.path(app_dir, "build_data.R"))) != 0)
  stop("build_data.R failed — fix the error above and re-run.")

# --- 2. Deploy to shinyapps.io using the ABSOLUTE appDir. ---------------------
message("==> Deploying to shinyapps.io …")
rsconnect::deployApp(
  appDir      = app_dir,
  appName     = "evo-m1-brain-traits",
  appTitle    = "Evo-M1 Comparative Brain-Trait Data",
  forceUpdate = TRUE
)
message("Done — the public URL is printed above.")

# NOTE: this deploys the app + its local data/ fallback. The LIVE data is read
# from GitHub, so also commit + push your changes (or just run deploy_shiny.command,
# which does the git push for you).
