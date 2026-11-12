## Frozen source -> analysis CSV + registry-coded public TSV.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error=function(e) NULL)
  if(!is.null(of) && nzchar(of)) return(normalizePath(of))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run this saved script with Rscript or Source it in RStudio")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
library(readxl)
filecodes <- read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1", col_types="text")
i <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
stopifnot(length(i)==1L)
item_encoded <- filecodes$`Item encoded`[i]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$",item_encoded))
tsv_dir <- file.path(base,"__Public","comparative-data")
source(file.path(base,"_keys","resolve_species.R"))
num <- function(x) suppressWarnings(as.numeric(gsub("[ ,]","",x)))

snap <- read_excel(file.path(folder,paste0(item_name,"_snapshot.xls")),sheet="Sheet1",col_names=FALSE,col_types="text",.name_repair="minimal")
stopifnot(nrow(snap)==447L,ncol(snap)==25L,
          snap[[19]][2]=="Brain size [g or cc]")
dat <- snap[3:nrow(snap),]
printed <- as.character(dat[[3]])
rs <- resolve_species(gsub("_"," ",printed,fixed=TRUE),source_publication=basename(folder))
final.dataframe <- data.frame(Species=rs$accepted_name,species_as_published=printed,
 group_as_published=dat[[1]],species_number=as.integer(dat[[2]]),source_excel_row=seq.int(3L,447L),
 allonursing=num(dat[[4]]),communal_nesting_babysitting_retrieval=num(dat[[5]]),protection=num(dat[[6]]),
 provisioning_male=num(dat[[7]]),provisioning_others=num(dat[[8]]),carrying_male=num(dat[[9]]),carrying_others=num(dat[[10]]),
 PC1=num(dat[[11]]),PC2=num(dat[[12]]),provisioning_mothers=num(dat[[13]]),gregariousness=num(dat[[14]]),
 diet_code=num(dat[[15]]),activity_code=num(dat[[16]]),substrate_code=num(dat[[17]]),
 body_mass_g=num(dat[[18]]),brain_size_as_published=as.character(dat[[19]]),brain_size_numeric=num(dat[[19]]),
 brain_size_unit_as_published="g or cc",brain_measurement_basis="unresolved_per_row",
 fertility_offspring_per_year=num(dat[[20]]),gestation_length_days=num(dat[[21]]),weaning_age_days=num(dat[[22]]),
 age_at_first_reproduction_years=num(dat[[23]]),maximum_lifespan_years=num(dat[[24]]),remarks=as.character(dat[[25]]),
 brain_body_source_ref_keys="Isler and van Schaik 2009a",brain_body_source_reference_id="doi:10.1016/j.jhevol.2009.04.009",
 source_granularity="secondary_compilation_primary_lineage_unresolved",primary_reference_id="",
 sex_scope="sex-specific preferred female per methods; per-row sex not supplied",
 data_role="secondary",primary_pool_eligible=FALSE,species_basis=rs$species_basis,reidentified=rs$reidentified,
 check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(final.dataframe)==445L,identical(final.dataframe$species_number,1:445),
          !anyNA(final.dataframe$brain_size_numeric),!anyDuplicated(printed))
## Do not convert the mixed g/cc column to mg or mm3 until its original type is established.

write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
## Reference links are reconstructed from the frozen source-scope/bibliography
## snapshots. This does not infer experimental primaries from author/year.
status <- system2(Sys.which("python3"), shQuote(file.path(folder,"Isler_vanSchaik_2012_build_references.py")))
stopifnot(status==0L)
final.dataframe <- read.csv(file.path(folder,paste0(item_name,".csv")),check.names=FALSE,stringsAsFactors=FALSE,
                           colClasses=c(brain_size_as_published="character",primary_reference_id="character"))
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,na="",quote=TRUE,fileEncoding="UTF-8")
cat(item_name,":",nrow(final.dataframe),"rows; secondary provenance only, not added to primary merges\n")
