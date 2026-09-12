## Hanson et al. 2018 - Table 2 : snapshot -> derived
## Faithful snapshot (Hanson_etal_2018_Table2_snapshot.csv) reproduces the published Table 2 verbatim
## (WS/TD + Average percent change / t-statistics / df / P-value rows, mean ± SD).
## Derived = analysis-amenable: split "mean ± SD" into numeric *_mean / *_SD columns, one row per
## Region x Group; the stat rows (%change, t, df, P) are dropped (kept in the snapshot for provenance).

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source.", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder); options(stringsAsFactors = FALSE)
suppressMessages({ library(tidyr); library(dplyr) })

raw <- read.csv("Hanson_etal_2018_Table2_snapshot.csv", check.names = FALSE, skip = 1)

## keep only the group value rows (WS, TD); drop stat rows
val <- raw[raw$Stat %in% c("WS", "TD"), ]

## split "mean ± SD" -> numeric mean/SD (strip thousands commas)
split_pm <- function(x) {
  x <- gsub(",", "", trimws(as.character(x)))
  parts <- strsplit(x, "\\s*±\\s*")
  list(mean = suppressWarnings(as.numeric(sapply(parts, `[`, 1))),
       sd   = suppressWarnings(as.numeric(sapply(parts, `[`, 2))))
}
regions <- c(dC = "Caudate nucleus (dorsal)", mC = "Caudate nucleus (medial)",
             aP = "Putamen (associative)",    NA_ = "Nucleus Accumbens")
codes <- c("dC","mC","aP","NA")

measure_key <- c("Average neuron density" = "Neuron_density.per.mm3",
                 "Average glia density"   = "Glia_density.per.mm3",
                 "Glia per neuron"        = "Glia_Neuron_ratio",
                 "Average soma area (µm2)"= "Soma_area.um2")

long <- do.call(rbind, lapply(seq_len(nrow(val)), function(i) {
  m <- measure_key[[ val$Measure[i] ]]; grp <- val$Stat[i]
  do.call(rbind, lapply(codes, function(cc) {
    sp <- split_pm(val[[cc]][i])
    data.frame(Region_code = cc, Group = grp, var = m,
               mean = sp$mean, sd = sp$sd)
  }))
}))

wide_mean <- long %>% select(Region_code, Group, var, mean) %>% pivot_wider(names_from = var, values_from = mean)
wide_sd   <- long %>% select(Region_code, Group, var, sd)   %>% pivot_wider(names_from = var, values_from = sd)
names(wide_sd)[-(1:2)] <- paste0(names(wide_sd)[-(1:2)], ".SD")

reg_lab <- c(dC = "Caudate nucleus (dorsal)", mC = "Caudate nucleus (medial)",
             aP = "Putamen (associative)", "NA" = "Nucleus Accumbens")
out <- merge(wide_mean, wide_sd, by = c("Region_code","Group"))
out$Region <- reg_lab[out$Region_code]
out$taxon <- "Homo sapiens"; out$n <- 5L
out <- out[order(match(out$Region_code, codes), out$Group),
           c("Region","Region_code","Group","n","taxon",
             "Neuron_density.per.mm3","Neuron_density.per.mm3.SD",
             "Glia_density.per.mm3","Glia_density.per.mm3.SD",
             "Glia_Neuron_ratio","Glia_Neuron_ratio.SD",
             "Soma_area.um2","Soma_area.um2.SD")]
write.csv(out, "Hanson_etal_2018_Table2_derived.csv", row.names = FALSE)
cat("Table2 derived:", nrow(out), "rows\n")


## ---- public TSV (database "online" copy) : regenerate from the derived table ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(read.csv("Hanson_etal_2018_Table2_derived.csv", check.names = FALSE),
              file.path(.td, "10.1002%2Fdneu.22554_Table2.tsv"), sep = "\t", row.names = FALSE)
}
