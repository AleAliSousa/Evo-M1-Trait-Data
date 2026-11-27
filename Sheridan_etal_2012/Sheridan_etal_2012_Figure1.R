## Pixel-calibrated reading of Fig. 1; source image is on PDF page 2.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R", call.=FALSE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp); item_name <- sub("\\.R$", "", basename(sp))
base <- dirname(folder)
raw <- read.csv(file.path(folder, paste0(item_name,"_snapshot.csv")),
                stringsAsFactors=FALSE, check.names=FALSE)
stopifnot(nrow(raw)==3L, identical(raw$group_as_printed,c("CAU","FCG","NIG")),
          all(raw$axis_y400_pixel==447),all(raw$axis_y600_pixel==82))
to_cc <- function(y) 400+(447-y)*200/(447-82)
out <- data.frame(source_order=raw$source_order,
  group_as_printed=raw$group_as_printed, reference_group="NIG",
  structure_as_printed="Total cortical grey matter",
  volume_cc=to_cc(raw$bar_top_pixel),
  lower_SEM_cap_cc=to_cc(raw$sem_lower_cap_pixel),
  upper_SEM_cap_cc=to_cc(raw$sem_upper_cap_pixel),
  error_bar_type="±1 SEM", reading_method="manual pixel calibration",
  source_pdf_page=2L, species_as_published="human", Species="Homo sapiens",
  stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(all(out$lower_SEM_cap_cc<out$volume_cc),
          all(out$upper_SEM_cap_cc>out$volume_cc))
write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",
          fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
