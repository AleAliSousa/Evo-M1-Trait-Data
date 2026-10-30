if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl")
if (!requireNamespace("readr", quietly = TRUE)) stop("Install readr")

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p))
      p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p))
      return(normalizePath(p))
  }
  
  stop("Cannot determine script path.")
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))

snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
output_file   <- file.path(folder, paste0(item_name, ".csv"))

x <- readxl::read_excel(snapshot_file, skip = 1)

readr::write_csv(x, output_file, na = "")

message("Built ", nrow(x), " reported-result records")