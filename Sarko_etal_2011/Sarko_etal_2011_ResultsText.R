## Sarko et al. (2011), Journal of Comparative Neurology 519:64-74 — Results text.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),stringsAsFactors=FALSE)
append_flag<-function(x,flag)ifelse(!nzchar(x),flag,paste(x,flag,sep="|"))
append_note<-function(x,note)ifelse(!nzchar(x),note,paste(x,note,sep=" "))
total_by_age<-raw$mean_area_mm2[match(raw$age_group,raw$age_group[raw$structure=="total neocortex"])]
clean<-data.frame(
  Species="Onychomys leucogaster",common_name="northern grasshopper mouse",
  age_group=raw$age_group,n=raw$n,structure=raw$structure,
  mean_area_mm2=raw$mean_area_mm2,
  reported_plusminus_area_mm2=raw$sd_area_mm2,
  uncertainty_stat="not stated (SD vs SEM unresolved)",
  approx_pct_neocortex=raw$approx_pct,
  recomputed_pct_neocortex=100*raw$mean_area_mm2/total_by_age,
  where_in_paper=raw$source_location,
  source_flags="uncertainty_stat_not_stated|small_group_n",
  source_issue_note="The paper reports mean +/- values but does not identify them as SD or SEM; juvenile n=2 and adult n=4.",
  source=item_name,stringsAsFactors=FALSE
)
bad_pct<-clean$age_group=="juvenile"&clean$structure=="PMBSF of S1"
clean$source_flags[bad_pct]<-append_flag(clean$source_flags[bad_pct],"printed_percent_arithmetic_mismatch")
clean$source_issue_note[bad_pct]<-append_note(
  clean$source_issue_note[bad_pct],
  "The source prints approximately 5%, but 0.90/36.70 = 2.45%; the printed value is preserved in approx_pct_neocortex."
)
stopifnot(nrow(clean)==6L,!anyNA(clean[c("Species","mean_area_mm2","reported_plusminus_area_mm2")]))
stopifnot(abs(clean$recomputed_pct_neocortex[bad_pct]-100*0.90/36.70)<1e-10)
write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")
