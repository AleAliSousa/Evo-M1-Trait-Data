## Kochiyama_etal_2018 — reconcile the relative volumes of parcellated regions
## among NT / EH / MH, using the FIVE extracted items as independent sources.
##
## Idea (what the paper does not hand you as numbers, but can be recovered):
##   * Figure 3 legend gives MH mean & s.d. (cc) -> MH relative s.d. = CV = sd/mean.
##   * Extended Data Table 3 gives F(2,1190) and post-hoc t(1190) for NT/EH/MH.
##     Post-hoc t uses the pooled ANOVA error (df 1190); with n_NT=n_EH=4, n_MH=1185
##     and MSE ~= var(MH_rel)=CV^2 (MH dominates the pooled df), the group means can
##     be recovered:   m_g = 1 + sign_g * t_gMH * CV * sqrt(1/4 + 1/1185).
##   * The three pairwise t's are internally over-determined; the identity
##     t_NTvsEH = |s_NT*t_NTMH - s_EH*t_EHMH| / sqrt((1/4+1/4)/(1/4+1/1185))
##     validates Table 3 and fixes whether NT,EH are on the same/opposite side of MH.
##   * Figure 3 bars fix the absolute direction (above/below MH); Extended Data
##     Figure 4 (individual-brain reconstruction) is an independent digitized check.
##
## Run with Rscript. Reads the snapshots in this folder; writes the reconciliation CSV.

options(stringsAsFactors = FALSE)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getSourceEditorContext()$path))
  stop("Run with Rscript.")
})
setwd(dirname(.sp))

legend <- read.csv("Kochiyama_etal_2018_Figure3legend.csv", check.names = FALSE)
t3     <- read.csv("Kochiyama_etal_2018_ExtendedDataTable3.csv", check.names = FALSE)
## Figure 3 was split into separate 3A / 3B items (see Kochiyama_etal_2018_ReadMe_split.md);
## the NT_rel / EH_rel / MH_rel bar-graph values this script needs now live in Figure3A.
fig3   <- read.csv("Kochiyama_etal_2018_Figure3A.csv", check.names = FALSE)
ef4    <- read.csv("Kochiyama_etal_2018_ExtendedDataFigure4.csv", check.names = FALSE)

cv <- setNames(legend$MH_sd_Vol.cc / legend$MH_mean_Vol.cc, legend$Region_code)
se1_factor <- sqrt(1/4 + 1/1185)
ratio      <- sqrt((1/4 + 1/4) / (1/4 + 1/1185))     # se2/se1 = 1.41183

# directions relative to MH, fixed from Figure 3 (which group is above/below 1.0)
sign_nt <- c(Sm=-1, `Pa SI`=-1, `Oc SM`=+1, `Oc I`=+1, `Ce P`=-1, `Ce V`=-1)
sign_eh <- c(Sm=-1, `Pa SI`=-1, `Oc SM`=+1, `Oc I`=+1, `Ce P`=-1, `Ce V`=+1)

recover <- function(reg) {
  row <- t3[t3$Region_code == reg, ]
  if (is.na(row$t_NTvsMH) || row$t_NTvsMH == "") return(c(NA, NA, NA))
  tnteh <- as.numeric(row$t_NTvsEH); tntmh <- as.numeric(row$t_NTvsMH); tehmh <- as.numeric(row$t_EHvsMH)
  se1 <- cv[[reg]] * se1_factor
  m_nt <- 1 + sign_nt[[reg]] * tntmh * se1
  m_eh <- 1 + sign_eh[[reg]] * tehmh * se1
  pred_nteh <- abs(sign_nt[[reg]]*tntmh - sign_eh[[reg]]*tehmh) / ratio
  c(m_nt, m_eh, abs(pred_nteh - tnteh))     # last = internal-consistency error
}

out <- data.frame()
for (reg in legend$Region_code) {
  rc <- recover(reg)
  f3 <- fig3[fig3$Region_code == reg, ]
  e4 <- ef4[ef4$Region_code == reg, ]
  out <- rbind(out, data.frame(
    Region_code = reg,
    significant = !is.na(rc[1]),
    NT_fig3 = f3$NT_rel, EH_fig3 = f3$EH_rel,
    NT_recovered = round(rc[1], 4), EH_recovered = round(rc[2], 4),
    NT_extfig4 = e4$NT_rel, EH_extfig4 = e4$EH_rel,
    consistency_err_t = round(rc[3], 4),
    best_NT = round(ifelse(is.na(rc[1]), f3$NT_rel, rc[1]), 4),
    best_EH = round(ifelse(is.na(rc[2]), f3$EH_rel, rc[2]), 4)
  ))
}
write.csv(out, "Kochiyama_etal_2018_relative_volumes_reconciled.csv", row.names = FALSE)
sig <- out[out$significant, ]
message("Max internal-consistency error (t-units): ",
        round(max(sig$consistency_err_t), 4))
message("Max |Figure3 - recovered| (rel-vol units): ",
        round(max(abs(c(sig$NT_fig3 - sig$NT_recovered, sig$EH_fig3 - sig$EH_recovered))), 4))
