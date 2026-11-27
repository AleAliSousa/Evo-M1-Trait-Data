args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
root <- dirname(folder)
item <- 'Stensaas_etal_1974_Tables1to4'
s <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),stringsAsFactors=FALSE,check.names=FALSE,colClasses='character')
stopifnot(nrow(s)==21L,identical(as.integer(s$source_order),1:21),
          identical(names(table(s$table_number)),c('1','2','3','4')),
          identical(as.integer(table(s$table_number)),c(8L,3L,5L,5L)))
number <- function(x) suppressWarnings(as.numeric(ifelse(nzchar(x) & x!='?',x,NA_character_)))
scale <- ifelse(s$area_unit_as_printed=='cm2/hemisphere',100,1)
out <- data.frame(source_order=as.integer(s$source_order),table_number=as.integer(s$table_number),
                  source_pdf_page=as.integer(s$source_pdf_page),source_print_page=as.integer(s$source_print_page),
                  Species='Homo sapiens',entry_as_printed=s$entry_as_printed,
                  source_study=s$source_study,source_role=s$source_role,
                  area_unit_as_printed=s$area_unit_as_printed,
                  average_area_as_printed=s$average_area_as_printed,
                  low_area_as_printed=s$low_area_as_printed,
                  high_area_as_printed=s$high_area_as_printed,
                  average_area_mm2=number(s$average_area_as_printed)*scale,
                  low_area_mm2=number(s$low_area_as_printed)*scale,
                  high_area_mm2=number(s$high_area_as_printed)*scale,
                  average_percent=number(s$average_percent_as_printed),
                  low_percent=number(s$low_percent_as_printed),
                  high_percent=number(s$high_percent_as_printed),
                  n_hemispheres_as_printed=s$n_hemispheres_as_printed,
                  source_note=s$source_note,stringsAsFactors=FALSE)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMe.xlsx'),sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']]==item)
stopifnot(length(hit)==1L)
code <- reg[['Item encoded']][hit]
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,':',nrow(out),'source table rows ->',code,'\n')
