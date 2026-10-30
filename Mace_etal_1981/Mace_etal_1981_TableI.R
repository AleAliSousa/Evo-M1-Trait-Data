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

snap <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE,colClasses="character",fileEncoding="UTF-8-BOM",na.strings=NULL)
stopifnot(nrow(snap)==278L)
rs <- resolve_species(snap$species_as_printed,source_publication=basename(folder))
final.dataframe <- data.frame(Species=rs$accepted_name,species_as_published=snap$species_as_printed,
 source_row=as.integer(snap$source_row),source_pdf_page=as.integer(snap$source_pdf_page),
 order_as_published=snap$order_as_printed,family_as_published=snap$family_as_printed,
 ecology_as_published=snap$ecology_as_printed,
 body_mass_g=num(snap$body_weight_g_as_printed),body_length_mm=num(snap$body_length_mm_as_printed),
 brain_weight_estimate_mg=num(snap$brain_weight_g_as_printed)*1000,
 brain_weight_g_as_published=snap$brain_weight_g_as_printed,
 body_weight_g_as_published=snap$body_weight_g_as_printed,body_length_mm_as_published=snap$body_length_mm_as_printed,
 brain_measurement_basis="endocranial_volume_to_weight_estimate",brain_value_role="derived_estimate_from_own_skull_measurements",
 brain_original_measurement_source="Mace et al. 1981",brain_method="glass beads or skull X-rays; not identified per row",
 conversion_to_grams="not specified in this table; do not invert with an assumed density",
 brain_source_reference_id="doi:10.1111/j.1469-7998.1981.tb03449.x",brain_source_ref_keys="Mace et al. 1981",
 brain_method_ref_keys="Jerison 1969; Jerison 1973",ecology_source_ref_keys="Mace 1979",
 body_source_scope="published literature; no per-row citations supplied",
 data_role="secondary",primary_pool_eligible=FALSE,
 species_basis=rs$species_basis,reidentified=rs$reidentified,
 check.names=FALSE,stringsAsFactors=FALSE)
## The later 0.59 g rodent correction is NOT applied to the published snapshot or output.
## Original paper reports 261 species in the regression; the table also lists 17
## species without body mass. This count is a coverage check, not an arithmetic total.
stopifnot(sum(!is.na(final.dataframe$body_mass_g))==261L,
          !anyNA(final.dataframe$brain_weight_estimate_mg),
          final.dataframe$brain_weight_estimate_mg[1]==7630)

write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,na="",quote=TRUE,fileEncoding="UTF-8")
cat(item_name,":",nrow(final.dataframe),"rows; secondary provenance only, not added to primary merges\n")
