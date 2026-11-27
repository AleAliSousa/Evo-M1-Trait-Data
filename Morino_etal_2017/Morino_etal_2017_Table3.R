## Morino et al. 2017 Table 3: hand-preference subsets, with secondary row kept.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=","",a[1]))
folder <- dirname(sp);base <- dirname(folder)
item_name <- sub("\\.R$","",basename(sp))
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),
                colClasses="character",check.names=FALSE,na.strings=character(),
                stringsAsFactors=FALSE,fileEncoding="UTF-8")
stopifnot(nrow(raw)==7L,ncol(raw)==6L,
          identical(names(raw),c("Data subset","No. L","No. R","No. A","Mean HI-Freq.","SE")))
num <- function(x) as.numeric(chartr("−","-",x))
for(j in 2:4) stopifnot(all(grepl("^[0-9]+$",raw[[j]])))
stopifnot(all(grepl("^−[0-9]+\\.[0-9]{2}$",raw[[5]])),
          all(grepl("^[0-9]+\\.[0-9]{2}$",raw[[6]])))
is_siamang <- grepl("[Ss]iamangs",raw[[1]]) & !grepl("Non-",raw[[1]])
is_secondary <- grepl("ᵃ",raw[[1]],fixed=TRUE)
out <- data.frame(source_row=seq_len(nrow(raw)),
  data_subset_as_printed=raw[[1]],
  species_as_published=ifelse(is_siamang,"siamangs","mixed hylobatids"),
  Species=ifelse(is_siamang,"Symphalangus syndactylus",NA_character_),
  n_left_handed=as.integer(raw[[2]]),n_right_handed=as.integer(raw[[3]]),
  n_ambiguous=as.integer(raw[[4]]),
  n_classified=as.integer(raw[[2]])+as.integer(raw[[3]])+as.integer(raw[[4]]),
  mean_frequency_handedness_index=num(raw[[5]]),SE=num(raw[[6]]),
  source_role=ifelse(is_secondary,"secondary: Morino 2011","primary: Morino 2017"),
  stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(all(is.finite(out$mean_frequency_handedness_index)),
          all(out$mean_frequency_handedness_index>=-1 & out$mean_frequency_handedness_index<=1),
          identical(out$n_classified[1],37L),sum(is_secondary)==1L)
write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": 7 overlapping subsets; 1 secondary-source row")
