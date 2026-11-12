# Andersen_etal_1992_Table6_internal_check.R -----------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Andersen, Korbo & Pakkenberg (1992),
# J Comp Neurol 326: 549-560, TABLE 6 "Total Number of Six Cell Types in Four Different
# Regions (10^6)" (p. 559).
#
# Re-adds the four regions per cell type (Table 6 snapshot) and compares the sum with the
# Mean row of the sibling item Andersen_etal_1992_Table4 (read from ITS frozen snapshot):
# the four regions together make up the cerebellar cortex (Table 5), same five brains.
# Tolerance: half a unit of the last significant printed digit of each regional value plus
# half a unit of the printed Table 4 mean.
#
# Read-only: reads the two frozen snapshots in the paper folder, writes only
# Andersen_etal_1992_Table6_internal_check.csv next to this script. It never changes a
# value; a mismatch is warned and kept as printed. The item script
# Andersen_etal_1992_Table6.R reads only its own snapshot.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder)                       # <Paper>/internal_checks
item_name <- sub("_internal_check\\.R$", "", basename(.sp))
base <- item_name
paper <- basename(dirname(folder))
paper_dir <- dirname(folder)                                # snapshots live in the paper folder

## ---- read the frozen snapshots (positional; every cell as printed text) -------
read_snap <- function(file) {
  x <- as.matrix(read.csv(file.path(paper_dir, file), header = FALSE,
                          colClasses = "character", na.strings = character(0),
                          check.names = FALSE, fileEncoding = "UTF-8"))
  dimnames(x) <- NULL
  x
}
snap <- read_snap(paste0(base, "_snapshot.csv"))
t4   <- read_snap("Andersen_etal_1992_Table4_snapshot.csv")

## ---- helpers (as in Andersen_etal_1992_Table6.R) -------------------------------
na_tokens <- c("", "-", "\u2013", "\u2014", "NA", "n.a.", "__", "e")
cell_value <- function(x) {
  v <- trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x))
  out <- suppressWarnings(as.numeric(gsub(",", "", v)))
  out[v %in% na_tokens] <- NA_real_
  out
}
cell_value_string <- function(x) gsub(",", "", trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x)))
## half a unit in the last significant printed digit ("34,000" -> 500; "0.042" -> 0.0005)
half_unit <- function(s) {
  s <- cell_value_string(s)
  ifelse(grepl("\\.", s), 0.5 * 10^-nchar(sub("^.*\\.", "", s)),
         0.5 * 10^(nchar(s) - nchar(sub("0+$", "", s))))
}
tc_row <- function(check_id, basis, observed, printed, tolerance, note = "") {
  d <- observed - printed
  data.frame(check_id = check_id, basis = basis, observed = observed, printed = printed,
             difference = d, tolerance = tolerance,
             status = ifelse(is.na(d), "not_evaluable",
                             ifelse(abs(d) <= tolerance + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

stopifnot(ncol(snap) == 5L, nrow(snap) == 9L)
stopifnot(identical(snap[2, ], c("Cell types", "Pars anterior", "Vermis",
                                 "Flocculonodular lobe", "Pars posterior")))
cells <- snap[3:8, 1]
stopifnot(identical(cells, c("Granule", "Purkinje", "Golgi", "Glial in granular layer",
                             "Glial in molecular layer", "Neurons in molecular layer")))
body <- snap[3:8, 2:5, drop = FALSE]

## ---- cross-item check ------------------------------------------------------------
stopifnot(t4[8, 1] == "Mean")
t4_col <- c(Granule = "Granule", Purkinje = "Purkinje", Golgi = "Golgi/g",
            `Glial in granular layer` = "Glial/g", `Glial in molecular layer` = "Glial/m",
            `Neurons in molecular layer` = "Neurons/m")
table_checks <- do.call(rbind, lapply(seq_along(cells), function(i) {
  m_str <- t4[8, match(t4_col[[cells[i]]], t4[2, ])]
  tc_row(paste0("region_sum_", gsub(" ", "_", cells[i])),
         paste0("sum of 4 regions, row '", cells[i], "' vs Table 4 Mean, column '",
                t4_col[[cells[i]]], "' (10^6)"),
         sum(cell_value(body[i, ])), cell_value(m_str),
         sum(half_unit(body[i, ])) + half_unit(m_str),
         "cross-table: reads Andersen_etal_1992_Table4_snapshot.csv")
}))

## ---- output: this check's own CSV (never a snapshot, analysis CSV or TSV) ------
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": internal check  pass=", tally[[1]], "  mismatch=", tally[[2]],
        "  not_evaluable=", tally[[3]])
if (tally[[2]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$basis[i], bad$observed[i], bad$printed[i], bad$difference[i],
                    bad$tolerance[i]), call. = FALSE)
}
write.csv(table_checks, paste0(base, "_internal_check.csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(table_checks), " checks written to ", base, "_internal_check.csv")
