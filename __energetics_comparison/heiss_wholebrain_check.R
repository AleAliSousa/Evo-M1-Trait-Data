# ============================================================
# heiss_wholebrain_check.R
# ------------------------------------------------------------
# QUESTION (from the s4 endocranial energy-budget work):
#   If you sum up the Heiss et al. (2004) regions, do you get the
#   whole brain / total brain glucose use, or not -- because they
#   only measured selected regions?
#
# SHORT ANSWER: not by a raw sum. Heiss gives RATES (umol glucose/
#   100 g/min), not totals, and the 26 rows are a representative
#   sample of grey-matter nuclei + two white-matter samples -- they
#   do NOT tile the brain volumetrically. To get a whole-brain number
#   you must volume-weight the rates. This script does that with the
#   volumes we actually have (the 6 Kochiyama endocast regions used in
#   s4) and compares the result to a PUBLISHED human whole-brain value
#   from the Karbowski (2007) compilation (Clarke & Sokoloff 1994).
#
# DATA (all local to Evo-M1-Trait-Data):
#   Heiss     : Heiss_etal_2004/Heiss_etal_2004_TABLE1.csv   (rates)
#   Karbowski : Karbowski__2007/Karbowski__2007_TableS2.csv (benchmark)
#   Kuzawa    : NOT YET BUILT -- see the hook at the bottom.
# ============================================================

## portable base path: find the Evo-M1-Trait-Data root regardless of cwd
script_dir <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(dirname(normalizePath(sub("^--file=", "", a[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(dirname(normalizePath(rstudioapi::getSourceEditorContext()$path)))
  normalizePath(getwd())
})
evo <- normalizePath(file.path(script_dir, ".."))

GLU_MW    <- 180.16   # g/mol glucose
DENSITY   <- 1.036    # g/cc brain tissue

# ------------------------------------------------------------
# 1. Heiss rates -- show the region set is NOT a volumetric partition
# ------------------------------------------------------------
heiss <- read.csv(file.path(evo, "Heiss_etal_2004", "Heiss_etal_2004_TABLE1.csv"),
                  stringsAsFactors = FALSE, check.names = FALSE)
heiss <- heiss[heiss$Region != "Cerebral cortex (global average)", ]  # drop summary row
rate  <- setNames(heiss$`Both hemispheres Mean`, heiss$Region)

cat("Heiss 2004 supplies", nrow(heiss), "regional RATES (umol/100g/min),\n")
cat("grouped as:\n"); print(table(heiss$category))
cat("\nThese are selected nuclei + 2 white-matter samples -- e.g. only the\n",
    "medial thalamic nucleus (not whole thalamus), a few brain-stem nuclei\n",
    "(no pons/medulla bulk), and 2 representative white-matter sites. So a\n",
    "raw sum or unweighted mean of these rates is NOT a whole-brain value.\n\n", sep="")

cat(sprintf("Unweighted mean of all %d Heiss rates = %.1f umol/100g/min (meaningless as a whole-brain rate)\n\n",
            length(rate), mean(rate)))

# ------------------------------------------------------------
# 2. Published human whole-brain benchmark (Karbowski compilation)
# ------------------------------------------------------------
k <- read.csv(file.path(evo, "Karbowski__2007", "Karbowski__2007_TableS2.csv"),
              stringsAsFactors = FALSE, check.names = FALSE)
kh <- k[k$species_printed == "human" & k$structure == "Brain", ]
getk <- function(m) as.numeric(kh$value[kh$measure == m])
wb_CMRgl <- getk("CMRgl")                       # 0.31 umol/g/min
wb_total <- getk("Total_glucose_utilization")   # 428.55 umol/min
wb_ref   <- unique(kh$reference)
wb_mass  <- wb_total / wb_CMRgl                 # implied brain mass, g

cat("Published human WHOLE-BRAIN benchmark (", wb_ref, ", via Karbowski 2007):\n", sep="")
cat(sprintf("  CMRgl = %.2f umol/g/min ; total = %.1f umol/min ; implied mass = %.0f g\n",
            wb_CMRgl, wb_total, wb_mass))
cat(sprintf("  = %.0f g glucose/day\n\n", wb_total*60*24*GLU_MW/1e6))

# ------------------------------------------------------------
# 3. Volume-weight the Heiss rates over the 6 regions we HAVE volumes for
#    (Kochiyama 2018 modern-human parcel volumes, cc -- the s4 inputs)
# ------------------------------------------------------------
# region -> (Heiss rate key, MH volume cc)
meas <- data.frame(
  region  = c("Frontal lobe","Parietal lobe","Temporal lobe","Occipital lobe",
              "Cerebellar cortex","Vermis"),
  vol_cc  = c(317.105, 174.145, 173.770, 133.690, 128.270, 12.380),
  stringsAsFactors = FALSE)
meas$rate  <- rate[meas$region]
meas$mass  <- meas$vol_cc * DENSITY
meas$umol_min <- meas$rate/100 * meas$mass
meas_total <- sum(meas$umol_min)
meas_mass  <- sum(meas$mass)
meas_rate  <- meas_total/meas_mass   # umol/g/min

cat("The 6 endocast regions we CAN weight (rate x volume):\n")
print(transform(meas, rate=round(rate,1), mass=round(mass), umol_min=round(umol_min,1))[
      ,c("region","rate","vol_cc","mass","umol_min")], row.names = FALSE)
cat(sprintf("\n  measured total   = %.1f umol/min over %.0f g\n", meas_total, meas_mass))
cat(sprintf("  implied rate     = %.3f umol/g/min\n", meas_rate))

# ------------------------------------------------------------
# 4. THE CHECK: measured subset vs published whole brain
# ------------------------------------------------------------
cat("\n===================  CHECK  ===================\n")
cat(sprintf("measured 6 regions cover %.0f%% of whole-brain MASS but %.0f%% of whole-brain GLUCOSE\n",
            100*meas_mass/wb_mass, 100*meas_total/wb_total))
cat(sprintf("measured rate %.3f  >  whole-brain rate %.3f umol/g/min (ratio %.2f)\n",
            meas_rate, wb_CMRgl, meas_rate/wb_CMRgl))
cat("Interpretation: our regions are HIGH-rate cortex + cerebellar cortex, so they\n",
    "carry more glucose than their volume share. The ~30% of brain mass we omit is\n",
    "dominated by low-rate white matter (Heiss centrum semiovale = 12.3 vs cortex ~34),\n",
    "which is why summing only these regions OVER-states the per-gram rate and the\n",
    "extrapolated whole-brain total.\n", sep="")

# naive extrapolation (measured rate applied to whole brain) vs published
naive_wb <- meas_rate * wb_mass
cat(sprintf("\nExtrapolating measured rate to %.0f g: %.0f umol/min  vs published %.0f umol/min  (+%.0f%%)\n",
            wb_mass, naive_wb, wb_total, 100*(naive_wb/wb_total-1)))
cat(sprintf("=> Consistent: the +%.0f%% overshoot is the white-matter dilution we excluded.\n",
            100*(naive_wb/wb_total-1)))

# ------------------------------------------------------------
# 5. HOOK: Kuzawa (developmental whole-brain glucose, g/day) -- NOT YET BUILT
# ------------------------------------------------------------
# When the Kuzawa dataset folder exists (e.g. Kuzawa_etal_2014 with the
# lifespan brain glucose-uptake curve, PNAS 111:13010), add its adult
# whole-brain g/day value here as a second published benchmark:
#   kuzawa <- read.csv(file.path(evo, "Kuzawa_etal_2014", "<file>.csv"))
#   ... compare adult whole-brain g/day to wb_total*60*24*GLU_MW/1e6 above.
kuzawa_path <- file.path(evo, "Kuzawa_etal_2014")
if (dir.exists(kuzawa_path)) {
  cat("\n[Kuzawa folder found -- add its adult whole-brain g/day benchmark here.]\n")
} else {
  cat("\n[Kuzawa dataset not built yet -- second whole-brain benchmark pending.]\n")
}
