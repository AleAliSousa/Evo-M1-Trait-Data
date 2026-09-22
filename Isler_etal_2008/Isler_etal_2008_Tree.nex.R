## Isler et al. (2008), phylogenetic tree in NEXUS format.
## Build step only: frozen NEXUS snapshot -> local item -> encoded public item.

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
folder <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp)) # Isler_etal_2008_Tree.nex
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot <- file.path(folder, "Isler_etal_2008_Tree_snapshot.nex")
stopifnot(file.exists(snapshot), file.info(snapshot)$size > 0)
raw <- readBin(snapshot, what = "raw", n = file.info(snapshot)$size)
local_file <- file.path(folder, item_name)
con <- file(local_file, "wb"); writeBin(raw, con); close(con)
stopifnot(identical(unname(tools::md5sum(snapshot)), unname(tools::md5sum(local_file))))

if (is.na(base)) {
  warning("Repository root containing __ReadMe.xlsx not found; public NEXUS skipped.")
} else {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  out_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public NEXUS skipped.")
  } else if (!dir.exists(out_dir)) {
    warning("Shared folder not found: ", out_dir, "; public NEXUS skipped.")
  } else {
    out <- file.path(out_dir, item_encoded)
    con <- file(out, "wb"); writeBin(raw, con); close(con)
    stopifnot(identical(unname(tools::md5sum(snapshot)), unname(tools::md5sum(out))))
    message("Wrote byte-identical ", out)
  }
}
