# Audit the frozen transcription against the existing full-paper Excel export.
suppressPackageStartupMessages(library(readxl))

.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
comparison_dir <- dirname(.sp)
paper_dir <- dirname(comparison_dir)
snapshot <- read.csv(file.path(paper_dir, "Ebinger__1974_Tables3-4_snapshot.csv"),
                     check.names = FALSE, stringsAsFactors = FALSE)
raw <- read_excel(file.path(comparison_dir, "Ebinger-1974-A cytoarchitectonic.xlsx"),
                  sheet = "Sheet1", col_names = FALSE, col_types = "text")

num <- function(x) {
  x <- trimws(as.character(x))
  x[x == "J2879"] <- "12879" # OCR/export artifact; rendered Table 4 prints 12879
  suppressWarnings(as.numeric(gsub("[^0-9.]", "", x)))
}

# Rows 3:28 are the 26 measures.  Table 3 occupies cols 1 + 5:8;
# Table 4 occupies cols 9 + 10:15 in the existing Adobe export.
wild <- raw[3:28, c(1, 5:8)]
domestic <- raw[3:28, c(9, 10:15)]
names(wild) <- c("measure", "M1", "M2", "M3", "M4")
names(domestic) <- c("measure", "Sk1", "Sk2", "Sk3", "H1", "H2", "H3")

report <- list()
for (id in c("M1", "M2", "M3", "M4", "Sk1", "Sk2", "Sk3", "H1", "H2", "H3")) {
  ref <- if (id %in% names(wild)) num(wild[[id]]) else num(domestic[[id]])
  got <- as.numeric(snapshot[[id]])
  report[[id]] <- data.frame(
    individual = id, measure_printed = snapshot$measure_printed,
    snapshot_value = got, export_value = ref,
    difference = got - ref, match = is.na(got) & is.na(ref) | got == ref,
    stringsAsFactors = FALSE
  )
}
report <- do.call(rbind, report)
mismatches <- report[!report$match, , drop = FALSE]
write.csv(report, file.path(comparison_dir, "Ebinger__1974_Tables3-4_comparison_report_from_R.csv"), row.names = FALSE)
write.csv(mismatches, file.path(comparison_dir, "Ebinger__1974_Tables3-4_comparison_mismatches_from_R.csv"), row.names = FALSE)
if (nrow(mismatches)) stop(nrow(mismatches), " mismatch(es) against the existing Excel export")
message("Ebinger comparison: ", nrow(report), " values checked, 0 mismatches")
