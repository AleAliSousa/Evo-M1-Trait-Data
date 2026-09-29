## Kaskan et al. (2005), Electronic Appendix A, Table 1
## Input: Kaskan_etal_2005_TableS1_snapshot.xlsx
## Outputs: Kaskan_etal_2005_TableS1.csv and registry-coded public TSV
## The workbook is the frozen snapshot. Its first row contains the table heading
## and the a-t citation key; these are captured in the output columns.

library(readxl)
options(scipen=999)
.sp <- local({
 a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
 if(length(a)) return(normalizePath(sub("^--file=","",a[1])))
 if(requireNamespace("rstudioapi",quietly=TRUE) && rstudioapi::isAvailable()) {
  p <- rstudioapi::getSourceEditorContext()$path
  if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
  if(nzchar(p)) return(normalizePath(p))
 }
 stop("Run with Rscript file.R, or open in RStudio and click Source (save first).",call.=FALSE)
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); setwd(folder)
base <- local({ d<-folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
input <- "Kaskan_etal_2005_TableS1_snapshot.xlsx"
heading <- read_excel(input, range="A1:A1", col_names=FALSE, .name_repair="minimal")[[1]][1]
raw <- read_excel(input,skip=1,.name_repair="minimal")
raw <- raw[,seq_len(13)]
names(raw) <- c("species","common_name_raw","V1","V2","visual_other","A1","R","aud_other","SI_3b","SII","SS_other","M","motor_other")
clean_text <- function(x) { x <- as.character(x); x <- gsub("[\r\n]+"," ",x); x <- gsub("[[:space:]]+", " ", x); trimws(x) }
raw[] <- lapply(raw,clean_text)
## The heading is one wrapped PDF paragraph: it carries a CRLF and runs of spaces
## inside the citation key ("b Preuss & Kaas   (1996)"), so normalise its whitespace
## the same way the table cells are normalised before parsing it. Without this the
## parsed citations keep the printed spacing and stop matching References.csv.
heading <- clean_text(heading)
key <- regmatches(heading,regexpr("References:.*",heading))
## the heading closes "... Krubitzer et al. (1997).)" -- strip the sentence period
## AND the paren closing the parenthetical, in that order.
key <- sub("\\.?\\)$","",key)
refs <- sub("^References:\\s*","",key)
parts <- trimws(strsplit(refs,";",fixed=TRUE)[[1]])
map <- setNames(sub("^[a-t]\\s+","",parts),sub("^([a-t]).*","\\1",parts))
## ref_letters, not letters: `letters` is a base R constant and shadowing it here
## would silently break any later use of it. USE.NAMES=FALSE throughout, or vapply
## names the result by its input and those names become data.frame row names.
ref_letters <- vapply(raw$common_name_raw,function(x) { m<-regexpr("[a-t](,[a-t])?$",x); if(m[1]<0) "" else regmatches(x,m) },character(1),USE.NAMES=FALSE)
common <- mapply(function(x,k) if(nzchar(k)) sub(paste0(k,"$"),"",x,fixed=TRUE) else x,raw$common_name_raw,ref_letters,USE.NAMES=FALSE)
full <- setNames(read.csv("Kaskan_etal_2005_References.csv",check.names=FALSE,stringsAsFactors=FALSE)$full_reference,read.csv("Kaskan_etal_2005_References.csv",check.names=FALSE,stringsAsFactors=FALSE)$ref)
expand_refs <- function(x,lookup) { k<-strsplit(x,",",fixed=TRUE)[[1]]; paste(unname(lookup[k]),collapse="; ") }
## The paper prints "Cryptosis parva" for the least shrew; the accepted binomial is
## Cryptotis parva. Corrected for the join key, printed form kept verbatim alongside,
## as in deSousa_etal_2010 and Finlay_etal_2006.
species_as_published <- raw$species
species_fix <- c("Cryptosis parva"="Cryptotis parva")
species <- ifelse(species_as_published %in% names(species_fix),unname(species_fix[species_as_published]),species_as_published)
clean <- data.frame(species=species,species_as_published=species_as_published,common_name=common,ref=ref_letters,table_heading_citation=vapply(ref_letters,expand_refs,character(1),lookup=map,USE.NAMES=FALSE),full_reference=vapply(ref_letters,expand_refs,character(1),lookup=full,USE.NAMES=FALSE),raw[setdiff(names(raw),c("species","common_name_raw"))],source="Kaskan_etal_2005_TableS1",stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(clean)==30L,length(map)==20L,all(nzchar(clean$species)),all(nzchar(clean$species_as_published)),all(nzchar(clean$ref)),all(nzchar(clean$table_heading_citation)),all(nzchar(clean$full_reference)))
write.csv(clean,paste0(item_name,".csv"),row.names=FALSE,na="NA")
if(!is.na(base)) {
 fc<-read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1"); enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)]; out<-file.path(base,"__Public","comparative-data")
 if(!is.na(enc)&&nzchar(enc)&&dir.exists(out)) write.table(clean,file.path(out,paste0(enc,".tsv")),sep="\t",row.names=FALSE,quote=TRUE,na="NA") else warning("Public TSV skipped.")
}
message(item_name,": ",nrow(clean)," rows written; citations captured from heading")
