# internal_checks/Hevner_etal_1995_Text_internal_check.R -------------------------
#
# Cross-item check (build HOWTO 7b): values the RUNNING TEXT prints for bars of
# Fig. 31 / Fig. 32 (Hevner_etal_1995_Text snapshot) against the digitised bars
# in the sibling snapshots Hevner_etal_1995_Figure31_snapshot.csv and
# Hevner_etal_1995_Figure32_snapshot.csv. Read-only: writes only
# Hevner_etal_1995_Text_internal_check.csv next to this script. No value is changed.
#
# Tolerances: printed rounding (half a unit of the last printed digit) plus the
# digitising resolution (2 px: 0.5 mU/mg tissue, 5 mU/mg protein, 0.001 OD).

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R", call. = FALSE)
})
folder    <- dirname(dirname(.sp))                 # the paper folder
item_name <- sub("_internal_check$", "", tools::file_path_sans_ext(basename(.sp)))
base      <- item_name
rd <- function(f) read.csv(f, colClasses = "character", na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
tx  <- rd(file.path(folder, paste0(base, "_snapshot.csv")))
f31 <- rd(file.path(folder, "Hevner_etal_1995_Figure31_snapshot.csv"))
f32 <- rd(file.path(folder, "Hevner_etal_1995_Figure32_snapshot.csv"))
num <- function(x) suppressWarnings(as.numeric(x))
tv  <- function(r, col = "value_printed") num(tx[[col]][tx$text_row == as.character(r)])
b31 <- function(p, reg, col = "mean_digitised") num(f31[[col]][f31$panel == p & f31$region_as_printed == reg])
b32 <- function(cell, col = "mean_digitised") num(f32[[col]][f32$cell_type_as_printed == cell])
n31 <- function(p, reg) num(f31$n_from_legend[f31$panel == p & f31$region_as_printed == reg])

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed, difference = observed - printed,
             tolerance = tol, status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
checks <- rbind(
  chk("text19_vs_fig31A_whole_brain_mean", "text row 19 (p. 335, 158 mU/mg tissue) vs Fig. 31A whole brain bar", b31("A", "whole brain"), tv(19), 1.0),
  chk("text19_sd_vs_fig31A_whole_brain_sem", "text row 19 S.D. 12 / sqrt(6) vs Fig. 31A whole brain S.E.M. bar", b31("A", "whole brain", "sem_digitised"), tv(19, "dispersion_printed") / sqrt(n31("A", "whole brain")), 1.0, "p. 335 states mean ± S.D.; the legend says the figure plots S.E.M."),
  chk("text20_vs_fig31B_whole_brain_mean", "text row 20 (p. 335, 1760 mU/mg protein) vs Fig. 31B whole brain bar", b31("B", "whole brain"), tv(20), 15),
  chk("text20_sd_vs_fig31B_whole_brain_sem", "text row 20 S.D. 100 / sqrt(6) vs Fig. 31B whole brain S.E.M. bar", b31("B", "whole brain", "sem_digitised"), tv(20, "dispersion_printed") / sqrt(n31("B", "whole brain")), 10, "digitised 31 vs 41 expected from the printed S.D.; kept as digitised"),
  chk("text26_vs_fig31A_cerebellar_cortex", "text row 26 (p. 336, 157 ± 17) vs Fig. 31A cerebellar cortex bar", b31("A", "cerebellar cortex"), tv(26), 1.0),
  chk("text26_sem_vs_fig31A_cerebellar_cortex", "text row 26 S.E.M. 17 vs Fig. 31A cerebellar cortex cap", b31("A", "cerebellar cortex", "sem_digitised"), tv(26, "dispersion_printed"), 1.5),
  chk("text27_vs_fig31B_visual_cortex", "text row 27 (p. 336, 1760 ± 150) vs Fig. 31B visual cortex bar", b31("B", "visual cortex"), tv(27), 15),
  chk("text27_sem_vs_fig31B_visual_cortex", "text row 27 S.E.M. 150 vs Fig. 31B visual cortex cap", b31("B", "visual cortex", "sem_digitised"), tv(27, "dispersion_printed"), 15, "digitised 132 vs printed 150 (7 px); the printed value takes precedence"),
  chk("text35_vs_fig32_CA3", "text row 35 (p. 337, 0.495 ± 0.017) vs Fig. 32 CA3 bar", b32("CA3 hippocampal pyramid"), tv(35), 0.0015),
  chk("text35_sem_vs_fig32_CA3", "text row 35 S.E.M. 0.017 vs Fig. 32 CA3 cap", b32("CA3 hippocampal pyramid", "sem_digitised"), tv(35, "dispersion_printed"), 0.0025),
  chk("text36_vs_fig32_CA1", "text row 36 (p. 337, 0.357 ± 0.005) vs Fig. 32 CA1 bar", b32("CA1 hippocampal pyramid"), tv(36), 0.0015),
  chk("text36_sem_vs_fig32_CA1", "text row 36 S.E.M. 0.005 vs Fig. 32 CA1 cap", b32("CA1 hippocampal pyramid", "sem_digitised"), tv(36, "dispersion_printed"), 0.0025),
  chk("text34_vs_fig32_ratio", "text row 34 (p. 337, 78 % higher) vs 100 x (Fig. 32 mesencephalic V / dentate granule - 1)", 100 * (b32("mesencephalic nucleus of V") / b32("dentate granule cell") - 1), tv(34), 1.0, "marginal: 76.7 vs 78; the authors may have used unrounded means"),
  chk("text24_vs_fig31A_gray_white", "text row 24 (p. 336, 'about 10- to 12-fold') vs mean gray / mean white of Fig. 31A (printed = range midpoint)",
      mean(num(f31$mean_digitised[f31$panel == "A" & f31$tissue_class_as_printed == "gray matter"])) / mean(num(f31$mean_digitised[f31$panel == "A" & f31$tissue_class_as_printed == "white matter"])), 11, 1),
  chk("text25_vs_fig31B_gray_white", "text row 25 (p. 336, 'about eight- to 10-fold') vs mean gray / mean white of Fig. 31B",
      mean(num(f31$mean_digitised[f31$panel == "B" & f31$tissue_class_as_printed == "gray matter"])) / mean(num(f31$mean_digitised[f31$panel == "B" & f31$tissue_class_as_printed == "white matter"])), 9, 1),
  chk("text28_vs_fig31C_gray_white", "text row 28 (p. 337, 'about four to five times') vs mean gray / mean white of Fig. 31C",
      mean(num(f31$mean_digitised[f31$panel == "C" & f31$tissue_class_as_printed == "gray matter"])) / mean(num(f31$mean_digitised[f31$panel == "C" & f31$tissue_class_as_printed == "white matter"])), 4.5, 0.5, "3.85 by mean-of-means; the authors' basis for 'four to five' is not stated")
)
tally <- table(factor(checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, " internal check: pass=", tally[["pass"]], " mismatch=", tally[["mismatch"]], " not_evaluable=", tally[["not_evaluable"]])
for (i in which(checks$status == "mismatch"))
  warning(sprintf("%s: observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", checks$check_id[i], checks$observed[i], checks$printed[i], checks$difference[i], checks$tolerance[i]), call. = FALSE)
write.csv(checks, file.path(dirname(.sp), paste0(base, "_internal_check.csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
