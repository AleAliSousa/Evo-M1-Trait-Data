args <- grep('^--file=', commandArgs(FALSE), value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=', '', args[1])))
root <- dirname(folder)
item <- 'Westergaard_Hyatt_1994_Figure2'
s <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(s)==6L,identical(s$source_order,1:6),all(s$source_pixel_y_40<s$source_pixel_y_zero))
value <- round((s$source_pixel_y_zero-s$source_pixel_y_bar_end)/(s$source_pixel_y_zero-s$source_pixel_y_40)*40,1)
out <- data.frame(source_order=s$source_order,Species='Pan paniscus',n_subjects=9L,
                  behavior_as_published=s$behavior_as_published,
                  relative_duration_difference_score=value,
                  unit='percentage points of relative duration; mirror-on minus mirror-off',
                  significant_p_lt_0.05=s$significance_star=='yes',
                  extraction=ifelse(is.na(value),'no discernible bar; value not assigned','approximate from plotted bar; 170-dpi PDF render'),
                  source_page=s$source_page,stringsAsFactors=FALSE)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMe.xlsx'),sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']]==item)
stopifnot(length(hit)==1L)
code <- reg[['Item encoded']][hit]
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,':',sum(!is.na(value)),'visible bars ->',code,'\n')
