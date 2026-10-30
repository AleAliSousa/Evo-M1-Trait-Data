## Reader for Kruska_Rohrs_1974_Table2. Reads the frozen snapshot only; no table values are typed in this script.
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
population <- "feral pig (Galapagos Islands)"
raw <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
                       colClasses = "character", check.names = FALSE, na.strings = NULL,
                       fileEncoding = "UTF-8", stringsAsFactors = FALSE)
cell_label <- trimws(raw[[1]])
num <- function(x) { y <- suppressWarnings(as.numeric(x)); stopifnot(!anyNA(y)); y }

hdr <- which(cell_label == "Structure")
stopifnot(length(hdr) == 1L)
spec_col <- which(seq_len(ncol(raw)) > 1L & nzchar(trimws(unlist(raw[hdr, ]))))
spec_id  <- trimws(unlist(raw[hdr, spec_col]))
stopifnot(!anyDuplicated(spec_id))
i_bw <- which(cell_label == "brain weight (g)")
i_bv <- which(cell_label == "brain volume (mm3)")
stopifnot(length(i_bw) == 1L, length(i_bv) == 1L, i_bw < i_bv)
spec <- data.frame(specimen_id = spec_id,
                   brain_weight_g = num(unlist(raw[i_bw, spec_col])),
                   brain_volume_mm3 = num(unlist(raw[i_bv, spec_col])), stringsAsFactors = FALSE)
body <- seq.int(hdr + 1L, i_bw - 1L)
body <- body[nzchar(cell_label[body])]
long <- do.call(rbind, lapply(body, function(i) {
  data.frame(population = population, specimen_id = spec_id,
             structure_as_printed = cell_label[i],
             volume_mm3 = num(unlist(raw[i, spec_col])), stringsAsFactors = FALSE)
}))
result <- cbind(long, spec[match(long$specimen_id, spec$specimen_id), c("brain_weight_g", "brain_volume_mm3")])
stopifnot(nrow(result) == length(spec_id) * length(body))
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
