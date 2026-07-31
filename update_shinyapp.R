# =============================================================================
# update_shinyapp.R  —  one program to update the Evo-M1 Shiny app from your
# own computer. Run it after you change any data (spreadsheets, merges, source
# tables) and it will:
#
#   1. BUILD   rebuild the two derived files + the offline fallback copies
#              (Rscript __ShinyApp/build_data.R)
#   2. PUSH    commit + push to GitHub  <-- this is what updates the LIVE data,
#              because the app reads its data straight from GitHub at runtime
#   3. DEPLOY  re-upload the app itself to shinyapps.io (only needed when app.R
#              or the fallback data changes; done by default to be safe)
#
# ---------------------------------------------------------------------------
# HOW TO RUN IT
# ---------------------------------------------------------------------------
#   • Easiest — double-click the launcher for your computer:
#         macOS    ->  Update_ShinyApp.command
#         Windows  ->  Update_ShinyApp.bat
#   • In a terminal, from anywhere:
#         Rscript "/full/path/to/update_shinyapp.R"
#   • In R / RStudio:
#         source("/full/path/to/update_shinyapp.R")
#
# It finds the repo folder on its own, so you never need to setwd() or cd.
#
# ---------------------------------------------------------------------------
# OPTIONS  (append to the Rscript / launcher command, in any order)
# ---------------------------------------------------------------------------
#   --no-deploy   just refresh the data on GitHub; skip the shinyapps.io upload
#                 (use this for a plain data update — the live app picks it up)
#   --no-push     rebuild + deploy but do NOT commit/push to GitHub
#   --no-build    skip the data rebuild (deploy/push what is already on disk)
#   --any-branch  allow the push step to run off `main` (see SAFETY below)
#   --help        show this list and exit
#
# ---------------------------------------------------------------------------
# SAFETY — what the push step will and will not commit
# ---------------------------------------------------------------------------
#   • It refuses to run unless you are on `main`. The live app reads its data
#     from `main`, so a push to a feature branch looks like it worked but
#     changes nothing users see. Override with --any-branch if you really mean
#     to refresh data on a side branch.
#   • It stages only files git already tracks, plus __ShinyApp/data. Untracked
#     files (new PDFs, stray copies, .claude/, scratch output) are listed for
#     you and left alone — add those deliberately with `git add` yourself.
#
# ---------------------------------------------------------------------------
# ONE-TIME SETUP  (only ever needed once on a new computer)
# ---------------------------------------------------------------------------
#   1. Install R:  https://cran.r-project.org
#   2. Get a shinyapps.io token: log in at https://www.shinyapps.io ->
#      Account -> Tokens -> Show -> "Show secret" -> Copy to clipboard.
#      Paste the copied line into R once, e.g.:
#          rsconnect::setAccountInfo(name="...", token="...", secret="...")
#      (This script installs rsconnect for you and reminds you if it's missing.)
#   Any R packages that are missing are installed automatically the first time.
# =============================================================================

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || is.na(a[1])) b else a

# ---- pretty logging ---------------------------------------------------------
.step <- function(...) message("\n==> ", ...)
.ok   <- function(...) message("    ✓ ", ...)
.warn <- function(...) message("    ! ", ...)
.die  <- function(...) stop(paste0(...), call. = FALSE)

# ---- parse command-line flags (work under Rscript and source()) -------------
.argv <- commandArgs(trailingOnly = TRUE)
if ("--help" %in% .argv || "-h" %in% .argv) {
  .self <- sub("^--file=", "",
               grep("^--file=", commandArgs(FALSE), value = TRUE)[1] %||% "")
  .txt  <- if (nzchar(.self)) readLines(.self) else character(0)
  # print the whole banner comment: up to the closing ==== rule
  .end  <- grep("^# =====", .txt)
  cat(utils::head(.txt, if (length(.end) > 1) .end[2] else length(.txt)), sep = "\n")
  quit(save = "no", status = 0)
}
DO_BUILD   <- !("--no-build"  %in% .argv)
DO_PUSH    <- !("--no-push"   %in% .argv)
DO_DEPLOY  <- !("--no-deploy" %in% .argv)
ANY_BRANCH <-  ("--any-branch" %in% .argv)
PUSH_BRANCH <- "main"                 # the branch the live app reads from

# ---- locate the repo root (this script lives at the repo root) --------------
find_repo <- function() {
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)          # Rscript
  if (length(a)) return(normalizePath(dirname(sub("^--file=", "", a[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {                                 # RStudio Source
    p <- tryCatch(rstudioapi::getSourceEditorContext()$path, error = function(e) "")
    if (nzchar(p)) return(normalizePath(dirname(p)))
  }
  # last resort: the current working directory, if it looks like the repo
  if (dir.exists(file.path(getwd(), "__ShinyApp"))) return(normalizePath(getwd()))
  .die("Could not locate the repo folder. Run this script from inside the ",
       "Evo-M1-Trait-Data folder, or double-click Update_ShinyApp.command / .bat.")
}
REPO    <- find_repo()
APP_DIR <- file.path(REPO, "__ShinyApp")
if (!dir.exists(APP_DIR))
  .die("No __ShinyApp folder found under: ", REPO,
       "\n    This script must sit at the top of the Evo-M1-Trait-Data folder.")
message("Repo folder: ", REPO)

# ---- make sure required R packages are present (install missing ones) --------
ensure_pkgs <- function(pkgs, why) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (!length(missing)) return(invisible())
  .step("Installing missing R package(s) for ", why, ": ",
        paste(missing, collapse = ", "))
  repos <- getOption("repos")
  if (is.null(repos) || is.na(repos["CRAN"]) || repos["CRAN"] == "@CRAN@")
    repos <- c(CRAN = "https://cloud.r-project.org")
  install.packages(missing, repos = repos)
  still <- missing[!vapply(missing, requireNamespace, logical(1), quietly = TRUE)]
  if (length(still))
    .die("Could not install: ", paste(still, collapse = ", "),
         "\n    Install it by hand in R:  install.packages(c(",
         paste(sprintf('\"%s\"', still), collapse = ", "), "))")
}

# ---- 1. BUILD ---------------------------------------------------------------
if (DO_BUILD) {
  ensure_pkgs("readxl", "the data rebuild")
  .step("1/3  Rebuilding derived data (build_data.R) …")
  rc <- system2(file.path(R.home("bin"), "Rscript"),
                shQuote(file.path(APP_DIR, "build_data.R")))
  if (rc != 0)
    .die("build_data.R failed (see the error above). Nothing was pushed or ",
         "deployed. Fix the data problem and re-run.")
  .ok("Derived data rebuilt.")
} else .step("1/3  Skipping data rebuild (--no-build).")

# ---- 2. PUSH to GitHub (this updates the LIVE app's data) --------------------
git <- function(...) suppressWarnings(
  system2("git", c("-C", shQuote(REPO), ...), stdout = TRUE, stderr = TRUE))

if (DO_PUSH) {
  if (Sys.which("git") == "")
    .die("git is not installed. Install it from https://git-scm.com and re-run, ",
         "or use --no-push to skip this step.")
  .step("2/3  Committing + pushing to GitHub …")

  # -- guard 1: only push from the branch the live app actually reads ----------
  branch <- git("rev-parse", "--abbrev-ref", "HEAD")[1]
  if (!identical(branch, PUSH_BRANCH)) {
    if (!ANY_BRANCH)
      .die("You are on branch '", branch, "', not '", PUSH_BRANCH, "'.\n",
           "    The live app reads its data from '", PUSH_BRANCH, "', so pushing ",
           "here would not update it.\n",
           "    Either switch branches:   git checkout ", PUSH_BRANCH, "\n",
           "    or skip this step:        --no-push\n",
           "    or push here on purpose:  --any-branch")
    .warn("Pushing to '", branch, "', not '", PUSH_BRANCH,
          "' (--any-branch). The LIVE app will not change.")
  }

  # -- guard 2: stage tracked edits + derived data only, never stray files -----
  invisible(git("add", "-u"))                       # tracked modifications only
  invisible(git("add", "--", "__ShinyApp/data"))    # derived outputs, incl. new
  # whatever is still untracked after staging is genuinely being left behind
  untracked <- git("ls-files", "--others", "--exclude-standard")
  untracked <- untracked[nzchar(untracked)]
  if (length(untracked)) {
    .warn("Leaving ", length(untracked), " untracked file(s) out of this commit:")
    for (f in utils::head(untracked, 10)) message("        ", f)
    if (length(untracked) > 10)
      message("        … and ", length(untracked) - 10, " more")
    .warn("Add any of these yourself with `git add <file>` if they belong.")
  }

  staged <- git("diff", "--cached", "--quiet")               # exit 1 if changes
  if (!is.null(attr(staged, "status")) && attr(staged, "status") != 0) {
    files <- git("diff", "--cached", "--name-only")
    files <- files[nzchar(files)]
    .ok("Staged ", length(files), " file(s):")
    for (f in utils::head(files, 10)) message("        ", f)
    if (length(files) > 10) message("        … and ", length(files) - 10, " more")
    msg <- paste0("Refresh Shiny app data ", format(Sys.time(), "%Y-%m-%d %H:%M"))
    invisible(git("commit", "-m", shQuote(msg)))
    .ok("Committed: ", msg)
  } else .ok("No data changes to commit — repo already current.")

  # push current branch to its upstream, with a few retries for flaky networks
  pushed <- FALSE
  for (attempt in 1:4) {
    out <- git("push")
    if (is.null(attr(out, "status")) || attr(out, "status") == 0) { pushed <- TRUE; break }
    .warn("push attempt ", attempt, " failed; retrying in ", 2^attempt, "s …")
    Sys.sleep(2^attempt)
  }
  if (pushed) .ok("Pushed to GitHub — the live app now serves the new data.")
  else .warn("Could not push to GitHub after 4 tries. Check your connection / ",
             "credentials and run `git push` by hand. (Deploy will still proceed.)")
} else .step("2/3  Skipping GitHub push (--no-push).")

# ---- 3. DEPLOY the app to shinyapps.io --------------------------------------
if (DO_DEPLOY) {
  ensure_pkgs(c("rsconnect", "shiny", "bslib", "DT", "ggplot2"),
              "the shinyapps.io deploy")
  .step("3/3  Deploying to shinyapps.io …")
  accts <- tryCatch(rsconnect::accounts(), error = function(e) NULL)
  if (is.null(accts) || nrow(accts) == 0) {
    .warn("No shinyapps.io account is configured on this computer yet.")
    message(
      "    The data was refreshed on GitHub, but the app was NOT re-deployed.\n",
      "    To finish one-time setup, run this once in R (get the exact line from\n",
      "    shinyapps.io -> Account -> Tokens -> Show -> \"Show secret\"):\n\n",
      "        rsconnect::setAccountInfo(name=\"...\", token=\"...\", secret=\"...\")\n\n",
      "    then re-run this updater.")
  } else {
    rsconnect::deployApp(
      appDir      = APP_DIR,
      appName     = "evo-m1-brain-traits",
      appTitle    = "Evo-M1 Comparative Brain-Trait Data",
      forceUpdate = TRUE
    )
    .ok("Deployed. The public URL is printed just above ",
        "(…shinyapps.io/evo-m1-brain-traits/).")
  }
} else .step("3/3  Skipping shinyapps.io deploy (--no-deploy).")

.step("All done ✅")
