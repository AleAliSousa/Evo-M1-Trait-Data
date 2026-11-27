args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
root <- dirname(folder)
item <- 'Frost_Masterton_1994_Figure3'
s <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),stringsAsFactors=FALSE)
stopifnot(nrow(s)==18L,identical(s$source_order,1:18),identical(unique(s$series_code),c('d','e')))
value <- round((s$source_pixel_y_zero-s$source_pixel_y)/(s$source_pixel_y_zero-s$source_pixel_y_90)*90,1)
out <- data.frame(source_order=s$source_order,Species=s$species_as_published,
                  series_code=s$series_code,frequency_kHz=s$frequency_kHz,
                  detection_threshold_dB_SPL=value,note='approximate figure digitization',
                  source_page=s$source_page,stringsAsFactors=FALSE)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMe.xlsx'),sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']]==item)
stopifnot(length(hit)==1L)
code <- reg[['Item encoded']][hit]
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,':',nrow(out),'points ->',code,'\n')
