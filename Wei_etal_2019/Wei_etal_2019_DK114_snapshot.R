## Freeze the authors' deposited DK114 CSV byte-for-byte as this item's source.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp); item <- sub("_snapshot\\.R$", "", basename(sp))
source <- file.path(folder,"dutchconnectomelab_download","chimp2humanDK114.csv")
dest <- file.path(folder,paste0(item,"_snapshot.csv"))
bytes <- readBin(source,"raw",n=file.info(source)$size)
if (file.exists(dest)) {
  stopifnot(identical(bytes,readBin(dest,"raw",n=file.info(dest)$size)))
  message("Frozen snapshot matches source CSV: ",dest)
} else {
  writeBin(bytes,dest)
  message("Frozen snapshot copied from source CSV: ",dest)
}
