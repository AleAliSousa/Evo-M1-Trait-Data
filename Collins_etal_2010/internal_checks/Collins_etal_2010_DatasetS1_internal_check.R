## Collins_etal_2010_DatasetS1_internal_check.R -- internal check (build HOWTO 7b)
##
## Collins, C. E., Airey, D. C., Young, N. A., Leitch, D. B., & Kaas, J. H. (2010). Neuron densities vary across and within cortical areas in primates. Proceedings of the National Academy of Sciences, 107(36), 15927-15932. https://doi.org/10.1073/pnas.1010356107
##
## QUESTION. Dataset S1 gives the counts for every tissue sample of one cortical hemisphere of
## five animals and prints no totals. The paper's running text gives whole-hemisphere figures.
## For three cases the sum of the samples is the text figure. For two it is not: macaque 08-59
## (text "nearly 3.5 billion" cells, "1.4 billion" neurons) and galago 07-104 (text 2,261 mm2,
## "approximately 326 million" cells, 127 million neurons). Is the supplement complete and
## internally consistent for those two cases, and which figures does the rest of the paper support?
##
## WHAT IS CHECKED, per case (check_id starts with the case number):
##   samples                 rows in the supplement vs the number of samples the text gives
##   *_sum_vs_text           sum of cells, neurons, surface area, tissue weight vs the text figure
##                           (tolerance 1 % of the text figure; the note gives the % difference)
##   cells_density_x_weight  samples whose total_cells differs from cells per g x weight by > 2 %
##   neurons_cells_x_share   samples whose total_neurons differs from total_cells x the printed
##                           neuron share by > 2 %
##   neuron_share_vs_text    100 x sum of neurons / sum of cells vs the text's percentage
##   neuron_share_min/max    range of the neuron share across samples vs the text's range
## and for galago 07-104 also:
##   per-sample cells and neurons per mm2 vs the labelled contours of the paper's Fig. 1 C and D;
##   the density the text's totals imply vs the samples; g per mm2 of 07-104 vs 08-07; area,
##   weight and counts of 07-104 relative to the other galago hemispheres (Collins 08-07 and the
##   three galagos of Young, Collins & Kaas 2013).
##
## Figures from the text and the figures are entered below as constants, each with its source.
## status: pass / mismatch where a printed figure exists to compare with; empty where the row
## only records a number (the paper prints nothing to compare it with).
## Reads only the item table Collins_etal_2010_DatasetS1.csv; writes only
## Collins_etal_2010_DatasetS1_internal_check.csv in this folder. Never changes a value; a
## mismatch is warned and kept as printed.

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
item_name <- sub("_internal_check$", "", tools::file_path_sans_ext(basename(.sp)))   # "Collins_etal_2010_DatasetS1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
item_csv  <- file.path(folder, paste0(item_name, ".csv"))
check_csv <- file.path(check_dir, paste0(item_name, "_internal_check.csv"))

## 1. LOAD (read-only) ------------------------------------------------
options(scipen = 999)                                     # whole numbers, not 3.26e+08, in the result file
d <- read.csv(item_csv, colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE)
num_cols <- c("surface_area_mm2", "tissue_weight_g", "total_cells", "neun_percent_printed", "total_neurons",
              "cell_density_per_g", "cell_density_per_mm2", "neuron_density_per_g", "neuron_density_per_mm2")
for (cl in num_cols) d[[cl]] <- suppressWarnings(as.numeric(d[[cl]]))
cases <- c("07-104", "08-07", "07-78", "08-59", "09-27")
stopifnot(nrow(d) == 244L, setequal(unique(d$specimen), cases))
# the supplement prints the neuron share as a percentage on the baboon sheet and as a fraction
# on the others (item README); here it is used as a fraction
d$share_printed <- ifelse(d$neun_percent_printed > 1, d$neun_percent_printed / 100, d$neun_percent_printed)

## 2. FIGURES FROM THE PAPER (constants, with their source) -----------
# Collins et al. 2010, Results, unless another source is named. NA = the paper gives no figure.
text <- list(
  "07-104" = list(samples = 36,   cells = 326e6,  neurons = 127e6,  area = 2261,  share = 39, share_min = 27, share_max = 60,
                  where = "Results, Prosimian Galagos (galago #1): '46 tissue pieces ... processed as 36 samples'; '2,261 mm2'; 'approximately 326 million' cells (printed with the approximately-equal sign, 'estimated'); '127 million' neurons; '39%; the range across tissue pieces was 27-60% neurons'"),
  "08-07"  = list(samples = NA,   cells = 243e6,  neurons = 107e6,  area = 1849,  share = 44, share_min = 30, share_max = 69,
                  where = "Results, Prosimian Galagos (galago #2): '1,849 mm2, containing 243 million total cells and 107 million total neurons, with an average of 44% neurons ... (range, 30-69%)'"),
  "07-78"  = list(samples = NA,   cells = 553e6,  neurons = 212e6,  area = NA,    share = 38, share_min = NA, share_max = NA,
                  where = "Results, New World Owl Monkey: 'more than 553 million cells, of which 212 million were neurons. Neurons comprised 38%'"),
  "08-59"  = list(samples = NA,   cells = 3.5e9,  neurons = 1.4e9,  area = NA,    share = 40, share_min = NA, share_max = NA,
                  where = "Results, Old World Macaque Monkey: 'Of the nearly 3.5 billion cells in the macaque cortex, 40% (1.4 billion) were neurons'; surface areas were not determined"),
  "09-27"  = list(samples = 142,  cells = 4.67e9, neurons = 2.36e9, area = 18577, share = 51, share_min = NA, share_max = NA,
                  where = "Results (baboon): '268 tissue pieces ... processed as 142 samples'; '18,577 mm2 ... a total of 4.67 billion cells, of which 2.36 billion (51%) were neurons'"))
macaque_discussion_neurons <- 1.36e9     # Discussion: "our results using the isotropic fractionator estimated 1.36 billion neurons in the macaque cortex"
# Fig. 1 C (cells) and D (neurons), galago 07-104: lowest and highest labelled contour and the
# step between contours, read from the figure. The figure prints no unit; the text calls the
# plots "total cells and neurons per millimeter" and the values are on the scale of the
# supplement's cells and neurons per mm2 in thousands.
fig1_cells   <- c(lowest = 100, highest = 340, step = 20)
fig1_neurons <- c(lowest = 40,  highest = 200, step = 20)
# Other galago hemispheres. Young, Collins & Kaas 2013 (Front Neural Circuits 7:30), Results,
# Prosimian galagos: "the total surface area of the flat cortex was 1782 mm2 (galago 1), 1850 mm2
# (galago 2), and 1817 mm2 (galago 3). The total cortex weight ... 2.86, 2.87, and 2.37 g".
# Galago 2 is Collins case 08-07; galago 3 is case 10-41. The areas are built in this repository
# as the item Young_etal_2013_ResultsTextSurface; the weights are in the same sentence of the text.
young_galago <- data.frame(galago = c("Young 2013 galago 1", "Young 2013 galago 2 (= Collins 08-07)", "Young 2013 galago 3 (case 10-41)"),
                           area_mm2 = c(1782, 1850, 1817), weight_g = c(2.86, 2.87, 2.37), stringsAsFactors = FALSE)

## 3. CHECKS ------------------------------------------------------------
mk <- function(id, basis, observed, printed, tolerance, note, digits) {
  difference <- observed - printed
  data.frame(check_id = id, basis = basis, observed = round(observed, digits), printed = round(printed, digits),
             difference = round(difference, digits), tolerance = if (is.na(tolerance)) NA else signif(tolerance, 6),
             status = if (is.na(printed) || is.na(tolerance)) "" else if (abs(difference) <= tolerance) "pass" else "mismatch",
             note = note, stringsAsFactors = FALSE)
}
pct <- function(a, b) sprintf("%+.2f %%", 100 * (a - b) / b)
S <- function(case, cl) sum(d[[cl]][d$specimen == case], na.rm = TRUE)

per_case <- do.call(rbind, lapply(cases, function(case) {
  x <- d[d$specimen == case, , drop = FALSE]; tx <- text[[case]]
  cells <- sum(x$total_cells); neurons <- sum(x$total_neurons); weight <- sum(x$tissue_weight_g)
  has_area <- any(!is.na(x$surface_area_mm2)); area <- if (has_area) sum(x$surface_area_mm2, na.rm = TRUE) else NA
  dev_cells   <- abs(x$total_cells - x$cell_density_per_g * x$tissue_weight_g) / x$total_cells
  dev_neurons <- abs(x$total_neurons - x$total_cells * x$share_printed) / x$total_neurons
  share <- 100 * x$total_neurons / x$total_cells
  out <- rbind(
    mk(paste0(case, "_samples"), "rows (samples) of the case in Dataset S1 vs the number of samples the text gives",
       nrow(x), tx$samples, 0, if (is.na(tx$samples)) "the text gives no number of samples for this case" else tx$where, 0),
    mk(paste0(case, "_cells_sum_vs_text"), "sum of total_cells over the samples vs the whole-hemisphere figure of the text",
       cells, tx$cells, 0.01 * tx$cells, paste0("sum vs text: ", pct(cells, tx$cells), ". ", tx$where), 0),
    mk(paste0(case, "_neurons_sum_vs_text"), "sum of total_neurons over the samples vs the whole-hemisphere figure of the text",
       neurons, tx$neurons, 0.01 * tx$neurons, paste0("sum vs text: ", pct(neurons, tx$neurons), ". ", tx$where), 0),
    if (case == "08-59")
      mk("08-59_neurons_sum_vs_discussion", "sum of total_neurons over the samples vs the figure of the Discussion",
         neurons, macaque_discussion_neurons, 0.01 * macaque_discussion_neurons,
         paste0("sum vs Discussion: ", pct(neurons, macaque_discussion_neurons),
                ". Discussion: 'our results using the isotropic fractionator estimated 1.36 billion neurons in the macaque cortex'"), 0),
    if (has_area)
      mk(paste0(case, "_area_sum_vs_text"), "sum of surface_area_mm2 over the samples vs the hemisphere surface area of the text",
         area, tx$area, 0.01 * tx$area,
         if (is.na(tx$area)) paste0("the text gives no surface area for this case; ", sum(!is.na(x$surface_area_mm2)), " of ", nrow(x), " samples have an area")
         else paste0("sum vs text: ", pct(area, tx$area), ". ", tx$where), 3),
    mk(paste0(case, "_weight_sum"), "sum of tissue_weight_g over the samples (g)", weight,
       if (case == "08-07") young_galago$weight_g[2] else NA, if (case == "08-07") 0.005 else NA,
       if (case == "08-07") "compared with Young et al. 2013, Results: total cortex weight of galago 2 (the same animal) 2.87 g; tolerance = rounding of the printed figure"
       else "Collins et al. 2010 give no cortex weight in the text", 4),
    mk(paste0(case, "_cells_density_x_weight"), "samples whose total_cells differs from cell_density_per_g x tissue_weight_g by more than 2 %",
       sum(dev_cells > 0.02), 0, 0, sprintf("largest difference %.2f %% of the sample's cells, over %d samples", 100 * max(dev_cells), nrow(x)), 0),
    mk(paste0(case, "_neurons_cells_x_share"), "samples whose total_neurons differs from total_cells x the printed neuron share by more than 2 %",
       sum(dev_neurons > 0.02), 0, 0, sprintf("largest difference %.2f %% of the sample's neurons, over %d samples; neuron share as printed in the supplement (neun_percent_printed)", 100 * max(dev_neurons), nrow(x)), 0),
    mk(paste0(case, "_neuron_share_vs_text"), "100 x sum of neurons / sum of cells vs the percentage of neurons in the text",
       100 * neurons / cells, tx$share, 0.5,
       paste0("tolerance = rounding of a whole percent. ",
              if (case == "09-27") "The text's own two figures give 2.36 / 4.67 = 50.5 %, between the sum and the printed 51 %. " else "",
              tx$where), 2),
    if (!is.na(tx$share_min)) rbind(
      mk(paste0(case, "_neuron_share_min_vs_text"), "lowest neuron share of a sample (%) vs the lower end of the range in the text",
         min(share), tx$share_min, 0.5, paste0("tolerance = rounding of a whole percent. ", tx$where), 2),
      mk(paste0(case, "_neuron_share_max_vs_text"), "highest neuron share of a sample (%) vs the upper end of the range in the text",
         max(share), tx$share_max, 0.5, paste0("tolerance = rounding of a whole percent. ", tx$where), 2)))
  out
}))

# galago 07-104: the paper's own figure, and the other galago hemispheres
g1 <- d[d$specimen == "07-104", , drop = FALSE]; g2 <- d[d$specimen == "08-07", , drop = FALSE]
cd <- g1$cell_density_per_mm2 / 1000; nd <- g1$neuron_density_per_mm2 / 1000      # thousands per mm2
contour_note <- "contours are drawn between the centres of the samples, so the lowest labelled contour may lie outside the lowest sample; pass = within two contour steps of it"
top_note <- "pass = the highest sample lies between the highest labelled contour and the next step above it"
galago <- rbind(
  mk("07-104_fig1C_cells_per_mm2_lowest", "lowest per-sample cell_density_per_mm2 (thousands) vs the lowest labelled contour of Fig. 1 C",
     min(cd), fig1_cells[["lowest"]], 2 * fig1_cells[["step"]], contour_note, 1),
  mk("07-104_fig1C_cells_per_mm2_highest", "highest per-sample cell_density_per_mm2 (thousands) vs the highest labelled contour of Fig. 1 C",
     max(cd), fig1_cells[["highest"]], fig1_cells[["step"]], top_note, 1),
  mk("07-104_fig1D_neurons_per_mm2_lowest", "lowest per-sample neuron_density_per_mm2 (thousands) vs the lowest labelled contour of Fig. 1 D",
     min(nd), fig1_neurons[["lowest"]], 2 * fig1_neurons[["step"]], contour_note, 1),
  mk("07-104_fig1D_neurons_per_mm2_highest", "highest per-sample neuron_density_per_mm2 (thousands) vs the highest labelled contour of Fig. 1 D",
     max(nd), fig1_neurons[["highest"]], fig1_neurons[["step"]], top_note, 1),
  mk("07-104_cells_per_mm2_median", "median per-sample cell_density_per_mm2 (thousands)", median(cd), NA, NA,
     sprintf("samples: %.0f to %.0f thousand cells per mm2; the supplement's own totals give %.1f (sum of cells / sum of areas)",
             min(cd), max(cd), S("07-104", "total_cells") / S("07-104", "surface_area_mm2") / 1000), 1),
  mk("07-104_neurons_per_mm2_median", "median per-sample neuron_density_per_mm2 (thousands)", median(nd), NA, NA,
     sprintf("samples: %.0f to %.0f thousand neurons per mm2; the supplement's own totals give %.1f (sum of neurons / sum of areas)",
             min(nd), max(nd), S("07-104", "total_neurons") / S("07-104", "surface_area_mm2") / 1000), 1),
  mk("07-104_text_cells_per_text_area", "cells per mm2 (thousands) implied by the text's totals (326 million / 2,261 mm2) vs the median sample",
     text[["07-104"]]$cells / text[["07-104"]]$area / 1000, median(cd), NA,
     "the text's two figures together imply a density below the median of the samples that the paper's own Fig. 1 C plots; no tolerance: recorded, not tested", 1),
  mk("07-104_text_over_sum_cells", "text figure / sum of samples, cells (1 = the text is the supplement)",
     text[["07-104"]]$cells / S("07-104", "total_cells"), 1, 0.01, "the three ratios (cells, neurons, area) differ from 1 and from each other: no single factor turns the supplement into the text", 3),
  mk("07-104_text_over_sum_neurons", "text figure / sum of samples, neurons (1 = the text is the supplement)",
     text[["07-104"]]$neurons / S("07-104", "total_neurons"), 1, 0.01, "see 07-104_text_over_sum_cells", 3),
  mk("07-104_text_over_sum_area", "text figure / sum of samples, surface area (1 = the text is the supplement)",
     text[["07-104"]]$area / S("07-104", "surface_area_mm2"), 1, 0.01, "see 07-104_text_over_sum_cells", 3),
  mk("07-104_g_per_mm2_vs_08-07", "tissue weight per surface area (g per mm2): case 07-104 vs case 08-07 (sums of the samples)",
     S("07-104", "tissue_weight_g") / S("07-104", "surface_area_mm2"), S("08-07", "tissue_weight_g") / S("08-07", "surface_area_mm2"),
     0.05 * S("08-07", "tissue_weight_g") / S("08-07", "surface_area_mm2"),
     "tolerance 5 %. The same weight per area in both hemispheres: the smaller area of 07-104 comes with a proportionally smaller weight", 6),
  mk("07-104_area_relative_to_08-07", "surface area of 07-104 / surface area of 08-07 (sums of the samples)",
     S("07-104", "surface_area_mm2") / S("08-07", "surface_area_mm2"), NA, NA, "recorded, not tested", 3),
  mk("07-104_weight_relative_to_08-07", "tissue weight of 07-104 / tissue weight of 08-07 (sums of the samples)",
     S("07-104", "tissue_weight_g") / S("08-07", "tissue_weight_g"), NA, NA, "recorded, not tested", 3),
  do.call(rbind, lapply(c(1, 3), function(i) rbind(
    mk(paste0("07-104_area_relative_to_Young2013_galago", i), paste0("surface area of 07-104 / flat-cortex surface area of ", young_galago$galago[i]),
       S("07-104", "surface_area_mm2") / young_galago$area_mm2[i], NA, NA,
       paste0("recorded, not tested. Young, Collins & Kaas 2013, Results (Prosimian galagos): ", young_galago$area_mm2[i], " mm2"), 3),
    mk(paste0("07-104_weight_relative_to_Young2013_galago", i), paste0("tissue weight of 07-104 / total cortex weight of ", young_galago$galago[i]),
       S("07-104", "tissue_weight_g") / young_galago$weight_g[i], NA, NA,
       paste0("recorded, not tested. Young, Collins & Kaas 2013, Results (Prosimian galagos): ", young_galago$weight_g[i], " g"), 3)))),
  mk("07-104_cells_relative_to_08-07", "cells of 07-104 / cells of 08-07 (sums of the samples)",
     S("07-104", "total_cells") / S("08-07", "total_cells"), NA, NA, "recorded, not tested: the cell number is like the other galago's while the area and the weight are not", 3),
  mk("07-104_neurons_relative_to_08-07", "neurons of 07-104 / neurons of 08-07 (sums of the samples)",
     S("07-104", "total_neurons") / S("08-07", "total_neurons"), NA, NA, "recorded, not tested", 3),
  mk("08-07_area_vs_Young2013_galago2", "surface area of 08-07 (sum of the samples) vs Young et al. 2013 galago 2",
     S("08-07", "surface_area_mm2"), young_galago$area_mm2[2], 1,
     "the same animal in the later paper, which prints 1850 mm2 where Collins et al. 2010 print 1,849 mm2; tolerance 1 mm2", 3))

table_checks <- rbind(per_case, galago)
rownames(table_checks) <- NULL

## 4. REPORT + WRITE ----------------------------------------------------
print(table(case = sub("_.*$", "", table_checks$check_id), status = ifelse(nzchar(table_checks$status), table_checks$status, "(recorded)")))
if (any(table_checks$status == "mismatch"))
  warning(sum(table_checks$status == "mismatch"), " check(s) do not agree -- kept as printed (see the note column).", call. = FALSE)
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
