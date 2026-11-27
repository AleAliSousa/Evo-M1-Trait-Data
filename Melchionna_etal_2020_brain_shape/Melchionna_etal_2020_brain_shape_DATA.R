## Melchionna et al. (2020), brain-shape supplement: deposited ECV vector.
## Reads untouched public Zenodo DATA.rda; source order and source codes retained.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
.sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp))
base <- dirname(folder)
frozen <- file.path(folder,"DATA.rda")
e <- new.env(parent=emptyenv())
objects <- load(frozen,envir=e)
stopifnot("volumes" %in% objects, is.numeric(e$volumes), length(e$volumes)==123L,
          length(names(e$volumes))==123L, "set" %in% objects,
          identical(names(e$volumes),dimnames(e$set)[[3]]))
map <- read.csv(file.path(folder,"reference_tables",paste0(item_name,"_source_code_map.csv")),
                stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(map)==19L, !anyDuplicated(map$source_code),
          setequal(unique(names(e$volumes)),map$source_code))
source_code <- names(e$volumes)
species_as_published <- map$species_as_published[match(source_code,map$source_code)]
stopifnot(!anyNA(species_as_published))
within_code_index <- ave(seq_along(source_code),source_code,FUN=seq_along)
final.dataframe <- data.frame(
  source_vector_index=seq_along(e$volumes),
  source_code=source_code,
  within_source_code_index=as.integer(within_code_index),
  species_as_published=species_as_published,
  Species=species_as_published,
  species_basis="author_script_label; not taxonomically revised",
  ECV_value_as_deposited=as.numeric(e$volumes),
  ECV_unit="not stated in data deposit or article",
  specimen_id=NA_character_,
  stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(final.dataframe)==123L, length(unique(final.dataframe$source_code))==19L,
          all(is.finite(final.dataframe$ECV_value_as_deposited)),
          all(final.dataframe$ECV_value_as_deposited>0))
options(digits=17)
write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(final.dataframe,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": 123 deposited values in 19 source-code groups; units unresolved")
