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

snap <- read.delim(file.path(folder,paste0(item_name,"_snapshot.txt")),check.names=FALSE,
 colClasses="character",stringsAsFactors=FALSE,na.strings=NULL,fileEncoding="ASCII")
stopifnot(nrow(snap)==313L,ncol(snap)==13L,!anyDuplicated(snap$Species))
rs <- resolve_species(snap$Species,source_publication=basename(folder))
final.dataframe <- data.frame(Species=rs$accepted_name,species_as_published=snap$Species,
 family_as_published=snap$Family,source_row=seq_len(nrow(snap)),source_text_line=seq_len(nrow(snap))+1L,
 body_mass_g=num(snap[[3]]),brain_mass_mg=num(snap[[4]]),bmr_mLO2_hr=num(snap[[5]]),
 intestine_length_mm=num(snap[[6]]),gestation_length_days=num(snap[[7]]),diet_code=num(snap[[8]]),
 body_mass_g_as_published=snap[[3]],brain_mass_mg_as_published=snap[[4]],bmr_mLO2_hr_as_published=snap[[5]],
 intestine_length_mm_as_published=snap[[6]],gestation_length_days_as_published=snap[[7]],diet_code_as_published=snap[[8]],
 body_brain_ref_keys=snap[[9]],bmr_ref_keys=snap[[10]],intestine_ref_keys=snap[[11]],gestation_ref_keys=snap[[12]],diet_ref_keys=snap[[13]],
 brain_measurement_basis="mass_reported_by_compiler",brain_preparation_state="not_supplied_per_row",
 brain_value_role="secondary_species_mean",sex_scope="combined males and nonpregnant females per Methods; no per-row sex",
 source_granularity="joint_body_and_brain_source_list_not_partitioned_by_value",primary_reference_id="",
 data_role="secondary",primary_pool_eligible=FALSE,species_basis=rs$species_basis,reidentified=rs$reidentified,
 check.names=FALSE,stringsAsFactors=FALSE)
## Preserve the actual supplement: it has 90 gestation values and no weaning column,
## despite the main Methods reporting 96 and 86 respectively. No values are inferred.
stopifnot(sum(!is.na(final.dataframe$brain_mass_mg))==313L,
          sum(!is.na(final.dataframe$bmr_mLO2_hr))==69L,
          sum(!is.na(final.dataframe$intestine_length_mm))==51L,
          sum(!is.na(final.dataframe$gestation_length_days))==90L,
          sum(!is.na(final.dataframe$diet_code))==312L,
          all(na.omit(final.dataframe$diet_code) %in% c(0,1)))
write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
status <- system2(Sys.which("python3"), shQuote(file.path(folder,"Jones_MacLarnon_2004_build_references.py")))
stopifnot(status==0L)

write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,na="",quote=TRUE,fileEncoding="UTF-8")
cat(item_name,":",nrow(final.dataframe),"rows; secondary provenance, excluded from primary pooling\n")
