# Rebuild this domain from registered source items.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if(!length(a)) stop("Run this domain builder with Rscript")
base <- dirname(dirname(normalizePath(sub("^--file=","",a[1]))))
source(file.path(base,"_helpers/compile_source_additions.R"))
compile_source_additions(base,"claustrum_cerebellar")
