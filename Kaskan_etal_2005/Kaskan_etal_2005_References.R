## Full references corresponding to the a-t citation key in Kaskan Table S1
.sp <- local({ a<-grep("^--file=",commandArgs(FALSE),value=TRUE); if(length(a)) return(normalizePath(sub("^--file=","",a[1]))); if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))}; stop("Run with Rscript or Source") })
folder<-dirname(.sp); setwd(folder)
snap<-read.csv("Kaskan_etal_2005_References_snapshot.csv",check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(snap)==20L,identical(snap$ref,letters[1:20]),all(nzchar(snap$full_reference)))
write.csv(snap,"Kaskan_etal_2005_References.csv",row.names=FALSE,na="NA")
message("Kaskan_etal_2005_References: 20 keyed references written")

## Public TSV. `Item encoded` is read from __ReadMe.xlsx BY ITEM NAME -- the registry is the
## authority for the filename. file_list.R only INDEXES existing TSVs; it never writes one, so
## the earlier note deferring this to that pipeline meant the item never got a public copy.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (file.exists(file.path(root, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly = TRUE)) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- registry[["Item encoded"]][match("Kaskan_etal_2005_References", registry[["Item name"]])]
  if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
      !grepl("_$", item_encoded)) {
    tsv_dir <- file.path(root, "__Public", "comparative-data")
    dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
    write.table(snap, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t",
                row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
    message("Kaskan_etal_2005_References", ": public TSV ", item_encoded, ".tsv")
  } else {
    warning("Kaskan_etal_2005_References", ": no usable 'Item encoded' in __ReadMe.xlsx; run _tools/file_list.R first. ",
            "Public TSV not written.")
  }
}
