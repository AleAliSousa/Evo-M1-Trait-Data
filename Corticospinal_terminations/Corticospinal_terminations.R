#!/usr/bin/env Rscript
# Curated, conservative CST/CM termination compilation.

suppressWarnings(suppressMessages({library(readxl); library(writexl)}))
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript Corticospinal_terminations.R", call. = FALSE)
})
paper_dir <- dirname(.sp)
root <- normalizePath(file.path(paper_dir, ".."))

d <- as.data.frame(read_excel(file.path(paper_dir, "Corticospinal_terminations_snapshot.xlsx"),
                              sheet = "Table1"), check.names = FALSE)
required <- c("Species_printed", "species_sci", "CST_termination_grade",
              "CM_monosynaptic", "CM_connection_inference", "Source", "DOI",
              "Source_location", "Evidence_summary")
missing <- setdiff(required, names(d))
if (length(missing)) stop("Snapshot is missing: ", paste(missing, collapse = ", "))
if (any(!d$CST_termination_grade %in% 0:2)) stop("CST grades must be integers 0, 1, or 2")

write.csv(d, file.path(paper_dir, "Corticospinal_terminations.csv"),
          row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
public <- file.path(root, "__Public", "comparative-data",
                    "COMPILATION%3ACorticospinal_terminations_Table1.tsv")
write.table(d, public, sep = "\t", row.names = FALSE, na = "NA", quote = TRUE,
            fileEncoding = "UTF-8")

trait <- d[, c("species_sci", "Species_printed", "CST_termination_grade",
                "CM_monosynaptic", "CM_connection_inference", "Source", "DOI",
                "Source_location")]
names(trait)[names(trait) == "Species_printed"] <- "Species"
write_xlsx(trait, file.path(root, "____EvoM1_TraitTable", "corticospinal_terminations.xlsx"))
cat(sprintf("CST compilation: %d species; grades %s\n", nrow(d),
            paste(sort(unique(d$CST_termination_grade)), collapse = ", ")))
