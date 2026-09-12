## Hanson et al. 2018 - Table 3 : snapshot -> derived
## Faithful snapshot reproduces published Table 3 (oligodendrocyte density WS/TD/t/df/p/%increase +
## oligodendrocytes-as-%-of-glia). Derived = numeric oligo density mean/SD + oligo % of glia, per
## Region x Group (dC, mC only); stat rows dropped (kept in snapshot).

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

raw <- read.csv("Hanson_etal_2018_Table3_snapshot.csv", check.names = FALSE, skip = 1)
num <- function(x) suppressWarnings(as.numeric(gsub("[,%]", "", trimws(as.character(x)))))
split_pm <- function(x) {
  x <- gsub(",", "", trimws(as.character(x))); p <- strsplit(x, "\\s*±\\s*")
  list(mean = suppressWarnings(as.numeric(sapply(p, `[`, 1))),
       sd   = suppressWarnings(as.numeric(sapply(p, `[`, 2))))
}
codes <- c("dC","mC"); reg_lab <- c(dC="Caudate nucleus (dorsal)", mC="Caudate nucleus (medial)")

od  <- raw[raw$Measure=="Oligodendrocyte density" & raw$Stat %in% c("WS","TD"), ]
pct <- raw[raw$Measure=="Oligodendrocytes: percent of total glia" & raw$Stat %in% c("WS","TD"), ]

rows <- do.call(rbind, lapply(codes, function(cc) {
  do.call(rbind, lapply(c("WS","TD"), function(g) {
    sp <- split_pm(od[[cc]][od$Stat==g])
    data.frame(Region = reg_lab[[cc]], Region_code = cc, Group = g, n = 5L, taxon = "Homo sapiens",
               Oligodendrocyte_density.per.mm3 = sp$mean,
               Oligodendrocyte_density.per.mm3.SD = sp$sd,
               Oligodendrocyte_pct_of_glia = num(pct[[cc]][pct$Stat==g]))
  }))
}))
write.csv(rows, "Hanson_etal_2018_Table3_derived.csv", row.names = FALSE)
cat("Table3 derived:", nrow(rows), "rows\n")


## ---- public TSV (database "online" copy) : regenerate from the derived table ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(read.csv("Hanson_etal_2018_Table3_derived.csv", check.names = FALSE),
              file.path(.td, "10.1002%2Fdneu.22554_Table3.tsv"), sep = "\t", row.names = FALSE)
}
