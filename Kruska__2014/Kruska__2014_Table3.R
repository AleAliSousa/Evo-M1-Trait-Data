## Reader for Kruska__2014_Table3. Reads the frozen snapshot only; no table values are typed in this script.
## Written 2026-10-17 by an AI assistant from the frozen snapshot; not yet run in RStudio.
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
population <- "guinea pig"
raw <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
                       colClasses = "character", check.names = FALSE, na.strings = NULL,
                       fileEncoding = "UTF-8", stringsAsFactors = FALSE)
cell_label <- trimws(raw[[1]])
num <- function(x) { y <- suppressWarnings(as.numeric(x)); stopifnot(!anyNA(y)); y }

hdr <- which(cell_label == "Prep. no./sex")
stopifnot(length(hdr) == 1L)
spec_col <- which(seq_len(ncol(raw)) > 1L & nzchar(trimws(unlist(raw[hdr, ]))))
spec_raw <- trimws(unlist(raw[hdr, spec_col]))
spec_id  <- sub(" [MF]$", "", spec_raw)
spec_sex <- sub("^.* ", "", spec_raw)
stopifnot(all(spec_sex %in% c("M", "F")), !anyDuplicated(spec_id))
get_row <- function(lbl) {
  i <- which(cell_label == lbl); stopifnot(length(i) == 1L)
  unlist(raw[i, spec_col])
}
## "value" or "value (percent)"; anything else stops the script.
parse_cell <- function(x) {
  m <- regmatches(x, regexec("^([0-9]+(?:\\.[0-9]+)?)(?: \\(([0-9]+(?:\\.[0-9]+)?)\\))?$", x, perl = TRUE))
  stopifnot(all(lengths(m) > 0))
  t(sapply(m, function(z) c(as.numeric(z[2]), if (nzchar(z[3])) as.numeric(z[3]) else NA_real_)))
}
tbw   <- num(get_row("Total brain weight"))
tbv   <- num(get_row("Total brain volume"))
rest  <- num(get_row("Rest tissue"))
vent  <- num(get_row("Ventricle"))
pure  <- parse_cell(get_row("Pure brain tissue"))[, 1]
i_pure <- which(cell_label == "Pure brain tissue"); stopifnot(length(i_pure) == 1L)
i_note <- which(startsWith(cell_label, "Percentages"))
last   <- if (length(i_note)) i_note[1] - 1L else nrow(raw)
body   <- seq.int(i_pure + 1L, last)
body   <- body[nzchar(cell_label[body])]
spec <- data.frame(specimen_id = spec_id, sex = spec_sex, total_brain_weight_g = tbw,
                   total_brain_volume_mm3 = tbv, rest_tissue_mm3 = rest, ventricle_mm3 = vent,
                   pure_brain_tissue_mm3 = pure, stringsAsFactors = FALSE)
long <- do.call(rbind, lapply(body, function(i) {
  pv <- parse_cell(unlist(raw[i, spec_col]))
  data.frame(population = population, specimen_id = spec_id, sex = spec_sex,
             structure_as_printed = cell_label[i], volume_mm3 = pv[, 1],
             pct_of_pure_brain_printed = pv[, 2], stringsAsFactors = FALSE)
}))
result <- cbind(long, spec[match(long$specimen_id, spec$specimen_id),
                           c("total_brain_weight_g", "total_brain_volume_mm3", "rest_tissue_mm3",
                             "ventricle_mm3", "pure_brain_tissue_mm3")])
## Checks: the printed header arithmetic must close, and every specimen must carry every structure row.
stopifnot(all(abs(spec$total_brain_volume_mm3 - spec$rest_tissue_mm3 - spec$ventricle_mm3 -
                  spec$pure_brain_tissue_mm3) < 0.01),
          nrow(result) == length(spec_id) * length(body))
message("Structure rows per specimen: ", length(body))

out_path <- file.path(folder, paste0(item_name, ".csv"))
utils::write.csv(result, out_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("Wrote ", nrow(result), " rows to ", out_path)

## Public TSV (registry Item encoded = file stem). Written automatically, per owner decision 2026-10-16.
local({
  root <- folder
  while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root) root <- dirname(root)
  reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit <- which(reg[["Item name"]] == item_name)
  stopifnot(length(hit) == 1L)
  enc <- as.character(reg[["Item encoded"]][hit])
  stopifnot(!is.na(enc), nzchar(enc), !grepl("_$", enc))
  pub <- file.path(root, "__Public", "comparative-data")
  stopifnot(dir.exists(pub))
  utils::write.table(result, file.path(pub, paste0(enc, ".tsv")), sep = "\t",
                     row.names = FALSE, na = "", fileEncoding = "UTF-8")
})
