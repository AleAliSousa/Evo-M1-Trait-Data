## Plavcan & van Schaik 1997b Table 1: printed primate weights, dimorphism,
## canine size, and competition. Preserve source labels and table order.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp); base <- dirname(folder)
item_name <- sub("\\.R$", "", basename(sp))
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),
                colClasses="character",check.names=FALSE,na.strings=character(),
                stringsAsFactors=FALSE,fileEncoding="UTF-8")
stopifnot(nrow(raw)==87L,ncol(raw)==14L,
          identical(raw$Species[1],"Cercocebus albigena"),
          identical(tail(raw$Species,1),"Saguinus oedipus"))
num <- function(x) {
  x[x %in% c("—","–","")] <- NA_character_
  as.numeric(chartr("·",".",x))
}
out <- data.frame(source_row=seq_len(nrow(raw)),
  species_as_published=raw$Species,Species=raw$Species,
  male_weight_kg=num(raw[[2]]),female_weight_kg=num(raw[[3]]),
  weight_dimorphism_as_printed=num(raw[[4]]),
  mandibular_dim_MD=num(raw[[5]]),mandibular_dim_BL=num(raw[[6]]),
  mandibular_dim_height=num(raw[[7]]),
  maxillary_dim_MD=num(raw[[8]]),maxillary_dim_BL=num(raw[[9]]),
  maxillary_dim_height=num(raw[[10]]),
  male_canine_MD_as_printed=num(raw[[11]]),
  male_canine_BL_as_printed=num(raw[[12]]),
  male_canine_height_as_printed=num(raw[[13]]),
  competition_level_as_printed=num(raw[[14]]),
  stringsAsFactors=FALSE,check.names=FALSE)
## The printed body-weight ratio is an internal transcription check, not a
## replacement for the source value. Rounding of kg and ratio is expected.
calculated_ratio <- out$male_weight_kg/out$female_weight_kg
delta <- abs(out$weight_dimorphism_as_printed-calculated_ratio)
table_checks <- data.frame(
  check_id=paste0("weight_ratio_row_",seq_len(nrow(out))),
  basis="male_weight_kg/female_weight_kg",
  observed=calculated_ratio,printed=out$weight_dimorphism_as_printed,
  difference=delta,tolerance=0.02,
  status=ifelse(delta<=0.02,"pass","warn"),
  note="Printed weights and ratio are rounded; no source value changed",
  stringsAsFactors=FALSE)
if (any(table_checks$status!="pass")) warning("Printed weight-ratio check exceeded tolerance")
stopifnot(!anyNA(out$male_weight_kg),!anyNA(out$female_weight_kg),
          !anyNA(out$weight_dimorphism_as_printed))
write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
  message("Public TSV: ",code,".tsv")
} else message(item_name,": analysis CSV built; public TSV pending registry code")
message(item_name,": ",nrow(out)," table rows; ratio checks ",
        sum(table_checks$status=="pass"),"/",nrow(table_checks),
        "; max difference ",signif(max(table_checks$difference),4))
