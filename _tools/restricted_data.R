## =============================================================================
## _tools/restricted_data.R  --  resolve the PRIVATE companion repo from this one
## =============================================================================
##
## A few builds in this public repository read a source file that cannot be published:
## data another researcher supplied privately, or unpublished material shared by email.
## Those files live in the private repo **Evo-M1-Traits-Data-restricted** (see
## __COMPARISON_MOVED.md), and the build scripts reach them through this helper rather
## than through a hardcoded path.
##
##   source(file.path(base, "_tools", "restricted_data.R"))
##   f <- evom1_restricted_file("unpublished_data/____Unpublished__DosSantos_microglia_2024",
##                              "2020-PublishedDataMammalsMicroglia - cópia.xlsx")
##
## Resolution order for the private repo:
##   1. the EVOM1_RESTRICTED environment variable (set it in ~/.Renviron)
##   2. the default side-by-side layout: <parent of this repo's parent>/Evo-M1-Traits-Data-restricted
##   3. a plain sibling of this repo
## It is identified by its own _paths.R. If it is not mounted, evom1_restricted() returns
## NA (with a warning) so a caller can degrade gracefully, and evom1_restricted_file()
## stops with a message naming the file it needed — never a silent wrong path.
##
## NOTE ON PUBLISHING. A build that reads a restricted source produces a derived table in
## this public repo. Whether that derivative may be public is a per-source permission
## question, not a technical one. Each such source carries a ReadMe in the private repo
## stating the conditions it was shared under; check it before publishing anything built
## from it.
## =============================================================================

evom1_restricted <- function(quiet = FALSE) {
  is_res <- function(p) !is.na(p) && nzchar(p) && file.exists(file.path(p, "_paths.R"))

  env <- Sys.getenv("EVOM1_RESTRICTED", "")
  if (nzchar(env)) {
    env <- path.expand(env)
    if (is_res(env)) return(normalizePath(env))
    if (!quiet) warning("EVOM1_RESTRICTED is set to '", env, "' but no _paths.R is there.")
  }

  here <- local({                      # this repo's root: nearest ancestor with __ReadMe.xlsx
    d <- normalizePath(getwd(), mustWork = FALSE)
    a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(a)) d <- dirname(normalizePath(sub("^--file=", "", a[1])))
    while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
    if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
  })
  if (!is.na(here)) {
    for (cand in c(file.path(dirname(dirname(here)), "Evo-M1-Traits-Data-restricted"),
                   file.path(dirname(here), "Evo-M1-Traits-Data-restricted"))) {
      if (is_res(cand)) return(normalizePath(cand))
    }
  }
  if (!quiet) warning("The private repo Evo-M1-Traits-Data-restricted is not mounted; ",
                      "set EVOM1_RESTRICTED or clone it beside this one.")
  NA_character_
}

## Full path to a file inside the private repo. Stops if the repo or the file is missing.
evom1_restricted_file <- function(..., must_exist = TRUE) {
  root <- evom1_restricted(quiet = TRUE)
  rel <- file.path(...)
  if (is.na(root)) {
    stop("This build needs a restricted source file (", rel, ") that lives in the private repo\n",
         "  Evo-M1-Traits-Data-restricted, which is not currently reachable.\n",
         "  Set EVOM1_RESTRICTED=/path/to/Evo-M1-Traits-Data-restricted (or add it to ~/.Renviron).",
         call. = FALSE)
  }
  p <- file.path(root, rel)
  if (must_exist && !file.exists(p)) {
    stop("Restricted source file not found: ", p, call. = FALSE)
  }
  p
}
