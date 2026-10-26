## Babushina_etal_1991_Figures1-3_crosscheck.R -- do Figs 1, 2 and 3 agree on the fur seal points?
##
## Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and underwater hearing
## characteristics of the northern fur seal: audiograms, frequency and differential thresholds.
## Biophysics 36(5): 909-913.
##
## Fig. 1 (water; P, dB re 1 ubar), Fig. 2 (air; P, dB re 0,0002 dyne/cm2) and Fig. 3 (both media;
## I, dB re 1 uW/cm2) plot the same fur seal thresholds. Intensity is I = p^2 / (rho c), so a Fig. 1
## or Fig. 2 level plus one fixed offset per medium should land on the matching Fig. 3 point.
## This script reads the three frozen snapshots (it never edits them), pairs each Fig. 3 point with
## the nearest point of the other figure (no more than 0.05 decade apart), converts that point to
## intensity and reports the difference. Levels are compared at the paired points as plotted: the
## small frequency offsets between figures are drafting/reading differences, not different tests.
##
## rho c is not stated in the paper. Assumed: 415 Pa s/m (air at about 20 C) and 1.54e6 Pa s/m
## (sea water; fresh water, about 1.48e6, moves the water offset by 0.2 dB).
##
## Written 26 Oct 2026 by Microsoft Copilot (AI assistant) for A. de Sousa.
## R NOT RUN: the CSV and PNG beside this script were produced by a line-for-line Python port.
## Rerun this script to confirm it writes the same CSV (the PNG is redrawn in base R).

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
folder <- dirname(.sp)
setwd(folder)
paper     <- "Babushina_etal_1991"
check_csv <- file.path(folder, paste0(paper, "_Figures1-3_crosscheck.csv"))
check_png <- file.path(folder, paste0(paper, "_Figures1-3_crosscheck.png"))
snap      <- function(fig) file.path(folder, paste0(paper, "_", fig, "_snapshot.csv"))

## 1. LOAD (frozen snapshots, read as text) ---------------------------
rd <- function(f) read.csv(f, check.names = FALSE, stringsAsFactors = FALSE,
                           colClasses = "character", fileEncoding = "UTF-8")
f1 <- rd(snap("Figure1"))
f2 <- rd(snap("Figure2"))
f3 <- rd(snap("Figure3"))
stopifnot(nrow(f1) > 0, nrow(f2) > 0, nrow(f3) > 0)
col_of <- function(df, pattern) {
  hit <- grep(pattern, names(df), value = TRUE)
  if (length(hit) != 1L) stop("expected one column matching '", pattern, "'", call. = FALSE)
  hit
}
lgf     <- "lg f [kHz]"
lev1    <- col_of(f1, "^P, dB \\(rel\\. 1 ")        # Fig. 1, dB re 1 ubar
lev2    <- col_of(f2, "^P, dB \\(rel\\. 0,0002 ")   # Fig. 2, dB re 0,0002 dyne/cm2
lev3    <- col_of(f3, "^I, dB")                     # Fig. 3, dB re 1 uW/cm2
legend3 <- "Curve legend (caption)"                 # "water" (curve 1) or "air" (curve 2)

## 2. CONVERSION CONSTANTS -------------------------------------------
rho_c_air    <- 415      # Pa s/m, air at about 20 C (assumed)
rho_c_water  <- 1.54e6   # Pa s/m, sea water (assumed)
p_ref_air    <- 20e-6    # Pa  = 0,0002 dyne/cm2
p_ref_water  <- 0.1      # Pa  = 1 ubar
i_ref        <- 1e-2     # W/m2 = 1 uW/cm2
offset_air   <- 10 * log10(p_ref_air^2   / rho_c_air   / i_ref)   # about -100.2 dB
offset_water <- 10 * log10(p_ref_water^2 / rho_c_water / i_ref)   # about  -61.9 dB
max_dlgf <- 0.05   # pair points no more than 0.05 decade apart
tol_db   <- 2      # flag differences larger than 2 dB

## 3. PAIR AND COMPARE ------------------------------------------------
fmt        <- function(x, d) sprintf(paste0("%.", d, "f"), x)
fmt_signed <- function(x, d) sprintf(paste0("%+.", d, "f"), x)

compare <- function(medium, other, other_fig, other_col, offset, reference) {
  px  <- as.numeric(other[[lgf]])
  py  <- as.numeric(other[[other_col]])
  pid <- other$Point
  f3m <- f3[f3[[legend3]] == medium, , drop = FALSE]
  out <- list()
  used <- character(0)
  for (i in seq_len(nrow(f3m))) {
    x3 <- as.numeric(f3m[[lgf]][i])
    i3 <- as.numeric(f3m[[lev3]][i])
    k  <- which.min(abs(px - x3))
    dx <- x3 - px[k]
    if (abs(dx) > max_dlgf) {
      out[[length(out) + 1]] <- c(medium, f3m$Point[i], fmt(x3, 3), fmt(i3, 1), other_fig, "", "", "",
                                  reference, "", "", "", "no partner point within 0.05 decade")
      next
    }
    used     <- c(used, pid[k])
    expected <- py[k] + offset
    diff     <- i3 - expected
    out[[length(out) + 1]] <- c(medium, f3m$Point[i], fmt(x3, 3), fmt(i3, 1), other_fig, pid[k],
                                fmt(px[k], 3), fmt(py[k], 1), reference, fmt(expected, 1),
                                fmt_signed(diff, 1), fmt_signed(dx, 3),
                                if (abs(diff) <= tol_db) "agrees" else "check")
  }
  for (j in seq_along(px)) {
    if (!(pid[j] %in% used))
      out[[length(out) + 1]] <- c(medium, "", "", "", other_fig, pid[j], fmt(px[j], 3), fmt(py[j], 1),
                                  reference, "", "", "", "no Figure 3 point")
  }
  do.call(rbind, out)
}

check <- rbind(compare("water", f1, "Figure 1", lev1, offset_water, "dB re 1 \u00b5bar"),
               compare("air",   f2, "Figure 2", lev2, offset_air,   "dB re 0,0002 dyne/cm\u00b2"))
check <- as.data.frame(check, stringsAsFactors = FALSE)
names(check) <- c("Medium", "Figure 3 point", "Figure 3 lg f [kHz]",
                  "Figure 3 I, dB (rel. 1 \u00b5W/cm\u00b2)", "Other figure", "Other figure point",
                  "Other figure lg f [kHz]", "Other figure level (dB as plotted)", "Other figure reference",
                  "Other figure level converted to I (dB re 1 \u00b5W/cm\u00b2)",
                  "Difference, Figure 3 minus converted (dB)",
                  "Frequency offset, Figure 3 minus other figure (decades)", "Result")
write.csv(check, check_csv, row.names = FALSE, fileEncoding = "UTF-8")

## 4. SUMMARY -----------------------------------------------------------
dcol <- "Difference, Figure 3 minus converted (dB)"
for (m in c("water", "air")) {
  d <- as.numeric(check[check$Medium == m & nzchar(check[[dcol]]), dcol])
  cat(sprintf("%s: %d pairs; difference median %+.1f dB (range %+.1f to %+.1f); %d flagged; %d unpaired\n",
              m, length(d), median(d), min(d), max(d),
              sum(check$Medium == m & check$Result == "check"),
              sum(check$Medium == m & grepl("^no ", check$Result))))
}

## 5. PLOT ---------------------------------------------------------------
num <- function(x) as.numeric(x)
w3 <- f3[f3[[legend3]] == "water", , drop = FALSE]
a3 <- f3[f3[[legend3]] == "air", , drop = FALSE]
yr <- range(c(num(f3[[lev3]]), num(f1[[lev1]]) + offset_water, num(f2[[lev2]]) + offset_air))
png(check_png, width = 1500, height = 930, res = 150)
plot(num(w3[[lgf]]), num(w3[[lev3]]), pch = 16, col = "#1f4e79", cex = 1.3,
     xlim = c(-1.15, 1.75), ylim = yr, xlab = "lg f [kHz]",
     ylab = "I, dB (rel. 1 \u00b5W/cm\u00b2)",
     main = "Fur seal points: Fig. 3 versus Figs 1 and 2 converted to intensity")
grid()
points(num(f1[[lgf]]), num(f1[[lev1]]) + offset_water, pch = 4, col = "#5aa9e6", lwd = 2)
points(num(a3[[lgf]]), num(a3[[lev3]]), pch = 1, col = "#b5462f", lwd = 2, cex = 1.3)
points(num(f2[[lgf]]), num(f2[[lev2]]) + offset_air, pch = 3, col = "#e3906f", lwd = 2)
legend("bottomleft", cex = 0.85, pch = c(16, 4, 1, 3), pt.lwd = 2,
       col = c("#1f4e79", "#5aa9e6", "#b5462f", "#e3906f"),
       legend = c("Fig. 3, water (curve 1)",
                  sprintf("Fig. 1, water, converted (%.1f dB)", offset_water),
                  "Fig. 3, air (curve 2)",
                  sprintf("Fig. 2, air, converted (%.1f dB)", offset_air)))
invisible(dev.off())
