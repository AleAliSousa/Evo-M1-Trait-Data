# Run from repository root: Rscript _checks/social_variables/load_app.R OUTPUT.rds
repo <- normalizePath(getwd())
Sys.setenv(EVOM1_SOURCE='local')
setwd(file.path(repo,'__ShinyApp'))
s <- readLines('app.R'); cut <- grep('^shinyApp\\(',s)
e <- new.env(parent=globalenv())
eval(parse(text=paste(s[seq_len(cut-1)],collapse='\n')),envir=e)
saveRDS(e$compiled,commandArgs(TRUE)[1])
