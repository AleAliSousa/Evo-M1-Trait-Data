## Hanson et al. 2018 - Table 3 : snapshot -> analysis-ready CSV
## The XLSX snapshot preserves the complete published table. The density values are means ± SEM:
## the printed uncertainties reproduce the Welch t statistics when treated as standard errors.

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
suppressMessages(library(readxl))

raw <- as.data.frame(read_excel("Hanson_etal_2018_Table3_snapshot.xlsx", sheet = "Table 3", skip = 1,
                                .name_repair = "minimal"), check.names = FALSE)
num <- function(x) suppressWarnings(as.numeric(gsub("[,%]", "", trimws(as.character(x)))))
split_pm <- function(x) {
  x <- gsub(",", "", trimws(as.character(x))); p <- strsplit(x, "\\s*±\\s*")
  list(mean = suppressWarnings(as.numeric(sapply(p, `[`, 1))),
       sem  = suppressWarnings(as.numeric(sapply(p, `[`, 2))))
}
codes <- c("dC","mC"); reg_lab <- c(dC="Caudate nucleus (dorsal)", mC="Caudate nucleus (medial)")

od  <- raw[raw$Measure=="Oligodendrocyte density" & raw$Stat %in% c("WS","TD"), ]
pct <- raw[raw$Measure=="Oligodendrocytes: percent of total glia" & raw$Stat %in% c("WS","TD"), ]

rows <- do.call(rbind, lapply(codes, function(cc) {
  do.call(rbind, lapply(c("WS","TD"), function(g) {
    sp <- split_pm(od[[cc]][od$Stat==g])
    data.frame(Region = reg_lab[[cc]], Region_code = cc, Group = g, n = 5L, taxon = "Homo sapiens",
               Oligodendrocyte_density.per.mm3 = sp$mean,
               Oligodendrocyte_density.per.mm3.SEM = sp$sem,
               Oligodendrocyte_pct_of_glia = num(pct[[cc]][pct$Stat==g]))
  }))
}))
write.csv(rows, "Hanson_etal_2018_Table3.csv", row.names = FALSE, na = "NA")
cat("Table 3:", nrow(rows), "analysis-ready rows\n")


## ---- public TSV (database online copy) ----
## Written into <repo-root>/__Public/comparative-data when run inside the repo (root = has __ReadMe.xlsx).
.tsv_base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
if (!is.na(.tsv_base)) {
  .td <- file.path(.tsv_base, "__Public", "comparative-data")
  if (!dir.exists(.td)) dir.create(.td, recursive = TRUE)
  write.table(rows, file.path(.td, "10.1002%2Fdneu.22554_Table3.tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA", eol = "\n")
}
