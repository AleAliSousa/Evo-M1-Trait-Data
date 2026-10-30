## Lukas & Clutton-Brock (2013), Science 341:526-530 -- Supplementary Data
## (social organization of 2,545 mammalian species).
##
## Source: a digital-native copy of this exact table, deposited by the authors on KNB
## ("Social systems of mammalian species", doi:10.5063/F1NC5Z4D, entity dieter_lukas.14.1,
## https://knb.ecoinformatics.org/knb/d1/mn/v2/object/dieter_lukas.14.1) -- used instead of
## transcribing lukas.sm.pdf's 66-page printed version of the same table, whose text layer
## extracts out of row order. The untouched download is frozen as the snapshot (md5-verified
## byte-identical) per house convention for digital-native sources -- see README.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

raw<-read.delim(file.path(folder,paste0(item_name,"_snapshot.tsv")),check.names=FALSE,stringsAsFactors=FALSE)
clean<-raw
names(clean)<-c("SpeciesName","Solitary","SocialMonogamy","GroupLiving","PaternalCare","Reference_code")

stopifnot(nrow(clean)==2545L, !anyNA(clean$SpeciesName), !anyNA(clean$Reference_code))

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")
