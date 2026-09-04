options(stringsAsFactors = FALSE)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' is required")
input <- file.path("snapshot", "Table_S5_MERFISH_snRNA_prop_EI.xlsx")
x <- readxl::read_excel(input, sheet = "snRNA_EI")
# Rows and columns retained unchanged
write.csv(x, "Jorstad_etal_2023_Table_S5_snRNA_EI.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.table(x, "Jorstad_etal_2023_Table_S5_snRNA_EI_public.tsv", sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
