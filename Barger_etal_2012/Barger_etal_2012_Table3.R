## Barger et al. (2012) J. Comp. Neurol. 520(13):3035-3054
## Table 3 — average amygdala neuron numbers per nucleus per species (stereology)
## Corrected build script: frozen snapshot -> analysis CSV (+ public TSV)

## 0. PATHS -- self-contained ------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})

folder       <- dirname(.sp)
item_name    <- tools::file_path_sans_ext(basename(.sp))
dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. READ FROZEN SNAPSHOT ---------------------------------------------------
snap <- as.data.frame(
  read_excel(snapshot_xlsx, sheet = "Table3", .name_repair = "minimal"),
  check.names = FALSE
)

## 3. REFORMAT -> species rows, absolute counts ------------------------------
species <- sub("_millions_mean_SD$", "", names(snap)[-1])

acc <- c(
  Human = "Homo sapiens",
  Chimpanzee = "Pan troglodytes",
  Bonobo = "Pan paniscus",
  Gorilla = "Gorilla gorilla",
  Orangutan = "Pongo pygmaeus",
  Gibbon = "Hylobatidae sp.",
  Macaque = "Macaca fascicularis"
)

n_spec <- c(Human = 11, Chimpanzee = 5, Bonobo = 4, Gorilla = 5,
            Orangutan = 4, Gibbon = 3, Macaque = 3)

concept <- c(
  Orangutan = "Pongo pygmaeus (s.l.); island/subspecies not stated; pooled n=4",
  Gibbon = "POOLED Hylobatidae: H. muelleri + white-cheeked (Nomascus) + H. lar; decomposable=FALSE"
)

parse_ms <- function(x) {
  x <- as.character(x)
  m  <- as.numeric(sub("\\s*\\(.*$", "", x))
  sd <- as.numeric(gsub(".*\\(([-0-9.]+)\\).*", "\\1", x))
  c(mean = m, sd = sd)
}

out <- data.frame(
  Species = unname(acc[species]),
  Species_Barger2012 = species,
  n_specimens = unname(n_spec[species]),
  taxon_concept = ifelse(species %in% names(concept), unname(concept[species]), ""),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

## Each snapshot row is one nucleus; columns 2:n are the seven species.
for (i in seq_len(nrow(snap))) {
  nuc  <- snap$ROI_nucleus[i]
  vals <- as.character(unlist(snap[i, -1], use.names = FALSE))
  ms   <- t(vapply(vals, parse_ms, numeric(2)))

  stopifnot(nrow(ms) == nrow(out))

  out[[paste0(nuc, "_neurons")]]    <- round(ms[, "mean"] * 1e6)
  out[[paste0(nuc, "_neurons_SD")]] <- round(ms[, "sd"] * 1e6)
}

## 4. WRITE OUTPUTS ----------------------------------------------------------
write.csv(out, final_csv, row.names = FALSE, na = "")

if (!is.na(dataset_root)) {
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(
    out,
    file.path(public_tsv_dir, paste0(item_name, ".tsv")),
    sep = "\t", row.names = FALSE, quote = FALSE, na = ""
  )
}

message("Wrote: ", final_csv)
