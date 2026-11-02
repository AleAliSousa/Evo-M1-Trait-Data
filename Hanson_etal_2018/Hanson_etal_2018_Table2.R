## Hanson et al. 2018 - Table 2 : snapshot -> analysis-ready CSV
## The XLSX snapshot preserves the complete published table. The values are means ± SEM:
## the printed uncertainties reproduce the Welch t statistics when treated as standard errors.
## The clean CSV splits means/SEMs and retains one row per Region x Group.

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
suppressMessages({ library(readxl); library(tidyr); library(dplyr) })

raw <- as.data.frame(read_excel("Hanson_etal_2018_Table2_snapshot.xlsx", sheet = "Table 2", skip = 1,
                                .name_repair = "minimal"), check.names = FALSE)

## keep only the group value rows (WS, TD); drop stat rows
val <- raw[raw$Stat %in% c("WS", "TD"), ]

## split "mean ± SEM" -> numeric mean/SEM (strip thousands commas)
split_pm <- function(x) {
  x <- gsub(",", "", trimws(as.character(x)))
  parts <- strsplit(x, "\\s*±\\s*")
  list(mean = suppressWarnings(as.numeric(sapply(parts, `[`, 1))),
       sem  = suppressWarnings(as.numeric(sapply(parts, `[`, 2))))
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
               mean = sp$mean, sem = sp$sem)
  }))
}))

wide_mean <- long %>% select(Region_code, Group, var, mean) %>% pivot_wider(names_from = var, values_from = mean)
wide_sem  <- long %>% select(Region_code, Group, var, sem) %>% pivot_wider(names_from = var, values_from = sem)
names(wide_sem)[-(1:2)] <- paste0(names(wide_sem)[-(1:2)], ".SEM")

reg_lab <- c(dC = "Caudate nucleus (dorsal)", mC = "Caudate nucleus (medial)",
             aP = "Putamen (associative)", "NA" = "Nucleus Accumbens")
out <- merge(wide_mean, wide_sem, by = c("Region_code","Group"))
out$Region <- reg_lab[out$Region_code]
out$taxon <- "Homo sapiens"; out$n <- 5L
out <- out[order(match(out$Region_code, codes), out$Group),
           c("Region","Region_code","Group","n","taxon",
             "Neuron_density.per.mm3","Neuron_density.per.mm3.SEM",
             "Glia_density.per.mm3","Glia_density.per.mm3.SEM",
             "Glia_Neuron_ratio","Glia_Neuron_ratio.SEM",
             "Soma_area.um2","Soma_area.um2.SEM")]
write.csv(out, "Hanson_etal_2018_Table2.csv", row.names = FALSE, na = "NA")
cat("Table 2:", nrow(out), "analysis-ready rows\n")


## ---- public TSV (database online copy) ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(out, file.path(.td, "10.1002%2Fdneu.22554_Table2.tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA", eol = "\n")
}
