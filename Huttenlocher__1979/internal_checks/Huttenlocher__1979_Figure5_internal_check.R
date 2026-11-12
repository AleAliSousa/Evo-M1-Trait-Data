## Huttenlocher__1979_Figure5_internal_check.R -- cross-item check (build HOWTO 7b)
##
## Huttenlocher, P. R. (1979). Synaptic density in human frontal cortex: developmental
## changes and effects of aging. Brain Res. 163, 195-205. doi:10.1016/0006-8993(79)90349-4
##
## FIG. 5 (mean synapses per neuron vs age, open triangles) IS A DERIVED FIGURE: the caption says
## 'derived from data of the present study', and p. 202 states the value was calculated from packing
## density together with synaptic density -- i.e. Fig. 3 / Fig. 4. This check multiplies each triangle
## by the neuronal density plotted at the same abscissa in Fig. 4 (open circles) and asks whether the
## product is one of the 22 synaptic densities plotted in Fig. 3. It needs the Figure3 and Figure4
## snapshots, so it was moved out of Huttenlocher__1979_Figure5.R (which now reads only its own
## snapshot). Reads only the three snapshots; writes only
## Huttenlocher__1979_Figure5_internal_check.csv in this folder. Never changes a value; a mismatch
## is warned and kept as printed.

## 0. PATHS --------------------------------------------------------
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
check_dir <- dirname(.sp)                                 # <Paper>/internal_checks
folder    <- dirname(check_dir)                           # <Paper>
item_name <- sub("_internal_check$", "", tools::file_path_sans_ext(basename(.sp)))   # "Huttenlocher__1979_Figure5"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
check_csv    <- file.path(check_dir, paste0(item_name, "_internal_check.csv"))

## 1. LOAD (read-only) ------------------------------------------------
snap <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
f4 <- read.csv(file.path(folder, "Huttenlocher__1979_Figure4_snapshot.csv"),
               comment.char = "#", stringsAsFactors = FALSE)
f3 <- read.csv(file.path(folder, "Huttenlocher__1979_Figure3_snapshot.csv"),
               comment.char = "#", stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 10)
snap <- snap[order(snap$plot_symbol, snap$px_x), ]                  # as in Huttenlocher__1979_Figure5.R
Synapses_per_neuron.count <- snap$value_in_figure_units * 10000.0   # as in Huttenlocher__1979_Figure5.R

## 2. CHECKS ---------------------------------------------------------
## The check multiplies each Fig. 5 triangle by the neuronal density plotted at the same abscissa in
## Fig. 4 (open circles, left to right) and asks whether the product is one of the Fig. 3 densities.
f4o <- f4[f4$plot_symbol == "open_circle", ][order(f4$px_x[f4$plot_symbol == "open_circle"]), ]
implied <- Synapses_per_neuron.count * (f4o$value_in_figure_units * 1e4)   # synapses/neuron x neurons/mm3
nearest <- sapply(implied, function(v) f3$value_in_figure_units[which.min(abs(f3$value_in_figure_units * 1e8 - v))] * 1e8)
dev <- abs(implied - nearest) / 1e8
table_checks <- data.frame(
  check_id = c("derivation", "derivation_mean"),
  basis = c("max |Fig5 x Fig4 - nearest Fig3 value| (x 10^8 synapses/mm3); 0 if Fig. 5 = Fig. 3 / Fig. 4",
            "mean |Fig5 x Fig4 - nearest Fig3 value| (x 10^8 synapses/mm3)"),
  observed = c(round(max(dev), 2), round(mean(dev), 2)),
  printed = c(0, 0), tolerance = c(1.1, 0.4),
  note = c("the largest deviation is the 'Aged (74-90)' column, where Fig. 5 plots one mean but Fig. 3 plots four separate brains", ""),
  stringsAsFactors = FALSE)
table_checks$difference <- table_checks$observed - table_checks$printed
table_checks$status <- ifelse(abs(table_checks$difference) <= table_checks$tolerance, "pass", "mismatch")
table_checks <- table_checks[, c("check_id", "basis", "observed", "printed", "difference", "tolerance", "status", "note")]
print(table_checks[, c("check_id", "observed", "printed", "difference", "tolerance", "status")], row.names = FALSE)
if (any(table_checks$status != "pass")) warning("Figure5 derivation check not passed -- kept as printed.", call. = FALSE)
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
