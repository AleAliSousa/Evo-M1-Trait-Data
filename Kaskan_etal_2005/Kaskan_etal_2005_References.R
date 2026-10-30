## Full references corresponding to the a-t citation key in Kaskan Table S1
.sp <- local({ a<-grep("^--file=",commandArgs(FALSE),value=TRUE); if(length(a)) return(normalizePath(sub("^--file=","",a[1]))); if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))}; stop("Run with Rscript or Source") })
folder<-dirname(.sp); setwd(folder)
snap<-read.csv("Kaskan_etal_2005_References_snapshot.csv",check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(snap)==20L,identical(snap$ref,letters[1:20]),all(nzchar(snap$full_reference)))
write.csv(snap,"Kaskan_etal_2005_References.csv",row.names=FALSE,na="NA")
message("Kaskan_etal_2005_References: 20 keyed references written")
