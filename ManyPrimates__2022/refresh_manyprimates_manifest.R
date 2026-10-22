suppressPackageStartupMessages(library(readr))
a<-grep("^--file=",commandArgs(FALSE),value=TRUE)
here<-if(length(a))dirname(normalizePath(sub("^--file=","",a[1])))else getwd();repo<-dirname(here)
meta<-read_csv(file.path(here,"ManyPrimates_source_metadata.csv"),show_col_types=FALSE)
p<-file.path(repo,"__ShinyApp/data/source_manifest.csv");m<-read_csv(p,trim_ws=FALSE,col_types=cols(.default=col_character()),show_col_types=FALSE);m<-m[!m$file%in%paste0(meta$encoded,".tsv"),]
for(i in seq_len(nrow(meta))){x<-meta[i,];f<-paste0(x$encoded,".tsv");d<-read_tsv(file.path(repo,"__Public/comparative-data",f),show_col_types=FALSE);r<-as.data.frame(as.list(setNames(rep("",ncol(m)),names(m))));r$file<-f;r$identifier<-x$doi;r$id_type<-"DOI";r$table_label<-x$locus;r$url<-paste0("https://doi.org/",x$doi);r$readme<-paste0(x$encoded,".README.txt");r$n_rows<-as.character(nrow(d));r$n_cols<-as.character(ncol(d));r$columns<-paste(names(d),collapse="; ");r$citation<-x$citation;r$citation_short<-gsub("_"," ",x$folder);r$first_author<-sub("_.*","",x$folder);r$year<-sub(".*_([0-9]{4}).*","\\1",x$folder);m<-rbind(m,r)
 src<-file.path(repo,x$folder,paste0(x$item,".README.md"));file.copy(src,file.path(repo,"__Public/comparative-data",r$readme),overwrite=TRUE)
 dest<-file.path(repo,"__ShinyApp/data/source-tables");dir.create(dest,recursive=TRUE,showWarnings=FALSE);file.copy(src,file.path(dest,r$readme),overwrite=TRUE)
}
write_csv(m,p,na="")
