#!/usr/bin/env Rscript
args <- grep("^--file=",commandArgs(FALSE),value=TRUE)
base <- dirname(dirname(normalizePath(sub("^--file=","",args[1]))))
specs <- jsonlite::fromJSON(file.path(base,"_keys/source_builds/nick_fran_2026.json"),simplifyVector=FALSE)
source(file.path(base,"_helpers/build_source_table.R"))
for(x in specs) build_source_table(file.path(base,x$folder),x$item,base)
source(file.path(base,"_helpers/compile_source_additions.R"))
for(domain in c("taste","social_mirror_play","claustrum_cerebellar")) compile_source_additions(base,domain)
for(script in c("_keys/build_variable_catalog.R","__ShinyApp/build_data.R")) {
 status<-system2(file.path(R.home("bin"),"Rscript"),shQuote(file.path(base,script)))
 if(status!=0) stop("Build failed: ",script)
}
