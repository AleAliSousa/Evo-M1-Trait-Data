options(stringsAsFactors = FALSE)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' is required")
input <- file.path("snapshot", "Table_S5_MERFISH_snRNA_prop_EI.xlsx")
x <- readxl::read_excel(input, sheet = "MERFISH")
x <- tidyr::pivot_longer(x, cols = -c(Area, Metric, Grouping), names_to = "donor", values_to = "value", values_drop_na = TRUE)
x$Grouping <- trimws(gsub(" ", " ", x$Grouping, fixed = TRUE))
x <- x[, c("donor", "Area", "Metric", "Grouping", "value")]
write.csv(x, "Jorstad_etal_2023_Table_S5_MERFISH.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.table(x, "Jorstad_etal_2023_Table_S5_MERFISH_public.tsv", sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
