## Karlsen & Pakkenberg 2011 - author-provided neocortical stereology workbooks
## Two complete, sanitized workbook snapshots -> group-level analysis-ready CSV.
## Counts in the workbooks are one hemisphere and are multiplied by 2 (bilateral),
## as instructed by B. Pakkenberg. Densities and ratios are hemisphere-invariant.

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
folder <- dirname(.sp)
setwd(folder)
options(scipen = 999, stringsAsFactors = FALSE)
suppressMessages(library(readxl))

files <- c(
  Control = "Karlsen_Pakkenberg_2011_authordata_control_snapshot.xlsx",
  DS = "Karlsen_Pakkenberg_2011_authordata_DS_snapshot.xlsx"
)
regions <- data.frame(
  Region = c("Frontal", "Temporal", "Parietal", "Occipital", "Neocortex total"),
  npref = c("F", "T", "P", "O", "Ne"),
  gpref = c("Fr", "Te", "Pa", "Oc", "Ne"),
  stringsAsFactors = FALSE
)

parse_workbook <- function(path, group) {
  if (!file.exists(path)) stop("Missing snapshot: ", path, call. = FALSE)
  if (!"Summ" %in% excel_sheets(path)) stop("Snapshot lacks 'Summ' sheet: ", path, call. = FALSE)
  M <- as.matrix(suppressWarnings(read_excel(path, sheet = "Summ", col_names = FALSE,
                                             .name_repair = "minimal")))
  M[is.na(M)] <- ""
  labels <- trimws(paste(M[, 1], M[, 2], M[, 3]))
  code_rows <- which(apply(M, 1, function(r) any(r == "Code")) & seq_len(nrow(M)) > 40)
  if (length(code_rows) != 1L) stop("Expected one specimen-code row in ", path, call. = FALSE)
  code_row <- code_rows[1]
  code_cols <- which(nzchar(M[code_row, ]) & !M[code_row, ] %in% c("0", "Code"))
  code_cols <- code_cols[code_cols >= 4]
  codes <- as.character(M[code_row, code_cols])
  expected <- if (group == "Control") paste0("A", 1:6) else paste0("B", 1:4)
  keep <- codes %in% expected
  code_cols <- code_cols[keep]
  codes <- codes[keep]
  if (!identical(codes, expected)) {
    stop("Unexpected specimen codes in ", path, ": ", paste(codes, collapse = ", "), call. = FALSE)
  }
  get_row <- function(label) {
    idx <- which(labels == label)
    if (length(idx) != 1L) stop("Expected one row labelled '", label, "' in ", path, call. = FALSE)
    suppressWarnings(as.numeric(M[idx, code_cols]))
  }
  out <- vector("list", nrow(regions))
  for (i in seq_len(nrow(regions))) {
    np <- regions$npref[i]
    gp <- regions$gpref[i]
    out[[i]] <- data.frame(
      Group = group,
      Brain = codes,
      Region = regions$Region[i],
      Volume_hemisphere.cm3 = get_row(paste0(np, " V cm3")),
      Neuron_N.x10.9 = get_row(paste0(np, " N 10^9")) * 2,
      Neuron_density.x10.6.per.cm3 = get_row(paste0(np, " NV Mcm-3")),
      Astrocyte_N.x10.9 = get_row(paste0(gp, "Ast N")) * 2,
      Astrocyte_density.x10.6.per.cm3 = get_row(paste0(gp, "Ast NV")),
      Oligodendrocyte_N.x10.9 = get_row(paste0(gp, "Oli N")) * 2,
      Oligodendrocyte_density.x10.6.per.cm3 = get_row(paste0(gp, "Oli NV")),
      Microglia_N.x10.9 = get_row(paste0(gp, "Mic N")) * 2,
      Microglia_density.x10.6.per.cm3 = get_row(paste0(gp, "Mic NV")),
      Glia_N.x10.9 = get_row(paste0(gp, "_Gl N")) * 2,
      Glia_density.x10.6.per.cm3 = get_row(paste0(gp, "_Gl NV")),
      Glia_Neuron_ratio = get_row(paste0(gp, "_Gl Gl/Ne")),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }
  do.call(rbind, out)
}

individual <- do.call(rbind, Map(parse_workbook, files, names(files)))
measure_cols <- setdiff(names(individual), c("Group", "Brain", "Region"))
final <- aggregate(individual[measure_cols],
                   by = list(Group = individual$Group, Region = individual$Region),
                   FUN = function(x) mean(x, na.rm = TRUE))
counts <- tapply(individual$Brain, individual$Group, function(x) length(unique(x)))
final$n_brains <- as.integer(counts[final$Group])
for (nm in measure_cols) final[[nm]] <- round(final[[nm]], 4)
final$Region <- factor(final$Region, levels = regions$Region)
final$Group <- factor(final$Group, levels = c("Control", "DS"))
final <- final[order(final$Region, final$Group), ]
final$Region <- as.character(final$Region)
final$Group <- as.character(final$Group)
final <- final[, c("Group", "Region", measure_cols, "n_brains")]

stopifnot(nrow(final) == 10L,
          identical(sort(unique(final$n_brains)), c(4L, 6L)))
write.csv(final, "Karlsen_Pakkenberg_2011_authordata.csv", row.names = FALSE, na = "NA")

root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (!is.na(root)) {
  tsv <- file.path(root, "__Public", "comparative-data",
                   "10.1093%2Fcercor%2Fbhr033_authordata(groupmeans).tsv")
  write.table(final, tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "NA", eol = "\n")
}
cat("Wrote", nrow(final), "group-by-region rows from",
    length(unique(individual$Brain)), "brains.\n")
