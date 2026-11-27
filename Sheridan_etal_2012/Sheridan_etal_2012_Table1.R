## Sheridan et al. (2012): printed MRI-volume association coefficients.
## The same reader is used by the separate Table 1 and Table 2 item scripts;
## each reads only its own frozen table snapshot.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
.sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp))
base <- dirname(folder)
frozen <- file.path(folder,paste0(item_name,"_snapshot.csv"))
raw <- read.csv(frozen,colClasses="character",check.names=FALSE,na.strings=character(),
                stringsAsFactors=FALSE,fileEncoding="UTF-8")
stopifnot(ncol(raw)==4L, nrow(raw) %in% c(8L,12L))
table_number <- sub("^.*_Table", "", item_name)
stopifnot(table_number %in% c("1","2"))
structures <- if (table_number=="1") c("Gray matter","White matter") else
  c("Anterior CC","Central CC","Posterior CC")
stopifnot(identical(raw[[1]][!raw[[1]] %in% c("EIG","CAU","FCG")],structures))
read_cell <- function(x) {
  y <- chartr("−","-",gsub("†","",x,fixed=TRUE))
  stopifnot(grepl("^-?[0-9]+\\.[0-9]+ \\([0-9]+\\.[0-9]+\\)$",y))
  c(beta=as.numeric(sub(" \\(.*$","",y)),
    SE=as.numeric(sub("^.*\\(([0-9]+\\.[0-9]+)\\)$","\\1",y)))
}
out <- list(); structure <- NA_character_
for (i in seq_len(nrow(raw))) {
  label <- raw[[1]][i]
  if (label %in% structures) {structure <- label; next}
  stopifnot(label %in% c("EIG","CAU","FCG"), !is.na(structure))
  for (j in 2:4) {
    x <- raw[[j]][i]
    if (!nzchar(x)) next
    v <- read_cell(x)
    model <- j-1L
    out[[length(out)+1L]] <- data.frame(
      source_row=i+1L, structure_as_printed=structure, group_as_printed=label,
      reference_group="NIG", model=model,
      model_covariates=if (model<3L) "none reported in table" else
        if (table_number=="1") "age; sex" else "age; sex; total brain volume",
      beta_as_printed=x, beta=unname(v["beta"]), SE=unname(v["SE"]),
      significant_at_0_05=grepl("†",x,fixed=TRUE),
      beta_unit="not stated in table", species_as_published="human",
      Species="Homo sapiens", stringsAsFactors=FALSE,check.names=FALSE)
  }
}
final.dataframe <- do.call(rbind,out)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe)==if (table_number=="1") 10L else 15L,
          all(is.finite(final.dataframe$beta)), all(is.finite(final.dataframe$SE)))
write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(final.dataframe,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": ",nrow(final.dataframe)," printed coefficient cells")
