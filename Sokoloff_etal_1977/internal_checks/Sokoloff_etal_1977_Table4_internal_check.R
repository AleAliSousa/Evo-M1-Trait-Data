# Sokoloff_etal_1977_Table4_internal_check.R ------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Sokoloff et al. (1977), J Neurochem
# 28: 897-916. The Control (conscious, 30 min, n = 6) column of TABLE 4 (p. 913) is
# compared, structure by structure, with the 30 min (n = 10) column of TABLE 3 (p. 912),
# both read from THEIR frozen snapshots. The two columns come from DIFFERENT groups of
# conscious rats measured the same way, so agreement is expected only within sampling
# error: the tolerance is 2 x sqrt(SEM3^2 + SEM4^2) per structure (a ~95% band for the
# difference of two independent means), and the result is descriptive, not a transcription
# test. All 25 Table 4 structures (21 gray + 4 white) are also printed in Table 3, which
# adds 8 gray structures (Olfactory and Frontal cortex, Mamillary body, Dentate gyrus,
# Septal nucleus, Nucleus accumbens, Globus-pallidus, Substantia nigra).
#
# Read-only: reads the two snapshots in the paper folder, writes only
# Sokoloff_etal_1977_Table4_internal_check.csv next to this script. It never changes a
# value; a difference beyond tolerance is warned and kept as printed.

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
paper_dir <- dirname(folder)

read_snapshot <- function(file) {
  x <- read.csv(file, header = FALSE, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
strip_marks <- function(x) trimws(sub("([†*]+)$", "", x))
mean_of <- function(x) as.numeric(trimws(sub("\\s*±.*$", "", strip_marks(x))))
sem_of  <- function(x) as.numeric(trimws(sub("^.*±\\s*", "", strip_marks(x))))

s3 <- read_snapshot(file.path(paper_dir, "Sokoloff_etal_1977_Table3_snapshot.csv"))
s4 <- read_snapshot(file.path(paper_dir, paste0(base, "_snapshot.csv")))
stopifnot(identical(dim(s3), c(43L, 3L)), identical(dim(s4), c(36L, 4L)))
r3 <- which(grepl("±", s3[, 2])); r4 <- which(grepl("±", s4[, 2]))
t3 <- data.frame(structure = gsub("\n", " ", s3[r3, 1], fixed = TRUE),
                 m3 = mean_of(s3[r3, 2]), se3 = sem_of(s3[r3, 2]), stringsAsFactors = FALSE)
t4 <- data.frame(structure = gsub("\n", " ", s4[r4, 1], fixed = TRUE),
                 m4 = mean_of(s4[r4, 2]), se4 = sem_of(s4[r4, 2]), stringsAsFactors = FALSE)
stopifnot(nrow(t3) == 33L, nrow(t4) == 25L)
m <- merge(t4, t3, by = "structure", sort = FALSE)
stopifnot(nrow(m) == 25L)          # all 25 Table 4 structures are printed in Table 3
m <- m[match(t4$structure[t4$structure %in% m$structure], m$structure), ]

tol <- 2 * sqrt(m$se3^2 + m$se4^2)
status <- ifelse(abs(m$m4 - m$m3) <= tol + 1e-9, "pass", "mismatch")
internal_checks <- data.frame(
  check_id = paste0("control_vs_table3_30min_", seq_len(nrow(m))),
  basis = paste0("Table 4 Control (n = 6) vs Table 3 30 min (n = 10): ", m$structure),
  observed = m$m4, printed = m$m3, difference = m$m4 - m$m3, tolerance = round(tol, 2),
  status = status,
  note = sprintf("Table 4 %g ± %g; Table 3 %g ± %g; percent difference %+.1f%%; different animal groups",
                 m$m4, m$se4, m$m3, m$se3, 100 * (m$m4 - m$m3) / m$m3),
  stringsAsFactors = FALSE)
internal_checks <- rbind(internal_checks, data.frame(
  check_id = "control_vs_table3_30min_summary",
  basis = "25 shared structures: mean of (Table 4 control - Table 3 30 min); printed = 0 (same-population expectation)",
  observed = mean(m$m4 - m$m3), printed = 0, difference = mean(m$m4 - m$m3),
  tolerance = NA_real_, status = "not_evaluable",
  note = sprintf("mean abs difference %.2f umol/100 g/min; mean percent difference %+.1f%%; range of differences %g to %g; Spearman rho of the 25 means %.3f; %d of 25 within 2 x pooled SEM",
                 mean(abs(m$m4 - m$m3)), mean(100 * (m$m4 - m$m3) / m$m3), min(m$m4 - m$m3), max(m$m4 - m$m3),
                 cor(m$m4, m$m3, method = "spearman"), sum(status == "pass")),
  stringsAsFactors = FALSE))

tally <- table(factor(internal_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": internal checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
bad <- internal_checks[internal_checks$status == "mismatch", ]
for (i in seq_len(nrow(bad)))
  warning(sprintf("%s: %s observed %g vs printed %g (diff %g, tol %g)", bad$check_id[i], bad$basis[i],
                  bad$observed[i], bad$printed[i], bad$difference[i], bad$tolerance[i]), call. = FALSE)
message(internal_checks$note[nrow(internal_checks)])
write.csv(internal_checks, paste0(base, "_internal_check.csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
