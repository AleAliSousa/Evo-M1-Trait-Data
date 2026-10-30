# Frozen source → analysis CSV → DOI-coded public TSV.
.sp <- local({
 a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
 if(length(a)) return(normalizePath(sub("^--file=","",a[1])))
 for(f in rev(sys.frames())) if(!is.null(f$ofile)) return(normalizePath(f$ofile))
 stop("Run with Rscript or source()")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
source(file.path(base,"_helpers","build_source_table.R"))
final.dataframe <- build_source_table(folder,item_name,base)
