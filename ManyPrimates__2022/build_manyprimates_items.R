suppressPackageStartupMessages(library(readr))
a<-grep("^--file=",commandArgs(FALSE),value=TRUE)
here<-if(length(a))dirname(normalizePath(sub("^--file=","",a[1])))else getwd()
repo<-dirname(here)
catalog<-read_csv(file.path(here,"ManyPrimates_built_items.csv"),show_col_types=FALSE)
# Select the identity workbook for each batch until registered in the live workbook.
for(i in seq_len(nrow(catalog))){
 it<-catalog$item[i];supp<-it%in%c("Kamilar_Cooper_2013_S2","Nunn_Samson_2018_SupplementaryTable1","Grueter_etal_2013_TableS1")
 Sys.setenv(DATASET_REGISTRY=file.path(here,if(supp)"ManyPrimates_supplements_build_registry.xlsx"else"ManyPrimates_all_items_build_registry.xlsx"))
 source(file.path(repo,catalog$reader[i]),local=new.env())
}
Sys.unsetenv("DATASET_REGISTRY")
source(file.path(repo,"__merging_supplementary/supplementary_compiled.R"),local=new.env())
