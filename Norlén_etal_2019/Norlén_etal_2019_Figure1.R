args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
root <- dirname(folder)
item <- 'Norlén_etal_2019_Figure1'
s <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),stringsAsFactors=FALSE)
stopifnot(nrow(s)==92L, identical(unique(s$panel),c('Sucrose','Fructose','Glucose','Maltose','Lactose')),
          all(s$series_symbol %in% c('circle','square','triangle')))
out <- data.frame(source_order=seq_len(nrow(s)),Species='Pan troglodytes verus',
                  sugar=s$panel,series_symbol=s$series_symbol,
                  point_order=s$point_order,
                  concentration_mM=round(10^(1+2*(s$source_pixel_x-s$x_at_10mM)/(s$x_at_1000mM-s$x_at_10mM)),1),
                  preference_percent=round(40+60*(s$y_at_40percent-s$source_pixel_y)/(s$y_at_40percent-s$y_at_100percent),1),
                  source_pdf_page=s$source_pdf_page,
                  measurement_note='approximate plotted-point digitization; animal identity not printed',
                  stringsAsFactors=FALSE)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMe.xlsx'),sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']]==item)
stopifnot(length(hit)==1L)
code <- reg[['Item encoded']][hit]
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,':',nrow(out),'plotted points ->',code,'\n')
