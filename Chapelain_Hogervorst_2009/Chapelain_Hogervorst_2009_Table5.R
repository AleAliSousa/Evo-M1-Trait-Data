## One reader per source table: 29 bonobos, same subjects across Tables 4–6.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=","",a[1]))
folder <- dirname(sp);base <- dirname(folder)
item_name <- sub("\\.R$","",basename(sp))
number <- sub("^.*_Table","",item_name)
stopifnot(number %in% c("4","5","6"))
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),
                colClasses="character",check.names=FALSE,na.strings=character(),
                stringsAsFactors=FALSE,fileEncoding="UTF-8")
stopifnot(nrow(raw)==30L,ncol(raw)==9L,
          identical(raw$Individuals[30],"Total/mean"),
          identical(raw$Individuals[1],"Jasiri"),
          identical(raw$Individuals[29],"Luo"))
d <- raw[1:29,,drop=FALSE]
num <- function(x) as.numeric(chartr("−","-",x))
out <- data.frame(source_row=seq_len(nrow(d)),
  zoo_as_printed=d$Zoo,individual_as_printed=d$Individuals,
  species_as_published="bonobos",Species="Pan paniscus",
  response_series=if(number=="4") "frequency" else if(number=="5") "bouts" else "first_50_frequency",
  right_count=as.integer(d$Right),left_count=as.integer(d$Left),
  total_count_as_printed=as.integer(d$Total),
  HI_as_printed=d$HI,HI=num(d$HI),
  ABSHI_as_printed=d$ABSHI,ABSHI=num(d$ABSHI),
  binomial_p_as_printed=d[["Binomial test"]],
  binomial_p=num(d[["Binomial test"]]),
  handedness_category_as_printed=d$Category,
  stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(!anyNA(out[c("right_count","left_count","total_count_as_printed","HI","ABSHI","binomial_p")] ),
          all(out$right_count+out$left_count==out$total_count_as_printed))
ratio <- (out$right_count-out$left_count)/out$total_count_as_printed
stopifnot(all(abs(ratio-out$HI)<0.001),all(abs(abs(out$HI)-out$ABSHI)<0.001))
printed_totals <- as.integer(unlist(raw[30,c("Right","Left","Total")]))
stopifnot(identical(unname(as.integer(colSums(out[c("right_count","left_count","total_count_as_printed")]))),
                    printed_totals))
if (any(out$binomial_p>1))
  warning("Source has binomial p > 1; retained as printed: ",
          paste(out$individual_as_printed[out$binomial_p>1],collapse=", "))
write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": 29 bonobos; printed count totals and HI ratios checked")
