## Wei et al. 2019: 114 deposited cortical parcels, source values unchanged.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp); base <- dirname(folder)
item_name <- sub("\\.R$", "", basename(sp))
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),
                check.names=FALSE,stringsAsFactors=FALSE,
                colClasses="character",na.strings=character())
stopifnot(nrow(raw)==114L,identical(names(raw),c("Regions","RSN","Expansion")),
          !anyDuplicated(raw$Regions),all(nzchar(raw$Regions)),all(nzchar(raw$RSN)))
expansion <- as.numeric(raw$Expansion)
stopifnot(!anyNA(expansion),all(is.finite(expansion)),all(expansion>0))
out <- data.frame(source_row=seq_len(nrow(raw)),
  region_as_deposited=raw$Regions,network_as_deposited=raw$RSN,
  expansion_as_deposited=raw$Expansion,expansion_ratio=expansion,
  numerator_species="Homo sapiens",denominator_species="Pan troglodytes",
  Species=NA_character_,stringsAsFactors=FALSE,check.names=FALSE)
write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
  message("Public TSV: ",code,".tsv")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": 114 deposited cortical parcels across ",
        length(unique(out$network_as_deposited))," networks")
