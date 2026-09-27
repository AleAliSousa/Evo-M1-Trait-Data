#!/usr/bin/env Rscript
# =============================================================================
# build_trait_authority.R
#
# Regenerate _keys/trait_authority.csv: for every app-facing variable label,
# WHICH REPO FOLDER holds the authoritative value.
#
# Why the key exists. Authority used to be implicit: app.R's label_for() picks
# whichever spelling happens to exist among the loaded labels, so which merge
# "wins" was a side effect of how that merge spelled its output.
# variable_canonical.csv lists only the exceptions, and its `superseded_by`
# column -- which reads like the declaration -- is not consulted by any code.
# This key states the answer for every label, and _checks/check_trait_authority.R
# enforces it.
#
# `basis` records how each row got its authority, and the three values are NOT
# interchangeable:
#   auto_single_producer             one producer, so no decision to make
#   adopted_from_variable_canonical  taken from an existing superseded_by
#   adjudicated                      a human decided; NEVER overwritten here
#
# Run:  Rscript _keys/build_trait_authority.R [--dry-run]
# Then: Rscript _checks/check_trait_authority.R
# =============================================================================

args <- commandArgs(trailingOnly = TRUE); dry_run <- "--dry-run" %in% args
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
keys_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg[1]))) else getwd()
repo     <- normalizePath(file.path(keys_dir, ".."))
out_path <- file.path(keys_dir, "trait_authority.csv")

# ---- the label -> producer map comes from the app's own loader --------------
# Deriving it any other way would mean a second implementation of load_compiled()
# that could disagree with the app. Everything above the shinyApp() call is
# definitions and data loading, so evaluating that prefix yields `compiled`
# without starting a server.
app_file <- file.path(repo, "__ShinyApp", "app.R")
if (!file.exists(app_file)) stop("Cannot find __ShinyApp/app.R at ", app_file)
src <- readLines(app_file, warn = FALSE)
cut <- grep("^shinyApp\\(", src)
if (length(cut) != 1)
  stop("Expected exactly one top-level shinyApp( call in app.R, found ", length(cut),
       ". The prefix-evaluation trick below depends on it.")
suppressPackageStartupMessages({library(shiny); library(bslib); library(DT); library(ggplot2)})
app_env <- new.env(parent = globalenv())
old_wd <- setwd(file.path(repo, "__ShinyApp")); on.exit(setwd(old_wd), add = TRUE)
if (!nzchar(Sys.getenv("EVOM1_SOURCE"))) Sys.setenv(EVOM1_SOURCE = "local")
eval(parse(text = paste(src[seq_len(cut - 1)], collapse = "\n")), envir = app_env)
setwd(old_wd)
compiled <- get("compiled", envir = app_env)
if (!nrow(compiled)) stop("app.R produced an empty compiled table.")

# Dataset display name -> the repo folder that produces it.
DS <- c(
  "Brain-structure volumes"  = "__merging_volumes",
  "Cell counts"              = "__merging_cellcounts",
  "EvoM1 traits"             = "____EvoM1_TraitTable (melted)",
  "Body & ecology"           = "__merging_body_ecology",
  "Brain mass"               = "__merging_brain_mass",
  "Behaviour"                = "__merging_behaviour",
  "Brain-part weights"       = "__merging_weights",
  "Endocranial volume"       = "__merging_endocranial_volume",
  "Cerebellar folding"       = "__merging_cerebellar_folding",
  "Cerebral metabolic rate"  = "__merging_cerebral_metabolic_rate",
  "Grey-level index"         = "__merging_GLI",
  "Cortical areas & surfaces"= "__merging_cortical_areas",
  "Cortical layer thickness" = "__merging_cortical_layers",
  "Fossil brain glucose"     = "__merging_fossil_brain_glucose",
  "Gyrification (GI)"        = "__merging_gyrification",
  "Sensory performance"      = "__merging_sensory"
)
seen <- unique(compiled$Dataset)
unmapped <- setdiff(seen, names(DS))
if (length(unmapped))
  stop("Dataset(s) with no folder mapping: ", paste(unmapped, collapse = ", "),
       "\nAdd them to DS in this script -- an unmapped dataset would silently ",
       "become its own bogus 'authority'.")

pairs <- unique(compiled[, c("Variable", "Dataset")])
pairs$folder <- unname(DS[pairs$Dataset])
prod <- tapply(pairs$folder, pairs$Variable, function(x) paste(sort(unique(x)), collapse = "; "))
nprod <- tapply(pairs$folder, pairs$Variable, function(x) length(unique(x)))
labels <- names(prod)

# ---- existing declarations: superseded_by on supersede rows -----------------
rd <- function(p) read.csv(p, stringsAsFactors = FALSE, check.names = FALSE,
                           colClasses = "character", encoding = "UTF-8")
canon <- rd(file.path(keys_dir, "variable_canonical.csv"))
canon <- canon[trimws(canon$action) == "supersede" & nzchar(trimws(canon$superseded_by)), ]
declared <- list()
for (i in seq_len(nrow(canon))) {
  lab <- canon$canonical_variable[i]
  if (!(lab %in% labels)) lab <- paste0(canon$canonical_variable[i], " (", canon$canonical_unit[i], ")")
  declared[[lab]] <- unique(c(declared[[lab]], trimws(canon$superseded_by[i])))
}

prev <- if (file.exists(out_path)) rd(out_path) else NULL

rows <- lapply(labels, function(lab) {
  folders <- strsplit(prod[[lab]], "; ")[[1]]
  keep <- if (!is.null(prev)) prev[prev$label == lab & prev$basis == "adjudicated", , drop = FALSE] else NULL
  if (!is.null(keep) && nrow(keep)) {          # human decisions are never regenerated
    auth <- keep$authority[1]; basis <- "adjudicated"; note <- keep$note[1]
  } else if (nprod[[lab]] == 1) {
    auth <- folders[1]; basis <- "auto_single_producer"; note <- ""
  } else if (!is.null(declared[[lab]]) && length(declared[[lab]]) == 1) {
    auth <- declared[[lab]]; basis <- "adopted_from_variable_canonical"
    note <- "authority already declared by superseded_by; adopted unchanged"
  } else {
    auth <- ""; basis <- "NEEDS_DECISION"
    note <- "two or more producers and no existing declaration -- set authority and basis=adjudicated"
  }
  data.frame(label = lab, authority = auth, basis = basis, status = "active",
             n_producers = nprod[[lab]], all_producers = prod[[lab]],
             other_producers = paste(setdiff(folders, auth), collapse = "; "),
             note = note, stringsAsFactors = FALSE)
})
out <- do.call(rbind, rows)
out <- out[order(out$label), ]

if (!is.null(prev)) {
  lost <- setdiff(prev$label[prev$basis == "adjudicated"], out$label[out$basis == "adjudicated"])
  if (length(lost))
    stop("Adjudicated row(s) would be lost: ", paste(lost, collapse = ", "),
         "\nThese labels no longer appear in the app. Remove them deliberately, ",
         "do not let a regeneration drop a human decision.")
}

message("labels: ", nrow(out))
print(table(out$basis))
nd <- sum(out$basis == "NEEDS_DECISION")
if (nd) message("\n", nd, " label(s) need a decision -- see basis = NEEDS_DECISION.")
if (dry_run) { message("\n--dry-run: nothing written."); quit(save = "no") }

# BOM + raw UTF-8 bytes: Rscript often runs in the C locale, where write.csv
# turns accented source names into "<U+00E4>" escapes.
fld <- function(x) { x <- ifelse(is.na(x), "", as.character(x))
                     n <- grepl('[",\n\r]', x); x[n] <- paste0('"', gsub('"', '""', x[n]), '"'); x }
lines <- c(paste(fld(names(out)), collapse = ","),
           do.call(paste, c(lapply(out, fld), sep = ",")))
con <- file(out_path, open = "wb")
writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), con)
close(con)
message("\nwrote ", out_path)
