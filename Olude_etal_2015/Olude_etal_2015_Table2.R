## Olude et al. 2015 Table 2: source astrocyte counts with SEM by age group.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp);base <- dirname(folder)
item_name <- sub("\\.R$", "", basename(sp))
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),
                colClasses="character",check.names=FALSE,na.strings=character(),
                stringsAsFactors=FALSE,fileEncoding="UTF-8")
stopifnot(nrow(raw)==17L,identical(names(raw),c("Brain region","Juvenile","Adult")))
parse_cell <- function(x) {
  stopifnot(all(grepl("^[0-9]+\\.[0-9]{2} ± [0-9]+\\.[0-9]{2}$",x)))
  cbind(mean=as.numeric(sub(" ±.*$","",x)),
        SEM=as.numeric(sub("^.*± ","",x)))
}
j <- parse_cell(raw$Juvenile);a <- parse_cell(raw$Adult)
out <- data.frame(source_row=seq_len(nrow(raw)),
  species_as_published="Cricetomys gambianus",Species="Cricetomys gambianus",
  brain_region_as_printed=raw[[1]],
  significant_juvenile_adult_at_p_0_01=grepl("∗",raw[[1]],fixed=TRUE),
  juvenile_mean_astrocyte_count=j[,"mean"],juvenile_SEM=j[,"SEM"],
  adult_mean_astrocyte_count=a[,"mean"],adult_SEM=a[,"SEM"],
  n_juvenile_animals=5L,n_adult_animals=5L,
  count_basis="right-hemisphere sagittal sections; not cells per mm3",
  stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(all(is.finite(out$juvenile_mean_astrocyte_count)),
          all(is.finite(out$adult_mean_astrocyte_count)),
          sum(out$significant_juvenile_adult_at_p_0_01)==7L)
write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": 17 regions; 7 printed significance marks")
