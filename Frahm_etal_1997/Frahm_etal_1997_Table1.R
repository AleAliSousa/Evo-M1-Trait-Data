## Frahm, Rehkamper & Nevo (1997), printed Tables 1 and 2.
## The one workbook preserves each table on its own sheet; this reader joins
## the printed group means by group label and does all analysis reshaping.
options(scipen = 999)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required")
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(.sp)
item <- tools::file_path_sans_ext(basename(.sp))
book <- file.path(folder, paste0(item, "_snapshot.xlsx"))
read_table <- function(sheet, header) {
  x <- as.data.frame(readxl::read_excel(book, sheet = sheet, col_names = FALSE,
                                        col_types = "text"), stringsAsFactors = FALSE)
  x[is.na(x)] <- ""
  stopifnot(nrow(x) == 25L, ncol(x) == length(header),
            identical(as.character(x[2, ]), header),
            x[3, 1] == "Spalax", x[15, 1] == "Rattus",
            x[12, 1] == "(n=8)", x[24, 1] == "(n=8)",
            x[13, 1] == "±SD", x[25, 1] == "±SD",
            all(x[14, ] == ""))
  list(data = x, mean = x[c(12, 24), , drop = FALSE],
       sd = x[c(13, 25), , drop = FALSE])
}
t1 <- read_table("Table1", c("No", "Body (in g)", "Brain (in mg)", "Tegmentum",
                              "Cerebellum", "Tectum", "Diencephalon", "Telencephalon"))
t2 <- read_table("Table2", c("No", "Bulbus olfact.", "Paleo-cortex", "Amygdala",
                              "Septum", "Striatum", "Schizo-cortex", "Hippocampus", "Neo-cortex"))
stopifnot(grepl("^Table 1\\.", t1$data[1, 1]), grepl("^Table 2\\.", t2$data[1, 1]))
stopifnot(identical(as.character(t1$data[c(4:11, 16:23), 1]),
                    as.character(t2$data[c(4:11, 16:23), 1])))
num <- function(x) as.numeric(gsub(",", "", as.character(x), fixed = TRUE))

## Check the transcribed specimen values against the paper's printed group
## means and SDs. The printed Spalax diencephalon row is an exception: its
## eight visible cells yield 176.91 ± 29.30, whereas the summary prints
## 187.04 ± 11.15. Keep both as printed and use the published group summary.
for (tab in list(t1, t2)) {
  for (i in seq_along(c("Spalax", "Rattus"))) {
    rows <- if (i == 1L) 4:11 else 16:23
    for (j in 2:ncol(tab$data)) {
      if (identical(tab$data[1, 1], t1$data[1, 1]) && i == 1L && j == 7L) next
      vals <- num(tab$data[rows, j])
      printed_mean <- num(tab$mean[i, j])
      printed_sd <- num(tab$sd[i, j])
      mean_tol <- if (j <= 3L && identical(tab$data[1, 1], t1$data[1, 1])) 0.5 else 0.03
      sd_tol <- if (j <= 3L && identical(tab$data[1, 1], t1$data[1, 1])) 0.5 else 0.03
      stopifnot(abs(mean(vals) - printed_mean) <= mean_tol + 1e-8,
                abs(sd(vals) - printed_sd) <= sd_tol + 1e-8)
    }
  }
}

lookup <- read.csv(file.path(folder, "reference_tables", paste0(item, "_species_lookup.csv")),
                   stringsAsFactors = FALSE)
stopifnot(identical(lookup$printed_group, c("Spalax", "Rattus")))
## The two source sheets have the same specimen groups and source order.
clean <- data.frame(
  species = lookup$species,
  body_weight_g = num(t1$mean[, 2]),
  brain_weight_mg = num(t1$mean[, 3]),
  cerebellum_mm3 = num(t1$mean[, 5]),
  diencephalon_mm3 = num(t1$mean[, 7]),
  telencephalon_mm3 = num(t1$mean[, 8]),
  bulbus_olfactorius_mm3 = num(t2$mean[, 2]),
  septum_mm3 = num(t2$mean[, 5]),
  striatum_mm3 = num(t2$mean[, 6]),
  schizo_cortex_mm3 = num(t2$mean[, 7]),
  hippocampus_mm3 = num(t2$mean[, 8]),
  neocortex_mm3 = num(t2$mean[, 9]),
  palaeocortex_mm3 = num(t2$mean[, 3]),
  amygdala_mm3 = num(t2$mean[, 4]),
  source = sub("_Table[^_]*$", "", item),
  stringsAsFactors = FALSE
)
clean <- clean[order(clean$species), , drop = FALSE]
rownames(clean) <- NULL
write.csv(clean, file.path(folder, paste0(item, ".csv")), row.names = FALSE)
base <- dirname(folder)
if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
  codes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- codes$`Item encoded`[match(item, codes$`Item name`)]
  if (!is.na(encoded) && nzchar(encoded))
    write.table(clean, file.path(base, "__Public", "comparative-data", paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
}
