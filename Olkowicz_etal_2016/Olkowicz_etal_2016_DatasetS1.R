# Olkowicz et al. 2016 Dataset S1: avian brain cellular composition.

suppressPackageStartupMessages({
  library(readxl)
})

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
root_dir <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

source_archive <- file.path(paper_dir, "pnas.1517131113.sd01.source.zip")
archive_md5 <- unname(tools::md5sum(source_archive))
if (!identical(archive_md5, "4ea82db38d2f673ed7f3588b0f2caa50")) {
  stop("Unexpected source-archive checksum: ", archive_md5)
}
extract_dir <- tempfile("olkowicz_dataset_s1_")
dir.create(extract_dir)
on.exit(unlink(extract_dir, recursive = TRUE), add = TRUE)
unzip(source_archive, files = "pnas.1517131113.sd01.xlsx", exdir = extract_dir)
source_file <- file.path(extract_dir, "pnas.1517131113.sd01.xlsx")
source_md5 <- unname(tools::md5sum(source_file))
if (!identical(source_md5, "0b0454f3d3da43e405fb5d444f9a0e4f")) {
  stop("Unexpected workbook checksum inside source archive: ", source_md5)
}

core <- c("mass_g", "cell_count", "neuron_count", "nonneuronal_cell_count")
partition <- c(core, "neuronal_cell_percent", "neuron_density_per_mg",
               "nonneuronal_cell_density_per_mg", "brain_mass_percent",
               "brain_neuron_percent", "brain_nonneuronal_cell_percent")
density <- c(core, "neuron_density_per_mg", "nonneuronal_cell_density_per_mg")
rest_metrics <- c(density, "brain_mass_percent", "brain_neuron_percent",
                  "brain_nonneuronal_cell_percent")
groups <- list(
  list(prefix = "whole_brain", structure = "WholeBrain", metrics = core),
  list(prefix = "telencephalon", structure = "Telencephalon", metrics = partition),
  list(prefix = "pallium", structure = "Pallium", metrics = density),
  list(prefix = "subpallium", structure = "Subpallium", metrics = density),
  list(prefix = "tectum", structure = "Tectum", metrics = partition),
  list(prefix = "diencephalon", structure = "Diencephalon", metrics = partition),
  list(prefix = "cerebellum", structure = "Cerebellum", metrics = partition),
  list(prefix = "brainstem", structure = "Brainstem", metrics = partition),
  list(prefix = "rest_of_brain", structure = "RestOfBrain", metrics = rest_metrics)
)
metric_meta <- do.call(rbind, lapply(groups, function(g) {
  data.frame(Code = paste(g$prefix, g$metrics, sep = "_"),
             Structure = g$structure, suffix = g$metrics,
             stringsAsFactors = FALSE)
}))
stopifnot(nrow(metric_meta) == 75L)

raw <- as.data.frame(read_excel(source_file, sheet = "List1", skip = 2,
                                col_names = FALSE, .name_repair = "minimal"),
                     stringsAsFactors = FALSE)
source_names <- c("common_name_printed", "scientific_name_printed", "order_printed",
                  "body_mass_g", metric_meta$Code)
stopifnot(nrow(raw) == 28L, ncol(raw) == length(source_names))
names(raw) <- source_names

final.dataframe <- data.frame(
  source_row = seq_len(nrow(raw)),
  Species_Olkowicz2016_common = raw$common_name_printed,
  Species_Olkowicz2016 = raw$scientific_name_printed,
  order_printed = raw$order_printed,
  Class = "Aves",
  raw[c("body_mass_g", metric_meta$Code)],
  check.names = FALSE,
  stringsAsFactors = FALSE
)

numeric_cols <- c("body_mass_g", metric_meta$Code)
if (any(vapply(final.dataframe[numeric_cols], function(x) any(is.na(x) | x <= 0), logical(1)))) {
  stop("Dataset S1 measurements must be complete and positive")
}
for (g in groups) {
  p <- g$prefix
  residual <- final.dataframe[[paste0(p, "_cell_count")]] -
    final.dataframe[[paste0(p, "_neuron_count")]] -
    final.dataframe[[paste0(p, "_nonneuronal_cell_count")]]
  scale <- final.dataframe[[paste0(p, "_cell_count")]]
  if (max(abs(residual) / scale) > 1e-12) stop("Cell partition failed for ", p)
}
whole_components <- c("telencephalon", "tectum", "diencephalon", "cerebellum", "brainstem")
for (suffix in core) {
  component_sum <- rowSums(final.dataframe[paste0(whole_components, "_", suffix)])
  whole <- final.dataframe[[paste0("whole_brain_", suffix)]]
  if (max(abs(whole - component_sum) / whole) > 1e-12) {
    stop("Whole-brain component check failed for ", suffix)
  }
  tel_sum <- final.dataframe[[paste0("pallium_", suffix)]] +
    final.dataframe[[paste0("subpallium_", suffix)]]
  tel <- final.dataframe[[paste0("telencephalon_", suffix)]]
  if (max(abs(tel - tel_sum) / tel) > 1e-12) {
    stop("Telencephalon partition check failed for ", suffix)
  }
}
percent_cols <- grep("_percent$", names(final.dataframe), value = TRUE)
if (any(vapply(final.dataframe[percent_cols], function(x) any(x < 0 | x > 100), logical(1)))) {
  stop("Percentage outside 0–100")
}

local_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, local_csv, row.names = FALSE, na = "")

registry <- read_excel(file.path(root_dir, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  stop("No cached Item encoded value for ", item_name, " in __ReadMe.xlsx")
}
public_tsv <- file.path(root_dir, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, public_tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "")

# Build the variable dictionary from the same ordered mapping as the data.
headers <- as.data.frame(read_excel(source_file, sheet = "List1", range = "A1:CA2",
                                    col_names = FALSE, .name_repair = "minimal"),
                         stringsAsFactors = FALSE)
group_header <- as.character(headers[1, ])
for (i in seq_along(group_header)) {
  if (is.na(group_header[i]) || !nzchar(group_header[i])) group_header[i] <- group_header[i - 1L]
}
sub_header <- as.character(headers[2, ])
source_header <- trimws(paste(group_header, ifelse(is.na(sub_header), "", sub_header)))
source_header <- source_header[5:79]

metric_definition <- function(structure, suffix) {
  s <- tolower(gsub("([a-z])([A-Z])", "\\1 \\2", structure))
  switch(suffix,
    mass_g = paste("mean", s, "mass"),
    cell_count = paste("mean estimated total cell number in", s),
    neuron_count = paste("mean estimated neuron number in", s),
    nonneuronal_cell_count = paste("mean estimated non-neuronal cell number in", s),
    neuronal_cell_percent = paste("mean percentage of", s, "cells labelled NeuN-positive"),
    neuron_density_per_mg = paste("mean neuron density in", s),
    nonneuronal_cell_density_per_mg = paste("mean non-neuronal cell density in", s),
    brain_mass_percent = paste("mean percentage of whole-brain mass in", s),
    brain_neuron_percent = paste("mean percentage of whole-brain neurons in", s),
    brain_nonneuronal_cell_percent = paste("mean percentage of whole-brain non-neuronal cells in", s)
  )
}
metric_measure <- c(
  mass_g = "Mass.g", cell_count = "Cells.n", neuron_count = "N.n",
  nonneuronal_cell_count = "O.n", neuronal_cell_percent = "pct.NeuN",
  neuron_density_per_mg = "N.p.mg", nonneuronal_cell_density_per_mg = "O.p.mg",
  brain_mass_percent = "pct.brain.mass", brain_neuron_percent = "pct.brain.N",
  brain_nonneuronal_cell_percent = "pct.brain.O"
)
defs_info <- data.frame(
  Code = c("source_row", "Species_Olkowicz2016_common", "Species_Olkowicz2016",
           "order_printed", "Class", "body_mass_g"),
  Definition = c("row number in Dataset S1", "common species name printed in Dataset S1",
                 "scientific species name printed in Dataset S1", "avian order printed in Dataset S1",
                 "vertebrate class", "mean body mass"),
  Structure = c("", "", "", "", "", "Body"),
  Measure = c("", "", "", "Class", "Class", "Mass.g"),
  Stat = c("", "", "", "", "", "mean"),
  role = c("info", "info", "info", "info", "info", "primary"),
  taxon = "Aves", Reference = item_name,
  Note = c("1–28", "preserved verbatim", "preserved verbatim; not yet resolved through a bird taxonomy backbone",
           "preserved verbatim", "explicit non-mammal gate", "species mean over available individuals"),
  `Source Note` = c("", "Species Common name", "Species Scientific name", "Order", "", "Body mass (g)"),
  check.names = FALSE, stringsAsFactors = FALSE
)
defs_metrics <- data.frame(
  Code = metric_meta$Code,
  Definition = mapply(metric_definition, metric_meta$Structure, metric_meta$suffix,
                      USE.NAMES = FALSE),
  Structure = metric_meta$Structure,
  Measure = unname(metric_measure[metric_meta$suffix]),
  Stat = "mean", role = "primary", taxon = "Aves", Reference = item_name,
  Note = "species mean over available individuals; isotropic fractionator",
  `Source Note` = source_header,
  check.names = FALSE, stringsAsFactors = FALSE
)
defs_method <- data.frame(
  Code = "Method:isotropic_fractionator",
  Definition = "cell and neuron counts estimated by isotropic fractionation with NeuN immunocytochemistry",
  Structure = "", Measure = "", Stat = "", role = "method", taxon = "Aves",
  Reference = item_name,
  Note = "avian shelf dataset; not wired into the mammal-only compiled merge",
  `Source Note` = "Dataset S1", check.names = FALSE, stringsAsFactors = FALSE
)
definitions <- rbind(defs_info, defs_metrics, defs_method)
defs_dir <- file.path(paper_dir, "reference_tables")
dir.create(defs_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(definitions, file.path(defs_dir, paste0(item_name, "_definitions.csv")),
          row.names = FALSE, na = "")
message("Wrote ", local_csv, ", ", public_tsv, " and definitions (",
        nrow(final.dataframe), " species; ", ncol(final.dataframe), " columns)")
