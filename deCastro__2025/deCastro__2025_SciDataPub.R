## de Castro (2025), Sci Data 12:1589 -- FmrBT dataset (field metabolic rate, body mass,
## ambient temperature; 4,637 records, >700 species).
##
## Source: FieldMR_SciDataPub.xls, sheet "Alldata" -- digital-native supplementary data,
## kept untouched as the frozen source (no derived snapshot) per house convention.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

## IMPORTANT: readxl's default column-type guessing samples only the first rows of each column;
## for "Comment" (mostly blank, text appears later) this silently guesses "logical" and DROPS
## every comment string to NA with no error -- caught during this build (816 comments lost).
## col_types= is specified explicitly for every column to prevent silent data loss recurring.
col_types<-c("text","text","text","text","text","text","text","text","numeric","numeric","numeric","numeric","text","text","numeric")
raw<-readxl::read_excel(file.path(folder,"FieldMR_SciDataPub.xls"),sheet="Alldata",col_types=col_types)
clean<-as.data.frame(raw)
## Renamed Mass_g -> BodyMass_g (source column name kept verbatim nowhere else needs it): the
## __merging_body_ecology auto-harvester matches header names against a "body.?mass" pattern, which
## a bare "Mass_g" does not satisfy -- renaming here (not touching the shared merge script) lets the
## existing BodyMass_g column be auto-picked up as a new "mass" source without special-casing.
names(clean)[names(clean)=="Mass_g"]<-"BodyMass_g"

stopifnot(nrow(clean)==4637L, all(c("SpeciesVerbatim","FMR_kJ_d","BodyMass_g","Endotherm","Reference") %in% names(clean)), !anyNA(clean$SpeciesVerbatim), !anyNA(clean$BodyMass_g), sum(!is.na(clean$Comment) & clean$Comment!="")==816L)

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="NA")
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE,na="NA")else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")
